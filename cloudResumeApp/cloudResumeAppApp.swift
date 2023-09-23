//
//  cloudResumeAppApp.swift
//  cloudResumeApp
//
//  Created by Sosa on 9/20/23.
//
import SwiftUI

@main
struct cloudResumeAppApp: App {
    var backend: Backend = Backend.shared // Initialize the Backend singleton
    
    init() {
        print("Backend initialized")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
