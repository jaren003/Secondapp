import SwiftUI

struct Pill: View {
    let text: String

    var body: some View {
        Text(text)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(
                Capsule()
                    .fill(Color.accentColor.opacity(0.2))
            )
            .accessibilityLabel(text)
    }
}

func sectionHeaderColor(for timing: PrepTiming) -> Color {
    switch timing {
    case .nightBefore:
        return .purple
    case .morningOf:
        return .yellow
    }
}

private let weekdayMonthDayFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE MMM d"
    return formatter
}()

extension Date {
    func weekdayMonthDay() -> String {
        weekdayMonthDayFormatter.string(from: self)
    }
}
