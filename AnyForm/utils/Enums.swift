//
//  Enums.swift
//  AnyForm
//
//  Created by נדב אבנון on 18/07/2021.
//

import Foundation
import UIKit

enum FormFieldType {
    case categoryOneChoiceField,
         categoryMultiChoiceField,
         singleOneChoiceField,
         undefined
    static func fromString(_ str:String) -> FormFieldType  {
        switch str {
        case "SOCF":
            return .singleOneChoiceField
        case "CMCF":
            return .categoryMultiChoiceField
        case "COCF":
            return .categoryOneChoiceField
        default:
            return .undefined
        }
    }
    
}


enum FormError :Error{
    case unDefinedFieldKey(String)
}

enum FormType {
    case loanrequest,form101
    func getFormName() -> String {
        var str = ""
        switch self {
        case .loanrequest:
            str = loan_request_name
        case .form101:
            str = form101name
        }
        return str
    }
    
    func getFormURL() -> URL? {
        var str = ""
        switch self {
        case .loanrequest:
            str = loanrequesturlstring
        case .form101:
            str = form101urlstring
        }
        guard let url = URL(string: str) else {return nil}
        return url
    }
    func getPages() -> Int {
        switch self {
        case .form101:
            return 1
        case .loanrequest:
            return 1
        }
    }
    
    func getFormTemplateFile() -> String {
        switch self {
        case .loanrequest:
            return loan_request_template
        case .form101:
            return form101template
        }
    }
    
    func getCleanFilePath() -> String {
        switch self {
        case .loanrequest:
            return loan_request
        case .form101:
            return form101file
        }
    }
    
    func getEditedFilePath() -> String {
        switch self {
        case .loanrequest:
            return loan_request_edited
        case .form101:
            return form101editedfile
        }
    }
}
