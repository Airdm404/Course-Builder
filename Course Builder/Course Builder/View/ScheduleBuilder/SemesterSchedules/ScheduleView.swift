//
//  Schedule.swift
//  Course Builder
//
//  Created by Albert on 3/16/23.
//  Modified by Edem

import SwiftUI

//MARK: view for a single semester where classes can be updated
struct ScheduleView: View {
    @Binding var classes: [Int: Course]
    @State private var active = 0
    @Binding var electiveClasses: [Course]
    @Binding var requiredClasses: [Course]
    var idx: Int
    
    var body: some View {
        GeometryReader { geometry in
            Color(red: 242/255, green: 242/255, blue: 242/255)
            VStack {
                HStack {
                    Text("Semester \(idx)")
                        .foregroundColor(Color(UIColor(named: "lightAccent")!))
                        .font(.title)
                }
                .padding(.top)
                List{
                    ForEach(0..<5) { row in
                        GridCell(active: self.active == (row + 1), course: classes[row + 1])
                            .onDrop(of: [.text], delegate: MyDropDelegate(classes: $classes, active: $active, gridPosition: row + 1, electiveClasses: $electiveClasses, requiredClasses: $requiredClasses))
                            .onLongPressGesture(minimumDuration: 1){
                                if let course = classes[row + 1] {
                                    if REQUIREDCLASSES.contains(course) {
                                        requiredClasses.append(course)
                                    } else {
                                        electiveClasses.append(course)
                                    }
                                    classes[row + 1] = nil
                                }
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    if let course = classes[row + 1] {
                                        if REQUIREDCLASSES.contains(course) {
                                            requiredClasses.append(course)
                                        } else {
                                            electiveClasses.append(course)
                                        }
                                        classes[row + 1] = nil
                                    }
                                } label: {
                                    Label("", systemImage: "minus")
                                }
                                .tint(.red)
                            }
                    }
                }
                .frame(height: 270)
                
            }
        }
        .cornerRadius(20)
        .scaledToFit()
        .shadow(radius: 5, x: 0, y: 5)
    }
}

//class details will not work here because no navigation stack
struct ScheduleView_Previews: PreviewProvider {
    @State static var classes: [Course] = [Course(crse_id: "idk")]
    @State static var semester: [Int: Course] = [1:Course(crse_id: "idk")]
    static var previews: some View {
        ScheduleView(classes: $semester, electiveClasses: $classes, requiredClasses: $classes, idx: 1)
    }
}
