//
//  RequiredClassesContainer.swift
//  Course Builder
//
//  Created by Albert on 3/16/23.
//

import SwiftUI
//MARK: container for all of the required classes.
struct RequiredClassesContainer: View {
    @Binding var classes: [Course]
    var body: some View {
        VStack{
            Text("Required Classes")
                .foregroundColor(.accentColor)
                .font(.title2)
                .padding(.top)
            List{
                if classes.count == 0 {
                    //MARK: invisible spacer so this view appears visually even if it's empty
                    Spacer()
                        .listRowBackground(Color.clear)
                } else {
                    ForEach($classes, id: \.self){ course in
                        ClassView(course: course.wrappedValue)
                    }
                }
            }
            
        }
        .background(Color(red: 0, green: 180/255, blue: 216/255))
        .cornerRadius(20)
        .shadow(radius: 5, x: 0, y: 5)
    }
}

struct RequiredClassesContainer_Previews_wrapper : View {
    @State var classes = [Course(), Course()]
    var body: some View {
        RequiredClassesContainer(classes: $classes)
    }
}

struct RequiredClassesContainer_Previews: PreviewProvider {
    static var previews: some View {
        RequiredClassesContainer_Previews_wrapper()
    }
}
