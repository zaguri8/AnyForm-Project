//
//  Form.swift
//  AnyForm
//
//  Created by נדב אבנון on 18/07/2021.
//

import UIKit
import PDFKit
class FormView: PDFView {
    
    /// `Add an annotation to a field on the view`
    /// - Parameters:
    ///   - fieldKey: the key used to identify the field
    ///   - annotation: the pdf annotation to draw in the field
    func addedAnnotation(fieldKey: String, annotation: PDFAnnotation) {
        guard let currentpage = self.document?.page(at: 1)  else  {
            return}
        currentpage.addAnnotation(annotation)
        self.annotations[fieldKey] = annotation
    }
    
    /// `Remove an annotation from a field on the view`
    /// - Parameter fieldKey: the key used to identify the field
    func removedAnnotation(fieldKey: String) {
        let annotation = self.annotations[fieldKey]
        self.annotations.removeValue(forKey: fieldKey)
        guard let doc = document else {return}
        for i in 0...doc.pageCount {
            guard let page = doc.page(at: i), let a = annotation else {return}
            page.removeAnnotation(a)
        }
    }
    
    var annotations:[String: PDFAnnotation] = [:]
    override init(frame: CGRect) {
        super.init(frame: frame)
        /// here we change the view's properties and qualities
        /// e.x: zoom in when document loaded
        self.translatesAutoresizingMaskIntoConstraints = false
        self.displayMode = .singlePageContinuous
        self.autoScales = true
        self.scaleFactor = (self.bounds.width) / UIScreen.main.bounds.width
        self.displayDirection = .vertical
        self.isUserInteractionEnabled = true
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    convenience init(frame:CGRect,document:PDFDocument) {
        self.init(frame:frame)
        self.document = document
    }
    
    
    func setDocument(_ doc: PDFDocument) {
        self.document = document
    }
    
}
