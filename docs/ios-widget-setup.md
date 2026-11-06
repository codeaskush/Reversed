# iOS widget setup (one-time, in Xcode)

Flutter generates the iOS app project but cannot create a WidgetKit extension
target. The Swift sources are already in `ios/ReversedWidget/`; you only need
to create the target and attach them.

## 1. Create the extension target

1. `open ios/Runner.xcworkspace` (run `flutter pub get` first so the
   workspace exists; if `Pods` is missing run `cd ios && pod install`).
2. **File → New → Target… → Widget Extension**.
3. Product name: **`ReversedWidget`** (must match `AppConstants.iosWidgetName`).
   Leave *Include Configuration App Intent* **unchecked**. Finish, and choose
   **Activate** when asked about the scheme.
4. Xcode created a `ReversedWidget` folder with template files. Delete the
   template `ReversedWidget.swift`, `ReversedWidgetBundle.swift` and
   `Info.plist` **from the target**, then drag the files from the repo's
   `ios/ReversedWidget/` folder into the group (uncheck *Copy items* so the
   repo files are used):
   - `ReversedWidget.swift`
   - `ReversedWidgetBundle.swift`
   - `Info.plist`
   - `ReversedWidget.entitlements`
5. In the target's **Build Settings**, set
   `Info.plist File` = `ReversedWidget/Info.plist` and
   `Code Signing Entitlements` = `ReversedWidget/ReversedWidget.entitlements`.
   Set the **iOS Deployment Target** to 14.0 or higher (17.0 recommended).

## 2. App Group (shared storage)

The app and the widget share data through the App Group
`group.com.codeaskush.reversed`.

1. Select the **Runner** target → *Signing & Capabilities* → **+ Capability →
   App Groups** → add `group.com.codeaskush.reversed`. (The entitlements file
   `ios/Runner/Runner.entitlements` already lists it; Xcode will register it
   with your team.)
2. Repeat for the **ReversedWidget** target.

If you use a different bundle id / team, change the group id in **three**
places: `lib/core/constants.dart`, `ios/ReversedWidget/ReversedWidget.swift`,
and both `.entitlements` files.

## 3. Shuffle button (iOS 17 interactive widget)

`ios/Runner/BackgroundIntent.swift` is already a member of the Runner target.
It must also be a member of the widget target:

1. Select `BackgroundIntent.swift` in the navigator.
2. In the File inspector, under **Target Membership**, tick **ReversedWidget**.

Then enable the widget target in `ios/Podfile` by uncommenting the
`target 'ReversedWidget'` block and run `cd ios && pod install`.

## 4. Build

```bash
flutter run -d <your iPhone or simulator>
```

Add the widget: long-press the home screen → **+** → search *Reversed*.

## Troubleshooting

- **Widget shows the placeholder text** – open the app once; it writes the
  schedule into the App Group. Check both targets have the same App Group.
- **Shuffle does nothing** – confirm `BackgroundIntent.swift` is in both
  targets and the widget target links `home_widget` via the Podfile block.
- **`No such module 'home_widget'` in the extension** – the Podfile block
  for `ReversedWidget` is still commented out, or `pod install` wasn't rerun.
