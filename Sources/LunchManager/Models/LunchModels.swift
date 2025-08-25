import Foundation
import SwiftData

enum PrepTiming: String, Codable, CaseIterable {
    case nightBefore
    case morningOf

    var label: String {
        switch self {
        case .nightBefore:
            return "Night Before"
        case .morningOf:
            return "Morning Of"
        }
    }
}

@Model
final class LunchPlan {
    @Attribute(.unique) var id: UUID
    var date: Date
    var main: String
    var sides: [String]
    var drink: String?
    var notes: String?
    @Relationship(deleteRule: .cascade, inverse: \PrepStep.plan) var steps: [PrepStep]

    init(
        id: UUID = UUID(),
        date: Date,
        main: String,
        sides: [String],
        drink: String? = nil,
        notes: String? = nil,
        steps: [PrepStep] = []
    ) {
        self.id = id
        self.date = date.startOfDay()
        self.main = main
        self.sides = sides
        self.drink = drink
        self.notes = notes
        self.steps = steps
    }
}

@Model
final class PrepStep {
    @Attribute(.unique) var id: UUID
    var text: String
    var timing: PrepTiming
    @Relationship(inverse: \LunchPlan.steps) var plan: LunchPlan?

    init(
        id: UUID = UUID(),
        text: String,
        timing: PrepTiming,
        plan: LunchPlan? = nil
    ) {
        self.id = id
        self.text = text
        self.timing = timing
        self.plan = plan
    }
}

extension Date {
    func startOfDay() -> Date {
        Calendar.current.startOfDay(for: self)
    }

    func tomorrow() -> Date {
        Calendar.current.date(byAdding: .day, value: 1, to: startOfDay())!
    }

    var yyyyMMddString: String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = Calendar.current.timeZone
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: self)
    }
}

enum SeedData {
    static func ensureSeed(container: ModelContainer) {
        let context = ModelContext(container)

        let fetch = FetchDescriptor<LunchPlan>()
        do {
            let plans = try context.fetch(fetch)
            if plans.isEmpty {
                let tomorrow = Date().tomorrow()
                let plan = LunchPlan(
                    date: tomorrow,
                    main: "Sandwich",
                    sides: ["Chips", "Fruit"],
                    drink: "Water",
                    notes: "Pack utensils"
                )

                let step1 = PrepStep(text: "Prepare ingredients", timing: .nightBefore, plan: plan)
                let step2 = PrepStep(text: "Assemble sandwich", timing: .morningOf, plan: plan)
                let step3 = PrepStep(text: "Pack lunch bag", timing: .morningOf, plan: plan)

                plan.steps = [step1, step2, step3]

                context.insert(plan)
                do {
                    try context.save()
                } catch {
                    print("Failed to seed data: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Failed to fetch lunch plans for seeding: \(error.localizedDescription)")
        }
    }
}

