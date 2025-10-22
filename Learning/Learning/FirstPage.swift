import SwiftUI

// ملاحظة: تم حذف جميع تعريفات الألوان ومساعد Hex Color لتوحيدها في AppColors.swift

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
                .padding(.horizontal, 10)
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
        .buttonStyle(.glass)
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
        // 🌟 تمت إضافة NavigationStack لتمكين التنقل
        NavigationStack {
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
                            .padding(.top)
                        Spacer()
                    }
                    .padding(-50)

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
                            // استخدام اللون الموحد الآن
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
                        
                        // 🌟 تم استبدال Button بـ NavigationLink للانتقال إلى SecondPage
                        NavigationLink(destination: SecondPage()) {
                            Text("Start learning") //
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primaryText)
                                // 💡 تم تصغير الزر بتحديد عرض ثابت
                                .frame(width: 250, height: 48)
                                .background(Color.accentOrange)
                                .clipShape(Capsule()) // زوايا دائرية بالكامل
                        }
                        .buttonStyle(.plain) // لضمان تطبيق الستايل المخصص على 
                        
                        Spacer() // 👈 لدفعه إلى المنتصف
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
