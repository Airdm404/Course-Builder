//
//  HomePage.swift
//  Course Builder
//
//  Created by Albert on 3/15/23.
//

import SwiftUI

//MARK: main view that the user sees. displays an option to create a new schedule, displays existing schedules, and allows the user to delete or view existing schedules
struct HomeView: View {
    @EnvironmentObject var schedules: ScheduleModel
    @State private var goToAddSchedule = false
    @State private var currSchedule: Schedule? = nil
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                Section {
                    //MARK: button to make a new schedule from scratch
                    Image("duke logo")
                        .resizable()
                        .ignoresSafeArea(edges: [.trailing, .leading])
                        .aspectRatio(contentMode: .fit)
                    Button {
                        goToAddSchedule.toggle()
                    } label: {
                        PlusButtonView()
                            .offset(y: -60)
                            .padding(.bottom, -60)
                    }
                    .fullScreenCover(isPresented: $goToAddSchedule){
                        //Use fullscreen so that we can reset navi stack for sidebar
                        EditView(schedule: Schedule(), selection: Programs.allCases[0], newName: "", requiredClasses: REQUIREDCLASSES, electiveClasses: [Course]())
                            .environmentObject(schedules)
                    }
                }
                List {
                    Section(header: Text("saved schedules")) {
                        //MARK: list of existing schedules that are already made
                        ForEach(schedules.database) { schedule in
                            Button {
                                currSchedule = schedule
                            } label: {
                                ScheduleCapsuleView(schedule: schedule)
                            }
                            .fullScreenCover(item: $currSchedule){ sched in
                                //Use fullscreen so that we can reset navi stack for sidebar
                                EditView(schedule: sched, selection: sched.program, newName: sched.name, requiredClasses: sched.required, electiveClasses: sched.backpack)
                                    .environmentObject(schedules)
                                    .onDisappear{
                                        schedules.load()
                                    }
                            }
                        }
                    }
                }
                .navigationTitle("Course Builder")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

struct HomeView_Previews_wrapper : View {
    
    func preview(model: ScheduleModel) -> ScheduleModel {
        let a = [Schedule(name: "test", desc: "?", program: Programs.allCases[0]), Schedule(name: "test2", desc: "?", program: Programs.allCases[0])]
        model.database = a
        return model
    }
    
    var body: some View {
        
        HomeView()
            .environmentObject(preview(model: ScheduleModel.instance))
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView_Previews_wrapper()
    }
}
