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
    
    var VCMaster:ViewController = ViewController()
    var darkModeEnabled:Bool = false
    
    @IBOutlet weak var gradientView: GradientView!
    
    @IBAction func valueChanged(_ sender: UISlider) {
        let roundedValue = round(sender.value)
        sender.value = roundedValue
        sliderValueLabel.text = "\(sender.value.clean) seconds"
    }
    
    @IBAction func sliderReleased(_ sender: UISlider) {
        VCMaster.restDuration = Int(sender.value)
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        setUpTableViewHeader()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.darkModeEnabled = (self.traitCollection.userInterfaceStyle == .dark)
        self.navigationController?.navigationBar.isHidden = false
        self.restDurationSlider.value = Float(VCMaster.restDuration) //initialize to the stored value
        sliderValueLabel.text = "\(restDurationSlider.value.clean) seconds"
    }
    
    private func setUpTableViewHeader(){
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = gradientView.firstColor
        self.navigationController?.view.backgroundColor = .clear
        self.navigationController?.navigationBar.tintColor = .black
        navigationItem.hidesBackButton = false
        //navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .done,target: self, action: #selector(backTapped))
        let label = UILabel(frame: CGRect(x:0, y:0, width:350, height:30))
        label.backgroundColor = .clear
        label.numberOfLines = 1
        label.font = UIFont (name: "Avenir Next", size: 14.0)!
        label.textAlignment = .center
        label.textColor = .black
        label.text = "Configure Settings"
        self.navigationItem.titleView = label
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
