# Wireframes (Text Outline)

These wireframes outline screens and key controls. Visual sketches can be added later.

## Screen: Camera (Capture 1)
- Elements: Live preview, grid toggle, Capture 1 button (primary), settings.
- Behavior: Requests camera permission if needed.
- Haptics: Light on button press.

## Screen: Ghost Overlay (After Shot 1)
- Elements: Live preview + overlay of Shot 1 at 50% opacity, opacity slider, Capture 2 button, Retake 1, AE/AF lock toggle.
- Behavior: Overlay aligns to preview bounds; orientation consistent.
- Notes: Option to show thirds grid.

## Screen: Review & Blend
- Elements: Simple vs Smart toggle, blend intensity slider, Blend button, back to retake 2.
- Behavior: Simple = on-device alpha blend; Smart = run Vision registration then blend.
- Feedback: Progress indicator during Smart alignment.

## Screen: Result
- Elements: Final image preview, Save to Photos, Share, Start over.
- Behavior: Save via PhotoKit; share sheet for export.
- Error states: Save failure (retry), registration low confidence (fallback used).

