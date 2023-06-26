//
//  DataStructures.swift
//  Course Builder
//
//  Created by Albert on 3/17/23.
//  Modified by Edem

import Foundation

//MARK: struct for downloading from API
//https://app.quicktype.io/#l=go
struct SubjectSearch: Codable{
    let ssr_get_courses_resp: SsrGetCoursesResp
    
    struct SsrGetCoursesResp: Codable {
        let course_search_result: CourseSearchResult
        let xmlns: String

        enum CodingKeys: String, CodingKey {
            case xmlns = "@xmlns"
            case course_search_result
        }
    }
    
    struct CourseSearchResult: Codable {
        let ssr_crs_gen_msg: String?
        let ssr_crs_srch_count: String
        let subjects: Subjects
    }

    struct Subjects: Codable {
        let subject: Subject
    }

    struct Subject: Codable {
        let institution, institution_lov_descr, subject, subject_lov_descr: String
        let subject_crs_count: String
        let course_summaries: CourseSummaries?
    }
    struct CourseSummaries: Codable {
        let course_summary: [RawCourse]
    }
}

//MARK: course json as defined by duke dev console
struct RawCourse: Codable, Hashable{
    let crse_id, crse_id_lov_descr, effdt, crse_offer_nbr: String?
    let institution, institution_lov_descr, subject, subject_lov_descr: String?
    let catalog_nbr, course_title_long, ssr_crse_typoff_cd, ssr_crse_typoff_cd_lov_descr: String?
    let msg_text, multi_off, crs_topic_id, course_off_summaries: String?
}

//MARK: course json modifed to have flags (concentration,required,etc)
struct Course: Codable, Hashable {
    
    let crse_id, crse_id_lov_descr, effdt, crse_offer_nbr: String?
    let institution, institution_lov_descr, subject, subject_lov_descr: String?
    let catalog_nbr, course_title_long, ssr_crse_typoff_cd, ssr_crse_typoff_cd_lov_descr: String?
    let msg_text, multi_off, crs_topic_id, course_off_summaries: String?
    //var flags: [String : Bool]
    var flags = ["core": false,
                 "concentration": false,
                 Programs.Software.rawValue: false,
                 Programs.Hardware.rawValue: false,
                 Programs.Data.rawValue: false,
                 Programs.Quantum.rawValue: false,
                 Programs.Microelectronics.rawValue: false,
//                 "designYourOwn_conc": false, //prob dont include this
                 "internship": false,
                 "technical": false,
                 "general": true,
                 "credit": true
                ]
    
    //MARK: initializer allows us to make an empty course
    init(crse_id: String? = nil, crse_id_lov_descr: String? = nil, effdt: String? = nil, crse_offer_nbr: String? = nil,
         institution: String? = nil, institution_lov_descr: String? = nil, subject: String? = nil, subject_lov_descr: String? = nil,
         catalog_nbr: String? = nil, course_title_long: String? = nil, ssr_crse_typoff_cd: String? = nil, ssr_crse_typoff_cd_lov_descr: String? = nil,
         msg_text: String? = nil, multi_off: String? = nil, crs_topic_id: String? = nil, course_off_summaries: String? = nil) {
        self.crse_id = crse_id
        self.crse_id_lov_descr = crse_id_lov_descr
        self.effdt = effdt
        self.crse_offer_nbr = crse_offer_nbr
        
        self.institution = institution
        self.institution_lov_descr = institution_lov_descr
        self.subject = subject
        self.subject_lov_descr = subject_lov_descr
        
        self.catalog_nbr = catalog_nbr
        self.course_title_long = course_title_long
        self.ssr_crse_typoff_cd = ssr_crse_typoff_cd
        self.ssr_crse_typoff_cd_lov_descr = ssr_crse_typoff_cd_lov_descr
        
        self.msg_text = msg_text
        self.multi_off = multi_off
        self.crs_topic_id = crs_topic_id
        self.course_off_summaries = course_off_summaries
        
        checkReq()
    }
    
    //MARK: sets flags by checking ReqClasses.<TYPE>
    mutating func checkReq() {
        if self.catalog_nbr == nil{
            flags["general"] = false
            flags["credit"] = false
            return
        }

        if check(classes: ReqClasses.coreClasses) {

            flags["core"] = true
        }
        if check(classes: ReqClasses.internshipClasses) {
            flags["internship"] = true
            flags["credit"] = false
        }
        if check(classes: ReqClasses.technicalElectives){
            flags["technical"] = true
        }
        var conc = false
        if check(classes: ReqClasses.softwareClasses) {
            flags[Programs.Software.rawValue] = true
            conc = true
            
        }
        if check(classes: ReqClasses.hardwareClasses) {
            flags[Programs.Hardware.rawValue] = true
            conc = true
            
        }
        if check(classes: ReqClasses.dataClasses) {
            flags[Programs.Data.rawValue] = true
            conc = true
            
        }
        if check(classes: ReqClasses.quantumClasses) {
            flags[Programs.Quantum.rawValue] = true
            conc = true
            
        }
        if check(classes: ReqClasses.microelectronicsClasses) {
            flags[Programs.Microelectronics.rawValue] = true
            conc = true
        }
        if conc {
            flags["concentration"] = true
        }
    }
    
    //MARK: compares this class to the requirements list. if course subject, number, and title all match, return true
    func check(classes: [(String, String, String)]) -> Bool {
        for course in classes {
            if (self.subject!.trimmingCharacters(in: .whitespacesAndNewlines) == course.0 &&
                self.catalog_nbr!.trimmingCharacters(in: .whitespacesAndNewlines) == course.1
                && self.course_title_long!.trimmingCharacters(in: .whitespacesAndNewlines) == course.2) {
                return true
            }
        }
        return false
    }
}

//MARK: struct for a schedule. holds all of the information of a schedule.
class Schedule: Codable, Hashable, Equatable, Identifiable {
    static func == (lhs: Schedule, rhs: Schedule) -> Bool {
        return lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
            hasher.combine(id)
    }
    var name: String
    var desc: String
    let id: String
    var program: Programs
    var semesters: [[Int: Course]] = [[:]]
    var backpack: [Course] = []
    var required: [Course] = REQUIREDCLASSES
    
    //MARK: helper function for testing to see which classes are in a schedule.
    func display(){
        print("schedule: \(name)")
        for semester in semesters{
            print("   semester: \(semester)")
            for course in semester.values{
                print("      class: \(String(describing: course.subject)), \(String(describing: course.catalog_nbr)), \(String(describing: course.course_title_long))")
            }
        }
        print("   backpack:")
        for course in backpack{
            print("      class: \(String(describing: course.subject)), \(String(describing: course.catalog_nbr)), \(String(describing: course.course_title_long))")
        }
        print("   required:")
        for course in required{
            print("      class: \(String(describing: course.subject)), \(String(describing: course.catalog_nbr)), \(String(describing: course.course_title_long))")
        }
        
    }
    
    init(){
        self.id = UUID().uuidString
        self.name = ""
        self.desc = ""
        self.program = Programs.allCases[0]
    }
    init(name: String, desc: String, program: Programs) {
        self.id = UUID().uuidString
        self.name = name
        self.desc = desc
        self.program = program
    }
    
    init(name: String, desc: String, program: Programs, semesters: [[Int:Course]], backpack: [Course]) {
        self.id = UUID().uuidString
        self.name = name
        self.desc = desc
        self.program = program
        self.semesters = semesters
        self.backpack = backpack
    }
    
    func save(name: String, desc: String, program: Programs, semesters: [[Int:Course]], backpack: [Course], requiredClasses: [Course]) {
        self.name = name
        self.desc = desc
        self.program = program
        self.semesters = semesters
        self.backpack = backpack
        self.required = requiredClasses
    }
}

//MARK: struct for decoding /model/subjects.json file. how we get a list of subjects in subject search
struct Subject: Codable, Hashable {
    let code, desc: String
}

//MARK: struct for saving/loading schedules from persistant storage
struct Plan: Codable, Hashable{
    let name: String
    let description: String
    let program: String
}

//MARK: list of classes that all ECE MEng students need to take regardless of concentration
var REQUIREDCLASSES: [Course] = [
    Course(crse_id: "026731",
           crse_id_lov_descr: nil,
           effdt: "2022-01-01",
           crse_offer_nbr: "1",
           institution: "DUKEU",
           institution_lov_descr: "Duke University",
           subject: "MENG",
           subject_lov_descr: "Master of Engineering",
           catalog_nbr: " 540",
           course_title_long: "Management of High Tech Industries",
           ssr_crse_typoff_cd: "FALL-SPRNG",
           ssr_crse_typoff_cd_lov_descr: "Fall and/or Spring",
           msg_text: nil,
           multi_off: "N",
           crs_topic_id: "0",
           course_off_summaries: nil),
    Course(crse_id: "020325",
           crse_id_lov_descr: nil,
           effdt: "2012-08-13",
           crse_offer_nbr: "1",
           institution: "DUKEU",
           institution_lov_descr: "Duke University",
           subject: "MENG",
           subject_lov_descr: "Master of Engineering",
           catalog_nbr: " 570",
           course_title_long: "Business Fundamentals for Engineers",
           ssr_crse_typoff_cd: "FALL-SPRNG",
           ssr_crse_typoff_cd_lov_descr: "Fall and/or Spring",
           msg_text: nil,
           multi_off: "N",
           crs_topic_id: "0",
           course_off_summaries: nil),
    Course(crse_id: "020324",
           crse_id_lov_descr: nil,
           effdt: "2012-08-13",
           crse_offer_nbr: "1",
           institution: "DUKEU",
           institution_lov_descr: "Duke University",
           subject: "MENG",
           subject_lov_descr: "Master of Engineering",
           catalog_nbr: " 550",
           course_title_long: "Master of Engineering Internship/Project",
           ssr_crse_typoff_cd: "FA-SPR-SU",
           ssr_crse_typoff_cd_lov_descr: "Fall, Spring and Summer",
           msg_text: nil,
           multi_off: "N",
           crs_topic_id: "0",
           course_off_summaries: nil),
    Course(crse_id: "020357",
           crse_id_lov_descr: nil,
           effdt: "2012-08-13",
           crse_offer_nbr: "1",
           institution: "DUKEU",
           institution_lov_descr: "Duke University",
           subject: "MENG",
           subject_lov_descr: "Master of Engineering",
           catalog_nbr: " 551",
           course_title_long: "Master of Engineering Internship/Project Assessment",
           ssr_crse_typoff_cd: "FA-SPR-SU",
           ssr_crse_typoff_cd_lov_descr: "Fall, Spring and Summer",
           msg_text: nil,
           multi_off: "N",
           crs_topic_id: "0",
           course_off_summaries: nil)
]

//MARK: static lists of classes for graduation requirements.
struct ReqClasses: Codable, Hashable {
    static let coreClasses = [
        ("MENG","540","Management of High Tech Industries"),
        ("MENG","570", "Business Fundamentals for Engineers")
    ]
    
    static let internshipClasses = [
        (subject: "MENG", catalog_nbr: "550", course_title_long: "Master of Engineering Internship/Project"),
        (subject: "MENG", catalog_nbr: "551", course_title_long: "Master of Engineering Internship/Project Assessment")
    ]
    
    static let softwareClasses = [
        (subject: "ECE", catalog_nbr: "551D", course_title_long: "Programming, Data Structures, and Algorithms in C++"),
        (subject: "ECE", catalog_nbr: "550D", course_title_long: "Fundamentals of Computer Systems and Engineering"),
        (subject: "ECE", catalog_nbr: "651", course_title_long: "Software Engineering"),
        (subject: "ECE", catalog_nbr: "650", course_title_long: "Systems Programming and Engineering"),
        (subject: "ECE", catalog_nbr: "553", course_title_long: "Compiler Construction"),
        (subject: "ECE", catalog_nbr: "555", course_title_long: "Probability for Electrical and Computer Engineers"),
        (subject: "ECE", catalog_nbr: "558", course_title_long: "Computer Networks and Distributed Systems"),
        (subject: "ECE", catalog_nbr: "564", course_title_long: "Mobile Application Development"),
        (subject: "ECE", catalog_nbr: "565", course_title_long: "Performance, Optimization, and Parallelism"),
        (subject: "ECE", catalog_nbr: "590", course_title_long: "Enterprise Storage Architecture"),
        (subject: "ECE", catalog_nbr: "563", course_title_long: "Cloud Computing"),
        (subject: "ECE", catalog_nbr: "590", course_title_long: "Engineering Robust Server Software")
    ]
    
    static let hardwareClasses = [
        (subject: "ECE", catalog_nbr: "552", course_title_long: "Advanced Computer Architecture I"),
        (subject: "ECE", catalog_nbr: "550D", course_title_long: "Fundamentals of Computer Systems and Engineering"),
        (subject: "ECE", catalog_nbr: "559", course_title_long: "Advanced Digital Design"),
        (subject: "ECE", catalog_nbr: "539", course_title_long: "CMOS VLSI Design Methodologies"),
        (subject: "ECE", catalog_nbr: "555", course_title_long: "Probability for Electrical and Computer Engineers"),
        (subject: "ECE", catalog_nbr: "590", course_title_long: "Enterprise Storage Architecture"),
        (subject: "ECE", catalog_nbr: "561", course_title_long: "Datacenter Computing"),
        (subject: "ECE", catalog_nbr: "562", course_title_long: "Energy Efficient Computing"),
        
        (subject: "ECE", catalog_nbr: "652", course_title_long: "Advanced Computer Architecture II"),
        (subject: "ECE", catalog_nbr: "554", course_title_long: "Fault Tolerant and Testable Computer Systems"),
        (subject: "ECE", catalog_nbr: "526", course_title_long: "Semiconductor Devices for Integrated Circuits"),
        (subject: "ECE", catalog_nbr: "532", course_title_long: "Analog Integrated Circuit Design"),
        (subject: "ECE", catalog_nbr: "538", course_title_long: "VLSI System Testing")
    ]
    
    static let dataClasses = [
        (subject: "ECE", catalog_nbr: "586D", course_title_long: "Vector Space Methods with Applications"),
        (subject: "ECE", catalog_nbr: "581", course_title_long: "Random Signals and Noise"),
        (subject: "ECE", catalog_nbr: "551", course_title_long: "Programming, Data Structures, and Algorithms in C++"),
        (subject: "ECE", catalog_nbr: "580", course_title_long: "Introduction to Machine Learning"),
        (subject: "ECE", catalog_nbr: "590", course_title_long: "Deep Learning"),
        (subject: "ECE", catalog_nbr: "682D", course_title_long: "Probabilistic Machine Learning"),
        (subject: "ECE", catalog_nbr: "590D", course_title_long: "Machine Learning"),
        (subject: "ECE", catalog_nbr: "588", course_title_long: "Image and Video Processing"),
        (subject: "ECE", catalog_nbr: "582", course_title_long: "Digital Signal Processing"),
        (subject: "ECE", catalog_nbr: "590", course_title_long: "Textual Data Acquisition and Analysis"),
        (subject: "ECE", catalog_nbr: "590", course_title_long: "Uncertainty Analysis"),
        (subject: "STA", catalog_nbr: "601", course_title_long: "Bayesian Methods and Modern Statistics"),
        (subject: "ECE", catalog_nbr: "587", course_title_long: "Information Theory"),
        (subject: "CEE", catalog_nbr: "690", course_title_long: "Numerical Optimization"),
        (subject: "ECE", catalog_nbr: "551D", course_title_long: "Programming, Data Structures, and Algorithms in C++"),
        (subject: "ME", catalog_nbr: "548", course_title_long: "Multivariable Control"),
        (subject: "ME", catalog_nbr: "542", course_title_long: "Modern Control and Dynamic Systems"),
    ]
    
    static let quantumClasses = [
        (subject: "ECE", catalog_nbr: "590", course_title_long: "Introduction to Quantum Engineering"),
        (subject: "ECE", catalog_nbr: "523", course_title_long: "Quantum Information and Computation"),
        (subject: "ECE", catalog_nbr: "590", course_title_long: "Quantum Information Theory"),
        (subject: "ECE", catalog_nbr: "590", course_title_long: "Quantum Error Correction"),
        (subject: "ECE", catalog_nbr: "551D", course_title_long: "Programming, Data Structures, and Algorithms in C++"),
        (subject: "ECE", catalog_nbr: "550D", course_title_long: "Fundamentals of Computer Systems and Engineering"),
        (subject: "ECE", catalog_nbr: "651", course_title_long: "Software Engineering"),
        (subject: "ECE", catalog_nbr: "650", course_title_long: "Systems Programming and Engineering"),
        (subject: "ECE", catalog_nbr: "521", course_title_long: "Quantum Mechanics"),
        (subject: "ECE", catalog_nbr: "571", course_title_long: "Electromagnetic Theory"),
        (subject: "ECE", catalog_nbr: "575", course_title_long: "Microwave Electronic Circuits"),
        (subject: "ECE", catalog_nbr: "577", course_title_long: "Computational Electromagnetics"),
    ]
    
    static let microelectronicsClasses = [
        (subject: "ECE", catalog_nbr: "511", course_title_long: "Foundations of Nanoscale Science & Technology"),
        (subject: "ECE", catalog_nbr: "512", course_title_long: "Emerging Nanoelectronic Devices"),
        (subject: "ECE", catalog_nbr: "526", course_title_long: "Semiconductor Devices for ICs"),
        (subject: "ECE", catalog_nbr: "521", course_title_long: "Quantum Mechanics"),
        (subject: "ECE", catalog_nbr: "523", course_title_long: "Quantum Information Science"),
        (subject: "ECE", catalog_nbr: "527", course_title_long: "Analog Integrated Circuits"),
        (subject: "ECE", catalog_nbr: "528", course_title_long: "Integrated Circuit Engineering"),
        (subject: "ECE", catalog_nbr: "529", course_title_long: "Digital Integrated Circuits"),
        (subject: "ECE", catalog_nbr: "532", course_title_long: "Analog Integrated Circuit Design"),
        (subject: "ECE", catalog_nbr: "533", course_title_long: "Biochip Engineering"),
        (subject: "ECE", catalog_nbr: "546", course_title_long: "Optoelectronic Devices"),
        (subject: "ECE", catalog_nbr: "722", course_title_long: "Quantum Electronics"),
    ]
    static let technicalElectives = [
        (subject: "ECE", catalog_nbr: "511", course_title_long: "Foundations of Nanoscale Science & Technology"),
        (subject: "ECE", catalog_nbr: "512", course_title_long: "Emerging Nanoelectronic Devices"),
        (subject: "ECE", catalog_nbr: "520", course_title_long: "Graduate Introduction to Quantum Engineering"),
        (subject: "ECE", catalog_nbr: "521", course_title_long: "Quantum Mechanics"),
        (subject: "ECE", catalog_nbr: "523", course_title_long: "Quantum Information Science"),
        (subject: "ECE", catalog_nbr: "524", course_title_long: "Introduction to Solid-State Physics"),
        (subject: "ECE", catalog_nbr: "526", course_title_long: "Semiconductor Devices for Integrated Circuits"),
        (subject: "ECE", catalog_nbr: "528", course_title_long: "Integrated Circuit Engineering"),
        (subject: "ECE", catalog_nbr: "529", course_title_long: "Digital Integrated Circuits"),
        (subject: "ECE", catalog_nbr: "531", course_title_long: "Power Electronic Circuits for Energy Conversion"),
        (subject: "ECE", catalog_nbr: "532", course_title_long: "Analog Integrated Circuit Design"),
        (subject: "ECE", catalog_nbr: "533", course_title_long: "Biochip Engineering"),
        (subject: "ECE", catalog_nbr: "538", course_title_long: "VLSI System Testing"),
        (subject: "ECE", catalog_nbr: "539", course_title_long: "CMOS VLSI Design Methodologies"),
        (subject: "ECE", catalog_nbr: "541", course_title_long: "Advanced Optics"),
        (subject: "ECE", catalog_nbr: "545", course_title_long: "Foundations of Nanoelectronics & Nanophotonics"),
        (subject: "ECE", catalog_nbr: "546", course_title_long: "Optoelectronic Devices"),
        (subject: "ECE", catalog_nbr: "549", course_title_long: "Optics & Photonics Seminar Series"),
        (subject: "ECE", catalog_nbr: "550D", course_title_long: "Fundamentals of Computer Systems and Engineering"),
        (subject: "ECE", catalog_nbr: "551D", course_title_long: "Programming, Data Structures, and Algorithms in C++"),
        (subject: "ECE", catalog_nbr: "552", course_title_long: "Advanced Computer Architecture I"),
        (subject: "ECE", catalog_nbr: "553", course_title_long: "Compiler Construction"),
        (subject: "ECE", catalog_nbr: "554", course_title_long: "Fault-Tolerant and Testable Computer Systems"),
        (subject: "ECE", catalog_nbr: "555", course_title_long: "Probability for Electrical and Computer Engineers"),
        (subject: "ECE", catalog_nbr: "556", course_title_long: "Wireless Networking and Mobile Computing"),
        (subject: "ECE", catalog_nbr: "558", course_title_long: "Advanced Computer Networks"),
        (subject: "ECE", catalog_nbr: "559", course_title_long: "Advanced Digital System Design"),
        (subject: "ECE", catalog_nbr: "560", course_title_long: "Computer and Information Security"),
        (subject: "ECE", catalog_nbr: "564", course_title_long: "Mobile Application Development"),
        (subject: "ECE", catalog_nbr: "565", course_title_long: "Performance Optimization & Parallelism"),
        (subject: "ECE", catalog_nbr: "566", course_title_long: "Enterprise Storage Architecture"),
        (subject: "ECE", catalog_nbr: "567", course_title_long: "Cyber-Physical System Design"),
        (subject: "ECE", catalog_nbr: "568", course_title_long: "Engineering Robust Server Software"),
        (subject: "ECE", catalog_nbr: "571", course_title_long: "Electromagnetic Theory"),
        (subject: "ECE", catalog_nbr: "572", course_title_long: "Electromagnetic Communication Systems"),
        (subject: "ECE", catalog_nbr: "573", course_title_long: "Optical Communication Systems"),
        (subject: "ECE", catalog_nbr: "574", course_title_long: "Waves in Matter"),
        (subject: "ECE", catalog_nbr: "575", course_title_long: "Microwave Electronic Circuits"),
        (subject: "ECE", catalog_nbr: "580", course_title_long: "Introduction to Machine Learning"),
        (subject: "ECE", catalog_nbr: "581", course_title_long: "Random Signals and Noise"),
        (subject: "ECE", catalog_nbr: "585", course_title_long: "Signal Detection and Extraction Theory"),
        (subject: "ECE", catalog_nbr: "586", course_title_long: "Vector Space Methods with Applications"),
        (subject: "ECE", catalog_nbr: "587", course_title_long: "Information Theory"),
        (subject: "ECE", catalog_nbr: "588", course_title_long: "Image and Video Processing: From Mars to Hollywood with a Stop at the Hospital"),
        (subject: "ECE", catalog_nbr: "590", course_title_long: "Advanced Topics in Electrical and Computer Engineering"),
        (subject: "ECE", catalog_nbr: "621", course_title_long: "Quantum Error Correction"),
        (subject: "ECE", catalog_nbr: "623", course_title_long: "Quantum Information Theory"),
        (subject: "ECE", catalog_nbr: "650", course_title_long: "Systems Programming and Engineering"),
        (subject: "ECE", catalog_nbr: "651", course_title_long: "Software Engineering"),
        (subject: "ECE", catalog_nbr: "652", course_title_long: "Advanced Computer Architecture II"),
        (subject: "ECE", catalog_nbr: "653", course_title_long: "Human-Centered Computing"),
        (subject: "ECE", catalog_nbr: "654", course_title_long: "Edge Computing"),
        (subject: "ECE", catalog_nbr: "661", course_title_long: "Computer Engineering Machine Learning and Deep Neural Nets"),
        (subject: "ECE", catalog_nbr: "675", course_title_long: "Optical Imaging and Spectroscopy"),
        (subject: "ECE", catalog_nbr: "682D", course_title_long: "Probabilistic Machine Learning"),
        (subject: "ECE", catalog_nbr: "684", course_title_long: "Natural Language Processing"),
        (subject: "ECE", catalog_nbr: "685D", course_title_long: "Introduction to Deep Learning"),
        (subject: "ECE", catalog_nbr: "687D", course_title_long: "Theory and Algorithms for Machine Learning"),
        (subject: "ECE", catalog_nbr: "688", course_title_long: "Sensor Array Signal Processing"),
        (subject: "ECE", catalog_nbr: "721", course_title_long: "Nanotechnology Materials Lab"),
        (subject: "ECE", catalog_nbr: "741", course_title_long: "Compressed Sensing and Related Topics"),
        (subject: "ECE", catalog_nbr: "751D", course_title_long: "Advanced Programming, Data Structures, and Algorithms for C++"),
        (subject: "ECE", catalog_nbr: "784LA", course_title_long: "Sound in the Sea: Introduction to Marine Bioacoustics"),
        (subject: "ECE", catalog_nbr: "891", course_title_long: "Internship"),
        (subject: "ECE", catalog_nbr: "899", course_title_long: "Special Readings in Electrical and Computer Engineering"),
    ]
}



