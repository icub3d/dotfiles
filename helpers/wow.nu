#!/usr/bin/env nu

mkdir ~/dev
if (not ("~/dev/strongbox.jar" | path exists)) {
	http get https://github.com/ogri-la/strongbox/releases/download/3.2.1/strongbox-3.2.1-standalone.jar | save ~/dev/strongbox.jar
}

if (not ("~/dev/WoW-Cache" | path exists)) {
	git clone https://github.com/Bromeego/WoW-Cache ~/dev/WoW-Cache
}

cd ~/dev/WoW-Cache
git pull
popd

cd /data/lutris/world-of-warcraft/drive_c/Program\ Files\ \(x86\)/World\ of\ Warcraft/_retail_/
rm -rf Cache
unzip ~/dev/WoW-Cache/Retail-Cache.zip
