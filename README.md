# Wireguard Server Infrastructure

This repository provisions and configures a Wireguard server and client using Terraform and Ansible.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Folder Structure](#folder-structure)
- [Setup](#setup)
- [Usage](#usage)
- [Contributing](#contributing)

## Prerequisites
- AWS CLI and credentials configured
- Terraform >= 1.5.7
- Ansible
- Ubuntu 22.04 LTS for the EC2 instance
- Pre-commit with the following hooks enabled: flake8, black, pyupgrade, terraform fmt, terraform validate, beautify, yamlfmt

## Folder Structure

```plaintext
├── ansible
│   ├── inventories
│   │   └── aws_ec2.yaml                                # Ansible dynamic inventory for AWS EC2
│   ├── tasks
│   │   ├── manage
│   │   │   ├── fetch_server_info.yaml                  # Fetches server information
│   │   │   └── restart_wireguard_client_server.yaml    # Restarts Wireguard on both client and server
│   │   ├── security
│   │   │   └── crons.yaml                              # Cron jobs for server maintenance
│   │   └── setup
│   │       └── setup_wireguard.yaml                    # Initial Wireguard setup, most important
│   └── templates
│       └── wg1.conf.j2                                 # Template for Wireguard configuration files
├── config_files
│   ├── create_client_config.sh                         # Script to create client configuration
│   ├── sample_wg1_client.conf                          # Sample client configuration for Wireguard
│   └── sample_wg1_server.conf                          # Sample server configuration for Wireguard
├── .gitignore
├── .pre-commit-config.yaml
├── README.md
├── .secrets.baseline
└── terraform                                           # For ec2 server infrastructure
    ├── main.tf
    ├── README.md                                       # Created by terraform_docs pre-commit
    └── .terraform.lock.hcl
```

## Setup

1. **Initialize Terraform**
    ```bash
    cd terraform
    terraform init
    ```

2. **Apply Terraform Configuration**
    ```bash
    terraform apply
    ```

3. **Run Ansible Playbook**
    ```bash
    cd ../ansible
    ansible-playbook -i inventories/aws_ec2.yaml tasks/setup_wireguard.yaml
    ```

## Usage

- **Restart Wireguard Services**
    ```bash
    ansible-playbook -i inventories/aws_ec2.yaml tasks/restart_wireguard_client_server.yaml
    ```

- **Fetch Server Info**
    ```bash
    ansible-playbook -i inventories/aws_ec2.yaml tasks/fetch_server_info.yaml
    ```

## Contributing

This repository follows the best practices in terms of code formatting and validation. Make sure you have pre-commit installed and all hooks are passing before submitting any pull request.
