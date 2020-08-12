//
//  ViewController.swift
//  10MinWorkout
//
//  Created by Gavin Ryder on 8/11/20.
//  Copyright © 2020 Gavin Ryder. All rights reserved.
//

import UIKit
import UICircularProgressRing

class ViewController: UIViewController {
    
    
    //MARK: Properties
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var timerRing: UICircularTimerRing!
    
    
    private let workouts:Workouts = Workouts()
    
    private var workoutNames: [String] = []
    
    private func setupTimerRing (timeLeft: Double) {
        timerRing.startAngle = 90
        //timerRing.endAngle = 180
        timerRing.outerRingColor = UIColor.clear
        timerRing.innerRingColor = UIColor.black//colorForTime(timeRemaining: timeLeft)
        timerRing.innerCapStyle = .round
        timerRing.innerRingWidth = 20.0
        timerRing.tintColor = UIColor.orange
        timerRing.startTimer(to: workouts.duration, handler: self.handleTimer)
    }
    
    
    private func colorForTime(timeRemaining: TimeInterval) -> UIColor {
        if timeRemaining > 15 {
            return UIColor.green
        } else if timeRemaining >= 10 {
            return UIColor.yellow
        } else if timeRemaining >= 5 {
            return UIColor.orange
        }
        return UIColor.red
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if (self.traitCollection.userInterfaceStyle == .dark){
            gradientView.firstColor =   #colorLiteral(red: 1, green: 0.2969330549, blue: 0, alpha: 1)
            gradientView.secondColor =  #colorLiteral(red: 1, green: 0.8361050487, blue: 0.6631416678, alpha: 1)
        } else {
            gradientView.firstColor = #colorLiteral(red: 1, green: 0.8361050487, blue: 0.6631416678, alpha: 1)
            gradientView.secondColor = #colorLiteral(red: 1, green: 0.2969330549, blue: 0, alpha: 1)
        }
        
        self.workoutNames = workouts.workoutNames
        setupTimerRing(timeLeft: 30)
        
    }
    
    private func handleTimer(state: UICircularTimerRing.State?) {
        if case .finished  = state {
            timerRing.resetTimer()
            timerRing.startTimer(to: workouts.duration, handler: self.handleTimer)
        }
    }
    
    
    


}

