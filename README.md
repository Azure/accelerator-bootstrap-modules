# Accelerator Bootstrap Modules

[![End to End Tests](https://github.com/Azure/accelerator-bootstrap-modules/actions/workflows/end-to-end-test.yml/badge.svg)](https://github.com/Azure/accelerator-bootstrap-modules/actions/workflows/end-to-end-test.yml)
[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/Azure/accelerator-bootstrap-modules/badge)](https://scorecard.dev/viewer/?uri=github.com/Azure/accelerator-bootstrap-modules)

This repository contains the Terraform modules that are used to deploy the accelerator bootstrap environments.

## Features

- Azure DevOps and GitHub bootstrap orchestrations
- User-assigned managed identities with federated credentials
- Self-hosted agents with Container Instances or Container App Jobs (Azure DevOps only)
- Private networking support with NAT Gateway
- Container Registry with ACR Tasks for agent images
