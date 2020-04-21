function my-ip 
    command http http://ipinfo.io/ | python -c 'import sys, yaml, json; yaml.safe_dump(json.load(sys.stdin), sys.stdout, default_flow_style=False)'
    command echo
end