//
//  APIutils.swift
//  Course Builder
//
//  Created by Albert on 3/17/23.
//

import Foundation

//MARK: api key for the duke dev console
let APIKEY = "1325bd812cb5da16670370d470fa315d"
let departmentURL = "https://streamer.oit.duke.edu/curriculum/courses/subject"
//MARK: file for all of the subject options
var SUBJECTS = Bundle.main.url(forResource: "subjects", withExtension: "json")!

//MARK: class for handling course searches
class APIrequestor: NSObject, ObservableObject, URLSessionDownloadDelegate{
    //MARK: singleton for getting the api requestor
    static let getRequestor = APIrequestor()
    //MARK: static list of subjects to search with
    static let allsubjects = APIrequestor.getSubjects()
    
    var currSubject: String = APIrequestor.allsubjects[0]
    @Published var data = [Course]()
    //MARK: will be 'loading' or 'done'. shown in search view
    @Published var status = ""
    
    //MARK: given a string, search for subjects with that prefix
    func filterSubjects(search: String) -> [String]{
        var ret = [String]()
        for i in APIrequestor.allsubjects{
            if i.lowercased().hasPrefix(search.lowercased()){
                ret.append(i)
            }
        }
        return ret
    }
    
    //MARK: return list of searched courses
    func getCourses() -> [Course]{
        return data
    }
    
    //MARK: return list of searched courses but also check that each course is not already in the required/elective class containers
    func getCourses(existingCourses: [Course]) -> [Course]{
        var prunedData = [Course]()
        for i in data{
            if REQUIREDCLASSES.contains(i) || existingCourses.contains(i){
                continue
            }
            prunedData.append(i)
            
        }
        return prunedData
    }
    
    //MARK: set currSubject
    func setCurrSubject(_ subject: String){
        currSubject = subject
    }

    //MARK: function for getting a url session
    func getSession() -> URLSession {
        let session : URLSession = {
            let config = URLSessionConfiguration.ephemeral
            config.allowsCellularAccess = false
            let session = URLSession(configuration: config, delegate: self, delegateQueue: .main)
            return session
        }()
        return session
    }
    
    //MARK: search function
    func getBySubject(){
        let session = getSession()
        let req = requestType(getType: "bySubject", args: currSubject)!
        let task = session.downloadTask(with: req)
        status = "Loading..."
        task.resume()
    }
    
    //MARK: completion handler for searching. if no classes found, populate self.data with an empty Course. Else create Course objects from the RawCourse objects that were decoded by JSONDecoder()
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        if let d = try? Data(contentsOf: location){
            if let json = try? JSONDecoder().decode(SubjectSearch.self, from: d){
                let courses = json.ssr_get_courses_resp.course_search_result.subjects.subject.course_summaries
                if courses == nil{
                    self.data = [Course(course_title_long: "No Classes Found")]
                }else{
                    DispatchQueue.main.async {
                        var temp = [Course]()
                        for i in courses!.course_summary{
                            temp.append(Course(
                                crse_id: i.crse_id,
                                crse_id_lov_descr: i.crse_id_lov_descr,
                                effdt: i.effdt,
                                crse_offer_nbr: i.crse_offer_nbr,
                                institution: i.institution,
                                institution_lov_descr: i.institution_lov_descr,
                                subject: i.subject,
                                subject_lov_descr: i.subject_lov_descr,
                                catalog_nbr: i.catalog_nbr,
                                course_title_long: i.course_title_long,
                                ssr_crse_typoff_cd: i.ssr_crse_typoff_cd,
                                ssr_crse_typoff_cd_lov_descr: i.ssr_crse_typoff_cd_lov_descr,
                                msg_text: i.msg_text,
                                multi_off: i.multi_off,
                                crs_topic_id: i.crs_topic_id,
                                course_off_summaries: i.course_off_summaries
                            ))
                        }
                        self.data = temp
                    }
                }
            }else{
                self.data = [Course(course_title_long: "Failed to Decode")]
            }
        }else{
            self.data = [Course(course_title_long: "Failed to Fetch Data")]
        }
        self.status = ""
        
    }
    
    //MARK: function for converting search args into a http request url
    func requestType(getType: String, args:String...) -> URLRequest?{
        let url : URL?
        var req : URLRequest
        switch getType{
        case "bySubject":
            var builtURL = departmentURL
            for arg in args{
                builtURL += "/\(arg.replacingOccurrences(of: " ", with: "%20"))"
            }
            builtURL += "?access_token=\(APIKEY)"
            url = URL(string: builtURL)
            req = URLRequest(url: url!)
            req.httpMethod = "GET"
            
        default:
            return nil
        }
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return req
    }
    
    //MARK: static function for decoding /model/subject.json into a list of Subjects
    static func getSubjects() -> [String]{
        do {
            let d = try Data(contentsOf: SUBJECTS)
            var list = [String]()
            if let decoded = try?
                JSONDecoder().decode([Subject].self, from: d) {
                for i in decoded{
                    list.append("\(i.code) - \(i.desc)")
                }
            }
            return list
        } catch{
            print("error finding file with subject names \(error)")
            return [String]()
        }
    }
    
}

