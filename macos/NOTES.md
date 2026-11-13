# Not1MM on macOS: build notes

Test build for Apple Silicon. Built 2026-11-14 on an M2 Max, macOS 15 (Darwin 24.6),
from upstream release 26.11.10 (24516005) on the VK1HF fork, branch macos-packaging.
The author's agreement to an AI agent doing this packaging was confirmed by Ian
(VK1HF) on 2026-11-14 before any change was made.

## Prerequisites

- Xcode Command Line Tools: already present.
- Homebrew installed for this build: python@3.12 (3.12.16), hamlib (4.7.2), create-dmg (1.3.0).
  portaudio 19.7.0 was already installed. (sounddevice's wheel carries its own PortAudio,
  so the app does not need Homebrew's.)

## Phase 1: run from source

- `pip install -e .` in a Python 3.12 venv: OK.
- Entry point `not1mm = "not1mm.__main__:run"` launches. First run creates `~/.not1mm`
  (ham.db, not1mm.json, logs) and opens the first-run settings dialog. No errors or
  warnings were printed.
- Not done unattended: creating a contest, logging a QSO, and exporting Cabrillo and ADIF.
  Ian was at the Mac, so the GUI was not driven automatically. **Left for the hand test.**

## Phase 2: macOS blockers

None found, so **no code changes outside macos/**. Data and config live in `~/.not1mm`
(upstream's existing macOS path via `appdata`), and that is unchanged. Serial ports,
audio devices, cwdaemon and editor opening were not exercised unattended; see the hand-test list.

## Phase 3: the .app

- PyInstaller 6.22.3 with `macos/not1mm.spec`: onedir, windowed, arm64. Bundle id
  `io.github.mbridak.not1mm`, version from pyproject.toml.
- Contests are imported by name (`importlib.import_module("not1mm.plugins.<name>")`),
  so the spec collects every submodule: **96 plugins** are in the frozen archive,
  including cq_ww_cw, oceania_dx_cw/ssb, john_moyle_field_day and wia_remembrance.
- All of not1mm/data (UI files, fonts, cty.json, MASTER.SCP, translations, phonetics)
  is bundled. LICENSE is in Contents/Resources.
- PortAudio: `libportaudio.dylib` (from sounddevice) is bundled and links only to
  CoreAudio/AudioToolbox. No bundled library refers to /opt/homebrew, /usr/local or $HOME.
- Info.plist has NSHighResolutionCapable, NSMicrophoneUsageDescription,
  NSLocalNetworkUsageDescription and CFBundleShortVersionString 26.11.10.
- Icon: `macos/not1mm.icns`, made from not1mm/data/macosicon.png with sips + iconutil.
- Ad-hoc signed; `codesign --verify --deep --strict` passes.
- Hamlib is not bundled; README-macOS.txt says `brew install hamlib`.
- **Launch test: PASS.** Copied out of the DMG and run with `env -i` (PATH=/usr/bin:/bin,
  no venv, no Homebrew Python), it stays up and reaches the first-run settings dialog,
  the same as from source.

## Phase 4: DMG

`dist/Not1MM-26.11.10-macOS-arm64-unsigned.dmg`, 45 MB, sha256 `695bcc2cd94288d410d649413b8083b215643762922d406a0703667c346576d7`.
It contains not1mm.app, an Applications link, LICENSE and README-macOS.txt.
create-dmg's Finder layout step (AppleScript) timed out unattended, so build.sh passes
`--skip-jenkins`. The DMG works, but Finder shows its default icon layout.

## Phase 5: build script

`macos/build.sh`: venv (macos/.venv) → pip install . + pyinstaller → PyInstaller →
LICENSE into Resources → ad-hoc sign + verify → DMG. set -euo pipefail, rerunnable,
prints the DMG path. Ran clean end to end.

## Phase 6: test checklist (on the built app)

| # | Test | Result |
|---|---|---|
| 1 | Launches after copying out of the DMG | PASS (unattended launch without Python/venv); Finder double-click + Gatekeeper left for Ian |
| 2 | Database, contest (CQ WW CW, a VK contest), Station Settings | Not run: GUI |
| 3 | Log QSOs, dupe check | Not run: GUI |
| 4 | Cabrillo and ADIF export | Not run: GUI |
| 5 | CAT via `rigctld -m 1` | Not run: GUI |
| 6 | Function-key macros | Not run: GUI |
| 7 | Band map, check partial, other windows dock | Not run: GUI |
| 8 | Quit and relaunch keeps log and settings | Not run: GUI |

## Open issues

- Items 2–8 above need a person at the Mac.
- The DMG window has no custom layout (see Phase 4).
- Unsigned and not notarized: first launch needs the Gatekeeper bypass in README-macOS.txt.
