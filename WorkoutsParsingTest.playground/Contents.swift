import UIKit
import Foundation

struct Workout: Decodable {
    let duration:TimeInterval?
    let name:String
}

let plistURL:URL = URL(fileURLWithPath: Bundle.main.path(forResource:"Workouts", ofType:"plist")!)


typealias Workouts = [Workout]

var allWorkouts:Workouts = []

if let data = try? Data(contentsOf: plistURL) {
    let decoder = PropertyListDecoder()
    allWorkouts = try! decoder.decode(Workouts.self, from:data)
}

print(allWorkouts)

