# Validate FluxCD Docker Action

Validate FluxCD and Kustomizations.

This action is meant to run on FluxCD multi-tenant repositories as described in the [flux2-multi-tenancy](https://github.com/fluxcd/flux2-multi-tenancy) example repo.

- Validates yaml files with `yq`
- Downloads the FluxCD OpenAPI schemas and validates clusters and kustomizations with `kubeconform`.
- Checks for API deprecations in kustomizations with `kubepug`.

## Inputs

### `k8s-target`

**Required** The K8S target version to run the `kubepug` deprecation checker against. Default `"1.20.9"`.

## Example Usage

```yaml
uses: actions/validate-fluxcd-action@v1
with:
k8s-target: "1.20.9"
```

### Running the action with pre-reqs installed.

Several binaries are required before this Action will function.

- `kubeconform`
- `kubepug`
- `kustomize`
- `yq`

These two actions should provide the required binaries.

```yaml
- uses: stefanprodan/kube-tools@v1
- uses: cpanato/kubepug-installer@v1.0.0
```
