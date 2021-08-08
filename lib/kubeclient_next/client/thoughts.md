# Client module

The client module aims to provide a minimal, yet complete, interface for creating client objects, which themselves expose the usual client methods for interacting with a k8s API server (for a particular group-version(s)). The complexity here lies in the varying levels of abstraction required to deal with the myriad ways a client configuration can be realized.

For example, the [rest package in client-go](https://github.com/kubernetes/client-go/blob/master/rest/config.go#L53) generates REST clients from a suite of configuration options, taking care of the URI corresponding to a given host and version, transport options (TLS config, etc.), and rate limiting, among others. A cursory inspection suggests this is the package that the [abonas/kubeclient Client](https://github.com/abonas/kubeclient/blob/master/lib/kubeclient.rb#L95) models.

However, only modelling this client yields some unfortunate consequences, the most salient of which is the complete loss of information (and reference to) the kubeconfig that generated the REST client in the first place. The analogue in Go is the [clientcmd Config struct](https://github.com/kubernetes/client-go/blob/master/tools/clientcmd/api/v1/types.go#L28). This manifests in [abonas/kubeclient](https://github.com/abonas/kubeclient) as an inability to update expired auth (except, of course, if an entirely new client is instantiated).

# Ideas

- Keep RESTClient as an implementation detail of some exposed, higher-level, Client class. This could open up the door to a few benefits:
  - No need to instantiate new clients for different group-versions (just switch between underlying RESTClients)
  - Maintains a reference to the Config object (presumably from a KUBECONFIG file) that allows easy generation of new clients, renew auth tokens, easily switch between different contexts.
  - Could make generating in-cluster clients more-or-less completely transparent

As a consequence of this approach, some thought needs to be given of the public API of the consumed Client class (whatever it ends up being called). Somewhat relatedly, it would be nice to break apart different layers of the current kubeclient into better-separated and more clearly delineated modules.

```ruby
# TODO write out imagined public API* 
```

