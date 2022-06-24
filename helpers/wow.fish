#!/usr/bin/fish

mkdir -p ~/dev
if not test -f ~/dev/strongbox.jar
	http -F https://github.com/ogri-la/strongbox/releases/download/3.2.1/strongbox-3.2.1-standalone.jar > ~/dev/strongbox.jar
end

if not test -d ~/dev/WoW-Cache
	git clone https://github.com/Bromeego/WoW-Cache ~/dev/WoW-Cache
end

pushd ~/dev/WoW-Cache
git pull
popd

pushd ~/Games/world-of-warcraft/drive_c/Program\ Files\ \(x86\)/World\ of\ Warcraft/_retail_/
rm -rf Cache
unzip ~/dev/WoW-Cache/Retail-Cache.zip
popd
