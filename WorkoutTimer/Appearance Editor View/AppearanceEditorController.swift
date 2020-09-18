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

public extension UIDevice {
    
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String {
            #if os(iOS)
            switch identifier {
            
            case "iPod9,1":                                 return "iPod touch (7th generation)"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPhone12,1":                              return "iPhone 11"
            case "iPhone12,3":                              return "iPhone 11 Pro"
            case "iPhone12,5":                              return "iPhone 11 Pro Max"
            case "iPhone12,8":                              return "iPhone SE (2nd generation)"
            case "i386", "x86_64":                          return "\(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #endif
        }
        
        return mapToDevice(identifier: identifier)
    }()
    
}


//@available(iOS 14.0, *)
class AppearanceEditorController: UIViewController, UIColorPickerViewControllerDelegate {

    @IBOutlet weak var gradientColorsLabel: UILabel!
    @IBOutlet var gradientView: GradientBackgroundView!
    @IBOutlet weak var color1Button: UIButton!
    @IBOutlet weak var color2Button: UIButton!
    @IBOutlet weak var backingView: UIView!
    
    let startColorPicker = UIColorPickerViewController()
    let endColorPicker = UIColorPickerViewController()
    
    @IBAction func color1BtnTapped(_ sender: UIButton) {
        color2Button.isEnabled = !color2Button.isEnabled
        self.present(startColorPicker, animated: true, completion: nil)
    }
    
    @IBAction func color2BtnTapped(_ sender: UIButton) {
        color1Button.isEnabled = !color1Button.isEnabled
        self.present(endColorPicker, animated: true, completion: nil)
    }
    
    
    func updateViewColors() {
        self.gradientView.startColor = StyledGradientView.viewColors.first!
        self.gradientView.endColor = StyledGradientView.viewColors.last!
        self.gradientView.setNeedsDisplay()
    }
    
    
    let sharedView:GradientBackgroundView = StyledGradientView.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupColorPickers()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        color1Button.isUserInteractionEnabled = true
        color2Button.isUserInteractionEnabled = true
        
        StyledGradientView.setup()
        configNavBar()
        setUIElements()
        
        roundUIView(color1Button)
        roundUIView(color2Button)
        roundUIView(backingView)
    }
    
    
    private func roundUIView(_ view:UIView) { //round the corners of the button passed in
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
    }
    
    private func configBackingViewSpacing() {
        let modelName = UIDevice.modelName
        print("Model: \(modelName)")
        if (modelName == "iPhone 8" || modelName == "iPhone SE (2nd generation)") {
            NSLayoutConstraint.activate([
                backingView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -425)
            ])
        } else if (modelName == "iPhone 8 Plus") {
            NSLayoutConstraint.activate([
                backingView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -480)
            ])
        } else if (modelName == "iPhone 11 Pro Max") {
            NSLayoutConstraint.activate([
                backingView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -540)
            ])
        } else if (modelName == "iPod touch (7th generation)") {
            NSLayoutConstraint.activate([
                backingView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -320)
            ])
        } else if (modelName == "iPhone XR") {
            NSLayoutConstraint.activate([
                backingView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -520)
            ])
        }
    }
    
    private func setUIElements() {
        let buttonTitleFont = UIFont(name: "Avenir Next", size: 15.0)
        
        color1Button.backgroundColor = StyledGradientView.viewColors.first!
        color2Button.backgroundColor = StyledGradientView.viewColors.last!
        
        color1Button.titleLabel?.font = buttonTitleFont
        color2Button.titleLabel?.font = buttonTitleFont
        
        if (color1Button.backgroundColor!.isLight()) {
            color1Button.setTitleColor(.black, for: .normal)
        } else {
            color1Button.setTitleColor(.white, for: .normal)
        }
        
        if (color2Button.backgroundColor!.isLight()) {
            color2Button.setTitleColor(.black, for: .normal)
        } else {
            color2Button.setTitleColor(.white, for: .normal)
        }
        
        if (StyledGradientView.viewColors.first!.isLight()){
            gradientColorsLabel.textColor = .black
        } else {
            gradientColorsLabel.textColor = .white
        }
        
        self.navigationController?.navigationBar.tintColor = StyledGradientView.viewColors.last!
    }
    
    private func configNavBar() {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationItem.hidesBackButton = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configBackingViewSpacing()
        updateViewColors()
    }
    
    private func setupColorPickers() {
        startColorPicker.delegate = self
        endColorPicker.delegate = self
        startColorPicker.supportsAlpha = false
        endColorPicker.supportsAlpha = false
        startColorPicker.selectedColor = StyledGradientView.viewColors[0]
        endColorPicker.selectedColor = StyledGradientView.viewColors[1]
        startColorPicker.title = "Gradient Start Color"
        endColorPicker.title = "Gradient End Color"
    }
    
    
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        if (viewController == startColorPicker) {
            StyledGradientView.viewColors[0] = viewController.selectedColor
        } else {
            StyledGradientView.viewColors[1] = viewController.selectedColor
        }
        updateViewColors()
        setUIElements()
    }
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        color1Button.isEnabled = true
        color2Button.isEnabled = true
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
