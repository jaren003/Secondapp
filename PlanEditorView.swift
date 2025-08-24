import SwiftUI
import SwiftData

struct PlanEditorView: View {
    var body: some View {
        Text("Plan Editor View Placeholder")
            .padding()
    }
}

#Preview {
    do {
        let container = try ModelContainer(
            for: [LunchPlan.self, PrepStep.self],
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        SeedData.ensureSeed(container: container)
        return PlanEditorView()
            .modelContainer(container)
    } catch {
        return Text("Preview error: \(error.localizedDescription)")
    }
}
