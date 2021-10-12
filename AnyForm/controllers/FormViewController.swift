//
//  FormViewController.swift
//  AnyForm
//
//  Created by Nadav Avnon on 09/10/2021.
//

import UIKit
import PDFKit
class FormViewController: UIViewController,UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if(gestureRecognizer.state == .ended) {
            formView.scrollView?.setZoomScale(1.0, animated: true)
        }
        return true
    }
    
    lazy var zoomView : ZoomView = {
       let zoomView = ZoomView()
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(dragZoomView))
        gesture.delegate = self
        zoomView.addGestureRecognizer(gesture)
        
        return zoomView
    }()
    
    @objc func dragZoomView(gesture:UIPanGestureRecognizer) {
        let location = gesture.location(in: self.view)
        let draggedView = gesture.view
        draggedView?.center = location
        formView.scrollView?.zoom(to: CGRect(x:location.x,y:location.y,width:120,height:120), animated: true)
        if gesture.state == .ended {
            formView.scrollView?.setZoomScale(1.0, animated: true)
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(toolBar)
        toolBar.constraintTopToTopOf(view)
        toolBar.constraintStartToStartOf(view)
        toolBar.constraintEndToEndOf(view)
        toolBar.constraintHeight(55)
        let label = titleLabel("תצוגת הטופס")
        label.backgroundColor = .systemOrange
        self.toolBar.addSubview(label)
        label.constraintTopToTopOf(self.toolBar , 16 ,safe: false)
        label.constraintStartToStartOf(self.toolBar,8)
        label.constraintEndToEndOf(self.toolBar,8)
        view.addSubview(zoomView)

    }

    override func viewWillAppear(_ animated: Bool) {
        self.view.backgroundColor = UIUtils.hexStringToUIColor(hex: "FFD7B5")
        self.formView.cornerRadius = 32
    }
    @IBOutlet weak var formView: FormView!
    lazy var toolBar:UIView = {
        let toolBarView = UIView()
        toolBarView.backgroundColor = .systemOrange
        return toolBarView
        
    }()
    
    lazy var titleLabel:((String) -> UILabel) = { titleText in
        let label = UILabel()
        label.text = titleText
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .white
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        return label
    }
    
    
    func populate(_ form:Form?) {
    
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        
        let label = UILabel()
        label.text = "טוען.."
        alert.view.addSubview(label)
        label.textAlignment = .center
        label.constraintTopToTopOf(alert.view,8)
        label.constraintStartToStartOf(alert.view)
        label.constraintEndToEndOf(alert.view)

        present(alert, animated: true)
        guard let form = form else {return}
        Networking().getForm(type: form.type) { [weak self] data, err in
            guard let data = data else {return}
            guard let strongSelf = self else {return}
            let doc = PDFDocument(data: data)!
            strongSelf.formView.document = doc
            for sb in strongSelf.formView.subviews {
                sb.layer.cornerRadius = 30.0
            }
            strongSelf.formView.scrollView?.bounces = false
            strongSelf.formView.backgroundColor = UIUtils.hexStringToUIColor(hex: "FFFFFF")
            strongSelf.formView.scaleFactor = 0.6

                var i = 0
                var page = doc.page(at: i)
            alert.dismiss(animated: true)
                while (page != nil && i < form.pages.count) {
                    let checkboxfields = form.getCheckBoxes(page: i)
                    let textFields = form.getTextFields(page:i)
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
                if let signature = form.getPage(at: i).signature, let signatureField = form.getTextFields(page: i).first(where: { field in
                    FieldProps.isSignatureField(field.key)
                }) {
                    let bounds = CGRect(x: signatureField.point.x - 50, y: signatureField.point.y + 20, width: 100, height: 50)
                    let x = PDFImageAnnotation(imageBounds: bounds, image: signature)
                    x.page = page
                    x.backgroundColor = .clear
                    x.color = .clear
                    page?.addAnnotation(x)
                }
                    i += 1
                    page = doc.page(at: i)
                }
        
        }
                  
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
