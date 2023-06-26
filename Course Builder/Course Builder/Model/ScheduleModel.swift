//
//  ScheduleModel.swift
//  Course Builder
//
//  Created by Cynthia Z France on 3/28/23.
//  Modified by Edem

import Foundation
import UIKit

class ScheduleModel: NSObject, ObservableObject {
    static let instance = ScheduleModel()
    
    //MARK: database of schedules saved
    @Published var database: [Schedule] = [Schedule]()
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    let databaseURL = DocumentsDirectory.appendingPathComponent("scheduleDatabase.json")
    
    //MARK: displays the database
    func showDatabase(){
        for schedule in database{
            schedule.display()
        }
    }
    //MARK: add schedule to the database
    func addSchedule(schedule: Schedule) {
        for (idx, sched) in database.enumerated(){
            if sched.id == schedule.id{
                database.remove(at: idx)
                break
            }
        }
        database.append(schedule)
    }
    
    //MARK: delete schedule from database
    func deleteSchedule(id: String) -> Bool {
        for i in 0..<database.count {
            if (database[i].id == id) {
                database.remove(at: i)
                save()
                return true
            }
        }
        return false
    }
    
    //MARK: check if the schedule has a value name
    func checkValidScheduleName(name: String, newname: String) -> Bool{
        if newname.count == 0 { //empty name
            return false
        }else if name == newname{ //case when no change to name
            return true
            //else check if newname is already taken
        }
        for sched in database{
            if sched.name == newname{
                return false
            }
        }
        return true
    }
    
    //MARK: load schedules from file
    func load() -> Bool {
        let tempData: Data
        do {
           tempData = try Data(contentsOf: databaseURL)
        } catch _ as NSError {
            do {
                let bundle: Bundle = .main
                if let defaultData = bundle.url(forResource: "scheduleDatabase", withExtension: "json") {
                    tempData = try Data(contentsOf: defaultData)
                }
                else {
                    return false
                }
            } catch let error as NSError {
                print("error finding database file \(error)")
                return false
            }
        }
        
        return decode(data: tempData)
    }
    
    //MARK: decode file
    func decode(data: Data) -> Bool {
        self.database = [Schedule]()
        if let decoded = try? JSONDecoder().decode([Schedule].self, from: data) {
            for schedule in decoded {
                self.database.append(schedule)
            }
            return true
        } else {
            return false
        }
    }
    
    //MARK: save database to file
    func save() -> Bool {
        var outputData = Data()
        let encoder = JSONEncoder()
    
        if let encoded = try? encoder.encode(database) {
            if let _ = String(data: encoded, encoding: .utf8) {
                outputData = encoded
            }
            else { return false }
            
            do {
                try outputData.write(to: databaseURL)
            } catch let error as NSError {
                print ("error writing to database file \(error)")
                return false
            }
            return true
        }
        else { return false }
    }
}
