//
//  FormCollectionViewCell.swift
//  AnyForm
//
//  Created by עודד האינה on 24/07/2021.
//

import UIKit
import PDFKit

class FormCollectionViewCell: UICollectionViewCell {
    override func awakeFromNib() {
        formView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(formclicked)))
    }
    
    /// notifies the form picker that a form was clicked
    @objc func formclicked(){
        guard let type = type else {return}
        delegate?.didPickForm(type: type)
    }
    
    @IBOutlet weak var formBanner: UIView!
    @IBOutlet weak var formName: UILabel!
    @IBOutlet weak var formView: FormView!
    var type:FormType?
    var delegate:FormPickerDelegate?
    
    /// `Form Cell Populate`
    /// populate the form's cell with a pdf document
    /// first fetch a fresh form from the internet
    /// then set the form's document view with the form
    /// **change the background color to match the view controller's background**
    func populate(type:FormType) {
        if self.formView.document != nil{
            return
        }
        formName.text? = type.getFormName()
        self.type = type
        Networking().getForm(type: type) { [weak self] data, err in
            guard let data = data else {return}
            guard let strongSelf = self else {return}
            let doc = PDFDocument(data: data)
            doc?.removePage(at: 1)
            strongSelf.formView.document = doc
            for sb in strongSelf.formView.subviews {
                sb.layer.cornerRadius = 30.0
            }
            strongSelf.formBanner.layer.cornerRadius = 6.0
            strongSelf.formBanner.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
            strongSelf.formView.backgroundColor = UIUtils.hexStringToUIColor(hex: "FFFFFF")
            strongSelf.formView.scaleFactor = 0
            strongSelf.formView.minScaleFactor = strongSelf.formView.scaleFactor
            strongSelf.formView.maxScaleFactor = strongSelf.formView.scaleFactor
            for sb in strongSelf.formView.subviews {
                if sb == sb as? UIScrollView {
                    (sb as! UIScrollView).isScrollEnabled = false
                }}
        }
    }
}
