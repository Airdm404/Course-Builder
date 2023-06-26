//
//  Enums.swift
//  Course Builder
//
//  Created by Albert on 3/17/23.
//  

import Foundation

//MARK: selection of concentrations to pick
enum Programs: String, CaseIterable, Codable{
    case Software = "Software Development"
    case Hardware = "Hardware Design"
    case Data = "Data Analytics & Machine Learning"
    case Quantum = "Quantum Computing"
    case Microelectronics = "Microelectronics, Photonics and Nanotechnology"
}

//MARK: alert types during save schedule
enum AlertType: CaseIterable, Codable{
    case emptyName
    case repeatName
}

//MARK: whether or not a schedule has completed all of the graduation requirements
enum GradCheck: CaseIterable, Codable{
    case graduate
    case noGraduate
}
