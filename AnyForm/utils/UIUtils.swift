//
//  UIUtils.swift
//  AnyForm
//
//  Created by נדב אבנון on 18/07/2021.
//

import Foundation
import UIKit
struct Constraint {
    var from:UIView
    var to:UIView
    var constant:CGFloat
    init(_ from:UIView,_ to:UIView,_ constant:CGFloat) {
        self.from = from
        self.to = to
        self.constant = constant
    }
}

func animate(_ block: @escaping () -> Void,completion:@escaping (Bool) -> Void = { bool in },delay:TimeInterval = 0,duration:TimeInterval) {
    UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 1, initialSpringVelocity: 0.8, options: [], animations: block, completion: completion)
}

func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }

    if ((cString.count) != 6) {
        return UIColor.gray
    }

    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)

    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}
func constraints(top:Constraint? = nil,bottom:Constraint? = nil,leading:Constraint? = nil,trailing:Constraint? = nil) {
    var c:[NSLayoutConstraint] = []
    if let top = top {
        c.append(top.from.topAnchor.constraint(equalTo: top.to.topAnchor,constant: top.constant))
    }
    if let bottom = bottom {
        c.append(bottom.from.bottomAnchor.constraint(equalTo: bottom.to.bottomAnchor,constant: -bottom.constant))
    }
    if let leading = leading {
        c.append(leading.from.leadingAnchor.constraint(equalTo: leading.to.leadingAnchor,constant: leading.constant))
    }
    
    if let trailing = trailing {
        c.append(trailing.from.trailingAnchor.constraint(equalTo: trailing.to.trailingAnchor,constant: -trailing.constant))
    }
    NSLayoutConstraint.activate(c)
    
}
