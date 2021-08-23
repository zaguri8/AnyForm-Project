//
//  FormFieldsViewController.swift
//  AnyForm
//
//  Created by נדב אבנון on 24/07/2021.
//
import UIKit
import MBCircularProgressBar
import RoundedSwitch
import WMSegmentControl
protocol FormCheckBoxDelegate {
    func didCheckValue(checkBox:FormCheckBox)
}
protocol FormTextFieldDelegate {
    func presentFromView(vc:UIViewController)
    func setFieldValue(arg1:String,arg2:String)
}


class FormFieldsViewController: UIViewController,UITextFieldDelegate,FormCheckBoxDelegate,FormTextFieldDelegate, UIDocumentInteractionControllerDelegate {
    func setFieldValue(arg1: String, arg2: String) {
        form.setFieldValue(for: "שם_פרטי", newValue: arg2)
        form.setFieldValue(for: "שם_משפחה", newValue: arg1)
    }
    
    func presentFromView(vc: UIViewController) {
        self.present(vc, animated: true)
    }
    

    func didCheckValue(checkBox: FormCheckBox) {
        setCheckBoxFieldValue(for: checkBox.key, checkBox.checked)
        
    }
    
    var form:Form!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        generateButton.isEnabled = false
        self.view.backgroundColor = form.getDesign().backgroundColor()
        hideKeyboardWhenTappedAround()
        createAllFieldInputs {
            sendTip()
        }
        addFieldQuestionCounter()
        addNextPrevButtons()
        showFirstField()
    }
    
    func sendTip() {
        let user = CoreDataManager.shared.getUser()
        let firstEntrance = user?.firstEntrance ?? false
        if firstEntrance {
            let alert = UIAlertController(title: "AnyForm", message: "ענה על כל השאלות ולחץ על כפתור יצירת קובץ PDF בעת סיום", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "הבנתי", style: .default))
            self.present(alert, animated: true)
            user?.firstEntrance = false
            CoreDataManager.shared.saveContext()
        }else {
            guard let data = user?.getUserData(),!data.isEmpty else {
                return}
            let alert = UIAlertController(title: "AnyForm", message: "האם תרצה להשתמש בהיסטוריית הנתונים השמורים?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "כן", style: .default,handler: { (act) in
                self.populateWithUserData()
            }))
            alert.addAction(UIAlertAction(title: "לא תודה", style: .default))
            self.present(alert, animated: true)
        }
    }

    var buttonStack:UIStackView = {
        let stack = UIStackView()
        return stack
    }()
    
    
    
    lazy var fieldCounter:UILabel = {
        let label = UILabel()
        label.attributedText = self.form.getDesign().questionCounterAttributes(text: "שאלה מספר 1 מתוך \(self.fieldHolder.count)")
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let tf = textField as? UITextFieldForm, let key = tf.formtextfield?.key, let value = tf.text,!value.isEmpty else {return}
        form.setFieldValue(for: key, newValue: value)
        
    }
    
    lazy var nextButton:UIButton = {
        let button = UIButton()
        let att = form.getDesign().buttonsTextAttributes(text: "הַבָּא")
        button.setAttributedTitle(att, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction(handler: { act in
            self.nextField()
        }), for: .touchUpInside)
        return button
    }()
    
    lazy var prevButton:UIButton = {
        let button = UIButton()
        let att = form.getDesign().buttonsTextAttributes(text: "קודם")
        button.setAttributedTitle(att, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        button.addAction(UIAction(handler: { act in
            self.previousField()
        }), for: .touchUpInside)
        return button
    }()
    
    var fieldHeaders:[UILabel] = []
    var textFields:[Any] = [] // UIFormTextField
    var checkBoxes:[UICheckBoxForm] = []
    var datePickers:[UIDatePickerForm] = []
    var fieldStack:[UIStackView] = []
    var fieldHolder:[UIView] = []
    var currentField = 0
    
    
    func populateWithUserData() {
        guard let allData = CoreDataManager.shared.getUserData(), !allData.isEmpty else {
            return}
        var gamefields:[UITextFieldFormGamified] = []
        var tfs:[UITextFieldForm] = []
        self.textFields.forEach { any in
            if let any = any as? UITextFieldFormGamified {
                gamefields.append(any)
            }else if let any  = any as? UITextFieldForm {
                tfs.append(any)
            }
        }
        
        for d in allData {
            if self.form.getTextFields().contains(where: { (textfield)  in
                textfield.key == d.key
            })  {
               
                guard let match = (self.textFields.first { (textfield)  in
                    if let tf = textfield as? UITextFieldFormGamified {
                        return tf.field?.key == d.key
                    }else  {
                       return  (textfield as! UITextFieldForm).formtextfield!.key == d.key
                    }
                }) else {
                    return}
                
                guard let match = tfs.first(where: { tf in
                    tf.formtextfield?.key == d.key
                })else {
                    guard let gamifiedMatch = gamefields.first(where: { gfs in
                        return gfs.field?.key == d.key
                    })else {return}
                    guard let firstName = allData.first(where: { nextD in
                     return   nextD.key! == "שם_פרטי"
                    })?.value  else {return}
                    guard let lastName = allData.first(where: { nextD in
                        nextD.key! == "שם_משפחה"
                    })?.value else {return}
                    gamifiedMatch.savedData = firstName + " " + lastName
                    return
                }
                
                let data = d.value ?? ""
                match.text = data
                match.formtextfield!.value = data

        
            }
            if(self.form.getCheckBoxes().contains(where: { (checkbox)  in
                checkbox.key == d.key
            }) ) {
                guard let match = (self.checkBoxes.first { (checkbox)  in
                    checkbox.formcheckbox!.key == d.key
                }) else {return}
                let data = d.value == "false" ? false : true
                match.isChecked = data
                match.formcheckbox?.checked = data
            }
        }
        
    }
    
    func saveUserData() {
        for checkBox in self.checkBoxes {
            guard let formData  = checkBox.formcheckbox else {
                return}
            let strVal = checkBox.isChecked ? "true" : "false"
            CoreDataManager.shared.addUserData(key: formData.key, value: strVal,category: formData.props.category)
        }
        for textField in self.textFields {
            if let tf = textField as? UITextFieldForm {
                guard let formData = tf.formtextfield, let strVal = tf.text, !strVal.isEmpty else {return}
                CoreDataManager.shared.addUserData(key: formData.key, value: strVal,category: "")
            }else if let gamifiedtf = textField as? UITextFieldFormGamified {
                guard let arg1 = gamifiedtf.arg1,let arg2 = gamifiedtf.arg2, !arg1.isEmpty, !arg2.isEmpty else {return}
                CoreDataManager.shared.addUserData(key: "שם_פרטי", value: arg1,category: "")
                CoreDataManager.shared.addUserData(key: "שם_משפחה", value: arg2, category: "")
            }
        }
    }
    
    func showFirstField() {
        fieldHolder[currentField].isHidden = false
    }
    
    
    @objc func setFieldDate(_ picker: UIDatePickerForm) {
        guard  let key = picker.formtextfield?.key else {return}
        let strVal = picker.date.string()
        form.setFieldValue(for: key, newValue: strVal)
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
                label.text = newValue
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
            lbl.font = UIFont.boldSystemFont(ofSize: 8.5)
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
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageHovered)))
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
            }else {
                self.arg2 = textField.text
            }
        }
        
        @objc func imageHovered () {
            UIUtils.animateDuration({ [weak self] in
                self?.imageView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }, completion: {b in UIUtils.animateDuration({[weak self] in
                self?.imageView.transform =  .identity
            }, completion: {[weak self] b  in
                guard let title = self?.alertTitle else {return}
                let alert = UIAlertController(title: "AnyForm", message: title, preferredStyle: .alert)
                alert.addTextField { nameTextField in
                    nameTextField.delegate = self
                    nameTextField.textAlignment = .right
                    nameTextField.placeholder = "הכנס שם פרטי"
                }
                alert.addTextField { lastNameTextField in
                    lastNameTextField.delegate = self
                    lastNameTextField.textAlignment = .right
                    lastNameTextField.placeholder = "הכנס שם משפחה"
                }
                alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: { alert in
                    
                }))
                
                alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { act in
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
                        self?.label.text = arg2 + " " + arg1
                    }
                    }
                }))
                self?.delegate?.presentFromView(vc: alert)
            }, delay: 0, duration: 0.3) }, delay: 0, duration: 0.3)
        }
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }
    }
    
    func isGamifiedTextField(key:String) -> Bool {
        return key == "שם_פרטי" || key == "שם_משפחה"
    }
    func createFieldInput(_ formTextField:FormTextField) {
        let header = UILabel()
        let question = formTextField.key.replacingOccurrences(of: "_", with: " ").capitalized
        header.attributedText = form.getDesign().questionTextAttributes(text: question)
        header.textAlignment = .center
        header.layoutMargins = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        header.backgroundColor = form.getDesign().questionBoxHeaderBgColor()
        header.layer.borderColor = UIColor.black.cgColor
        header.layer.borderWidth = 0.5
        if formTextField.key.contains("תאריך") {
            
            let datePicker = UIDatePickerForm(formTextField)
            datePicker.date = Date()
            datePicker.datePickerMode = .date
            datePicker.addTarget(self, action: #selector(setFieldDate), for: .valueChanged)
            datePicker.preferredDatePickerStyle = .wheels
            self.datePickers.append(datePicker)
            
            let stack = UIStackView(arrangedSubviews: [header,datePicker])
            stack.axis = .vertical
            stack.distribution = .fillEqually
            stack.contentMode = .center
            stack.layer.cornerRadius = form.getDesign().questionBoxCornerRadius()
            stack.backgroundColor = form.getDesign().questionBoxColor()
            stack.layer.borderColor = form.getDesign().questionBoxBorderColor()
            stack.layer.borderWidth = form.getDesign().questionBoxBorderWidth()
            stack.clipsToBounds = true
            stack.setCustomSpacing(8, after: header)
            stack.translatesAutoresizingMaskIntoConstraints = false
            self.fieldStack.append(stack)
            
            let holder = UIView()
            holder.addSubview(stack)
            holder.backgroundColor = form.getDesign().holderBackgroundColor()
            let stackconstraints = [stack.centerXAnchor.constraint(equalTo: holder.centerXAnchor),
                                    stack.centerYAnchor.constraint(equalTo: holder.centerYAnchor),
                                    stack.heightAnchor.constraint(equalToConstant: 180),
                                    stack.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 1.3)]
            NSLayoutConstraint.activate(stackconstraints)
            holder.isHidden = true
            holder.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(holder)
            self.fieldHolder.append(holder)
            
            let holderconstraints = [holder.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                                     holder.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
                                     holder.heightAnchor.constraint(equalToConstant: 280),
                                     holder.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)]
            NSLayoutConstraint.activate(holderconstraints)
        }else {
            var stack:UIStackView = UIStackView()
            let isGamifiedTextfield = isGamifiedTextField(key: formTextField.key)
            // Only for first name and last name - איכס
            if (isGamifiedTextfield) {
                if formTextField.key == "שם_משפחה" {
                    return
                }
                let textFieldGamified = UITextFieldFormGamified(image: UIImage(named: "name_tag")!, field: formTextField, design: form.getDesign())
                stack = UIStackView(arrangedSubviews: [header,textFieldGamified])
                textFieldGamified.delegate = self
                textFieldGamified.alertTitle = "הכנס שם מלא"
                header.text = "שם מלא"
                self.textFields.append(textFieldGamified)
            }else {
            let textfield = UITextFieldForm(formTextField)
            textfield.attributedPlaceholder = form.getDesign().answerTextFieldAttributes(text: "הזן תשובה")
            textfield.delegate = self
            textfield.textAlignment = .center
            self.textFields.append(textfield)
             stack = UIStackView(arrangedSubviews: [header,textfield])
            }
            stack.axis = .vertical
            stack.distribution = isGamifiedTextfield ? .fill : .fillProportionally
            stack.contentMode = .center
            stack.spacing = 5.0
            stack.clipsToBounds = true
            stack.layer.borderColor = form.getDesign().questionBoxBorderColor()
            stack.layer.borderWidth = form.getDesign().questionBoxBorderWidth()
            stack.layer.cornerRadius = form.getDesign().questionBoxCornerRadius()
            stack.backgroundColor = form.getDesign().questionBoxColor()
            stack.translatesAutoresizingMaskIntoConstraints = false
            self.fieldStack.append(stack)
            
            let holder = UIView()
            holder.backgroundColor = form.getDesign().holderBackgroundColor()
            holder.addSubview(stack)
            let stackconstraints = [stack.centerXAnchor.constraint(equalTo: holder.centerXAnchor),
                                    stack.centerYAnchor.constraint(equalTo: holder.centerYAnchor),
                                    stack.heightAnchor.constraint(equalToConstant: isGamifiedTextfield ? 300 : 120),
                                    stack.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 1.2)]
            NSLayoutConstraint.activate(stackconstraints)
            holder.translatesAutoresizingMaskIntoConstraints = false
            holder.isHidden = true
            self.view.addSubview(holder)
            self.fieldHolder.append(holder)
            let constraints = [holder.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                               holder.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
                               holder.heightAnchor.constraint(equalToConstant: isGamifiedTextfield ? 350 : 280),
                               holder.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)]
            NSLayoutConstraint.activate(constraints)
        }
    }
    
    
    func setCheckBoxFieldValue(for key:String,_ value:Bool) {
        let strVal = value ? "true" : "false"
        form.setFieldValue(for: key, newValue: strVal)
    }
    
    
    
    static var categoryStack:( ([UIView]) -> UIStackView) = { (views) in
        let stack = UIStackView(arrangedSubviews: views)
        stack.distribution = .fillEqually
        stack.axis = .vertical
        return stack
    }
    
    func createFieldInput(_ formCheckBox:FormCheckBox) {
        let header = UILabel()
        let question = formCheckBox.key.replacingOccurrences(of: "_", with:" ").capitalized
        header.attributedText = form.getDesign().questionTextAttributes(text: question)
        header.textAlignment = .center
        header.layoutMargins = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        header.backgroundColor = form.getDesign().questionBoxHeaderBgColor()
        header.layer.borderColor = UIColor.black.cgColor
        header.layer.borderWidth = 0.5
        let checkbox = UICheckBoxForm(formCheckBox)
        checkbox.isChecked = false
        checkbox.addAction(UIAction(handler: { [weak self]  (act)in
            checkbox.isChecked = !checkbox.isChecked
            self?.setCheckBoxFieldValue(for: formCheckBox.key, checkbox.isChecked)
        }), for: .touchUpInside)
        self.checkBoxes.append(checkbox)
        let yes = UILabel()
        yes.textAlignment = .center
        
        yes.attributedText = form.getDesign().questionTextAttributes(text: "סמן את התיבה אם כן")
        let cstack = UIStackView(arrangedSubviews: [checkbox,yes])
        cstack.axis = .horizontal
        cstack.distribution = .fillProportionally
        cstack.spacing = 0
        
        let stack = UIStackView(arrangedSubviews: [header,cstack])
        stack.isUserInteractionEnabled = true
        stack.axis = .vertical
        stack.clipsToBounds = true
        
        stack.layer.borderColor = form.getDesign().questionBoxBorderColor()
        stack.layer.borderWidth = form.getDesign().questionBoxBorderWidth()
        stack.layer.cornerRadius = form.getDesign().questionBoxCornerRadius()
        stack.backgroundColor = form.getDesign().questionBoxColor()
        
        stack.distribution = .fillProportionally
        stack.contentMode = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        
        self.fieldStack.append(stack)
        let holder = UIView()
        holder.addSubview(stack)
        holder.backgroundColor = form.getDesign().holderBackgroundColor()
        let stackconstraints = [stack.centerXAnchor.constraint(equalTo: holder.centerXAnchor),
                                stack.centerYAnchor.constraint(equalTo: holder.centerYAnchor),
                                stack.heightAnchor.constraint(equalToConstant: 180),
                                stack.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 1.2)]
        NSLayoutConstraint.activate(stackconstraints)
        
        
        holder.isHidden = true
        holder.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(holder)
        self.fieldHolder.append(holder)
        let constraints = [holder.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                           holder.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
                           holder.heightAnchor.constraint(equalToConstant: 280),
                           holder.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)]
        NSLayoutConstraint.activate(constraints)
    }
    
    class AnyFormSegmentControl  {
        var segmentControl:WMSegment
        var items: [FormCheckBox]
        var delegate:FormCheckBoxDelegate!
        init (items:[FormCheckBox], segmentControl:WMSegment,delegate: FormCheckBoxDelegate,defaultColor:UIColor) {
            self.segmentControl = segmentControl
            self.items = items
            self.segmentControl.buttonTitles = items.compactMap({ item in
               return  item.key.replacingOccurrences(of: "_", with: " ")
            }).joined(separator: ",")
            self.segmentControl.buttonImages = items.compactMap({ item in
                item.props.bitmap
            }).joined(separator: ",")
            self.delegate = delegate
            setup()
            self.segmentControl.selectorColor = defaultColor
            self.segmentControl.selectorTextColor = defaultColor
            self.segmentControl.selectorType = .bottomBar
            self.segmentControl.normalFont = UIFont.boldSystemFont(ofSize: 12)
            self.segmentControl.SelectedFont = UIFont.boldSystemFont(ofSize: 12)
            self.segmentControl.isRounded = true
        }
        
    
        func setup() {
            segmentControl.addAction(UIAction(handler: {act in
                self.items[self.segmentControl.selectedSegmentIndex].checked = true
                for (index,item) in self.items.enumerated() {
                    if item.key != self.items[self.segmentControl.selectedSegmentIndex].key {
                        self.items[index].checked =  false
                    }
                    self.delegate.didCheckValue(checkBox: self.items[index])
                }
            }), for: .touchUpInside)
            
        }

    }
    
    
    var segmentControls:[AnyFormSegmentControl] = []

    func createFieldInputCategory(category:String,formCheckBoxes:[FormCheckBox]) {
        let header = UILabel()
        let isBinaryQuestion = formCheckBoxes.count % 2 == 0
        let question = category.replacingOccurrences(of: "_", with:" ").capitalized
        
        // Question header . EX: First Name
        header.attributedText = form.getDesign().questionTextAttributes(text: question)
        header.layoutMargins = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        header.numberOfLines = 2
        header.translatesAutoresizingMaskIntoConstraints = false
        header.backgroundColor = form.getDesign().questionBoxHeaderBgColor()
        header.layer.cornerRadius = 8
        header.layer.borderWidth = 0.4
        header.layer.borderColor = form.getDesign().questionBoxHeaderBgColor().cgColor
        header.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        header.clipsToBounds = true
        header.textAlignment = .center
        var checkboxesStacks:[UIStackView] = []
        
        // binary - 2 options of selection
        if isBinaryQuestion {
            let segmentControl = WMSegment()
            let pickSwitch = AnyFormSegmentControl(items: formCheckBoxes, segmentControl: segmentControl, delegate: self,defaultColor: form.getDesign().questionBoxHeaderBgColor())
                segmentControls.append(pickSwitch)
                var cstack:UIStackView?
                let v = UIView()
                v.addSubview(segmentControl)
            segmentControl.translatesAutoresizingMaskIntoConstraints = false
            segmentControl.widthAnchor.constraint(equalTo: v.widthAnchor).isActive = true
            segmentControl.heightAnchor.constraint(equalToConstant: 60).isActive = true
            segmentControl.centerXAnchor.constraint(equalTo: v.centerXAnchor).isActive = true
            segmentControl.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true
                cstack = UIStackView(arrangedSubviews: [v])
                if let cstack = cstack {
                cstack.axis = .horizontal
                checkboxesStacks.append(cstack)
            }
            // More then 2 options of selection
        }else  {
            formCheckBoxes.forEach { formCheckBox in
                let cbx:UICheckBoxForm = UICheckBoxForm(formCheckBox)
                cbx.isChecked = false
                cbx.setContentHuggingPriority(.defaultHigh, for: .horizontal)
                cbx.addAction(UIAction(handler: { [weak self]  (act)in
                    guard let strong = self else {return}
                    cbx.isChecked = !cbx.isChecked
                    strong.setCheckBoxFieldValue(for: formCheckBox.key, cbx.isChecked)
                    if cbx.isChecked {
                        for cb in strong.checkBoxes {
                            guard let fcb = cb.formcheckbox else {return}
                            if (fcb.props.category == formCheckBox.props.category) && (fcb.key != formCheckBox.key) {
                                cb.isChecked = !cbx.isChecked
                                self?.setCheckBoxFieldValue(for: fcb.key, !cbx.isChecked)
                            }
                        }
                    }
                }), for: .touchUpInside)
                self.checkBoxes.append(cbx)
                let yes = UILabel()
                yes.textAlignment = .center
                let question = formCheckBox.key.replacingOccurrences(of: "_", with:" ").capitalized
                yes.attributedText = form.getDesign().questionCheckBoxTextAttributrs(text: question)
                var cstack:UIStackView?
                if(formCheckBox.props.bitmap.isEmpty) {
                    cstack = UIStackView(arrangedSubviews: [cbx,yes])
                }else {
                    let bitmap = UIImageView(image:UIImage(named:formCheckBox.props.bitmap))
                    bitmap.contentMode = .scaleAspectFit
                    cstack = UIStackView(arrangedSubviews: [cbx,yes,bitmap])
                }
                if let cstack = cstack {
                cstack.distribution = .fill
                cstack.axis = .horizontal
                cstack.spacing = 4
                checkboxesStacks.append(cstack)
                }
            }
        }
        
        // Populate a stack view with all the categorie's checkboxes
        let catStack = FormFieldsViewController.categoryStack(checkboxesStacks)
   
        catStack.spacing = 0
        catStack.distribution = .fillEqually

        catStack.isUserInteractionEnabled = true
        catStack.axis = .vertical
        catStack.clipsToBounds = true
    
        catStack.layer.cornerRadius = form.getDesign().questionBoxCornerRadius()
        catStack.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
        
        catStack.backgroundColor = form.getDesign().questionBoxColor()
        catStack.distribution = .fillProportionally
        catStack.contentMode = .center
        catStack.isLayoutMarginsRelativeArrangement = true
        catStack.layoutMargins = UIEdgeInsets(top: 0, left: isBinaryQuestion ? 8 : 48, bottom: 0, right: isBinaryQuestion ? 8 : 48)
        catStack.translatesAutoresizingMaskIntoConstraints = false
        self.fieldStack.append(catStack)
        let holder = UIView()
        holder.addSubview(catStack)
        holder.backgroundColor = form.getDesign().holderBackgroundColor()
        
        let stackconstraints = [catStack.centerXAnchor.constraint(equalTo: holder.centerXAnchor),
                                catStack.topAnchor.constraint(equalTo: header.bottomAnchor),
                                catStack.heightAnchor.constraint(equalToConstant: isBinaryQuestion  ? 120 : 320),
                                catStack.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 1.3)]
        
        let headerconstraints = [header.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 1.3),
                                 header.centerXAnchor.constraint(equalTo: holder.centerXAnchor),
                                 header.heightAnchor.constraint(equalToConstant:50),
                                 header.topAnchor.constraint(equalTo: holder.topAnchor)]
        
        holder.addSubview(header)
        holder.isHidden = true
        holder.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(holder)
        self.fieldHolder.append(holder)
        let constraints = [holder.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                           holder.centerYAnchor.constraint(equalTo: self.view.centerYAnchor,constant: isBinaryQuestion ? 72 : 0),
                           holder.heightAnchor.constraint(equalToConstant: 340),
                           holder.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)]
        
        NSLayoutConstraint.activate(constraints)
        NSLayoutConstraint.activate(headerconstraints)
        NSLayoutConstraint.activate(stackconstraints)
        
    }
    
    func addNextPrevButtons() {
        let buttonStack = UIStackView(arrangedSubviews: [prevButton,nextButton])
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.axis = .horizontal
        buttonStack.isUserInteractionEnabled = true
        buttonStack.distribution = .fillEqually
        view.addSubview(buttonStack)
        let c  = [buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)]
        NSLayoutConstraint.activate(c)
    }
    
    let shapeLayer = CAShapeLayer()
    let trackLayer = CAShapeLayer()
    let prog =  MBCircularProgressBarView()
    func addFieldQuestionCounter() {
        prog.maxValue = CGFloat(self.fieldStack.count)
        
        prog.value = CGFloat(currentField)
        prog.backgroundColor = .clear
        prog.value = 1
        prog.progressColor = .green
        prog.progressStrokeColor = form.getDesign().questionBoxHeaderBgColor()
        prog.fontColor = .white
        prog.unitString = ""
        prog.valueFontSize = 24
        prog.progressLineWidth = 1
        prog.progressAngle = 100
        prog.progressRotationAngle = 50
        self.view.addSubview(prog)
        prog.translatesAutoresizingMaskIntoConstraints = false
        prog.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        prog.widthAnchor.constraint(equalToConstant: 70).isActive = true
        prog.heightAnchor.constraint(equalToConstant: 70).isActive = true
        prog.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor,constant: 24).isActive = true
    }
    
    
    func createAllFieldInputs(callback:() -> Void) {
        var tfs = form.getTextFields()
        var cbxs = form.getCheckBoxes()
        var categories:[String:[FormCheckBox]] = [:]
        cbxs.sort { fcbx1, fcbx2 in
            (fcbx1.point.y > fcbx2.point.y) && ( (fcbx1.point.x > fcbx2.point.x))
        }
    
        cbxs.forEach { cbx in
            if let cbxCat = categories[cbx.props.category], !cbxCat.isEmpty  {
                categories[cbx.props.category]?.append(cbx)
            }else {
                categories[cbx.props.category] = []
                categories[cbx.props.category]?.append(cbx)
            }
        }
        tfs.sort { tfs1, tfs2 in
            (tfs1.point.y > tfs2.point.y) && ( (tfs1.point.x > tfs2.point.x))
        }
        tfs.forEach(createFieldInput)
        categories.forEach { category,boxes in
            if category.isEmpty {
                boxes.forEach(createFieldInput)
            }else {
                self.createFieldInputCategory(category: category, formCheckBoxes: boxes)
            }
        }
        callback()
    }
    
    func nextField() {
        if !clickableButton {
            return
        }
        self.clickableButton = false
        let count = fieldHolder.count
        if(currentField == count-2) {
            self.nextButton.isHidden = true
            enableGenerateBarButton()
        }else if currentField+1 >= count {
            return
        }
    if(self.prevButton.isHidden && currentField >= 0) {
            self.prevButton.isHidden = false
        }
        
        hideCurrentField()
    }
    
    var clickableButton:Bool = true
    func previousField() {
        if !clickableButton {
            return
        }
        self.clickableButton = false
       // let count = fieldHolder.count
        if currentField < 0 {
            self.prevButton.isHidden = true
            return
        }
        if (self.nextButton.isHidden) {
            disableGenerateBarButton()
            self.nextButton.isHidden = false
            
        }
        
        if(currentField - 1 <= 0 ) {
            self.prevButton.isHidden = true
        }
        hideCurrentField(true)
    }
    
    @IBOutlet weak var generateButton: UIBarButtonItem!
    
    func enableGenerateBarButton() {
        generateButton.isEnabled = true
    }
    func disableGenerateBarButton() {
        generateButton.isEnabled = false
    }
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    var docController:UIDocumentInteractionController = UIDocumentInteractionController()
    @IBAction func fillForm(_ sender: Any) {
        let alert = UIAlertController(title: "AnyForm", message: "האם אתה מוכן ליצור קובץ PDF?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "עדיין לא", style: .default))
        alert.addAction(UIAlertAction(title: "אני מוכן", style: .destructive, handler: { [weak self](act) in
            self?.saveUserData()
            self?.form.fill { url in
                let alert = UIAlertController(title: "AnyForm", message: "המסמך נוצר בהצלחה ונשמר בתיקיית המסמכים במכשירך \(url.path)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "פתח את המסמך", style: .default, handler: { (act) in
                    guard let selfStrong = self else {return}
                    selfStrong.docController = UIDocumentInteractionController(url: url)
                    selfStrong.docController.delegate = selfStrong
                    selfStrong.docController.presentOpenInMenu(from: (sender as! UIButton).frame, in: selfStrong.view, animated: true)
                }))
                alert.addAction(UIAlertAction(title: "שתף ב- WhatsApp", style: .default, handler: { (act) in
                    guard let selfStrong = self else {return}
                    WhatsAppShare.whatsappShareWithImages(url, controller: &selfStrong.docController, viewcontroller: selfStrong)
                }))
                alert.addAction(UIAlertAction(title: "סגור", style: .cancel))
                self?.present(alert, animated: true)
            }
        }))
        self.present(alert, animated: true)
        
    }
    
    
    /// `Hide Current Field Method`
    /// - Parameter prev: Previous button true / Next Button false
    /// - This is a little messy but works
    func hideCurrentField(_ prev:Bool = false) {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: []) {
            if self.currentField < 0 {
                return}
            self.fieldHolder[self.currentField].alpha = 0
        } completion: { (bool) in
            if self.currentField < 0 {
                return}
            self.fieldHolder[self.currentField].isHidden = true
            if prev {
                self.currentField -= 1
                let replace = "מספר "
                self.fieldCounter.text = self.fieldCounter.text?.replacingOccurrences(of: replace + String(self.currentField + 2), with: replace +  String(self.currentField + 1))
                if self.currentField < 0 {
                    return}
            }else {
                if self.currentField + 1 >= self.fieldHolder.count {
                    return
                }
                let replace = "מספר "
                self.currentField += 1
                self.fieldCounter.text = self.fieldCounter.text?.replacingOccurrences(of: replace + String(self.currentField), with:  replace + String(self.currentField == 1 ? 2 : self.currentField + 1))
            }
            if (self.currentField == self.fieldHolder.count) {
                self.nextButton.isHidden = true
            }
            self.showNextField()
        }
    }
    
    
    
    func showNextField() {
        
        self.fieldHolder[self.currentField].isHidden = false
        self.fieldHolder[self.currentField].alpha = 0
        
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: []) {
            self.fieldHolder[self.currentField].alpha = 1
        } completion: { (complete) in
            self.clickableButton = true
        }
        self.prog.value = CGFloat(self.currentField+1)
//        if currentField == 10 {
//            let v = UIView()
//            v.translatesAutoresizingMaskIntoConstraints = false
//            let text = ViewFactory.blackCenteredLabel("קדימה, נותרו רק 5 שאלות!")
//            text.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
//            v.addSubview(text)
//            v.backgroundColor = form.getDesign().questionBoxColor()
//            text.center = v.convert(v.center, from: v.superview)
//            self.view.addSubview(v)
//            v.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16).isActive = true
//
//            v.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 16).isActive = true
//
//            v.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 16).isActive = true
//            v.widthAnchor.constraint(equalToConstant: 100).isActive = true
//            v.heightAnchor.constraint(equalToConstant: 70).isActive = true
//            v.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
//        }
    }

    
    func setForm(_ form:Form) {
        self.form = form
    }
    
    
}
