module "shell_data" {
  source                    = "Invicton-Labs/shell-data/external"
  version                   = "~>0.3.1"
  fail_on_nonzero_exit_code = true
  fail_on_stderr            = true
  command_unix              = <<EOF
set -e
_hash_hex=$(echo "${var.content_base64}" | base64 --decode | sha256sum | awk '{print $1}')
_bin_eval_string=""
for ((i=0;i<$${#_hash_hex};i+=2)); do
  _bin_eval_string="$${_bin_eval_string}\\x$${_hash_hex:i:2}"
done
echo "$_hash_hex"
echo -en "$_bin_eval_string" | base64
EOF

  // This is the command that will be run on Windows-based systems
  command_windows = <<EOF
$ErrorActionPreference = "Stop"
$_hash_bytes = New-Object System.Security.Cryptography.SHA256Managed | ForEach-Object {$_.ComputeHash([System.Convert]::FromBase64String("${var.content_base64}"))}
Write-Output $(($_hash_bytes | ForEach-Object {$_.ToString("x2")}) -join "")
Write-Output $([System.Convert]::ToBase64String($_hash_bytes))
EOF
}

locals {
  out    = split("\n", replace(replace(module.shell_data.stdout, "\r", ""), "\r\n", "\n"))
  hex    = trimspace(lower(local.out[0]))
  base64 = trimspace(local.out[1])
}
