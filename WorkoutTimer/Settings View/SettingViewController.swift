//
//  SettingViewController.swift
//  WorkoutTimer
//
//  Created by Gavin Ryder on 8/18/20.
//  Copyright © 2020 Gavin Ryder. All rights reserved.
//

import UIKit

extension Float {
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}


class SettingViewController: UIViewController {
    
    @IBOutlet weak var restDurationSlider: UISlider!
    @IBOutlet weak var sliderValueLabel: UILabel!
    @IBOutlet weak var gradientView: GradientView!
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var dropdownBtn: UIButton!
    @IBOutlet weak var optionsTableView: UITableView!
    @IBOutlet weak var restDropdownBtn: UIButton!
    @IBOutlet weak var restOptionsTblView: UITableView!
    
    var soundOptionsList = ["Tone", "Beep","Whistle", "Ding"]
    
    let workoutEndKey = "WORKOUT_END_KEY"
    let restEndKey = "REST_END_KEY"
    var workoutEndChoice = "Tone" {
        didSet {
            UserDefaults.standard.set(workoutEndChoice, forKey: "WORKOUT_END_KEY")
        }
    }
    
    var restEndChoice = "Tone" {
        didSet {
            UserDefaults.standard.set(restEndChoice, forKey: "REST_END_KEY")
        }
    }
    
    var VCMaster:ViewController = ViewController()
    var darkModeEnabled:Bool = false
    
    @IBAction func valueChanged(_ sender: UISlider) {
        let roundedValue = round(sender.value)
        sender.value = roundedValue
        sliderValueLabel.text = "\(sender.value.clean) seconds"
    }
    
    @IBAction func sliderReleased(_ sender: UISlider) {
        VCMaster.restDuration = Int(sender.value)
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        setUpTableViewHeader()
        self.restDurationSlider.isEnabled = !(VCMaster.isRestTimerActive)
        self.sliderValueLabel.isEnabled = !(VCMaster.isRestTimerActive)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
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
        loadSoundPathsFromLocalData()
        sliderValueLabel.text = "\(restDurationSlider.value.clean) seconds"
        dropdownBtn.setTitle(workoutEndChoice, for: .normal)
        restDropdownBtn.setTitle(restEndChoice, for: .normal)
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
            
            self.optionsTableView.setIsHidden(true, animated: true)
        } else if (tableView.restorationIdentifier == "rest") {
            restDropdownBtn.setTitle("\(soundOptionsList[indexPath.row])", for: .normal)
            restEndChoice = soundOptionsList[indexPath.row]
            VCMaster.restEndSoundName = restEndChoice
            
            VCMaster.configMainPlayerToPlaySound(name: restEndChoice)
            VCMaster.mainPlayer.prepareToPlay()
            VCMaster.mainPlayer.play()
            
            self.restOptionsTblView.setIsHidden(true, animated: true)
        }
    }
    
    
}
