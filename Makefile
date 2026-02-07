deploy:
	ansible-playbook deploy.yml --ask-become-pass --vault-password-file .vault-pass

deps:
	ansible-galaxy install -r requirements.yml

clean:
	ansible-playbook cleanup.yml


@.PHONY: deploy clean deps