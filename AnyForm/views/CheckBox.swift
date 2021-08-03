//
//  CheckBox.swift
//  AnyForm
//
//  Created by נדב אבנון on 18/07/2021.
//

import UIKit

class CheckBox: UIButton {
    // Images
    let checkedImage = #imageLiteral(resourceName: "icons8-checked_checkbox_filled")
    let uncheckedImage = #imageLiteral(resourceName: "icons8-unchecked_checkbox_filled")
    
    // Bool property
    var isChecked: Bool = false {
        didSet {
            if isChecked == true {
                self.setImage(checkedImage, for: UIControl.State.normal)
            } else {
                self.setImage(uncheckedImage, for: UIControl.State.normal)
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
