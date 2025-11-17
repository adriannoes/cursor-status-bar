import SwiftUI

@main
struct CursorStatsApp: App {
    var body: some Scene {
        MenuBarExtra("Cursor Stats", systemImage: "chart.bar.fill") {
            MenuBarView()
        }
        .menuBarExtraStyle(.window)
    }
}

