//
//  FormUIComponents.swift
//  AnyForm
//
//  Created by נדב אבנון on 26/07/2021.
//

import Foundation
import UIKit
import RoundedSwitch
class UITextFieldForm : UITextField {
    var formtextfield:FormTextField?
    convenience init(_ field: FormTextField) {
        self.init()
        self.formtextfield = field
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
class UIDatePickerForm : UIDatePicker {
    var formtextfield:FormTextField?
    convenience init(_ field: FormTextField) {
        self.init()
        self.formtextfield = field
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
class UICheckBoxForm : CheckBox {
    var formcheckbox:FormCheckBox?
    convenience init(_ field: FormCheckBox) {
        self.init()
        self.formcheckbox = field
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
