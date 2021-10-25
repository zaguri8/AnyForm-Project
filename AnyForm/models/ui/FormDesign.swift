//
//  FormDesign.swift
//  AnyForm
//
//  Created by נדב אבנון on 26/07/2021.
//

import Foundation
import UIKit
protocol FormDesign : AnyObject {
    func questionCounterAttributes(text:String) -> NSAttributedString
    func questionTextAttributes(text:String) -> NSAttributedString
    func questionCheckBoxTextAttributrs(text:String) -> NSAttributedString
    func answerTextFieldAttributes(text:String) -> NSAttributedString
    func buttonsTextAttributes(text:String) -> NSAttributedString
    func backgroundColor() -> UIColor
    
    func holderBackgroundColor() -> UIColor
    func holderBorderColor() -> CGColor
    func holderBorderWidth() -> CGFloat
    
    func questionBoxColor() -> UIColor
    func questionBoxHeaderBgColor() -> UIColor
    func questionBoxBorderColor() -> CGColor
    func questionBoxBorderWidth() -> CGFloat
    func questionBoxCornerRadius() -> CGFloat
}
