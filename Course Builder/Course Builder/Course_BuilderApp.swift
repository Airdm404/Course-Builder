//
//  Course_BuilderApp.swift
//  Course Builder
//
//  Created by Albert on 3/15/23.
//

import SwiftUI

@main
struct Course_BuilderApp: App {
    @StateObject private var schedules = ScheduleModel.instance
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(schedules)
                .onAppear {
                    schedules.load()
                }
        }
    }
}
