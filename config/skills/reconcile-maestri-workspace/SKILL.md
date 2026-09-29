# Reconciling Maestri Workspace Notes

When reusing a Maestri workspace for a new project, clear stale context across shared agent notes to avoid incorrect execution in the pipeline:

1. **maestro-notes**: Update workspace name, project root path, and active target.
2. **project-tech-stack**: Update runtime, framework, UI libraries, package manager, and testing configuration.
3. **current-feature**: Clear active task pointers or update to the new feature.
4. **qa-checklist**: Align validation commands (e.g. build/lint scripts) and specific checks (animations, 3D, responsive layout).
5. **portal-config**: Update local dev scripts and port configurations.
6. **release-flow-rules**: Configure branch strategy and commit standards.
7. **restricted-credentials**: Purge obsolete secrets and credentials from prior projects.
8. **maestri-governance**: Ensure pipeline governance rules align with project policies.
