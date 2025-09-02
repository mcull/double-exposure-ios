# Xcode Setup

This repo uses XcodeGen to generate the Xcode project.

## Steps
- Install XcodeGen: `brew install xcodegen`
- Generate the project: `make gen`
- Open the project: `make open`
- In Xcode, set your Team under Signing & Capabilities (Automatic signing).

## Notes
- Target: iOS 16.0+
- Usage descriptions are in `App/Info.plist` (Camera, Photo Library Add).
- Bundle identifier is `com.example.DoubleExposureCamera` — update as needed.

