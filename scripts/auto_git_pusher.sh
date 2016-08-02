#!/usr/bin/env bash

# Config
pushing_limit=1 # No of commits to push at a time
verbose=true # Verbose mode

# Get current branch name
branch_name="$(git symbolic-ref HEAD 2>/dev/null)" ||
branch_name="(unnamed branch)"     # detached HEAD
branch_name=${branch_name##refs/heads/}
if [ "$verbose" = true ] ; then
	echo "You are on branch: " $branch_name
fi

# Get number of commits ahead
commits_ahead="$(git rev-list origin/$branch_name..HEAD --count)"
if [ "$verbose" = true ] ; then
	echo "Commits ahead: " $commits_ahead
fi

# Get number of commits behind
commits_behind="$(git rev-list HEAD..origin/$branch_name --count)"
if [ "$verbose" = true ] ; then
	echo "Commits behind: " $commits_behind
fi
if [ "$commits_behind" != "0" ]; then
	if [ "$verbose" = true ] ; then
		echo "Behind origin by " $commits_behind " commits. Please pull your branch."
	fi
fi

# Checkout to last pushed commit and push code
if [ $commits_ahead>=$pushing_limit ]; then
	push_commits=$pushing_limit
else
	push_commits=$commits_ahead
fi

# Push commits
if [ $(( $commits_ahead-$push_commits )) -gt "0" ]; then
	git checkout HEAD~$(( $commits_ahead-$push_commits ))
	commit_sha="$(git rev-parse HEAD)"
	if [ "$verbose" = true ] ; then
		echo "At commit: " $commit_sha " Pushing commits: " $push_commits
	fi
	git push origin $commit_sha:$branch_name
else
	echo "Origin is upto date."
fi

# Back to where HEAD was
git checkout $branch_name

# Show Git log graph
echo "Git Log: "
git log --pretty=oneline --abbrev-commit --graph --decorate --all
