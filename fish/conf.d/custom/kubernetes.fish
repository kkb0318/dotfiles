function switch-k8s-context
    set selected_ctx (kubectx | peco)
    if test -n "$selected_ctx"
        kubectx $selected_ctx > /dev/null
        commandline -f repaint
    end
end

function delete-k8s-context
    set selected_ctx (kubectx | peco)
    if test -n "$selected_ctx"
        kubectx  -d $selected_ctx > /dev/null
        echo "dummy"
        echo (echo "This will be executed as if you pressed Enter.")
        commandline -f repaint
    end
end

# Helper function to get a selected resource using peco
function get-selected-resource
    set resource_type $argv[1]
    echo (kubectl get $resource_type -A --no-headers | peco)
end

# Helper function to reconcile a resource using Flux
function reconcile-resource
    set resource_type $argv[1]
    set selected $argv[2]

    # Extract namespace and name from the selected line
    set namespace (echo $selected | awk '{print $1}')
    set name (echo $selected | awk '{print $2}')

    # Check if both namespace and name are set
    if test -n "$namespace" -a -n "$name"
        # Reconcile the resource using Flux
        flux reconcile $resource_type $name -n $namespace
    else
        echo "No $resource_type selected."
        commandline -f repaint
    end
end


function reconcile-hr
    set selected (get-selected-resource hr)
    reconcile-resource hr $selected
end

function reconcile-ks
    set selected (get-selected-resource ks)
    reconcile-resource ks $selected
end


bind \ckl delete-k8s-context
bind \ckd switch-k8s-context
bind \ckhr reconcile-hr
bind \ckks reconcile-ks

