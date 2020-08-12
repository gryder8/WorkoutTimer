//
//  Workouts.swift
//  10MinWorkout
//
//  Created by Gavin Ryder on 8/11/20.
//  Copyright © 2020 Gavin Ryder. All rights reserved.
//

import Foundation

class Workouts {
    
    typealias Workouts = [Workout];
    
    var workoutNames: [String] = [];

    let duration:TimeInterval = 30.0 //for now
    let numWorkouts: Int = 20 //for now
    
    struct Workout: Decodable {
        let duration:TimeInterval
        let name:String
    }
    
    
    public init() {
        loadData()
    }
    
    private func loadData() -> [String]{
        let url = Bundle.main.url(forResource: "WorkoutNames", withExtension: "plist")!
        let workoutNamesData = try! Data(contentsOf: url)
        let myDecodedPlistData = try! PropertyListSerialization.propertyList(from: workoutNamesData, options: [], format: nil)
        workoutNames = myDecodedPlistData as! [String];
        return workoutNames
    }
    
    private func initData() {
        
    }
    
}
