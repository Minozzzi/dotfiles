---
name: update-lambda-node-version
description: "Checklist for fully updating an AWS Lambda project to a new Node.js version (pipeline, Datadog layers, esbuild, types)."
---

# Updating Node.js Version for AWS Lambda Projects

When tasked with upgrading the Node.js runtime version for an AWS Lambda function (e.g., to Node.js 24), ensure all of the following components are updated across the repository. Do not just update the CI/CD runtime variable.

## Checklist

### 1. CI/CD Pipeline (`.gitlab-ci.yml` or similar)
- **Runtime Variable**: Update the deployment runtime variable (e.g., `RUNTIME: "nodejs24.x"`).
- **Build Images**: Update any Docker images used for building, testing, or linting (e.g., `image: public.ecr.aws/sam/build-nodejs24.x`).
- **Lambda Layers (Datadog, etc.)**: Ensure specific Lambda Layers tied to the runtime are updated. For Datadog, update the ARN suffix to the new Node version (e.g., `Datadog-Node24-x`).

### 2. Package Configuration (`package.json`)
- **Types**: Bump `@types/node` in `devDependencies` to match the major version (e.g., `^24.0.0`).
- **Bundler Target**: If using a bundler like `esbuild`, update the target flag in the build scripts (e.g., `--target=node24`).

### 3. Documentation (`README.md` and others)
- **Grep for old versions**: Search the codebase (excluding `node_modules`) for the old version number (e.g., `node20`, `nodejs20.x`) and update documentation, README files, or comments to reflect the new runtime.
