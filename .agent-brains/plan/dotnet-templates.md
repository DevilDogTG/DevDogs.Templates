# Atomic Plan: .NET Templates NuGet Package

**Status:** 🟢 Phase 1-3 Complete  
**Assigned to:** Developer  
**Feature:** Personal `dotnet new` template pack

---

## Goal
Create a NuGet `.nupkg` that registers custom `dotnet new` templates so the user can scaffold preferred project/item skeletons from the CLI.

---

## Final Folder Structure

```
DevDogs.Templates/
├── templatepack.csproj          ← NuGet packaging manifest
├── README.md                    ← Usage instructions
└── content/
    ├── WebApi/                  ← PROJECT TEMPLATE: Minimal Web API
    │   ├── .template.config/
    │   │   └── template.json    ← Template metadata & symbol definitions
    │   ├── Program.cs           ← Minimal API entry w/ Serilog + error handling
    │   ├── WebApi.csproj        ← Pre-configured project file (Serilog, etc.)
    │   ├── appsettings.json
    │   ├── appsettings.Development.json
    │   └── Extensions/
    │       └── ServiceExtensions.cs   ← DI helper kept clean
    └── items/
        └── Service/             ← ITEM TEMPLATE: Service + Interface pair
            ├── .template.config/
            │   └── template.json
            ├── IService.cs      ← Interface stub (name parameterized)
            └── Service.cs       ← Implementation stub (name parameterized)
```

---

## Checklist

### Phase 1 — Package Scaffold
- [x] tp-01: Create `DevDogs.Templates/` root directory
- [x] tp-02: Create `templatepack.csproj` with `<PackageType>Template</PackageType>`, content glob, and NuGet metadata
- [x] tp-03: Create top-level `README.md` with install + usage commands

### Phase 2 — Web API Project Template
- [x] tp-04: Create `content/WebApi/.template.config/template.json`  
  - `identity`: `DevDogs.WebApi`  
  - `shortName`: `devdogs-webapi`  
  - `classifications`: `["Web","API"]`  
  - symbols: `ProjectName` (parameter, replaces `WebApi` in filenames/namespaces)
- [x] tp-05: Create `content/WebApi/WebApi.csproj`  
  - Target: `net9.0`  
  - Packages: `Serilog.AspNetCore`, `Serilog.Sinks.Console`, `Serilog.Sinks.File`
- [x] tp-06: Create `content/WebApi/Program.cs`  
  - Minimal API host builder  
  - Serilog bootstrap logger  
  - Global exception handler middleware  
  - Calls `builder.Services.AddApplicationServices()`
- [x] tp-07: Create `content/WebApi/Extensions/ServiceExtensions.cs`  
  - Static `AddApplicationServices(this IServiceCollection)` extension method
- [x] tp-08: Create `content/WebApi/appsettings.json` and `appsettings.Development.json`  
  - Include Serilog config section

### Phase 3 — Service Item Template
- [x] tp-09: Create `content/items/Service/.template.config/template.json`  
  - `identity`: `DevDogs.Item.Service`  
  - `shortName`: `devdogs-service`  
  - `classifications`: `["Item"]`  
  - symbols: `ServiceName` (parameter, replaces `Service` token in filenames and class names)  
  - `primaryOutputs` pointing to both generated files
- [x] tp-10: Create `content/items/Service/IService.cs`  
  - Interface with `ServiceName` token in name and namespace
- [x] tp-11: Create `content/items/Service/Service.cs`  
  - Class implementing the interface with `ServiceName` token

### Phase 4 — Validation
- [ ] tp-12: Run `dotnet pack` on `templatepack.csproj` — confirm `.nupkg` is produced
- [ ] tp-13: Install locally: `dotnet new install ./nupkg/<package>.nupkg`
- [ ] tp-14: Verify `dotnet new list` shows both `devdogs-webapi` and `devdogs-service`
- [ ] tp-15: Scaffold Web API: `dotnet new devdogs-webapi -n MyApp -o ./test-output/MyApp` — confirm files render correctly with name substitution
- [ ] tp-16: Scaffold Service item: `dotnet new devdogs-service -n OrderService -o ./test-output/MyApp` — confirm `IOrderService.cs` + `OrderService.cs` are generated
- [ ] tp-17: Uninstall test package; delete `./test-output/`

---

## Key Conventions

| Convention | Detail |
|---|---|
| Template discovery | `.template.config/template.json` at root of each template folder |
| Name substitution | Use `sourceName` in `template.json`; files/classes named to match |
| NuGet packaging | `<PackageType>Template</PackageType>` + `<Content Include="content/**" Pack="true" PackagePath="content"/>` |
| Short names | Prefix with `devdogs-` to avoid collision with built-in templates |
| Target framework | `net9.0` |
| Style | No unnecessary comments; explicit DI; Serilog over `ILogger<T>` bootstrap |

---

## .NET Templating Reference

- `template.json` required fields: `$schema`, `author`, `classifications`, `identity`, `name`, `shortName`, `tags`
- Use `"sourceName": "WebApi"` so the engine replaces all occurrences of the string `WebApi` with the user-supplied `-n` value (files, namespaces, class names)
- Item templates use `"type": "item"`; project templates use `"type": "project"`
- `primaryOutputs` in item templates tells the CLI which files were generated
