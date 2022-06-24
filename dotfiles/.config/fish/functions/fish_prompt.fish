function fish_prompt --description 'Write out the prompt'
	printf "%b" (string join "\n" (fish_prompt_print))
    vterm_prompt_end
end
