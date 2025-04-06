//
//  File.swift
//  HatchChat
//
//  Created by Mohi Farhand on 2025-04-05.
//

import UIKit

extension UIFont {
    
    static func CDFontExtraBold(size: CGFloat) -> UIFont {
        return UIFont(name: "Poppins-ExtraBold", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    static func CDFontBold(size: CGFloat) -> UIFont {
        return UIFont(name: "Poppins-Bold", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }
    
    static func CDFontSemiBold(size: CGFloat) -> UIFont {
        return UIFont(name: "Poppins-SemiBold", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }
    
    static func CDFontMedium(size: CGFloat) -> UIFont {
        return UIFont(name: "Poppins-Medium", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }
    
    
    static func CDFontRegular(size: CGFloat) -> UIFont {
        return UIFont(name: "Poppins-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func CDFontLight(size: CGFloat) -> UIFont {
        return UIFont(name: "Poppins-Light", size: size) ?? UIFont.systemFont(ofSize: size)
    }
}

extension UIColor {
    static var HCBackground: UIColor {
        return UIColor(named: "HCBackground") ?? UIColor.systemPink
    }
    
    static var HCTextViewBackground: UIColor {
        return UIColor(named: "HCTextViewBackground") ?? UIColor.systemPink
    }
    
    static var HCCellBackground: UIColor {
        return UIColor(named: "HCCellBackground") ?? UIColor.systemBlue
    }
    
    static var HCMainLabel: UIColor {
        return UIColor(named: "HCMainLabel") ?? UIColor.label
    }
    
    static var HCSecondaryLabel: UIColor {
        return UIColor(named: "HCSecondaryLabel") ?? UIColor.label
    }
    
    
    
    
    
}
