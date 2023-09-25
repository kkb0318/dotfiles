function switch-k8s-context
    set selected_ctx (kubectx | peco)
    if test -n "$selected_ctx"
        kubectx $selected_ctx > /dev/null
        commandline -f repaint
    end
end

bind \ck switch-k8s-context

