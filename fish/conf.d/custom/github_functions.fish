function show_github_issue
    set selected (gh issue list --state open --limit 100 | fzf --preview 'gh issue view (echo {} | cut -f1)' | cut -f1)
    if test -n "$selected"
        set -l BUFFER "gh issue view -w $selected"
        eval $BUFFER
    end
end

function show_github_pr
    set selected (gh pr list --state open --limit 100 | fzf --preview 'gh pr view (echo {} | cut -f1)' | cut -f1)
    if test -n "$selected"
        set -l BUFFER "gh pr view -w $selected"
        eval $BUFFER
    end
end

bind \cgp show_github_pr
bind \cgi show_github_issue

