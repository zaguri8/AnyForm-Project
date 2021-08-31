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
    func clearField() {
        progTunnel.scrollToItem(at: IndexPath(row: currentField, section: 0), at: .centeredHorizontally, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {[weak self] in
            guard let strong = self else {return}
            guard let tube = strong.progTunnel.cellForItem(at: IndexPath(row: strong.currentField, section: 0)) as? Tube else {
                print("bad tube")
                return}
            if !strong.clearedFieldKeys.contains(tube.tubeLabel.text!) {
                strong.clearedFieldKeys.append(tube.tubeLabel.text!)
           
            tube.clear()
            if (((strong.fieldHolder.count - strong.clearedFieldKeys.count - 2) != 0)
                    && (strong.clearedFieldKeys.count == 1 || strong.clearedFieldKeys.count % 5 == 0 )) {
                strong.showAnyFormToast(message: "קדימה! נשארו עוד \(strong.fieldHolder.count - strong.clearedFieldKeys.count) שאלות",boxColor:strong.form.getDesign().questionBoxHeaderBgColor().withAlphaComponent(0.8),borderColor: .white,textColor: .white,font: UIFont.boldSystemFont(ofSize: 18))
            }
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
            sendTip()
        }
        addFieldQuestionCounter()
        createProgressionTunnel()
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
    /**
        Listens to form text field changes and sets the value on the form
     */
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let tf = textField as? UITextFieldForm, let key = tf.formtextfield?.key, let value = tf.text,!value.isEmpty else {return}
        form.setFieldValue(for: key, newValue: value)
        clearField()
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
    lazy var navBar:UIView = {
        let nav = UIView()
        nav.backgroundColor = form.getDesign().questionBoxHeaderBgColor()
        nav.translatesAutoresizingMaskIntoConstraints = false
        return nav
    }()
    var menu:FormMenu!
    
    
    /**
        Next field button, current set as "הבא"
     */
    lazy var nextButton:UIButton = {
        let button = UIButton()
        let att = form.getDesign().buttonsTextAttributes(text: "הַבָּא")
        button.setAttributedTitle(att, for: .normal)
        button.backgroundColor = .systemOrange
        button.layer.cornerRadius = 12
        button.layerGradient()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction(handler: { act in
            self.nextField()
        }), for: .touchUpInside)
        return button
    }()
    /**
        Previous field button, current set as "קודם"
     */
    lazy var prevButton:UIButton = {
        let button = UIButton()
        let att = form.getDesign().buttonsTextAttributes(text: "קודם")
        button.setAttributedTitle(att, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        button.layer.cornerRadius = 12
        button.backgroundColor = .systemOrange
        button.addAction(UIAction(handler: { act in
            self.previousField()
        }), for: .touchUpInside)
        return button
    }()
    
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
            guard let fieldKey = d.key else {continue}
            let trueKey = parentFieldKey(for: fieldKey)
            if self.form.getTextFields().contains(where: { (textfield)  in
                textfield.key == fieldKey
            })  {
                guard let match = tfs.first(where: { tf in
                    tf.formtextfield?.key == trueKey
                })else {
                    guard let gamifiedMatch = gamefields.first(where: { gamefield in
                        gamefield.field?.key == trueKey
                    }) else {
                        return}
                    guard let firstName = allData.first(where: { nextD in
                     return   nextD.key! == "שם_פרטי"
                    })?.value  else {
                        return}
                    guard let lastName = allData.first(where: { nextD in
                        nextD.key! == "שם_משפחה"
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
                CoreDataManager.shared.addUserData(key: "שם_פרטי", value: arg2,category: "")
                CoreDataManager.shared.addUserData(key: "שם_משפחה", value: arg1, category: "")
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
        clearField()
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
    
    /**
        Binary Gamified TextField
     */
    class UITextFieldFormGamified : UIView, UITextFieldDelegate{
        var textColor:UIColor = .black
        
        var arg1:String?
        var arg2:String?
        
        var field:FormTextField?
        var savedData:String   {
            set {
                animateLabelTextChange(text: newValue)
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
    
    func isGamifiedTextFieldParent(key:String) -> Bool {
        return key == "שם_פרטי"
    }
    func isGameifiedTextFieldChild(key:String) -> Bool {
        return key == "שם_משפחה" || key == "רחוב"
        || key == "מספר_רחוב" ||  key == "מיקוד"
    }
    func parentFieldKey(for childKey:String) -> String {
        if childKey == "שם_משפחה" {return "שם_פרטי"}
        else if childKey == "עיר_מגורים" {return "כתובת"}
        return childKey
    }
    func isLocationFieldKey(key:String) -> Bool{
        return key ==  "עיר_מגורים"
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
    
    
    
    func createFieldInput(_ formTextField:FormTextField) {
        if(isGameifiedTextFieldChild(key: formTextField.key)) {return}
        let header = UILabel()
        let question = parentFieldKey(for: formTextField.key).replacingOccurrences(of: "_", with: " ").capitalized
        header.attributedText = form.getDesign().questionTextAttributes(text: question)
        header.textAlignment = .center
        header.layoutMargins = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        header.backgroundColor = form.getDesign().questionBoxHeaderBgColor()
        self.fieldHeaders.append(header.text ?? "")
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
            let isGamifiedTextfield = isGamifiedTextFieldParent(key: formTextField.key)
            // Only for first name and last name - איכס
            if (isGamifiedTextfield) {
                let textFieldGamified = UITextFieldFormGamified(image: UIImage(named: "name_tag")!, field: formTextField, design: form.getDesign())
                textFieldGamified.clipsToBounds = true
                stack = UIStackView(arrangedSubviews: [header,textFieldGamified])
                textFieldGamified.delegate = self
                textFieldGamified.alertTitle = "הכנס שם מלא"
                header.text = "שם מלא"
                self.textFields.append(textFieldGamified)
            }else if (isLocationFieldKey(key: formTextField.key)) {
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
            
            stack.addShadowAround(size: CGSize(width: (UIScreen.main.bounds.width / 1.2),
                                               height: (isGamifiedTextfield ? 300 : 120)))
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
    
    func createNavBar() {
        self.view.addSubview(navBar)
        navBar.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        navBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        navBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        navBar.heightAnchor.constraint(equalToConstant: 100).isActive = true
        createMenuWithButton()
        createBackButton()
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
    func createBackButton() {
        self.navBar.addSubview(backButton)
        backButton.topAnchor.constraint(equalTo: self.navBar.safeAreaLayoutGuide.topAnchor,constant: 16).isActive = true
        backButton.leadingAnchor.constraint(equalTo: self.navBar.safeAreaLayoutGuide.leadingAnchor,constant: 16).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
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
    
    
    var segmentControls:[AnyFormSegmentControl] = []

    func createFieldInputCategory(category:String,formCheckBoxes:[FormCheckBox]) {
        let header = UILabel()
        let isBinaryQuestion = formCheckBoxes.count == 2
        let isOneChoiceOutOfMany = (formCheckBoxes.count > 2) && formCheckBoxes.count % 2 > 0
        let question = category.replacingOccurrences(of: "_", with:" ").capitalized
        
        // Question header . EX: First Name
        header.attributedText = form.getDesign().questionTextAttributes(text: question)
        header.layoutMargins = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        header.numberOfLines = 2
        header.translatesAutoresizingMaskIntoConstraints = false
        header.backgroundColor = form.getDesign().questionBoxHeaderBgColor()
        header.layer.cornerRadius = 8
        let headerSize = CGSize(width: UIScreen.main.bounds.width / 1.3, height: 50)
        header.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        header.clipsToBounds = true
        header.textAlignment = .center
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
            // More then 2 options of selection
        }else if (isOneChoiceOutOfMany) {
           // let bitmap = UIImageView(image:UIImage(named:formCheckBox.props.bitmap))
           // bitmap.contentMode = .scaleAspectFit
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
                                self?.clearField()
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
        let catStackSize = CGSize(width: UIScreen.main.bounds.width / 1.3, height: (isBinaryQuestion || isOneChoiceOutOfMany) ? 120 : 320)
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
        
        let Yaxis:CGFloat = (isBinaryQuestion || isOneChoiceOutOfMany) ? 72 : 0
        
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
    
    func addNextPrevButtons() {
        let buttonStack = UIStackView(arrangedSubviews: [prevButton,nextButton])
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.axis = .horizontal
        buttonStack.isUserInteractionEnabled = true
        buttonStack.distribution = .fillEqually
        buttonStack.setCustomSpacing(32, after: prevButton)
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
        progTunnel.scrollToItem(at: IndexPath(row: currentField+1, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    var clickableButton:Bool = true
    func previousField() {
        if !clickableButton {
            return
        }
        self.clickableButton = false
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
        let pickerViewValues: [[String]] = [fields.map{$0.key.replacingOccurrences(of: "_", with: " ")}]
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
            btn.setTitle(selected.key.replacingOccurrences(of: "_", with: " "), for: .normal)
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
            self.form.setFieldValue(for: "רחוב", newValue: street)
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
                if (strong.currentField == strong.fieldHolder.count) {
                    strong.nextButton.isHidden = true
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
        let count = fieldHolder.count
        if(currentField == count-2) {
            self.nextButton.isHidden = true
            enableGenerateBarButton()
        }
        if(self.prevButton.isHidden && currentField >= 0) {
            self.prevButton.isHidden = false
        }
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
         showFieldList { [weak self] in
                guard let strong = self else {return}
                UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: []) {
                    strong.fieldHolder[previous].alpha = 0
                } completion: { (bool) in
                    if strong.currentField < 0 {
                        return}
                    strong.fieldHolder[strong.currentField].isHidden = true
                    if (strong.currentField == strong.fieldHolder.count) {
                        strong.nextButton.isHidden = true
                    }
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
            self.clickableButton = true
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
        cell.initTube(tube:parentFieldKey(for:(self.fieldHeaders[indexPath.row])), cleared: clearedFieldKeys)
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        jumpToField(index: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.fieldHeaders.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
}
