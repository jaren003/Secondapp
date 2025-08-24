import SwiftUI
import SwiftData

struct PlanEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @Bindable var plan: LunchPlan
    @State private var sidesText: String

    init(plan: LunchPlan) {
        self._plan = Bindable(wrappedValue: plan)
        _sidesText = State(initialValue: plan.sides.joined(separator: ", "))
    }

    init(date: Date = .now) {
        let newPlan = LunchPlan(date: date, main: "", sides: [])
        self._plan = Bindable(wrappedValue: newPlan)
        _sidesText = State(initialValue: "")
    }

    private var parsedSides: [String] {
        sidesText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private var nightStepIndices: [Int] {
        plan.steps.enumerated().compactMap { index, step in
            step.timing == .nightBefore ? index : nil
        }
    }

    private var morningStepIndices: [Int] {
        plan.steps.enumerated().compactMap { index, step in
            step.timing == .morningOf ? index : nil
        }
    }

    var body: some View {
        List {
            Section("Details") {
                DatePicker("Date", selection: $plan.date, displayedComponents: .date)
                TextField("Main", text: $plan.main)
                TextField("Drink", text: Binding(
                    get: { plan.drink ?? "" },
                    set: { plan.drink = $0.isEmpty ? nil : $0 }
                ))
                VStack(alignment: .leading) {
                    TextField("Sides", text: $sidesText)
                    if !parsedSides.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(parsedSides, id: \.self) { side in
                                    Text(side)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(
                                            Capsule()
                                                .fill(Color.gray.opacity(0.2))
                                        )
                                }
                            }
                        }
                    }
                }
                VStack(alignment: .leading) {
                    TextEditor(text: Binding(
                        get: { plan.notes ?? "" },
                        set: { plan.notes = $0.isEmpty ? nil : $0 }
                    ))
                    .frame(minHeight: 100, alignment: .top)
                }
            }

            Section("Prep Tonight") {
                ForEach(nightStepIndices, id: \.self) { index in
                    TextField("Step", text: $plan.steps[index].text)
                }
                .onDelete { offsets in
                    deleteSteps(offsets, timing: .nightBefore)
                }
                Button("Add step") {
                    addStep(timing: .nightBefore)
                }
            }

            Section("Prep Morning") {
                ForEach(morningStepIndices, id: \.self) { index in
                    TextField("Step", text: $plan.steps[index].text)
                }
                .onDelete { offsets in
                    deleteSteps(offsets, timing: .morningOf)
                }
                Button("Add step") {
                    addStep(timing: .morningOf)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }
                    .disabled(plan.main.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    private func addStep(timing: PrepTiming) {
        let step = PrepStep(text: "", timing: timing, plan: plan)
        plan.steps.append(step)
    }

    private func deleteSteps(_ offsets: IndexSet, timing: PrepTiming) {
        let indices = timing == .nightBefore ? nightStepIndices : morningStepIndices
        let realOffsets = IndexSet(offsets.map { indices[$0] })
        plan.steps.remove(atOffsets: realOffsets)
    }

    private func save() {
        plan.date = plan.date.startOfDay()
        plan.sides = parsedSides
        if let drink = plan.drink, drink.isEmpty { plan.drink = nil }
        if let notes = plan.notes, notes.isEmpty { plan.notes = nil }
        for index in plan.steps.indices {
            plan.steps[index].plan = plan
        }
        if plan.modelContext == nil {
            context.insert(plan)
        }
        try? context.save()
        dismiss()
    }
}

#Preview {
    PlanEditorView(plan: LunchPlan(date: .now, main: "Sample", sides: ["Chips"]))
        .modelContainer(for: [LunchPlan.self, PrepStep.self], inMemory: true)
}
