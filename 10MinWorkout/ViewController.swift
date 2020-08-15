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

//TODO: Fix state issues!

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
    
    func setIsHidden(_ hidden: Bool, animated: Bool) {
        if animated {
            if self.isHidden && !hidden {
                self.alpha = 0.0
                self.isHidden = false
            }
            UIView.animate(withDuration: 0.15, animations: {
                self.alpha = hidden ? 0.0 : 1.0
            }) { (complete) in
                self.isHidden = hidden
            }
        } else {
            self.isHidden = hidden
        }
    }
}

class ViewController: UIViewController, AVAudioPlayerDelegate, MPMediaPickerControllerDelegate {
    
    private var audioPlayer = AVAudioPlayer()
    private let bellDingSoundPath = Bundle.main.path(forResource: "Tone", ofType: "mp3")

    private var buttonState:ButtonMode = ButtonMode.start
    
    private let workouts:Workouts = Workouts()
    private let purpleGradient:[UIColor] = [#colorLiteral(red: 0.6, green: 0.5019607843, blue: 0.9803921569, alpha: 1), #colorLiteral(red: 0.8813742278, green: 0.4322636525, blue: 0.9803921569, alpha: 1)]
    
    typealias AllWorkouts = [Workouts.Workout]
        
    private var currentWorkout = Workouts.Workout(duration: 0, name: "")
    private var nextWorkout = Workouts.Workout(duration: 0, name: "")
    private var timerInitiallyStarted = false
    
    //MARK: Testing vars
    
    
    //MARK: Properties
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var timerRing: UICircularTimerRing!
    @IBOutlet weak var workoutNameLabel: UILabel!
    @IBOutlet weak var nextWorkoutNameLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var selectSongs: UIButton!
    @IBOutlet weak var soundToggle: UISwitch!
    
    
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        if (buttonState == .start && !timerInitiallyStarted) { //first start
            timerInitiallyStarted = true
            startTimerIfWorkoutExists()
            //buttonState = .pause
            changeToMode(mode: .pause)
            soundToggle.isEnabled = false
            selectSongs.isEnabled = false
            return
        } else if (buttonState == .start) { //resuming from pause
            timerRing.continueTimer()
            //buttonState = .pause
            changeToMode(mode: .pause)
            soundToggle.isEnabled = false
            selectSongs.isEnabled = false
            return
        } else if (buttonState == .pause){ //pause timer
            timerRing.pauseTimer()
            soundToggle.isEnabled = true
            selectSongs.isEnabled = true
            //buttonState = .start
            changeToMode(mode: .start)
            return
        } else if (buttonState == .restart){ //restart timer
            self.resetAll()
//            enableButton(restartButton)
//            disableButton(startButton)
//            soundToggle.isEnabled = true
//            selectSongs.isEnabled = true
            return
        }
    }
    
    private func changeToMode(mode: ButtonMode) {
        startButton.isUserInteractionEnabled = true
        //set the state of the button according to the state passed in
        if (mode == .start && !timerInitiallyStarted) { //first start
            startButton.setTitle("Start", for: .normal)
            startButton.backgroundColor = UIColor.green
            self.buttonState = mode
            return
        } else if (mode == .start && timerInitiallyStarted) { //resume
            startButton.setTitle("Resume", for: .normal)
            startButton.backgroundColor = UIColor.green
            enableButton(stopButton)
            self.buttonState = mode
            return
        } else if (mode == .pause){ //pause
            startButton.setTitle("Pause", for: .normal)
            startButton.backgroundColor = UIColor.yellow
            disableButton(stopButton)
            self.buttonState = mode
            return
        } else if (mode == .restart) { //restart
            startButton.setTitle("Restart", for: .normal)
            startButton.backgroundColor = UIColor.systemBlue
            disableButton(stopButton)
            self.buttonState = mode
            return
        }
    }
    
    
    @IBAction func stopButtonTapped(_ sender: UIButton) {
        self.resetAll()
    }
    
    
    @IBAction func restartButtonTapped(_ sender: UIButton) {
        self.resetAll()
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
        musicPlayer.prepareToPlay()
        mediaPicker.dismiss(animated: true)
        // Begin playback.
        musicPlayer.play()
    }

    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true)
    }
    
    func enableButton(_ button: UIButton, isAnimated:Bool? = true) { //helper
        button.setIsHidden(false, animated: isAnimated!)
        button.isEnabled = true
        button.isUserInteractionEnabled = true
    }
    
    func disableButton(_ button: UIButton, isAnimated:Bool? = true) { //helper
        button.setIsHidden(true, animated: isAnimated!)
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
    
    
    private func resetAll() {
        timerRing.resetTimer()
        timerInitiallyStarted = false
        workouts.currentWorkoutIndex = 0
        currentWorkout = workouts.getCurrentWorkout()
        nextWorkout = workouts.getNextWorkout()
        updateLabels()
        disableButton(restartButton, isAnimated: false)
        disableButton(stopButton, isAnimated: false)
        enableButton(startButton, isAnimated: true)
        timerRing.shouldShowValueText = false
        //soundToggle.isEnabled = true
        //startButton.setTitle("Start", for: .normal)
        changeToMode(mode: .start)
        soundToggle.isEnabled = true
        selectSongs.isEnabled = true
    }
    
    


    
    private func initializeTimerRing() {
        timerRing.shouldShowValueText = false
        timerRing.backgroundColor = UIColor.clear //no background
        timerRing.startAngle = 90
        //timerRing.endAngle = 180 //endAngle broken?
        timerRing.outerRingColor = UIColor.clear //don't show
        timerRing.innerRingColor = UIColor.black
        timerRing.innerCapStyle = .round
        timerRing.innerRingWidth = 20.0
        timerRing.tintColor = UIColor.orange //does this do anything?
    }
    
    
    func roundButton(button:UIButton) { //round the corners of the button passed in
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
    }
    
    private func roundAllButtons() { //local helper method
        roundButton(button: startButton)
        roundButton(button: stopButton)
        roundButton(button: restartButton)
        roundButton(button: selectSongs)
    }
    
    private func setupAudio() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: bellDingSoundPath!))
            audioPlayer.delegate = self
            audioPlayer.volume = 1.0
        } catch {
            print(error)
        }
        /*
         ---------------------------------------------------------------------------------------------------
         */
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
        
        self.currentWorkout = workouts.getCurrentWorkout()
        self.nextWorkout = workouts.getNextWorkout()
        
        updateLabels() //MUST come after current workout init
        
        setupAudio() //setup audio stuff
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.observeBackgroundEntry), name: UIApplication.didEnterBackgroundNotification, object: nil) //add observer to handle leaving the foreground and pausing the timer
    }
    
    @objc func observeBackgroundEntry(notification: Notification) {
        //print("Observer called!")
        if (self.buttonState != .pause) {
            timerRing.pauseTimer()
            soundToggle.isEnabled = true
            selectSongs.isEnabled = true
            //buttonState = .start
            changeToMode(mode: .start)
        }
    }
    
    private func updateLabels() { //set the label text to be the same as the name of the current workout
        self.workoutNameLabel.text = currentWorkout.name
        
        if (currentWorkout.duration == nil) {
            self.nextWorkoutNameLabel.text = ""
        } else if (nextWorkout.duration != nil) {
            self.nextWorkoutNameLabel.text = "Next: \(self.nextWorkout.name)"
        } else {
            self.nextWorkoutNameLabel.text = self.nextWorkout.name
        }
    }
    
    private func startTimerIfWorkoutExists() { //start the timer for the given duration or end the workout session if the current workout has no duration
        if (currentWorkout.duration != nil) {
            audioPlayer.numberOfLoops = 0
            timerRing.shouldShowValueText = true
            timerRing.startTimer(to: currentWorkout.duration!, handler: self.handleTimer)
        } else { // nil duration signifies being done with all exercises
            audioPlayer.numberOfLoops = 1
            timerRing.shouldShowValueText = false;
            disableButton(startButton)
            enableButton(restartButton)
            soundToggle.isEnabled = true
            selectSongs.isEnabled = true
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
    
    private func advanceWorkout() {
        self.workouts.currentWorkoutIndex += 1 //get the next workout
        self.currentWorkout = workouts.getCurrentWorkout()
        self.nextWorkout = workouts.getNextWorkout()
    }
    
    
    private func handleTimer(state: UICircularTimerRing.State?) {
        if case .finished = state { //when the timer finishes, do this...
            //TODO: Tweak from prefs pane?
            advanceWorkout()
            timerRing.resetTimer()
            startTimerIfWorkoutExists()
            if (soundToggle.isOn) {
                audioSessionEnabled(enabled: true) //enable audio play
                audioPlayer.prepareToPlay()
                audioPlayer.play()
            }
            updateLabels()
        }
        
        
    }
    
    
    


}

