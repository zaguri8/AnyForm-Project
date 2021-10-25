
//  FormElegantDesign.swift
//  AnyForm
//
//  Created by נדב אבנון on 26/07/2021.
//

import Foundation
import UIKit
class FormLightDesign : FormDesign {
    
    func questionBoxCornerRadius() -> CGFloat {
        8
    }
    
    func questionBoxColor() -> UIColor {
       UIUtils.hexStringToUIColor(hex: "FFFFFF")
    }
    
    func questionBoxBorderColor() -> CGColor {
        UIUtils.hexStringToUIColor(hex: "639FAB").cgColor
    }
    
    func questionBoxBorderWidth() -> CGFloat {
        1
    }
    
    func questionCounterAttributes(text: String) -> NSAttributedString {
        NSAttributedString(string: text, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 24),NSAttributedString.Key.foregroundColor : UIUtils.hexStringToUIColor(hex: "FFFFFF")])
    }
    
    func questionTextAttributes(text: String) -> NSAttributedString {
        NSAttributedString(string: text, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20),NSAttributedString.Key.foregroundColor : UIUtils.hexStringToUIColor(hex: "222222")])
    }
    func questionCheckBoxTextAttributrs(text: String) -> NSAttributedString {
        NSAttributedString(string: text, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 13),NSAttributedString.Key.foregroundColor : UIColor.black])
    }
    func questionBoxHeaderBgColor() -> UIColor {
        UIUtils.hexStringToUIColor(hex: "FFFFFF")
    }
    
    
    func answerTextFieldAttributes(text: String) -> NSAttributedString {
        NSAttributedString(string: text, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 13),NSAttributedString.Key.foregroundColor : UIUtils.hexStringToUIColor(hex: "222222")])
    }
    
    func buttonsTextAttributes(text: String) -> NSAttributedString {
        NSAttributedString(string: text, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18),NSAttributedString.Key.foregroundColor : UIUtils.hexStringToUIColor(hex: "FFFFFF")])
    }
    
    func backgroundColor() -> UIColor {
        UIUtils.hexStringToUIColor(hex: "1C5D99")
    }
    
    func holderBackgroundColor() -> UIColor {
        UIUtils.hexStringToUIColor(hex: "1C5D99")
    }
    
    func holderBorderColor() -> CGColor {
        UIColor.white.cgColor
    }
    
    func holderBorderWidth() -> CGFloat {
        0.6
    }
}
