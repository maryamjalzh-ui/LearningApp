//
//  LearningApp.swift
//  Learning
//
//  Created by Maryam Jalal Alzahrani on 29/04/1447 AH.
//
import SwiftUI

@main
struct LearningApp: App {
    // 🧠 هذا المانجر مشترك في كل الصفحات
    @StateObject private var activityManager = ActivityManager()

    var body: some Scene {
        WindowGroup {
            FirstPage()
                .environmentObject(activityManager) // تمرير المانجر لكل الصفحات
        }
    }
}
