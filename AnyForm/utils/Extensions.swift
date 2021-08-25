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
    
    
    struct PropertyHolder {
         static var showingToast:Bool = false
     }
     var showingToast:Bool {
         get {
             return PropertyHolder.showingToast
         }
         set(newValue) {
            PropertyHolder.showingToast = newValue
         }
     }
    
    func showAnyFormToast(message:String,boxColor:UIColor = .orange.withAlphaComponent(0.8),borderColor:UIColor = .black, textColor:UIColor = .black, font:UIFont = .boldSystemFont(ofSize: 12), duration:TimeInterval = 3) {
        guard let window  = view.window, !showingToast else {return}
        let parentHeight = view.frame.size.height
        let messageBoxSize = CGSize(width: window.frame.width / 1.7, height: 60)
        let messageBoxPos = CGPoint(x: messageBoxSize.width / 2.7, y: parentHeight)
        let messageBox = UIView(frame: CGRect(origin: messageBoxPos, size: messageBoxSize))
        messageBox.insetsLayoutMarginsFromSafeArea = false
        messageBox.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        messageBox.backgroundColor = boxColor
        messageBox.layer.borderWidth = 0.6
        messageBox.layer.borderColor = borderColor.cgColor
        messageBox.layer.cornerRadius = messageBoxSize.height / 2
        let label = UILabel()
        label.textColor = textColor
        label.text = message
        label.numberOfLines = 3
        label.font = font
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        messageBox.addSubview(label)
        label.centerXAnchor.constraint(equalTo: messageBox.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: messageBox.centerYAnchor).isActive = true
        label.widthAnchor.constraint(equalToConstant: messageBoxSize.width ).isActive = true
        label.heightAnchor.constraint(equalToConstant: messageBoxSize.height / 1.5).isActive = true
        let removeTask:() -> Void = {
            UIView.animate(withDuration: 0.7) {
               messageBox.frame.origin.y = parentHeight
                messageBox.layoutIfNeeded()
            } completion: {[weak self] b in
                messageBox.removeFromSuperview()
                self?.showingToast = false
            }
        }
        
        window.addSubview(messageBox)
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.8, options: []) {
            messageBox.frame.origin.y = parentHeight - 80
        } completion: { b in
            DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: removeTask)
        }
        showingToast = true
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
