#!/bin/bash
if ! command -v terraform >/dev/null; then
    echo "terraform is not installed!"
    exit 1
fi

terraform destroy --auto-approve
rm -r ./vpn-ca