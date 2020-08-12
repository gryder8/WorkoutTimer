//
//  Workouts.swift
//  10MinWorkout
//
//  Created by Gavin Ryder on 8/11/20.
//  Copyright © 2020 Gavin Ryder. All rights reserved.
//

import Foundation

class Workouts {
    
    var workoutNames: [String] = []
    var workoutList:[Workout] = []
    let duration:TimeInterval = 30.0 //for now
    let numWorkouts: Int = 20 //for now
    let currentWorkoutIndex:Int = 0
    
    struct Workout: Decodable {
        let duration:TimeInterval
        let name:String
    }
    
    
    public init() {
        workoutNames.reserveCapacity(numWorkouts)
        workoutList.reserveCapacity(numWorkouts)
        loadData()
        initData()
    }
    
    private func loadData() {
        let url = Bundle.main.url(forResource: "WorkoutNames", withExtension: "plist")!
        let workoutNamesData = try! Data(contentsOf: url)
        let myDecodedPlistData = try! PropertyListSerialization.propertyList(from: workoutNamesData, options: [], format: nil)
        workoutNames = myDecodedPlistData as! [String]
        print(workoutNames)
    }
    
    private func initData() {
        for i in 0..<workoutNames.count {
            let newWorkout = Workout(duration: self.duration, name: workoutNames[i])
            workoutList.append(newWorkout)
        }
        print(workoutList)
    }
    
    func currentWorkout() -> Workout {
        return workoutList[currentWorkoutIndex]
    }
    
    
    func getNextWorkout() -> Workout {
        if (currentWorkoutIndex < workoutList.count-1) {
            return workoutList[currentWorkoutIndex+1]
        }
        return Workout(duration: 0, name: "You're done!")
    }
    
}
