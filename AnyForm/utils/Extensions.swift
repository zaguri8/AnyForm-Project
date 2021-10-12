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
        label.heightAnchor.constraint(equalToConstant: messageBoxSize.height).isActive = true
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
extension String {
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
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
    
    func enableCustomConstraints() {
        if translatesAutoresizingMaskIntoConstraints  {
            translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func constraintTopToTopOf(_ view:UIView,_ spacing:CGFloat = 0,safe:Bool = false) {
        enableCustomConstraints()
        let anchor:NSLayoutAnchor = safe ? view.safeAreaLayoutGuide.topAnchor : view.topAnchor
        let constraint = topAnchor.constraint(equalTo: anchor,constant: spacing)
        constraint.identifier = "top" + String(hash)
        constraint.isActive = true
    }
    
    func constraintTopToBottomOf(_ view:UIView,_ spacing:CGFloat = 0,safe:Bool = false) {
        enableCustomConstraints()
        let anchor:NSLayoutAnchor = safe ? view.safeAreaLayoutGuide.bottomAnchor : view.bottomAnchor
        let constraint = topAnchor.constraint(equalTo: anchor,constant: spacing)
        constraint.identifier = "top" + String(hash)
        constraint.isActive = true
    }
    
    func constraintBottomToTopOf(_ view:UIView,_ spacing:CGFloat = 0,safe:Bool = false) {
        enableCustomConstraints()
        let anchor:NSLayoutAnchor = safe ? view.safeAreaLayoutGuide.topAnchor : view.topAnchor
        let constraint =  bottomAnchor.constraint(equalTo: anchor,constant: -spacing)
        constraint.identifier = "bottom" + String(hash)
        constraint.isActive = true
    }
    
    func constraintBottomToBottomOf(_ view:UIView,_ spacing:CGFloat = 0,safe:Bool = false) {
        enableCustomConstraints()
        let anchor:NSLayoutAnchor = safe ? view.safeAreaLayoutGuide.bottomAnchor : view.bottomAnchor
        let constraint =  bottomAnchor.constraint(equalTo: anchor,constant: -spacing)
        constraint.identifier = "bottom" + String(hash)
        constraint.isActive = true
    }
    
    
    func constraintStartToStartOf(_ view:UIView,_ spacing:CGFloat = 0,safe:Bool = false) {
        enableCustomConstraints()
        let anchor:NSLayoutAnchor = safe ? view.safeAreaLayoutGuide.leadingAnchor : view.leadingAnchor
        let constraint = leadingAnchor.constraint(equalTo: anchor,constant: spacing)
        constraint.identifier = "start" + String(hash)
        constraint.isActive = true
    }
    
    func constraintStartToEndOf(_ view:UIView,_ spacing:CGFloat = 0,safe:Bool = false) {
        enableCustomConstraints()
        let anchor:NSLayoutAnchor = safe ? view.safeAreaLayoutGuide.trailingAnchor : view.trailingAnchor
        let constraint = leadingAnchor.constraint(equalTo: anchor,constant: spacing)
        constraint.identifier = "start" + String(hash)
        constraint.isActive = true
    }
    
    func constraintEndToStartOf(_ view:UIView,_ spacing:CGFloat = 0,safe:Bool = false) {
        enableCustomConstraints()
        let anchor:NSLayoutAnchor = safe ? view.safeAreaLayoutGuide.leadingAnchor : view.leadingAnchor
        let constraint = trailingAnchor.constraint(equalTo: anchor,constant: -spacing)
        constraint.identifier = "end" +  String(hash)
        constraint.isActive = true
    }
    
    func constraintEndToEndOf(_ view:UIView,_ spacing:CGFloat = 0,safe:Bool = false) {
        enableCustomConstraints()
        let anchor:NSLayoutAnchor = safe ? view.safeAreaLayoutGuide.trailingAnchor : view.trailingAnchor
        let constraint =  trailingAnchor.constraint(equalTo: anchor,constant: -spacing)
        constraint.identifier = "end" + String(hash)
        constraint.isActive = true
    }
    
    func constraintCenterHorizontallyIn(_ view:UIView,_ spacing:CGFloat = 0) {
        enableCustomConstraints()
        let constraint =  centerXAnchor.constraint(equalTo: view.centerXAnchor,constant: spacing)
        constraint.identifier = "centerX" + String(hash)
        constraint.isActive = true
    }
    func constraintCenterVerticallyIn(_ view:UIView,_ spacing:CGFloat = 0) {
        enableCustomConstraints()
        let constraint = centerYAnchor.constraint(equalTo: view.centerYAnchor,constant: spacing)
        constraint.identifier = "centerY" + String(hash)
        constraint.isActive = true
    }
    func constraintHeight(_ value: CGFloat) {
        enableCustomConstraints()
        let constraint = heightAnchor.constraint(equalToConstant: value)
        constraint.identifier = "height" + String(hash)
        constraint.isActive = true
    }
    func constraintWidth(_ value:CGFloat) {
        enableCustomConstraints()
        let constraint = widthAnchor.constraint(equalToConstant: value)
        constraint.identifier = "width" + String(hash)
        constraint.isActive = true
    }
    
    func animateConstraint(_ type:ConstraintType,constant:CGFloat,duration:TimeInterval = 0.5,cancelLayout:Bool = false) {
        var constraint:NSLayoutConstraint?
        if type == .height ||
            type == .width {
            constraint = constraints.first { $0.identifier == type.rawValue + String(hash)}
        }else {
            constraint = superview?.constraints.first {$0.identifier == type.rawValue + String(hash)}
            
        }
        constraint?.constant = constant

        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.8, options: []) {
            if !cancelLayout {
            self.superview?.layoutIfNeeded()
            }
            self.layoutIfNeeded()
        }
    }
    enum ConstraintType :String {
        case top = "top",bottom = "bottom",
             start = "start",end = "end",
             centerX = "centerX",centerY = "centerY",
             height = "height",width = "width"
    }
    
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
    func addShadowAround(size:CGSize, offset:CGSize? = nil) {
        let shadowSize : CGFloat = 15.0
        let shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize / 2,
                                                    y: -shadowSize / 2,
                                                    width:  size.width + shadowSize,
                                                    height: size.height +  shadowSize))
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.4).cgColor
        if let offset = offset {
            self.layer.shadowOffset = offset
        }else {
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        }
        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 8
        self.layer.shadowPath = shadowPath.cgPath
    }
    func removeShadow() {
        self.layer.masksToBounds = true
        self.layer.shadowColor = .none
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowOpacity = 0
        self.layer.shadowRadius = 0
        self.layer.shadowPath = nil
    }
}

extension CGPoint {
    func pdfPoint(docView:UIView) -> CGPoint {
        // location.y = documentView.bounds.height - location.y
        return CGPoint(x:x ,y: docView.bounds.height - y)
    }
}
extension String {
    func textFromKey() -> String {
       return self.replacingOccurrences(of: "_", with: " ")
    }
}
extension NSPointerArray {
    func addObject(_ object: AnyObject?) {
        guard let strongObject = object else { return }

        let pointer = Unmanaged.passUnretained(strongObject).toOpaque()
        addPointer(pointer)
    }

    func insertObject(_ object: AnyObject?, at index: Int) {
        guard index < count, let strongObject = object else { return }

        let pointer = Unmanaged.passUnretained(strongObject).toOpaque()
        insertPointer(pointer, at: index)
    }

    func replaceObject(at index: Int, withObject object: AnyObject?) {
        guard index < count, let strongObject = object else { return }

        let pointer = Unmanaged.passUnretained(strongObject).toOpaque()
        replacePointer(at: index, withPointer: pointer)
    }

    func object(at index: Int) -> AnyObject? {
        guard index < count, let pointer = self.pointer(at: index) else { return nil }
        return Unmanaged<AnyObject>.fromOpaque(pointer).takeUnretainedValue()
    }

    func removeObject(at index: Int) {
        guard index < count else { return }

        removePointer(at: index)
    }
}
