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
import MediaPlayer

extension UIView { //courtesy StackOverflow lol
    @discardableResult
    func applyGradient(colours: [UIColor]) -> CAGradientLayer {
        return self.applyGradient(colours: colours, locations: nil)
    }

    @discardableResult
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> CAGradientLayer {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
        return gradient
    }
}

class ViewController: UIViewController, AVAudioPlayerDelegate, MPMediaPickerControllerDelegate {
    
    var audioPlayer = AVAudioPlayer()
    let bellDingSoundPath = Bundle.main.path(forResource: "Tone", ofType: "mp3")

    
    private let workouts:Workouts = Workouts()
    private var workoutNames: [String] = []
    let purpleGradient:[UIColor] = [#colorLiteral(red: 0.6, green: 0.5019607843, blue: 0.9803921569, alpha: 1), #colorLiteral(red: 0.8509803922, green: 0.5019607843, blue: 0.9803921569, alpha: 1)]
    
    typealias AllWorkouts = [Workouts.Workout]
    
    let plistURL:URL = URL(fileURLWithPath: Bundle.main.path(forResource:"", ofType:"plist")!)
    
    //fileprivate var workoutIndex:Int = 0
    private var currentWorkout = Workouts.Workout(duration: 0, name: "")
    private var nextWorkout = Workouts.Workout(duration: 0, name: "")
    fileprivate var timerInitiallyStarted = false
    
    
    //MARK: Testing vars
    //private var finishedOnce = false
    
    
    //MARK: Properties
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var timerRing: UICircularTimerRing!
    @IBOutlet weak var workoutNameLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var selectSongs: UIButton!
    
    
    var buttonState:ButtonMode = ButtonMode.start
    @IBAction func startButtonTapped(_ sender: UIButton) {
        if (buttonState == .start && !timerInitiallyStarted) { //first start
            timerInitiallyStarted = true
            startTimerIfWorkoutExists()
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
    
    @IBAction func selectSongs(_ sender: UIButton) {
        let controller = MPMediaPickerController(mediaTypes: .music)
        controller.allowsPickingMultipleItems = true
        controller.popoverPresentationController?.sourceView = sender
        controller.delegate = self
        self.present(controller, animated: true)
    }
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController,
                     didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        // Get the system music player.
        let musicPlayer = MPMusicPlayerController.systemMusicPlayer
        musicPlayer.setQueue(with: mediaItemCollection)
        mediaPicker.dismiss(animated: true)
        // Begin playback.
        musicPlayer.play()
    }

    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true)
    }
    
    func enableButton(_ button: UIButton) { //helper
        button.isHidden = false
        button.isEnabled = true
        button.isUserInteractionEnabled = true
    }
    
    func disableButton(_ button: UIButton) { //helper
        button.isHidden = true
        button.isEnabled = false
        button.isUserInteractionEnabled = false
    }
    
    
    enum ButtonMode:Equatable { //button states
        case start
        case pause
        case restart
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) { //delegate method
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
        //set the state of the button according to the state passed in
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

    
    private func initializeTimerRing() {
        timerRing.shouldShowValueText = false
        timerRing.backgroundColor = UIColor.clear //no background
        timerRing.startAngle = 90
        //timerRing.endAngle = 180 //endAngle broken?
        timerRing.outerRingColor = UIColor.clear
        timerRing.innerRingColor = UIColor.black//colorForTime(timeRemaining: timeLeft)
        timerRing.innerCapStyle = .round
        timerRing.innerRingWidth = 20.0
        timerRing.tintColor = UIColor.orange //does this do anything?
    }
    
    
    func roundButton(button:UIButton) { //round the corners of the button passed in
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
    }
    
    fileprivate func roundAllButtons() { //local helper method
        roundButton(button: startButton)
        roundButton(button: stopButton)
        roundButton(button: restartButton)
        roundButton(button: selectSongs)
    }
    
    fileprivate func setupAudio() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: bellDingSoundPath!))
            audioPlayer.delegate = self
            audioPlayer.volume = 1.0
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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        timerInitiallyStarted = false
        if (self.traitCollection.userInterfaceStyle == .dark){
            gradientView.firstColor =   #colorLiteral(red: 1, green: 0.2969330549, blue: 0, alpha: 1)
            gradientView.secondColor =  #colorLiteral(red: 1, green: 0.8361050487, blue: 0.6631416678, alpha: 1)
        } else {
            gradientView.firstColor = #colorLiteral(red: 1, green: 0.8361050487, blue: 0.6631416678, alpha: 1)
            gradientView.secondColor = #colorLiteral(red: 1, green: 0.2969330549, blue: 0, alpha: 1)
        }
        
        roundAllButtons()
        selectSongs.applyGradient(colours: purpleGradient)
        
        enableButton(startButton)
        disableButton(stopButton)
        
        initializeTimerRing()
        
        currentWorkout = workouts.getCurrentWorkout()
        
        updateLabel() //MUST come after current workout init
        
        setupAudio() //setup audio stuff
    }
    
    private func updateLabel() { //set the label text to be the same as the name of the current workout
        self.workoutNameLabel.text = currentWorkout.name
    }
    
    fileprivate func startTimerIfWorkoutExists() { //start the timer for the given duration or end the workout session if the current workout has no duration
        if (currentWorkout.duration != nil) {
            timerRing.shouldShowValueText = true
            timerRing.startTimer(to: currentWorkout.duration!, handler: self.handleTimer)
        } else { // nil duration signifies being done with all exercises
            audioPlayer.numberOfLoops = 1
            timerRing.shouldShowValueText = false;
            disableButton(startButton)
            enableButton(restartButton)
            //finishedOnce = true
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
        if case .finished = state { //when the timer finishes, do this...
            //TODO: Tweak from prefs pane?
            audioSessionEnabled(enabled: true) //enable audio play
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            self.workouts.currentWorkoutIndex += 1 //get the next workout
            self.currentWorkout = workouts.getCurrentWorkout()
            timerRing.resetTimer()
            startTimerIfWorkoutExists()
            updateLabel()
        }
        
        
    }
    
    
    


}

