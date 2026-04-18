# Canonical upstream attribution snippet

The agent file `agents/ui-ux-pro-max-designer.md` MUST contain exactly the line below, as a Markdown blockquote, placed **after** the YAML frontmatter closing `---` and **before** the `# UI/UX Pro Max Designer` H1. Used by SC-013 grep-based validation.

```markdown
> Based on [ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) by @nextlevelbuilder — origin of the `ui-ux-pro-max` skill this agent composes.
```

## Rules

- URL MUST be exactly `https://github.com/nextlevelbuilder/ui-ux-pro-max-skill`. No shorteners, no tracking params, no trailing slash.
- The blockquote MUST be a single line (no multi-line wrap in the source file).
- The line is metadata of provenance; it stays in English regardless of the agent's bilingual output rule.
- Grep validation: `rg -c "https://github.com/nextlevelbuilder/ui-ux-pro-max-skill" agents/ui-ux-pro-max-designer.md` MUST return exactly `1`.

## Rationale

See `research.md` §Decision 3. FR-022 fixes this block; SC-013 validates it.
