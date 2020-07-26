#!/usr/bin/fish

mkdir -p ~/dev
if not test -f ~/dev/strongbox.jar
	http -F https://github.com/ogri-la/strongbox/releases/download/1.1.0/strongbox-1.1.0-standalone.jar > ~/dev/strongbox.jar
end

if not test -d ~/WoW-Cache
	git clone https://github.com/Bromeego/WoW-Cache ~/WoW-Cache
end

pushd ~/WoW-Cache
git pull
popd

pushd ~/Games/world-of-warcraft/drive_c/Program\ Files\ \(x86\)/World\ of\ Warcraft/_retail_/
rm -rf Cache
unzip ~/WoW-Cache/Retail-Cache.zip
popd
