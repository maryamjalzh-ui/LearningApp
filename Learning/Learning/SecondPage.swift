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
    
    // ✅ عدادات الهدف الحالي فقط
    @Published var currentGoalLearned = 0
    @Published var currentGoalFreezed = 0

    init() {
        let today = Date().startOfDay!
        let weekStart = today.startOfWeek!
        self.startOfWeek = weekStart
        self.selectedDate = today
        self.dailyStatus = [:]
    }

    var daysLearned: Int { dailyStatus.values.filter { $0 == .Logged }.count }
    var daysFreezed: Int { dailyStatus.values.filter { $0 == .Freezed }.count }

    func updateStatus(to status: ActivityStatus) {
        dailyStatus[selectedDate.startOfDay!] = status

        switch status {
        case .Logged:
            currentGoalLearned += 1
        case .Freezed:
            currentGoalFreezed += 1
        default:
            break
        }
    }
    
    func resetCountersForNewGoal() {
        currentGoalLearned = 0
        currentGoalFreezed = 0
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
    let isPastDay: Bool
    
    init(manager: ActivityManager, date: Date) {
        self.manager = manager
        self.date = date
        self.isPastDay = date < Date().startOfDay!
    }

    var body: some View {
        Button(action: {
            if !isPastDay {
                manager.selectedDate = date.startOfDay!
            }
        }) {
            VStack(spacing: 10) {
                Text(date.dayAbbreviation)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(isPastDay ? .gray.opacity(0.4) : .secondaryText)
                
                Text("\(date.dayNumber)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(isPastDay ? .gray.opacity(0.5) : .primaryText)
                    .frame(width: 50, height: 40)
                    .background(
                        Group {
                            if isSelected && !isPastDay {
                                Circle().fill(Color.orange.opacity(0.90))
                            } else if status == .Logged {
                                Circle().fill(Color.orange.opacity(0.3))
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
        .disabled(isPastDay)
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
                    .font(.title)
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
    var textColor: Color {
            switch manager.dailyStatus[manager.selectedDate.startOfDay!] ?? .Default {
            case .Default: return .primaryText
            case .Logged: return .accentOrange
            case .Freezed: return .freezedCyan
            }
        }
    var bgColor: Color {
        switch manager.dailyStatus[manager.selectedDate.startOfDay!] ?? .Default {
        case .Default: return .accentOrange
        case .Logged: return Color.LoggedColor
        case .Freezed: return .FreezedColor
        }
    }
    
    var isDisabled: Bool {
            let status = manager.dailyStatus[manager.selectedDate.startOfDay!] ?? .Default
            return status == .Logged || status == .Freezed
        }

    var body: some View {
        Button(action: { manager.updateStatus(to: .Logged) }) {
            Text(text)
                .font(.title2)
                .fontWeight(.heavy)
                .foregroundColor(textColor) // ← هنا التغيير
                .frame(width: 250, height: 250)
                .background(
                    Circle()
                        .fill(bgColor)
                        .shadow(color: Color.orange.opacity(0.5), radius: 10)
                        .glassEffect(.clear.tint(.buttonGlow))
                )
        }
        .disabled(isDisabled)
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
            // 🔹 العنوان مع الأسهم واختيار التاريخ
            HStack {
                HStack(spacing: 6) {
                    Text(monthYearDisplay)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryText)
                    
                    Button(action: {
                        tempDate = manager.startOfWeek
                        isShowingDatePicker.toggle()
                    }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.accentOrange)
                    }
                }
                
                Spacer()
                
                Button {
                    if let newDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: manager.startOfWeek) {
                        manager.startOfWeek = newDate
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(.accentOrange)
                        .padding(15)
                }
                
                Button {
                    if let newDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: manager.startOfWeek) {
                        manager.startOfWeek = newDate
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .foregroundColor(.accentOrange)
                }
            }
            .sheet(isPresented: $isShowingDatePicker) {
                VStack {
                    DatePicker(
                        "Select Date",
                        selection: $tempDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .colorScheme(.dark)
                    .accentColor(.accentOrange)
                    .padding()
                    
                    Button("Done") {
                        if let newStart = tempDate.startOfWeek {
                            manager.startOfWeek = newStart

                        }
                        isShowingDatePicker = false
                        
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentOrange)
                    .glassEffect(.clear)
                    .cornerRadius(15)
                    .padding(.horizontal)
                }
                .presentationDetents([.height(300)])
                .background(Color.primaryBackground)
            }
            
            // 🔹 الأيام
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

// MARK: - Subview: Secondary Action Button
struct SecondaryActionButtonView: View {
    @ObservedObject var manager: ActivityManager
    let maxFreezes: Int

    var isDisabled: Bool {
        let status = manager.dailyStatus[manager.selectedDate.startOfDay!] ?? .Default
        return status == .Logged || status == .Freezed || manager.currentGoalFreezed >= maxFreezes
    }

    var body: some View {
        Button(action: {
            if !isDisabled {
                manager.updateStatus(to: .Freezed)
            }
        }) {
            Text("Log as Freezed")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primaryText)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Capsule().fill(Color.freezedCyan))
        }
        .buttonStyle(.plain)
        .shadow(color: Color.freezedCyan.opacity(0.4), radius: 40)
        .disabled(isDisabled)
    }
}


// MARK: - Main View: SecondPage
// MARK: - Main View: SecondPage
struct SecondPage: View {
    @EnvironmentObject var manager: ActivityManager
    var learningTopic: String
    var selectedDuration: FirstPage.Duration

    // ✅ عدد الأيام المطلوبة بناءً على نوع الهدف
    private var goalDays: Int {
        switch selectedDuration {
        case .week:  return 7
        case .month: return 30
        case .year:  return 365
        }
    }

    // ✅ يتحقق إذا المستخدم خلص الهدف (تعلم + تجميد)
    private var isGoalDone: Bool {
        let totalLogged = manager.currentGoalLearned
        let totalFreezed = manager.currentGoalFreezed
        let totalDays = totalLogged + totalFreezed
        return totalDays >= goalDays
    }

    var maxFreezes: Int {
        switch selectedDuration {
        case .week:  return 2
        case .month: return 8
        case .year:  return 96
        }
    }

    var body: some View {
        ZStack {
            Color.primaryBackground.ignoresSafeArea()

            VStack(spacing: 25) {
                // ✅ الكارد الأساسي
                VStack(spacing: 20) {
                    WeekCalendarView(manager: manager)
                    
                    Text(learningTopic)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 5)
                    
                    // ✅ عدادات الهدف الحالي
                    HStack(spacing: 10) {
                        SummaryCard(
                            value: manager.currentGoalLearned,
                            label: "Days Learned",
                            color: Color.accentOrange.opacity(0.8),
                            icon: "flame.fill",
                            iconColor: .accentOrange
                        )
                        SummaryCard(
                            value: manager.currentGoalFreezed,
                            label: "Days Freezed",
                            color: Color.freezedCyan.opacity(0.7),
                            icon: "cube.fill",
                            iconColor: .freezedCyan
                        )
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 40)
                        .fill(Color.darkGreyBackground.opacity(0.5))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 50)
                        .stroke(Color.gray, lineWidth: 0.3)
                )

                // ✅ إذا خلص الهدف تطلع شاشة التهنئة
                if isGoalDone {
                    VStack(spacing: 20) {
                        Image(systemName: "hands.clap.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.accentOrange)
                            .padding(.top, 30)

                        Text("Well done!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primaryText)

                        Text("Goal completed! Start learning again or set a new learning goal.")
                            .font(.callout)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondaryText)
                            .padding(.horizontal, 20)

                        // زر إنشاء هدف جديد
                        NavigationLink(destination: LearningGoal().environmentObject(manager)) {
                            Text("Set new learning goal")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 280, height: 50)
                                .glassEffect(.clear)
                                .background(Color.accentOrange)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)

                        // زر نفس الهدف
                        Button(action: {
                            manager.resetCountersForNewGoal()
                        }) {
                            Text("Set same learning goal and duration")
                                .font(.footnote)
                                .foregroundColor(.accentOrange)
                            
                        }
                        .padding(.bottom, 40)
                    }
                    .transition(.opacity)
                } else {
                    // ✅ الوضع الطبيعي أثناء التعلم
                    MainActionButton(manager: manager)
                    SecondaryActionButtonView(manager: manager, maxFreezes: maxFreezes)
                    Text("\(manager.currentGoalFreezed) out of \(maxFreezes) Freezes used")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
            }
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
                HStack(spacing: 15) {
                    NavigationLink(destination: AllActivity().environmentObject(manager)) {
                        Image(systemName: "calendar")
                            .font(.title3)
                            .padding(4)
                    }

                    NavigationLink(destination: LearningGoal().environmentObject(manager)) {
                        Image(systemName: "pencil.and.outline")
                            .font(.title2)
                            .padding(4)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SecondPage(learningTopic: "Swift", selectedDuration: .week)
            .environmentObject(ActivityManager())
    }
    .preferredColorScheme(.dark)
}
