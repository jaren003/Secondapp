import SwiftUI
import SwiftData

struct SettingsView: View {
    @AppStorage("showTomorrowOnLaunch") private var showTomorrowOnLaunch = true
    @Query private var plans: [LunchPlan]

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        return build.isEmpty ? version : "\(version) (\(build))"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("General") {
                    Toggle("Show Tomorrow on Launch", isOn: $showTomorrowOnLaunch)
                }

                Section("Data") {
                    HStack {
                        Text("Total Lunch Plans")
                        Spacer()
                        Text("\(plans.count)")
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    EmptyView()
                } footer: {
                    Text("Version \(appVersion)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
