# Kubeclient-next

Kubeclient-next is a gem that aims to provide a flexible, testable, and intuitive Ruby client for interacting with the Kubernetes API server. It's specific design goals are:

- Fully testable (both unit and integration)
- Layered API ('batteries included' classes along with access to lower-level implementations)
- Multiple group-version support per client instance
- Transparent and renewable authentication

# Usage: high level API

The 2 primary classes at the highest API layer are `Kubeconfig` and `Client`. In general, we expect `Kubeconfig` to be derived from a YAML file (defaults to `$KUBECONFIG`). If `$KUBECONFIG` is not set and you are running in-cluster, an in-cluster config will be instantiated by default. Rightly or wrongly, the `Kubeconfig` abstraction permeates the design of Kubeclient-next, and is used at multiple levels to organize the basic connection parameters to a cluster.

With a config instance in hand, instantiating a client is simple:

```ruby
config = KubeclientNext::Kubeconfig.from_file
client = KubeclientNext::Client.from_config(config)
```



