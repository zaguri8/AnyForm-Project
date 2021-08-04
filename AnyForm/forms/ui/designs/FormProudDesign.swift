//
//  FormProudDesign.swift
//  AnyForm
//
//  Created by נדב אבנון on 26/07/2021.
//

import Foundation
import UIKit

class FormProudDesign : FormDesign {
  
    
    func questionBoxCornerRadius() -> CGFloat {
        8
    }
    
    func questionBoxColor() -> UIColor {
       hexStringToUIColor(hex: "FFFFFF")
    }
    
    func questionBoxBorderColor() -> CGColor {
        hexStringToUIColor(hex: "0D090A").cgColor
    }
    
    func questionBoxBorderWidth() -> CGFloat {
        1
    }
    
    func questionCounterAttributes(text: String) -> NSAttributedString {
        NSAttributedString(string: text, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 24),NSAttributedString.Key.foregroundColor : hexStringToUIColor(hex: "EAF2EF")])
    }
    
    func questionTextAttributes(text: String) -> NSAttributedString {
        NSAttributedString(string: text, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20),NSAttributedString.Key.foregroundColor : hexStringToUIColor(hex: "0D090A")])
    }
    func questionCheckBoxTextAttributrs(text: String) -> NSAttributedString {
        NSAttributedString(string: text, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 13),NSAttributedString.Key.foregroundColor : UIColor.black])
    }
    func questionBoxHeaderBgColor() -> UIColor {
        hexStringToUIColor(hex: "FFFFFF")
    }
    
    
    func answerTextFieldAttributes(text: String)  -> NSAttributedString {
       NSAttributedString(string: text, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 13),NSAttributedString.Key.foregroundColor : hexStringToUIColor(hex: "0D090A")])
    }
    
    
    func buttonsTextAttributes(text: String) -> NSAttributedString {
        NSAttributedString(string: text, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18),NSAttributedString.Key.foregroundColor : hexStringToUIColor(hex: "EAF2EF")])
    }
    
    func backgroundColor() -> UIColor {
        hexStringToUIColor(hex: "81171B")
    }
    
    func holderBackgroundColor() -> UIColor {
        hexStringToUIColor(hex: "81171B")
    }
    
    func holderBorderColor() -> CGColor {
        UIColor.white.cgColor
    }
    
    func holderBorderWidth() -> CGFloat {
        0.6
    }
}
