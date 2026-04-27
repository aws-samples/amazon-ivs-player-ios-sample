# IVS Player Samples — Consolidation Spec

## Goal

Combine the 3 separate iOS apps (BasicPlayback, CustomUI, QuizDemo) into a single unified app using a master/detail navigation pattern. The master screen lists the 3 demos; tapping one pushes to the corresponding detail screen with the same functionality as the original app.

## Current State

| Project | View Controllers | Key Features |
|---|---|---|
| BasicPlayback | `ViewController` | Hardcoded stream URL, play/pause/seek, playback rate, quality picker, buffered range, PiP (iOS 15+) |
| CustomUI | `MainViewController`, `SourceSelectViewController` | Custom overlay controls with blur, source URL picker (modal), dark/light theme, orientation-aware layout, UserDefaults history |
| QuizDemo | `SourceViewController`, `PlayerViewController` | Source URL picker, timed metadata quiz overlay, animated answer feedback |

Shared across all 3:
- Identical `AppDelegate` (AVAudioSession `.playback` setup)
- Identical `SourceEntity` model (CustomUI & QuizDemo)
- AmazonIVSPlayer SDK v1.51.0 via local Swift Package
- iOS 14.0 deployment target, storyboard-based UI

## Architecture

### New Project: `AmazonIVSPlayerSamples`

A single `.xcodeproj` replacing the 3 existing projects, named to match the existing workspace. The workspace will reference only this project plus the existing `AmazonIVSPlayer` local Swift Package.

### Rename Strategy

All file and directory renames must use `git mv` to preserve history. Storyboard files are renamed only at the filesystem level — no edits to storyboard XML contents. Class renames and module reference updates happen in Swift source and the Xcode project file, not inside storyboards.

### Navigation Flow

```
UINavigationController (root)
  └─ SamplesViewController (master — UITableViewController, programmatic)
       ├─ Push → UIStoryboard("BasicPlayback").instantiateInitialViewController()
       ├─ Push → UIStoryboard("CustomUI").instantiateInitialViewController()
       │            └─ Modal → CustomUISourceViewController (internal storyboard segue)
       └─ Push → UIStoryboard("QuizDemo").instantiateInitialViewController()
                    └─ Segue → QuizDemoViewController (internal storyboard segue)
```

Each demo's storyboard is `git mv`-renamed from `Main.storyboard` to a unique name (e.g., `BasicPlayback.storyboard`) and loaded programmatically via `UIStoryboard(name:bundle:).instantiateInitialViewController()`. No storyboard XML is edited. Internal segues within each storyboard remain untouched.

### File/Group Structure

```
AmazonIVSPlayerSamples/
├── AppDelegate.swift                  # Single shared AppDelegate
├── SamplesViewController.swift         # NEW — master list
├── Shared/
│   └── Source.swift                    # git mv + rename from SourceEntity.swift
│   └── SourceTableViewCell.swift       # NEW — unified cell, replaces old SourceTableViewCell + SourceEntityCell
│   └── UIView+Gradient.swift          # Shared extension
├── BasicPlayback/
│   └── BasicPlaybackViewController.swift   # git mv from ViewController.swift
│   └── BasicPlayback.storyboard            # git mv + rename from Main.storyboard
├── CustomUI/
│   └── CustomUIViewController.swift        # git mv from MainViewController.swift
│   └── CustomUISourceViewController.swift  # git mv from SourceSelectViewController.swift
│   └── UIColor+Hex.swift                   # CustomUI-specific (theme colors)
│   └── CMTime+Positional.swift             # CustomUI-specific
│   └── CustomUI.storyboard                 # git mv + rename from Main.storyboard
├── QuizDemo/
│   └── QuizDemoViewController.swift        # git mv from PlayerViewController.swift
│   └── QuizDemoSourceViewController.swift  # git mv from SourceViewController.swift
│   └── AnswerButton.swift
│   └── Question.swift                      # QuizDemo-specific model
│   └── QuizDemo.storyboard                 # git mv + rename from Main.storyboard
├── Assets.xcassets                    # Merged from all 3
├── LaunchScreen.storyboard
└── Info.plist
```

> **Unified `SourceTableViewCell`**: Replaces the old `SourceTableViewCell` (CustomUI) and `SourceEntityCell` (QuizDemo). Programmatic cell using `UITableViewCell(style: .default)` — no storyboard prototype needed. Accepts a `Source` in its `configure(with:)` method. Both source view controllers switch to `tableView.register(SourceTableViewCell.self, ...)` and the prototype cell definitions are removed from the storyboards.

## Implementation Steps

### 1. Create the Xcode project

- New single-view iOS app target `AmazonIVSPlayerSamples`, deployment target iOS 14.0.
- Add `AmazonIVSPlayer` local package dependency (same as existing).
- Update workspace to reference only the new project.

### 2. Create `SamplesViewController`

A `UITableViewController` embedded in a `UINavigationController` as the app's root. Three static rows:

| Row | Title | Subtitle | Detail VC |
|---|---|---|---|
| 0 | Basic Playback | Simple streaming with standard controls | `BasicPlaybackViewController` |
| 1 | Custom UI | Custom player controls with source selection | `CustomUIViewController` |
| 2 | Quiz Demo | Interactive quiz over timed metadata | `QuizDemoSourceViewController` |

Each row pushes the corresponding view controller via `show()`. Use storyboard segues or programmatic push — either works.

### 3. Migrate BasicPlayback

- `git mv ViewController.swift` → `BasicPlaybackViewController.swift`. Rename the class inside the file.
- `git mv` the storyboard into the new location. Do not edit storyboard XML.
- Remove the hardcoded `viewWillAppear` auto-play — instead load/play in `viewDidAppear` so it works correctly when pushed/popped on a nav stack.
- No other logic changes needed.

### 4. Migrate CustomUI

- `git mv MainViewController.swift` → `CustomUIViewController.swift`. Rename the class inside the file.
- `git mv SourceSelectViewController.swift` → `CustomUISourceViewController.swift`. Rename the class inside the file.
- `git mv` the storyboard into the new location. Do not edit storyboard XML.
- The `CustomUISourceViewController` modal presentation stays as-is.
- Extract `UIColor+Hex` and `CMTime+Positional` extensions into `CustomUI/` group.
- Move `SourceEntity` to `Shared/Source.swift`. Rename the struct to `Source`.
- Delete `SourceTableViewCell`. Update `CustomUISourceViewController` to register and use the new shared `SourceTableViewCell`. Remove the prototype cell from the storyboard.

### 5. Migrate QuizDemo

- `git mv SourceViewController.swift` → `QuizDemoSourceViewController.swift`. Rename the class inside the file.
- `git mv PlayerViewController.swift` → `QuizDemoViewController.swift`. Rename the class inside the file.
- `git mv` the storyboard into the new location. Do not edit storyboard XML.
- Move `Question` model to `QuizDemo/`.
- Extract `UIView+Gradient` extension to `Shared/`.
- Move `AnswerButton` into `QuizDemo/` group.
- Delete `SourceEntityCell`. Update `QuizDemoSourceViewController` to register and use the new shared `SourceTableViewCell`. Remove the prototype cell from the storyboard.

### 6. Deduplicate shared code

| Code | Currently in | Action |
|---|---|---|
| `AppDelegate` | All 3 (identical) | Single copy at root |
| `SourceEntity` | CustomUI + QuizDemo (identical) | Single copy in `Shared/Source.swift`, rename struct to `Source` |
| `UIColor(hex:)` + theme colors | CustomUI | Keep in `CustomUI/` (only used there) |
| `CMTime.positionalTime` | CustomUI | Keep in `CustomUI/` (only used there) |
| `UIView.applyGradientBackground/applyShadow` | QuizDemo | Move to `Shared/` |
| `Question` | QuizDemo | Keep in `QuizDemo/` (only used there) |
| `SourceTableViewCell` / `SourceEntityCell` | CustomUI / QuizDemo | Delete both, replace with new shared `SourceTableViewCell` (programmatic, no storyboard prototype) |

### 7. Merge assets

- CustomUI has the most image assets (play/pause buttons, settings icons, modal button images). Copy all into the unified `Assets.xcassets`.
- QuizDemo has `AnswerCorrect`/`AnswerIncorrect` named colors and `more-icon`. Copy those in.
- BasicPlayback has no custom assets beyond the default app icon.
- Resolve any naming conflicts (both CustomUI and QuizDemo have `more-icon` — verify they're identical or namespace them).

### 8. Info.plist consolidation

Merge the superset of all 3 plists:
- `UIBackgroundModes: audio` (from BasicPlayback — needed for PiP)
- `UIStatusBarStyle: UIStatusBarStyleLightContent` (from CustomUI)
- `UISupportedInterfaceOrientations`: all orientations (superset of BasicPlayback + CustomUI; QuizDemo was portrait-only but that can be handled per-VC)
- Remove `UIMainStoryboardFile` — the root `UINavigationController` + `SamplesViewController` is set up programmatically in `AppDelegate`.

### 9. Per-VC orientation support

Since the 3 demos have different orientation needs:
- BasicPlayback & CustomUI: all orientations
- QuizDemo: portrait only

Handle this by overriding `supportedInterfaceOrientations` on `QuizDemoSourceViewController` and `QuizDemoViewController` to return `.portrait`. The app delegate forwards orientation queries to the top view controller via `application(_:supportedInterfaceOrientationsFor:)`.

### 10. Update README

Update `README.md` to reflect the new single-app structure: remove references to 3 separate projects, document the master/detail flow, and update setup instructions.

### 11. Bundle identifier (manual)

Manually set the bundle identifier to `com.amazonaws.ivs.player.sample-app` in the new Xcode project target settings.

### 12. Clean up old projects

Delete the 3 original `.xcodeproj` directories (`BasicPlayback/BasicPlayback.xcodeproj`, `CustomUI/CustomUI.xcodeproj`, `QuizDemo/QuizDemo.xcodeproj`) and any leftover empty directories from the `git mv` operations.

## Risks / Considerations

- **Storyboard object IDs**: Each project's storyboard uses its own IDs. Extracting scenes into separate `.storyboard` files per demo avoids conflicts.
- **UserDefaults key collision**: Both CustomUI and QuizDemo use `"sources_history_data"` as their UserDefaults key. Namespace them (e.g., `"customui_sources_history_data"`, `"quiz_sources_history_data"`) so they don't share state.
- **UserDefaults Codable migration**: Renaming `SourceEntity` → `Source` won't break `PropertyListDecoder` (Codable uses property names, not the struct name), but the UserDefaults key namespacing above effectively resets saved data anyway.
- **`more-icon` asset**: Used in both CustomUI and QuizDemo. Verify they're the same image; if not, rename one.
- **Module references in storyboards**: Storyboard `customModule` and `customClass` attributes reference the original module and class names. After renaming Swift classes, manually update `customClass` to the new class name and `customModule` to `AmazonIVSPlayerSamples` in each storyboard. Outlets, segues, and constraints are unaffected since they're wired by name, not class.
- **`SourceSelectViewDelegate` protocol**: Lives in `CustomUISourceViewController`. Rename references from `SourceSelectViewDelegate` to match the new naming if desired, and update `removeVideoSourceEntity` → `removeSource` or similar to align with the `Source` rename.
- **PiP background behavior**: BasicPlayback's `applicationDidEnterBackground` logic pauses playback unless PiP is active. This should still work in the consolidated app since it uses NotificationCenter observers scoped to the VC lifecycle.
