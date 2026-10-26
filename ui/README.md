# UI source and resources

`src/` contains the inventory/HUD ActionScript classes exported directly from the final 0.5.4 resources using JPEXS Free Flash Decompiler. This includes the extra-slot layout/selection classes and native UI classes used by the regression harness. It is not a separate UI language translation.

The canonical packed resources are `mods/modSlotComida/content/blob0.bundle` and `metadata.store`. The ordinary project build copies these approved files unchanged. No compiler binary is bundled.

The original resource files, including Flash symbols/assets, can be recovered and repacked with Python's standard library:

```sh
python tools/ui.py inspect
python tools/ui.py unpack
python tools/ui.py repack --resources dist/ui-export
```

Both output commands require a fresh output directory. Use `--out` for another directory. Repacking writes a bundle/index pair to `dist/ui-repacked`; it does not replace the canonical distribution or touch the game.

For interface edits, compile the edited ActionScript into the relevant exported SWF/GFX with your own compatible Flash tooling (the project was built with JPEXS FFDec). `.redswf` resources also contain a CR2W wrapper and embedded GFX; changes to their size must update the wrapper sizes/checksums. A raw SWF is not a replacement for a `.redswf` wrapper. Repacking validates resource wrappers, bundle data and the index. Test interface changes in the game before replacing the canonical distribution and refreshing the release manifest.
