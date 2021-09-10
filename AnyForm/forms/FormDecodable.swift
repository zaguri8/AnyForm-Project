//
//  FormDecodable.swift
//  AnyForm
//
//  Created by נדב אבנון on 23/07/2021.
//

import Foundation
import UIKit

/// an object used to hold all the fields of the form
struct FormTemplateHolder : Codable {
    var textfields:[FormTextField]
    var formcheckboxes:[FormCheckBox]
}

/// an object type used to reference a text field in a form
struct FormTextField : Codable {
    var key:String
    var value:String = ""
    var point:CGPoint
    var props:FormTextFieldProps
    init(key:String,point:CGPoint,props:FormTextFieldProps) {
        self.key = key
        self.point = point
        self.props = props
    }
}
//// an object type used to reference a check box in a form
struct FormCheckBox : Codable {
    var key:String
    var point:CGPoint
    var checked:Bool
    var props:FormCheckBoxProps
    init(key:String,point:CGPoint,category:String,props:FormCheckBoxProps) {
        self.key = key
        self.point = point
        self.checked = false
        self.props = props
    }
}


struct FormCheckBoxProps : Codable{
    var bitmap:String = ""
    var category:String = ""
    var type:String
}

struct FormTextFieldProps : Codable {
    var type:String
}
