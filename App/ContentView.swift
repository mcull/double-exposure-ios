import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var model = CameraViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            content
        }
        .safeAreaInset(edge: .top) { header }
        .safeAreaInset(edge: .bottom) { controlsBar }
        .onAppear { model.onAppear() }
        .onDisappear { model.onDisappear() }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Text("Double Exposure Camera").font(.headline)
            Spacer()
            // Simple orientation indicator relative to Shot 1
            if let initial = model.initialDeviceOrientation, model.stage == .ghosting {
                HStack(spacing: 6) {
                    Image(systemName: "viewfinder")
                    Text(initial.label)
                    Text("→")
                    Text(model.currentDeviceOrientation.label)
                }
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial, in: Capsule())
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
    }

    @ViewBuilder
    private var content: some View {
        switch model.authState {
        case .authorized:
            ZStack {
                CameraPreviewView(session: model.controller.session)
                    .ignoresSafeArea()

                // Gridlines
                if model.showGrid { gridOverlay.ignoresSafeArea() }

                // Ghost overlay
                if let ghost = model.ghostImage {
                    Image(uiImage: ghost)
                        .resizable()
                        .scaledToFill()
                        .opacity(model.overlayOpacity)
                        .ignoresSafeArea()
                        .accessibilityLabel("Ghost overlay")
                }
            }
        case .unknown:
            VStack(spacing: 16) {
                Text("Camera permission needed").font(.title3).bold()
                Text("We use the camera to capture your two shots.")
                    .foregroundStyle(.secondary)
                Button("Allow Camera Access") {
                    Task { await model.requestAuthorization() }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        case .denied:
            VStack(spacing: 12) {
                Text("Camera access denied").font(.title3).bold()
                Text("Enable camera in Settings → Privacy → Camera, then relaunch.")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }

    private var controlsBar: some View {
        VStack(spacing: 12) {
            topControls
            HStack {
                Spacer()
                Button(action: { model.capture() }) {
                    Circle()
                        .fill(.white)
                        .frame(width: 72, height: 72)
                        .overlay(Circle().stroke(Color.black.opacity(0.15), lineWidth: 2))
                        .shadow(radius: 2)
                }
                Spacer()
            }
            .padding(.bottom, 24)
            if model.ghostImage != nil && model.shot2Image != nil {
                Button(action: { model.blendSimple() }) {
                    Text("Blend")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(.top, 12)
        .padding(.horizontal)
        .background(
            LinearGradient(gradient: Gradient(colors: [.black.opacity(0.0), .black.opacity(0.4)]), startPoint: .top, endPoint: .bottom)
        )
        .sheet(isPresented: $model.showingBlendPreview) {
            BlendPreviewView(image: model.blendedImage, onDismiss: {
                model.showingBlendPreview = false
            })
        }
    }

    private var topControls: some View {
        VStack(spacing: 10) {
            HStack {
                if let img = model.ghostImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 56, height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(.white.opacity(0.6), lineWidth: 1))
                        .accessibilityLabel("Ghost thumbnail")
                }
                Spacer()
                Toggle("AE/AF Lock", isOn: Binding(get: { model.isLockedAEAF }, set: { _ in model.toggleAEAF() }))
                    .toggleStyle(.switch)
                    .labelsHidden()
                    .tint(.orange)
                Button(action: { model.showGrid.toggle() }) {
                    Image(systemName: model.showGrid ? "grid.circle.fill" : "grid.circle")
                        .font(.title2)
                        .foregroundStyle(.white)
                }
            }

            if model.ghostImage != nil {
                HStack {
                    Image(systemName: "circle.lefthalf.filled").foregroundStyle(.white.opacity(0.8))
                    Slider(value: $model.overlayOpacity, in: 0...1)
                    Image(systemName: "circle.righthalf.filled").foregroundStyle(.white.opacity(0.8))
                }
            }

            HStack {
                if model.ghostImage != nil {
                    Button("Retake 1") { model.resetGhost() }
                        .buttonStyle(.bordered)
                        .tint(.white.opacity(0.8))
                }
                Spacer()
                Text(model.stage == .idle ? "Capture 1" : "Capture 2")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
            }
        }
    }

    private var gridOverlay: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            Path { p in
                // Vertical thirds
                p.move(to: CGPoint(x: w/3, y: 0)); p.addLine(to: CGPoint(x: w/3, y: h))
                p.move(to: CGPoint(x: 2*w/3, y: 0)); p.addLine(to: CGPoint(x: 2*w/3, y: h))
                // Horizontal thirds
                p.move(to: CGPoint(x: 0, y: h/3)); p.addLine(to: CGPoint(x: w, y: h/3))
                p.move(to: CGPoint(x: 0, y: 2*h/3)); p.addLine(to: CGPoint(x: w, y: 2*h/3))
            }
            .stroke(Color.white.opacity(0.35), lineWidth: 0.6)
        }
    }
}

private struct BlendPreviewView: View {
    let image: UIImage?
    var onDismiss: () -> Void
    @State private var showShare = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                if let img = image {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                        .padding()
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Blend Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", action: onDismiss)
                }
                ToolbarItemGroup(placement: .confirmationAction) {
                    if let img = image {
                        Button("Share") { showShare = true }
                        Button("Save") { save(img) }
                    }
                }
            }
        }
        .sheet(isPresented: $showShare) {
            if let img = image { ShareSheet(activityItems: [img]) }
        }
        .alert("Save", isPresented: $showAlert, actions: {
            Button("OK", role: .cancel) {}
        }, message: {
            Text(alertMessage)
        })
    }

    private func save(_ img: UIImage) {
        SaveManager.saveToPhotos(image: img) { result in
            switch result {
            case .success:
                alertMessage = "Saved to Photos"
            case .failure(let error):
                alertMessage = error.localizedDescription
            }
            showAlert = true
        }
    }
}

#Preview {
    ContentView()
}
