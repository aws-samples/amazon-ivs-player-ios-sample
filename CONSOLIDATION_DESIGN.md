# IVS Player Samples — Detailed Design

This document is the implementation-level companion to `CONSOLIDATION_SPEC.md`. It contains every `git mv` command, every file to create/delete, and the full source for all new and modified files.

---

## Phase 1: Directory Scaffolding

Create the target directory structure before moving files.

```bash
mkdir -p AmazonIVSPlayerSamples/Shared
mkdir -p AmazonIVSPlayerSamples/BasicPlayback
mkdir -p AmazonIVSPlayerSamples/CustomUI
mkdir -p AmazonIVSPlayerSamples/QuizDemo
```

---

## Phase 2: git mv Operations

All moves preserve history. Grouped by source project.

### From BasicPlayback/

```bash
git mv BasicPlayback/BasicPlayback/ViewController.swift AmazonIVSPlayerSamples/BasicPlayback/BasicPlaybackViewController.swift
git mv BasicPlayback/BasicPlayback/Base.lproj/Main.storyboard AmazonIVSPlayerSamples/BasicPlayback/BasicPlayback.storyboard
git mv BasicPlayback/BasicPlayback/AppDelegate.swift AmazonIVSPlayerSamples/AppDelegate.swift
```

### From CustomUI/

```bash
git mv CustomUI/CustomUI/Controllers/MainViewController.swift AmazonIVSPlayerSamples/CustomUI/CustomUIViewController.swift
git mv CustomUI/CustomUI/Controllers/SourceSelectViewController.swift AmazonIVSPlayerSamples/CustomUI/CustomUISourceViewController.swift
git mv CustomUI/CustomUI/Extensions/UIColor.swift AmazonIVSPlayerSamples/CustomUI/UIColor+Hex.swift
git mv CustomUI/CustomUI/Extensions/CMTime.swift AmazonIVSPlayerSamples/CustomUI/CMTime+Positional.swift
git mv CustomUI/CustomUI/Models/SourceEntity.swift AmazonIVSPlayerSamples/Shared/Source.swift
git mv CustomUI/CustomUI/Views/Base.lproj/Main.storyboard AmazonIVSPlayerSamples/CustomUI/CustomUI.storyboard
```

### From QuizDemo/

```bash
git mv QuizDemo/QuizDemo/Controllers/PlayerViewController.swift AmazonIVSPlayerSamples/QuizDemo/QuizDemoViewController.swift
git mv QuizDemo/QuizDemo/Controllers/SourceViewController.swift AmazonIVSPlayerSamples/QuizDemo/QuizDemoSourceViewController.swift
git mv QuizDemo/QuizDemo/Custom/AnswerButton.swift AmazonIVSPlayerSamples/QuizDemo/AnswerButton.swift
git mv QuizDemo/QuizDemo/Models/Question.swift AmazonIVSPlayerSamples/QuizDemo/Question.swift
git mv QuizDemo/QuizDemo/Custom/UIView.swift AmazonIVSPlayerSamples/Shared/UIView+Gradient.swift
git mv QuizDemo/QuizDemo/Views/Base.lproj/Main.storyboard AmazonIVSPlayerSamples/QuizDemo/QuizDemo.storyboard
```

### LaunchScreen (pick one — they're all identical)

```bash
git mv BasicPlayback/BasicPlayback/Base.lproj/LaunchScreen.storyboard AmazonIVSPlayerSamples/LaunchScreen.storyboard
```

---

## Phase 3: Assets Merge

```bash
# Start with CustomUI's assets (most complete)
git mv CustomUI/CustomUI/Assets.xcassets AmazonIVSPlayerSamples/Assets.xcassets

# Copy QuizDemo-only assets into the merged catalog
cp -r QuizDemo/QuizDemo/Assets.xcassets/AnswerCorrect.colorset AmazonIVSPlayerSamples/Assets.xcassets/
cp -r QuizDemo/QuizDemo/Assets.xcassets/AnswerIncorrect.colorset AmazonIVSPlayerSamples/Assets.xcassets/
git add AmazonIVSPlayerSamples/Assets.xcassets/AnswerCorrect.colorset
git add AmazonIVSPlayerSamples/Assets.xcassets/AnswerIncorrect.colorset
```

> **Check**: Both CustomUI and QuizDemo have `more-icon`. Compare them — if identical, no action needed (already in the merged catalog from CustomUI). If different, rename QuizDemo's to `quiz-more-icon` and update the QuizDemo storyboard reference.

---

## Phase 4: Files to Delete

```bash
# Old cell files (replaced by unified SourceTableViewCell)
git rm CustomUI/CustomUI/Views/SourceTableViewCell.swift
git rm QuizDemo/QuizDemo/Controllers/SourceEntityCell.swift

# Duplicate AppDelegates
git rm CustomUI/CustomUI/AppDelegate.swift
git rm QuizDemo/QuizDemo/AppDelegate.swift

# Duplicate SourceEntity (kept the CustomUI copy, moved to Shared/)
git rm QuizDemo/QuizDemo/Models/SourceEntity.swift

# Old Xcode projects
git rm -r BasicPlayback/BasicPlayback.xcodeproj
git rm -r CustomUI/CustomUI.xcodeproj
git rm -r QuizDemo/QuizDemo.xcodeproj

# Clean up empty directories left behind
# (git doesn't track empty dirs, but clean up working tree)
find BasicPlayback CustomUI QuizDemo -empty -type d -delete
```

---

## Phase 5: New Files

### 5.1 `AmazonIVSPlayerSamples/AppDelegate.swift` — Modifications

The `git mv`'d AppDelegate needs one change: set up the root window programmatically instead of relying on `UIMainStoryboardFile`.

```swift
import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("‼️ Could not setup AVAudioSession: \(error)")
        }

        let window = UIWindow(frame: UIScreen.main.bounds)
        let nav = UINavigationController(rootViewController: SamplesViewController())
        window.rootViewController = nav
        window.makeKeyAndVisible()
        self.window = window

        return true
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if let nav = window?.rootViewController as? UINavigationController,
           let top = nav.topViewController {
            return top.supportedInterfaceOrientations
        }
        return .all
    }
}
```

### 5.2 `AmazonIVSPlayerSamples/SamplesViewController.swift` — New

```swift
import UIKit

class SamplesViewController: UITableViewController {

    private struct Sample {
        let title: String
        let subtitle: String
        let storyboardName: String
    }

    private let samples = [
        Sample(title: "Basic Playback", subtitle: "Simple streaming with standard controls", storyboardName: "BasicPlayback"),
        Sample(title: "Custom UI", subtitle: "Custom player controls with source selection", storyboardName: "CustomUI"),
        Sample(title: "Quiz Demo", subtitle: "Interactive quiz over timed metadata", storyboardName: "QuizDemo"),
    ]

    private let cellIdentifier = "SampleCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "IVS Player Samples"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        samples.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let sample = samples[indexPath.row]
        if #available(iOS 14.0, *) {
            var config = cell.defaultContentConfiguration()
            config.text = sample.title
            config.secondaryText = sample.subtitle
            cell.contentConfiguration = config
        } else {
            cell.textLabel?.text = sample.title
            cell.detailTextLabel?.text = sample.subtitle
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sample = samples[indexPath.row]
        let storyboard = UIStoryboard(name: sample.storyboardName, bundle: nil)
        guard let vc = storyboard.instantiateInitialViewController() else { return }
        show(vc, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
```

### 5.3 `AmazonIVSPlayerSamples/Shared/Source.swift` — Rename

The `git mv`'d file. Rename the struct from `SourceEntity` to `Source`:

```swift
import Foundation

struct Source: Codable {
    let title: String
    let urlString: String
    let timestamp: Date

    init(_ title: String, _ urlString: String) {
        self.title = title
        self.urlString = urlString
        self.timestamp = Date()
    }
}
```

### 5.4 `AmazonIVSPlayerSamples/Shared/SourceTableViewCell.swift` — New

Programmatic cell replacing both old cell classes.

```swift
import UIKit

class SourceTableViewCell: UITableViewCell {

    static let reuseIdentifier = "SourceTableViewCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with source: Source) {
        textLabel?.text = source.title
        textLabel?.textColor = UIColor(red: 0.973, green: 0.6, blue: 0.114, alpha: 1)
        backgroundColor = UIColor(red: 0.455, green: 0.455, blue: 0.502, alpha: 0.18)
        let backView = UIView()
        backView.backgroundColor = UIColor(red: 1, green: 0.6, blue: 0, alpha: 1)
        selectedBackgroundView = backView
        applyMaskLayer()
    }

    func applyMaskLayer(_ withOffset: CGFloat = 0) {
        let maskLayer = CALayer()
        maskLayer.cornerRadius = 12
        maskLayer.backgroundColor = UIColor.white.cgColor
        maskLayer.frame = CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width + withOffset, height: bounds.height)
            .insetBy(dx: 16, dy: 0)
        layer.masksToBounds = true
        layer.mask = maskLayer
    }
}
```

### 5.5 `AmazonIVSPlayerSamples/Shared/UIView+Gradient.swift` — Rename only

File is `git mv`'d from `QuizDemo/QuizDemo/Custom/UIView.swift`. No content changes needed.

---

## Phase 6: Class Renames in git mv'd Files

These are find-and-replace operations inside the moved Swift files. Only the class/struct name and internal references change — no logic modifications.

### 6.1 `BasicPlaybackViewController.swift`

```
Find:    class ViewController:
Replace: class BasicPlaybackViewController:
```

Also change `viewWillAppear` → `viewDidAppear` for the stream load/play block (so it works correctly when pushed/popped on a nav stack):

```
Find:    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
Replace: override func viewDidAppear(_ animated: Bool) {
         super.viewDidAppear(animated)
```

### 6.2 `CustomUIViewController.swift`

```
Find:    class MainViewController: UIViewController, SourceSelectViewDelegate {
Replace: class CustomUIViewController: UIViewController, CustomUISourceViewDelegate {

Find:    var videoSourceEntities: [SourceEntity] = []
Replace: var sources: [Source] = []

Find:    let videoSourceEntitiesSaveKey: String = "sources_history_data"
Replace: let sourcesSaveKey: String = "customui_sources_history_data"
```

Then find/replace throughout the file:

| Find | Replace |
|---|---|
| `videoSourceEntities` | `sources` |
| `videoSourceEntitiesSaveKey` | `sourcesSaveKey` |
| `SourceEntity(` | `Source(` |
| `[SourceEntity]` | `[Source]` |
| `removeVideoSourceEntity(at:)` | `removeSource(at:)` |

### 6.3 `CustomUISourceViewController.swift`

```
Find:    protocol SourceSelectViewDelegate {
Replace: protocol CustomUISourceViewDelegate {

Find:    class SourceSelectViewController: UIViewController {
Replace: class CustomUISourceViewController: UIViewController {

Find:    var delegate: SourceSelectViewDelegate?
Replace: var delegate: CustomUISourceViewDelegate?
```

Then find/replace throughout the file:

| Find | Replace |
|---|---|
| `SourceSelectViewDelegate` | `CustomUISourceViewDelegate` |
| `videoSourceEntities` | `sources` |
| `[SourceEntity]` | `[Source]` |
| `removeVideoSourceEntity(at index: Int)` | `removeSource(at index: Int)` |
| `delegate?.removeVideoSourceEntity(at:` | `delegate?.removeSource(at:` |

Replace storyboard prototype cell usage with programmatic registration:

```swift
// In viewWillAppear, add:
predefinedUrlsTableView.register(SourceTableViewCell.self, forCellReuseIdentifier: SourceTableViewCell.reuseIdentifier)

// In cellForRowAt, replace the old dequeue with:
let cell = tableView.dequeueReusableCell(withIdentifier: SourceTableViewCell.reuseIdentifier, for: indexPath) as! SourceTableViewCell
cell.configure(with: delegate.sources[indexPath.section])
return cell
```

### 6.4 `QuizDemoSourceViewController.swift`

```
Find:    class SourceViewController: UIViewController {
Replace: class QuizDemoSourceViewController: UIViewController {
```

Then find/replace throughout the file:

| Find | Replace |
|---|---|
| `videoSourceEntities` | `sources` |
| `[SourceEntity]` | `[Source]` |
| `SourceEntity(` | `Source(` |
| `videoSourceEntitiesSaveKey` | `sourcesSaveKey` |
| `"sources_history_data"` | `"quiz_sources_history_data"` |

> **Note**: Keep `sourceEntitiesTableView` as-is — it's an `@IBOutlet` wired in the storyboard.

Also in `prepare(for:sender:)`:
```
Find:    segue.destination as? PlayerViewController
Replace: segue.destination as? QuizDemoViewController
```

Replace storyboard prototype cell usage with programmatic registration:

```swift
// In viewDidLoad, add:
sourceEntitiesTableView.register(SourceTableViewCell.self, forCellReuseIdentifier: SourceTableViewCell.reuseIdentifier)

// In cellForRowAt, replace the old dequeue with:
let cell = tableView.dequeueReusableCell(withIdentifier: SourceTableViewCell.reuseIdentifier, for: indexPath) as! SourceTableViewCell
cell.configure(with: sources[indexPath.section])
return cell
```

### 6.5 `QuizDemoViewController.swift`

```
Find:    class PlayerViewController: UIViewController {
Replace: class QuizDemoViewController: UIViewController {

Find:    let videoSourceEntitiesSaveKey: String = "sources_history_data"
Replace: let sourcesSaveKey: String = "quiz_sources_history_data"
```

### 6.6 Orientation Lock for QuizDemo

Add to both `QuizDemoSourceViewController` and `QuizDemoViewController`:

```swift
override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
```

---

## Phase 7: Storyboard Edits (Manual)

These are the `customClass` and `customModule` updates you'll do by hand in each storyboard XML.

### BasicPlayback.storyboard

| Find | Replace |
|---|---|
| `customClass="ViewController"` | `customClass="BasicPlaybackViewController"` |
| `customModule="BasicPlayback"` | `customModule="AmazonIVSPlayerSamples"` |

### CustomUI.storyboard

| Find | Replace |
|---|---|
| `customClass="MainViewController"` | `customClass="CustomUIViewController"` |
| `customClass="SourceSelectViewController"` | `customClass="CustomUISourceViewController"` |
| `customModule="CustomUI"` | `customModule="AmazonIVSPlayerSamples"` |

Also remove the `<tableViewCell ... reuseIdentifier="sourceUrlCell" ... customClass="SourceTableViewCell">` prototype block and its contents from the table view definition.

### QuizDemo.storyboard

| Find | Replace |
|---|---|
| `customClass="SourceViewController"` | `customClass="QuizDemoSourceViewController"` |
| `customClass="PlayerViewController"` | `customClass="QuizDemoViewController"` |
| `customModule="QuizDemo"` | `customModule="AmazonIVSPlayerSamples"` |

Also remove the `<tableViewCell ... reuseIdentifier="sourceEntityCell" ... customClass="SourceEntityCell">` prototype block and its contents from the table view definition.

---

## Phase 8: Info.plist

Single merged plist:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>UIBackgroundModes</key>
    <array>
        <string>audio</string>
    </array>
    <key>UILaunchStoryboardName</key>
    <string>LaunchScreen</string>
    <key>UIRequiredDeviceCapabilities</key>
    <array>
        <string>armv7</string>
    </array>
    <key>UIStatusBarStyle</key>
    <string>UIStatusBarStyleLightContent</string>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    <key>UISupportedInterfaceOrientations~ipad</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationPortraitUpsideDown</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
</dict>
</plist>
```

Note: No `UIMainStoryboardFile` — root VC is set up in `AppDelegate`.

---

## Phase 9: Workspace Update

Edit `AmazonIVSPlayerSamples.xcworkspace/contents.xcworkspacedata`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "group:AmazonIVSPlayerSamples/AmazonIVSPlayerSamples.xcodeproj">
   </FileRef>
</Workspace>
```

The `AmazonIVSPlayer` Swift Package is added as a dependency in the `.xcodeproj`, not as a workspace reference.

---

## Phase 10: Xcode Project Setup (Manual in Xcode)

1. Create new iOS App project `AmazonIVSPlayerSamples` inside the `AmazonIVSPlayerSamples/` directory, deployment target iOS 14.0.
2. Delete the auto-generated files Xcode creates (ViewController.swift, Main.storyboard, etc.) — we have our own.
3. Add all files from the directory structure to the target.
4. Add `AmazonIVSPlayer` local package dependency pointing to `../AmazonIVSPlayer`.
5. Set bundle identifier to `com.amazonaws.ivs.player.sample-app`.
6. Ensure "AmazonIVSPlayer" framework is linked in Build Phases → Link Binary With Libraries.

---

## Phase 11: README Update

```markdown
<a href="https://docs.aws.amazon.com/ivs/"><img align="right" width="128px" src="./ivs-logo.svg"></a>

# Amazon IVS Player iOS SDK Sample App

A single app demonstrating the Amazon IVS Player iOS SDK with three sample experiences:

- **Basic Playback**: Simple streaming with standard playback controls and Picture-in-Picture support.
- **Custom UI**: Custom player controls with blur overlay, source URL selection, and dark/light theme support.
- **Quiz Demo**: Interactive trivia game using timed metadata embedded in the stream.

## More Documentation

+ [Release Notes](https://docs.aws.amazon.com/ivs/latest/userguide/IVSPRN.html)
+ [iOS SDK Guide](https://docs.aws.amazon.com/ivs/latest/userguide/SIPAG.html)

## Setup

1. Clone the repository to your local machine.
2. Open `AmazonIVSPlayerSamples.xcworkspace`.
3. Build and run the `AmazonIVSPlayerSamples` target in the simulator.
4. Select a sample from the list to try it out.

## License

This project is licensed under the MIT-0 License. See the LICENSE file.
```

---

## Summary: Final File Tree

```
.
├── AmazonIVSPlayer/
│   └── Package.swift                              # Unchanged
├── AmazonIVSPlayerSamples/
│   ├── AmazonIVSPlayerSamples.xcodeproj/          # New (created in Xcode)
│   ├── AppDelegate.swift                           # Modified (programmatic root VC + orientation forwarding)
│   ├── SamplesViewController.swift                 # New
│   ├── Shared/
│   │   ├── Source.swift                            # git mv + rename SourceEntity → Source
│   │   ├── SourceTableViewCell.swift               # New
│   │   └── UIView+Gradient.swift                   # git mv (no changes)
│   ├── BasicPlayback/
│   │   ├── BasicPlaybackViewController.swift       # git mv + class rename + viewDidAppear fix
│   │   └── BasicPlayback.storyboard               # git mv + manual customClass/customModule edit
│   ├── CustomUI/
│   │   ├── CustomUIViewController.swift            # git mv + class rename + Source rename
│   │   ├── CustomUISourceViewController.swift      # git mv + class rename + delegate rename + cell swap
│   │   ├── UIColor+Hex.swift                       # git mv (no changes)
│   │   ├── CMTime+Positional.swift                 # git mv (no changes)
│   │   └── CustomUI.storyboard                    # git mv + manual customClass/customModule edit + remove prototype cell
│   ├── QuizDemo/
│   │   ├── QuizDemoViewController.swift            # git mv + class rename
│   │   ├── QuizDemoSourceViewController.swift      # git mv + class rename + Source rename + cell swap
│   │   ├── AnswerButton.swift                      # git mv (no changes)
│   │   ├── Question.swift                          # git mv (no changes)
│   │   └── QuizDemo.storyboard                    # git mv + manual customClass/customModule edit + remove prototype cell
│   ├── Assets.xcassets                             # git mv from CustomUI + QuizDemo color assets copied in
│   ├── LaunchScreen.storyboard                     # git mv (no changes)
│   └── Info.plist                                  # New (merged superset)
├── AmazonIVSPlayerSamples.xcworkspace/
│   └── contents.xcworkspacedata                    # Updated to reference new project only
├── README.md                                       # Updated
├── CONSOLIDATION_SPEC.md
├── CONSOLIDATION_DESIGN.md
├── LICENSE
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
├── .editorconfig
├── .gitignore
└── ivs-logo.svg
```
