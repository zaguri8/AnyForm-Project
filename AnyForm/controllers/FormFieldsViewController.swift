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
    
 
    /**
        This method sets the value of the gamified text fields
            current supporting שם_משפחה,שם_פרטי
     */
    func setFieldValue(arg1: String, arg2: String) {
        form.setFieldValue(for: "שם_פרטי", newValue: arg2)
        form.setFieldValue(for: "שם_משפחה", newValue: arg1)
        clearField()
    }
    
    func presentFromView(vc: UIViewController) {
        self.present(vc, animated: true)
    }
    

    func didCheckValue(checkBox: FormCheckBox) {
        setCheckBoxFieldValue(for: checkBox.key, checkBox.checked)
        clearField()
    }
    func showFormFillingToast(message:String) {
        showAnyFormToast(message:message,boxColor:form.getDesign().questionBoxHeaderBgColor().withAlphaComponent(0.8),borderColor: .white,textColor: .white,font: UIFont.boldSystemFont(ofSize: 15.5))
        
    }
    func clearField() {
        let cleared = !completionButton.isEnabled && allCleared()
        if cleared { enableGenerateBarButton()}
        progTunnel.scrollToItem(at: IndexPath(row: currentField, section: 0), at: .centeredHorizontally, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {[weak self] in
            guard let strong = self else {return}
            guard let tube = strong.progTunnel.cellForItem(at: IndexPath(row: strong.currentField, section: 0)) as? Tube else {
                print("bad tube")
                return}
            if !strong.clearedFieldKeys.contains(tube.tubeLabel.text!) {
                strong.clearedFieldKeys.append(tube.tubeLabel.text!)
           
            tube.clear()
                if (((strong.fieldHolder.count - strong.clearedFieldCount() - 2) != 0)
                        && (strong.clearedFieldCount() == 1 || strong.clearedFieldCount() % 5 == 0 && strong.clearedFieldCount() > 0 )) {
                    strong.showFormFillingToast(message: "קדימה! נשארו עוד \(strong.fieldHolder.count - strong.clearedFieldCount()) שאלות")
            }else if (cleared) {
                strong.showFormFillingToast(message: "ענית על כל השאלות! לחץ על הכפתור למעלה ליצירת קובץ")
            }
               
            }
        }
    }
    
    func clearFields(keys:[String]) {
        for (i,h) in fieldHeaders.enumerated() {
            if keys.contains(h) {
                guard let tube = progTunnel.cellForItem(at: IndexPath(row: i, section: 0)) as? Tube else {
                    print("no tube")
                return}
            tube.clear()
            clearedFieldKeys.append(h)
            }
        }
    }
    
    var form:Form!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        generateButton.isEnabled = false
        self.view.backgroundColor = form.getDesign().backgroundColor()
        hideKeyboardWhenTappedAround()
        createNavBar()
        createAllFieldInputs {
            createProgressionTunnel()
            sendTip()
        }
        addFieldQuestionCounter()
        showFirstField()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        hideNavBar()
        self.view.addGestureRecognizer(swipeLeftGesture)
        self.view.addGestureRecognizer(swipeRightGesture)
    }
    override func viewDidDisappear(_ animated: Bool) {
        showNavBar()
        showTabBar()
    }
    
    @objc func swipeLeft(_ gesture:UISwipeGestureRecognizer) {
        if currentField == fieldHolder.count-1 {
            return
        }
        nextField()
    }
    @objc func swipeRight(_ gesture:UISwipeGestureRecognizer) {
        if currentField == 0 {
            return
        }
        previousField()
    }
    var toggledMenu:Bool = false
    func showMenu() {
        UIUtils.animateDuration({
            if !self.toggledMenu  {
                self.menuAnchor?.constant = 0
                self.menuButton.transform = CGAffineTransform(rotationAngle:CGFloat((90 * Double.pi) / 180))
                self.view.bringSubviewToFront(self.menu)
                self.view.mask?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                self.view.layoutIfNeeded()
                
            }else {
                self.menuAnchor?.constant = 300
                self.menuButton.transform = CGAffineTransform(rotationAngle: 0)
                self.view.layoutIfNeeded()
            }
        }, duration: 1)
        toggledMenu = !toggledMenu
    }
    
    func addSignatureField() {
        let header = headerLabel("חתימה")
        let holder = UIView()
        self.fieldHeaders.append("חתימה")
 
        let signature = AnyFormSignatureField()
        
        signature.isOpaque = false
        signature.backgroundColor = .clear
        let submitBtn = UIButton()
        submitBtn.setAttributedTitle(NSAttributedString(string:"שלח" + " " + "חתימה" , attributes: [.foregroundColor : UIColor.systemGreen,.font : UIFont.boldSystemFont(ofSize: 14)]), for: .normal)
        submitBtn.addAction(UIAction(handler: {act in
            self.setFieldSignature(cgImage: signature.getSignature())
        }), for: .touchUpInside)
        let clearBtn = UIButton()
        clearBtn.setAttributedTitle(NSAttributedString(string:"נקה" , attributes: [.foregroundColor : UIColor.systemGreen,.font : UIFont.boldSystemFont(ofSize: 14)]), for: .normal)
        clearBtn.addAction(UIAction(handler: {act in
            signature.clear()
        }), for: .touchUpInside)
        
        let btnStack = UIStackView(arrangedSubviews: [submitBtn,clearBtn])
        btnStack.axis = .horizontal
        btnStack.distribution = .fillEqually
        signature.setStrokeColor(color: .black)
        header.heightAnchor.constraint(equalToConstant: 50).isActive = true
        header.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        header.bounds.size.height = 50
        header.layer.cornerRadius = 8
        header.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        header.clipsToBounds = true
    
        let stack = UIStackView(arrangedSubviews: [header,signature,btnStack])
        
        
        stack.axis = .vertical
        stack.distribution = .fill
        stack.contentMode = .center
        stack.spacing = 0
        stack.clipsToBounds = true
        stack.layer.borderColor = form.getDesign().questionBoxBorderColor()
        stack.layer.borderWidth = form.getDesign().questionBoxBorderWidth()
        stack.layer.cornerRadius = form.getDesign().questionBoxCornerRadius()
        stack.backgroundColor = form.getDesign().questionBoxColor()
        stack.translatesAutoresizingMaskIntoConstraints = false
        self.fieldStack.append(stack)

        stack.addShadowAround(size: CGSize(width: (UIScreen.main.bounds.width / 1.2),
                                           height: 120))
        
        holder.backgroundColor = form.getDesign().holderBackgroundColor()
        holder.addSubview(stack)
        
        let stackconstraints = [stack.centerXAnchor.constraint(equalTo: holder.centerXAnchor),
                                stack.centerYAnchor.constraint(equalTo: holder.centerYAnchor),
                                stack.heightAnchor.constraint(equalToConstant: 180),
                                stack.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 1.2)]
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
    
    /**
        This method sends the form entrance messages to the user
        use saved info, instructions etc..
     */
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

    // we dont use this anymore
    // next&prev buttons replaced with swiping.
    var buttonStack:UIStackView = {
        let stack = UIStackView()
        return stack
    }()

    lazy var swipeRightGesture:UISwipeGestureRecognizer = {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight))
        swipe.direction = .right
        return swipe
    }()
    
    lazy var swipeLeftGesture:UISwipeGestureRecognizer = {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft))
        swipe.direction = .left
        return swipe
    }()
    func textFieldDidBeginEditing(_ textField: UITextField) {
        canSwipeField = false
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        guard let tf = textField as? UITextFieldForm, let formfield = tf.formtextfield else {return false}
        if FieldProps.isPhoneNumberField(formfield.key)  || FieldProps.isNumericField(formfield.key){
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
    
    /**
            This button is in charge of showing drawer menu
     */
    lazy var menuButton:UIButton = {
       let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "menu"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction(handler: { act in
            self.showMenu()
        }), for: .touchUpInside)
        return button
    }()
    lazy var backButton:UIButton = {
       let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "back"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction(handler: { act in
            self.navigationController?.popViewController(animated: true)
        }), for: .touchUpInside)
        return button
    }()
    
    lazy var completionButton:UIButton = {
       let button = UIButton()
        button.setTitle("צור קובץ PDF", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction(handler: {act in self.complete()}), for: .touchUpInside)
        button.contentEdgeInsets = UIEdgeInsets(top: 32, left: 16, bottom: 32, right: 16)
        button.layer.cornerRadius = 8
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 0.2
        button.backgroundColor = .white.withAlphaComponent(0.2)
        button.sizeToFit()
        return button
    }()
    
    lazy var navBar:UIView = {
        let nav = UIView()
        nav.backgroundColor = form.getDesign().questionBoxHeaderBgColor()
        nav.translatesAutoresizingMaskIntoConstraints = false
        return nav
    }()
    var menu:FormMenu!
    

    
    var fieldHeaders:[String] = []
    var textFields:[Any] = [] // UIFormTextField
    var checkBoxes:[UICheckBoxForm] = []
    var datePickers:[UIDatePickerForm] = []
    var fieldStack:[UIStackView] = []
    var fieldHolder:[UIView] = []
    var currentField = 0
    var clearedFieldKeys:[String] = []
    
    func populateWithUserData() {
        guard let allData = CoreDataManager.shared.getUserData(), !allData.isEmpty else {
            return}
        let saved =  allData.compactMap{$0.key}
        let toclear =  allData.compactMap{$0.key?.textFromKey()}
        clearFields(keys: toclear)
        var gamefields:[UITextFieldFormGamified] = []
        var tfs:[UITextFieldForm] = []
        self.textFields.forEach { any in
            if let gamefield = any as? UITextFieldFormGamified {
                guard let key = gamefield.field?.key else {return }
                if saved.contains(key) && FieldProps.isNameField(key) {gamefields.append(gamefield)}
            }else if let tf  = any as? UITextFieldForm {
                guard let key = tf.formtextfield?.key else {return }
                if saved.contains(key) {tfs.append(tf)}
            }
        }
          
          for d in allData {
            let trueKey = FieldProps.savedKey(for: d.key!).textFromKey()
              if self.form.getTextFields().contains(where: { (textfield)  in
                textfield.key.textFromKey() == d.key!.textFromKey()
              })  {
                  guard let match = tfs.first(where: { tf in
                    tf.formtextfield?.key.textFromKey() == trueKey
                  })else {
                      guard let gamifiedMatch = gamefields.first(where: { gamefield in
                        gamefield.field?.key.textFromKey() == trueKey
                      }) else {
                          return}
                      guard let firstName = allData.first(where: { nextD in
                        return   nextD.key!.textFromKey() == "שם פרטי"
                      })?.value  else {
                          return}
                      guard let lastName = allData.first(where: { nextD in
                        nextD.key!.textFromKey() == "שם משפחה"
                      })?.value else {
                          return}
                      gamifiedMatch.savedData = firstName + " " + lastName
                      return
                  }
                  
                  let data = d.value ?? ""
                  match.text = data
                  match.formtextfield!.value = data
              }
              if(self.form.getCheckBoxes().contains(where: { (checkbox)  in
                checkbox.key.textFromKey() == d.key?.textFromKey()
              }) ) {
                  guard let match = (self.checkBoxes.first { (checkbox)  in
                    checkbox.formcheckbox!.key.textFromKey() == d.key?.textFromKey()
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
                CoreDataManager.shared.addUserData(key: "שם_פרטי", value: arg2,category: "")
                CoreDataManager.shared.addUserData(key: "שם_משפחה", value: arg1, category: "")
            }
        }
    }
    
    func showFirstField() {
        fieldHolder[currentField].isHidden = false
    }


    func setFieldText(tf:UITextFieldForm) {
        canSwipeField = true
        guard let key = tf.formtextfield?.key, let value = tf.text,!value.replacingOccurrences(of: " ", with: "").isEmpty else {return}
        showFormFillingToast(message: key.textFromKey() + " " +  "השתנה בהצלחה\n" + value)
        form.setFieldValue(for: key, newValue: value)
        clearField()
    }
    func setFieldSignature(cgImage:CGImage?) {
        canSwipeField = true
        form.setSignature(val: cgImage)
        clearField()
    }
      func setFieldDate(_ picker: UIDatePickerForm) {
        guard  let key = picker.formtextfield?.key else {return}
        showFormFillingToast(message: key.textFromKey() + " " +  "השתנה בהצלחה\n" + picker.date.dateString())
        let strVal = picker.date.string()
        form.setFieldValue(for: key, newValue: strVal)
        clearField()
    }

    

    
    lazy var progTunnel:UICollectionView = {
        let tunnelLayout = UICollectionViewFlowLayout()
        tunnelLayout.scrollDirection = .horizontal
        tunnelLayout.itemSize = CGSize(width: 200, height: 80)
        tunnelLayout.minimumInteritemSpacing  = 0.0
        tunnelLayout.minimumLineSpacing = 0.0
        let tunnelPos = CGPoint(x: 0, y: 620)
        let tunnelFrame = CGRect(x: tunnelPos.x, y: tunnelPos.y, width: UIScreen.main.bounds.size.width, height: 100)
        let tunnelView = UICollectionView(frame: tunnelFrame, collectionViewLayout: tunnelLayout)
        tunnelView.delegate = self
        tunnelView.dataSource = self
        tunnelView.backgroundView?.addShadowAround(size: CGSize(width: 200, height: 100))
        tunnelView.register(UINib(nibName: "Tube", bundle: .main), forCellWithReuseIdentifier: "tubecell")
        tunnelView.backgroundColor = UIUtils.hexStringToUIColor(hex: "ff9248")
        tunnelView.cornerRadius = 8
        tunnelView.borderWidth = 0.5
        tunnelView.borderColor = .black
        tunnelView.bounces = false
        tunnelView.alwaysBounceHorizontal = false
        tunnelView.translatesAutoresizingMaskIntoConstraints = false
        return tunnelView
    }()
    
    func createProgressionTunnel() {
        self.view.addSubview(progTunnel)
        progTunnel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,constant: -4).isActive = true
        progTunnel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 4).isActive = true
        progTunnel.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor,constant: -8).isActive = true
        progTunnel.heightAnchor.constraint(equalToConstant:100).isActive = true
    }
    
    class FieldProps {
         static func isDateField(_ key:String) -> Bool {return key.contains("תאריך")}
        static  func isLocationField(_ key:String) -> Bool{
            let k = key.replacingOccurrences(of:"_",with:" ")
            return k.contains("עיר")}
         static func isNameField(_ key:String) -> Bool {
            let fieldKey = key.textFromKey()
            return fieldKey.contains("שם פרטי")
         }
        static func isNumericField(_ key:String) -> Bool{
            let k = key.textFromKey()
            return k.contains("מספר") || k.contains("תעודה") || k.contains("תעודת")
        }
        static func isPhoneNumberField(_ key:String) -> Bool{
            let k = key.textFromKey()
            return k.contains("מספר") || k.contains("פלאפון") || k.contains("טלפון")  || k.contains("נייד")
        }
        static func savedKey(for childKey:String) -> String {
                if childKey == "שם_משפחה" {return "שם_פרטי"}
                else if childKey == "עיר_מגורים" {return "כתובת"}
                return childKey
            }
        
         static func isSubField(_ key:String) -> Bool {
            let k = key.textFromKey()
            return k.contains("שם משפחה") || k.contains("רחוב") ||  k.contains("מיקוד") || k.contains("חתימה")
         }
         static func getRootFieldKey(_ childKey:String) -> String {
            let k = childKey.textFromKey()
            if k == ("שם משפחה") || k == ("שם פרטי") {return "שם_מלא"}
            else if k.contains("עיר") || k.contains("רחוב") {return "כתובת"}
             return childKey
         }
    }
    
    func createFieldInput(_ formTextField:FormTextField) {
        if(FieldProps.isSubField(formTextField.key)) {return}
        var header:UILabel!
            func createHeader() {
                let question = FieldProps.getRootFieldKey(formTextField.key).textFromKey().capitalized
                header = headerLabel(question)
                self.fieldHeaders.append(header.text ?? "")
                }
        
        createHeader()
        
        
        if FieldProps.isDateField(formTextField.key) {
            
            // Create a new date picker
            let datePicker = UIDatePickerForm(formTextField)
            datePicker.date = Date()
            datePicker.datePickerMode = .date
            datePicker.preferredDatePickerStyle = .wheels
            self.datePickers.append(datePicker)
            
            let submitbtn = self.submitBtn(key: formTextField.key.textFromKey()) {
                self.setFieldDate(datePicker)
            }
            
            let stack = UIStackView(arrangedSubviews: [header,datePicker,submitbtn])
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
            stack.addShadowAround(size: CGSize(width: UIScreen.main.bounds.width / 1.3,
                                               height: 180))
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
            let isNameField = FieldProps.isNameField(formTextField.key)
            if (isNameField) {
                let textFieldGamified = UITextFieldFormGamified(image: UIImage(named: "name_tag")!, field: formTextField, design: form.getDesign())
                textFieldGamified.clipsToBounds = true
            
                stack = UIStackView(arrangedSubviews: [header,textFieldGamified])
                textFieldGamified.delegate = self
                textFieldGamified.alertTitle = "הכנס שם מלא"
                header.text = "שם מלא"
                self.textFields.append(textFieldGamified)
                
            }else if (FieldProps.isLocationField(formTextField.key)) {
                let btn = UIButton()
                btn.setAttributedTitle(NSAttributedString(string: "בחר כתובת", attributes: [.foregroundColor : form.getDesign().questionBoxHeaderBgColor(), .font : UIFont.boldSystemFont(ofSize: 16)]), for: .normal)
                btn.titleLabel?.numberOfLines = 3
                btn.addAction(UIAction(handler: { act in
                    self.showLocationAlert(field: formTextField,btn:btn)
                }), for: .touchUpInside)
                stack = UIStackView(arrangedSubviews: [header,btn])
            } else {
            let textfield = UITextFieldForm(formTextField)
            textfield.attributedPlaceholder = form.getDesign().answerTextFieldAttributes(text: "הזן תשובה")
            textfield.delegate = self
            textfield.layer.borderWidth = 0.1
            let keyboardType:UIKeyboardType = FieldProps.isPhoneNumberField(formTextField.key) ? .phonePad : FieldProps.isNumericField(formTextField.key) ? .numberPad : .default
            textfield.keyboardType = keyboardType
            textfield.layer.borderColor = UIColor.black.cgColor
            textfield.textAlignment = .center

                let submitBtn = self.submitBtn(key: formTextField.key.textFromKey()) {
                    self.setFieldText(tf: textfield)
                }
            self.textFields.append(textfield)
             stack = UIStackView(arrangedSubviews: [header,textfield,submitBtn])
            }
            stack.axis = .vertical
            stack.distribution = isNameField ? .fill : .fillProportionally
            stack.contentMode = .center
            stack.spacing = 0
            stack.clipsToBounds = true
            stack.layer.borderColor = form.getDesign().questionBoxBorderColor()
            stack.layer.borderWidth = form.getDesign().questionBoxBorderWidth()
            stack.layer.cornerRadius = form.getDesign().questionBoxCornerRadius()
            stack.backgroundColor = form.getDesign().questionBoxColor()
            stack.translatesAutoresizingMaskIntoConstraints = false
            self.fieldStack.append(stack)
            
            let holder = UIView()
            
            stack.addShadowAround(size: CGSize(width: (UIScreen.main.bounds.width / 1.2),
                                               height: (isNameField ? 300 : 120)))
            holder.backgroundColor = form.getDesign().holderBackgroundColor()
            holder.addSubview(stack)
            
            let stackconstraints = [stack.centerXAnchor.constraint(equalTo: holder.centerXAnchor),
                                    stack.centerYAnchor.constraint(equalTo: holder.centerYAnchor),
                                    stack.heightAnchor.constraint(equalToConstant: isNameField ? 300 : 120),
                                    stack.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 1.2)]
            NSLayoutConstraint.activate(stackconstraints)
            holder.translatesAutoresizingMaskIntoConstraints = false
            holder.isHidden = true
            self.view.addSubview(holder)
            self.fieldHolder.append(holder)
            let constraints = [holder.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                               holder.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
                               holder.heightAnchor.constraint(equalToConstant: isNameField ? 350 : 280),
                               holder.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)]
            NSLayoutConstraint.activate(constraints)
            
        }
    }
    
    func createNavBar() {
        self.view.addSubview(navBar)
        navBar.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        navBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        navBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        navBar.heightAnchor.constraint(equalToConstant: 100).isActive = true
        createMenuWithButton()
        createBackButton()
        createCompletionButton()
    }
    var menuAnchor:NSLayoutConstraint?
    func createMenuWithButton() {
        self.navBar.addSubview(menuButton)
        menuButton.topAnchor.constraint(equalTo: self.navBar.safeAreaLayoutGuide.topAnchor,constant: 16).isActive = true
        menuButton.trailingAnchor.constraint(equalTo: self.navBar.safeAreaLayoutGuide.trailingAnchor,constant: -16).isActive = true
        menuButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        menuButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        
        menu = FormMenu(frame: CGRect())
        view.addSubview(menu)
        menu.topAnchor.constraint(equalTo: navBar.bottomAnchor).isActive = true
        menuAnchor =  menu.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,constant: 300)
        menu.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        menu.widthAnchor.constraint(equalToConstant: 150).isActive = true
        menuAnchor?.isActive = true
    }
    func createCompletionButton() {
        self.navBar.addSubview(completionButton)
        completionButton.trailingAnchor.constraint(equalTo: self.menuButton.leadingAnchor, constant: -16).isActive = true
        completionButton.topAnchor.constraint(equalTo: self.navBar.safeAreaLayoutGuide.topAnchor,constant: 12).isActive = true
        completionButton.bottomAnchor.constraint(equalTo: self.navBar.safeAreaLayoutGuide.bottomAnchor,constant: -8).isActive = true
    }
    func createBackButton() {
        self.navBar.addSubview(backButton)
        backButton.topAnchor.constraint(equalTo: self.navBar.safeAreaLayoutGuide.topAnchor,constant: 16).isActive = true
        backButton.leadingAnchor.constraint(equalTo: self.navBar.safeAreaLayoutGuide.leadingAnchor,constant: 16).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
    }
    
    func submitBtn(key: String, block:@escaping () -> ()) -> UIButton {
        let submitBtn = UIButton()
        submitBtn.setAttributedTitle(NSAttributedString(string:"שלח" + " " + key , attributes: [.foregroundColor : UIColor.systemGreen,.font : UIFont.boldSystemFont(ofSize: 14)]), for: .normal)
        submitBtn.addAction(UIAction(handler: {act in block()}), for: .touchUpInside)
        return submitBtn
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
    
    func headerLabel(_ title:String) -> UILabel{
        let header = UILabel()
        header.attributedText = form.getDesign().questionTextAttributes(text: title)
        header.textAlignment = .center
        header.layoutMargins = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        header.backgroundColor = form.getDesign().questionBoxHeaderBgColor()
        return header
    }
    
    func createFieldInput(_ formCheckBox:FormCheckBox) {
     
        let question = formCheckBox.key.replacingOccurrences(of: "_", with:" ").capitalized
        let header = headerLabel(question)
    
        self.fieldHeaders.append(header.text ?? "")
        let checkbox = UICheckBoxForm(formCheckBox)
        checkbox.isChecked = false
        checkbox.addAction(UIAction(handler: { [weak self]  (act)in
            checkbox.isChecked = !checkbox.isChecked
            self?.setCheckBoxFieldValue(for: formCheckBox.key, checkbox.isChecked)
            self?.clearField()
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
        stack.addShadowAround(size: CGSize(width: UIScreen.main.bounds.width / 1.2,
                                           height: 180))
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
    

    
    
    var segmentControls:[AnyFormSegmentControl] = []

    func createFieldInputCategory(category:String,formCheckBoxes:[FormCheckBox]) {
        let isBinaryQuestion = formCheckBoxes.count == 2
        let isMultiChoice = !formCheckBoxes.filter{FormFieldType.fromString($0.props.type) == .categoryMultiChoiceField}.isEmpty
        let question = category.replacingOccurrences(of: "_", with:" ").capitalized
        let header = headerLabel(question)
        header.numberOfLines = 2
        header.translatesAutoresizingMaskIntoConstraints = false
        header.backgroundColor = form.getDesign().questionBoxHeaderBgColor()
        header.layer.cornerRadius = 8
        let headerSize = CGSize(width: UIScreen.main.bounds.width / 1.3, height: 50)
        header.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        header.clipsToBounds = true
        
        
        
        self.fieldHeaders.append(header.text ?? "")
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
            // More then 2 options, one selection allowed
        }else if (!isMultiChoice) {
            let btn = UIButton()
            btn.setTitleColor(form.getDesign().questionBoxHeaderBgColor(), for: .normal)
            btn.setTitle("לחץ כדי לבחור", for: .normal)
            btn.addAction(UIAction(handler: { act in
                self.showPickerAlert(fields: formCheckBoxes,btn: btn)
            }), for: .touchUpInside)
            let cstack = UIStackView(arrangedSubviews: [btn])
                cstack.distribution = .fill
                cstack.axis = .horizontal
                cstack.spacing = 4
                checkboxesStacks.append(cstack)
        }else {
            // More then 2 options, more then one selection allowed
            formCheckBoxes.forEach { formCheckBox in
                            let cbx:UICheckBoxForm = UICheckBoxForm(formCheckBox)
                            cbx.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
                            cbx.isChecked = false
                            cbx.addAction(UIAction(handler: { [weak self]  (act)in
                                guard let strong = self else {return}
                                cbx.isChecked = !cbx.isChecked
                                strong.setCheckBoxFieldValue(for: formCheckBox.key, cbx.isChecked)
                                self?.clearField()
                            }), for: .touchUpInside)
                            self.checkBoxes.append(cbx)
                            let yes = UILabel()
                            yes.textAlignment = .center
                            yes.numberOfLines = 2
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
                                cstack.distribution = .fillProportionally
                                cstack.axis = .horizontal
                                cstack.spacing = 4
                                checkboxesStacks.append(cstack)
                            }
        }
        }
        
        // Populate a stack view with all the categorie's checkboxes
        let catStack = FormFieldsViewController.categoryStack(checkboxesStacks)
        let catStackSize = CGSize(width: UIScreen.main.bounds.width / 1.3, height: (isBinaryQuestion || !isMultiChoice) ? 120 : 320)
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
        
        let Yaxis:CGFloat = (isBinaryQuestion || !isMultiChoice) ? 72 : 0
        
        catStack.addShadowAround(size: CGSize(width: UIScreen.main.bounds.width / 1.3, height: catStackSize.height))
        holder.addSubview(catStack)
        holder.backgroundColor = form.getDesign().holderBackgroundColor()
        let stackconstraints = [catStack.centerXAnchor.constraint(equalTo: holder.centerXAnchor),
                                catStack.topAnchor.constraint(equalTo: header.bottomAnchor),
                                catStack.heightAnchor.constraint(equalToConstant: catStackSize.height),
                                catStack.widthAnchor.constraint(equalToConstant: catStackSize.width)]
        
        let headerconstraints = [header.widthAnchor.constraint(equalToConstant: headerSize.width),
                                 header.centerXAnchor.constraint(equalTo: holder.centerXAnchor),
                                 header.heightAnchor.constraint(equalToConstant:headerSize.height),
                                 header.topAnchor.constraint(equalTo: holder.topAnchor)]
        
        holder.addSubview(header)
        holder.isHidden = true
        holder.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(holder)
        self.fieldHolder.append(holder)
        let constraints = [holder.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                           holder.centerYAnchor.constraint(equalTo: self.view.centerYAnchor,constant:Yaxis),
                           holder.heightAnchor.constraint(equalToConstant: 340),
                           holder.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)]
        
        NSLayoutConstraint.activate(constraints)
        NSLayoutConstraint.activate(headerconstraints)
        NSLayoutConstraint.activate(stackconstraints)
        
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
        prog.fontColor = .systemOrange
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
        prog.topAnchor.constraint(equalTo: self.navBar.bottomAnchor,constant: 24).isActive = true
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
        self.addSignatureField()
        callback()
    }
    
    func nextField() {
        if !canSwipeField {
            return
        }
        self.canSwipeField = false
        let count = fieldHolder.count
         if currentField+1 >= count {
            return
        }

        hideCurrentField()
        progTunnel.scrollToItem(at: IndexPath(row: currentField+1, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    var canSwipeField:Bool = true
    func previousField() {
        if !canSwipeField {
            return
        }
        self.canSwipeField = false
        if currentField < 0 {
            return
        }
        hideCurrentField(true)
        progTunnel.scrollToItem(at: IndexPath(row: currentField-1, section: 0), at: .centeredHorizontally, animated: true)
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
    
    func showPickerAlert(fields:[FormCheckBox],btn:UIButton) {
        let alert = UIAlertController(style: .actionSheet)
        let pickerViewValues: [[String]] = [fields.map{$0.key.textFromKey()}]
        let saved = form.getCheckBoxes().first { checkbox in
            (checkbox.checked == true) && (pickerViewValues[0].contains(checkbox.key))
        }
        let savedIndex = fields.firstIndex { cb in
            cb.key == saved?.key
        }.map { index in
            Int(index)
        } ?? 0
        let pickerViewSelectedValue: PickerViewViewController.Index = (column:0,row:savedIndex)

        alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { vc, picker, index, values in
            let selected = fields[index.row]
            fields.forEach {self.setCheckBoxFieldValue(for: $0.key, false)}
            btn.setTitle(selected.key.textFromKey(), for: .normal)
            self.setCheckBoxFieldValue(for: selected.key, true)
            self.clearField()
        }
        alert.addAction(title: "סגור", style: .cancel)
        present(alert, animated: true)
    }
    
    func showLocationAlert(field:FormTextField,btn:UIButton) {
        let alert = UIAlertController(style: .actionSheet)
        alert.addLocationPicker { location in
            guard let loc = location else {return}
            let address = loc.address.split(separator: "\n")
            var street = String(address[0])
            var postalcode = ""
            let city = String(address[1])
            let st = street.split(separator: " ")
            let pc = city.split(separator: " ")
            var street_num = 0
            for item in st {
                let part = item.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                if let intVal = Int(part) {
                    street_num = intVal
                    street =  street.replacingOccurrences(of: String(intVal), with: "")
                }
            }
            
            for item in pc {
                let part = item.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                if let intVal = Int(part) {
                    postalcode += String(intVal)
                }
            }
            
            self.form.setFieldValue(for: "עיר_מגורים", newValue: city.replacingOccurrences(of: postalcode, with: ""))
            self.form.setFieldValue(for: "רחוב", newValue: street.replacingOccurrences(of: "Street", with: ""))
            self.form.setFieldValue(for: "מספר_רחוב", newValue: String(street_num))
            self.form.setFieldValue(for: "מיקוד", newValue: postalcode)
            self.clearField()
            btn.setAttributedTitle(NSAttributedString(string: loc.address, attributes: [.foregroundColor : self.form.getDesign().questionBoxHeaderBgColor(), .font : UIFont.boldSystemFont(ofSize: 14)]), for: .normal)
        }
        alert.addAction(title: "סגור", style: .cancel)
        present(alert, animated: true)
    }
    
    var docController:UIDocumentInteractionController = UIDocumentInteractionController()
    @IBAction func fillForm(_ sender: Any) {
        complete()
    }
    func clearedFieldCount() -> Int{
       return clearedFieldKeys.count
    }
    func allCleared() -> Bool {
        return clearedFieldCount() == fieldHolder.count
    }
    func complete() {
       // if !allCleared() { showFormFillingToast(message: "יש למלא את כל השאלות לפני יצירת קובץ PDF! וודא שענית על כולן ונסה שוב"); return}
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
                    selfStrong.docController.presentOpenInMenu(from: selfStrong.completionButton.frame, in: selfStrong.view, animated: true)
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
    ///   has alot of things to consider
    func hideCurrentField(_ prev:Bool = false) {
        showFieldList { [weak self] in
            guard let strong = self else {return}
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: []) {
                if strong.currentField < 0 {
                    return}
                strong.fieldHolder[strong.currentField].alpha = 0
            } completion: { (bool) in
                if strong.currentField < 0 {
                    return}
                strong.fieldHolder[strong.currentField].isHidden = true
                if prev {
                    strong.currentField -= 1
                    if strong.currentField < 0 {
                        return}
                }else {
                    if strong.currentField + 1 >= strong.fieldHolder.count {
                        return
                    }
                    strong.currentField += 1
                }
                strong.showNextField()
            }
        }
      
    }
    
    func jumpToField(index:Int) {
        if index == currentField {
            return
        }
        let previous = currentField
        currentField = index
        if currentField < 0 {
            return
        }
         showFieldList { [weak self] in
                guard let strong = self else {return}
                UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: []) {
                    strong.fieldHolder[previous].alpha = 0
                } completion: { (bool) in
                    if strong.currentField < 0 {
                        return}
                    strong.fieldHolder[strong.currentField].isHidden = true
                    strong.fieldHolder[strong.currentField].isHidden = false
                    strong.fieldHolder[strong.currentField].alpha = 0
                    
                    UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: []) {
                        strong.fieldHolder[strong.currentField].alpha = 1
                    }
                    strong.prog.value = CGFloat(strong.currentField+1)
                }
         }
        
    }
    
    
    func showNextField() {
        self.fieldHolder[self.currentField].isHidden = false
        self.fieldHolder[self.currentField].alpha = 0
        
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: []) {
            self.fieldHolder[self.currentField].alpha = 1
        } completion: { (complete) in
            self.canSwipeField = true
        }
        self.prog.value = CGFloat(self.currentField+1)
       
    }
    func showFieldList(completion:@escaping () -> Void) {
        completion()
    }
  
    
    func setForm(_ form:Form) {
        self.form = form
    }
    
    
}

extension FormFieldsViewController : UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tubecell", for: indexPath) as! Tube
        cell.initTube(tube:FieldProps.getRootFieldKey(self.fieldHeaders[indexPath.row]), cleared: clearedFieldKeys)
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !canSwipeField {return}
        jumpToField(index: indexPath.row)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.fieldHeaders.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
}
