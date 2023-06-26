//
//  SearchView.swift
//  Course Builder
//
//  Created by Albert on 3/15/23.
//

import SwiftUI

//MARK: View for searching for classes to add as electives
struct SearchView: View {
    @State var instructor = ""
    @State var keyword = ""
    @State var subject = APIrequestor.allsubjects[0]
    @Binding var selected: [Course]

    @ObservedObject var requestor: APIrequestor = APIrequestor.getRequestor

    
    var body: some View {
            
        NavigationStack{
            VStack{
                Text("Search Electives")
                    .font(.title)
                    .foregroundColor(.accentColor)
                Text(requestor.status)
                    .font(.subheadline)
                //MARK: a button that is used to change the subject to search with
                SearchSubjects(subject: $subject, requestor: requestor)
                    .onChange(of: subject) { subjName in
                        requestor.setCurrSubject(subjName)
                        requestor.getBySubject()
                    }
                    .onAppear{
                        requestor.getBySubject()
                    }
                List{
                    //MARK: list of all the classes for a given subject
                    ForEach(requestor.getCourses(existingCourses: selected), id: \.self) { course in
                        ClassView(course: course)
                            .swipeActions{
                                //MARK: ensure that empty/nil classes can be clicked on
                                if course.catalog_nbr != nil{
                                    Button(role: .destructive){
                                        selected.append(course)
                                    }label:{
                                        Label("", systemImage: "plus")
                                    }
                                    .tint(.green)
                                }
                            }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SearchView_Previews_wrapper : View {
    @State var classes = [Course(), Course()]
    var body: some View {
        SearchView(selected: $classes)
    }
}
struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView_Previews_wrapper()
    }
}
