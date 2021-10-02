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
    var pages:[FormPage] = []
    let design:FormDesign
    let type:FormType
    
    
    init(type:FormType, design:FormDesign) {
        self.type = type
        self.design = design
        loadForm()
    }
    
    func getDesign() -> FormDesign {
        return design
    }
    func getPage(at:Int) -> FormPage {
        return pages[at]
    }
    func getOptionalPages() -> [FormPage] {
        return pages.filter{$0.optional}
    }
    func getRequiredPages() -> [FormPage] {
        return pages.filter{!$0.optional}
    }
    
    func getOptionalTextFields() -> [FormTextField] {
        return self.pages.filter{$0.optional}.compactMap{$0.textfields}.reduce([]) { res, arr in
            var ret = res
            ret.append(arr)
            return ret
        }
    }
    func getRequiredTextFields() -> [FormTextField] {
        return self.pages.filter{!$0.optional}.compactMap{$0.textfields}.reduce([]) { res, arr in
            var ret = res
            ret.append(arr)
            return ret
        }
    }
    
    
    func getOptionalCheckBoxes() -> [FormCheckBox] {
        return self.pages.filter{$0.optional}.compactMap{$0.formcheckboxes}.reduce([]) { res, arr in
            var ret = res
            ret.append(arr)
            return ret
        }
    }
    func getRequiredCheckBoxes() -> [FormCheckBox] {
        return self.pages.filter{!$0.optional}.compactMap{$0.formcheckboxes}.reduce([]) { res, arr in
            var ret = res
            ret.append(arr)
            return ret
        }
    }
    func getPageCount() -> Int {
        return pages.count
    }
    func getCheckBoxes(page:Int) -> [FormCheckBox] {
        return self.pages[page].getCheckBoxes()
    }
    func getTextFields(page:Int) -> [FormTextField] {
        return self.pages[page].getTextFields()
    }
    func setFieldValue(for key:String,newValue:String,page:Int) {
        self.pages[page].setFieldValue(for: key, value: newValue)
    }
    func setSignature(val:CGImage?,page:Int) {
        self.pages[page].setSignature(val: val)
    }
    
    func hasTextField(key:String) -> Bool {
        for p in pages {
            if p.getTextFields().contains(where: {$0.key == key}) {
                return true
            }
        }
        return false
    }
    func hasCheckBox(key:String) -> Bool {
        for p in pages {
            if p.getCheckBoxes().contains(where: {$0.key == key}) {
                return true
            }
        }
        return false
    }

    /// **Load**
    /// we first create a reference to the generated file from template generator
    /// we then use   **JSONDecoder** to instantiate a new template holder
    /// finally we pass the template's fields to the form field holder
    func loadForm() {
        guard let url = Bundle.main.url(
                forResource: type.getFormTemplateFile()
                ,withExtension: "json") else {
            print("Invalid filename/path: ." )
            return}
        do {
            let data = try Data(contentsOf: url)
            guard let formData = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else {return}
            let formPages = formData["pages"] as! [[String:Any]]
            var pageTemplates:[FormTemplatePage] = []
            for pageTemplateData in formPages {
                    let templatePage = FormTemplatePage.objectFromData(pageTemplateData)
                    pageTemplates.append(templatePage)
            }
            print(pageTemplates.count)
            for i in 0...formPages.count - 1{
                let page = FormPage(index: i)
                pages.append(page)
            }
            
            for (index,page) in pages.enumerated() {
                if pageTemplates.count <= index {continue}
                page.textfields = pageTemplates[index].textfields
                page.formcheckboxes = pageTemplates[index].formcheckboxes
                page.index = pageTemplates[index].index
                page.optional = pageTemplates[index].optional
                page.pageTitle = pageTemplates[index].pageTitle
            }
        } catch let error {
            print("parse error: \(error.localizedDescription)")
        }
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
    func fill(callback:@escaping (URL) -> Void) {
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
                var i = 0
                var page = doc.page(at: i)
                while (page != nil && i < strongSelf.pages.count) {
                    let checkboxfields = strongSelf.getCheckBoxes(page: i)
                    let textFields = strongSelf.getTextFields(page:i)
                if !checkboxfields.isEmpty {
                    checkboxfields.forEach { field in
                        let freeTextAnnotation = PDFAnnotation(bounds: CGRect(x: field.point.x, y:field.point.y - ( page!.bounds(for: .mediaBox).height) - 10, width: 200, height: 50), forType: .freeText, withProperties: nil)
                        freeTextAnnotation.fontColor = .black
                        // We need to set this to clear, otherwise the background will be yellow by default.
                        freeTextAnnotation.color = .clear
                        freeTextAnnotation.contents = field.checked ? "✓" : ""
                        freeTextAnnotation.font = UIFont(name: "TimesNewRomanPSMT", size: 10)
                        page!.addAnnotation(freeTextAnnotation)
                    }
                }
                for field in textFields {
                    let freeTextAnnotation = PDFAnnotation(bounds: CGRect(x: field.point.x, y: field.point.y - ( page!.bounds(for: .mediaBox).height) - 8, width: 200, height: 50), forType: .freeText, withProperties: nil)
                    freeTextAnnotation.fontColor = .black
                    // We need to set this to clear, otherwise the background will be yellow by default.
                    freeTextAnnotation.color = .clear
                    freeTextAnnotation.contents = field.value
                    freeTextAnnotation.font = UIFont.boldSystemFont(ofSize: 12)
                    page?.addAnnotation(freeTextAnnotation)
                }
                if let signature = strongSelf.getPage(at: i).signature, let signatureField = strongSelf.getTextFields(page: i).first(where: { field in
                    FieldProps.isSignatureField(field.key)
                }) {
                    let bounds = CGRect(x: signatureField.point.x, y: signatureField.point.y, width: 100, height: 50)
                    let x = PDFImageAnnotation(imageBounds: bounds, image: signature)
                    x.page = page
                    x.backgroundColor = .clear
                    x.color = .clear
                    page?.addAnnotation(x)
                }
                    i += 1
                    page = doc.page(at: i)
                }
                doc.write(to: filledPath)
                print(filledPath.absoluteString)
                callback(filledPath)
            }
        }
    }
}
class PDFImageAnnotation: PDFAnnotation {

   private var _image: CGImage?

   public init(imageBounds: CGRect, image: CGImage?) {
       self._image = image
       super.init(bounds: imageBounds, forType: .stamp, withProperties: nil)
   }

   required public init?(coder aDecoder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
   }

   override public func draw(with box: PDFDisplayBox, in context: CGContext) {
       guard let cgImage = self._image else {
           return
       }
      let drawingBox = self.page?.bounds(for: box)
      //Virtually changing reference frame since the context is agnostic of them. Necessary hack.
      context.draw(cgImage, in: self.bounds.applying(CGAffineTransform(
      translationX: (drawingBox?.origin.x)! * -1.0,
                 y: (drawingBox?.origin.y)! * -1.0)))
   }

}

