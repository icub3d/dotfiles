function g
	set BASE_BRANCH develop
	if test $argv[1] = "fs"
		# start a new feature
		if test (count $argv) -eq 2
			command git checkout -b feature/$argv[2] $BASE_BRANCH
		else if test (count $argv) -eq 3
			command git checkout -b feature/$argv[2] $argv[3]
		else
			echo "Usage: g fs <branch-name> [base-branch]"
		end
	else if test $argv[1] = "fu"
		# push a feature
		if test (count $argv) -eq 2
			command git checkout feature/$argv[2]
			command git push -u origin feature/$argv[2]
		else
			echo "Usage: g fu <branch-name>"
		end
	else if test $argv[1] = "fp"
		# pull (update) a feature
		if test (count $argv) -eq 1
			$argv[2] = (git rev-parse --abbrev-ref HEAD)
		end
		command git pull --rebase origin $argv[2]
	else if test $argv[1] = "ft"
		# switch to a feature, fetch all first
		if test (count $argv) -ne 2
			echo "Usage: g ft <branch-name>"
		end
		command git fetch --all
		command git checkout feature/$argv[2]
	else if test $argv[1] = "ff"
		# finish a feature
		if test (count $argv) -eq 1
			$argv[2] = (git rev-parse --abbrev-ref HEAD)
		end
		command git fetch --all
		command git checkout $BASE_BRANCH
		command git merge --no-ff feature/$argv[2]
		command git branch -d feature/$argv[2]
		command git push origin $BASE_BRANCH
	else
		command git $argv
	end
end
