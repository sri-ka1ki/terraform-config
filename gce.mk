include $(shell git rev-parse --show-toplevel)/terraform.mk

WRITE_CONFIG_OPTS := --write-bastion --env-tail $(ENV_TAIL)

.PHONY: default
default: hello

CONFIG_FILES := \
	config/bastion.env \
	config/gce-workers-$(ENV_SHORT).json \
	config/worker-com.env \
	config/worker-org.env

.PHONY: .config
.config: $(CONFIG_FILES) $(ENV_NAME).tfvars

$(CONFIG_FILES): .write-config-files
	cp -v $$TRAVIS_KEYCHAIN_DIR/travis-keychain/gce/*.json config/
