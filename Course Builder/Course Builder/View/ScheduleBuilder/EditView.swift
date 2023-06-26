//
//  EditView.swift
//  Course Builder
//
//  Created by Cynthia Z France on 3/29/23.
//  Modified by Edem

import SwiftUI

//MARK: view for constructing a view. Gives the user the option to set a name, pick a concentration, add semesters, move classes to and from semesters, and check graduation
struct EditView: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @EnvironmentObject var schedules: ScheduleModel
    
    //MARK: variables set by callers
    @State var schedule: Schedule
    @State var selection: Programs
    @State var newName: String
    @State var requiredClasses: [Course]
    @State var electiveClasses: [Course]
    
    //MARK: private variables for showing alerts and checking graduation
    @State private var showAlert: Bool = false
    @State private var alertType: AlertType = AlertType.allCases[0]
    @State private var gradCheck: GradCheck = GradCheck.allCases[0]
    @State private var showGrad: Bool = false
    @State var showExport: Bool = false
    @State private var gradStatus: String = ""
    
    var body: some View {
        GeometryReader{geometry in
            NavigationStack {
                VStack(alignment: .leading) {
                    //MARK: textfield for setting a new name
                    TextField("Schedule Name", text: $newName)
                        .multilineTextAlignment(.center)
                        .font(.largeTitle)
                        .foregroundColor(.accentColor)
                    //MARK: picker for selecting a concentration
                    HStack{
                        Text("Program: ")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                        Picker("Program", selection: $selection) {
                            ForEach(Programs.allCases, id: \.self) {
                                Text($0.rawValue)
                            }
                        }
                    }
                    .padding(.top)
                    .padding(.leading)
                    .padding(.bottom)
                    
                    //MARK: holds all of the semsters, which represent groups of classes to be taken in the fall/spring. includes an 'add semester button'
                    ScheduleContainer(schedule: $schedule, electiveClasses: $electiveClasses, requiredClasses: $requiredClasses)
                        .frame(height: geometry.size.height*0.5)
                        .environmentObject(schedules)
                    
                    //MARK: two containers for classes. one
                    HStack{
                        RequiredClassesContainer(classes: $requiredClasses)
                        Spacer()
                        ElectiveClassesContainer(classes: $electiveClasses)
                    }
                    .frame(height: geometry.size.height*0.30)
                    .padding(.bottom)
                    .padding(.top)
                }
                .toolbar {
                    //MARK: buttons for demo
                    Button("software"){
                        software()
                    }
                    .buttonStyle(.borderedProminent)
                    //MARK: button for demo
                    Button("hardware"){
                        hardware()
                    }
                    .buttonStyle(.borderedProminent)
                    //MARK: exports schedule to PDF / image
                    Button("export") {
                        showExport.toggle()
                    }
                    .buttonStyle(.borderedProminent)
                    .sheet(isPresented: $showExport) {
                        ExportView(schedule: schedule)
                    }
                    //MARK: button that runs the graduation check function. shows an alert with the status of graduation
                    Button("Check Graduation") {
                        showGrad.toggle()
                        gradCheck = checkGraduate() ? GradCheck.graduate : GradCheck.noGraduate
                    }
                    .buttonStyle(.borderedProminent)
                    .alert(isPresented: $showGrad){
                        switch gradCheck {
                        case .graduate:
                            return Alert(title: Text("Fulfilled Requirements"), message: Text(gradStatus), dismissButton: .default(Text("ok")))
                        case .noGraduate:
                            return Alert(title: Text("Missing Requirements"), message: Text(gradStatus), dismissButton: .default(Text("ok")))
                        }
                    }
                    Spacer()
                    //MARK: button to exit out of the view without saving. returns to HomeView
                    Button("Cancel"){
                        self.mode.wrappedValue.dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    //MARK: checks that the name is not a duplicate name and isn't empty. invalid names will trigger alerts. then saves the new/updated schedule to the SchdeuleModel
                    Button("Save") {
                        if schedules.checkValidScheduleName(name: schedule.name, newname: newName){
                            schedule.save(name: newName, desc: schedule.desc, program: selection, semesters: schedule.semesters, backpack: electiveClasses, requiredClasses: requiredClasses)
                            schedules.addSchedule(schedule: schedule)
                            schedules.save()
                            self.mode.wrappedValue.dismiss()
                        } else if newName.count > 0{
                            showAlert.toggle()
                            alertType = AlertType.repeatName
                        } else{
                            showAlert.toggle()
                            alertType = AlertType.emptyName
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .alert(isPresented: $showAlert){
                        switch alertType{
                        case .repeatName:
                            return Alert(title: Text("Repeat Name"), message: Text("Repeat Name"), dismissButton: .default(Text("Ok")))
                        case .emptyName:
                            return Alert(title: Text("Name Cannot Be Empty"), message: Text("Name Cannot Be Empty"), dismissButton: .default(Text("Ok")))
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    //MARK: function for demo to auto populate the 'elective classes' bin with all of the classes required for a software concentration
    func software() {
        //concentration
        electiveClasses.append(Course(subject: "ECE", catalog_nbr: "550D", course_title_long: "Fundamentals of Computer Systems and Engineering"))
        electiveClasses.append(Course(subject: "ECE", catalog_nbr: "551D", course_title_long: "Programming, Data Structures, and Algorithms in C++"))
        electiveClasses.append(Course(subject: "ECE", catalog_nbr: "651", course_title_long: "Software Engineering"))
        //technical
        electiveClasses.append(Course(subject: "ECE", catalog_nbr: "574", course_title_long: "Waves in Matter"))
        electiveClasses.append(Course(subject: "ECE", catalog_nbr: "575", course_title_long: "Microwave Electronic Circuits"))
        //gen
        electiveClasses.append(Course(subject: "ARTHIST", catalog_nbr: "222", course_title_long: "genEd2"))
        electiveClasses.append(Course(subject: "ECE", catalog_nbr: "590", course_title_long: "Engineering Robust Server Software"))
        electiveClasses.append(Course(subject: "ARTHIST", catalog_nbr: "333", course_title_long: "genEd3"))
        schedule.save(name: newName, desc: schedule.desc, program: selection, semesters: schedule.semesters, backpack: electiveClasses, requiredClasses: requiredClasses)
        schedules.addSchedule(schedule: schedule)
    }
    
    //MARK: function for demo to auto populate the 'elective classes' bin with all of the classes required for a hardware concentration
    func hardware() {
        //concentration
        electiveClasses.append(Course(subject: "ECE", catalog_nbr: "586D", course_title_long: "Vector Space Methods with Applications"))
        electiveClasses.append(Course(subject: "ECE", catalog_nbr: "551D", course_title_long: "Programming, Data Structures, and Algorithms in C++"))
        electiveClasses.append(Course(subject: "ECE", catalog_nbr: "581", course_title_long: "Random Signals and Noise"))
        //technical
        electiveClasses.append(Course(subject: "ECE", catalog_nbr: "574", course_title_long: "Waves in Matter"))
        electiveClasses.append(Course(subject: "ECE", catalog_nbr: "575", course_title_long: "Microwave Electronic Circuits"))
        //gen
        electiveClasses.append(Course(subject: "ARTHIST", catalog_nbr: "222", course_title_long: "genEd2"))
        electiveClasses.append(Course(subject: "ECE", catalog_nbr: "590", course_title_long: "Engineering Robust Server Software"))
        electiveClasses.append(Course(subject: "ARTHIST", catalog_nbr: "333", course_title_long: "genEd3"))
        schedule.save(name: newName, desc: schedule.desc, program: selection, semesters: schedule.semesters, backpack: electiveClasses, requiredClasses: requiredClasses)
        schedules.addSchedule(schedule: schedule)
    }
    
    //MARK: checks the classes that are in the schedules and sees if there are enough to graduate with the selected concentration in mind.
    func checkGraduate() -> Bool {
        var classes : [Course] = []
        schedule.semesters.forEach { semester in
            semester.values.forEach { course in
                classes.append(course)
            }
        }
        var credits:Int = 0
        var core:Int = 0
        var concentration:Int = 0
        var internship:Int = 0
        var technical:Int = 0
        var general:Int = 0
        
        for course in classes{
            let flags = course.flags
            if flags["internship"]! { internship += 1
                continue
            }
            
            if flags["credit"]! { credits += 3 }
            if flags["core"]! { core += 1 }
            
            if flags[selection.rawValue]! { concentration += 1 }
            else if flags["technical"]! { technical += 1 }
            else if flags["general"]! { general += 1 }
        }
        
        self.gradStatus = ""
        if credits<30{
            self.gradStatus += "-Missing credits: \(30-credits)\n"
        }
        if core<2{
            self.gradStatus += "-Missing core classes: \(2-core)\n"
        }
        if internship<1{
            self.gradStatus += "-Missing internship: \(1-internship)\n"
        }
        if concentration<3{
            self.gradStatus += "-Missing concentration classes: \(3-concentration)\n"
        }
        if technical<2 {
            self.gradStatus += "-Missing technical electives: \(2-technical)\n"
        }
        if general<3 {
            self.gradStatus += "-Missing general electives: \(3-general)\n"
        }
        if self.gradStatus.count > 0{
            return false
        }
        self.gradStatus = "On track to graduate"
        return true
    }
    
    

    func ind() -> Int {
        let id = schedule.id
        for i in 0..<schedules.database.count {
            if (schedules.database[i].id == id) {
                return i
            }
        }
        return -1
    }
}

struct EditView_Previews_wrapper : View {
    var schedule: Schedule {
        let a = [Schedule(name: "test", desc: "?", program: Programs.allCases[0]), Schedule(name: "test2", desc: "?", program: Programs.allCases[0])]
        ScheduleModel.instance.database = a
        return a[0]
    }
    
    var body: some View {
        EditView(schedule: schedule, selection: schedule.program, newName: schedule.name, requiredClasses: REQUIREDCLASSES, electiveClasses: schedule.backpack)
            .environmentObject(ScheduleModel.instance)
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView_Previews_wrapper()
    }
}
