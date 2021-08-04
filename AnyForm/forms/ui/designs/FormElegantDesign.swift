//
//  EggPlantDesign.swift
//  AnyForm
//
//  Created by נדב אבנון on 26/07/2021.
//

import Foundation
import UIKit
//685369
class FormElegantDesign : FormDesign {
    func questionBoxCornerRadius() -> CGFloat {
        8
    }
    
    func questionBoxColor() -> UIColor {
       hexStringToUIColor(hex: "F2F4F3")
    }
    
    func questionBoxBorderColor() -> CGColor {
        hexStringToUIColor(hex: "5E503F").cgColor
    }
    
    func questionBoxBorderWidth() -> CGFloat {
        1
    }
    
    func questionCounterAttributes(text: String) -> NSAttributedString {
        NSAttributedString(string: text, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 24),NSAttributedString.Key.foregroundColor : hexStringToUIColor(hex: "F2F4F3")])
    }
    
    
    func questionTextAttributes(text: String) -> NSAttributedString {
        NSAttributedString(string: text, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18),NSAttributedString.Key.foregroundColor : UIColor.white])
    }
    func questionCheckBoxTextAttributrs(text: String) -> NSAttributedString {
        NSAttributedString(string: text, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 13),NSAttributedString.Key.foregroundColor : UIColor.black])
    }
    
    func questionBoxHeaderBgColor() -> UIColor {
        hexStringToUIColor(hex: "0F9A99")
    }
    
    func answerTextFieldAttributes(text: String)  -> NSAttributedString {
        NSAttributedString(string: text, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 13),NSAttributedString.Key.foregroundColor : UIColor.black])
    }
    
    func buttonsTextAttributes(text: String) -> NSAttributedString {
        NSAttributedString(string: text, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18),NSAttributedString.Key.foregroundColor : hexStringToUIColor(hex: "F2F4F3")])
    }
    
    
    func backgroundColor() -> UIColor {
        hexStringToUIColor(hex: "22333B")
    }
    
    func holderBackgroundColor() -> UIColor {
        hexStringToUIColor(hex: "22333B")
    }
    
    func holderBorderColor() -> CGColor {
        UIColor.white.cgColor
    }
    
    func holderBorderWidth() -> CGFloat {
        0.6
    }
    
}
