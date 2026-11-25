# Android Device Runner

Run Android projects from ZCode: a side panel with devices, build, install, launch and logcat.

## What it does

**Side panel** (`ui.surfaces`)

- Device cards: model, serial, Android version, physical/emulator; click to switch the target device
- Emulators: lists AVDs and boots one, waiting until it is ready (up to 180s)
- App: package name, module/variant, APK size and build time
- Environment: live SDK / adb / JDK / Gradle detection results
- Actions: run (build → install → launch), build, install, launch, stop, restart, logcat, environment check, uninstall, clear data
- Console: streamed output of build/install/launch; a second tab streams logcat

**CLI** (`scripts/ar.js`, zero dependencies)

```bash
node scripts/ar.js doctor          # environment self-check
node scripts/ar.js devices         # devices and emulators
node scripts/ar.js use <serial>    # remember the target device
node scripts/ar.js run             # build → install → launch
node scripts/ar.js logcat          # logcat, filtered to the app process
```

`ar.js --help` lists every command.

## Zero-config detection

| Item | Detection order |
|---|---|
| Project root | find `gradlew` inside the current workspace (6 levels up / recursive down) |
| adb | `local.properties` → `ANDROID_HOME` → common SDK dirs → `PATH` |
| JDK | saved choice for this project → `org.gradle.java.home` → `.idea/gradle.xml` `gradleJvm` → `JAVA_HOME` → Android Studio JBR → system `java` → installed JDKs (picks one compatible with the Gradle version) |
| Flavor | `productFlavors` in the module build file; defaults to `official` (else the only flavor / `dev`) |
| Package name | `output-metadata.json` → module `build.gradle` `applicationId` |
| APK | newest artifact under `build/outputs/apk/<flavor>/<variant>/` (also reads AGP 3.x `output.json`) |

Anything undetected can be passed explicitly: `--module`, `--variant`, `--flavor`, `--apk`, `--package`, `--adb`, `--java-home`.

### JDK and flavors

- **The JDK must match the Gradle version.** The plugin reads `gradle-wrapper.properties` and `gradle.properties` (e.g. a legacy `-XX:MaxPermSize` only works on Java 8) and auto-picks a compatible JDK, preferring the one configured by the project.
- Pin one: `ar java <path or 17 / corretto-17>` (saved per project); `ar java --clear` restores auto; one-off with `--java-home` or `AR_JAVA_HOME`. The panel's environment section can switch it too.
- Multi-channel projects (`channel.txt` + `productFlavors`) default to the `official` **debug** variant — runs and builds stay on debug and never build every channel at once. Pass `--flavor <name>` for one specific channel (still debug only). With several flavors and no `official`, the plugin asks you to choose.

## Side effects and safety

- **Command execution**: runs the project's own `gradlew` and `adb` on the local machine. No network access of its own.
- **File writes**: may create `local.properties` when missing (contains `sdk.dir`); remembers device/project choices in `~/.android-runner/`.
- **Destructive**: on signature mismatch or version downgrade, install **uninstalls and reinstalls automatically**, wiping the app's local data. Opt out with `--no-reinstall`; `--reinstall` opts back in and wins over `--no-reinstall`. Before uninstalling it verifies the package actually installed on the device, so `applicationIdSuffix` builds are handled.
- `uninstall` / `clear-data` are destructive: the panel asks for confirmation, the CLI requires an explicit `--yes`.
- **Multiple devices**: with more than one online device and no target selected, the panel asks you to pick one and disables install/launch-style actions. `build` is unaffected and never needs a device.
- **MCP server**: a local stdio server (`scripts/mcp-server.mjs`) serving the panel and running the CLI. It binds no ports.

## Requirements

- ZCode Desktop with `ui.surfaces` support
- Node.js 18+ on `PATH` (starts the MCP server)
- Android SDK with `platform-tools/adb`
- A Gradle Wrapper (`gradlew`) in the project

## Structure

```
.zcode-plugin/plugin.json   # manifest: ui.surfaces + MCP server
assets/panel.html           # side panel UI
scripts/mcp-server.mjs      # MCP server: tools, resources, background jobs
scripts/ar.js               # CLI core: detection, devices, build, install, launch, logcat
scripts/project-info.js     # module / APK / package detection
skills/android-runner/      # skill instructions
commands/                   # /android-run, /android-doctor, /android-devices, /android-panel
```

## License

MIT. The detection and execution logic is ported from
[menggod/android-runner](https://github.com/menggod/android-runner); the original
`LICENSE` is kept in this directory.
