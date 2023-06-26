//
//  DataModel.swift
//  Course Builder
//
//  Created by Loaner on 3/30/23.
//

import Foundation

class DataModel: ObservableObject{
    static let getModel =  DataModel()
    
    @Published var schedules = ["test": Plan(name: "test", description: "", program: "MEng")]
    func getSchedules() -> [Plan]{
        var list = [Plan]()
        for i in schedules.values{
            list.append(i)
        }
        return list
    }
    func save(program: String, name: String, description: String, oldname: String) -> Bool{
        print("save: ")
        print("name \(name)")
        print("program \(program)")
        print("description \(description)")
        print("oldname\(oldname)")
        print("-----")
        
        if oldname.count == 0{
            return false
        }
        schedules[name] = Plan(name: name, description: description, program: program)
        print(schedules)
        return true
    }
    
    func deleteSchedule(name: String){
        print("delete: ")
        print("oldname\(name)")
        print("-----")
        
        schedules.removeValue(forKey: name)
        print(schedules)
    }
    
    func checkScheduleName(name:String, oldname: String) -> Bool{
        print("checking \(name)")
        print("oldname \(oldname)")
        
        if name.count == 0 {
            return false
        }
        if name == oldname{
            return true
        }
        if schedules.keys.contains(name){
            return false
        }
        return true
    }
}
