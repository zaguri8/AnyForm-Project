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
    init(key:String,point:CGPoint) {
        self.key = key
        self.point = point
    }
}
//// an object type used to reference a check box in a form
struct FormCheckBox : Codable {
    var key:String
    var point:CGPoint
    var category:String
    var checked:Bool = false
    init(key:String,point:CGPoint,category:String) {
        self.key = key
        self.point = point
        self.category = category
    }
}
