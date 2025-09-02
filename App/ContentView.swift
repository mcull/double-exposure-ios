import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Double Exposure Camera")
                .font(.title2).bold()
            Text("Milestone 2: Project scaffolding ready.")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

