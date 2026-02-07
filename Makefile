ENVS := dev prod

# Default to dev if no environment is specified
ENV ?= dev

# Ensure the specified environment is valid
ifeq ($(filter $(ENV),$(ENVS)),)
$(error Invalid environment. Must be one of: $(ENVS))
endif

deploy:
	ansible-playbook deploy.yml -i inventories/$(ENV).yml \
		--vault-password-file .vault-pass

clean:
	ansible-playbook cleanup.yml -i inventories/$(ENV).yml

deps:
	ansible-galaxy install -r requirements.yml

.PHONY: deploy clean deps
