## next

## 0.3.0

**Enhancements**

- Auth configuration dynamically set according to provided config [#29](https://github.com/tsontario/k8y/pull/29)

**Bug fixes**

- `Client::Client` API methods (`get_resource`, `update_resource`, etc.) now respects the `as:` parameter [#28](https://github.com/tsontario/k8y/pull/28)

## 0.2.0

**Enhancements**

- `K8y::Client::from_in_cluster` for easily building in-cluster clients [#23](https://github.com/tsontario/k8y/pull/23)

**Testing**

- Integration test suite to run against (KinD) cluster [#11](https://github.com/tsontario/k8y/pull/11)
- Run integration tests in parallel [#22](https://github.com/tsontario/k8y/pull/22)

**Design**

- Move generated API methods (get_pods, delete_service, etc.) into separate API class, out of top-level K8y::Client::Client [#17](https://github.com/tsontario/k8y/pull/17)

