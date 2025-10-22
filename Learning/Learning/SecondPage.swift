import SwiftUI
import Combine

// يتم جلب جميع الألوان من ملف AppColors.swift (يفترض وجودها)

// MARK: - App State (Main Activity Status and Data)

// تمثيل حالة اليوم
enum ActivityStatus: Codable, Equatable {
    case Default // لم يتم التسجيل بعد
    case Logged // تم تسجيل التعلم اليوم
    case Freezed // تم تجميد اليوم
}

// مدير الحالة الحقيقي للأنشطة
class ActivityManager: ObservableObject {
    
    @Published var startOfWeek: Date
    @Published var selectedDate: Date
    @Published var dailyStatus: [Date: ActivityStatus]

    // لتبسيط الإعدادات الافتراضية للقاموس
    private func safeDate(_ value: Int) -> Date {
        // نضمن عودة قيمة Date آمنة للتهيئة
        return Date.calendar.date(byAdding: .day, value: value, to: Date().startOfDay!)!
    }

    init() {
        // 1) احسب اليوم وبداية الأسبوع
        let today = Date().startOfDay!
        let weekStart = today.startOfWeek!
        
        // 2) هيّئ الخصائص المخزنة أولًا
        self.startOfWeek = weekStart
        self.selectedDate = today
        self.dailyStatus = [:]
        
        // 3) احسب تواريخ الأمس وبكرا محليًا بدون استخدام self
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        // 4) عيّن القيم بعد اكتمال التهيئة
        self.dailyStatus = [
            today: .Logged,
            yesterday: .Logged,
            tomorrow: .Freezed
        ]
    }
    
    // البيانات الإحصائية (سأجعلها computed property لتحديثها تلقائيًا)
    var daysLearned: Int {
        dailyStatus.values.filter { $0 == .Logged }.count
    }
    
    var daysFreezed: Int {
        dailyStatus.values.filter { $0 == .Freezed }.count
    }

    // لتحديث حالة النشاط لليوم المختار
    func updateStatus(to status: ActivityStatus) {
        dailyStatus[selectedDate.startOfDay!] = status
    }
}

// MARK: - Date Extensions (مساعدات لتنظيم التاريخ)
extension Date {
    static let calendar = Calendar.current
    
    var startOfWeek: Date? {
        // يعيد تاريخ بداية الأسبوع (الأحد أو الإثنين حسب إعدادات الجهاز)
        return Date.calendar.date(from: Date.calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
    }
    
    var startOfDay: Date? {
        return Date.calendar.startOfDay(for: self)
    }
    
    var dayBefore: Date? {
        return Date.calendar.date(byAdding: .day, value: -1, to: self)
    }
    
    var dayAfter: Date? {
        return Date.calendar.date(byAdding: .day, value: 1, to: self)
    }
    
    // للحصول على اختصار يوم الأسبوع (مثال: SUN)
    var dayAbbreviation: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: self).uppercased()
    }
    
    // للحصول على رقم اليوم (مثال: 24)
    var dayNumber: Int {
        return Date.calendar.component(.day, from: self)
    }
}

// MARK: - Component 1: Date Button (زر اليوم القابل للنقر)
struct DateButton: View {
    @ObservedObject var manager: ActivityManager
    let date: Date
    
    var status: ActivityStatus {
        // قراءة حالة اليوم من المدير
        manager.dailyStatus[date.startOfDay!] ?? .Default
    }
    
    var isSelected: Bool {
        // مقارنة اليوم مع اليوم المختار
        manager.selectedDate.startOfDay! == date.startOfDay!
    }

    var selectedBgColor: Color {
        switch status {
        case .Logged:
            return .accentOrange
        case .Freezed:
            return .freezedCyan
        case .Default:
            return .clear // لا يوجد لون خلفية إذا كان مختارًا ولم يتم تسجيله بعد
        }
    }

    var body: some View {
        Button(action: {
            // منطق حقيقي: عند النقر، يتم تحديث اليوم المختار في المدير
            manager.selectedDate = date.startOfDay!
        }) {
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
                                Circle()
                                    .fill(Color.gray.opacity(40))
                                // لون خفيف إذا كان مختارًا و Default
                            } else {
                                // تلوين الأيام التي تم تسجيلها أو تجميدها حتى لو لم تكن مختارة
                                if status == .Logged {
                                    Circle().fill(Color.accentOrange.opacity(0.3))
                                } else if status == .Freezed {
                                    Circle().fill(Color.freezedCyan.opacity(0.3))
                                } else {
                                    Color.clear
                                    
                                }
                            }
                        }
                    )
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Component 2: Summary Card (بطاقات الإحصائيات الصغيرة)
struct SummaryCard: View {
    let value: Int
    let label: String
    let color: Color
    let icon: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.primaryText)
            
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
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(color.opacity(0.4))
        )
        .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Component 3: Main Dynamic Button (الزر الدائري الرئيسي)
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
        case .Logged: return .LoggedColor
        case .Freezed: return .FreezedColor
            
        }
    }
    
    var body: some View {
        Button(action: {
            // منطق حقيقي: عند النقر، تحديث حالة اليوم المختار إلى Logged
            manager.updateStatus(to: .Logged)
        }) {
            Text(text)
                .font(.title2)
                .fontWeight(.heavy)
                .foregroundColor(.primaryText)
                .frame(width: 250, height: 250)
                .background(
                    Circle()
                        .fill(bgColor)
                    
                        .shadow(color: bgColor.opacity(0.6), radius: 30, x: 0, y: 10)
                        // ملاحظة: glassEffect غير معرّف لدينا في المشروع بحسب البحث.
                        // إذا لديك موديفاير مخصص له، أضفه هنا. وإلا يمكن تركه بدون.
                )
            
        }
        // ملاحظة: .buttonStyle(.glass) غير معرّف لدينا في المشروع بحسب البحث.
        // إن كان لديك ستايل مخصص بنفس الاسم، أعده. وإلا استخدم .buttonStyle(.plain) أو عرف ستايل موحد.
        .buttonStyle(.plain)
    }
}


// MARK: - Main View: SecondPage
struct SecondPage: View {
    
    @StateObject private var manager = ActivityManager()
    
    // دالة للحصول على أيام الأسبوع الحالي المعروض
    func getWeekDays() -> [Date] {
        var days: [Date] = []
        let start = manager.startOfWeek
        for i in 0..<7 {
            if let date = Calendar.current.date(byAdding: .day, value: i, to: start) {
                days.append(date)
            }
        }
        return days
    }
    
    // للحصول على الشهر والسنة المعروضين
    var monthYearDisplay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: manager.startOfWeek).capitalized
    }
    
    // MARK: Popover state + temp date
    @State private var isShowingDatePicker = false
    @State private var tempDate = Date()
    
    var body: some View {
        ZStack {
            Color.primaryBackground
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 25) {
                
                VStack(spacing: 20) {
                    // --- 2. شريط التقويم الأسبوعي ---
                    VStack(spacing: 20) {
                        HStack {
                            Text("\(monthYearDisplay)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primaryText)
                            
                            // زر السهم لفتح الـ Popover
                            Button {
                                // عيّني التاريخ المؤقت للحالي قبل الفتح
                                tempDate = manager.selectedDate
                                isShowingDatePicker = true
                            } label: {
                                Image(systemName: "chevron.right")
                                    .font(.title3)
                                    .foregroundColor(.accentOrange)
                            }
                            .buttonStyle(.plain)
                            // Popover مع DatePicker Wheel
                            .popover(isPresented: $isShowingDatePicker) {
                                VStack(spacing: 16) {
                                    DatePicker(
                                        "",
                                        selection: $tempDate,
                                        displayedComponents: [.date]
                                    )
                                    .datePickerStyle(.wheel)
                                    .labelsHidden()
                                    
                                    Button {
                                        // ثبّت الاختيار: حدّث selectedDate و startOfWeek
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
                                            .background(
                                                Capsule().fill(Color.accentOrange)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding()
                                // إجبار الـ popover فقط على المظهر الداكن ليصبح الـ wheel أسود
                                .preferredColorScheme(.dark)
                                .presentationDetents([.fraction(0.35)])
                            }
                            
                            Spacer()
                            
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
                        .padding(.top, 5)
                        
                        // عرض الأيام
                        HStack(spacing: 0) {
                            ForEach(getWeekDays(), id: \.self) { date in
                                DateButton(manager: manager, date: date)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    
                    // 🔹 الخط الفاصل الرمادي الغامق (زي الصورة)
                    Divider()
                        .frame(height: 1)
                        .background(Color.gray.opacity(0.4))
                        .padding(.horizontal, 10)
                    
                    // --- 3. Learning Topic ---
                    Text("Learning Swift")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // --- 4. Summary Cards ---
                    HStack(spacing: 15) {
                        SummaryCard(
                            value: manager.daysLearned,
                            label: "Days Learned",
                            color: Color.accentOrange.opacity(0.8),
                            icon: "flame.fill"
                        )
                        
                        
                        SummaryCard(
                            value: manager.daysFreezed,
                            label: "Day Freezed",
                            color: Color.freezedCyan.opacity(0.7),
                            icon: "cube.fill"
                        )
                        
                    }
                }
                .padding(5)
                .background( // نفس البطاقة الداكنة اللي بالصورة
                    RoundedRectangle(cornerRadius: 40)
                        .fill(Color.gray.opacity(0.10))
                )
                
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray, lineWidth: 2)
                )
                
                
                // 5. Main Dynamic Button (الزر المركزي)
                MainActionButton(manager: manager)
                    .padding(.vertical, 0)
                
                
                // 6. Secondary Action Button (Log as Freezed)
                Button(action: {
                    // منطق حقيقي: تحديث حالة اليوم المختار إلى Freezed
                    manager.updateStatus(to: .Freezed)
                }) {
                    Text("Log as Freezed")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primaryText)
                        .padding(.horizontal, 16) // توسع من اليمين واليسار
                        .padding(.vertical, 8)    // توسع من الأعلى والأسفل
                        .background(
                            Capsule()
                                .fill(Color.freezedCyan)
                                // glassEffect غير معرف لدينا. إن كان لديك، أعده هنا.
                        )
                    
                }
                .buttonStyle(.plain)
                .shadow(color: Color.freezedCyan.opacity(0.4), radius: 40, x: 0, y: 0)
                
                // 7. Freezer Usage Text
                Text("1 out of 2 Freezes used") // تركها ثابتة كبيانات وهمية مؤقتًا
                    .font(.caption)
                    .foregroundColor(.secondaryText)
                
            }
            .padding(.horizontal, 30) // لمطابقة FirstPage
        }
        // توحيد لون التينت/الروابط مع FirstPage
        .tint(.accentOrange)
        .toolbar {
            // العنوان في الوسط
            ToolbarItem(placement: .principal) {
                Text("Activity")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryText)
            }
            // الأزرار في اليمين: كل زر كعنصر مستقل
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
        // لف SecondPage داخل NavigationStack لعرض الـ Toolbar في الكانفس
        NavigationStack {
            SecondPage()
        }
        .preferredColorScheme(.dark)
    }
}
