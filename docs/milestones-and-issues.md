# Milestones and Issues

This document outlines the project milestones and discrete issues for each.

Labels used: `type:feature`, `type:task`, `type:bug`, `area:camera`, `area:overlay`, `area:blend`, `area:vision`, `area:ux`, `area:infra`, `priority:p1`, `priority:p2`.

---

## Milestone 1 — Repo & Planning

1. Create repository scaffolding
   - Description: Add README, .gitignore, docs structure.
   - Acceptance: Files present; repo initializes clean.
   - Labels: type:task, area:infra, priority:p1

2. Define architecture outline
   - Description: Document modules: CameraController, OverlayView, ImageProcessor, SaveManager, ViewModel.
   - Acceptance: `docs/architecture.md` with responsibilities and data flow.
   - Labels: type:task, area:infra, priority:p1

3. Define UX wireframes
   - Description: Simple sketches/screens: Camera, Ghost, Review, Result.
   - Acceptance: `docs/wireframes.md` with 3–4 screens.
   - Labels: type:task, area:ux, priority:p2

---

## Milestone 2 — Xcode Project Setup

1. Initialize SwiftUI app project
   - Description: Create Xcode project with SwiftUI lifecycle; iOS 16+ target.
   - Acceptance: App builds and runs on simulator.
   - Labels: type:task, area:infra, priority:p1

2. Project configuration
   - Description: Bundle ID, signing set to automatic; enable camera/photos capabilities.
   - Acceptance: Targets configured; no build warnings.
   - Labels: type:task, area:infra, priority:p1

3. Info.plist usage descriptions
   - Description: Add `NSCameraUsageDescription`, `NSPhotoLibraryAddUsageDescription`.
   - Acceptance: Strings present; app prompts correctly.
   - Labels: type:task, area:infra, priority:p1

---

## Milestone 3 — Camera & Permissions

1. Camera permission flow
   - Description: Request and handle camera authorization states.
   - Acceptance: App handles authorized/denied states gracefully.
   - Labels: type:feature, area:camera, priority:p1

2. Live preview with AVFoundation
   - Description: `AVCaptureSession` + preview layer wrapped for SwiftUI.
   - Acceptance: 60fps preview on device; correct aspect fill.
   - Labels: type:feature, area:camera, priority:p1

3. Photo capture pipeline
   - Description: Capture full-res stills to `CVPixelBuffer`/`CIImage`.
   - Acceptance: Save raw buffers for processing; metadata retained.
   - Labels: type:feature, area:camera, priority:p1

---

## Milestone 4 — Ghost Overlay & Controls

1. Overlay rendering
   - Description: Render shot #1 at adjustable opacity over live preview.
   - Acceptance: 0–100% opacity slider; 50% default.
   - Labels: type:feature, area:overlay, priority:p1

2. Exposure/focus lock
   - Description: Lock AE/AF after shot #1 to reduce flicker.
   - Acceptance: Lock toggles; state persists until reset.
   - Labels: type:feature, area:camera, priority:p2

3. Gridlines & guides
   - Description: Optional thirds grid to assist alignment.
   - Acceptance: Toggle grid; no performance impact.
   - Labels: type:feature, area:ux, priority:p3

---

## Milestone 5 — Capture Flow & State

1. Two-shot state machine
   - Description: ViewModel orchestrates idle → shot1 → ghost → shot2 → review.
   - Acceptance: Deterministic transitions with cancel/retake support.
   - Labels: type:feature, area:ux, priority:p1

2. Retake controls
   - Description: Retake #1 or #2 without leaving the screen.
   - Acceptance: Buffers cleared; UI resets appropriately.
   - Labels: type:feature, area:ux, priority:p2

3. Orientation handling
   - Description: Normalize EXIF orientation for both shots.
   - Acceptance: Images upright regardless of device orientation.
   - Labels: type:task, area:camera, priority:p1

---

## Milestone 6 — Simple Blend (Core Image)

1. Alpha blend implementation
   - Description: Core Image pipeline to alpha-blend images with slider.
   - Acceptance: Real-time preview; export matches preview.
   - Labels: type:feature, area:blend, priority:p1

2. Tone/contrast helpers
   - Description: Optional curves or levels to enhance result.
   - Acceptance: Subtle presets; non-destructive.
   - Labels: type:feature, area:blend, priority:p3

---

## Milestone 7 — Smart Alignment (Vision)

1. Downscaled registration prototype
   - Description: Run `VNHomographicImageRegistrationRequest` (fallback translational) on 1280px copies.
   - Acceptance: Returns transform + confidence; logs metrics.
   - Labels: type:feature, area:vision, priority:p1

2. Warp and composite
   - Description: Apply transform using `CIPerspectiveTransform`/`CIAffineTransform`, then blend.
   - Acceptance: Visual improvement vs. simple blend on test pairs.
   - Labels: type:feature, area:blend, priority:p1

3. Full-res application
   - Description: Scale transform to full-res; reuse CIContext.
   - Acceptance: Exports at capture resolution; <2s on A15+.
   - Labels: type:task, area:vision, priority:p1

4. Failure handling & fallbacks
   - Description: Low-confidence fallback to translational/manual nudge.
   - Acceptance: UX message; never blocks save.
   - Labels: type:feature, area:vision, priority:p2

---

## Milestone 8 — Save & Share

1. Save to Photos
   - Description: Write final `CIImage` via `PHPhotoLibrary` with metadata.
   - Acceptance: Asset appears in Recents; error handling covered.
   - Labels: type:feature, area:ux, priority:p1

2. Share sheet
   - Description: System share sheet for the exported image.
   - Acceptance: Standard UIActivityViewController integration.
   - Labels: type:feature, area:ux, priority:p2

---

## Milestone 9 — Performance & Polish

1. Performance pass
   - Description: Reuse CIContext; measure memory/CPU; downscale where needed.
   - Acceptance: Smooth UI; no frame drops during preview.
   - Labels: type:task, area:blend, priority:p1

2. Visual polish
   - Description: Haptics, micro-animations, safe-area/layout tweaks.
   - Acceptance: Feels responsive and refined.
   - Labels: type:task, area:ux, priority:p2

3. Edge-aware mask (optional)
   - Description: Simple luminance/edge weighting to reduce highlight ghosting.
   - Acceptance: Subtle improvement on high-contrast scenes.
   - Labels: type:feature, area:blend, priority:p3

---

## Milestone 10 — Beta & Release

1. App icon, branding, copy
   - Description: App icon set, name, and store metadata draft.
   - Acceptance: Assets compiled; no missing icons.
   - Labels: type:task, area:ux, priority:p2

2. Test plan & sample set
   - Description: Curate diverse test pairs; document expected outcomes.
   - Acceptance: `docs/test-plan.md` with images and notes.
   - Labels: type:task, area:infra, priority:p2

3. TestFlight setup
   - Description: Signing, bundle IDs, App Store Connect config.
   - Acceptance: Build distributed to internal testers.
   - Labels: type:task, area:infra, priority:p2

---

## Backlog

- AR-based alignment experiment (ARKit anchors)
- RAW capture mode exploration
- Multi-exposure (3+ frames) UI
- Preset blends (multiply, screen, soft light)
- In-app gallery of results

---

## Creating GitHub Issues

Option A (GitHub UI): Create milestones with the titles above; add issues with titles/descriptions/acceptance from this file.

Option B (CLI): After logging in with `gh auth login` and pushing the repo, run `gh issue create` for each item. You can paste the bullet text as the body and apply labels.

> Tip: Use labels from the top of this file for consistency.
