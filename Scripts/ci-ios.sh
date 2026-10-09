#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p .ci
common=(-project Monederito-iOS.xcodeproj -scheme Monederito-Mock -derivedDataPath .ci/DerivedData -clonedSourcePackagesDirPath .ci/SourcePackages -onlyUsePackageVersionsFromResolvedFile)
xcodebuild "${common[@]}" -resolvePackageDependencies
# Select an installed iPhone simulator rather than relying on a device name.
xcrun simctl list devices available --json > .ci/devices.json
device_id=$(python3 - <<'PY'
import json
with open('.ci/devices.json') as f:
    devices = json.load(f)['devices']
for runtime in sorted(devices, reverse=True):
    if 'iOS' not in runtime:
        continue
    phones = [d for d in devices[runtime] if d['isAvailable'] and d['name'].startswith('iPhone')]
    if phones:
        print(phones[0]['udid'])
        break
else:
    raise SystemExit('No available iPhone simulator on this runner')
PY
)
xcodebuild "${common[@]}" -configuration Debug -destination "platform=iOS Simulator,id=$device_id" -resultBundlePath .ci/MockTests.xcresult test CODE_SIGNING_ALLOWED=NO
for configuration in Release SandboxDebug SandboxRelease; do
    xcodebuild "${common[@]}" -configuration "$configuration" -destination 'generic/platform=iOS Simulator' build CODE_SIGNING_ALLOWED=NO
 done
# Refuse an unintentional lockfile update.
git diff --exit-code -- Monederito-iOS.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved
