import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var model = CameraViewModel()

    var body: some View {
        VStack(spacing: 0) {
            header
            content
        }
        .onAppear { model.onAppear() }
        .onDisappear { model.onDisappear() }
    }

    private var header: some View {
        HStack {
            Text("Double Exposure Camera").font(.headline)
            Spacer()
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
    }

    @ViewBuilder
    private var content: some View {
        switch model.authState {
        case .authorized:
            ZStack(alignment: .bottom) {
                CameraPreviewView(session: model.controller.session)
                    .ignoresSafeArea()

                controlsBar
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
            if let img = model.lastCapturedImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(.white.opacity(0.6), lineWidth: 1))
            }
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
        }
        .padding(.top, 12)
        .padding(.horizontal)
        .background(
            LinearGradient(gradient: Gradient(colors: [.black.opacity(0.0), .black.opacity(0.4)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

#Preview {
    ContentView()
}
