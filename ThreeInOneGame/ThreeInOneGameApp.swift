//
//  ThreeInOneGameApp.swift
//  FourInOneGameApp
//
//  Created by Varun Deep Saini on 25/08/24.
//

import SwiftUI

@main
struct FourInOneGameAppApp: App {
    @StateObject private var settings = AppSettings()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
        }
    }
}
