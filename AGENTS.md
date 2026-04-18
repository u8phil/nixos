# AGENTS.md

## Project Overview

This repository is a personal NixOS flake for a single `x86_64-linux` host named `nixos`.
It combines:

- System configuration from `modules/nixos/`
- Host wiring from `hosts/nixos/`
- Home Manager configuration for user `phil` from `home/`
- Plasma desktop configuration via `plasma-manager`
- Secret management via `sops-nix`
- AI/MCP tooling integrations such as Claude Code, Opencode, and `mcp-nixos`

Home Manager is integrated through the NixOS flake, not managed as a separate standalone setup.

## Repository Layout

- `flake.nix`: main entrypoint, inputs, overlays, and `nixosConfigurations.nixos`
- `hosts/nixos/`: host-level entrypoint that imports the shared NixOS module set
- `modules/nixos/`: system-level modules for boot, networking, desktop, audio, users, packages, secrets, and services
- `home/`: Home Manager modules for user applications, terminal tools, AI tooling, and Plasma setup
- `home/ai/`: Home Manager modules for AI tooling such as Claude Code, OpenCode, and GitHub MCP
- `home/plasma/`: Plasma Manager configuration, including panels and desktop behavior
- `secrets/`: SOPS-managed secret material

## Change Guidelines

- Keep changes small and local to the relevant module.
- Prefer updating an existing module over creating a new abstraction unless reuse is clearly needed.
- Preserve the split between system config in `modules/nixos/` and user config in `home/`.
- When changing user-facing tools like Claude Code, OpenCode, or GitHub MCP, check `home/ai/` first. For Zed, Plasma, and other user modules, check `home/` first.

## Validation Rules

- NEVER use `nix build` in this repository for routine validation.
- Prioritize `sudo nixos-rebuild dry-build --flake .#nixos` for validation.
- If activation behavior matters, prioritize `sudo nixos-rebuild dry-activate --flake .#nixos`.
- Use `sudo nixos-rebuild switch --flake .#nixos` only when explicitly asked to apply the changes.
- For quick syntax checks, `nix-instantiate --parse <file>` is fine, but the preferred end-to-end validation path is still the `sudo nixos-rebuild dry-*` workflow.

## Notes For Agents

- Assume this repo is the source of truth for both system and Home Manager state.
- Be careful with dirty worktrees: do not revert unrelated user changes.
- If a change touches Home Manager, remember it is still evaluated through the NixOS flake.
- Never search for a pattern across the whole `/nix/store` or run broad `grep`/`rg` there. It can be extremely large. If you need something from the store, inspect a specific known path instead or find a known path via CLI of choice.
- If you need some CLI tool and you don't find it in PATH, use `nix shell nixpkgs#package -c 'COMMAND'`