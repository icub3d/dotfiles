function bw-get-token
	set NAME $argv[1]
	bw list items --search $NAME | jq -r ".[] | select(.name==\"$NAME\")" | jq -r '.login.password'
end
