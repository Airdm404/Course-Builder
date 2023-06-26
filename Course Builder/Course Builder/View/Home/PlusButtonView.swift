//
//  PlusButtonView.swift
//  Course Builder
//
//  Created by Cynthia Z France on 4/22/23.
//

import SwiftUI

struct PlusButtonView: View {
    var body: some View {
        ZStack {
            //MARK: a circular plus view (when pressed, will allow user to create a new schedule)
            Circle()
                .frame(width: 100, height: 100)
                .foregroundColor(.accentColor)
            Image(systemName: "plus.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(Color(UIColor(named: "grayAccent")!))
                .clipShape(Circle())
                .overlay {
                    Circle().stroke(.gray, lineWidth: 4)
                }
                .shadow(radius: 7)
                .opacity(1)
        }
    }
}

struct PlusButtonView_Previews: PreviewProvider {
    static var previews: some View {
        PlusButtonView()
    }
}
