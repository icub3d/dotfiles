function screenshot-clipboard
	maim -g (slop) - | xclip -selection clipboard -t image/png -i
end
