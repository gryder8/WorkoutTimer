//
//  AppearanceEditorController.swift
//  WorkoutTimer
//
//  Created by Gavin Ryder on 9/7/20.
//  Copyright © 2020 Gavin Ryder. All rights reserved.
//

import UIKit

extension UIColor {

    // MARK: - Initialization

    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0

        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, alpha: a)
    }

    // MARK: - Computed Properties

    var toHex: String? {
        return toHex()
    }

    // MARK: - From UIColor to String

    func toHex(alpha: Bool = false) -> String? {
        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }

        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)

        if components.count >= 4 {
            a = Float(components[3])
        }

        if alpha {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
    
    func isLight() -> Bool
    {
        // algorithm from: http://www.w3.org/WAI/ER/WD-AERT/#color-contrast
        let components = self.cgColor.components
        let temp = ((components![0] * 299) + (components![1] * 587) + (components![2] * 114))
        let brightness =  temp / 1000

        if brightness < 0.5
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    func add(_ overlay: UIColor) -> UIColor {
        var bgR: CGFloat = 0
        var bgG: CGFloat = 0
        var bgB: CGFloat = 0
        var bgA: CGFloat = 0
        
        var fgR: CGFloat = 0
        var fgG: CGFloat = 0
        var fgB: CGFloat = 0
        var fgA: CGFloat = 0
        
        self.getRed(&bgR, green: &bgG, blue: &bgB, alpha: &bgA)
        overlay.getRed(&fgR, green: &fgG, blue: &fgB, alpha: &fgA)
        
        let r = fgA * fgR + (1 - fgA) * bgR
        let g = fgA * fgG + (1 - fgA) * bgG
        let b = fgA * fgB + (1 - fgA) * bgB
        
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
    
    static func +(lhs: UIColor, rhs: UIColor) -> UIColor {
        return lhs.add(rhs)
    }

}

extension Float {
    func asStringWithNoDecimal() -> String {
        return String("\(self)").components(separatedBy: ".")[0]
    }
}

extension Double {
    func asStringWithNoDecimal() -> String {
        return String("\(self)").components(separatedBy: ".")[0]
    }
}



class AppearanceEditorController: UIViewController, HSBColorPickerDelegate {
    
    let ELEMENT_SIZE_KEY = "ELEMENT_SIZE"
    
    @IBOutlet weak var gradientColorsLabel: UILabel!
    @IBOutlet var gradientView: GradientBackgroundView!
    @IBOutlet weak var color1Button: UIButton!
    @IBOutlet weak var color2Button: UIButton!
    @IBOutlet weak var colorPicker: HSBColorPicker!
    @IBOutlet weak var tileSizeLabel: UILabel!
    @IBOutlet weak var tileSizeStepper: UIStepper!
    @IBOutlet weak var tileSizeSlider: UISlider!
    @IBOutlet weak var tileSizeElementLabel: UILabel!
    
    
    @IBAction func color1BtnTapped(_ sender: UIButton) {
        currentColorIndex = 0
        colorPicker.setIsHidden(!colorPicker.isHidden, animated: true)
        color2Button.isEnabled = !color2Button.isEnabled
        hideSliderElements(!tileSizeSlider.isHidden)
    }
    
    @IBAction func color2BtnTapped(_ sender: UIButton) {
        currentColorIndex = 1
        colorPicker.setIsHidden(!colorPicker.isHidden, animated: true)
        color1Button.isEnabled = !color1Button.isEnabled
        hideSliderElements(!tileSizeSlider.isHidden)
    }

    @IBAction func elementSizeValChanged(_ sender: UISlider) {
        let roundedValue = round(sender.value)
        sender.value = roundedValue
        self.pickerElementSize = CGFloat(sender.value)
        colorPicker.elementSize = self.pickerElementSize
        tileSizeStepper.value = Double(sender.value)
        tileSizeLabel.text = sender.value.asStringWithNoDecimal()
    }
    
    @IBAction func tileSizeStepperChanged(_ sender: UIStepper) {
        let roundedValue = round(sender.value)
        sender.value = roundedValue
        tileSizeSlider.value = Float(sender.value)
        self.pickerElementSize = CGFloat(sender.value)
        colorPicker.elementSize = self.pickerElementSize
        tileSizeLabel.text = sender.value.asStringWithNoDecimal()
    }
    
    func updateViewColors() {
        self.gradientView.startColor = StyledGradientView.viewColors.first!
        self.gradientView.endColor = StyledGradientView.viewColors.last!
            self.gradientView.setNeedsDisplay()
    }
    
    func HSBColorColorPickerTouched(sender: HSBColorPicker, color: UIColor, point: CGPoint, state: UIGestureRecognizer.State) {
        StyledGradientView.viewColors[currentColorIndex] = color
        
        updateViewColors()
        refreshUIElements()
        colorPicker.setIsHidden(true, animated: true)
        hideSliderElements(true)
        color1Button.isEnabled = true
        color2Button.isEnabled = true

    }
    
    var currentColorIndex = 0
    
    let sharedView:GradientBackgroundView = StyledGradientView.shared
    
    let defaults = UserDefaults.standard
    
    var pickerElementSize:CGFloat = 10 {
        didSet {
            defaults.set(Float(pickerElementSize), forKey: ELEMENT_SIZE_KEY)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLocalElementSize()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        color1Button.isUserInteractionEnabled = true
        color2Button.isUserInteractionEnabled = true
        //gradientView.bringSubviewToFront(color1Button)
        //gradientView.bringSubviewToFront(color2Button)
        StyledGradientView.setup()
        //gradientView = sharedView
        setupColorPicker()
        configNavBar()
        refreshUIElements()
        
        roundButton(color1Button)
        roundButton(color2Button)
        hideSliderElements(true)
        //self.darkModeEnabled = (self.traitCollection.userInterfaceStyle == .dark)
        
    }
    
    private func loadLocalElementSize() {
        if (defaults.float(forKey: ELEMENT_SIZE_KEY) != 0) {
            self.pickerElementSize = CGFloat(defaults.float(forKey: ELEMENT_SIZE_KEY))
        } else {
            defaults.set(Float(self.pickerElementSize), forKey: ELEMENT_SIZE_KEY)
        }
    }
    
    private func hideSliderElements(_ hidden:Bool) {
        tileSizeSlider.setIsHidden(hidden, animated: true)
        tileSizeLabel.setIsHidden(hidden, animated: true)
        tileSizeStepper.setIsHidden(hidden, animated: true)
        tileSizeElementLabel.setIsHidden(hidden, animated: true)
    }
    
    private func roundButton(_ button:UIButton) { //round the corners of the button passed in
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
    }
    
    private func refreshUIElements() {
        let buttonTitleFont = UIFont(name: "Avenir Next", size: 15.0)
        let tileSliderLabelFont = UIFont(name: "Avenir Next", size: 20.0)
        
        tileSizeSlider.value = Float(self.pickerElementSize)
        tileSizeStepper.value = Double(tileSizeSlider.value)
        tileSizeLabel.text = tileSizeSlider.value.asStringWithNoDecimal()
        
        color1Button.backgroundColor = StyledGradientView.viewColors.last!
        color2Button.backgroundColor = StyledGradientView.viewColors.last!
        
        //color1Button.titleLabel?.isHidden = false
        //color2Button.titleLabel?.isHidden = false
        
        color1Button.titleLabel?.font = buttonTitleFont
        color2Button.titleLabel?.font = buttonTitleFont
        
        tileSizeSlider.minimumTrackTintColor = StyledGradientView.viewColors.first!
        tileSizeSlider.thumbTintColor = StyledGradientView.viewColors.last!
        
        if (color1Button.backgroundColor!.isLight()) {
            color1Button.setTitleColor(.black, for: .normal)
            color2Button.setTitleColor(.black, for: .normal)
        } else {
            color1Button.setTitleColor(.white, for: .normal)
            color2Button.setTitleColor(.white, for: .normal)
        }
        
        if (StyledGradientView.viewColors.first!.isLight()) {
            gradientColorsLabel.textColor = .black
        } else {
            gradientColorsLabel.textColor = .white
        }
        
        
        tileSizeLabel.font = tileSliderLabelFont
        if (StyledGradientView.viewColors.last!.isLight()) {
            tileSizeElementLabel.textColor = .black
            tileSizeLabel.textColor = .darkGray
        } else {
            tileSizeElementLabel.textColor = .white
            tileSizeLabel.textColor = .lightGray
        }
        
        self.navigationController?.navigationBar.tintColor = StyledGradientView.viewColors.last!

        
        
        //print("Button Color: \(color1Button.titleLabel?.textColor.toHex)")
        
        
    }
    
    private func configNavBar() {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        //self.navigationController?.navigationBar.barTintColor = gradientView.startColor
        self.navigationController?.view.backgroundColor = .clear
        self.navigationController?.navigationBar.tintColor = .black
        navigationItem.hidesBackButton = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateViewColors()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //updateViewColors()
        //print("Shared view color: \(String(sharedView.firstColor.toHex ?? "no hex"))")
    }
    
    private func setupColorPicker() {
        colorPicker.delegate = self
        colorPicker.setIsHidden(true, animated: false)
        colorPicker.elementSize = self.pickerElementSize
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
