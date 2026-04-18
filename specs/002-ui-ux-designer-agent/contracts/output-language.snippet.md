# Canonical `## Output Language` snippet

All 6 agents (1 new + 5 existing) MUST carry exactly the block below, verbatim. Used by SC-010 grep-based validation.

```markdown
## Output Language

Respond in the language of the request. Match the user's language (e.g., Portuguese → Portuguese, English → English). Keep all code identifiers, file paths, and technical keywords in English regardless of the response language.
```

## Usage rules

- Replace the entire existing `## Output Language` section in each target agent file. Do not merge with prior text.
- Do not translate or paraphrase — the exact English text above is part of the contract.
- Grep validation: `rg -U "^## Output Language\n\nRespond in the language of the request\\..*English regardless of the response language\\.$" agents/` MUST match in every agent file.

## Targets

| File | Current state | After change |
|---|---|---|
| `agents/ui-ux-pro-max-designer.md` | does not exist yet | contains snippet (new file) |
| `agents/frontend-react-developer.md` | `## Output Language\n\nEnglish.` | contains snippet |
| `agents/dotnet-senior-developer.md` | `## Output Language\n\nEnglish.` | contains snippet |
| `agents/dotnet-mobile-developer.md` | (verify current value) | contains snippet |
| `agents/qa-developer.md` | (verify current value) | contains snippet |
| `agents/analyst.md` | (verify current value) + description line removed | contains snippet |
