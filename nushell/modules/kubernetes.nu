# Kubernetes Helper Module

export alias k = kubectl

export def "k gc" [] { kubectl config get-contexts }
export def "k l" [pod] { kubectl logs -f po/$pod }
export def "k gn" [] { kubectl get namespaces }
export def "k ns" [namespace] { kubectl config set-context --current $"--namespace=($namespace)" }
export def "k uc" [context] { kubectl config use-context $context }
export def "k ga" [...args] { kubectl get all ...$args }

export def "k bash" [pod] {
    let pod = kubectl get po -o name | lines | find $pod | first
    kubectl exec -it $pod -- bash
}

export def "k sh" [pod] {
    let pod = kubectl get po -o name | lines | find $pod | first
    kubectl exec -it $pod -- sh
}

export def "k run" [pod, ...args] {
    let pod = kubectl get po -o name | lines | find $pod | first
    kubectl exec -it $pod -- ...$args
}
