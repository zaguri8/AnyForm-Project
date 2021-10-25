//
//  UIUtils.swift
//  AnyForm
//
//  Created by נדב אבנון on 18/07/2021.
//

import Foundation
import UIKit
class UIUtils {
static func animateDuration(_ block: @escaping () -> Void,completion:@escaping (Bool) -> Void = { bool in },delay:TimeInterval = 0,duration:TimeInterval) {
    UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 1, initialSpringVelocity: 0.8, options: [], animations: block, completion: completion)
}

static func hexStringToUIColor (hex:String) -> UIColor {
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
}
