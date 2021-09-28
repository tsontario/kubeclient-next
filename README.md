# K8y

K8y is (yet another) gem that allows you to talk to your kubernetes clusters!

For users, this gem is intended to be simple to use, but with enough flexibility to handle a wide variety of use cases. This is acheived by providing a high-level Client API along with a lower-level REST implementation.

For maintainers, the goal is to provide a highly testable, modular, and loosely coupled design to allow for easy change management and confidence in production worthiness.

# Basic usage

## From a Config file

```ruby
# basic client usage
client = K8y::Client.from_config(K8y::Kubeconfig.from_file)
client.discover!
client.get_pods(namespace: "some-namespace")
```

## From in-cluster

```ruby
# basic in-cluster client
client = K8y::Client.from_in_cluster
client.discover!
client.get_pods(namespace: "some-namespace")
```

## Client options

By default, `Kubeconfig.from_file` will read the file pointed to by `ENV["KUBECONFIG"]`, but a separate filepath can be provided.

```ruby
# client with custom kubeconfig
client = K8y::Client.from_config(K8y::Kubeconfig.from_file("path/to/file"))
client.discover!
client.get_pods(namespace: "my-namespace")
```

K8y will use whatever the current context your config is set to. To use a specific context, just supply the `context:` argument. This argument is not available for in-cluster clients.

```ruby
# explicit context
client = K8y::Client.from_config(K8y::Kubeconfig.from_file, context: "my-context")
client.discover!
client.get_pods(namespace: "some-namespace")
```

K8y clients also support multiple group versions per instance. By default, clients are loaded with `core/v1` and `apps/v1` group versions. To use a different set, supply the `group_versions:` arg.

```ruby
# specify group versions
group_versions = [
  K8y::GroupVersion.new(group: "core", version: "v1"),
  K8y::GroupVersion.new(group: "networking.k8s.io", version: "v1")
]

client = K8y::Client.from_config(K8y::Kubeconfig.from_file, group_versions: group_versions)
client.discover!
client.get_ingress(namespace: "some-namespace", name: "my-ingress")
```

If a conflict arises between group versions, a `K8y::Client::APINameConflictError` will be raised when trying to access a duplicate-named resource. **A future feature will allow fine-grained access to client group versions. E.g. `client.api_extensions_v1.get_ingresses**

# Lower-level access

Under the hood, `K8y::Client` makes its requests via a more generic REST client: `K8y::REST::Client`. REST clients can be instantiated much the same as top-level Clients. The `path:` argument will be used as a prefix for all requests made by the client. E.g. given a cluster server of `https://1.2.3.4`, and path `foo`, `rest_client.get("bar")` will make a request to `https://1.2.3.4/foo/bar`

```ruby
# basic rest client

# generate a REST config from a kubeconfig
rest_config = K8y::REST::Config.from_kubeconfig(Kubeconfig.from_file, path: "/")
rest_client = K8y::REST::Client.from_config(rest_config)
rest_client.get("healthz", as: :raw)
```

# Testing

Basic test suite: `bundle exec rake`

Integration test suite: `bundle exec rake test_integration` (requires a running cluster. Defaults to searching for a `kind` config, but can be overridden by setting `K8Y_TEST_CONFIG` and `K8Y_TEST_CONTEXT` environment variables)

A future goal is to test in-cluster behaviour by running a custom Github action, but that hasn't been done yet.

# Contributing

Contributions are always welcome!
