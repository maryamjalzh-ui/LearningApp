import SwiftUI
import Combine

// MARK: - App State

enum ActivityStatus: Codable, Equatable {
    case Default
    case Logged
    case Freezed
}

class ActivityManager: ObservableObject {
    @Published var startOfWeek: Date
    @Published var selectedDate: Date
    @Published var dailyStatus: [Date: ActivityStatus]

    init() {
        let today = Date().startOfDay!
        let weekStart = today.startOfWeek!
        
        self.startOfWeek = weekStart
        self.selectedDate = today
        self.dailyStatus = [:]
      
        
    }
    
    var daysLearned: Int {
        dailyStatus.values.filter { $0 == .Logged }.count
    }
    
    var daysFreezed: Int {
        dailyStatus.values.filter { $0 == .Freezed }.count
    }

    func updateStatus(to status: ActivityStatus) {
        dailyStatus[selectedDate.startOfDay!] = status
    }
}

// MARK: - Date Extensions

extension Date {
    static let calendar = Calendar.current
    
    var startOfWeek: Date? {
        Date.calendar.date(from: Date.calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
    }
    
    var startOfDay: Date? { Date.calendar.startOfDay(for: self) }
    var dayBefore: Date? { Date.calendar.date(byAdding: .day, value: -1, to: self) }
    var dayAfter: Date? { Date.calendar.date(byAdding: .day, value: 1, to: self) }
    
    var dayAbbreviation: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: self).uppercased()
    }
    
    var dayNumber: Int { Date.calendar.component(.day, from: self) }
}

// MARK: - Component: Date Button

struct DateButton: View {
    @ObservedObject var manager: ActivityManager
    let date: Date
    
    var status: ActivityStatus { manager.dailyStatus[date.startOfDay!] ?? .Default }
    var isSelected: Bool { manager.selectedDate.startOfDay! == date.startOfDay! }

    var body: some View {
        Button(action: { manager.selectedDate = date.startOfDay! }) {
            VStack(spacing: 10) {
                Text(date.dayAbbreviation)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondaryText)
                
                Text("\(date.dayNumber)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryText)
                    .frame(width: 50, height: 40)
                    .background(
                        Group {
                            if isSelected {
                                Circle().fill(Color.orange.opacity(0.90))
                            } else if status == .Logged {
                                Circle().fill(Color.accentOrange.opacity(0.3))
                            } else if status == .Freezed {
                                Circle().fill(Color.freezedCyan.opacity(0.3))
                            } else {
                                Color.clear
                            }
                        }
                    )
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Component: Summary Card

struct SummaryCard: View {
    let value: Int
    let label: String
    let color: Color
    let icon: String
    let iconColor: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .padding(.leading, 5)
                .foregroundColor(iconColor)
            
            VStack(alignment: .leading) {
                Text("\(value)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryText)
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(.primaryText)
            }
            Spacer()
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 2)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 45).fill(color.opacity(0.4)))
        .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)

    }
}

// MARK: - Component: Main Dynamic Button

struct MainActionButton: View {
    @ObservedObject var manager: ActivityManager
    
    var text: String {
        switch manager.dailyStatus[manager.selectedDate.startOfDay!] ?? .Default {
        case .Default: return "Log as Learned"
        case .Logged: return "Learned Today"
        case .Freezed: return "Day Freezed"
        }
    }
    
    var bgColor: Color {
        switch manager.dailyStatus[manager.selectedDate.startOfDay!] ?? .Default {
        case .Default: return .accentOrange
        case .Logged: return Color.LoggedColor
        case .Freezed: return .FreezedColor
        }
    }
    
    var body: some View {
        Button(action: { manager.updateStatus(to: .Logged) }) {
            Text(text)
                .font(.title2)
                .fontWeight(.heavy)
                .foregroundColor(.primaryText)
                .frame(width: 250, height: 250)
            
                .background(
                    Circle()
                        .fill(bgColor)
                        .shadow(color: Color.orange.opacity(0.3), radius: 5, x: 0, y: 0)
                        .glassEffect(.clear)    // ✅ أضف تأثير الزجاج هنا

                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Subview: Week Calendar

struct WeekCalendarView: View {
    @ObservedObject var manager: ActivityManager
    @State private var isShowingDatePicker = false
    @State private var tempDate = Date()
    
    var monthYearDisplay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: manager.startOfWeek).capitalized
    }
    
    func getWeekDays() -> [Date] {
        (0..<7).compactMap { Calendar.current.date(byAdding: .day, value: $0, to: manager.startOfWeek) }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text(monthYearDisplay)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryText)
                
                // DatePicker Popover
                Button {
                    tempDate = manager.selectedDate
                    isShowingDatePicker = true
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .foregroundColor(.accentOrange)
                }
                .buttonStyle(.plain)
                .popover(isPresented: $isShowingDatePicker) {
                    VStack(spacing: 16) {
                        DatePicker("", selection: $tempDate, displayedComponents: [.date])
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                        
                        Button {
                            manager.selectedDate = tempDate
                            if let newStart = tempDate.startOfWeek {
                                manager.startOfWeek = newStart
                            }
                            isShowingDatePicker = false
                        } label: {
                            Text("Done")
                                .font(.headline)
                                .foregroundColor(.primaryText)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Capsule().fill(Color.accentOrange))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding()
                    .preferredColorScheme(.dark)
                    .presentationDetents([.fraction(0.35)])
                }
                
                Spacer()
                
                // Week navigation
                Button {
                    if let newDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: manager.startOfWeek) {
                        manager.startOfWeek = newDate
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.accentOrange)
                }
                .buttonStyle(.plain)
                
                Button {
                    if let newDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: manager.startOfWeek) {
                        manager.startOfWeek = newDate
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundColor(.accentOrange)
                }
                .buttonStyle(.plain)
            }
            
            // Week days
            HStack(spacing: 0) {
                ForEach(getWeekDays(), id: \.self) { date in
                    DateButton(manager: manager, date: date)
                        .frame(maxWidth: .infinity)

                }

            }
            Divider()
                .frame(height: 0.5)
                .background(Color.gray.opacity(0.2))
                .padding(.horizontal, 10)
        }
        
    }

}

// MARK: - Subview: Summary Cards

struct SummaryCardsView: View {
    @ObservedObject var manager: ActivityManager
    
    var body: some View {
        HStack(spacing: 10) {
            SummaryCard(
                value: manager.daysLearned,
                label: "Days Learned",
                color: Color.accentOrange.opacity(0.8),
                icon: "flame.fill",
                iconColor: .accentOrange
            )
            
            SummaryCard(
                value: manager.daysFreezed,
                label: "Day Freezed",
                color: Color.freezedCyan.opacity(0.7),
                icon: "cube.fill",
                iconColor: .freezedCyan
            )
        }

    }
}

// MARK: - Subview: Secondary Action Button

struct SecondaryActionButtonView: View {
    @ObservedObject var manager: ActivityManager
    let maxFreezes: Int   // ✅ التغيير: تمرير أقصى عدد Freezes من SecondPage

    var isDisabled: Bool {   // ✅ التغيير: الزر يتوقف إذا وصل المستخدم الحد أو اليوم مسجل
        manager.daysFreezed >= maxFreezes || manager.dailyStatus[manager.selectedDate.startOfDay!] == .Logged
    }

    var body: some View {
        Button(action: { manager.updateStatus(to: .Freezed) }) {
            Text("Log as Freezed")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primaryText)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Capsule().fill(Color.freezedCyan))
        }
        .buttonStyle(.plain)
        .shadow(color: Color.freezedCyan.opacity(0.4), radius: 40, x: 0, y: 0)
        .disabled(isDisabled)  // ✅ التغيير
    }
}

// MARK: - Main View: SecondPage

struct SecondPage: View {
    @StateObject private var manager = ActivityManager()
    
    // ✅ التغييرات: استقبال البيانات من FirstPage
    var learningTopic: String
    var selectedDuration: FirstPage.Duration
    
    // ✅ التغيير: حساب أقصى Freezes حسب Duration
    var maxFreezes: Int {
        switch selectedDuration {
        case .week: return 2
        case .month: return 8
        case .year: return 96
        }
    }
    
    var body: some View {
        ZStack {
            Color.primaryBackground.edgesIgnoringSafeArea(.all)

            VStack(spacing: 25) {

                VStack(spacing: 20) {
                    // --- Week Calendar ---
                    WeekCalendarView(manager: manager)

                    // --- Learning Topic (Swift) ---
                    Text(learningTopic)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 5)

                    
                    // --- Summary Cards ---
                    SummaryCardsView(manager: manager)

                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 40)
                        .fill(Color.darkGreyBackground.opacity(0.3))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(Color.gray, lineWidth: 0.3)


                )


                
                MainActionButton(manager: manager)

                SecondaryActionButtonView(manager: manager, maxFreezes: maxFreezes)   // ✅ التغيير: تمرير maxFreezes
                
                Text("\(manager.daysFreezed) out of \(maxFreezes) Freezes used")
                    .font(.caption)
                    .foregroundColor(.secondaryText)

            }
            .padding(.horizontal, 30)
        }
        .tint(.accentOrange)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Activity")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryText)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: AllActivity()) {
                    Image(systemName: "calendar")
                        .font(.title3)
                        .padding()
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: LearningGoal()) {
                    Image(systemName: "pencil.and.outline")
                        .font(.title2)
                        .padding()
                }
            }
        }
    }
}

// MARK: - Preview

struct SecondPage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SecondPage(learningTopic: "Swift", selectedDuration: .week)
        }
        .preferredColorScheme(.dark)
    }
}

