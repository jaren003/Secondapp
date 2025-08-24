import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \LunchPlan.date, order: .forward, limit: 1)
    private var plans: [LunchPlan]

    var body: some View {
        if let plan = plans.first {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(plan.date.weekdayMonthDay)
                        .font(.title2)
                        .bold()
                        .accessibilityLabel("Lunch plan for \(plan.date.weekdayMonthDay)")

                    VStack(alignment: .leading, spacing: 8) {
                        Text(plan.main)
                            .font(.headline)

                        if !plan.sides.isEmpty {
                            HStack {
                                ForEach(plan.sides, id: \.self) { side in
                                    Pill(text: side)
                                }
                            }
                        }

                        if let drink = plan.drink {
                            Text("Drink: \(drink)")
                                .font(.subheadline)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                    )
                    .shadow(radius: 2)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Main \(plan.main), sides \(plan.sides.joined(separator: ", ")), drink \(plan.drink ?? \"None\")")

                    ForEach(PrepTiming.allCases, id: \.self) { timing in
                        let steps = plan.steps.filter { $0.timing == timing }
                        if !steps.isEmpty {
                            Section {
                                ForEach(steps, id: \.id) { step in
                                    Text(step.text)
                                        .padding(.vertical, 4)
                                }
                            } header: {
                                Text(timing.label)
                                    .font(.headline)
                                    .foregroundColor(sectionHeaderColor(for: timing))
                            }
                        }
                    }

                    Spacer()
                }
                .padding()
            }
        } else {
            Text("No plan available")
                .padding()
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [LunchPlan.self, PrepStep.self], inMemory: true)
}

