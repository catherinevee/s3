# S3 Module Makefile
# Common Terraform operations for the S3 bucket module

.PHONY: help init plan apply destroy validate fmt lint clean test examples

# Default target
help:
	@echo "Available targets:"
	@echo "  init      - Initialize Terraform"
	@echo "  plan      - Plan Terraform changes"
	@echo "  apply     - Apply Terraform changes"
	@echo "  destroy   - Destroy Terraform resources"
	@echo "  validate  - Validate Terraform configuration"
	@echo "  fmt       - Format Terraform code"
	@echo "  lint      - Lint Terraform code"
	@echo "  clean     - Clean up temporary files"
	@echo "  test      - Run tests"
	@echo "  examples  - Run examples"

# Initialize Terraform
init:
	terraform init

# Plan Terraform changes
plan:
	terraform plan

# Apply Terraform changes
apply:
	terraform apply

# Destroy Terraform resources
destroy:
	terraform destroy

# Validate Terraform configuration
validate:
	terraform validate

# Format Terraform code
fmt:
	terraform fmt -recursive

# Lint Terraform code (requires tflint)
lint:
	@if command -v tflint >/dev/null 2>&1; then \
		tflint; \
	else \
		echo "tflint not found. Install with: go install github.com/terraform-linters/tflint/cmd/tflint@latest"; \
	fi

# Clean up temporary files
clean:
	rm -rf .terraform
	rm -f .terraform.lock.hcl
	rm -f terraform.tfstate
	rm -f terraform.tfstate.backup
	rm -f *.tfplan

# Run tests (requires terratest)
test:
	@if command -v go >/dev/null 2>&1; then \
		cd test && go test -v -timeout 30m; \
	else \
		echo "Go not found. Install Go to run tests."; \
	fi

# Run examples
examples:
	@echo "Running examples..."
	@for example in examples/*/; do \
		if [ -d "$$example" ]; then \
			echo "Testing $$example"; \
			cd "$$example" && terraform init && terraform validate && cd ../..; \
		fi; \
	done

# Install development tools
install-tools:
	@echo "Installing development tools..."
	@if command -v go >/dev/null 2>&1; then \
		go install github.com/terraform-linters/tflint/cmd/tflint@latest; \
		go install github.com/gruntwork-io/terratest/modules/terraform@latest; \
	else \
		echo "Go not found. Install Go first."; \
	fi

# Pre-commit hooks
pre-commit: fmt lint validate

# Documentation
docs:
	@echo "Generating documentation..."
	@if command -v terraform-docs >/dev/null 2>&1; then \
		terraform-docs markdown . > README.md; \
	else \
		echo "terraform-docs not found. Install with: go install github.com/terraform-docs/terraform-docs@latest"; \
	fi

# Security scan (requires tfsec)
security-scan:
	@if command -v tfsec >/dev/null 2>&1; then \
		tfsec .; \
	else \
		echo "tfsec not found. Install with: go install github.com/aquasecurity/tfsec/cmd/tfsec@latest"; \
	fi

# Cost estimation (requires infracost)
cost-estimate:
	@if command -v infracost >/dev/null 2>&1; then \
		infracost breakdown --path .; \
	else \
		echo "infracost not found. Install with: go install github.com/infracost/infracost/cmd/infracost@latest"; \
	fi 