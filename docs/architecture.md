# Architecture Overview

This document outlines the high-level architecture and responsibilities.

## Modules

- CameraController (AVFoundation)
  - Manages `AVCaptureSession`, inputs/outputs, photo capture.
  - Handles permissions, focus/exposure lock, orientation.

- CameraPreviewView (UIKit/SwiftUI wrapper)
  - Wraps `AVCaptureVideoPreviewLayer` for SwiftUI.
  - Configures aspect fill and layout.

- OverlayView (SwiftUI)
  - Renders ghost image (shot #1) above live preview with adjustable opacity.
  - Optional gridlines/guides.

- ImageProcessor (Core Image + Vision)
  - Simple blend: alpha blend with adjustable intensity.
  - Smart alignment: Vision registration (homography/translational) on downscaled images; apply transform at full-res with Core Image warp; blend.
  - Reuses a shared `CIContext` for performance.

- SaveManager (Photos/PhotoKit)
  - Writes final `CIImage` to Photos with metadata.
  - Handles Photos permission edge cases.

- AppViewModel (State & Flow)
  - Orchestrates UI states: idle → shot1 → ghost → shot2 → review/result.
  - Manages buffers, transforms, progress/error states.

## Data Flow

1. Live preview starts after camera permission.
2. Capture #1 → store buffer/CIImage → show ghost overlay.
3. Capture #2 → process:
   - Simple: alpha blend.
   - Smart: Vision registration → transform → warp → blend.
4. Render preview → export full-res → save/share.

## Performance Notes

- Downscale for registration (e.g., ~1280px width), then apply transform at full-res.
- Reuse `CIContext`; avoid converting to `UIImage` until export.
- Run heavy processing off the main thread; show lightweight progress HUD.

## Error Handling

- Permission denied: show friendly call-to-action to enable in Settings.
- Registration low confidence: fall back to translational/manual nudge.
- Save errors: present retry and export-to-Files fallback.

