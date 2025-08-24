import SwiftUI
import SwiftData

struct HomeView: View {
    private let tomorrow: Date
    @Query private var plans: [LunchPlan]
    @State private var tonightCompleted: Set<UUID> = []
    @State private var morningCompleted: Set<UUID> = []

    init() {
        let t = Date().tomorrow()
        self.tomorrow = t
        _plans = Query(filter: #Predicate<LunchPlan> { $0.date == t.startOfDay() })
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if let plan = plans.first {
                    VStack(alignment: .leading, spacing: 24) {
                        summaryCard(for: plan)

                        let nightSteps = plan.steps.filter { $0.timing == .nightBefore }
                        let morningSteps = plan.steps.filter { $0.timing == .morningOf }

                        prepSection(title: "Prep Tonight", systemImage: "moon.stars", steps: nightSteps, done: $tonightCompleted)
                        prepSection(title: "Prep Morning", systemImage: "sun.max", steps: morningSteps, done: $morningCompleted)
                    }
                    .padding()
                } else {
                    VStack(spacing: 16) {
                        Text("No plan for \(tomorrow, style: .date) yet.")
                            .multilineTextAlignment(.center)
                        Button("Create Plan for Tomorrow") {
                            // Placeholder action
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
            }
            .navigationTitle("Tomorrow")
        }
    }

    @ViewBuilder
    private func summaryCard(for plan: LunchPlan) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(plan.date, style: .date)
                .font(.title2.bold())

            Label(plan.main, systemImage: "fork.knife")
                .font(.headline)

            if !plan.sides.isEmpty {
                HStack {
                    ForEach(plan.sides, id: \.self) { side in
                        Text(side)
                            .padding(8)
                            .background(Capsule().fill(Color.accentColor.opacity(0.2)))
                    }
                }
            }

            if let drink = plan.drink, !drink.isEmpty {
                Text("Drink: \(drink)")
            }

            if let notes = plan.notes, !notes.isEmpty {
                Text(notes)
                    .italic()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .systemBackground))
                .shadow(radius: 1)
        )
    }

    @ViewBuilder
    private func prepSection(title: String, systemImage: String, steps: [PrepStep], done: Binding<Set<UUID>>) -> some View {
        if !steps.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Label(title, systemImage: systemImage)
                    .font(.headline)
                ForEach(steps) { step in
                    Button {
                        if done.wrappedValue.contains(step.id) {
                            done.wrappedValue.remove(step.id)
                        } else {
                            done.wrappedValue.insert(step.id)
                        }
                    } label: {
                        HStack {
                            Image(systemName: done.wrappedValue.contains(step.id) ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(done.wrappedValue.contains(step.id) ? .accent : .secondary)
                            Text(step.text)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }
}

#Preview {
    do {
        let container = try ModelContainer(
            for: [LunchPlan.self, PrepStep.self],
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        SeedData.ensureSeed(container: container)
        return HomeView()
            .modelContainer(container)
    } catch {
        return Text("Preview error: \(error.localizedDescription)")
    }
}
