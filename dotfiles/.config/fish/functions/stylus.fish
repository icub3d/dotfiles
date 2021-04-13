function stylus
	for x in (xinput | grep HUION | grep -o 'id=[0-9]*' | grep -o '[0-9]+' | sort | uniq)
		xinput map-to-output $x DP-0
	end
end
