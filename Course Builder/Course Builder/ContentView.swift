//
//  ContentView.swift
//  Course Builder
//
//  Created by Albert on 3/15/23.
//  

import SwiftUI

//MARK: Content view is included just in case any build settings were modified
struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        HomeView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ScheduleModel.instance)
        
    }
}
