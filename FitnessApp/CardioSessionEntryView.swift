import SwiftUI
import SwiftData

struct CardioSessionEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var activity: CardioActivity = .walk
    @State private var customName = ""
    @State private var distance = ""
    @State private var hours = 0
    @State private var minutes = 0
    @State private var seconds = 0
    @State private var showsSaveError = false

    private var duration: Int? {
        CardioInputRules.durationSeconds(hours: hours, minutes: minutes, seconds: seconds)
    }

    private var name: String? {
        CardioInputRules.activityName(activity, customName: customName)
    }

    private var miles: Double? {
        CardioInputRules.distanceMiles(distance)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    CardioEntryHeader()
                    CardioEntryCard(title: "Activity", symbol: "figure.walk") {
                        Picker("Type", selection: $activity) {
                            ForEach(CardioActivity.allCases) { activity in
                                Text(LocalizedStringKey(activity.rawValue)).tag(activity)
                            }
                        }
                        .pickerStyle(.menu)
                        if activity == .other {
                            TextField("Activity name", text: $customName, prompt: Text("Activity name").foregroundStyle(Color("BackgroundColor").opacity(0.65)))
                                .textInputAutocapitalization(.words)
                                .textFieldStyle(.plain)
                                .foregroundStyle(Color("BackgroundColor"))
                                .padding(12)
                                .background(Color("BackgroundColor").opacity(0.06),
                                            in: RoundedRectangle(cornerRadius: 10))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color("BackgroundColor").opacity(0.2), lineWidth: 1)
                                }

                        }
                    }
                    CardioDurationSection(hours: $hours, minutes: $minutes, seconds: $seconds)
                    CardioEntryCard(title: "Distance", symbol: "point.topleft.down.to.point.bottomright.curvepath") {
                        HStack {
                            Text("Miles")
                                .font(.headline)
                            TextField("Distance", text: $distance, prompt: Text("Optional").foregroundStyle(Color("BackgroundColor").opacity(0.65)))
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .textFieldStyle(.plain)
                                .foregroundStyle(Color("BackgroundColor"))
                                .padding(12)
                                .background(Color("BackgroundColor").opacity(0.06),
                                            in: RoundedRectangle(cornerRadius: 10))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color("BackgroundColor").opacity(0.2), lineWidth: 1)
                                }
                                .accessibilityLabel("Distance in miles")
                        }

                    }
                    VStack(spacing: 12) {
                        Button("Save Cardio", action: save)
                            .buttonStyle(.fitnessPrimary())
                            .disabled(duration == nil || miles == nil || name == nil)
                            .opacity(duration == nil || miles == nil || name == nil ? 0.45 : 1)
                        Button("Cancel") { dismiss() }
                            .buttonStyle(FitnessSecondaryButtonStyle())
                    }
                }
                .padding(20)
            }
            .background(Color("BackgroundColor").ignoresSafeArea())
            .scrollDismissesKeyboard(.interactively)
            .navigationBarTitleDisplayMode(.inline)
            .alert("Couldn’t save cardio", isPresented: $showsSaveError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your entry is still here. Please try saving again.")
            }
        }
    }

    private func save() {
        guard let duration, let miles, let name else { return }
        let session = CardioSession(name: name, distance: miles, durationSeconds: duration)
        modelContext.insert(session)
        do {
            try modelContext.save()
            dismiss()
        } catch {
            // Remove only this failed insertion, preserving unrelated pending changes.
            modelContext.delete(session)
            showsSaveError = true
        }
    }
}

private struct CardioDurationSection: View {
    @Binding var hours: Int
    @Binding var minutes: Int
    @Binding var seconds: Int

    var body: some View {
        CardioEntryCard(title: "Duration", symbol: "timer") {
            CardioTimeSelection(title: "Hours", selection: $hours, values: 0..<24)
            CardioTimeSelection(title: "Minutes", selection: $minutes, values: 0..<60)
            CardioTimeSelection(title: "Seconds", selection: $seconds, values: 0..<60)
        }
        .pickerStyle(.menu)
    }
}

private struct CardioEntryHeader: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "figure.run")
                .font(.system(size: 38, weight: .semibold))
                .foregroundStyle(Color("PrimaryColor"))
                .padding(18)
                .background(Color("AccentColor").opacity(0.16),
                            in: RoundedRectangle(cornerRadius: 24))
                .accessibilityHidden(true)
            Text("ENTER YOUR CARDIO")
                .font(.title.weight(.black))
                .foregroundStyle(Color("AccentColor"))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

private struct CardioEntryCard<Content: View>: View {
    let title: LocalizedStringKey
    let symbol: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(title, systemImage: symbol)
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(Color("BackgroundColor"))
        .tint(Color("BackgroundColor"))
        .padding(20)
        .background(Color("AccentColor"), in: RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color("PrimaryColor").opacity(0.25), lineWidth: 1)
        }
        .shadow(color: Color("AccentColor").opacity(0.15), radius: 10, y: 5)
    }
}

private struct CardioTimeSelection: View {
    let title: LocalizedStringKey
    @Binding var selection: Int
    let values: Range<Int>

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Picker(title, selection: $selection) {
                ForEach(values, id: \.self) { value in
                    Text("\(value)").tag(value)
                }
            }
            .labelsHidden()
            .accessibilityLabel(Text(title))
        }
    }
}
