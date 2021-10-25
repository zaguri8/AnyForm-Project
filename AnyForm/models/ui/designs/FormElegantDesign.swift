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
       UIUtils.hexStringToUIColor(hex: "F2F4F3")
    }
    
    func questionBoxBorderColor() -> CGColor {
        UIColor.clear.cgColor
    }
    
    func questionBoxBorderWidth() -> CGFloat {
        1
    }
    
    func questionCounterAttributes(text: String) -> NSAttributedString {
        NSAttributedString(string: text, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 24),NSAttributedString.Key.foregroundColor : UIColor.systemOrange])
    }
    
    
    func questionTextAttributes(text: String) -> NSAttributedString {
        NSAttributedString(string: text, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18),NSAttributedString.Key.foregroundColor : UIColor.white])
    }
    func questionCheckBoxTextAttributrs(text: String) -> NSAttributedString {
        NSAttributedString(string: text, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16),NSAttributedString.Key.foregroundColor : UIColor.black])
    }
    
    func questionBoxHeaderBgColor() -> UIColor {
        UIColor.systemOrange.withAlphaComponent(0.9)
    }
    
    func answerTextFieldAttributes(text: String)  -> NSAttributedString {
        NSAttributedString(string: text, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16),NSAttributedString.Key.foregroundColor : UIColor.black])
    }
    
    func buttonsTextAttributes(text: String) -> NSAttributedString {
        NSAttributedString(string: text, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18),NSAttributedString.Key.foregroundColor : UIUtils.hexStringToUIColor(hex: "F2F4F3")])
    }
    
    
    func backgroundColor() -> UIColor {
        UIUtils.hexStringToUIColor(hex: "F8F7F5")
    }
    
    func holderBackgroundColor() -> UIColor {
        UIColor.clear
    }
    
    func holderBorderColor() -> CGColor {
        UIColor.clear.cgColor
    }
    
    func holderBorderWidth() -> CGFloat {
        0.6
    }
    func setElegantGradientBackground(backgroundView:UIView) {
        let colorTop =  UIColor.orange
        let colorBottom = UIColor.white
                    
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = backgroundView.bounds
                
        backgroundView.layer.insertSublayer(gradientLayer, at:0)
    }
    
}
