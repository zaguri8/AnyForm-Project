//
//  FormDecodable.swift
//  AnyForm
//
//  Created by נדב אבנון on 23/07/2021.
//

import Foundation
import UIKit

/// an object used to hold all the fields of the form
struct FormTemplatePage : Codable {
    var textfields:[FormTextField]
    var formcheckboxes:[FormCheckBox]
    var index:Int
    var optional:Bool
    var pageTitle:String
    
    static func objectFromData(_ json:[String:Any]) -> FormTemplatePage {
    
        let textFieldsData = json["textFields"] as? [[String:Any]] ?? []
        let textFields = textFieldsData.compactMap(FormTextField.objectFromJson)
        let formcheckboxesData = json["checkBoxes"] as? [[String:Any]] ?? []
        let formcheckboxes = formcheckboxesData.compactMap(FormCheckBox.objectFromJson)
        let index = json["index"] as? Int ?? 0
        let optional = json["optional"] as? Bool ?? false
        let pageTitle = json["pageTitle"] as? String ?? ""
        
        return FormTemplatePage(textfields: textFields, formcheckboxes: formcheckboxes, index: index, optional: optional, pageTitle: pageTitle)
    }
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
    
    static func objectFromJson(_ json:[String:Any]) -> FormTextField {
        let key = json["key"] as? String ?? ""
        let pointXY = json["point"] as? [CGFloat]
        var point = CGPoint()
        if let pointXY = pointXY {
        point = CGPoint(x:pointXY[0],y:pointXY[1])
        }
        let props = json["props"] as? [String:Any] ?? ["":""]
        return FormTextField(key: key, point: point, props: FormTextFieldProps.objectFromJson(props))
    }
}

//// an object type used to reference a check box in a form
struct FormCheckBox : Codable{
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
    
    static func objectFromJson(_ json:[String:Any]) -> FormCheckBox {
        let key = json["key"] as? String ?? ""
        let pointXY = json["point"] as? [CGFloat]
        var point = CGPoint()
        if let pointXY = pointXY {
        point = CGPoint(x:pointXY[0],y:pointXY[1])
        }
        let category = json["category"] as? String ?? ""
        let props = json["props"] as? [String:Any] ?? ["":""]
        return FormCheckBox(key: key, point: point, category: category, props: FormCheckBoxProps.objectFromJson(props))
    }
}


struct FormCheckBoxProps : Codable{
    var bitmap:String = ""
    var category:String = ""
    var type:String
    
    static func objectFromJson(_ json:[String:Any]) -> FormCheckBoxProps {
        let type = json["type"] as? String ?? ""
        let category = json["category"] as? String ?? ""
        let bitmap = json["bitmap"] as? String ?? ""
        return FormCheckBoxProps(bitmap:bitmap,category:category,type: type)
    }
}

struct FormTextFieldProps : Codable {
    var type:String
    
    static func objectFromJson(_ json:[String:Any]) -> FormTextFieldProps {
        let type = json["type"] as? String ?? ""
        return FormTextFieldProps(type: type)
    }
}
