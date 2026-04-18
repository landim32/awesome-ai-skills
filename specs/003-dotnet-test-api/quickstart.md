# Quickstart — Verifying the `dotnet-test-api` Skill

**Feature**: 003-dotnet-test-api
**Prereq**: PR merged or branch `003-dotnet-test-api` checked out locally. A .NET 8 SDK installed for behavioral tests.

## 1. Structural Verification (≤ 2 minutes)

Run these from repo root; each must pass.

### 1.1 Skill file exists at canonical path

```bash
test -f skills/dotnet-test-api/SKILL.md && echo OK
```

### 1.2 Frontmatter has all 4 required fields with correct values

```bash
rg -U "^---\nname: dotnet-test-api\ndescription: .{80,}\nallowed-tools: .+\nuser-invocable: true\n---" skills/dotnet-test-api/SKILL.md
```

### 1.3 SKILL.md size budget (SC-010)

```bash
wc -l skills/dotnet-test-api/SKILL.md
# Must be ≤ 400
```

### 1.4 At least 3 auth presets documented (SC-008)

```bash
rg -c "^### " skills/dotnet-test-api/SKILL.md
# Count the "### " headings under the "## Auth Presets" section specifically:
rg -U "## Auth Presets" -A 200 skills/dotnet-test-api/SKILL.md | rg -c "^### (NAuth|OAuth2|API key|API Key)"
# Must be ≥ 3
```

### 1.5 Agent `qa-developer` composes both skills (SC-009, SC-002)

```bash
rg "^- \`dotnet-test\`" agents/qa-developer.md         # must match once
rg "^- \`dotnet-test-api\`" agents/qa-developer.md     # must match once
```

### 1.6 Agent description updated (FR-011)

```bash
rg "unit and external API tests|external API tests" agents/qa-developer.md
# Must match
```

### 1.7 Agent preserves Output Language canonical block (feature 002)

```bash
rg "Respond in the language of the request" agents/qa-developer.md
# Must match
```

### 1.8 Agent file stays ≤ 100 lines (consistency with feature 002)

```bash
wc -l agents/qa-developer.md
# Should remain ≤ 100 (soft target; fail only if > 120)
```

## 2. Behavioral Smoke Tests (≤ 15 minutes, manual)

Invoke the skill or agent via Claude Code against a scratch .NET 8 solution. Prep: `dotnet new sln -n ScratchApi`, add a minimal `ScratchApi.API` and `ScratchApi.DTO` project, plus a minimal `OrderController` with `[Authorize]` on `GET /order/getById/{id}`.

### 2.1 US1 — Boot project via agent (P1)

**Prompt**: `"Crie os testes de API para o projeto ScratchApi"`

**Expect**:
- Agent responds in Portuguese (language match).
- Agent asks to disambiguate unit vs API (research §Decision 6) OR proceeds directly because the request says "API".
- Skill invoked. New folder `ScratchApi.ApiTests/` created with: csproj + appsettings.Test.json (placeholders) + Fixtures/ + empty Helpers/TestDataHelper.cs.
- DTO project auto-detected as `ScratchApi.DTO` (Q2: single candidate, auto-reference).
- `dotnet sln list` now includes the ApiTests project.

### 2.2 US2 — Add tests for a specific controller (P1)

**Prompt**: `"Adicione testes de API para o OrderController"`

**Expect**:
- `Controllers/OrderControllerTests.cs` created with `[Collection("ApiTests")]`, anonymous 401 test for the `[Authorize]` endpoint, authenticated happy-path test.
- `Helpers/TestDataHelper.cs` grew with factories only for OrderController DTOs — no orphans (SC-006).
- Asserts use FluentAssertions `.Should()` — zero `Assert.*` (SC-005).

### 2.3 US3 — Env var override works (P2)

```bash
export ApiBaseUrl=https://staging.example.com/api
export Auth__BaseUrl=https://staging.example.com/auth-api
export Auth__Email=qa@example.com
export Auth__Password=<secret>
cd ScratchApi && dotnet test ScratchApi.ApiTests/
```

**Expect**: fixture reads env vars, not the placeholders in `appsettings.Test.json`. Login attempt goes to the staging URL.

### 2.4 US4 — Ambiguity handling on `qa-developer` (P1)

**Prompt**: `"Create tests for OrderController"`

**Expect**:
- Agent asks via `AskUserQuestion` whether it's unit tests or API tests (research §Decision 6).
- Choosing "unit" invokes `dotnet-test` → adds to `ScratchApi.Tests/`.
- Choosing "API" invokes `dotnet-test-api` → works on `ScratchApi.ApiTests/`.

### 2.5 Secrets fast-fail (FR-016, SC-012)

Run `dotnet test ScratchApi.ApiTests/` **without** exporting env vars.

**Expect**: test run fails in `InitializeAsync` with a message naming the missing env var — e.g., `Config key 'Auth:Email' still holds the placeholder. Export environment variable 'Auth__Email' before running the tests ...`.

### 2.6 Detect-and-prompt (Q2) — zero DTO candidates

Prep: remove `ScratchApi.DTO` from the solution, keep only `ScratchApi.API`.

**Prompt**: `"Crie testes de API"`

**Expect**: skill asks the user whether to (a) provide a DTO project path manually or (b) use inline payloads.

### 2.7 Auth preset switch — NAuth

**Prompt**: `"Recrie a fixture usando o preset NAuth"`

**Expect**: skill consults SKILL.md §Auth Presets → NAuth, modifies `ApiTestFixture.cs` to inject `X-Tenant-Id`, `User-Agent`, `X-Device-Fingerprint` headers and reads `Tenant`, `UserAgent`, `DeviceFingerprint` from `appsettings.Test.json`.

## 3. Constitution Alignment

- `skills/dotnet-test-api/SKILL.md` is 100% English (Constitution §III). Check: no non-ASCII letters outside code fences / URLs.
- Frontmatter validates against `contracts/skill-frontmatter.schema.json`.
- Agent change preserves `## Output Language`, `## Boundaries`, `tools` (Constitution §V metadata discipline).
- No new top-level folders introduced (Constitution §II).

## 4. Ready-to-ship signals

- All grep/wc checks in §1 pass.
- Behavioral tests §2.1, §2.2, §2.4, §2.5 match expected outcomes.
- `dotnet build ScratchApi.ApiTests/` succeeds on first attempt (SC-003).
- `dotnet test ScratchApi.ApiTests/` finishes in ≤ 60 s/controller when API responds ≤ 2 s/request (SC-004).
