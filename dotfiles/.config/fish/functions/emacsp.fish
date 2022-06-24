function emacsp
	set NAME (basename $PWD)
    emacs --eval "(persp-switch \"$NAME\")"  $argv
end
