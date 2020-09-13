//
//  Workouts.swift
//  10MinWorkout
//
//  Created by Gavin Ryder on 8/11/20.
//  Copyright © 2020 Gavin Ryder. All rights reserved.
//

import Foundation


//TODO: more tones
class Workouts {
    //MARK: - Local Vars
    var currentWorkoutIndex:Int = 0
    let defaults = UserDefaults.standard
    let WORKOUTS_KEY:String = "WORKOUTS"
    
    var allWorkouts:[Workout] = [] {
        didSet { //write new data to cache on set
            if let dataToWrite = try? PropertyListEncoder().encode(allWorkouts) {
                defaults.set(dataToWrite, forKey: WORKOUTS_KEY)
                print("Wrote updated data to cache")
            } else {
                print("***Failed to encode/write workouts data to defaults!***")
            }
        }
    }
    
    typealias WorkoutList = [Workout]
    
    static let shared = Workouts()
    
    
    //MARK: - Workout Struct Definition
    struct Workout: Codable { //can be encoded and decoded
        var duration:TimeInterval?
        var name:String
    }
    
    //MARK: - Initializes Applicatiom by loading data
    public init() {
        loadData()
    }
    
    //MARK: - DATA LOADER
    //Loads data from the cache if possible, otherwise if parses a plist and writes the data
    private func loadData() {
        //defaults.removeObject(forKey: WORKOUTS_KEY)
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
    }
    
    //MARK: - Getters
    //return the current workout, checking the bounds to see if the session is over
    func getCurrentWorkout() -> Workout {
        if (currentWorkoutIndex < allWorkouts.count) {
            return allWorkouts[currentWorkoutIndex]
        }
        return Workout(duration: nil, name: "You're done!")
    }
    
    //return the next workout, checking bounds to see if session is almost over
    func getNextWorkout() -> Workout {
        if (currentWorkoutIndex < allWorkouts.count-1) {
            return allWorkouts[currentWorkoutIndex+1]
        }
        return Workout(duration: nil, name: "Last one! Almost there!")
    }
    
    //return the number of workouts in this instance
    func numWorkouts() -> Int { //helper
        return allWorkouts.count
    }
    
}
