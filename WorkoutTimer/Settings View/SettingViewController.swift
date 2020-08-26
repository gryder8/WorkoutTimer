//
//  SettingViewController.swift
//  WorkoutTimer
//
//  Created by Gavin Ryder on 8/18/20.
//  Copyright © 2020 Gavin Ryder. All rights reserved.
//

import UIKit


//MARK: - Float Extension
extension Float {
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

extension Double {
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

//MARK: - Class
class SettingViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var restDurationSlider: UISlider!
    @IBOutlet weak var sliderValueLabel: UILabel!
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var dropdownBtn: UIButton!
    @IBOutlet weak var optionsTableView: UITableView!
    @IBOutlet weak var restDropdownBtn: UIButton!
    @IBOutlet weak var restOptionsTblView: UITableView!
    @IBOutlet weak var timeStepper: UIStepper!
    
    @IBOutlet weak var volumeStepper: UIStepper!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var volumeSliderLabel: UILabel!
    
    
    //MARK: - Local vars
    let defaults = UserDefaults.standard
    
    var soundOptionsList = ["Tone","Beep","Whistle","Ding"]
    
    private let workoutEndKey = "WORKOUT_END_KEY"
    private let restEndKey = "REST_END_KEY"
    
    var workoutEndChoice = "Tone" {
        didSet {
            UserDefaults.standard.set(workoutEndChoice, forKey: "WORKOUT_END_KEY") //write to local
        }
    }
    
    var restEndChoice = "Tone" {
        didSet {
            UserDefaults.standard.set(restEndChoice, forKey: "REST_END_KEY") //write to local
        }
    }
    
    var VCMaster:ViewController = ViewController()
    private var darkModeEnabled:Bool = false
    
    //MARK: - Helpers
    func secondsToMinutesSeconds(secondsInput: Int) -> String {
        let seconds = secondsInput % 60
        let minutes = secondsInput / 60
        if (minutes <= 0) {
            return "\(seconds) seconds"
        } else if (seconds == 0) {
            if (minutes == 1) {
                return "\(minutes) minute"
            } else {
                return "\(minutes) minutes"
            }
        }
        return "\(minutes) min, \(seconds) sec"
    }
    
    
    //MARK: - Action Handlers
    @IBAction func valueChanged(_ sender: UISlider) {
        let roundedValue = round(sender.value)
        sender.value = roundedValue
        sliderValueLabel.text = secondsToMinutesSeconds(secondsInput: Int(sender.value.clean)!)
        //sliderValueLabel.text = "\(sender.value.clean) seconds"
        timeStepper.value = Double(sender.value)
    }
    
    @IBAction func sliderReleased(_ sender: UISlider) {
        let roundedValue = round(sender.value)
        sender.value = roundedValue
        VCMaster.restDuration = Int(sender.value)
        timeStepper.value = Double(sender.value)
    }
    
    @IBAction func volumeSliderReleased(_ sender: UISlider) {
        VCMaster.toneVolume = sender.value
    }
    
    @IBAction func volumeSliderValueChanged(_ sender: UISlider) {
        let step:Float = 0.05
        let roundedValue:Double = Double(round(sender.value / step) * step).roundTo(places: 2)
        //print(roundedValue)
        sender.value = Float(roundedValue)
        volumeStepper.value = Double(sender.value)
        volumeSliderLabel.text = "\(Int(sender.value * 100))%"
    }
    
    @IBAction func volumeStepperValueChanged(_ sender: UIStepper) {
        let step:Float = 0.05
        let roundedValue = Double(round(Float(sender.value) / step) * step).roundTo(places: 2)
        sender.value = roundedValue
        volumeSlider.value = Float(sender.value)
        VCMaster.toneVolume = volumeSlider.value
        volumeSliderLabel.text = "\(Int(sender.value * 100))%"
    }
    
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        let roundedValue = round(sender.value)
        sender.value = roundedValue
        restDurationSlider.value = Float(sender.value)
        VCMaster.restDuration = Int(sender.value)
        sliderValueLabel.text = secondsToMinutesSeconds(secondsInput: Int(sender.value.clean)!)
        //sliderValueLabel.text = "\(sender.value.clean) seconds"
    }
    
    @IBAction func dropdownButtonPressed(_ sender: UIButton) {
        if optionsTableView.isHidden {
            optionsTableView.setIsHidden(false, animated: true)
        } else {
            optionsTableView.setIsHidden(true, animated: true)
        }
    }
    
    @IBAction func restEndDropdownBtnPressed(_ sender: UIButton) {
        if restOptionsTblView.isHidden {
            restOptionsTblView.setIsHidden(false, animated: true)
        } else {
            restOptionsTblView.setIsHidden(true, animated: true)
        }
    }
    
    //MARK: - View Overrides
    override func viewWillAppear(_ animated: Bool) {
        setUpTableViewHeader()
//        self.restDurationSlider.isEnabled = !(VCMaster.isRestTimerActive)
//        self.sliderValueLabel.isEnabled = !(VCMaster.isRestTimerActive)
//        self.timeStepper.isEnabled = !(VCMaster.isRestTimerActive)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        optionsTableView.isHidden = true
        optionsTableView.dataSource = self
        optionsTableView.delegate = self
        optionsTableView.backgroundColor = .lightGray
        
        
        //**************************************************
        
        restOptionsTblView.isHidden = true
        restOptionsTblView.dataSource = self
        restOptionsTblView.delegate = self
        restOptionsTblView.backgroundColor = .lightGray
        
        self.darkModeEnabled = (self.traitCollection.userInterfaceStyle == .dark)
        self.navigationController?.navigationBar.isHidden = false
        self.restDurationSlider.value = Float(VCMaster.restDuration) //initialize to the stored value
        self.volumeSlider.value = VCMaster.toneVolume
        self.volumeSliderLabel.text = "\(Int(volumeSlider.value * 100))%"
        loadSoundPathsFromLocalData()
        sliderValueLabel.text = secondsToMinutesSeconds(secondsInput: Int(restDurationSlider.value.clean)!)
        dropdownBtn.setTitle(workoutEndChoice, for: .normal)
        restDropdownBtn.setTitle(restEndChoice, for: .normal)
                
        setupSteppers()
    }
    
    private func setupSteppers () {
        timeStepper.minimumValue = Double(restDurationSlider.minimumValue) //set bounds
        timeStepper.maximumValue = Double(restDurationSlider.maximumValue)
        timeStepper.value = Double(restDurationSlider.value) //init the value to ensure alignment
        timeStepper.layer.cornerRadius = 0.5
        
        volumeStepper.minimumValue = Double(volumeSlider.minimumValue)
        volumeStepper.maximumValue = Double(volumeSlider.maximumValue)
        volumeStepper.value = Double(volumeSlider.value)
        volumeStepper.layer.cornerRadius = 0.5
        volumeStepper.stepValue  = 0.05
    }
    
    
    //MARK: Loader and Setup Functions
    private func loadSoundPathsFromLocalData() {
        if (UserDefaults.standard.string(forKey: workoutEndKey) != nil) {
            self.workoutEndChoice = UserDefaults.standard.string(forKey: workoutEndKey)!
        } else {
            workoutEndChoice = "Tone" //revert to default
            UserDefaults.standard.set(workoutEndChoice, forKey: workoutEndKey)
        }
        
        if (UserDefaults.standard.string(forKey: restEndKey) != nil) {
            self.restEndChoice = UserDefaults.standard.string(forKey: restEndKey)!
        } else {
            restEndChoice = "Tone" //revert to default
            UserDefaults.standard.set(restEndChoice, forKey: restEndKey)
        }
    }
    
    
    private func setUpTableViewHeader(){
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = gradientView.firstColor
        self.navigationController?.view.backgroundColor = .clear
        self.navigationController?.navigationBar.tintColor = .black
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .done,target: self, action: #selector(backTapped))
        let label = UILabel(frame: CGRect(x:0, y:0, width:350, height:30))
        label.backgroundColor = .clear
        label.numberOfLines = 1
        label.font = UIFont (name: "Avenir Next", size: 18.0)!
        label.textAlignment = .center
        label.textColor = .black
        label.sizeToFit()
        label.text = "Configure Settings"
        self.navigationItem.titleView = label
    }
    
    @objc func backTapped(){
        navigationController?.popToRootViewController(animated: true)
    }
    
}

//MARK: - Table View Implementation!
extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return soundOptionsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 40)
        tableView.separatorColor = UIColor(red:0, green:0, blue:0, alpha:0.7) //shoud be black insets
        let cellIdentifier = "optionCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? OptionsViewCell else {
            fatalError("Dequeued cell not an instance of OptionsViewCell")
        }
        cell.isSelected = (workoutEndChoice == soundOptionsList[indexPath.row])
        cell.optionLabel.textColor = .black
        cell.optionLabel.textAlignment = .left
        cell.backgroundColor = .clear
        cell.optionLabel.text = soundOptionsList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView.restorationIdentifier == "workout") {
            dropdownBtn.setTitle("\(soundOptionsList[indexPath.row])", for: .normal)
            workoutEndChoice = soundOptionsList[indexPath.row]
            VCMaster.workoutEndSoundName = workoutEndChoice
            
            VCMaster.configMainPlayerToPlaySound(name: workoutEndChoice)
            VCMaster.mainPlayer.prepareToPlay()
            VCMaster.mainPlayer.play()
            
            //VCMaster.audioSessionEnabled(enabled: false)
            
            self.optionsTableView.setIsHidden(true, animated: true)
        } else if (tableView.restorationIdentifier == "rest") {
            restDropdownBtn.setTitle("\(soundOptionsList[indexPath.row])", for: .normal)
            restEndChoice = soundOptionsList[indexPath.row]
            VCMaster.restEndSoundName = restEndChoice
            
            VCMaster.configMainPlayerToPlaySound(name: restEndChoice)
            VCMaster.mainPlayer.prepareToPlay()
            VCMaster.mainPlayer.play()
            
            //VCMaster.audioSessionEnabled(enabled: false)
            
            self.restOptionsTblView.setIsHidden(true, animated: true)
        }
    }
    
    
    
    
}
