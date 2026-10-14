# AWS Ubuntu Module Template

This directory is a scaffold for adding an Ubuntu-based remote development machine on AWS.

## Expected Layout

```text
aws/ubuntu/
  terraform/
  ansible/
```

## Usage

Once `aws/ubuntu/terraform/` contains Terraform files, you can use:

- `cd aws && just init ubuntu`
- `cd aws && just plan ubuntu`
- `cd aws && just apply ubuntu`

If the directory exists but contains no Terraform files yet, `just init ubuntu` will fail fast with a clear message.
