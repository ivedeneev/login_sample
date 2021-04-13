//
//  Color.swift
//  mycars-ios
//
//  Created by Igor Vedeneev on 4/1/20.
//  Copyright © 2020 AGIMA. All rights reserved.
//

import UIKit


final class Color {

    /// Returns: ffffff
    static func background() -> UIColor {
        return color(light: "#ffffff", dark: "#222222")
    }
    
    static func secondaryBackground() -> UIColor {
        return color(light: "#dddddd", dark: "#666666")
    }

    /// - Returns: 000000
    static func text() -> UIColor {
        return color(light: "#000000", dark: "#ffffff")
    }
    
    static func secondaryText() -> UIColor {
        return color(light: "#999999", dark: "#aaaaaa")
    }
    
    /// - Returns: #B8C2DA
    static func accent() -> UIColor {
        return color(light: "#24B763", dark: "#24B763")
    }

    /// - Returns: #B8C2DA
    static func placeholder() -> UIColor {
        return color(light: "#B8C2DA", dark: "#B8C2DA")
    }

    /// - Returns: #30C884
    static func green() -> UIColor {
        return color(light: "#30C884", dark: "#30C884")
    }

    /// - Returns: #FF545E
    static func red() -> UIColor {
        return color(light: "#FF545E", dark: "#FF545E2")
    }

    /// - Returns: #7E88A4
    static func lightGrayText() -> UIColor {
        return color(light: "#7E88A4", dark: "#7E88A4")
    }

    static func lightGreen() -> UIColor {
        return color(light: "#1EC078", dark: "#1EC078")
    }
}

extension Color {
    private static func color(light: String, dark: String) -> UIColor {
        if #available(iOS 13, *) {
            return UIColor { (trait) -> UIColor in
                let hexColor =  trait.userInterfaceStyle == .dark ? dark : light
                return UIColor(hexString: hexColor)
            }
        }
        else {
            return UIColor(hexString: light)
        }
    }
}

extension UIColor {
    
    /**
     Makes UIColor with hex string
     */
    convenience init(withHexString hex: String) {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        switch cString.count {
        case 6:
            self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                      green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                      blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                      alpha: CGFloat(1.0))
        case 8:
            self.init(
                red: CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0,
                green: CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0,
                blue: CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0,
                alpha: CGFloat(rgbValue & 0x000000FF) / 255.0)
        default:
            print("probably invalid hex: \(hex)")
            self.init(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }
    
    convenience init(hex: Int, alpha: CGFloat = 1) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        
        self.init(red: components.R, green: components.G, blue: components.B, alpha: alpha)
    }
    
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    convenience init(r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat) {
        let components = (
            R: r/255.0,
            G: g/255.0,
            B: b/255.0
        )
        self.init(red: components.R, green: components.G, blue: components.B, alpha: a)
    }
    
    /// highlighted version of color. Typical use case is changing background color for highlighted state at `UIButton`
    var highlighted: UIColor {
        guard let components = getRGBAComponents() else { return self }
        let r = components.red * 0.9 * 255
        let g = components.green * 0.9 * 255
        let b = components.blue * 0.9 * 255
        return UIColor.init(r: r, g: g, b: b, a: components.alpha)
    }
    
    func highlighted(_ isHighlighted: Bool) -> UIColor {
        return isHighlighted ? highlighted : self
    }
    
    func getRGBAComponents() -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        var (red, green, blue, alpha) = (CGFloat(0.0), CGFloat(0.0), CGFloat(0.0), CGFloat(0.0))
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        {
            return (red, green, blue, alpha)
        }
        else
        {
            return nil
        }
    }
}
