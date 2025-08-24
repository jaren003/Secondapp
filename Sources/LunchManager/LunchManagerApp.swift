import SwiftUI
import SwiftData

@main
struct LunchManagerApp: App {
    @AppStorage("hasSeeded") private var hasSeeded = false

    private var sharedModelContainer: ModelContainer = {
        let container = try! ModelContainer(for: [LunchPlan.self, PrepStep.self])
        return container
    }()

    init() {
        if !hasSeeded {
            SeedData.ensureSeed(container: sharedModelContainer)
            hasSeeded = true
        }
    }

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
        }
        .modelContainer(sharedModelContainer)
    }
}

