function diff
    if command -vq delta
		delta --dark --minus-style="#CC2E55" --minus-emph-style="#B04C1B" --plus-emph-style="#B04C1B" --plus-style="#5D902A" $argv
	else
		command diff $argv
	end
end
