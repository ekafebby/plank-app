//
//  PlankMateApp.swift
//  PlankMate
//
//  Created by Eka Feby Ronauli Lubis on 19/04/26.
//

import SwiftUI

@main
struct PlankMateApp: App {
    @AppStorage("hasSeenIntro") var hasSeenIntro: Bool = false
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if !hasSeenIntro {
                    OnboardView(hasSeenIntro: $hasSeenIntro)
                } else {
                    HomeView()
                }
            }
        }
    }
}
