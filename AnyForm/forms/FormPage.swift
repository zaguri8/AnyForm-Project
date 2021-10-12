//
//  Form101Positioning.swift
//  AnyForm
//
//  Created by נדב אבנון on 18/07/2021.
//

import Foundation
import UIKit
class FormPage {
    var textfields:[FormTextField] = []
    var formcheckboxes:[FormCheckBox] = []
    var signature:CGImage?
    var index:Int
    var optional:Bool
    var pageTitle:String
    
    init(index:Int) {
        self.index = index
        self.optional = false
        self.pageTitle = ""
    }
    func getTextFields() -> [FormTextField] {
        return self.textfields
    }
    func getCheckBoxes() -> [FormCheckBox] {
        return self.formcheckboxes
    }
    
    
    /// PDF Form field value setting method :
    /// we receive a request to change the field's value from a client
    /// this is where a user has inserted data to for a certain field
    /// all the initial values of a form
    /// - Parameters:
    ///   - key: the key used to identify a form field created by a tempalte generator
    ///   - value: the value we want to give to the certain key
    func setFieldValue(for key:String,value:String) {
        guard let check =  Bool(value) else {
            for (i,tf) in self.textfields.enumerated() {
                if tf.key == key {
                    self.textfields[i].value = value
                }
            }
            return
        }
        for (i,cb) in self.formcheckboxes.enumerated() {
            if cb.key == key {
                self.formcheckboxes[i].checked = check
            }
        }
    }
    
    func setSignature(val:CGImage?) {
        self.signature = val
    }
    
}
