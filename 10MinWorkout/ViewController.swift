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
    
    private let workouts:Workouts = Workouts()
    private var workoutNames: [String] = []
    fileprivate var workoutIndex:Int = 0
    fileprivate var hasBeenStarted = false
    
    
    //MARK: Properties
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var timerRing: UICircularTimerRing!
    @IBOutlet weak var workoutNameLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    
    var isStartState:Bool = true
    @IBAction func startButtonTapped(_ sender: UIButton) {
        if (isStartState && !hasBeenStarted) { //first start
            hasBeenStarted = true
            timerRing.startTimer(to: workouts.duration, handler: self.handleTimer) //TODO: integrate with array from object
            isStartState = false
            changeStartPauseButtonToMode(mode: .pause)
        } else if (isStartState) { //resuming from pause
            timerRing.continueTimer()
            isStartState = false
            changeStartPauseButtonToMode(mode: .pause)
        } else { //pause timer
            timerRing.pauseTimer()
            isStartState = true
            changeStartPauseButtonToMode(mode: .start)
        }
    }
    
    @IBAction func stopButtonTapped(_ sender: UIButton) {
        timerRing.resetTimer()
        changeStartPauseButtonToMode(mode: .start)
        stopButtonEnabled(enabled: false) //override behavior from above method
        hasBeenStarted = false
    }
    
    enum ButtonMode {
        case start
        case pause
    }
    
    
    fileprivate func changeStartPauseButtonToMode(mode: ButtonMode) {
        startButton.isUserInteractionEnabled = true
        if case .start = mode {
            startButton.setTitle("Start", for: .normal)
            startButton.backgroundColor = UIColor.green
            stopButtonEnabled(enabled: true)
        } else if case .pause = mode {
            startButton.setTitle("Pause", for: .normal)
            startButton.backgroundColor = UIColor.yellow
            stopButtonEnabled(enabled: false)
        }
//        else { //not a valid mode
//            fatalError("Attempted to change button mode to an invalid mode of \(mode)")
//        }
    }
    
    fileprivate func stopButtonEnabled(enabled: Bool) {
        if (enabled) {
            stopButton.isHidden = false;
            stopButton.isEnabled = true;
            stopButton.isUserInteractionEnabled = true;
        } else {
            stopButton.isHidden = true;
            stopButton.isEnabled = false;
            stopButton.isUserInteractionEnabled = false;
        }
    }

    
    private func initializeTimerRing() {
        timerRing.backgroundColor = UIColor.clear
        timerRing.startAngle = 90
        //timerRing.endAngle = 180
        timerRing.outerRingColor = UIColor.clear
        timerRing.innerRingColor = UIColor.black//colorForTime(timeRemaining: timeLeft)
        timerRing.innerCapStyle = .round
        timerRing.innerRingWidth = 20.0
        timerRing.tintColor = UIColor.orange
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
        startButton.isHidden = false
        stopButtonEnabled(enabled: false)
        initializeTimerRing()
        
    }
    
    private func handleTimer(state: UICircularTimerRing.State?) {
        if case .finished = state {
            timerRing.resetTimer()
            timerRing.startTimer(to: workouts.duration, handler: self.handleTimer)
        }
        
        
    }
    
    
    


}

