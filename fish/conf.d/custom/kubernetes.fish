function switch-k8s-context
    set selected_ctx (kubectx | peco)
    if test -n "$selected_ctx"
        kubectx $selected_ctx
        commandline -f repaint
    end
end

function delete-k8s-context
    set selected_ctx (kubectx | peco)
    if test -n "$selected_ctx"
        kubectx -d $selected_ctx
        echo dummy
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
    set source $argv[3]

    # Extract namespace and name from the selected line
    set namespace (echo $selected | awk '{print $1}')
    set name (echo $selected | awk '{print $2}')

    # Check if both namespace and name are set
    if test -n "$namespace" -a -n "$name"
        # Reconcile the resource using Flux
        if test "$source" = true
            flux reconcile source $resource_type $name -n $namespace
        else
            if test "$resource_type" = hr
                flux reconcile $resource_type $name -n $namespace --force
            else
                flux reconcile $resource_type $name -n $namespace
            end
        end
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

function reconcile-gitrepo
    set selected (get-selected-resource gitrepo)
    reconcile-resource git $selected true
end

function reconcile-ocirepo
    set selected (get-selected-resource ocirepo)
    reconcile-resource oci $selected true
end

bind \ckl switch-k8s-context
bind \ckd delete-k8s-context
bind \ckhr reconcile-hr
bind \ckks reconcile-ks
bind \ckgit reconcile-gitrepo
bind \ckoci reconcile-ocirepo
