function stylus
	for x in (xinput | grep HUION | grep -o 'id=[0-9]*' | grep -o '[0-9]*')
		xinput map-to-output $x DP-2
	end
end
