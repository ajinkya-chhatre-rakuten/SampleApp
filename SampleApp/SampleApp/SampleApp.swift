//
//  SampleAppApp.swift
//  SampleApp
//
//  Created by Chhatre, Ajinkya | RIEPL on 23/11/22.
//

import SwiftUI

@main
struct SampleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
