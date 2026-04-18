# Contract — `dotnet-mobile-developer`

**Schema**: see [agent-schema.md](./agent-schema.md).
**File**: `agents/dotnet-mobile-developer.md`

## Frontmatter values

```yaml
---
name: dotnet-mobile-developer
description: Expert .NET MAUI mobile engineer. Invoke for MAUI presentation layer scaffolding — SQLite model attributes, AutoMapper profiles, ViewModels (CommunityToolkit.Mvvm), XAML Pages, Shell navigation, MauiProgram DI, and APK build guidance. Handles mobile-specific backend layers on first touch.
tools: Read, Grep, Glob, Bash, Write, Edit, Task, Skill
---
```

## Required Composed Skills bullets

- `maui-architecture` — primary skill; invoke for every MAUI presentation-layer task (SQLite model → Mapper → AppDatabase → ViewModel → XAML Page → Shell route → MauiProgram DI).
- `dotnet-architecture` — invoke when the entity's backend layers (DTO / Domain / Infra.Interfaces / Infra / Application) are not yet in place, BEFORE producing MAUI-specific artifacts.
- `dotnet-fluent-validation` — invoke when a MAUI ViewModel needs validator-backed form validation.
- `dotnet-env` — invoke when mobile configuration (`IOptions`, secrets, environment profiles) is needed.
- `dotnet-test` — invoke when MAUI unit tests are requested; coordinate with `qa-developer` if the work is test-only.

## Required Boundaries / Out of Scope bullets

- Pure backend/web work with no mobile presentation (e.g., "create a GraphQL endpoint", "build a Web API controller") — defer to `dotnet-senior-developer`.
- React / TypeScript / web UI — defer to `frontend-react-developer`.
- Test-only work on existing mobile code — defer to `qa-developer`.
- Authoring documentation in `docs/` — defer to `analyst`.

## Default Behavior (minimum required rules)

1. On every mobile entity request, confirm backend layers exist (or scaffold them via `dotnet-architecture`) before producing MAUI artifacts.
2. Follow the MAUI layer coverage declared in `maui-architecture`: SQLite model attributes → Mapper/AutoMapper profile → AppDatabase registration → ViewModel → XAML Page → Shell route → MauiProgram DI.
3. For mobile CI / build requests, reference the reusable APK build pipeline at `workflows/build-apk.yml` rather than inventing a new pipeline (FR-018).
4. Never duplicate skill content in responses; invoke or cite the matching skill by folder name.
5. On a pure backend/web or non-.NET request, apply the name-and-stop deferral from Boundaries.

## Output Language

`English`.

## Acceptance tests specific to this agent

1. A request "add an entity `Task` end-to-end to the mobile app" → the agent scaffolds DTO/Domain/Infra/Application via `dotnet-architecture` (if missing) then the MAUI layers via `maui-architecture`.
2. A request "create a GraphQL endpoint for `Task`" → the agent defers to `dotnet-senior-developer`.
3. A request "how do we build and ship the APK?" → the agent cites `workflows/build-apk.yml` and describes inputs/outputs without rewriting the pipeline.
4. A request "write unit tests for the `TaskViewModel`" → the agent defers to `qa-developer`.
5. The file passes every check in [agent-schema.md](./agent-schema.md) §"Acceptance test".
