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
    var currentWorkoutIndex:Int = 0
    
    typealias WorkoutList = [Workout]
    
    static let shared = Workouts()
    
    struct Workout: Decodable {
        let duration:TimeInterval?
        let name:String
    }
    
    
    public init() {
        loadData()
    }
    
    private func loadData() {
        let plistURL = Bundle.main.url(forResource: "FullWorkouts", withExtension: "plist")!
        if let data = try? Data(contentsOf: plistURL) {
            let decoder = PropertyListDecoder()
            workoutList = try! decoder.decode(WorkoutList.self, from:data)
        }
        //print(workoutList.count)
    }
    
    
    func getCurrentWorkout() -> Workout {
        if (currentWorkoutIndex < workoutList.count) {
            return workoutList[currentWorkoutIndex]
        }
        return Workout(duration: nil, name: "You're done!")
    }
    
    
    func getNextWorkout() -> Workout {
        if (currentWorkoutIndex < workoutList.count-1) {
            return workoutList[currentWorkoutIndex+1]
        }
        return Workout(duration: nil, name: "Last one! Almost there!")
    }
    
    func numWorkouts() -> Int { //helper
        return workoutList.count
    }
    
}
