function splunk-json
	cat $argv | jq '.result._time + " " + .result.host + " " + .result._raw' | tac | sed -e 's/^"//g' -e 's/"$//g' -e 's/\\\\"/"/g'
end
