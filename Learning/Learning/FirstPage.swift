import SwiftUI

// MARK: - Duration Button Component
struct DurationButton: View {
    let duration: FirstPage.Duration
    @Binding var selectedDuration: FirstPage.Duration

    var isSelected: Bool { duration == selectedDuration }

    var body: some View {
        Button(action: {
            selectedDuration = duration
        }) {
            Text(duration.rawValue)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .primaryText : .secondaryText)
                .padding(.horizontal, 20)
                .frame(height: 48)
                .background(
                    Group {
                        if isSelected {
                            Capsule()
                                .fill(Color.accentOrange)
                        }
                    }
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Main View: FirstPage
struct FirstPage: View {

    enum Duration: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }

    @State private var learningTopic: String = "Swift"
    @State private var selectedDuration: Duration = .week

    var body: some View {
        NavigationStack {
            ZStack {
                Color.primaryBackground
                    .edgesIgnoringSafeArea(.all)

                VStack(alignment: .leading, spacing: 30) {

                    // Logo/Icon
                    HStack {
                        Spacer()
                        Image("logoFirstScreen")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250, height: 250)
                            .padding(.top)
                        Spacer()
                    }

                    // Header Text
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Hello Learner")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primaryText)

                        Text("This app will help you learn everyday!")
                            .font(.callout)
                            .foregroundColor(.secondaryText)
                    }

                    // Learning Topic Input
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 0) {
                            Color.inputBarColor
                                .frame(width: 4, height: 20)
                                .cornerRadius(2)

                            Text("I want to learn")
                                .font(.body)
                                .foregroundColor(.primaryText)
                                .padding(.leading, 12)
                        }

                        TextField("Enter topic (e.g., Swift)", text: $learningTopic)
                            .foregroundColor(.primaryText)
                            .accentColor(.accentOrange)
                            .padding(.vertical, 8)

                        Divider()
                            .background(Color.secondaryText)
                    }

                    // Duration Selection
                    VStack(alignment: .leading, spacing: 15) {
                        Text("I want to learn it in a")
                            .font(.body)
                            .foregroundColor(.primaryText)

                        HStack(spacing: 10) {
                            ForEach(Duration.allCases, id: \.self) { duration in
                                DurationButton(
                                    duration: duration,
                                    selectedDuration: $selectedDuration
                                )
                            }
                            Spacer()
                        }
                    }

                    Spacer()

                    // Start Learning Button
                    HStack {
                        Spacer()
                        NavigationLink(destination: SecondPage(
                            learningTopic: learningTopic,
                            selectedDuration: selectedDuration
                        )) {
                            Text("Start learning")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primaryText)
                                .frame(width: 250, height: 48)
                                .background(Color.accentOrange)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        Spacer()
                    }
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 30)
            }
            .accentColor(Color.accentOrange)
        }
    }
}

// MARK: - Preview
struct FirstPage_Previews: PreviewProvider {
    static var previews: some View {
        FirstPage()
    }
}
