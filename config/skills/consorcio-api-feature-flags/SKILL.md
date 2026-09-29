---
name: consorcio-api-feature-flags
description: How to safely implement feature flags and conditionally omit JSON fields in consorcio-simulations-api without breaking unit tests.
---

# Feature Flags in Consórcio Simulations API

When implementing feature flags or new environment-based toggles in the `consorcio-simulations-api` repository, follow these rules to avoid breaking the unit test suite:

## 1. Avoid `Config.cs` for Feature Flags
**Do NOT** add new feature flags directly to `src/Consorcio.Simulations.Infra/Configurations/Config.cs`.
The static constructor of `Config.cs` enforces the presence of `DOTNET_ENVIRONMENT` and other environment variables. Unit tests typically run without these variables. If a mapper or service under test accesses `Config.cs`, it will trigger a `TypeInitializationException` and break the test suite.

## 2. Isolate in a Dedicated Static Class
Create a dedicated configuration class (e.g., `FeatureFlagConfig.cs`) within the `Configurations` directory.

```csharp
namespace Consorcio.Simulations.Infra.Configurations;

public static class FeatureFlagConfig {
    public static bool EnableMyFeature = bool.Parse(
        Environment.GetEnvironmentVariable("FEATURES_ENABLE_MY_FEATURE") ?? "false"
    );
}
```

## 3. Omitting Fields from JSON Payloads
If a disabled feature flag requires completely omitting a field from an external request (e.g., to the Bradesco integration) rather than sending a default value:
1. Make the property nullable (`string?`, `bool?`, `long?`, etc.) in the target DTO.
2. Apply `[JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]`.
3. In the mapping logic, return `null` if the feature is disabled.

```csharp
[JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
[JsonPropertyName("snExemplo")]
public string? MyField { get; }
```
