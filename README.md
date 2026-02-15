# Awesome AI Skills - Curated Claude Code Skills Collection

![Claude Code](https://img.shields.io/badge/Claude_Code-Skills-blueviolet)
![License](https://img.shields.io/badge/License-MIT-green)
![GitVersion](https://img.shields.io/badge/GitVersion-SemVer-blue)

## Overview

**Awesome AI Skills** is a curated collection of reusable [Claude Code](https://claude.ai/code) skills — specialized instructional guides and templates for AI-assisted development. Each skill provides implementation patterns, code templates, naming conventions, and best practices covering **React/TypeScript** and **.NET/C#** stacks. Built to accelerate feature scaffolding, ensure architectural consistency, and share knowledge across projects.

The repository also includes reusable **GitHub Actions workflow templates** for semantic versioning, release automation, and NPM publishing.

---

## 🚀 Features

- 🏗️ **dotnet-arch-entity** — Full entity scaffold following Clean Architecture (DTO → Domain → Infra → Application → API) with EF Core Code First, AutoMapper, and Repository pattern
- 📄 **dotnet-doc-controller** — Comprehensive API documentation generator for .NET REST controllers with Swagger/OpenAPI
- 🔐 **nauth-guide** — NAuth.ACL and NAuth.DTO integration for user authentication, JWT handling, and RBAC in .NET 8
- 🤖 **ntools-guide** — NTools integration for ChatGPT, DALL-E, S3 file upload, slug generation, email sending, and document validation in .NET 8
- ⚛️ **react-arch** — Complete React entity architecture: TypeScript types, service layer, context/provider, custom hooks, and provider registration
- 🪟 **react-modal** — Modal dialog creation using Radix UI Dialog primitives with Tailwind CSS styling and accessibility patterns
- 🔔 **react-alert** — Toast/alert notifications using the sonner library with typed notification patterns
- 🎨 **frontend-design** — Design thinking guidelines for distinctive, production-grade frontend interfaces that avoid generic AI aesthetics
- 📝 **readme-generator** — Standardized README.md generation with multi-phase project discovery and template-based output
- 🔄 **Reusable Workflows** — GitHub Actions templates for semantic versioning (GitVersion), automated releases, and NPM publishing

---

## 🛠️ Technologies Used

### Skills Cover

- **React + TypeScript** — Frontend architecture, UI components, state management
- **Tailwind CSS + Radix UI** — Styling and accessible UI primitives
- **.NET 8 + C#** — Clean Architecture, Entity Framework Core, AutoMapper
- **Sonner** — Toast notification library

### DevOps

- **GitHub Actions** — CI/CD workflow templates
- **GitVersion** — Semantic versioning via commit message conventions
- **NPM** — Package publishing pipeline

---

## 📁 Project Structure

```
awesome-ai-skills/
├── skills/                          # AI skills collection
│   ├── dotnet-arch-entity/          # .NET Clean Architecture entity scaffold
│   ├── dotnet-doc-controller/       # .NET API controller documentation
│   ├── frontend-design/             # Frontend design principles
│   ├── nauth-guide/                 # .NET authentication integration
│   ├── ntools-guide/                # .NET tools (AI, S3, email, etc.)
│   ├── react-alert/                 # Toast/alert notifications
│   ├── react-arch/                  # React entity architecture
│   ├── react-modal/                 # Modal dialog patterns
│   └── readme-generator/            # README.md generator
├── workflows/                       # Reusable GitHub Actions templates
│   ├── version-tag.yml              # Semantic versioning & tagging
│   ├── create-release.yml           # Automated GitHub Release creation
│   └── npm-publish.yml              # NPM package publishing
├── prompts/                         # Prompt templates
├── .github/workflows/               # CI/CD pipelines for this repo
├── collect-skills.ps1               # Skill collector script
├── GitVersion.yml                   # Semantic versioning configuration
├── CLAUDE.md                        # Claude Code guidance file
└── LICENSE                          # MIT License
```

---

## 🔧 Setup

### Prerequisites

- [Claude Code](https://claude.ai/code) CLI installed
- PowerShell (for the skill collector script)

### Using Skills in Your Project

Copy any skill directory into your project's `.claude/skills/` folder:

```bash
mkdir -p .claude/skills
cp -r /path/to/awesome-ai-skills/skills/react-arch .claude/skills/
```

Claude Code will automatically detect and use the skills when relevant to your requests.

### Collecting Skills from Local Projects

The collector script scans all repositories under `C:\repos` for `.claude/skills/` directories and imports any new skills:

```powershell
powershell -File collect-skills.ps1
```

---

## 🔄 CI/CD

### GitHub Actions

**Workflow: Version and Tag** (`version-tag.yml`)
- **Triggers:** Push to `main`, manual dispatch
- **Steps:** Calculates semantic version via GitVersion → Creates and pushes git tag

**Workflow: Create Release** (`create-release.yml`)
- **Triggers:** After "Version and Tag" workflow completes
- **Steps:** Detects version change type → Creates GitHub Release and release branch (major/minor only, skips patch)

### Commit Message Conventions

Version bumps are driven by commit message prefixes:

| Prefix | Version Bump |
|--------|-------------|
| `major:` or `breaking:` | Major |
| `feat:` or `feature:` or `minor:` | Minor |
| `fix:` or `patch:` | Patch |

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Adding a New Skill

1. Create a directory under `skills/` with a descriptive name
2. Add a `SKILL.md` file with frontmatter metadata:

```yaml
---
name: skill-name
description: Brief description of what the skill does
allowed-tools: Read, Write, Edit, Bash
user-invocable: true
---
```

3. Follow existing skills as reference for depth and structure
4. Commit with `feat: add <skill-name> skill` for a minor version bump

### Development Setup

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-skill`)
3. Add your skill following the structure above
4. Commit your changes (`git commit -m 'feat: add new-skill'`)
5. Push to the branch (`git push origin feature/new-skill`)
6. Open a Pull Request

---

## 👨‍💻 Author

Developed by **[Rodrigo Landim Carneiro](https://github.com/landim32)**

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/landim32/awesome-ai-skills/issues)
- **Discussions**: [GitHub Discussions](https://github.com/landim32/awesome-ai-skills/discussions)

---

**⭐ If you find this project useful, please consider giving it a star!**
