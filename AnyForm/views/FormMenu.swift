//
//  FormMenu.swift
//  AnyForm
//
//  Created by Nadav Avnon on 28/08/2021.
//

import UIKit

protocol FormMenuDelegate {

}

class FormMenu: UIView {
    var menuDelegate:FormMenuDelegate?
    
    lazy var tabs:[UIButton] = {
        var tabs:[UIButton] = []
        // First tab - Settings
        let settings = menuButton(title: "הגדרות") { tapAction in
            //..
        }
        
        // Second tab - Show tunnel
        let tunnel = menuButton(title: "שדות") { tapAction in
            //..
        }
        // Third tab preferences
        let prefrences = menuButton(title: "העדפות משתמש") { tapAction in
            //..
        }
        // Fourth tab - Fill from memory
        let history = menuButton(title: "היסטורייה") { tapAction in
            //..
        }
        // Fifth tab - Report a Problem
        let report = menuButton(title: "דווח על בעיה") { tapAction in
            //..
        }
        tabs.append(settings)
        tabs.append(tunnel)
        tabs.append(prefrences)
        tabs.append(history)
        tabs.append(report)
        return tabs
    }()

    func menuButton(title:String, handler: @escaping UIActionHandler) -> UIButton {
        let button = UIButton()
        button.setAttributedTitle(NSAttributedString(string: title,attributes: [.foregroundColor : UIColor.systemOrange.withAlphaComponent(0.95),.font : UIFont.boldSystemFont(ofSize: 14)]), for: .normal)
        button.layer.cornerRadius = 8
        button.borderColor = UIColor.black
        button.borderWidth = 0.5
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        button.backgroundColor = UIUtils.hexStringToUIColor(hex: "F8F7F5")
        button.showsTouchWhenHighlighted = true
        button.addAction(UIAction(handler: handler), for: .touchUpInside)
        return button
    }
    
    lazy var tabStack:UIStackView = {
       let stack = UIStackView(arrangedSubviews: tabs)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 16
        stack.distribution = .fillProportionally
        stack.axis = .vertical
        return stack
    }()
    override func didMoveToSuperview() {
        // Maybe stuff happening when view enters the screen?
    }
    var tabStackConstraints:[NSLayoutConstraint] = []
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIUtils.hexStringToUIColor(hex: "3A3129")
        addSubview(tabStack)
        translatesAutoresizingMaskIntoConstraints = false
        tabStackConstraints = [
        tabStack.topAnchor.constraint(equalTo: topAnchor, constant: 32),
        tabStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            tabStack.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 3)]
        NSLayoutConstraint.activate(self.tabStackConstraints)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
