//
//  MyDropDelegate.swift
//  Course Builder
//
//  Created by Edem Ahorlu on 4/9/23.
//

import SwiftUI
import MobileCoreServices

//MARK: handles dropping of classes into gridcells
struct MyDropDelegate: DropDelegate {
    @Binding var classes: [Int: Course]
    @Binding var active: Int
    let gridPosition: Int
    @Binding var electiveClasses: [Course]
    @Binding var requiredClasses: [Course]
    
    
    func validateDrop(info: DropInfo) -> Bool {
        return info.hasItemsConforming(to: [.text])
    }
    
    func performDrop(info: DropInfo) -> Bool {
        self.active = gridPosition

        if let item = info.itemProviders(for: [.json]).first {
            item.loadDataRepresentation(forTypeIdentifier: kUTTypeJSON as String) { (data, error) in
                DispatchQueue.main.async {
                    if let data = data {
                        let decoder = JSONDecoder()
                        if let course = try? decoder.decode(Course.self, from: data) {
                            if let oldcourse = self.classes[gridPosition] {
                                if REQUIREDCLASSES.contains(oldcourse) {
                                    requiredClasses.append(oldcourse)
                                } else {
                                    electiveClasses.append(oldcourse)
                                }
                            }
                            self.classes[gridPosition] = course
                            if let index = electiveClasses.firstIndex(where: { $0 == course }) {
                                electiveClasses.remove(at: index)
                            }
                            if let index = requiredClasses.firstIndex(where: { $0 == course }) {
                                requiredClasses.remove(at: index)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                                self.active = 0
                            }
                        }
                    }
                }
            }
            return true
        } else {
            return false
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        self.active = gridPosition
        return nil
    }

    func dropExited(info: DropInfo) {
        self.active = 0
    }
}
