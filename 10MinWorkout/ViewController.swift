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
    //fileprivate var workoutIndex:Int = 0
    private var currentWorkout = Workouts.Workout(duration: 0, name: "")
    private var nextWorkout = Workouts.Workout(duration: 0, name: "")
    fileprivate var timerInitiallyStarted = false
    
    //MARK: Testing vars
    private var finishedOnce = false
    
    
    //MARK: Properties
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var timerRing: UICircularTimerRing!
    @IBOutlet weak var workoutNameLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!
    
    
    var buttonState:ButtonMode = ButtonMode.start
    @IBAction func startButtonTapped(_ sender: UIButton) {
        if (buttonState == .start && !timerInitiallyStarted) { //first start
            timerInitiallyStarted = true
            startTimer()
            buttonState = .pause
            changeStartPauseButtonToState(mode: .pause)
            return
        } else if (buttonState == .start) { //resuming from pause
            timerRing.continueTimer()
            buttonState = .pause
            changeStartPauseButtonToState(mode: .pause)
            return
        } else if (buttonState == .pause){ //pause timer
            timerRing.pauseTimer()
            buttonState = .start
            changeStartPauseButtonToState(mode: .start)
            return
        } else if (buttonState == .restart){
            enableButton(restartButton)
            disableButton(startButton)
            return
        }
    }
    
    @IBAction func stopButtonTapped(_ sender: UIButton) {
        timerRing.resetTimer()
        changeStartPauseButtonToState(mode: .start)
         //override behavior from above method
        reset()
    }
    
    
    @IBAction func restartButtonTapped(_ sender: UIButton) {
        timerRing.resetTimer()
        changeStartPauseButtonToState(mode: .start)
        reset()
        disableButton(restartButton)
        enableButton(startButton)
        buttonState = .start
    }
    
    func enableButton(_ button: UIButton) {
        button.isHidden = false
        button.isEnabled = true
    }
    
    func disableButton(_ button: UIButton) {
        button.isHidden = true
        button.isEnabled = false
    }
    
    
    enum ButtonMode:Equatable {
        case start
        case pause
        case restart
    }
    
    fileprivate func reset() {
        workouts.currentWorkoutIndex = 0
        currentWorkout = workouts.getCurrentWorkout()
        updateLabel()
        timerInitiallyStarted = false
        stopButtonEnabled(enabled: false)
        timerRing.shouldShowValueText = false
    }
    
    
    fileprivate func changeStartPauseButtonToState(mode: ButtonMode) {
        startButton.isUserInteractionEnabled = true
        if (mode == .start) {
            startButton.setTitle("Start", for: .normal)
            startButton.backgroundColor = UIColor.green
            stopButtonEnabled(enabled: true)
            return
        } else if (mode == .pause){
            startButton.setTitle("Pause", for: .normal)
            startButton.backgroundColor = UIColor.yellow
            stopButtonEnabled(enabled: false)
            return
        } else if (mode == .restart) {
            startButton.setTitle("Restart", for: .normal)
            startButton.backgroundColor = UIColor.systemBlue
            stopButtonEnabled(enabled: false)
            return
        }

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
        timerRing.shouldShowValueText = false
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
        timerInitiallyStarted = false
        startButton.isHidden = false
        stopButtonEnabled(enabled: false)
        initializeTimerRing()
        currentWorkout = workouts.getCurrentWorkout()
        updateLabel()
        
    }
    
    private func updateLabel() {
        self.workoutNameLabel.text = currentWorkout.name
    }
    
    fileprivate func startTimer() {
        if (currentWorkout.duration != nil) {
            timerRing.shouldShowValueText = true
            timerRing.startTimer(to: currentWorkout.duration!, handler: self.handleTimer)
        } else { //done with all exercises
            timerRing.shouldShowValueText = false;
            changeStartPauseButtonToState(mode: .restart)
            buttonState = .restart
            finishedOnce = true
        }
    }
    
    private func handleTimer(state: UICircularTimerRing.State?) {
        if case .finished = state {
            workouts.currentWorkoutIndex += 1 //get the next one
            self.currentWorkout = workouts.getCurrentWorkout()
            timerRing.resetTimer()
            startTimer()
            updateLabel()
        }
        
        
    }
    
    
    


}

