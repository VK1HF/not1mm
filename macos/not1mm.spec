# -*- mode: python ; coding: utf-8 -*-
# PyInstaller spec for the macOS Not1MM app (onedir, windowed, arm64).
# Build with macos/build.sh, which runs this from the repository root.

import tomllib
from pathlib import Path

from PyInstaller.utils.hooks import collect_data_files, collect_submodules

ROOT = Path(SPECPATH).parent
with open(ROOT / "pyproject.toml", "rb") as f:
    VERSION = tomllib.load(f)["project"]["version"]

# Contests are imported by name at run time (importlib), so every plugin
# has to be listed or the frozen app cannot open them.
hiddenimports = (
    collect_submodules("not1mm.plugins")
    + collect_submodules("not1mm.lib")
    + collect_submodules("not1mm")
)

# Everything under not1mm/data (UI files, fonts, cty.json, MASTER.SCP,
# translations, phonetics) and the icons.
datas = collect_data_files("not1mm", include_py_files=False)
datas += [(str(ROOT / "LICENSE"), ".")]

a = Analysis(
    [str(ROOT / "macos" / "not1mm_launcher.py")],
    pathex=[str(ROOT)],
    binaries=[],
    datas=datas,
    hiddenimports=hiddenimports,
    hookspath=[],
    runtime_hooks=[],
    excludes=["tkinter"],
    noarchive=False,
)
pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name="not1mm",
    debug=False,
    strip=False,
    upx=False,
    console=False,
    target_arch="arm64",
)

coll = COLLECT(exe, a.binaries, a.datas, strip=False, upx=False, name="not1mm")

app = BUNDLE(
    coll,
    name="not1mm.app",
    icon=str(ROOT / "macos" / "not1mm.icns"),
    bundle_identifier="io.github.mbridak.not1mm",
    version=VERSION,
    info_plist={
        "CFBundleName": "not1mm",
        "CFBundleDisplayName": "not1mm",
        "CFBundleShortVersionString": VERSION,
        "CFBundleVersion": VERSION,
        "NSHighResolutionCapable": True,
        "LSMinimumSystemVersion": "12.0",
        "NSMicrophoneUsageDescription":
            "Not1MM uses audio devices for voice keying and audio macros.",
        "NSLocalNetworkUsageDescription":
            "Not1MM talks to rigctld, flrig and TCI for radio control, and uses "
            "multicast on the local network for multi-operator logging.",
        "NSHumanReadableCopyright": "Not1MM by Michael Bridak, K6GTE. GPL-3.0-or-later.",
    },
)
