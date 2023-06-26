//
//  ScheduleCapsuleView.swift
//  Course Builder
//
//  Created by Cynthia Z France on 4/22/23.
//

import SwiftUI

struct ScheduleCapsuleView: View {
    var schedule: Schedule
    @EnvironmentObject var schedules: ScheduleModel
    var body: some View {
        HStack {
            //MARK: Provides a preview of the schedule corresponding to this capsule (schedule name, program, num semesters, num classes)
            VStack(alignment: .leading) {
                Text(schedule.name)
                    .font(.title3)
                    .bold()
                    .foregroundColor(.accentColor)
                Text("program: \(schedule.program.rawValue)")
                    .font(.subheadline)
                    .foregroundColor(Color(UIColor(named: "lightAccent")!))
                Text("semesters: \(schedule.semesters.count)")
                    .font(.subheadline)
                    .foregroundColor(Color(UIColor(named: "lightAccent")!))
                Text("classes scheduled: \(getCount(semesters: schedule.semesters))")
                    .font(.subheadline)
                    .foregroundColor(Color(UIColor(named: "lightAccent")!))
            }
            Spacer()
        }
        .padding(20)
        .background(Color(UIColor(named: "grayAccent")!))
        .contentShape(Rectangle())
        .cornerRadius(20)
        .shadow(radius: 5, x: 0, y: 5)
        .swipeActions {
            //MARK: swiping deletes the schedule from the database
            Button(role: .destructive){
                schedules.deleteSchedule(id: schedule.id)
                schedules.save()
            }label:{
                Label("", systemImage: "trash")
            }
            .tint(.red)
            
        }
    }
}

//MARK: get the number of total classes planned 
func getCount(semesters: [[Int: Course]]) -> Int {
    print("schedule")
    var total: Int = 0
    semesters.forEach { semester in
        total = total + semester.count
    }
    return total
}

struct ScheduleCapsuleView_Previews: PreviewProvider {
    static var previews: some View {
        let schedule = Schedule(name: "sched", desc: "", program: .Software)
        ScheduleCapsuleView(schedule: schedule)
    }
}
