//
//  ElectiveClassesContainer.swift
//  Course Builder
//
//  Created by Albert on 3/16/23.
//  Modified by Edem

import SwiftUI

//MARK: container for selected elective classes.
struct ElectiveClassesContainer: View {
    @Binding var classes: [Course]
    var body: some View {
        NavigationStack{
            VStack{
                //MARK: button to go to search view
                HStack{
                    Text("Elective Classes")
                        .foregroundColor(.accentColor)
                        .font(.title2)
                        .padding(.top)
                    NavigationLink{
                        SearchView(selected: $classes)
                    } label: {
                        Label("", systemImage: "plus")
                            .foregroundColor(Color(UIColor(named: "lightAccent")!))
                    }
                    .padding(.top)
                }
                List{
                    if classes.count == 0{
                        //MARK: invisible spacer so this view appears visually even if it's empty
                        Spacer()
                            .listRowBackground(Color.clear)
                    } else {
                        ForEach($classes, id: \.self){ course in
                            //MARK: buttons that show more details about the class. swipe to remove the class
                            ClassView(course: course.wrappedValue)
                                .swipeActions{
                                    Button(role: .destructive){
                                        classes.remove(at: classes.firstIndex(of: course.wrappedValue)!)
                                        
                                    } label: {
                                        Label("", systemImage: "minus")
                                    }
                                    .tint(.red)
                                }
                        }
                    }
                }
            }
            .background(Color(red: 144/255, green: 224/255, blue: 239/255))
            .cornerRadius(20)
            .shadow(radius: 5, x: 0, y: 5)
        }
    }
}
struct ElectiveClassesContainer_Previews_wrapper : View {
    @State var classes = [Course(), Course()]
    var body: some View {
        ElectiveClassesContainer(classes: $classes)
    }
}

struct ElectiveClassesContainer_Previews: PreviewProvider {
    static var previews: some View {
        ElectiveClassesContainer_Previews_wrapper()
    }
}
