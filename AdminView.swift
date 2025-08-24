import SwiftUI
import SwiftData

struct AdminView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\LunchPlan.date, order: .reverse)]) private var plans: [LunchPlan]
    @State private var isAdding = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(plans) { plan in
                    NavigationLink {
                        PlanEditorView(plan: plan)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(plan.date, style: .date)
                                .font(.headline)
                            Text(plan.main)
                                .font(.subheadline)
                        }
                    }
                }
                .onDelete(perform: deletePlans)
            }
            .navigationTitle("Plans")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isAdding = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(isPresented: $isAdding) {
                PlanEditorView(plan: nil)
            }
        }
    }

    private func deletePlans(at offsets: IndexSet) {
        for index in offsets {
            let plan = plans[index]
            context.delete(plan)
        }
        try? context.save()
    }
}

#Preview {
    AdminView()
}
