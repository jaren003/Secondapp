import SwiftUI

// Capsule-style pill view for displaying side items
struct Pill: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Color.gray.opacity(0.2))
            )
    }
}

// Returns a color for section headers based on the prep timing
func sectionHeaderColor(for timing: PrepTiming) -> Color {
    switch timing {
    case .nightBefore:
        return .purple
    case .morningOf:
        return .yellow
    }
}

// Date formatting helper
extension Date {
    /// Formats date like "Tue, Jul 16"
    var weekdayMonthDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: self)
    }
}

