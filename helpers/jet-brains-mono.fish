#!/usr/bin/fish

if test ! -d ~/.local/share/fonts
  mkdir jet-brains-mono
  pushd jet-brains-mono

  wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/JetBrainsMono.zip
  unzip JetBrainsMono.zip

  mkdir -p ~/.local/share/fonts
  mv *.ttf ~/.local/share/fonts

  fc-cache -f -v

  popd
  rm -rf jet-brains-mono
end
