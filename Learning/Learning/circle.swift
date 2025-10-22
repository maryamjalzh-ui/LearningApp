import SwiftUI

struct DarkFireCircleView: View {
    var body: some View {
        ZStack {
            // 1. الدائرة الداكنة
            Circle()
                .fill(Color(red: 0.15, green: 0.05, blue: 0.05)) // لون بني داكن أو أسود تقريباً
                // إضافة ظل خفيف حول الحافة لإبرازها (اختياري)
                .shadow(color: Color.orange.opacity(0.3), radius: 5, x: 0, y: 0)

            // 2. الشعار (SF Symbol)
            // استخدام "flame.fill" أو "fire.fill" كرمز مناسب للهب
            Image(systemName: "flame.fill")
                .resizable() // للسماح بتغيير حجم الصورة
                .aspectRatio(contentMode: .fit) // للحفاظ على نسبة العرض إلى الارتفاع
                .frame(width: 100, height: 100) // تحديد حجم الشعار
                .foregroundColor(Color(red: 1.0, green: 0.65, blue: 0.2)) // لون برتقالي ناري
        }
        .frame(width: 250, height: 250) // حجم الإطار العام للدائرة
        .background(Color.black) // خلفية سوداء (لتتوافق مع الصورة)
    }
}

struct DarkFireCircleView_Previews: PreviewProvider {
    static var previews: some View {
        DarkFireCircleView()
    }
}
