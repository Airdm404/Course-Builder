//
//  SearchBar.swift
//  Course Builder
//
//  Created by Albert on 4/5/23.
//

import SwiftUI

//MARK: way to search subjects. when clicked, a sheet will pop up with available subjects. subjects can be searched.
struct SearchSubjects: View {
    @Binding var subject: String
    
    @State var searchText: String = ""
    @State var search: Bool = false
    @ObservedObject var requestor: APIrequestor

    var body: some View {
        Button{
            search.toggle()
        }label: {
            HStack {
                Text(subject)
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .padding(.leading, 8)
        
            }
                
        }
        .sheet(isPresented: $search){
            List{
                Section{
                    //MARK: search bar for filtering a subject
                    TextField("Search Subject", text: $searchText)
                }
                Section{
                    //MARK: case when a search is inputted. calls filtersubjects instead of allsubjects
                    if self.searchText != "" {
                        ForEach(requestor.filterSubjects(search: self.searchText), id: \.self){subject in
                                Button{
                                    self.subject = subject
                                    self.search.toggle()
                                    self.searchText = ""
                                }label:{
                                    //MARK: display a checkmark next to the subject that is currently selected
                                    if self.subject == subject{
                                        HStack{
                                            Text(subject)
                                            Spacer()
                                            Image(systemName: "checkmark")
                                        }
                                    }else{
                                        Text(subject)
                                    }
                                }
                            }
                    //MARK: case when search text is none, show all subjects
                    }else if self.searchText == "" {
                        ForEach(APIrequestor.allsubjects, id: \.self) { subject in
                            Button{
                                self.subject = subject
                                self.search.toggle()
                                self.searchText = ""
                            }label:{
                                if self.subject == subject{
                                    HStack{
                                        Text(subject)
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }else{
                                    Text(subject)
                                }
                            }
                        }
                    }
                }
            }
            
        }
    }
}
struct SearchSubjects_Previews_wrapper: View {
    @State var subject: String = APIrequestor.allsubjects[0]
    @ObservedObject var requestor: APIrequestor = APIrequestor.getRequestor

    var body: some View {
        SearchSubjects(subject: $subject, requestor: requestor)
    }
}


struct SearchSubjects_Previews: PreviewProvider {
    static var previews: some View {
        SearchSubjects_Previews_wrapper()
    }
}
