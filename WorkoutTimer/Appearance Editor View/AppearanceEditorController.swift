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

}


class AppearanceEditorController: UIViewController, HSBColorPickerDelegate {
    
    

    @IBOutlet var gradientView: GradientBackgroundView!
    @IBOutlet weak var color1Button: UIButton!
    @IBOutlet weak var color2Button: UIButton!
    @IBOutlet weak var colorPicker: HSBColorPicker!
    
    @IBAction func color1BtnTapped(_ sender: UIButton) {
        currentColorIndex = 0
        colorPicker.setIsHidden(!colorPicker.isHidden, animated: true)
    }
    
    @IBAction func color2BtnTapped(_ sender: UIButton) {
        currentColorIndex = 1
        colorPicker.setIsHidden(!colorPicker.isHidden, animated: true)
    }

    
    func updateViewColors() {
        //DispatchQueue.main.async {
//            let newView = GradientBackgroundView()
//            newView.startColor = StyledGradientView.viewColors[0]
//            newView.endColor = StyledGradientView.viewColors[1]
//
//            self.gradientView = newView
            self.gradientView.startColor = StyledGradientView.viewColors[0]
            self.gradientView.endColor = StyledGradientView.viewColors[1]
            self.gradientView.setNeedsDisplay()
            //let mRect = CGRect(x: 0, y: 0, width: 100, height: 100)
            //self.gradientView.draw(mRect)
            
            
            //print(String(self.gradientView.startColor?.toHex ?? "no hex color"))
           // print(String(self.gradientView.endColor?.toHex ?? "no hex color"))
           // print("***COMPLETED COLOR CHANGE***")
        //}
        
    }
    
    func HSBColorColorPickerTouched(sender: HSBColorPicker, color: UIColor, point: CGPoint, state: UIGestureRecognizer.State) {
//        let prevColor = StyledGradientView.viewColors[currentColorIndex]
        StyledGradientView.viewColors[currentColorIndex] = color
        
        //print("Colors are equal before and after: \(StyledGradientView.viewColors[currentColorIndex] == prevColor)")
        updateViewColors()
        
        colorPicker.setIsHidden(true, animated: true)

    }
    
    var currentColorIndex = 0
    var darkModeEnabled = false
    var usingDefaultColors = true
    
    
    
    var handleIDMap:[Int:Int] = [:]
    
    let sharedView:GradientBackgroundView = StyledGradientView.shared
    
    //let colorPicker:HSBColorPicker = HSBColorPicker()
    
    
    //let colorPicker = ChromaColorPicker(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        color1Button.isEnabled = true
        color2Button.isEnabled = true
        if #available(iOS 13.4, *) {
            color1Button.isPointerInteractionEnabled = true
            color2Button.isPointerInteractionEnabled = true
        }
        color1Button.isUserInteractionEnabled = true
        color2Button.isUserInteractionEnabled = true
        gradientView.bringSubviewToFront(color1Button)
        gradientView.bringSubviewToFront(color2Button)
        StyledGradientView.setup()
        //gradientView = sharedView
        setupColorPicker()
        configNavBar()
        refreshButtons()
        
        //self.darkModeEnabled = (self.traitCollection.userInterfaceStyle == .dark)
        
    }
    
    private func refreshButtons() {
        let buttonTitleFont = UIFont(name: "Avenir Next", size: 14.0)
        
        color1Button.titleLabel?.isHidden = false
        color2Button.titleLabel?.isHidden = false
        
        color1Button.titleLabel?.font = buttonTitleFont
        color2Button.titleLabel?.font = buttonTitleFont
        
        color1Button.titleLabel?.textColor = .black
        color1Button.titleLabel?.textColor = .black
        
        //color1Button.backgroundColor = .blue
        //color2Button.backgroundColor = .blue
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
        colorPicker.elementSize = 5
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
