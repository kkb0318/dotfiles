function show_github_issue
    set selected (gh issue list --state open --limit 100 | fzf --preview 'gh issue view -p (echo {} | cut -f1)' | cut -f1)
    if test -n "$selected"
        set -l BUFFER "gh issue view $selected"
        eval $BUFFER
    end
end

bind \cgi show_github_issue

