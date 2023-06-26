//
//  ClassDetails.swift
//  Course Builder
//
//  Created by Albert on 3/23/23.
//

import SwiftUI

//MARK: way to see more information of a given class. 
struct ClassDetails: View {
    let course: Course
    
    var body: some View {
        Text("Course Details")
            .font(.title)
            .foregroundColor(.accentColor)
            .padding()
        List{
            Section(header: Text("course details")) {
                Text("Catalog Number: \(course.catalog_nbr ?? "-")")
                    .foregroundColor(Color(UIColor(named: "lightAccent")!))
                Text("Course Title: \(course.course_title_long ?? "-")")
                    .foregroundColor(Color(UIColor(named: "lightAccent")!))
                Text("ssr_crse_typoff_cd: \(course.ssr_crse_typoff_cd ?? "-")")
                    .foregroundColor(Color(UIColor(named: "lightAccent")!))
                Text("ssr_crse_typoff_cd_lov_descr: \(course.ssr_crse_typoff_cd_lov_descr ?? "-")")
                    .foregroundColor(Color(UIColor(named: "lightAccent")!))
            }
            
            
            Section(header: Text("graduation details")) {
                Text("flags: ")
                    .foregroundColor(Color(UIColor(named: "lightAccent")!))
                ForEach(Array(course.flags.keys), id: \.self){flagname in
                    if course.flags[flagname]!{
                        Text(" - \(flagname)")
                            .foregroundColor(Color(UIColor(named: "lightAccent")!))
                    }
                }
            }
            
            Section(header: Text("campus + department details")) {
                Text("Institution: \(course.institution ?? "-")")
                    .foregroundColor(Color(UIColor(named: "lightAccent")!))
                Text("Institution Description: \(course.institution_lov_descr ?? "-")")
                    .foregroundColor(Color(UIColor(named: "lightAccent")!))
                Text("Subject: \(course.subject ?? "-")")
                    .foregroundColor(Color(UIColor(named: "lightAccent")!))
                Text("subject_lov_descr: \(course.subject_lov_descr ?? "-")")
                    .foregroundColor(Color(UIColor(named: "lightAccent")!))
            }
            
            Section(header: Text("course id details")) {
                Text("Course ID: \(course.crse_id ?? "-")")
                    .foregroundColor(Color(UIColor(named: "lightAccent")!))
                Text("Course ID Description: \(course.crse_id_lov_descr ?? "-")")
                    .foregroundColor(Color(UIColor(named: "lightAccent")!))
                Text("effdt: \(course.effdt ?? "-")")
                    .foregroundColor(Color(UIColor(named: "lightAccent")!))
                Text("Course Offer Number: \(course.crse_offer_nbr ?? "-")")
                    .foregroundColor(Color(UIColor(named: "lightAccent")!))
            }
            
            Section(header: Text("misc details")) {
                Text("Message Text: \(course.msg_text ?? "-")")
                    .foregroundColor(Color(UIColor(named: "lightAccent")!))
                Text("Multiple Offerings: \(course.multi_off ?? "-")")
                    .foregroundColor(Color(UIColor(named: "lightAccent")!))
                Text("Course Topic ID: \(course.crs_topic_id ?? "-")")
                    .foregroundColor(Color(UIColor(named: "lightAccent")!))
                Text("Course Offering Summaries: \(course.course_off_summaries ?? "-")")
                    .foregroundColor(Color(UIColor(named: "lightAccent")!))
            }
        }
    }
}

struct ClassDetails_Previews: PreviewProvider {
    static var previews: some View {
        ClassDetails(course: Course())
    }
}
