//
//  AppearanceEditorController.swift
//  WorkoutTimer
//
//  Created by Gavin Ryder on 9/7/20.
//  Copyright © 2020 Gavin Ryder. All rights reserved.
//

import UIKit
import ChromaColorPicker

class AppearanceEditorController: UIViewController {

    @IBOutlet var gradientView: GradientView!
    @IBOutlet weak var gradientViewButtonsParentView: UIView!
    @IBOutlet weak var color1Button: UIButton!
    @IBOutlet weak var color2Button: UIButton!
    
    var darkModeEnabled = false
    var usingDefaultColors = true
    
    let sharedView:GradientView = StyledGradientView.shared
    
    public let COLORS_KEY = "COLORS"
    var viewColors = StyledGradientView.viewColors {
        didSet {
            sharedView.firstColor = viewColors.first!
            sharedView.secondColor = viewColors.last!
            StyledGradientView.viewColors = self.viewColors
        }
    }
    
    
    let colorPicker = ChromaColorPicker(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StyledGradientView.setup()
        gradientView = sharedView
        setupColorPicker()
        configNavBar()
        //self.darkModeEnabled = (self.traitCollection.userInterfaceStyle == .dark)
        
    }
    
    private func configNavBar() {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = gradientView.firstColor
        self.navigationController?.view.backgroundColor = .clear
        self.navigationController?.navigationBar.tintColor = .black
        navigationItem.hidesBackButton = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        StyledGradientView.setColorsForGradientView(view: sharedView)
    }
    
    private func setupColorPicker() {
        gradientViewButtonsParentView.addSubview(colorPicker)

        let brightnessSlider = ChromaBrightnessSlider(frame: CGRect(x: 0, y: 0, width: 280, height: 32))
        gradientViewButtonsParentView.addSubview(brightnessSlider)
        colorPicker.connect(brightnessSlider)
    }
    
//    private func checkForLocalColors() {
//        if let foundColors:[UIColor] = defaults.array(forKey: COLORS_KEY) as? [UIColor] {
//            viewColors = foundColors
//            setLocalColors(colors: viewColors, forKey: COLORS_KEY)
//            setGradientViewColors()
//        } else {
//            setLocalColors(colors: viewColors, forKey: COLORS_KEY)
//        }
//    }
//
//    private func setLocalColors(colors: [UIColor], forKey key: String) {
//        defaults.set(colors, forKey: key)
//    }
//
//    private func setGradientViewColors() {
//        sharedView.firstColor = viewColors.first!
//        sharedView.secondColor = viewColors.last!
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
