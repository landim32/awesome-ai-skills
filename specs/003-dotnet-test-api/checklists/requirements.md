# Specification Quality Checklist: Skill `dotnet-test-api`

**Purpose**: Validate specification completeness and quality before proceeding to planning
**Created**: 2026-04-18
**Last Updated**: 2026-04-18 (após `/speckit.clarify` — 5 perguntas integradas)
**Feature**: [spec.md](../spec.md)

## Content Quality

- [x] No implementation details (languages, frameworks, APIs)
- [x] Focused on user value and business needs
- [x] Written for non-technical stakeholders
- [x] All mandatory sections completed

## Requirement Completeness

- [x] No [NEEDS CLARIFICATION] markers remain
- [x] Requirements are testable and unambiguous
- [x] Success criteria are measurable
- [x] Success criteria are technology-agnostic (no implementation details)
- [x] All acceptance scenarios are defined
- [x] Edge cases are identified
- [x] Scope is clearly bounded
- [x] Dependencies and assumptions identified

## Feature Readiness

- [x] All functional requirements have clear acceptance criteria
- [x] User scenarios cover primary flows
- [x] Feature meets measurable outcomes defined in Success Criteria
- [x] No implementation details leak into specification

## Notes

- **Clarifications integradas (sessão 2026-04-18)**:
  1. Q1 — Auth default: Generic JWT Bearer (não NAuth). NAuth vira preset (integrado em FR-004, FR-005, FR-014).
  2. Q2 — DTO coupling: detect-and-prompt por sufixos conhecidos (`.DTO`, `.Dto`, `.Dtos`, `.Contracts`, `.Models`, `.Shared`) — integrado em FR-003 e Assumptions.
  3. Q3 — Secrets: template + env overrides obrigatórios, placeholders `REPLACE_VIA_ENV_*` + fast-fail na fixture. Integrado em FR-004, FR-015, FR-016, SC-011, SC-012.
  4. Q4 — User-invocable: `true`, paridade com `dotnet-test`. Integrado em FR-001.
  5. Q5 — TestDataHelper: on-demand per controller, sem factories órfãs. Integrado em FR-008, SC-006.
- **Stack constraint**: .NET 8 + xUnit + Flurl.Http + FluentAssertions é definição de escopo da skill, não "implementation detail" da spec.
- **Novo FR-016** e **SC-011/SC-012** adicionados durante clarificação.
- Items marked incomplete require spec updates before `/speckit.plan`.
