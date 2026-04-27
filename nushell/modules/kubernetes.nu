# Kubernetes Helper Module

export alias k = kubectl

export def "k gc" [] { kubectl config get-contexts }
export def "k l" [pod] { kubectl logs -f po/$pod }
export def "k gn" [] { kubectl get namespaces }
export def "k ns" [namespace] { kubectl config set-context --current $"--namespace=($namespace)" }
export def "k uc" [context] { kubectl config use-context $context }
export def "k ga" [...args] { kubectl get all ...$args }

def resolve-pod [pattern: string] {
    kubectl get po -o name | lines | where { |p| $p | str contains $pattern } | first
}

export def "k bash" [pod: string] {
    kubectl exec -it (resolve-pod $pod) -- bash
}

export def "k sh" [pod: string] {
    kubectl exec -it (resolve-pod $pod) -- sh
}

export def "k run" [pod: string, ...args] {
    kubectl exec -it (resolve-pod $pod) -- ...$args
}
