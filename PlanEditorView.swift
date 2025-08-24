import SwiftUI
import SwiftData

struct PlanEditorView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    private var plan: LunchPlan?
    @State private var date: Date
    @State private var main: String
    private var isNew: Bool

    init(plan: LunchPlan?) {
        self.plan = plan
        _date = State(initialValue: plan?.date ?? Date())
        _main = State(initialValue: plan?.main ?? "")
        self.isNew = plan == nil
    }

    var body: some View {
        Form {
            DatePicker("Date", selection: $date, displayedComponents: .date)
            TextField("Main Dish", text: $main)
        }
        .navigationTitle(isNew ? "New Plan" : "Edit Plan")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }
            }
        }
    }

    private func save() {
        if let plan {
            plan.date = date.startOfDay()
            plan.main = main
        } else {
            let newPlan = LunchPlan(date: date, main: main, sides: [])
            context.insert(newPlan)
        }
        try? context.save()
        dismiss()
    }
}

#Preview {
    NavigationStack {
        PlanEditorView(plan: nil)
    }
}
