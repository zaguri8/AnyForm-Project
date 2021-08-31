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
    
    
    func hideNavBar() {
        guard let navController = self.navigationController else {return}
        navController.setNavigationBarHidden(true, animated: false)
        
    }
    func showNavBar() {
        guard let navController = self.navigationController else {return}
        navController.setNavigationBarHidden(false, animated: true)
    }
    func hideTabBar() {
        guard let tabController = self.tabBarController else {return}
        tabController.tabBar.isHidden = true
    }
    func setTabBarColor(color:UIColor) {
        guard let tabController = self.tabBarController else {return}
        tabController.tabBar.barTintColor = color
    }
    
    func showTabBar() {
        guard let tabController = self.tabBarController else {return}
        tabController.tabBar.isHidden = false
    }
    
    func setGradientBackground() {
        let colorTop =  UIColor(red: 255.0/255.0, green: 149.0/255.0, blue: 0.0/255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 255.0/255.0, green: 94.0/255.0, blue: 58.0/255.0, alpha: 1.0).cgColor
                    
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds
                
        self.view.layer.insertSublayer(gradientLayer, at:0)
    }
    
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
extension UIView {
    enum Side {
            case top
            case bottom
            case left
            case right
        }

        func addBorder(to side: Side, color: UIColor, borderWidth: CGFloat) {
            let subLayer = CALayer()
            subLayer.borderColor = color.cgColor
            subLayer.borderWidth = borderWidth
            let origin = findOrigin(side: side, borderWidth: borderWidth)
            let size = findSize(side: side, borderWidth: borderWidth)
            subLayer.frame = CGRect(origin: origin, size: size)
            layer.addSublayer(subLayer)
        }

        private func findOrigin(side: Side, borderWidth: CGFloat) -> CGPoint {
            switch side {
            case .right:
                return CGPoint(x: frame.maxX - borderWidth, y: 0)
            case .bottom:
                return CGPoint(x: 0, y: frame.maxY - borderWidth)
            default:
                return .zero
            }
        }

        private func findSize(side: Side, borderWidth: CGFloat) -> CGSize {
            switch side {
            case .left, .right:
                return CGSize(width: borderWidth, height: frame.size.height)
            case .top, .bottom:
                return CGSize(width: frame.size.width, height: borderWidth)
            }
        }
    func layerGradient() {
        let layer : CAGradientLayer = CAGradientLayer()
        layer.frame.size = self.frame.size
        layer.frame.origin = CGPoint(x: 0.0,y: 0.0)
        layer.cornerRadius = CGFloat(frame.width / 20)

        let color0 = UIColor(red:250.0/255, green:250.0/255, blue:250.0/255, alpha:0.5).cgColor
        let color1 = UIColor(red:200.0/255, green:200.0/255, blue: 200.0/255, alpha:0.1).cgColor
        let color2 = UIColor(red:150.0/255, green:150.0/255, blue: 150.0/255, alpha:0.1).cgColor
        let color3 = UIColor(red:100.0/255, green:100.0/255, blue: 100.0/255, alpha:0.1).cgColor
        let color4 = UIColor(red:50.0/255, green:50.0/255, blue:50.0/255, alpha:0.1).cgColor
        let color5 = UIColor(red:0.0/255, green:0.0/255, blue:0.0/255, alpha:0.1).cgColor
        let color6 = UIColor(red:150.0/255, green:150.0/255, blue:150.0/255, alpha:0.1).cgColor

        layer.colors = [color0,color1,color2,color3,color4,color5,color6]
        self.layer.insertSublayer(layer, at: 0)
    }
    func addShadowAround(size:CGSize) {
        let shadowSize : CGFloat = 15.0
        let shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize / 2,
                                                    y: -shadowSize / 2,
                                                    width:  size.width + shadowSize,
                                                    height: size.height +  shadowSize))
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.4).cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 8
        self.layer.shadowPath = shadowPath.cgPath
    }
}

extension CGPoint {
    func pdfPoint(docView:UIView) -> CGPoint {
        // location.y = documentView.bounds.height - location.y
        return CGPoint(x:x ,y: docView.bounds.height - y)
    }
}
