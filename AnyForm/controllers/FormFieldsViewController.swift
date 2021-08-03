//
//  FormFieldsViewController.swift
//  AnyForm
//
//  Created by נדב אבנון on 24/07/2021.
//

import UIKit
class FormFieldsViewController: UIViewController,UITextFieldDelegate, UIDocumentInteractionControllerDelegate {
    var form:Form!
    override func viewDidLoad() {
        super.viewDidLoad()
        generateButton.isEnabled = false
        self.view.backgroundColor = form.getDesign().backgroundColor()
        sendTip()
        hideKeyboardWhenTappedAround()
        createAllFieldInputs()
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
            guard let data = user?.data,!data.isEmpty else {

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
    var textFields:[UITextFieldForm] = []
    var checkBoxes:[UICheckBoxForm] = []
    var datePickers:[UIDatePickerForm] = []
    var fieldStack:[UIStackView] = []
    var fieldHolder:[UIView] = []
    var currentField = 0
    
    
    func populateWithUserData() {
        guard let data = CoreDataManager.shared.getUserData(), !data.isEmpty else {
            return}
        for (k,v) in data {
            if self.form.getTextFields().contains(where: { (textfield)  in
                textfield.key == k
            })  {
                guard let match = (self.textFields.first { (textfield)  in
                    textfield.formtextfield!.key == k
                }) else {return}
                let data = v as! String
                match.text = data
                match.formtextfield!.value = data
            }
            if(self.form.getCheckBoxes().contains(where: { (checkbox)  in
                checkbox.key == k
            }) ) {
                guard let match = (self.checkBoxes.first { (checkbox)  in
                    checkbox.formcheckbox!.key == k
                }) else {return}
                let data = (v as! String) == "false" ? false : true
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
            CoreDataManager.shared.setUserData(key: formData.key, value: strVal)
        }
        for textField in self.textFields {
            guard let formData = textField.formtextfield, let strVal = textField.text, !strVal.isEmpty else {return}
            CoreDataManager.shared.setUserData(key: formData.key, value: strVal)
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
    func createFieldInput(_ formTextField:FormTextField) {
        let header = UILabel()
        let question = formTextField.key.replacingOccurrences(of: "_", with: " ").appending(":").capitalized
        header.attributedText = form.getDesign().questionTextAttributes(text: question)
        header.textAlignment = .center
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
            
            let textfield = UITextFieldForm(formTextField)
            textfield.attributedPlaceholder = form.getDesign().answerTextFieldAttributes(text: "הזן תשובה")
            textfield.delegate = self
            textfield.textAlignment = .center
            textfield.layer.borderWidth = 0.6
            textfield.layer.borderColor = UIColor.black.cgColor
            self.textFields.append(textfield)
            
            let stack = UIStackView(arrangedSubviews: [header,textfield])
            stack.axis = .vertical
            stack.distribution = .fillProportionally
            stack.contentMode = .center
            stack.spacing = 5.0
            stack.setCustomSpacing(24, after: header)
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
                                    stack.heightAnchor.constraint(equalToConstant: 120),
                                    stack.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 1.5)]
            NSLayoutConstraint.activate(stackconstraints)
            holder.translatesAutoresizingMaskIntoConstraints = false
            holder.isHidden = true
            self.view.addSubview(holder)
            self.fieldHolder.append(holder)
            
            let constraints = [holder.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                               holder.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
                               holder.heightAnchor.constraint(equalToConstant: 280),
                               holder.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)]
            NSLayoutConstraint.activate(constraints)
        }
        
    }
    func setCheckBoxFieldValue(for key:String,_ value:Bool) {
        let strVal = value ? "true" : "false"
        form.setFieldValue(for: key, newValue: strVal)
    }
    
    func createFieldInput(_ formCheckBox:FormCheckBox) {
        let header = UILabel()
        let question = formCheckBox.key.replacingOccurrences(of: "_", with:" ").appending(":").capitalized
        header.attributedText = form.getDesign().questionTextAttributes(text: question)
        header.textAlignment = .center
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
                                stack.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 1.3)]
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
    
    func addFieldQuestionCounter() {
        
        self.view.addSubview(fieldCounter)
        let fieldCounterConstraints = [fieldCounter.bottomAnchor.constraint(equalTo: self.fieldStack[0].topAnchor, constant: -64),
                                       fieldCounter.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)]
        NSLayoutConstraint.activate(fieldCounterConstraints)
    }
    func createAllFieldInputs() {
        let tfs = form.getTextFields()
        let cbxs = form.getCheckBoxes()
        tfs.forEach(createFieldInput)
        cbxs.forEach(createFieldInput)
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
        }else if(self.prevButton.isHidden && currentField >= 0) {
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
        let count = fieldHolder.count
        if currentField < 0 {
            self.prevButton.isHidden = true
            return
        }else if (self.nextButton.isHidden) {
            disableGenerateBarButton()
            self.nextButton.isHidden = false
        } else if(currentField - 1 == 0 && currentField + 1 < count ) {
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
    }
    
    func setForm(_ form:Form) {
        self.form = form
    }
    
    
}
