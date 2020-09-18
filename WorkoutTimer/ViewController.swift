//
//  ViewController.swift
//  WorkoutTimer
//
//  Created by Gavin Ryder on 8/11/20.
//  Copyright © 2020 Gavin Ryder. All rights reserved.
//

import UIKit
import UICircularProgressRing
import AVFoundation
import MediaPlayer


//MARK: - UIView Animation Extension
extension UIView {
    
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

//MARK: - Main VC Class
class ViewController: UIViewController, AVAudioPlayerDelegate, MPMediaPickerControllerDelegate {
    
    //MARK: - Local Vars
    var mainPlayer: AVAudioPlayer!
    
    private let END_WORKOUT_SOUND_KEY = "ENDWORKOUT_SOUND_KEY"
    private let END_REST_SOUND_KEY = "RESTEND_SOUND_KEY"
    private let TONE_VOLUME_KEY = "TONE_VOLUME_KEY"
    
    var workoutEndSoundName = "Tone" {
        didSet {
            defaults.set(workoutEndSoundName, forKey: END_WORKOUT_SOUND_KEY)
        }
    }
    
    var restEndSoundName = "Tone" {
        didSet {
            defaults.set(restEndSoundName, forKey: END_REST_SOUND_KEY)
        }
    }
    
    var restDuration:Int = 15 {
        didSet {
            defaults.set(restDuration, forKey: restDurationKey) //update local data on set
        }
    }
    
    var toneVolume:Float = 1.0 {
        didSet {
            if (mainPlayer != nil) {
                mainPlayer.volume = toneVolume
            }
            defaults.set(toneVolume, forKey: TONE_VOLUME_KEY)
        }
    }
    
    
    private var buttonState:ButtonMode = ButtonMode.start //inital state
    private let restDurationKey = "REST_DUR_KEY" //KEY
    private let defaults = UserDefaults.standard
        
    typealias AllWorkouts = [Workouts.Workout] //array of struct
    
    var currentWorkout = Workouts.Workout(duration: 0, name: "")
    var nextWorkout = Workouts.Workout(duration: 0, name: "")
    var timerInitiallyStarted = false
    
    var isRestTimerActive = false
    private var restTimer:Timer!
    
    let sharedView:GradientBackgroundView = StyledGradientView.shared
    
    public let COLORS_KEY = "COLORS"
    var viewColors = StyledGradientView.viewColors {
        didSet {
            gradientView.startColor = viewColors.first!
            gradientView.endColor = viewColors.last!
            StyledGradientView.viewColors = self.viewColors
            
        }
    }
    
    //MARK: - Workouts Singleton!
    private let workouts:Workouts = Workouts.shared
    
    //MARK: - Button Modes
    enum ButtonMode:Equatable { //button states
        case start
        case pause
        case restart
    }
    
    //MARK: - Testing vars
    
    
    //MARK:  - Properties
    @IBOutlet weak var gradientView: GradientBackgroundView!
    @IBOutlet weak var timerRing: UICircularTimerRing!
    @IBOutlet weak var workoutNameLabel: UILabel!
    @IBOutlet weak var nextWorkoutNameLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var selectSongs: UIButton!
    @IBOutlet weak var workoutViewBtn: UIButton!
    @IBOutlet weak var settingsBtn: UIButton!
    @IBOutlet weak var appearanceButton: UIButton!
    @IBOutlet weak var soundToggleLabel: UILabel!
    @IBOutlet weak var soundToggle: UISwitch!
    @IBOutlet weak var swipeToTableView: UISwipeGestureRecognizer!
    @IBOutlet weak var restTimerLabel: UILabel!
    
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "swipeFromMain" || segue.identifier == "workoutBtnPressed") {
            (segue.destination as! WorkoutEditorControllerTableViewController).VCMaster = self
        } else if (segue.identifier == "settingsSegue") {
            (segue.destination as! SettingViewController).VCMaster = self
        }
    }
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.navigationBar.isHidden = true
        timerInitiallyStarted = false
        StyledGradientView.setup() //setup the static class (should only be done here!)
        loadDataFromLocalStorage()
        
        //********************************************************
        
        roundAllButtons()
        enableAndShowButton(startButton)
        disableAndHideButton(stopButton)
        disableAndHideButton(restartButton)
        self.soundToggle.isEnabled = true
        self.soundToggle.isUserInteractionEnabled = true
        soundToggle.addTarget(self, action: #selector(switchToggled), for: .valueChanged)
        
        //********************************************************
        
        workoutNameLabel.textColor = .black
        nextWorkoutNameLabel.textColor = .black
        
        setupTimerRing()
        
        self.currentWorkout = workouts.getCurrentWorkout()
        self.nextWorkout = workouts.getNextWorkout()
        
        //********************************************************
        
        updateLabels() //MUST come after current workout init
        configMainPlayerToPlaySound(name: workoutEndSoundName)
        setupAudio() //setup audio stuff
        
        //********************************************************
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.observeBackgroundEntry), name: UIApplication.didEnterBackgroundNotification, object: nil) //add observer to handle leaving the foreground and pausing the timer
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        gradientView.startColor = StyledGradientView.viewColors[0]
        gradientView.endColor = StyledGradientView.viewColors[1]
        
        soundToggle.onTintColor = gradientView.startColor
        soundToggle.thumbTintColor = gradientView.endColor
        
        if (gradientView.endColor!.isLight()) {
            soundToggleLabel.textColor = .black
        } else {
            soundToggleLabel.textColor = .white
        }
    }
    
    @objc func switchToggled() {
        if (soundToggle.isOn) {
            soundToggle.thumbTintColor = gradientView.endColor!
        } else {
            soundToggle.thumbTintColor = gradientView.startColor!
        }
    }
    
    
    //MARK: - AVPlayer Config
    func configMainPlayerToPlaySound(name:String) {
        let path = Bundle.main.path(forResource: name, ofType: "mp3")!
        let URLForSound = URL(string: path)!
        do {
            try mainPlayer = AVAudioPlayer(contentsOf: URLForSound)
            mainPlayer.delegate = self
        } catch {
            print("Failed to initialize player with error: \(error)")
        }
    }
    
    
    //MARK: - Enable and Disable Button
    func transitioningActionsEnabled(_ enabled: Bool) { //determine if buttons are on or off on the home page
        soundToggle.isEnabled = enabled
        selectSongs.isEnabled = enabled
        workoutViewBtn.isEnabled = enabled
        swipeToTableView.isEnabled = enabled
        appearanceButton.isEnabled = enabled
    }
    
    
    //MARK: - State Management
    @IBAction func startButtonTapped(_ sender: UIButton) {
        if (buttonState == .start && !timerInitiallyStarted) { //first start
            timerInitiallyStarted = true
            startTimerIfWorkoutExists()
            changeButtonToMode(mode: .pause)
            self.settingsBtn.isEnabled = false
            transitioningActionsEnabled(false)
            UIApplication.shared.isIdleTimerDisabled = true //once the user starts the workout, prevent the device from going to sleep
            return
        } else if (buttonState == .start) { //resuming from pause
            if (!isRestTimerActive) {
                timerRing.continueTimer()
            } else {
                restTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateLabelForCountdown), userInfo: nil, repeats: true)
            }
            self.settingsBtn.isEnabled = false
            changeButtonToMode(mode: .pause)
            transitioningActionsEnabled(false)
            return
        } else if (buttonState == .pause){ //pause timer
            if (!isRestTimerActive) {
                timerRing.pauseTimer()
                settingsBtn.isEnabled = true
            } else {
                restTimer.invalidate()
                settingsBtn.isEnabled = true
            }
            transitioningActionsEnabled(true)
            changeButtonToMode(mode: .start)
            return
        } else if (buttonState == .restart){ //restart timer
            self.resetAll()
            return
        }
    }
    
    func changeButtonToMode(mode: ButtonMode) {
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
            enableAndShowButton(stopButton)
            self.buttonState = mode
            return
        } else if (mode == .pause){ //pause
            startButton.setTitle("Pause", for: .normal)
            startButton.backgroundColor = UIColor.yellow
            disableAndHideButton(stopButton)
            self.buttonState = mode
            return
        } else if (mode == .restart) { //restart
            startButton.setTitle("Restart", for: .normal)
            UIApplication.shared.isIdleTimerDisabled = false //enable the screen to go to sleep once the workout is done
            startButton.backgroundColor = UIColor.systemBlue
            disableAndHideButton(stopButton)
            self.buttonState = mode
            return
        }
    }
    
    //MARK: - Button Action Handlers
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
            
    //MARK: - Delegates
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
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) { //delegate method
        audioSessionEnabled(enabled: false)
    }
    
    @objc func observeBackgroundEntry(notification: Notification) {
        if (timerInitiallyStarted) {
            if (!isRestTimerActive) {
                timerRing.pauseTimer()
                settingsBtn.isEnabled = true
            } else {
                restTimer.invalidate()
                settingsBtn.isEnabled = true
            }
            transitioningActionsEnabled(true)
            changeButtonToMode(mode: .start)
        }
        return
    }
    
    
    //MARK: - Local Helper and Initialization Functions
    private func startNextWorkout() {
        advanceWorkout()
        startTimerIfWorkoutExists()
        updateLabels()
    }
    
    func enableAndShowButton(_ button: UIButton, isAnimated:Bool? = true) { //helper
        button.setIsHidden(false, animated: isAnimated!)
        button.isEnabled = true
        button.isUserInteractionEnabled = true
    }
    
    func disableAndHideButton(_ button: UIButton, isAnimated:Bool? = true) { //helper
        button.setIsHidden(true, animated: isAnimated!)
        button.isEnabled = false
        button.isUserInteractionEnabled = false
    }
    
    func resetAll() {
        timerRing.resetTimer()
        timerInitiallyStarted = false
        workouts.currentWorkoutIndex = 0
        currentWorkout = workouts.getCurrentWorkout()
        nextWorkout = workouts.getNextWorkout()
        updateLabels()
        disableAndHideButton(restartButton, isAnimated: false)
        disableAndHideButton(stopButton, isAnimated: false)
        enableAndShowButton(startButton, isAnimated: true)
        timerRing.shouldShowValueText = false
        restTimerLabel.isHidden = true
        changeButtonToMode(mode: .start)
        self.settingsBtn.isEnabled = true
        self.isRestTimerActive = false
        transitioningActionsEnabled(true)
    }
    
    private func setupTimerRing() {
        timerRing.font = UIFont (name: "Avenir Next", size: 38.0)!.italic()
        timerRing.shouldShowValueText = false
        timerRing.backgroundColor = UIColor.clear //no background
        timerRing.startAngle = 90
        timerRing.outerRingColor = UIColor.clear //don't show
        timerRing.innerRingColor = UIColor.black
        timerRing.innerCapStyle = .round
        timerRing.innerRingWidth = 20.0
        restTimerLabel.isHidden = true
    }
    
    private func roundButton(button:UIButton) { //round the corners of the button passed in
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
    }
    
    private func roundAllButtons() { //local helper method
        roundButton(button: startButton)
        roundButton(button: stopButton)
        roundButton(button: restartButton)
    }
    
    private func setupAudio() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                AVAudioSession.Category.playback,
                mode: AVAudioSession.Mode.default,
                options: [
                    AVAudioSession.CategoryOptions.duckOthers
                ]
            )
        } catch {
            print("Error occured on intializing: \(error)")
        }
    }
    
    func updateLabels(nextWorkoutOnly: Bool = false) { //set the label text to be the same as the name of the current workout
        if(!nextWorkoutOnly) {
            self.workoutNameLabel.text = currentWorkout.name
        }
        if (currentWorkout.duration == nil) {
            self.nextWorkoutNameLabel.text = "" //won't be visible but isn't technically hidden
        } else if (nextWorkout.duration != nil) {
            self.nextWorkoutNameLabel.text = "Next: \(self.nextWorkout.name)"
        } else {
            self.nextWorkoutNameLabel.text = self.nextWorkout.name
        }
    }
    
    private func advanceWorkout() {
        self.workouts.currentWorkoutIndex += 1 //get the next workout
        self.currentWorkout = workouts.getCurrentWorkout()
        self.nextWorkout = workouts.getNextWorkout()
    }
    
    private func loadDataFromLocalStorage() {
        if (defaults.integer(forKey: restDurationKey) != 0) { //load duration if it exists
            self.restDuration = defaults.integer(forKey: restDurationKey)
        } else {
            defaults.set(restDuration, forKey: restDurationKey)
        }
        
        if (defaults.string(forKey: END_WORKOUT_SOUND_KEY) != nil) { //load sound name if it exists
            workoutEndSoundName = defaults.string(forKey: END_WORKOUT_SOUND_KEY)! //can't be nil here
        } else {
            //workoutEndSoundName = "Tone"
            defaults.set(workoutEndSoundName, forKey: END_WORKOUT_SOUND_KEY)
        }
        
        if (defaults.string(forKey: END_REST_SOUND_KEY) != nil) { //load sound name if it exists
            restEndSoundName = defaults.string(forKey: END_REST_SOUND_KEY)! //can't be nil here
        } else {
            //restEndSoundName = "Tone"
            defaults.set(restEndSoundName, forKey: END_REST_SOUND_KEY)
        }
        
        if (defaults.float(forKey: TONE_VOLUME_KEY) != 0) {
            toneVolume = defaults.float(forKey: TONE_VOLUME_KEY)
        } else {
            defaults.set(toneVolume, forKey: TONE_VOLUME_KEY)
        }
    }
    
    
    
    
    //MARK: - Timer and Audio Control
    private func startTimerIfWorkoutExists() { //start the timer for the given duration or end the workout session if the current workout has no duration
        if (currentWorkout.duration != nil) {
            mainPlayer.numberOfLoops = 0
            timerRing.shouldShowValueText = true
            timerRing.startTimer(to: currentWorkout.duration!, handler: self.handleTimer)
        } else { // nil duration signifies being done with all exercises
            mainPlayer.numberOfLoops = 1
            timerRing.shouldShowValueText = false;
            disableAndHideButton(startButton)
            enableAndShowButton(restartButton)
            soundToggle.isEnabled = true
            selectSongs.isEnabled = true
            settingsBtn.isEnabled = true
            workoutViewBtn.isEnabled = true
        }
    }
    
    
    func audioSessionEnabled(enabled: Bool) {
        if (enabled) {
            do {
                try AVAudioSession.sharedInstance().setActive(true, options: AVAudioSession.SetActiveOptions.notifyOthersOnDeactivation)
            } catch {
                print("Session failed to activate!")
                print("Error occured: \(error)")
            }
        } else {
            do {
                try AVAudioSession.sharedInstance().setActive(false, options: AVAudioSession.SetActiveOptions.notifyOthersOnDeactivation)
            } catch {
                print("Session failed to deactivate! (Session was busy?)")
                print("Error occured: \(error)")
            }
        }
    }
    
    
    private func handleTimer(state: UICircularTimerRing.State?) {
        if case .finished = state { //when the timer finishes, do this...
            if (soundToggle.isOn) {
                audioSessionEnabled(enabled: true) //enable audio play
                configMainPlayerToPlaySound(name: workoutEndSoundName)
                mainPlayer.prepareToPlay()
                mainPlayer.volume = toneVolume
                mainPlayer.play()
            }
            timerRing.resetTimer()
            
            if (workouts.getNextWorkout().duration != nil) {
                restFor(restDuration)
            } else {
                startNextWorkout() //code that must be run regardless of whether there should be a rest
            }
            
        }
    }
    
    //MARK: - Used for timer countdown
    private var count:Int = 0
    
    //MARK: - Rest Timer Stuff
    private func restFor(_ duration: Int) {
        restTimerLabel.isHidden = false
        restTimerLabel.text = String(duration)
        restTimerLabel.frame = timerRing.frame
        count = duration
        workoutNameLabel.text = "Rest!"
        timerRing.shouldShowValueText = false
        restTimerLabel.font = UIFont (name: "Avenir Next", size: 60.0)!.italic()
        isRestTimerActive = true
        restTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateLabelForCountdown), userInfo: nil, repeats: true)
    }
    
    @objc private func updateLabelForCountdown() {
        if (count > 1) {
            count -= 1
            restTimerLabel.text = String(count)
        } else {
            if (soundToggle.isOn) {
                audioSessionEnabled(enabled: true) //enable audio play
                configMainPlayerToPlaySound(name: restEndSoundName)
                mainPlayer.prepareToPlay()
                mainPlayer.volume = toneVolume
                mainPlayer.play()
            }
            restTimerLabel.isHidden = true
            isRestTimerActive = false
            restTimer.invalidate()
            startNextWorkout()
        }
    }
    
    
    
    
    
}

