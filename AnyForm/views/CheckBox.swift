//
//  CheckBox.swift
//  AnyForm
//
//  Created by נדב אבנון on 18/07/2021.
//

import UIKit

class CheckBox: UIButton {
    // Images
    var checkedImage = #imageLiteral(resourceName: "icons8-checked_checkbox_filled").withRenderingMode(.alwaysTemplate)
    var uncheckedImage = #imageLiteral(resourceName: "icons8-unchecked_checkbox_filled").withRenderingMode(.alwaysTemplate)
    
    // Bool property
    var isChecked: Bool = false {
        didSet {
            if isChecked == true {
                let image = checkedImage.withTintColor(.systemOrange).withRenderingMode(.alwaysTemplate)
                self.tintColor = .systemOrange
                self.setImage(image, for: UIControl.State.normal)
                tintColorDidChange()
            } else {
                let image = uncheckedImage.withTintColor(.systemOrange).withRenderingMode(.alwaysTemplate)
                self.tintColor = .systemOrange
                self.setImage(image, for: UIControl.State.normal)
                tintColorDidChange()
            }
        }
    }
        
    override func awakeFromNib() {
        self.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)
        self.isChecked = false
    }
        
    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
        }
    }
}
