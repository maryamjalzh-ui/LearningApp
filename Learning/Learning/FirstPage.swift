import SwiftUI

// MARK: - Hex Color Initializer Helper
// وظيفة مساعدة لتحويل أكواد Hex إلى كائنات Color في SwiftUI
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


// MARK: - Color Extension for App Colors
extension Color {
    // الخلفية الرئيسية (الأسود العادي)
    static let primaryBackground = Color.black
    // اللون البرتقالي المميز (FF9230)
    static let accentOrange = Color(hex: "#FF9230")
    
    // لون النص الأساسي
    static let primaryText = Color.white
    // لون النص الثانوي (لـ Month/Year)
    static let secondaryText = Color(white: 0.6)
    // لون خلفية الأزرار غير المختارة (الرمادي الداكن - لم يعد مستخدماً)
    static let darkGreyBackground = Color(white: 0.2)
    // اللون الجديد لنهاية التدرج اللوني في الأزرار غير المختارة: rgba(26, 26, 26, 1)
    static let darkGradientEnd = Color(red: 26/255, green: 26/255, blue: 26/255)

    // تقدير لون التوهج/الظل الخفيف للزر الرئيسي
    static let buttonGlow = Color.accentOrange.opacity(0.4)
}

// MARK: - Duration Button Component (مطابقة الأبعاد 48 والزوايا الدائرية)
struct DurationButton: View {
    let duration: FirstPage.Duration
    @Binding var selectedDuration: FirstPage.Duration

    var isSelected: Bool {
        duration == selectedDuration
    }

    var body: some View {
        Button(action: {
            selectedDuration = duration
        }) {
            Text(duration.rawValue)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .primaryText : .secondaryText)
                .padding(.horizontal, 20)
                // تحديد الارتفاع الثابت 48 نقطة
                .frame(height: 48)
                .background(
                    // التعديل هنا لتطبيق ستايل CSS المعقد
                    Group {
                        if isSelected {
                            // الزر المختار: لون برتقالي صلب
                            Capsule() // شكل بيضاوي لزوايا دائرية كاملة (Smooth Corners 50)
                                .fill(Color.accentOrange)
                        } else {
                            // الزر غير المختار: تطبيق ستايل Glass/Liquid من CSS
                            ZStack {
                                Capsule()
                                    // تطبيق التدرج اللوني: linear-gradient( rgba(0, 0, 0, 0.4) , rgba(26, 26, 26, 1) )
                                    .fill(LinearGradient(
                                        colors: [Color.black.opacity(0.4), Color.darkGradientEnd],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ))
                                    // تطبيق الضبابية: filter: blur( 6px ) على الخلفية فقط
                                    .blur(radius: 6)

                                // محاكاة الظلال/الحدود الداخلية (Inset Shadows)
                                Capsule()
                                    .stroke(Color.white.opacity(0.1), lineWidth: 0.5) // محاكاة الإضاءة العلوية
                                    .shadow(color: Color.black.opacity(0.8), radius: 2, x: 0, y: 1) // محاكاة الظل السفلي
                            }
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
        ZStack {
            Color.primaryBackground
                .edgesIgnoringSafeArea(.all)

            VStack(alignment: .leading, spacing: 30) {

                // 1. Logo/Icon (تم حذف الدائرة الخلفية وتكبير حجم الصورة لتأخذ مكان الدائرة)
                HStack {
                    Spacer()
                    // 🚨 استخدام الصورة مباشرة وتحديد حجمها
                    Image("logoFirstScreen") // اسم الصورة في Assets
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250) // الحجم الجديد
                        .padding(.top,)
                    Spacer()
                }
                .padding(.bottom, -50)

                // 2. Header Text
                VStack(alignment: .leading, spacing: 5) {
                    Text("Hello Learner")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryText)

                    Text("This app will help you learn everyday!")
                        .font(.callout)
                        .foregroundColor(.secondaryText)
                }

                // 3. Learning Topic Input
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 0) {
                        // تم إرجاع اللون الأخضر الأصلي
                        Color.green
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

                // 4. Duration Selection (الأزرار المنفصلة)
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

                // 5. Start Learning Button (الزر الرئيسي)
                HStack { // 👈 تم إضافة HStack لتوسيط الزر
                    Spacer() // 👈 لدفعه إلى المنتصف
                    Button(action: {
                        print("Start learning action")
                    }) {
                        Text("Start learning")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primaryText)
                            // 💡 تم تصغير الزر بتحديد عرض ثابت
                            .frame(width: 250, height: 48)
                            .background(Color.accentOrange)
                            .clipShape(Capsule()) // زوايا دائرية بالكامل
                    }
                    .shadow(color: Color.buttonGlow, radius: 10, x: 0, y: 0) // توهج
                    .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 3) // ظل
                    Spacer() // 👈 لدفعه إلى المنتصف
                }
                .padding(.bottom, 20)

            }
            .padding(.horizontal, 30)
        }
        .accentColor(Color.accentOrange)
    }
}

// MARK: - Preview
struct FirstPage_Previews: PreviewProvider {
    static var previews: some View {
        FirstPage()
    }
}
