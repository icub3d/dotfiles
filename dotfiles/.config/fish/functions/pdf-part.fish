function pdf-part
	pdftk $argv[1] cat $argv[2] output $argv[3]
end
