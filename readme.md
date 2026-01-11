### welcome to my system configuration repo!

Hi!, I'm new to NixOS (and its associated tools), and therefore, it's probably best not to use this as anything more than some possible inspiration :).

As always, feel free to give me suggestions on how I could make something better!

### Structure
This flake uses the (opinionated) library [Blueprint](https://github.com/numtide/blueprint) for organizing everything since I wanted to avoid boilerplate. It mostly follows the structure as specified in their docs, save for some extra module types.
```
.
├── hosts # individual systems
│   └── brittlehollow
│       ├── *.nix # per-system config (such as ups settings)
│       └── users # per-system users (also imports modules/home)
└── modules
    ├── darwin # MacOS system
    ├── disko # disk layouts
    ├── extra # extra modules (to be imported as-needed)
    ├── home # home manager
    │   └── cli # CLI programs (fish, git, ssh, etc.)
    └── nixos # NixOS system
        ├── apps # application configurations (forgejo, immich, minecraft, etc.)
        └── server # NixOS server-specific modules
```
 
### Dependencies
Key flakes:
- nix-private - sops-nix managed secrets and other config that doesn't fit here
- nix-helpers - A monorepo of several (typically python) applications and tools used here
