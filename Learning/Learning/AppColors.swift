import SwiftUI

// MARK: - Hex Color Initializer Helper
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
    
    // اللون البرتقالي المميز (FF9230) - يستخدم لحالة "Learned"
    static let accentOrange = Color(hex: "#FF9230")
    
    // اللون السماوي الجديد لحالة "Freezed" (0, 210, 224)
    static let freezedCyan = Color(red: 0/255, green: 210/255, blue: 224/255)
    
    // لون النص الأساسي
    static let primaryText = Color.white
    // لون النص الثانوي
    static let secondaryText = Color(white: 0.6)
    
    // لون خلفية الأزرار غير المختارة / اللون الثانوي (الرمادي الداكن)
    static let darkGreyBackground = Color(white: 0.2)
    
    // اللون الجديد لنهاية التدرج اللوني في الأزرار غير المختارة: rgba(26, 26, 26, 1)
    static let darkGradientEnd = Color(red: 26/255, green: 26/255, blue: 26/255)

    // لون شريط الإدخال أو الشريط الجانبي (كان أخضر/رمادي)
    static let inputBarColor = Color(red: 0.05, green: 0.4, blue: 0.05) // لون داكن
    
    // تقدير لون التوهج/الظل الخفيف للزر الرئيسي
    static let buttonGlow = Color.accentOrange.opacity(0.4)
}
