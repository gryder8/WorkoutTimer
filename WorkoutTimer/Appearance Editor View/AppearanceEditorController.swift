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
    
    @IBAction func color1ButtonTapped(_ sender: UIButton) {
        gradientViewButtonsParentView.bringSubviewToFront(colorPicker)
        colorPicker.isHidden = false
        brightnessSlider.isHidden = false
    }
    
    @IBAction func color2ButtonTapped(_ sender: UIButton) {
        
    }
    
    
    var darkModeEnabled = false
    var usingDefaultColors = true
    
    var lastUsedHandle:ChromaColorHandle = ChromaColorHandle()
    
    var handleIDMap:[Int:Int] = [:]
    
    let sharedView:GradientView = StyledGradientView.shared
    
    
    
    let colorPicker = ChromaColorPicker(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
    let brightnessSlider = ChromaBrightnessSlider(frame: CGRect(x: 0, y: 0, width: 280, height: 32))
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StyledGradientView.setup()
        gradientView = sharedView
        setupColorPicker()
        configNavBar()
        refreshButtons()
        
        //self.darkModeEnabled = (self.traitCollection.userInterfaceStyle == .dark)
        
    }
    
    private func refreshButtons() {
        color1Button.titleLabel?.isHidden = true
        color2Button.titleLabel?.isHidden = true
        
        color1Button.backgroundColor = StyledGradientView.viewColors[0]
        color2Button.backgroundColor = StyledGradientView.viewColors[1]
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

        gradientViewButtonsParentView.addSubview(brightnessSlider)
        brightnessSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        colorPicker.connect(brightnessSlider)
        
        let handle1:ChromaColorHandle = ChromaColorHandle(color: StyledGradientView.viewColors[0])
        handleIDMap[handle1.hashValue] = 0 //map to the index of the viewColor array we want this handle to modify
        colorPicker.addTarget(self, action: #selector(handleReleased(_:)), for: .touchUpInside)
        colorPicker.addHandle(handle1)
        
        let handle2:ChromaColorHandle = ChromaColorHandle(color: StyledGradientView.viewColors[1])
        handleIDMap[handle2.hashValue] = 1 //map to the index of the viewColor array we want this handle to modify
        colorPicker.addHandle(handle2)
        
        colorPicker.isHidden = true
        brightnessSlider.isHidden = true
        
        //let midX = gradientViewButtonsParentView.frame.midX
        let minY = gradientViewButtonsParentView.frame.midY
        let minX = gradientViewButtonsParentView.frame.minX
        //let maxX = gradientViewButtonsParentView.frame.maxX
        colorPicker.frame = CGRect(x: minX, y: minY, width: gradientViewButtonsParentView.frame.width / 1.3, height: gradientViewButtonsParentView.frame.width / 1.25)
        brightnessSlider.frame = CGRect(x: minX, y: colorPicker.frame.maxY + 5, width: colorPicker.frame.width / 1.5, height: 20)
    }
    
    
    @objc func sliderValueChanged(_ slider: ChromaBrightnessSlider) {
        let lastUsedHandleID:Int = handleIDMap[lastUsedHandle.hashValue]!
        StyledGradientView.viewColors[lastUsedHandleID] = slider.currentColor
        StyledGradientView.setColorsForGradientView(view: gradientView)
    }
    
    @objc func handleReleased(_ handle:ChromaColorHandle) {
        lastUsedHandle = handle
        let handleID:Int = handleIDMap[handle.hashValue]!
        StyledGradientView.viewColors[handleID] = handle.color
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
