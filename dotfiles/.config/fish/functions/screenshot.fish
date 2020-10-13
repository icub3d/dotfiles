function screenshot
	maim -g (slop) ~/Pictures/screenshot-(date  --rfc-3339=ns | tr ' ' 'T').png
end
