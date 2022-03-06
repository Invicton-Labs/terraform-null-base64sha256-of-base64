# Terraform SHA256 of Base64

This module is functionally equivalent to `sha256(base64decode(var.content_base64))` (`hex` output) and `base64sha256(base64decode(var.content_base64))` (`base64` output), except that it functions even when `content_base64` does not decode to valid UTF-8.

This module has been tested on Linux and Windows, but not macOS. In theory, it should function on any Unix-based OS that supports `bash`, `base64`, and `sha256sum` commands, or any Windows-based OS that supports PowerShell.

## Usage

```
locals {
  // foo is a base64-encoded string of some binary that does not represent valid UTF-8
  foo_b64 = "0000"

  foo_sha256_hex = sha256(base64decode(local.foo_b64))
  foo_sha256_b64 = base64sha256(base64decode(local.foo_b64))
}

output "sha256_hex" {
  value = local.foo_sha256_hex
}
output "sha256_b64" {
  value = local.foo_sha256_b64
}
```

This does not work, since `foo` is not a valid UTF-8 string.
```
Call to function "base64decode" failed: the result of decoding the provided string is not valid UTF-8.
Call to function "base64decode" failed: the result of decoding the provided string is not valid UTF-8.
```

But if we use this module:
```
locals {
  // foo is a base64-encoded string of some binary that does not represent valid UTF-8
  foo_b64 = "0000"

  foo_sha256_hex     = module.sha256.hex
  foo_sha256_b64 = module.sha256.base64
}

module "sha256" {
  source         = "../../terraform-modules-public/terraform-null-base64sha256-of-base64"
  content_base64 = local.foo_b64
}

output "sha256_hex" {
  value = local.foo_sha256_hex
}
output "sha256_b64" {
  value = local.foo_sha256_b64
}
```

```
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

sha256_b64 = "DhDgNWX0ZkoFw7xj7TXfPhqcslaDcdtPErZscolD+AI="
sha256_hex = "0e10e03565f4664a05c3bc63ed35df3e1a9cb2568371db4f12b66c728943f802"
```

### Validation

We can validate the above example by doing the same thing with Python:
```
import base64
import hashlib

bytes = base64.b64decode(b"0000")
digest = hashlib.sha256(bytes).digest()
print(base64.b64encode(digest).decode())
print(digest.hex())
```

```
DhDgNWX0ZkoFw7xj7TXfPhqcslaDcdtPErZscolD+AI=
0e10e03565f4664a05c3bc63ed35df3e1a9cb2568371db4f12b66c728943f802
```

And we can see that both the base64 and hex values match.
