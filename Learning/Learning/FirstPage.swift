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
                .frame(height: 58)
                .glassEffect(.clear)
                .background(
                    Group {
                        if isSelected {
                            Capsule()
                                .fill(Color.accentOrange)
                        }
                    }
                        .glassEffect(.clear).frame(height: 58)

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


                VStack(alignment: .leading, spacing: 50) {

                    // Logo/Icon
                    HStack {
                        Spacer()
                        
                        ZStack {
                            // 1. الدائرة الداكنة
                            Circle()
                                .fill(Color(red: 0.15, green: 0.05, blue: 0.05))
                                .shadow(color: Color.orange.opacity(0.3), radius: 5, x: 0, y: 0)
                                .glassEffect(.clear)
                            // 2. الشعار (SF Symbol)
                            Image(systemName: "flame.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                                .foregroundColor(Color(red: 1.0, green: 0.65, blue: 0.2))
                        }
                        .frame(width: 109, height: 109) // حجم الإطار العام للدائرة
                        .background(Color.black)       // خلفية سوداء
                        .padding(.top)
                        Spacer()
                    }


                    // Header Text
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Hello Learner")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primaryText)

                        Text("This app will help you learn everyday!")
                            .font(.callout)
                            .foregroundColor(.secondaryText)
                    }

                    // Learning Topic Input
                    VStack(alignment: .leading, spacing: 1) {
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
                                .glassEffect(.clear)
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
