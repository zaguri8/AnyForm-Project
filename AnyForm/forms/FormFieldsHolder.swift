//
//  Form101Positioning.swift
//  AnyForm
//
//  Created by נדב אבנון on 18/07/2021.
//

import Foundation
import UIKit
class FormFieldsHolder {
    fileprivate var textfields:[FormTextField] = []
    fileprivate var formcheckboxes:[FormCheckBox] = []
    let formType:FormType
    var signature:CGImage?
    init(formType:FormType) {
        self.formType = formType
        loadFromTemplate()
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
    /// **Load**
    /// we first create a reference to the generated file from template generator
    /// we then use   **JSONDecoder** to instantiate a new template holder
    /// finally we pass the template's fields to the form field holder
    func loadFromTemplate() {
        guard let url = Bundle.main.url(
                forResource: formType.getFormTemplateFile()
                ,withExtension: "json") else {
            print("Invalid filename/path: ." )
            return}
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let templateHolder = try decoder.decode(FormTemplateHolder.self, from: data)
            self.textfields = templateHolder.textfields
            self.formcheckboxes = templateHolder.formcheckboxes
        } catch let error {
            print("parse error: \(error.localizedDescription)")
        }
    }
    
}
