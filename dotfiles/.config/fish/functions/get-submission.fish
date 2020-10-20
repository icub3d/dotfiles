function get-submission
	env RESPONSES_(string upper $argv[2])_SUBMIT_ID=$argv[3] aa -e $argv[1] r r -j --exclude validationSummary $argv[2]/status
end
