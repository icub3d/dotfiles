#!/usr/bin/env nu
# Health report for the two Pi-holes: the Pi (primary, 192.168.86.29) and the
# k8s replica (namespace pihole, LB 192.168.86.194, synced by nebula-sync).
#
#   nu helpers/pihole-health.nu            # human report
#   nu helpers/pihole-health.nu --hours 6  # usage window (default 24)
#   nu helpers/pihole-health.nu --json     # raw record for further processing
#
# Checks: (1) sync — adlists/groups/domains/clients identical on both and the
# last nebula-sync run succeeded; (2) resolve — both answer UDP and TCP, block
# a known ad domain, serve the sw.marsh.gg wildcard and the `k8s` API name;
# (3) usage — totals, block rate, top blocked domains and top clients.

const PI = "192.168.86.29"
const REPLICA = "192.168.86.194"
const BLOCKED = "(1,4,5,6,7,8,9,10,11,15,16,18)"  # FTL statuses Pi-hole itself counts as blocked; 17 = CACHE_STALE is not

# Run a read-only SQL query on one instance; returns a table. SQL goes over
# stdin so quoting never fights the remote nushell/bash layers.
def pi-sql [where: string, db: string, sql: string] {
  let out = if $where == "pi" {
    $sql | ssh pihole $"sudo -n pihole-FTL sqlite3 -json /etc/pihole/($db)"
  } else {
    $sql | kubectl -n pihole exec -i deploy/pihole -- pihole-FTL sqlite3 -json $"/etc/pihole/($db)"
  }
  if ($out | str trim | is-empty) { [] } else { $out | from json }
}

def resolve [server: string, name: string, --tcp] {
  let args = if $tcp { ["+short" "+tcp" "+time=3" "+tries=1"] } else { ["+short" "+time=3" "+tries=1"] }
  try { dig ...$args $"@($server)" $name A | lines | first | default "" } catch { "" }
}

def resolve-checks [server: string] {
  [
    { check: "resolves google.com", got: (resolve $server google.com), ok: null, want: "an IP" }
    { check: "blocks ad.doubleclick.net", got: (resolve $server ad.doubleclick.net), ok: null, want: "0.0.0.0" }
    { check: "wildcard forgejo.sw.marsh.gg", got: (resolve $server forgejo.sw.marsh.gg), ok: null, want: "192.168.86.192" }
    { check: "k8s API name", got: (resolve $server k8s), ok: null, want: "192.168.86.38" }
    { check: "TCP github.com", got: (resolve $server github.com --tcp), ok: null, want: "an IP" }
  ] | each {|r|
    let ok = if $r.want == "an IP" { ($r.got =~ '^\d+\.\d+\.\d+\.\d+$') and $r.got != "0.0.0.0" } else { $r.got == $r.want }
    $r | update ok $ok
  }
}

def sync-state [where: string] {
  {
    adlists: (pi-sql $where gravity.db "select id, address, enabled, number from adlist order by id")
    groups: (pi-sql $where gravity.db "select count(*) n from 'group'" | get 0.n)
    domains: (pi-sql $where gravity.db "select count(*) n from domainlist" | get 0.n)
    clients: (pi-sql $where gravity.db "select count(*) n from client" | get 0.n)
    gravity: (pi-sql $where gravity.db "select count(*) n from gravity" | get 0.n)
    last_gravity: (pi-sql $where gravity.db "select datetime(max(date_updated),'unixepoch','localtime') t from adlist" | get 0.t)
  }
}

def usage [where: string, hours: int] {
  let since = $"strftime\('%s','now'\) - ($hours * 3600)"
  let tot = pi-sql $where pihole-FTL.db $"select count\(*\) total, sum\(case when status in ($BLOCKED) then 1 else 0 end\) blocked, count\(distinct client\) clients from queries where timestamp > ($since)" | get 0
  {
    total: $tot.total
    blocked: ($tot.blocked | default 0)
    pct_blocked: (if $tot.total > 0 { (($tot.blocked | default 0) * 100 / $tot.total | math round --precision 1) } else { 0 })
    clients: $tot.clients
    top_blocked: (pi-sql $where pihole-FTL.db $"select domain, count\(*\) n from queries where timestamp > ($since) and status in ($BLOCKED) group by domain order by n desc limit 10")
    top_clients: (pi-sql $where pihole-FTL.db $"select client, count\(*\) n, sum\(case when status in ($BLOCKED) then 1 else 0 end\) blocked from queries where timestamp > ($since) group by client order by n desc limit 10")
    top_permitted: (pi-sql $where pihole-FTL.db $"select domain, count\(*\) n from queries where timestamp > ($since) and status not in ($BLOCKED) group by domain order by n desc limit 10")
  }
}

def nebula-last [] {
  let log = try { kubectl -n pihole logs deploy/nebula-sync --tail=200 } catch { "" }
  let lines = $log | lines | where ($it =~ "Sync completed") or ($it =~ "Sync failed")
  let last = $lines | last | default ""
  {
    status: (if ($last =~ "completed") { "ok" } else if ($last =~ "failed") { "FAILED" } else { "unknown" })
    at: ($last | parse --regex '(?P<t>\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})' | get 0?.t | default "")
    line: ($last | ansi strip)
  }
}

def main [--hours: int = 24, --json] {
  let pi = { sync: (sync-state pi), resolve: (resolve-checks $PI), usage: (usage pi $hours) }
  let rep = { sync: (sync-state replica), resolve: (resolve-checks $REPLICA), usage: (usage replica $hours) }
  let nebula = nebula-last
  let in_sync = (
    ($pi.sync.adlists | select id address enabled) == ($rep.sync.adlists | select id address enabled)
    and $pi.sync.groups == $rep.sync.groups
    and $pi.sync.domains == $rep.sync.domains
    and $pi.sync.clients == $rep.sync.clients
    and $pi.sync.gravity == $rep.sync.gravity
  )
  let report = {
    in_sync: $in_sync
    nebula_sync: $nebula
    pi: $pi
    replica: $rep
    all_resolve_ok: (($pi.resolve | all {|r| $r.ok}) and ($rep.resolve | all {|r| $r.ok}))
  }
  if $json { return ($report | to json) }

  print $"(ansi default_bold)== Sync(ansi reset)  in_sync=($in_sync)  nebula-sync last run: ($nebula.status) ($nebula.at)"
  print ([
    { what: "adlists", pi: ($pi.sync.adlists | length), replica: ($rep.sync.adlists | length) }
    { what: "gravity domains", pi: $pi.sync.gravity, replica: $rep.sync.gravity }
    { what: "groups", pi: $pi.sync.groups, replica: $rep.sync.groups }
    { what: "domain rules", pi: $pi.sync.domains, replica: $rep.sync.domains }
    { what: "clients", pi: $pi.sync.clients, replica: $rep.sync.clients }
    { what: "last gravity", pi: $pi.sync.last_gravity, replica: $rep.sync.last_gravity }
  ] | table)
  if not $in_sync {
    print "adlists on pi:"; print ($pi.sync.adlists | table)
    print "adlists on replica:"; print ($rep.sync.adlists | table)
  }
  print $"\n(ansi default_bold)== Resolve(ansi reset)"
  print ($pi.resolve | insert server "pi" | append ($rep.resolve | insert server "replica") | select server check ok got | table)
  print $"\n(ansi default_bold)== Usage, last ($hours)h(ansi reset)"
  print ([
    { instance: "pi", queries: $pi.usage.total, blocked: $pi.usage.blocked, pct: $pi.usage.pct_blocked, clients: $pi.usage.clients }
    { instance: "replica", queries: $rep.usage.total, blocked: $rep.usage.blocked, pct: $rep.usage.pct_blocked, clients: $rep.usage.clients }
  ] | table)
  print "top blocked (pi):"; print ($pi.usage.top_blocked | table)
  print "top blocked (replica):"; print ($rep.usage.top_blocked | table)
  print "top clients (pi):"; print ($pi.usage.top_clients | table)
  print "top clients (replica):"; print ($rep.usage.top_clients | table)
}
