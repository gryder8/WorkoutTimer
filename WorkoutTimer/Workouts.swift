//
//  Workouts.swift
//  10MinWorkout
//
//  Created by Gavin Ryder on 8/11/20.
//  Copyright © 2020 Gavin Ryder. All rights reserved.
//

import Foundation

class Workouts {
    
    var allWorkouts:[Workout] = [] {
        didSet {
            if let dataToWrite = try? PropertyListEncoder().encode(allWorkouts) {
                defaults.set(dataToWrite, forKey: WORKOUTS_KEY)
                print("Wrote updated data to cache")
            }
        }
    }
    var currentWorkoutIndex:Int = 0
    let defaults = UserDefaults.standard
    let WORKOUTS_KEY:String = "WORKOUTS"
    
    typealias WorkoutList = [Workout]
    
    static let shared = Workouts()
    
    struct Workout: Codable {
        var duration:TimeInterval?
        var name:String
    }
    
    
    public init() {
        loadData()
    }
    
    private func loadData() {
        if let data = defaults.data(forKey: WORKOUTS_KEY) {
            self.allWorkouts = try! PropertyListDecoder().decode(WorkoutList.self, from: data)
            print("Got data from cache")
        } else {
            let plistURL = Bundle.main.url(forResource: "FullWorkouts", withExtension: "plist")!
            if let data = try? Data(contentsOf: plistURL) {
                let decoder = PropertyListDecoder()
                allWorkouts = try! decoder.decode(WorkoutList.self, from:data)
            }
            if let dataToWrite = try? PropertyListEncoder().encode(allWorkouts) {
                defaults.set(dataToWrite, forKey: WORKOUTS_KEY)
                print("Wrote data to cache")
            }
        }
        //print(workoutList.count)
    }
    
    
    func getCurrentWorkout() -> Workout {
        if (currentWorkoutIndex < allWorkouts.count) {
            return allWorkouts[currentWorkoutIndex]
        }
        return Workout(duration: nil, name: "You're done!")
    }
    
    
    func getNextWorkout() -> Workout {
        if (currentWorkoutIndex < allWorkouts.count-1) {
            return allWorkouts[currentWorkoutIndex+1]
        }
        return Workout(duration: nil, name: "Last one! Almost there!")
    }
    
    func numWorkouts() -> Int { //helper
        return allWorkouts.count
    }
    
    func updateWorkoutList(index: Int, _ newName:String?, _ newDuration:TimeInterval?) {
        if (newName != nil) {
            allWorkouts[index].name = newName!
        }
        if (newDuration != nil) {
            allWorkouts[index].duration = newDuration!
        }
    }
    
}
