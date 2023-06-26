//
//  ScheduleContainer.swift
//  Course Builder
//
//  Created by Albert on 3/16/23.
//  Modified by Edem

import SwiftUI

//MARK: container for all of the schdeule views
struct ScheduleContainer: View {
    @Binding var schedule: Schedule
    @EnvironmentObject var schedules: ScheduleModel
    @Binding var electiveClasses: [Course]
    @Binding var requiredClasses: [Course]

    var body: some View {
        VStack {
            //MARK: button to add a semester
            Button {
                schedule.semesters.append([:])
                schedules.addSchedule(schedule: schedule)
            } label: {
                Label("Add Semester", systemImage: "calendar.badge.plus")
                    .foregroundColor(Color(UIColor(named: "lightAccent")!))
                    .font(.title3)
            }
            ScrollView(.horizontal) {
                HStack(spacing: 20) {
                    ForEach(Array(schedule.semesters.enumerated()), id: \.offset) { index, _ in
                        ScheduleView(classes: Binding(get: {
                            schedule.semesters[index]
                        }, set: { newValue in
                            schedule.semesters[index] = newValue
                        }), electiveClasses: $electiveClasses, requiredClasses: $requiredClasses,
                            idx: index+1)
                    }
                }
                .padding()
            }
        }
    }
}

struct ScheduleContainer_Previews: PreviewProvider {
    @State static var schedule = Schedule(name: "idk", desc: "idk", program: Programs.allCases[0])
    @State static var classes: [Course] = [Course(crse_id: "idk")]
    static var previews: some View {
        ScheduleContainer(schedule: $schedule, electiveClasses: $classes, requiredClasses: $classes)
            .environmentObject(ScheduleModel.instance)
    }
}
