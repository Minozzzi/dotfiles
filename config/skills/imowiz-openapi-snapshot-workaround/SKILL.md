---
name: imowiz-openapi-snapshot-workaround
description: How to update the OpenAPI snapshot locally in imowiz-backend when the database is down and openapi.ps1 fails.
---

# Updating OpenAPI Snapshot without a Database

If the standard `pwsh scripts/harness/openapi.ps1 -Update` script fails because the API cannot start without a database (e.g., throwing `Npgsql.NpgsqlException` during `MigrateAsync`), you can use this workaround to generate the snapshot:

1. **Temporarily bypass migrations:** Edit `Imowiz.Erp.Api/Program.cs` and comment out the database migration and seeding lines inside the `IsDevelopment()` block.
   ```csharp
   // using var scope = app.Services.CreateScope();
   // var db = scope.ServiceProvider.GetRequiredService<ErpDatabaseContext>();
   // await db.Database.MigrateAsync();
   // await RoleSeeder.SeedAsync(scope.ServiceProvider);
   // await DocumentTagSeeder.SeedAsync(scope.ServiceProvider);
   ```
2. **Start the API:** Run the API project directly.
   ```bash
   dotnet run --project Imowiz.Erp.Api/Imowiz.Erp.Api.csproj
   ```
3. **Download the Snapshot:** In a separate terminal or after confirming the API is listening (default `http://localhost:8080`), fetch the swagger JSON and overwrite the snapshot.
   ```bash
   curl -s http://localhost:8080/swagger/v1/swagger.json -o ./contracts/openapi/imowiz-api.v1.json
   ```
4. **Clean up:** Stop the API and revert the changes to `Imowiz.Erp.Api/Program.cs`.
5. **Commit:** Stage `contracts/openapi/imowiz-api.v1.json` and commit the updated snapshot.
