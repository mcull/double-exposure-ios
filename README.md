# Double Exposure Camera (iOS)

Native iOS app to capture two photos, align the second shot to the first using on-device registration, and blend them into a beautiful double exposure. Includes a live "ghost" overlay to line up the second shot.

## Key Features
- Live camera preview with ghost overlay (adjustable opacity)
- Two-shot flow: Capture 1 → ghost overlay → Capture 2
- Simple blend (on-device alpha blend via Core Image)
- Smart blend (on-device: Vision registration + Core Image warp + blend)
- Save to Photos and share

## Stack
- UI: SwiftUI
- Camera: AVFoundation
- Alignment: Vision (homography/translational registration)
- Compositing: Core Image (optional Metal for performance)
- Photos: Photos/PhotoKit

## Status
Planning and setup. See `docs/milestones-and-issues.md` for the full roadmap.

## Local Setup (later)
When ready to code:
- Open the Xcode project (`.xcodeproj`/`.xcworkspace`) once added.
- Ensure camera/photo usage descriptions are present in `Info.plist`.

## Roadmap
See `docs/milestones-and-issues.md` for milestones, issue breakdown, and acceptance criteria.

