//
//  ViewController.swift
//  10MinWorkout
//
//  Created by Gavin Ryder on 8/11/20.
//  Copyright © 2020 Gavin Ryder. All rights reserved.
//

import UIKit
import UICircularProgressRing
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    var audioPlayer = AVAudioPlayer()
    let bellDingSoundPath = Bundle.main.path(forResource: "BellDing", ofType: "mp3")

    
    private let workouts:Workouts = Workouts()
    private var workoutNames: [String] = []
    
    typealias AllWorkouts = [Workouts.Workout]
    let plistURL:URL = URL(fileURLWithPath: Bundle.main.path(forResource:"", ofType:"plist")!)
    
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
    
    func enableButton(_ button: UIButton) { //helper
        button.isHidden = false
        button.isEnabled = true
        button.isUserInteractionEnabled = true
    }
    
    func disableButton(_ button: UIButton) {
        button.isHidden = true
        button.isEnabled = false
        button.isUserInteractionEnabled = false
    }
    
    
    enum ButtonMode:Equatable {
        case start
        case pause
        case restart
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        audioSessionEnabled(enabled: false)
    }
    
    
    fileprivate func reset() {
        workouts.currentWorkoutIndex = 0
        currentWorkout = workouts.getCurrentWorkout()
        updateLabel()
        timerInitiallyStarted = false
        disableButton(stopButton)
        timerRing.shouldShowValueText = false
    }
    
    
    fileprivate func changeStartPauseButtonToState(mode: ButtonMode) {
        startButton.isUserInteractionEnabled = true
        if (mode == .start) {
            startButton.setTitle("Start", for: .normal)
            startButton.backgroundColor = UIColor.green
            enableButton(stopButton)
            return
        } else if (mode == .pause){
            startButton.setTitle("Pause", for: .normal)
            startButton.backgroundColor = UIColor.yellow
            disableButton(stopButton)
            return
        } else if (mode == .restart) {
            startButton.setTitle("Restart", for: .normal)
            startButton.backgroundColor = UIColor.systemBlue
            disableButton(stopButton)
            return
        }

    }
    
//    fileprivate func stopButtonEnabled(enabled: Bool) {
//        if (enabled) {
//            stopButton.isHidden = false;
//            stopButton.isEnabled = true;
//            stopButton.isUserInteractionEnabled = true;
//        } else {
//            stopButton.isHidden = true;
//            stopButton.isEnabled = false;
//            stopButton.isUserInteractionEnabled = false;
//        }
//    }

    
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
    
    func roundButton(button:UIButton) {
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
    }
    
    fileprivate func roundAllButtons() { //local helper func
        roundButton(button: startButton)
        roundButton(button: stopButton)
        roundButton(button: restartButton)
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
        roundAllButtons()
        timerInitiallyStarted = false
        startButton.isHidden = false
        disableButton(stopButton)
        initializeTimerRing()
        currentWorkout = workouts.getCurrentWorkout()
        updateLabel()
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: bellDingSoundPath!))
            audioPlayer.delegate = self
        } catch {
            print(error)
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(
            AVAudioSession.Category.playback,
            mode: AVAudioSession.Mode.default,
            options: [
                AVAudioSession.CategoryOptions.duckOthers
            ]
        )
        } catch {
            print(error)
        }
                
    }
    
    private func updateLabel() {
        self.workoutNameLabel.text = currentWorkout.name
    }
    
    fileprivate func startTimer() {
        if (currentWorkout.duration != nil) {
            audioPlayer.numberOfLoops = 2
            timerRing.shouldShowValueText = true
            timerRing.startTimer(to: currentWorkout.duration!, handler: self.handleTimer)
        } else { // nil duration signifies being done with all exercises
            audioPlayer.numberOfLoops = 3
            timerRing.shouldShowValueText = false;
            disableButton(startButton)
            enableButton(restartButton)
            finishedOnce = true
        }
    }
    
    
    private func audioSessionEnabled(enabled: Bool) {
        if (enabled) {
            do {
                try AVAudioSession.sharedInstance().setActive(true, options: AVAudioSession.SetActiveOptions.notifyOthersOnDeactivation)
            } catch {
                print("Session failed to activate!")
                print(error)
            }
        } else {
            do {
                try AVAudioSession.sharedInstance().setActive(false, options: AVAudioSession.SetActiveOptions.notifyOthersOnDeactivation)
            } catch {
                print("Session failed to deactivate! (Session was busy?)")
                print(error)
            }
        }
    }
    
    
    private func handleTimer(state: UICircularTimerRing.State?) {
        if case .finished = state {
            audioPlayer.volume = 1.0
            audioSessionEnabled(enabled: true)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            //audioPlayer.stop()
            //audioSessionEnabled(enabled: false)
            workouts.currentWorkoutIndex += 1 //get the next one
            self.currentWorkout = workouts.getCurrentWorkout()
            timerRing.resetTimer()
            startTimer()
            updateLabel()
        }
        
        
    }
    
    
    


}

