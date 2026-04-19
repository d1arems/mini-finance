# Automated Finance App Deployment (Ansible Production Workflow)

![Ansible](https://img.shields.io/badge/Ansible-000000?style=for-the-badge&logo=ansible&logoColor=white)
![Azure](https://img.shields.io/badge/Azure-0089D6?style=for-the-badge&logo=microsoft-azure&logoColor=white)

This repository demonstrates a **production-grade** automation suite for deploying a Static Mini Finance Application on Azure. It highlights the shift from basic configuration to a secure, modular, and linted DevOps workflow.

## Key Technical Features
- **Security Hardening:** Enforced `host_key_checking = True` and utilized **SSH Agent Forwarding** for secure private repository cloning.
- **Modular Roles:** Decoupled infrastructure logic into reusable roles (`common`, `nginx`, `finance_app`).
- **Quality Gates:** Integrated `ansible-lint` and `pre-commit` hooks to ensure strict adherence to YAML 1.2 standards and FQCN.
- **Reproducibility:** Managed via a dedicated Python Virtual Environment and `requirements.txt`.

## Directory Structure
```text
.
├── ansible.cfg             # Hardened security & SSH configurations
├── inventory.ini           # Azure host definitions
├── site.yml                # Master deployment playbook
├── .pre-commit-config.yaml # Automated quality checks
└── roles/                  # Modular task blocks

Getting Started
Initialize Environment:

Bash
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
Establish Security Handshake:

Bash
ssh-keyscan -H <VM_IP> >> ~/.ssh/known_hosts
eval $(ssh-agent -s) && ssh-add ~/.ssh/id_rsa_ansible
Deploy:

Bash
ansible-playbook -i inventory.ini site.yml
Author: Oladayo Aremu
