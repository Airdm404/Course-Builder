//
//  PDFView.swift
//  Course Builder
//
//  Created by Cynthia Z France on 4/13/23.
//


import SwiftUI

let w = 595.28
let h = 841.89

struct PDFView: View {
    var schedule: Schedule
    var body: some View {
        VStack(spacing: 15) {
            VStack {
                //MARK: lists preliminary schedule information
                Text(schedule.name)
                    .font(.title)
                    .foregroundColor(Color(red: 0.004, green: 0.133, blue: 0.412))
                Text(schedule.program.rawValue)
                    .font(.subheadline)
                    .foregroundColor(Color(red: 0, green: 0.243, blue: 0.725))
            }
            VStack(alignment: .leading, spacing: 5) {
                //MARK: Lists the classes planned under each semester as a block/capsule
                ForEach(schedule.semesters, id: \.self) { semester in
                    HStack {
                        VStack {
                            HStack {
                                Text("Semester")
                                    .font(.title2)
                                    .foregroundColor(Color(red: 0.004, green: 0.133, blue: 0.412))
                                Spacer()
                            }
                            HStack {
                                VStack(alignment: .leading) {
                                    ForEach(semester.keys.sorted(), id: \.self) { key in
                                        Text(semester[key]!.course_title_long!)
                                            .font(.subheadline)
                                            .foregroundColor(Color(red: 0, green: 0.243, blue: 0.725))
                                    }
                                }
                                Spacer()
                            }
                        }
                        Spacer()
                    }
                    .padding(20)
                    .background(Color(red: 0.9, green: 0.9, blue: 0.9))
                    .contentShape(Rectangle())
                    .cornerRadius(20)
                }
            }
        }
        .frame(width: w, height: h)
        .shadow(radius: 5, x: 0, y: 5)
    }
}

struct PDFView_Previews: PreviewProvider {
    static var schedule = Schedule(name: "idk", desc: "idk", program: .Data)
    static var previews: some View {
        PDFView(schedule: schedule)
    }
}
