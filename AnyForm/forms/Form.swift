//
//  FilledForm.swift
//  AnyForm
//
//  Created by נדב אבנון on 18/07/2021.
//

import Foundation
import UIKit
import PDFKit


class Form  {
    fileprivate let holder:FormFieldsHolder
    fileprivate let design:FormDesign
    let type:FormType
    init(type:FormType, design:FormDesign) {
        self.type = type
        self.design = design
        self.holder = FormFieldsHolder(formType: type)
    }
    func getDesign() -> FormDesign {
        return design
    }
    func getHolder() -> FormFieldsHolder {
        return holder
    }
    func getTextFields() -> [FormTextField] {
        return self.holder.getTextFields()
    }
    func getCheckBoxes() -> [FormCheckBox] {
        return self.holder.getCheckBoxes()
    }
    
    func setFieldValue(for key:String,newValue:String) {
        self.holder.setFieldValue(for: key, value: newValue)
    }
    
    
    
    /// `Form Text Attributes`
    /// a variable containing the form's text attributes
    /// the following are examples for text attributes:
    /// font size
    /// font color
    /// font family
    var formTextAttributes:[NSAttributedString.Key : Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 9)]
    
    /// `Fill The Form`
    /// this function is doing the following:
    /// first we fetch a pdf form from the internet with our form's type
    /// we then write the data to a new pdf file on the the device
    /// and finally we copy that file and add the values from our field's holder
    /// as annotations to the copied new pdf form file
    func fill(callback:@escaping (URL
    ) -> Void) {
        let net = Networking()
        net.getForm(type:type) { [weak self] (d, e) in
            if let e = e {
                print(e.localizedDescription)
                return}
            guard let strongSelf = self else {return}
            let unfilled = strongSelf.type.getCleanFilePath()
            let fill = strongSelf.type.getEditedFilePath()
            let paths = FileManager.default.urls(for: .documentDirectory,  in: .userDomainMask)
            let documentsDirectory = paths[0]
            let unfilledPath = documentsDirectory.appendingPathComponent("/" + unfilled)
            let filledPath = documentsDirectory.appendingPathComponent("/" + fill)
            do {
                try d?.write(to: unfilledPath)
            }catch {
                print(error)
            }
            if let doc: PDFDocument = PDFDocument(url: unfilledPath) {
                let page = doc.page(at: 0)!
                let checkboxfields = strongSelf.getHolder().getCheckBoxes()
                let textFields = strongSelf.getHolder().getTextFields()
                if !checkboxfields.isEmpty {
                    checkboxfields.forEach { field in
                        let freeTextAnnotation = PDFAnnotation(bounds: CGRect(x: field.point.x, y: field.point.y, width: 200, height: 50), forType: .freeText, withProperties: nil)
                        freeTextAnnotation.fontColor = .black
                        // We need to set this to clear, otherwise the background will be yellow by default.
                        freeTextAnnotation.color = .clear
                        freeTextAnnotation.contents = field.checked ? "✓" : ""
                        freeTextAnnotation.font = UIFont(name: "TimesNewRomanPSMT", size: 10)
                        page.addAnnotation(freeTextAnnotation)
                    }
                }
                for field in textFields {
                    let freeTextAnnotation = PDFAnnotation(bounds: CGRect(x: field.point.x, y: field.point.y, width: 200, height: 50), forType: .freeText, withProperties: nil)
                    freeTextAnnotation.fontColor = .black
                    // We need to set this to clear, otherwise the background will be yellow by default.
                    freeTextAnnotation.color = .clear
                    freeTextAnnotation.contents = field.value
                    freeTextAnnotation.font = UIFont.boldSystemFont(ofSize: 12)
                    page.addAnnotation(freeTextAnnotation)
                }
                doc.write(to: filledPath)
                print(filledPath.absoluteString)
                callback(filledPath)
            }
        }
    }
}
