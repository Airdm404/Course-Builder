//
//  GridCell.swift
//  Course Builder
//
//  Created by Edem Ahorlu on 4/9/23.
//

import SwiftUI

//MARK: cell to drag and drop classes
struct GridCell: View {
    var active: Bool
    var course: Course?
    @State private var showingDetails = false
    
    var body: some View {
        
        let cls = Text("\(course?.subject ?? "") \(course?.catalog_nbr ?? "")")
            .foregroundColor(Color.accentColor)

        return Rectangle()
            .fill(self.active ? Color(UIColor(named: "grayAccent")!) : course != nil ? getColor() : Color.white)
            .overlay(cls)
            .cornerRadius(8)
            .shadow(radius: 2, x: 0, y: 3)
            .onTapGesture {
                self.showingDetails.toggle()
            }
            .sheet(isPresented: $showingDetails) {
                ClassDetails(course: course ?? Course())
            }
    }
    
    //MARK: depending on the type of class, color the grid cell a different color
    func getColor() -> Color {
        if REQUIREDCLASSES.contains(course!) {
            return Color(red: 0, green: 180/255, blue: 216/255)
        }
        return Color(red: 144/255, green: 224/255, blue: 239/255)
    }
}

struct GridCell_Previews: PreviewProvider {
    static var isActive = true
    static var course = Course(subject: "COMPSCI", catalog_nbr: "101", course_title_long: "Intro to CS")
    static var previews: some View {
        GridCell(active: isActive, course: course)
    }
}
