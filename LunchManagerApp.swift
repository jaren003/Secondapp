import SwiftUI
import SwiftData

@main
struct LunchManagerApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }

                AdminView()
                    .tabItem {
                        Label("Admin", systemImage: "wrench.and.screwdriver")
                    }

                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
            }
            .modelContainer(for: [])
        }
    }
}

