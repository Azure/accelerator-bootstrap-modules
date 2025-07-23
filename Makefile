default:
	@echo "==> Type make <thing> to run tasks"
	@echo
	@echo "Thing is one of:"
	@echo "docs fmt fmtcheck tfclean tools"

fmt:
	@echo "==> Fixing Terraform code with terraform fmt..."
	terraform fmt -recursive

fmtcheck:
	@echo "==> Checking source code with terraform fmt..."
	terraform fmt -check -recursive

# Makefile targets are files, but we aren't using it like this,
# so have to declare PHONY targets
.PHONY: fmt fmtcheck
