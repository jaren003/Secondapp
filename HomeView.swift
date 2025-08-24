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

                        prepSection(timing: .nightBefore, title: "Prep Tonight", systemImage: "moon.stars", steps: nightSteps, done: $tonightCompleted)
                        prepSection(timing: .morningOf, title: "Prep Morning", systemImage: "sun.max", steps: morningSteps, done: $morningCompleted)
                    }
                    .padding()
                } else {
                    VStack(spacing: 16) {
                        Text("No plan for \(tomorrow.weekdayMonthDay()) yet.")
                            .multilineTextAlignment(.center)
                        Button("Create Plan for Tomorrow") {
                            // Placeholder action
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
            }
            .navigationTitle(tomorrow.weekdayMonthDay())
        }
    }

    @ViewBuilder
    private func summaryCard(for plan: LunchPlan) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(plan.date.weekdayMonthDay())
                .font(.title2.bold())

            Label(plan.main, systemImage: "fork.knife")
                .font(.headline)
                .accessibilityLabel("Main: \(plan.main)")

            if !plan.sides.isEmpty {
                HStack {
                    ForEach(plan.sides, id: \.self) { side in
                        Pill(text: side)
                    }
                }
                .accessibilityLabel("Sides: \(plan.sides.joined(separator: ", "))")
            }

            if let drink = plan.drink, !drink.isEmpty {
                Text("Drink: \(drink)")
                    .accessibilityLabel("Drink: \(drink)")
            }

            if let notes = plan.notes, !notes.isEmpty {
                Text(notes)
                    .italic()
                    .accessibilityLabel("Notes: \(notes)")
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            #if os(iOS)
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
            #elseif os(macOS)
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(nsColor: .windowBackgroundColor))
            #endif
        )
        .shadow(radius: 1)
    }

    @ViewBuilder
    private func prepSection(timing: PrepTiming, title: String, systemImage: String, steps: [PrepStep], done: Binding<Set<UUID>>) -> some View {
        if !steps.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Label(title, systemImage: systemImage)
                    .font(.headline)
                    .foregroundStyle(sectionHeaderColor(for: timing))
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
                    .accessibilityLabel(done.wrappedValue.contains(step.id) ? "Mark \(step.text) incomplete" : "Mark \(step.text) complete")
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                #if os(iOS)
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                #elseif os(macOS)
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(nsColor: .windowBackgroundColor))
                #endif
            )
            .shadow(radius: 1)
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: [LunchPlan.self, PrepStep.self],
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    SeedData.ensureSeed(container: container)
    return HomeView()
        .modelContainer(container)
}
