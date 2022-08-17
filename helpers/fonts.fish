#!/usr/bin/env fish

mkdir -p ~/.local/share/fonts JetBrainsMono

wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/JetBrainsMono.zip
unzip -d JetBrainsMono JetBrainsMono.zip

pushd JetBrainsMono
ls | while read font
  cp $font ~/.local/share/fonts
end

sudo fc-cache -fv
popd
rm -rf JetBrainsMono.zip JetBrainsMono
