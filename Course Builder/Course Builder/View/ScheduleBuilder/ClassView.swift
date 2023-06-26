//
//  Class.swift
//  Course Builder
//
//  Created by Albert on 3/16/23.
//  Modified by Edem

import SwiftUI
import MobileCoreServices

//MARK: shows a preview of a class. shows subject, course number, and name.
struct ClassView: View {
    var course: Course
    
    var body: some View {
        NavigationLink(destination: ClassDetails(course: course)) {
            getText()
                .foregroundColor(Color(UIColor(named: "lightAccent")!))
            //MARK: copies data of class on drag
                .onDrag {
                    let itemProvider = NSItemProvider()
                    itemProvider.registerDataRepresentation(forTypeIdentifier: kUTTypeJSON as String, visibility: .all) { completion in
                        let encoder = JSONEncoder()
                        if let data = try? encoder.encode(course) {
                            completion(data, nil)
                        } else {
                            completion(nil, NSError(domain: "encodingError", code: 0))
                        }
                        return nil
                    }
                    return itemProvider
                }
        }
    }
    
    //MARK: based on what information is available, decide what the display as the course text
    func getText() -> Text {
        return course.catalog_nbr == nil ? Text("\(course.subject ?? "") \(course.catalog_nbr ?? "##"): \(course.course_title_long ?? "##")") : Text("\(course.subject ?? "") \(course.catalog_nbr ?? "##"): \(course.course_title_long ?? "##")")
    }
}

struct ClassView_Previews_wrapper : View {
    var body: some View {
        let c: Course = Course()
        ClassView(course: c)
    }
}

struct ClassView_Previews: PreviewProvider {
    static var previews: some View {
        ClassView_Previews_wrapper()
    }
}
