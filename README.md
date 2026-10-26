# Comida + Poção Extra | Food + Extra Potion

The Witcher 3 mod by **yero_gamer**. Version **0.5.4**, including controller support.

[Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3816490233) · [Português](README.pt-BR.md) · [Development](docs/DEVELOPMENT.md)

Adds a dedicated food slot and a fifth potion/decoction slot alongside the four original potion slots. Supports inventory/radial selection, custom keyboard/mouse shortcuts and the game's controller commands. Controller cycling includes the two additional slots. Selections persist across saving and loading.

## Install

Subscribe on Steam Workshop, wait for synchronization and restart the game. Unsubscribe and restart after Steam synchronizes to remove it. Use one active copy. The repository is also a development source: copy only `mods/modSlotComida` for a deliberate manual installation after disabling any other copy.

## Source and checks

- `mods/modSlotComida/content/scripts/`: all six WitcherScript sources.
- `ui/src/`: ActionScript sources exported from the final released UI resources.
- `tools/`: portable verification, packaging and UI resource tooling.
- `tests/`: controller/inventory regressions executing actual script methods with engine mocks.
- `manifest.json`: SHA-256 hashes of the exact tested distribution files.

```sh
python tools/project.py verify
python tests/run.py
python tools/project.py build
```

Python 3.10+ and Node.js 18+ are required for these developer commands. No third-party runtime packages or game installations are needed to run the logic tests. The supplied packed UI resources are used by the normal build; UI editing is described in [ui/README.md](ui/README.md).

In-game labels are currently Portuguese; the controller adaptation follows the original game controls. Custom keyboard and mouse bindings remain available. The mod is independent of [Shop Cleanup in 7 Days](https://github.com/richardcostarocha/witcher3-shop-cleanup-7-days).

## Compatibility and validation

Other mods replacing the same inventory, player/input, HUD, options or popup scripts may need a merge. This repository includes the tested UI compatibility changes; it is not a universal compatibility guarantee.

The final private R3 was confirmed by the author to launch, perform the extra-slot inventory swap, retain both items and preserve selections and swaps after a full save/restart/load cycle. The distribution's scripts and UI resources are unchanged from that approved revision. Automated tests use engine mocks and do not replace testing in the game. Report game/mod versions, reproduction steps, the full error and other active mods when opening an issue.
