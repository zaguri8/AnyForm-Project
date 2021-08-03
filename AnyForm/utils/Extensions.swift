//
//  Extensions.swift
//  AnyForm
//
//  Created by נדב אבנון on 18/07/2021.
//

import Foundation
import UIKit
import PDFKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
       
}
extension Date {
    func string() -> String {
        let dateComponents = NSCalendar.current.dateComponents([.year, .month, .day], from: self)
            let year = String(dateComponents.year ?? 0)
            let month = String(dateComponents.month ?? 0)
            let day = String(dateComponents.day ?? 0)
        return "\(year) / \(month) / \(day)"
    }
}
extension PDFView {
    var scrollView: UIScrollView? {
        return subviews.first(where: { $0 is UIScrollView }) as? UIScrollView
    }
}

extension CGPoint {
    func pdfPoint(docView:UIView) -> CGPoint {
        // location.y = documentView.bounds.height - location.y
        return CGPoint(x:x ,y: docView.bounds.height - y)
    }
}
