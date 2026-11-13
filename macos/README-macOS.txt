Not1MM for macOS (Apple Silicon) - test build
==============================================

This is an unsigned test build of Not1MM, the contest logger by Michael
Bridak, K6GTE (https://github.com/mbridak/not1mm). It is free software under
the GNU GPL v3; see LICENSE.

Install
-------
1. Open the DMG.
2. Drag not1mm.app onto the Applications folder.
3. Eject the DMG.

First launch (Gatekeeper)
-------------------------
The app is not signed by Apple, so macOS blocks the first launch. Use ONE of:
1. In Applications, right-click not1mm.app, choose Open, then Open again.
2. Or try to open it, then go to System Settings > Privacy & Security and
   click "Open Anyway".
3. Or run this in Terminal:
       xattr -dr com.apple.quarantine /Applications/not1mm.app

Radio and rotator control (Hamlib)
----------------------------------
rigctld and rotctld are not included. Install Hamlib with Homebrew:
       brew install hamlib
then start rigctld for your radio (for a test, "rigctld -m 1" is a dummy
radio) and choose rigctld in Not1MM's settings. flrig and TCI work without
Hamlib.

Where your data lives
---------------------
Logs, settings and databases: ~/.not1mm

Notes
-----
- Apple Silicon (arm64) only. Needs macOS 12 or later.
- cwdaemon is Linux only; on macOS use WinKeyer (serial) or SwiftKeyer.
- macOS asks for microphone and local-network access the first time they
  are needed (voice keying, radio control, multi-op). Allow them.
