# Purpose of this document

This document serves as a historical record of certain design decisions as they're made, in the hope that, down the line, it will be clear why certain implementations were chosen over others, and to inform future development. Any new feature or architectural change that relies on careful judgement of tradeoffs and/or assumptions should be documented.

# Authorization

For `auth-provider` based authorization, K8y exposes the `ProviderBase` class which all concrete provider implementations should implement. Subclasses should implement a single method: `#token`. The `#token` method is used in 3 instances:

- To generate a token if one doesn't exist
- To store generated tokens in the token store
- To regenerate expired tokens

This approach makes it easy to design new `auth-providers`: they just need to implement a single method and token configuration, regeneration, and reuse, occurs transparently. The tradeoff is slightly less fine-grained control over global (e.g process-wide) client settings. Another complicating factor is that the authorization config (for the `REST`) client is not context-aware. Instead, `TokenStore` keys tokens to the `REST::Client`s host (e.g. `https://1.2.3.4`). This makes it effectively impossible for the same process to use different tokens between clients targeting the same API server host. For now, this seems like a decent tradeoff: I'm having trouble imagining when/where such a case might be useful.

