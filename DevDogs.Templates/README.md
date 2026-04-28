# DevDogs.Templates

Personal `dotnet new` template pack for DevDogs projects.

## Install

```bash
dotnet new install DevDogs.Templates
```

Or install from a local `.nupkg`:

```bash
dotnet pack templatepack.csproj --no-build -o ./nupkg
dotnet new install ./nupkg/DevDogs.Templates.1.0.0.nupkg
```

## Templates

### Web API Project (`devdogs-webapi`)

Minimal ASP.NET Core Web API with Serilog, exception handling, and a clean DI extension.

```bash
dotnet new devdogs-webapi -n MyApp -o ./MyApp
```

### Service Item (`devdogs-service`)

Generates a matched interface + implementation pair.

```bash
dotnet new devdogs-service -n OrderService -o ./MyApp/Services
```

Produces `IOrderService.cs` and `OrderService.cs`.

### Avalonia App (`devdogs-avalonia`)

MVVM desktop application using Avalonia UI 11 with CommunityToolkit.Mvvm.

```bash
dotnet new devdogs-avalonia -n MyDesktopApp -o ./MyDesktopApp
```

### GraphQL API (`devdogs-graphql`)

Minimal ASP.NET Core GraphQL API using HotChocolate with Serilog and clean DI extension.

```bash
dotnet new devdogs-graphql -n MyGraphQLApi -o ./MyGraphQLApi
```

## Uninstall

```bash
dotnet new uninstall DevDogs.Templates
```
