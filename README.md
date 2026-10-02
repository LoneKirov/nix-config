<h1 align="center">🗺️ kanto</h1>

<p align="center">
  <em>One flake for every machine in the region.</em>
</p>

<p align="center">
  <a href="https://github.com/LoneKirov/nix-config/actions/workflows/nix-ci.yml"><img alt="Nix CI" src="https://github.com/LoneKirov/nix-config/actions/workflows/nix-ci.yml/badge.svg"></a>
  <a href="https://nixos.org"><img alt="NixOS unstable" src="https://img.shields.io/badge/NixOS-unstable-5277C3?logo=nixos&logoColor=white"></a>
  <a href="https://flake.parts"><img alt="flake-parts" src="https://img.shields.io/badge/built%20with-flake--parts-7EBAE4"></a>
  <a href="https://github.com/jj-vcs/jj"><img alt="Jujutsu" src="https://img.shields.io/badge/vcs-jujutsu-8A2BE2"></a>
</p>

---

| | Host | Role |
|---|---|---|
| ❄️ | **articuno** | Workstation: NVIDIA, niri + DankMaterialShell |
| 🪟 | **articuno-wsl** | NixOS on WSL |
| 🧬 | **mew** | Framework laptop: niri + DankMaterialShell |
| 🔥 | **moltres** | Home server: media, SSO, binary cache, backups |
| 💤 | **slowpoke** | Raspberry Pi 3: Tailscale exit node |

Hosts and their roles are declared in [`hosts/default.nix`](hosts/default.nix); the shared modules in [`modules/`](modules) turn those roles into config.

```mermaid
flowchart LR
  main[(GitHub main)] --> ci[Nix CI]
  ci -- "push builds" --> moltres[🔥 moltres]
  moltres -- "cache.kanto.casa" --> slowpoke[💤 slowpoke] & articuno[❄️ articuno] & mew[🧬 mew]
  main -. "daily auto-upgrade" .-> moltres & slowpoke
  articuno & mew & slowpoke -- "btrbk" --> moltres
```

## 🚀 Deploying

```sh
nh os switch                                               # this machine
nh os switch --target-host moltres --build-host moltres    # a server
```

- Remote deploys build on the target, since only CI may push unsigned paths into another host's store.
- slowpoke only installs what's already in the cache. After CI finishes on `main`, let it upgrade on its own or run `systemctl start nixos-upgrade` on it.
