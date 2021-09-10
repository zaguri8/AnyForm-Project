//
//  FormUIComponents.swift
//  AnyForm
//
//  Created by נדב אבנון on 26/07/2021.
//

import Foundation
import UIKit
import RoundedSwitch
import WMSegmentControl
class UITextFieldForm : UITextField {
    var formtextfield:FormTextField?
    convenience init(_ field: FormTextField) {
        self.init()
        self.formtextfield = field
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

class UIDatePickerForm : UIDatePicker {
    var formtextfield:FormTextField?
    let type:FormFieldType = .singleOneChoiceField
    convenience init(_ field: FormTextField) {
        self.init()
        self.formtextfield = field
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

struct Line {
    let strokeWidth: Float
    let color: UIColor
    var points: [CGPoint]
}

class AnyFormSignatureField: UIView {

    // public function
    fileprivate var strokeColor = UIColor.black
    fileprivate var strokeWidth: Float = 1
    func setStrokeWidth(width: Float) {
        self.strokeWidth = width
    }

    func setStrokeColor(color: UIColor) {
        self.strokeColor = color
    }

    func undo() {
        _ = lines.popLast()
        setNeedsDisplay()
    }

    func clear() {
        lines.removeAll()
        setNeedsDisplay()
    }

    fileprivate var lines = [Line]()
    fileprivate var context:CGContext!
    fileprivate var image:CGImage?
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        context = UIGraphicsGetCurrentContext()
        lines.forEach { (line) in
            context.setStrokeColor(line.color.cgColor)
            context.setLineWidth(CGFloat(line.strokeWidth))
            context.setLineCap(.round)
            for (i, p) in line.points.enumerated() {
                if i == 0 {
                    context.move(to: p)
                } else {
                    context.addLine(to: p)
                }
            }
            context.strokePath()
        }
        context.setFillColor(UIColor.clear.cgColor)
        image = context.makeImage()
    }
    
    func getSignature() -> CGImage? {
       return image
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lines.append(Line.init(strokeWidth: strokeWidth, color: strokeColor, points: []))
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        guard var lastLine = lines.popLast() else { return }
        lastLine.points.append(point)
        lines.append(lastLine)
        setNeedsDisplay()
    }
}
class AnyFormSegmentControl  {
    var segmentControl:WMSegment
    var items: [FormCheckBox]
    var delegate:FormCheckBoxDelegate!
    init (items:[FormCheckBox], segmentControl:WMSegment,delegate: FormCheckBoxDelegate,defaultColor:UIColor) {
        self.segmentControl = segmentControl
        self.items = items
        self.segmentControl.buttonTitles = items.compactMap({ item in
           return  item.key.textFromKey()
        }).joined(separator: ",")
        self.segmentControl.buttonImages = items.compactMap({ item in
            item.props.bitmap
        }).joined(separator: ",")
        self.delegate = delegate
        self.setupViews()
        self.segmentControl.selectorColor = defaultColor
        self.segmentControl.selectorTextColor = defaultColor
        self.segmentControl.isUserInteractionEnabled = true
        self.segmentControl.selectorType = .bottomBar
        self.segmentControl.normalFont = UIFont.boldSystemFont(ofSize: 16)
        self.segmentControl.SelectedFont = UIFont.boldSystemFont(ofSize: 16)
        self.segmentControl.isRounded = true
    }
    

    func setupViews() {
        segmentControl.addAction(UIAction(handler: {act in
            self.items[self.segmentControl.selectedSegmentIndex].checked = true
            for (index,item) in self.items.enumerated() {
                if item.key != self.items[self.segmentControl.selectedSegmentIndex].key {
                    self.items[index].checked =  false
                }
                self.delegate.didCheckValue(checkBox: self.items[index])
            }
        }), for: .valueChanged)
        
    }
}


/**
 
 
    CATEGORIES OF QUESTIONS
    
    Textfield Questions:
    normal text fields without any further gamification
    text fields with images and some gamefication EX. firstname,lastname tag thing
 
    CheckBox Question:
    Binary questions ( 2 options)  let it be a segment control
    More then 2 options - this may vary:
    some round picker with options, cool drop down menu etc etc...
    
 */

class UITextFieldFormGamified : UIView, UITextFieldDelegate{
    var textColor:UIColor = .black
    var arg1:String?
    var arg2:String?
    
    var field:FormTextField?
    var savedData:String   {
        set {
            animateLabelTextChange(text: newValue)
            print(newValue)
        }
        get {
            ""
        }
    }
    
    var design:FormDesign?
    var alertTitle:String?
    var delegate:FormTextFieldDelegate?
    
    var imageView:UIImageView = {
        let image = UIImageView()
        image.frame = CGRect(x: 0, y: 0, width: 330, height: 300)
        return image
    }()
    lazy var label:UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.boldSystemFont(ofSize: 13.5)
        lbl.highlightedTextColor = .blue
        lbl.textColor = design?.holderBackgroundColor()
        lbl.textAlignment = .right
        lbl.text = savedData.isEmpty ?  "לחץ כאן" : savedData
        lbl.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 50, height: 200))
        return lbl
    }()

    convenience init(image:UIImage,field:FormTextField ,design:FormDesign) {
        self.init(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 300, height: 300)))
        self.imageView.image = image
        self.field = field
        addSubview(imageView)
        self.design = design
        imageView.center = convert(center, from: superview)
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageClicked)))
        imageView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.trailingAnchor.constraint(equalTo: imageView.trailingAnchor,constant: -64).isActive = true
        label.bottomAnchor.constraint(equalTo: imageView.bottomAnchor,constant: -108).isActive = true
        label.widthAnchor.constraint(equalToConstant: 50).isActive = true
        label.transform = CGAffineTransform(rotationAngle: 0.15)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.placeholder == "הכנס שם משפחה"
        {
            self.arg1 = textField.text
        } else if(textField.placeholder == "הכנס שם פרטי") {
            self.arg2 = textField.text
        }
    }
    
    
    @objc func imageClicked () {
        UIUtils.animateDuration({ [weak self] in
            self?.imageView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: {b in UIUtils.animateDuration({[weak self] in
            self?.imageView.transform =  .identity
        }, completion: {[weak self] b  in
            guard let title = self?.alertTitle else {return}
            let alert = UIAlertController(title: "AnyForm", message: title, preferredStyle: .alert)
            alert.addTextField { nameTextField in
                guard let strong = self else {return}
                nameTextField.delegate = self
                nameTextField.textAlignment = .right
                nameTextField.placeholder = "הכנס שם פרטי"
                if let data = AnyFormHelper.shared.data, let firstname = data.first(where: {$0.key == "שם_פרטי"}) {
                    nameTextField.text = firstname.value
                }else {
                    nameTextField.text = strong.arg2
                }
            }
            alert.addTextField { lastNameTextField in
                guard let strong = self else {
                    return}
                lastNameTextField.delegate = self
                lastNameTextField.textAlignment = .right
                lastNameTextField.placeholder = "הכנס שם משפחה"
                if let data = AnyFormHelper.shared.data, let lastname = data.first(where: {$0.key == "שם_משפחה"}) {
                    lastNameTextField.text = lastname.value
                }else {
                    lastNameTextField.text = strong.arg1
                }
            }
        
            
            alert.addAction(UIAlertAction(title: "אישור", style: .default, handler: { act in
                guard let strong = self else {return}
                if !strong.savedData.isEmpty {
                    let d = strong.savedData.split(separator: " ").map { ss in
                        return String(ss)
                    }
                    if d.count < 2 {return}
                    let firstName = d[0]
                    let lastName = d[1]
                    strong.delegate?.setFieldValue(arg1: firstName, arg2: lastName)
                }else {
                if let arg1 = self?.arg1, let arg2 = self?.arg2 {
                self?.delegate?.setFieldValue(arg1: arg1, arg2: arg2)
                    self?.animateLabelTextChange(text: arg2 + " " + arg1)
                }
                }
            }))
            alert.addAction(UIAlertAction(title: "סגור", style: .destructive, handler: { alert in
                
            }))
            self?.delegate?.presentFromView(vc: alert)
        }, delay: 0, duration: 0.3) }, delay: 0, duration: 0.3)
    }
    
    func animateLabelTextChange(text:String) {
        self.label.textColor = UIColor.black
        self.label.transform = CGAffineTransform(translationX: 300, y: 0)
        UIUtils.animateDuration({ [weak self] in
            self?.label.font = .boldSystemFont(ofSize: 12)
            self?.label.text = text
        }, completion: { b in
            UIUtils.animateDuration({  [weak self] in
                self?.label.transform = .identity
                self?.label.font = .boldSystemFont(ofSize: 8.5)
            }, delay: 0, duration: 0.1)
        }, delay: 0, duration: 0.3)
        field?.value = text
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}


class UICheckBoxForm : CheckBox {
    var formcheckbox:FormCheckBox?
    convenience init(_ field: FormCheckBox) {
        self.init()
        self.formcheckbox = field
    }
    func isMultiChoiceField() -> Bool {
        guard let type = formcheckbox?.props.type else {return false}
        return FormFieldType.fromString(type) == .categoryMultiChoiceField
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
