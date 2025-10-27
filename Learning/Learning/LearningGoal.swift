import SwiftUI

struct LearningGoal: View {
    @EnvironmentObject var manager: ActivityManager
    @State private var learningTopic: String = "Swift"
    @State private var selectedDuration: FirstPage.Duration = .week

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                VStack(alignment: .leading, spacing: 50) {
                    VStack(alignment: .leading, spacing: 1) {
                        HStack(spacing: 0) {
                            Color(.tertiarySystemBackground)
                                .frame(width: 4, height: 20)
                                .cornerRadius(2)
                            Text("I want to learn")
                                .font(.body)
                                .foregroundColor(.primary)
                                .padding(.leading, 12)
                        }

                        TextField("Enter topic (e.g., Swift)", text: $learningTopic)
                            .foregroundColor(.primary)
                            .accentColor(.accentOrange)
                            .padding(.vertical, 8)

                        Divider().background(Color.secondary)
                    }

                    VStack(alignment: .leading, spacing: 15) {
                        Text("I want to learn it in a")
                            .font(.body)
                            .foregroundColor(.primary)

                        HStack(spacing: 10) {
                            ForEach(FirstPage.Duration.allCases, id: \.self) { duration in
                                DurationButton(duration: duration, selectedDuration: $selectedDuration)
                            }
                            Spacer()
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 30)
            }
            .accentColor(Color.accentOrange)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Learning Goal")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: SecondPage(
                        learningTopic: learningTopic,
                        selectedDuration: selectedDuration
                    ).environmentObject(manager)) { // ✅ هنا استخدمنا manager
                        ZStack {
                            Circle()
                                .fill(Color.accentOrange)
                                .frame(width: 35, height: 35)

                            Image(systemName: "checkmark")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        manager.resetCountersForNewGoal()
                    })
                    .buttonStyle(.plain)
                }

            }
        }
    }
}

#Preview {
    LearningGoal()
        .environmentObject(ActivityManager())
        .preferredColorScheme(.dark)
}
