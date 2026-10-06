# Changes in this build

## Desktop
- main.dart: window for 1367-1920px screens is now 1280x800 (min 1200x700) so the permanent sidebar layout is used.
- Sidebar (sidebar.dart, tab_sidebar.dart): added Income List, Income Head, Sale Mode; "Translation" label -> "Transactions".
- installer_script.nsi: version 1.1.2, fixed install folder, closes running app, cleans old 1.0.3 install, launches app non-elevated.
- windows/runner/Runner.rc: company/copyright = Meherin Software.
- macos Release.entitlements: added network.client (sandboxed release could not reach the API).
- AutoTimerService is cancelled on logout (LocalDB.delLoginInfo).

## Mobile
- mobile_root.dart: bottom nav respects permissions (greyed out when not allowed).
- main.dart: phones (shortest side < 600dp) locked to portrait.
- mobile_create_sales_pos.dart: removed print of the auth token.
- get_response.dart: session-expired toast title was "Success!".
- iOS Info.plist: camera + photo library usage descriptions.
- AndroidManifest.xml: removed duplicate INTERNET, added CAMERA (+ uses-feature required=false).
- MainActivity.kt moved to kotlin/com/meherin/meherinMart/.

## Bundle / app id (all platforms) = com.meherin.meherinMart
- ios and macos project.pbxproj, macos AppInfo.xcconfig (RunnerTests = ...meherinMart.RunnerTests).

## NOT changed (needs your decision)
- LocalDB (shared_preferences) stores email, PASSWORD and token in plain text; used by every API call.
- .env is bundled as an asset (readable from the APK/IPA/install folder).
- usesCleartextTraffic=true / iOS NSAllowsArbitraryLoads=true.
- Undisposed controllers in mobile_create_sales_pos / mobile_create_purchase_screen / bad stock / expense create / supplier payment create.
- Mobile dashboard profile icon pushes a second MobileRootScreen.
- 14 fully commented-out files; ~60 print() calls.
- iOS CFBundleDisplayName "Smart Inventory" vs Android label "Meherin Mart".
