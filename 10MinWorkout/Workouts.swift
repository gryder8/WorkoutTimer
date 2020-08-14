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
    var duration:TimeInterval = 3.0 //for now
    var numWorkouts: Int = 20 //for now
    var currentWorkoutIndex:Int = 0
    
    typealias WorkoutList = [Workout]
    
    struct Workout: Decodable {
        let duration:TimeInterval?
        let name:String
    }
    
    
    public init() {
        //workoutNames.reserveCapacity(numWorkouts)
        //workoutList.reserveCapacity(numWorkouts)
        loadData()
//        initData()
    }
    
    private func loadData() {
        let plistURL = Bundle.main.url(forResource: "Workouts", withExtension: "plist")!
//        let workoutNamesData = try! Data(contentsOf: plistURL)
//        let myDecodedPlistData = try! PropertyListSerialization.propertyList(from: workoutNamesData, options: [], format: nil)
//        workoutNames = myDecodedPlistData as! [String]
        if let data = try? Data(contentsOf: plistURL) {
            let decoder = PropertyListDecoder()
            workoutList = try! decoder.decode(WorkoutList.self, from:data)
        }
        print(workoutList)
    }
    
//    private func initData() { //TODO: Pull workout name and duration from plist
//        for i in 0..<workoutNames.count {
//            let newWorkout = Workout(duration: self.duration, name: workoutNames[i])
//            workoutList.append(newWorkout)
//        }
//        print(workoutList)
//    }
    
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
    
}
