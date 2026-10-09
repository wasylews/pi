# pi — Personal Infrastructure (Ansible)

This repository contains Ansible playbooks, roles, and supporting files used to build and manage a personal services stack (AdGuard, Caddy, MariaDB, Shelfmark, Booklore, etc.). It provides two deployment targets: **dev** for local testing (deploys into `build/` folder) and **prod** for Raspberry Pi.

Primary interface: `admin.sh`

Use the `admin.sh` wrapper for all key operations:
- Install Ansible dependencies
- Deploy services to dev (into `build/` folder) or prod (to Raspberry Pi)
- Stop containers
- Prune unused Docker artifacts
- Retrieve Caddy root certificate and copy to `certs/` folder

See `admin.sh` header for available commands and flags.

Repository layout (key items)

- `admin.sh` — Primary helper script and documented entrypoint for common workflows.
- `deploy.yml` — Main playbook to deploy services.
- `stop.yml` — Stop services.
- `prune.yml` — Clean up unused artifacts.
- `ca.yml` — Playbook to retrieve Caddy root certificate.
- `roles/` — Ansible roles (adguardhome, booklore, caddy, docker, mariadb, shelfmark).
- `inventories/` — Inventory examples: `dev.example.yml` for local development and `prod.example.yml` for Raspberry Pi. Copy them to `dev.yml` and `prod.yml` when deploying. Real inventories stay local-only, like the vault.
- `group_vars/` — Group variables and vault variables (sensitive values referenced here). See `group_vars/vault.example.yml` for a template.
- `build/` — Local deployment data and configuration used only for testing the `dev` environment. When deploying to dev, services are deployed into this folder. It does not contain Ansible configuration and should not be modified by hand when deploying to prod.
- `certs/` — TLS artifacts used by services (populated by the `ca` command via `admin.sh`).
- `requirements.yml` — Ansible Galaxy requirements for external roles.

Prerequisites

- Linux host with Docker and Docker Compose (or Podman) installed.
- Ansible (2.9+ recommended) and any role/collection dependencies from `requirements.yml`.
- Access to the inventory files under `inventories/` and appropriate credentials.
- If using Ansible Vault: ensure you have the vault password or `--vault-id` configured. This repo includes a `group_vars/vault.example.yml` to copy-and-fill, and `admin.sh` will use a `.vault-pass` file by default when present.

Quickstart (preferred)

1. Create the inventory you plan to use by copying `inventories/dev.example.yml` to `inventories/dev.yml` (for local testing into the `build/` folder) or `inventories/prod.example.yml` to `inventories/prod.yml` (for Raspberry Pi), then edit the hosts.
2. Populate secrets: copy `group_vars/vault.example.yml` to `group_vars/vault.yml`, edit the secrets, then encrypt with `ansible-vault encrypt group_vars/vault.yml`.
3. Create a `.vault-pass` file at the repo root with your vault password (or provide secrets via `--vault-id` or `--extra-vars`).
4. Use the `admin.sh` wrapper to run tasks. Examples:

```bash
# View help
./admin.sh --help

# Install dependencies
./admin.sh deps

# Deploy to dev (deploys into build/ folder)
./admin.sh deploy

# Deploy to prod (Raspberry Pi)
./admin.sh deploy prod

# Stop services on prod
./admin.sh stop prod

# Prune containers on dev
./admin.sh prune

# Retrieve Caddy certificate and copy to certs/
./admin.sh ca
```

Alternative: run playbooks directly if desired:

```bash
ansible-playbook -i inventories/dev.yml deploy.yml --ask-vault-pass
```

Secrets and vault

- Copy `group_vars/vault.example.yml` to `group_vars/vault.yml`, fill in secrets, and encrypt with `ansible-vault`.
- `admin.sh` expects a vault password file at `.vault-pass` by default when calling the deploy command; you can also use `--ask-vault-pass` or `--vault-id` with `ansible-playbook` directly.

Development notes

- The `build/` directory contains local service-specific data used only when testing the `dev` environment; it is not an Ansible config directory and typically does not need to be edited when deploying to other environments.
- Role templates live under `roles/*/templates` — update these when changing service configuration.

Troubleshooting

- Verify Ansible version and that dependencies from `requirements.yml` are installed.
- If services fail to start, check files under `build/` for missing assets (icons, certs, DB files) when running local tests.
- Read the usage/help in `admin.sh` for scripted workflows and diagnostics.

Where to look next

- Vault example: `group_vars/vault.example.yml`
- Vault variables: `group_vars/vault.yml` (after copying/encrypting)
- Inventories: `inventories/dev.example.yml` and `inventories/prod.example.yml`
- Main playbook: `deploy.yml`
- Helper and docs: `admin.sh`
