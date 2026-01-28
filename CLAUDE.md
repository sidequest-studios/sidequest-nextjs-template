# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Starter Template

This is a Next.js 16 + React 19 + Tailwind 4 + shadcn/ui starter template.

When a user clones this repo, help them:
1. Describe what they want to build
2. Initialize a fresh git repo (`rm -rf .git && git init`)
3. Update this CLAUDE.md with project-specific guidance
4. Update package.json name and README.md

## Commands

```bash
bun dev          # Dev server (http://localhost:3000)
bun lint         # Biome check
bun typecheck    # TypeScript check
```

## Structure

- `src/app/` - Pages and layouts
- `src/components/ui/` - shadcn/ui components
- `src/lib/utils.ts` - `cn()` helper for class merging
- Import alias: `@/` maps to `src/`
