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
    
    var soundList = ["Tone", "Beep","Whistle", "Ding"]
    
    let choiceKey = "CHOICE_KEY"
    var choice = "Tone" {
        didSet {
            UserDefaults.standard.set(choice, forKey: "CHOICE_KEY")
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
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        setUpTableViewHeader()
        
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
        self.darkModeEnabled = (self.traitCollection.userInterfaceStyle == .dark)
        self.navigationController?.navigationBar.isHidden = false
        self.restDurationSlider.value = Float(VCMaster.restDuration) //initialize to the stored value
        if (UserDefaults.standard.string(forKey: choiceKey) != nil) {
            self.choice = UserDefaults.standard.string(forKey: choiceKey)!
        } else {
            choice = "Tone" //revert to default
            UserDefaults.standard.set(choice, forKey: choiceKey)
        }
        sliderValueLabel.text = "\(restDurationSlider.value.clean) seconds"
        dropdownBtn.setTitle(choice, for: .normal)
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return soundList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 40)
        tableView.separatorColor = UIColor(red:0, green:0, blue:0, alpha:0.7) //shoud be black insets
        let cellIdentifier = "optionCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? OptionsViewCell else {
            fatalError("Dequeued cell not an instance of OptionsViewCell")
        }
        cell.isSelected = (choice == soundList[indexPath.row])
        //cell.isHighlighted = (choice == soundList[indexPath.row])
        cell.optionLabel.textColor = .black
        cell.optionLabel.textAlignment = .left
        cell.backgroundColor = .clear
        cell.optionLabel.text = soundList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dropdownBtn.setTitle("\(soundList[indexPath.row])", for: .normal)
        choice = soundList[indexPath.row]
        VCMaster.currentSoundFileName = choice
        self.optionsTableView.setIsHidden(true, animated: true)
    }
    
    
}
