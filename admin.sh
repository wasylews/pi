#!/usr/bin/env bash
set -euo pipefail

# Allowed environments
ENVS=("dev" "prod")

# Default environment
DEFAULT_ENV="dev"

usage() {
    cat <<EOF
Usage: $0 <command> [environment]

Commands:
  deploy      Deploy services to the specified environment
  stop        Stop services in the specified environment
  prune       Prune docker containers in the specified environment
  deps        Install Ansible Galaxy dependencies

Environment (optional):
  dev (default)
  prod

Examples:
  $0 deploy          # deploy to dev
  $0 deploy prod     # deploy to prod
  $0 stop prod       # stop services on prod
  $0 prune prod      # prune docker containers on prod
  $0 deps            # install dependencies
EOF
}

# Check at least one argument is provided
if [[ $# -lt 1 ]]; then
    usage
    exit 1
fi

COMMAND="$1"
ENV="${2:-$DEFAULT_ENV}"

# Validate environment for commands that need it
if [[ "$COMMAND" =~ ^(deploy|stop)$ ]]; then
    if [[ ! " ${ENVS[*]} " =~ " ${ENV} " ]]; then
        echo "Invalid environment: $ENV"
        echo "Must be one of: ${ENVS[*]}"
        exit 1
    fi
fi

case "$COMMAND" in
    deploy)
        echo "Deploying to $ENV..."
        ansible-playbook deploy.yml -i "inventories/${ENV}.yml" --vault-password-file .vault-pass
        ;;
    stop)
        echo "Stopping services on $ENV..."
        ansible-playbook stop.yml -i "inventories/${ENV}.yml"
        ;;
    prune)
        echo "Pruning containers on $ENV..."
        ansible-playbook prune.yml -i "inventories/${ENV}.yml"
        ;;    
    deps)
        echo "Installing Ansible Galaxy dependencies..."
        ansible-galaxy install -r requirements.yml
        ;;
    *)
        echo "Unknown command: $COMMAND"
        usage
        exit 1
        ;;
esac
