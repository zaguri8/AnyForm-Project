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


protocol FormCheckBoxDelegate : AnyObject {
   func didCheckValue(checkBox:FormCheckBox)
}
protocol FormTextFieldDelegate : AnyObject {
   func presentFromView(vc:UIViewController)
   func setFieldValue(arg1:String,arg2:String)
}



class FormFieldsViewController: UIViewController,UITextFieldDelegate,FormCheckBoxDelegate,FormTextFieldDelegate, UIDocumentInteractionControllerDelegate,FormMenuDelegate {

   
   func showFormButtonClicked() {
      self.showForm()
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
   
   func getNewPageView() -> UIView {
      let view = UIView()
      view.isHidden = true
      self.view.addSubview(view)
      view.constraintEndToEndOf(self.view)
      view.constraintStartToStartOf(self.view)
      view.constraintHeight(400)
      return view
   }
   
   var pageViews:NSPointerArray = NSPointerArray.weakObjects()
   /**
    This button is in charge of showing drawer menu
    */
   lazy var menuButton:UIButton = {
      let button = UIButton()
      button.setImage(#imageLiteral(resourceName: "menu"), for: .normal)
      button.translatesAutoresizingMaskIntoConstraints = false
      button.addAction(UIAction(handler: { [weak self]act in
         self?.showMenu()
      }), for: .touchUpInside)
      return button
   }()
   lazy var backButton:UIButton = {
      let button = UIButton()
      button.setImage(#imageLiteral(resourceName: "back"), for: .normal)
      button.translatesAutoresizingMaskIntoConstraints = false
      button.addAction(UIAction(handler: { [weak self] act in
         self?.clean()
         self?.performSegue(withIdentifier:"UNWIND",sender:nil)
      }), for: .touchUpInside)
      return button
   }()
   
   
   lazy var completionButton:UIButton = {
      let button = UIButton()
      button.setTitle("צור קובץ PDF", for: .normal)
      button.setTitleColor(.black, for: .normal)
      button.translatesAutoresizingMaskIntoConstraints = false
      button.addAction(UIAction(handler: {[weak self] act in self?.complete()}), for: .touchUpInside)
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
   
   lazy var pageSegment:UISegmentedControl = {
      let segmentC = UISegmentedControl()
      segmentC.translatesAutoresizingMaskIntoConstraints = false
      let pageCount = form.getPageCount()
      let pages = form.pages.sorted{$0.index < $1.index}
      for page in pages {
         let index = page.index
         segmentC.insertSegment(action: UIAction(handler: {[weak self] act in
            guard let strong = self else {return}
            var pageView = strong.pageViews.object(at: strong.pageIndex) as? UIView
            pageView?.isHidden = true
            strong.pageIndex = page.index - 1
            pageView = strong.pageViews.object(at: strong.pageIndex) as? UIView
            pageView?.isHidden = false
            strong.progTunnel?.reloadData()
         }), at: index-1 , animated: true)
         segmentC.setTitle(page.pageTitle.textFromKey(), forSegmentAt: index-1)
      }
      return segmentC
   }()
   
   func createShapeLayer () -> CAShapeLayer {
      let shapeLayer = CAShapeLayer()
      shapeLayer.fillColor = .none
      shapeLayer.strokeColor = UIColor.blue.cgColor
      shapeLayer.position = CGPoint(x:0,y:0)
      shapeLayer.lineWidth = 3
      shapeLayer.path = createBezierPath().cgPath
      return shapeLayer
   }
   func createBezierPath() -> UIBezierPath {
      guard let progTunnel = progTunnel else {return UIBezierPath()}
      let path = UIBezierPath()
      
      let minX = progTunnel.bounds.minX
      let minY = progTunnel.bounds.minX
      
      let midX = progTunnel.bounds.midX
      let midY = progTunnel.bounds.midY
      
      let maxX = progTunnel.bounds.maxX
      let maxY = progTunnel.bounds.maxY
      
      let bottomStart = CGPoint(x:minX,y:maxY)
      let bottomEnd = CGPoint(x:maxX,y:maxY)
      
      let topStart = CGPoint(x:minX,y:minY)
      let topEnd = CGPoint(x:maxX,y:minY)
      path.move(to: bottomStart)
      path.addLine(to: topStart)
      path.addLine(to: topEnd)
      path.addLine(to:  bottomEnd)
      path.close()
      return path
      
   }
   lazy var progTunnel:UICollectionView? = {
      let tunnelLayout = UICollectionViewFlowLayout()
      tunnelLayout.scrollDirection = .horizontal
      tunnelLayout.minimumInteritemSpacing  = 0.0
      tunnelLayout.minimumLineSpacing = 0.0
      let tunnelPos = CGPoint(x: 0, y: 620)
      let tunnelFrame = CGRect(x: tunnelPos.x, y: tunnelPos.y, width: UIScreen.main.bounds.size.width, height: 100)
      let tunnelView = UICollectionView(frame: tunnelFrame, collectionViewLayout: tunnelLayout)
      tunnelView.delegate = self
      tunnelView.dataSource = self
      tunnelView.register(UINib(nibName: "Tube", bundle: .main), forCellWithReuseIdentifier: "tubecell")
      tunnelView.backgroundColor = UIUtils.hexStringToUIColor(hex: "ff9248")
      tunnelView.cornerRadius = 8
      tunnelView.borderWidth = 0.5
      tunnelView.borderColor = .black
      tunnelView.bounces = false
      tunnelView.alwaysBounceHorizontal = false
      tunnelView.autoresizingMask = .flexibleWidth
      return tunnelView
   }()
   
   let shapeLayer = CAShapeLayer()
   let trackLayer = CAShapeLayer()
   fileprivate lazy var prog:MBCircularProgressBarView? = {
      MBCircularProgressBarView()
   }()
   fileprivate lazy var menu:FormMenu? = {
      let menu = FormMenu(frame: CGRect())
      menu.menuDelegate = self
      return menu
   }()
   
   var form:Form!
   var fieldHeaders:[Int : [String]] = [:]
   var textFields:NSPointerArray = NSPointerArray.weakObjects()
   var gameFields:NSPointerArray = NSPointerArray.weakObjects()
   var checkBoxes:NSPointerArray = NSPointerArray.weakObjects()
   var datePickers:NSPointerArray = NSPointerArray.weakObjects()
   var fieldHolder:[Int : NSPointerArray] = [:]
   var currentField:[Int:Int] = [:]
   var pageIndex:Int = 0
   var clearedFieldKeys:Set<String> = []
   var docController:UIDocumentInteractionController? = UIDocumentInteractionController()
   
   /**
    This method sets the value of the gamified text fields
    current supporting שם_משפחה,שם_פרטי
    */
   func setFieldValue(arg1: String, arg2: String) {
      form.setFieldValue(for: "שם פרטי", newValue: arg2,page: pageIndex)
      form.setFieldValue(for: "שם משפחה", newValue: arg1,page: pageIndex)
      
      clearField()
   }
   
   func saveTextFieldValue(key:String,value:String) {
      CoreDataManager.shared.saveFieldValue(key: key, val: value)
   }
   func fetchTextFieldValues(key:String) -> [String] {
      return CoreDataManager.shared.getSavedFieldValues(key)
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
   
   
   func showForm(){
      guard let dest = storyboard?.instantiateViewController(withIdentifier: "formViewController") as? FormViewController else { return}
      present(dest, animated: true) {[weak self] in
         guard let strong = self else {return}
         dest.populate(strong.form)
      }
   }
   
   
   
   func clearField() {
      let cleared = !completionButton.isEnabled && allCleared()
      if cleared { enableGenerateBarButton()}
      progTunnel?.scrollToItem(at: IndexPath(row: currentField[pageIndex]!, section: 0), at: .centeredHorizontally, animated: true)
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {[weak self] in
         guard let strong = self else {return}
         guard let tube = strong.progTunnel?.cellForItem(at: IndexPath(row: strong.currentField[strong.pageIndex]!, section: 0)) as? Tube else {
            return}
         if !strong.clearedFieldKeys.contains(tube.tubeLabel.text!) {
            strong.clearedFieldKeys.insert(tube.tubeLabel.text!)
            tube.clear()
            let count = strong.totalFieldCount()
            if (((count - strong.clearedFieldCount() - 2) != 0)
                && (strong.clearedFieldCount() == 1 || strong.clearedFieldCount() % 5 == 0 && strong.clearedFieldCount() > 0 )) {
               strong.showFormFillingToast(message: "קדימה! נשארו עוד \(count - strong.clearedFieldCount()) שאלות")
            }else if (cleared) {
               strong.showFormFillingToast(message: "ענית על כל השאלות! לחץ על הכפתור למעלה ליצירת קובץ")
            }
         }
      }
   }
   
   func totalFieldCount() -> Int {
      var count = 0
      for v in fieldHolder.values {
         count += v.count
      }
      return count
   }
   
   func pageFieldCount(page:Int) -> Int {
      return fieldHolder[page]!.count
   }
   
   
   // Populate with user data (clearing all saved fields)
   func clearFields(keys:[String]) {
      for i in 0...fieldHolder.count-1 {
         let relevant = keys.filter{fieldHeaders[i]!.contains($0)}
         relevant.forEach{
            clearedFieldKeys.insert($0)
         }
      }
      progTunnel?.reloadData()
   }
   
   
   override func viewDidLoad() {
      super.viewDidLoad()
      generateButton.isEnabled = false
      view.isUserInteractionEnabled = true
      self.view.backgroundColor = form.getDesign().backgroundColor()
      hideKeyboardWhenTappedAround()
      createNavBar()
      createAllFieldInputs()
      createProgressionTunnel()
      createPageSegmentControl()
      addFieldQuestionCounter()
      sendTip()
      showFirstField()
      
   }
   override func viewDidAppear(_ animated: Bool) {
      toggleTunnel()
   }
   
   override func viewWillAppear(_ animated: Bool) {
      hideNavBar()
      hideTabBar()
      view.addGestureRecognizer(swipeLeftGesture)
      view.addGestureRecognizer(swipeRightGesture)
   }
   override func viewDidDisappear(_ animated: Bool) {
      super.viewDidDisappear(true)
      self.removeFromParent()
      self.dismiss(animated: true, completion: nil)
   }
   
   func clean() {
      self.form = nil
      self.menu = nil
      self.prog = nil
      self.progTunnel = nil
      self.docController = nil
   }
   
   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      
   }
   
   override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(true)
   }
   
   @objc func swipeLeft(_ gesture:UISwipeGestureRecognizer) {
      guard let fieldCount = fieldHolder[pageIndex]?.count else {
         return}
      if currentField[pageIndex]! == fieldCount - 1 {
         return
      }
      nextField()
   }
   
   @objc func swipeRight(_ gesture:UISwipeGestureRecognizer) {
      if currentField[pageIndex]! == 0 {
         return
      }
      previousField()
   }
   
   var toggledMenu:Bool = false
   func showMenu() {
      UIUtils.animateDuration({[weak self] in
         guard let strong = self else {return}
         if !strong.toggledMenu  {
            strong.menuAnchor?.constant = 0
            strong.menuButton.transform = CGAffineTransform(rotationAngle:CGFloat((90 * Double.pi) / 180))
            if let menu = strong.menu {
               strong.view.bringSubviewToFront(menu)
            }
            strong.view.mask?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            strong.view.layoutIfNeeded()
            
         }else {
            strong.menuAnchor?.constant = 300
            strong.menuButton.transform = CGAffineTransform(rotationAngle: 0)
            strong.view.layoutIfNeeded()
         }
      }, duration: 1)
      toggledMenu = !toggledMenu
   }
   var signatureView:AnyFormSignatureField!
   func addSignatureField(_ pageView:UIView,at pageIndex:Int) {
      let header = headerLabel("חתימה")
      let holder = UIView()
      self.fieldHeaders[pageIndex]!.append("חתימה")
      
      signatureView = AnyFormSignatureField()
      signatureView.isOpaque = false
      signatureView.backgroundColor = .clear
      let submitBtn = UIButton()
      submitBtn.setAttributedTitle(NSAttributedString(string:"אשר" + " " + "חתימה" , attributes: [.foregroundColor : UIColor.systemGreen,.font : UIFont.boldSystemFont(ofSize: 14)]), for: .normal)
      submitBtn.addAction(UIAction(handler: {[weak self] act in
         if let strong = self {
            strong.setFieldSignature(cgImage: strong.signatureView.getSignature())
         }
      }), for: .touchUpInside)
      let clearBtn = UIButton()
      clearBtn.setAttributedTitle(NSAttributedString(string:"נקה" , attributes: [.foregroundColor : UIColor.systemGreen,.font : UIFont.boldSystemFont(ofSize: 14)]), for: .normal)
      clearBtn.addAction(UIAction(handler: {[weak self]act in
         self?.signatureView.clear()
      }), for: .touchUpInside)
      
      let btnStack = UIStackView(arrangedSubviews: [submitBtn,clearBtn])
      btnStack.axis = .horizontal
      btnStack.distribution = .fillEqually
      signatureView.setStrokeColor(color: .black)
      header.heightAnchor.constraint(equalToConstant: 50).isActive = true
      header.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
      header.bounds.size.height = 50
      header.layer.cornerRadius = 8
      header.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
      header.clipsToBounds = true
      
      let stack = UIStackView(arrangedSubviews: [header,signatureView,btnStack])
      
      
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
      pageView.addSubview(holder)
      self.fieldHolder[pageIndex]?.addObject(holder)
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
         alert.addAction(UIAlertAction(title: "כן", style: .default,handler: { [weak self]  (act) in
            self?.populateWithUserData()
         }))
         alert.addAction(UIAlertAction(title: "לא תודה", style: .default))
         self.present(alert, animated: true)
      }
   }
   
   func textFieldDidBeginEditing(_ textField: UITextField) {
      canSwipeField = false
   }
   func textFieldDidEndEditing(_ textField: UITextField) {
      canSwipeField = true
   }
   func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
      let allowedCharacters = CharacterSet.decimalDigits
      let characterSet = CharacterSet(charactersIn: string)
      guard let tf = textField as? SearchTextField, let formfield = tf.formtextfield else {return false}
      if FieldProps.isPhoneNumberField(formfield.key)  || FieldProps.isNumericField(formfield.key){
         return allowedCharacters.isSuperset(of: characterSet)
      }
      return true
   }
   
   func populateWithUserData() {
      let allData = CoreDataManager.shared.getUserData()
      if allData.isEmpty {return}
      for dataPiece in allData {
         let key = FieldProps.savedKey(for: dataPiece.getKey())
         clearedFieldKeys.insert(key)
         clearedFieldKeys.insert(FieldProps.getRootFieldKey(key))
         if form.hasTextField(key: key) {
            if FieldProps.isDateField(key) {
               let datePicker = (datePickers.allObjects as? [UIDatePickerForm])?.first{$0.getFieldKey() == key}
               var date = Date()
               if let c = dataPiece.value?.split(separator: "/") {
                  if c.count > 2 {
                     let dateComponents = c.map {Int($0) ?? 2}
                     date.day = dateComponents[0]
                     date.month = dateComponents[1]
                     date.year = dateComponents[2]
                     datePicker?.setDate(date, animated: true)
                  }
               }
            }
            if FieldProps.isNameField(key) {
               let gameField = (gameFields.allObjects as? [UITextFieldFormGamified])?.first{$0.getFieldKey() == key}
               let firstName = allData.first{$0.getKey() == "שם פרטי"}?.value ?? ""
               let lastName =  allData.first{$0.getKey() == "שם משפחה"}?.value ?? ""
               gameField?.savedData = (firstName) + " " + (lastName)
               gameField?.arg2 = firstName
               gameField?.arg1 = lastName
            }
            let textField = (textFields.allObjects as? [SearchTextField])?.first{$0.getFieldKey() == key}
            let data = dataPiece.value ?? ""
            textField?.text = data
            textField?.formtextfield.value = data
         }else if(form.hasCheckBox(key: key)) {
            
            
            if let match = ((checkBoxes.allObjects as? [UICheckBoxForm])?.first{$0.getFieldKey() == key}) {
               
               let data = dataPiece.value == "false" ? false : true
               match.isChecked = data
               match.formcheckbox.checked = data
               
            }else {
               if let category = dataPiece.category {
                  let sControl = segmentControls.first {$0.optionListSelection[0].category == category}
                  if let sControl = sControl {
                     var i = 0
                     for item in sControl.optionListSelection {
                        if item.key == key {
                           sControl.segmentControl?.setSelectedIndex(i)
                        }
                        i += 1
                     }
                  }
               }
            }
            
         }
         
         if let value = dataPiece.value {
            for p in form.pages {
               form.setFieldValue(for: key, newValue: value, page: p.index-1)
            }
            clearedFieldKeys.insert(key)
         }
         
      }
      var categories:[String] = []
      var categoryKeys:[String] = []
      for field in allData {
         guard let  c = field.category else {continue}
         categoryKeys.append(field.getKey())
         categories.append(c)
      }
      clearFields(keys: categories)
   }
   
   func saveUserData() {
      for cb in self.checkBoxes.allObjects {
         guard let checkBox = cb as? UICheckBoxForm else {continue}
         let strVal = checkBox.Bool
         if checkBox.isMultiChoiceField() {
            if checkBox.isChecked {
               CoreDataManager.shared.addUserData(key: checkBox.getFieldKey(), value: "true",category: checkBox.formcheckbox.props.category)
            }
         }else {
            CoreDataManager.shared.addUserData(key: checkBox.getFieldKey(), value: strVal,category: checkBox.formcheckbox.props.category)
         }
      }
      for segControl in self.segmentControls {
         guard  let index = segControl.segmentControl?.selectedSegmentIndex else {continue}
         if index < segControl.optionListSelection.count {
            let formData = segControl.optionListSelection[index]
            if formData.checked {
               CoreDataManager.shared.addUserData(key: formData.key, value: "true",category: formData.category)
            }
         }
      }
      for dp in datePickers.allObjects {
         guard let datePicker = dp as? UIDatePickerForm else {continue}
         let strVal =  datePicker.date.string()
         guard let formData = datePicker.formtextfield, !strVal.isEmpty else {continue}
         CoreDataManager.shared.addUserData(key: formData.key, value:strVal,category: "")
      }
      for tf in self.textFields.allObjects {
         guard let textField = tf as? SearchTextField else {continue}
         guard let formData = textField.formtextfield, let strVal = textField.text, !strVal.isEmpty else {continue}
         CoreDataManager.shared.addUserData(key: formData.key, value: strVal,category: "")
      }
      for gf in gameFields.allObjects {
         guard let gameField = gf as? UITextFieldFormGamified else {continue}
         guard let arg1 = gameField.arg1,let arg2 = gameField.arg2, !arg1.isEmpty, !arg2.isEmpty else {
            continue}
         CoreDataManager.shared.addUserData(key: "שם פרטי", value: arg2,category: "")
         CoreDataManager.shared.addUserData(key: "שם משפחה", value: arg1, category: "")
      }
      
   }
   
   func showFirstField() {
      for p in form.pages {
         (fieldHolder[p.index-1]?.allObjects as? [UIView])?[0].isHidden = false
         pageSegment.selectedSegmentIndex = 0
      }
      (pageViews.object(at: 0) as? UIView)?.isHidden = false
   }
   
   
   func setFieldText(tf:SearchTextField) {
      canSwipeField = true
      guard let value = tf.text,!value.replacingOccurrences(of: " ", with: "").isEmpty else {return}
      let key = tf.getFieldKey()
      showFormFillingToast(message: key.textFromKey() + " " +  "השתנה בהצלחה\n" + value)
      form.setFieldValue(for: key, newValue: value,page: pageIndex)
      saveTextFieldValue(key: key, value: value)
      clearField()
   }
   
   func setFieldSignature(cgImage:CGImage?) {
      canSwipeField = true
      form.setSignature(val: cgImage,page: pageIndex)
      clearField()
   }
   
   func setFieldDate(_ picker: UIDatePickerForm) {
      let key = picker.getFieldKey()
      showFormFillingToast(message: key.textFromKey() + " " +  "השתנה בהצלחה\n" + picker.date.dateString())
      let strVal = picker.date.string()
      form.setFieldValue(for: key, newValue: strVal,page: pageIndex)
      clearField()
   }
   
   let arrowUp = UIImage(named: "arrow_up")
   let arrowDown = UIImage(named: "arrow_down")
   var initialTunnelToggle:Bool = true
   @objc func toggleTunnel () {
      guard let progTunnel = progTunnel else {return}
      if tunnelToggled {
         tunnelToggled = !tunnelToggled
         progTunnel.collectionViewLayout.invalidateLayout()
         progTunnel.animateConstraint(.start, constant:UIScreen.main.bounds.width-66)
         tunnelHideBtn?.animateConstraint(.start, constant:UIScreen.main.bounds.width-66)
         progTunnel.animateConstraint(.height,constant: 50)
         tunnelMask!.isHidden = false
         tunnelHideBtn?.setImage(arrowUp, for: .normal)
      } else {
         progTunnel.animateConstraint(.start, constant:16,cancelLayout: initialTunnelToggle)
         tunnelHideBtn?.animateConstraint(.start, constant:16,cancelLayout: initialTunnelToggle)
         progTunnel.animateConstraint(.height,constant: 100,cancelLayout: initialTunnelToggle)
         tunnelMask?.isHidden = true
         tunnelHideBtn?.setImage(arrowDown, for: .normal)
         tunnelToggled = !tunnelToggled
         progTunnel.collectionViewLayout.invalidateLayout()
         progTunnel.scrollToItem(at: IndexPath(row: currentField[pageIndex]!, section: 0), at: .centeredHorizontally, animated: true)
      }
      if initialTunnelToggle {
         progTunnel.scrollToItem(at: IndexPath(row: fieldHolder[pageIndex]!.count-1, section: 0), at: .centeredHorizontally, animated: false)
         initialTunnelToggle = false
      }
      
   }
   
   var tunnelToggled:Bool = false
   lazy var tunnelMask:UIView? = {
      return nil
   }()
   lazy var tunnelHideBtn:UIButton? = {
      return nil
   }()
   func createProgressionTunnel() {
      guard let progTunnel = progTunnel else {return}
      self.view.addSubview(progTunnel)
      progTunnel.constraintStartToStartOf(view,UIScreen.main.bounds.width-66,safe:true)
      progTunnel.constraintHeight(50)
      progTunnel.layer.cornerRadius  = 25
      progTunnel.constraintEndToEndOf(view,16,safe:true)
      progTunnel.constraintBottomToBottomOf(view,32,safe:true)
      tunnelMask = UIView()
      tunnelHideBtn = UIButton()
      tunnelHideBtn?.setImage(arrowUp, for: .normal)
      tunnelHideBtn?.setTitleColor(.systemRed, for: .normal)
      tunnelHideBtn?.addAction(UIAction(handler: { [weak self] act in
         
         self?.toggleTunnel()
      }), for: .touchUpInside)
      
      tunnelMask!.backgroundColor = .white
      progTunnel.addSubview(tunnelMask!)
      tunnelMask!.constraintHeight(50)
      tunnelMask!.constraintWidth(9999)
      view.addSubview(tunnelHideBtn!)
      tunnelHideBtn?.constraintBottomToTopOf(progTunnel)
      tunnelHideBtn?.constraintStartToStartOf(view,UIScreen.main.bounds.width-66,safe:true)
      tunnelMask!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleTunnel)))
      UIView.animate(withDuration: 0.4, delay: 0, options: [.repeat,.autoreverse,.allowUserInteraction]) {[weak self] in
         self?.tunnelHideBtn?.transform = CGAffineTransform(translationX: 0, y: 6)
      }
   }
   
   
   func createFieldInput(_ formTextField:FormTextField,_ pageView:UIView,at pageIndex:Int) {
      if(FieldProps.isSubField(formTextField.key)) {return}
      var fieldwithsubs:FieldWithSubs?
      var fieldWidth:CGFloat = 300
      if FieldProps.isDateField(formTextField.key) {
         
         let datePicker = UIDatePickerForm(formTextField)
         datePicker.date = Date()
         datePicker.datePickerMode = .date
         datePicker.preferredDatePickerStyle = .wheels
         let submitDateAction =  UIAction(handler: {[weak self] act in
            self?.setFieldDate(datePicker)})
         fieldwithsubs = FieldWithSubs(delegate:self,
                                       key: formTextField.key,
                                       content: datePicker,
                                       pageIndex: pageIndex,
                                       contentSize: CGSize(width: 0, height: 200),
                                       submitFieldAction:submitDateAction)
      }else {
         let isNameField = FieldProps.isNameField(formTextField.key)
         
         // gamified fields , name,children
         if (isNameField) {
            let textFieldGamified = UITextFieldFormGamified(image: UIImage(named: "name_tag")!, field: formTextField, design: form.getDesign())
            textFieldGamified.delegate = self
            textFieldGamified.alertTitle = "הכנס שם מלא"
            
            fieldwithsubs = FieldWithSubs(delegate:self,
                                          key: FieldProps.getRootFieldKey(formTextField.key),
                                          content: textFieldGamified,
                                          pageIndex:pageIndex,
                                          contentSize: CGSize(width: 0, height: 250))
            
         } else if (FieldProps.isChildrenField(formTextField.key)){
            
            let childFieldView = ChildFieldView(frame:CGRect())
            childFieldView.delegate = self
            childFieldView.initializeCollection(delegate: self)
            fieldwithsubs = FieldWithSubs(delegate: self, key: FieldProps.getRootFieldKey(formTextField.key), content: childFieldView, pageIndex: pageIndex, contentSize: CGSize(width: ChildCell.cellSize.width + 32, height: 0))
            fieldWidth = ChildCell.cellSize.width + 32
         } else if (FieldProps.isLocationField(formTextField.key)) {
            let btn = UIButton()
            btn.setAttributedTitle(NSAttributedString(string: "בחר כתובת", attributes: [.foregroundColor : form.getDesign().questionBoxHeaderBgColor(), .font : UIFont.boldSystemFont(ofSize: 16)]), for: .normal)
            btn.titleLabel?.numberOfLines = 3
            btn.addAction(UIAction(handler: { [weak self]  act in
               self?.showLocationAlert(field: formTextField,btn:btn)
            }), for: .touchUpInside)
            fieldwithsubs = FieldWithSubs(delegate:self,
                                          key: FieldProps.getRootFieldKey(formTextField.key),
                                          content: btn,pageIndex: pageIndex,
                                          contentSize:CGSize(width: 0, height: 100))
         } else {
            let textfield = SearchTextField(formTextField)
            let saved = fetchTextFieldValues(key: formTextField.key)
            textfield.filterStrings(saved)
            textfield.attributedPlaceholder = form.getDesign().answerTextFieldAttributes(text: "הזן תשובה")
            textfield.delegate = self
            textfield.layer.borderWidth = 0.1
            let keyboardType:UIKeyboardType = FieldProps.isPhoneNumberField(formTextField.key) ? .phonePad : FieldProps.isNumericField(formTextField.key) ? .numberPad : .default
            textfield.keyboardType = keyboardType
            textfield.layer.borderColor = UIColor.black.cgColor
            textfield.textAlignment = .center
            
            let submitTextFieldAction =  UIAction(handler: { [weak self] act in
               self?.setFieldText(tf: textfield)})
            
            fieldwithsubs = FieldWithSubs(delegate:self,
                                          key: formTextField.key,
                                          content: textfield,pageIndex: pageIndex,
                                          contentSize: CGSize(width: 0, height: 100),
                                          submitFieldAction:submitTextFieldAction)
         }
         
      }
      
      pageView.addSubview(fieldwithsubs!)
      fieldwithsubs?.constraintCenterHorizontallyIn(pageView)
      fieldwithsubs?.constraintCenterVerticallyIn(pageView)
      fieldwithsubs?.constraintWidth(fieldWidth)
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
   func createPageSegmentControl() {
      self.view.addSubview(pageSegment)
      pageSegment.topAnchor.constraint(equalTo: navBar.bottomAnchor).isActive = true
      pageSegment.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
      pageSegment.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
      pageSegment.heightAnchor.constraint(equalToConstant: 50).isActive = true
   }
   var menuAnchor:NSLayoutConstraint?
   func createMenuWithButton() {
      self.navBar.addSubview(menuButton)
      menuButton.topAnchor.constraint(equalTo: self.navBar.safeAreaLayoutGuide.topAnchor,constant: 16).isActive = true
      menuButton.trailingAnchor.constraint(equalTo: self.navBar.safeAreaLayoutGuide.trailingAnchor,constant: -16).isActive = true
      menuButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
      menuButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
      if let menu = menu {
         view.addSubview(menu)
         menu.topAnchor.constraint(equalTo: navBar.bottomAnchor).isActive = true
         menuAnchor =  menu.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,constant: 300)
         menu.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
         menu.widthAnchor.constraint(equalToConstant: 150).isActive = true
      }
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
      submitBtn.setAttributedTitle(NSAttributedString(string:"אשר" + " " + key , attributes: [.foregroundColor : UIColor.systemGreen,.font : UIFont.boldSystemFont(ofSize: 14)]), for: .normal)
      submitBtn.addAction(UIAction(handler: {act in block()}), for: .touchUpInside)
      return submitBtn
   }
   
   
   
   func setCheckBoxFieldValue(for key:String,_ value:Bool) {
      let strVal = value ? "true" : "false"
      form.setFieldValue(for: key, newValue: strVal,page: pageIndex)
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
   
   func createFieldInput(_ formCheckBox:FormCheckBox,_ pageView:UIView,at pageIndex:Int) {
      var fieldwithsubs:FieldWithSubs?
      let checkbox = UICheckBoxForm(formCheckBox)
      checkbox.isChecked = false
      checkbox.addAction(UIAction(handler: { [weak self]  (act)in
         checkbox.isChecked = !checkbox.isChecked
         self?.setCheckBoxFieldValue(for: formCheckBox.key, checkbox.isChecked)
         self?.clearField()
      }), for: .touchUpInside)
      let yes = UILabel()
      yes.textAlignment = .center
      
      yes.attributedText = form.getDesign().questionCheckBoxTextAttributrs(text: "סמן את התיבה אם כן")
      let cstack = UIStackView(arrangedSubviews: [checkbox,yes])
      cstack.axis = .horizontal
      cstack.distribution = .fillProportionally
      cstack.spacing = 0
      fieldwithsubs = FieldWithSubs(delegate:self,
                                    key: formCheckBox.key,
                                    content: cstack,pageIndex: pageIndex,
                                    contentSize: CGSize(width: 0, height: 100))
      pageView.addSubview(fieldwithsubs!)
      fieldwithsubs?.constraintCenterHorizontallyIn(pageView)
      fieldwithsubs?.constraintCenterVerticallyIn(pageView)
      fieldwithsubs?.constraintWidth(300)
   }
   
   
   
   
   var segmentControls:[AnyFormSegmentControl] = []
   
   func createFieldInputCategory(category:String,formCheckBoxes:[FormCheckBox],_ pageView:UIView,at pageIndex:Int) {
      let isBinaryQuestion = formCheckBoxes.count == 2
      let isMultiChoice = !formCheckBoxes.filter{FormFieldType.fromString($0.props.type) == .categoryMultiChoiceField}.isEmpty
      
      var checkboxesStacks:[UIStackView] = []
      var fieldwithsubs:FieldWithSubs?
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
            cstack.isUserInteractionEnabled = true
         }
         // More then 2 options, one selection allowed
      }else if (!isMultiChoice) {
         let btn = UIButton()
         btn.setTitleColor(form.getDesign().questionBoxHeaderBgColor(), for: .normal)
         btn.setTitle("לחץ כדי לבחור", for: .normal)
         btn.addAction(UIAction(handler: {[weak self]  act in
            self?.showPickerAlert(fields: formCheckBoxes,btn: btn)
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
            self.checkBoxes.addObject(cbx)
            let yes = UILabel()
            yes.textAlignment = .center
            yes.numberOfLines = 2
            let question = formCheckBox.key.capitalized
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
      
      let catStackSize = CGSize(width: UIScreen.main.bounds.width / 1.3, height: (isBinaryQuestion || !isMultiChoice) ? 200 : 320)
      fieldwithsubs = FieldWithSubs(delegate:self,
                                    key: category,
                                    content: catStack,pageIndex: pageIndex,
                                    contentSize: CGSize(width: 0, height: catStackSize.height))
      pageView.addSubview(fieldwithsubs!)
      fieldwithsubs?.constraintCenterHorizontallyIn(pageView)
      fieldwithsubs?.constraintCenterVerticallyIn(pageView)
      fieldwithsubs?.constraintWidth(catStackSize.width)

   }
   
   
   
   func addFieldQuestionCounter() {
      guard let prog = prog else {return}
      prog.maxValue = CGFloat(totalFieldCount())
      
      prog.value = CGFloat(currentField[pageIndex]!)
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
      prog.topAnchor.constraint(equalTo: self.pageSegment.bottomAnchor,constant: 16).isActive = true
      (pageViews.allObjects as? [UIView])?.forEach{$0.constraintTopToBottomOf(prog,16)}
   }
   
   
   func createAllFieldInputs() {
      let c = form.getPageCount()
      for i in 1...c {
         fieldHolder[i-1] = NSPointerArray.weakObjects()
         fieldHeaders[i-1] = []
         currentField[i-1] = 0
      }
      let pages = form.pages.sorted{$0.index < $1.index}
      for page in pages {
         let pageView = getNewPageView()
         let index = page.index - 1
         var tfs = page.getTextFields()
         var cbxs = page.getCheckBoxes()
         var categories:[String:[FormCheckBox]] = [:]
         let pageSignature = page.textfields.first{$0.key.contains("חתימה")}
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
         tfs.forEach { tf in
            
            createFieldInput(tf,pageView,at: index)
            
         }
         
         categories.forEach { category,boxes in
            if category.isEmpty {
               boxes.forEach { cb in
                  createFieldInput(cb,pageView,at:index)
               }
            }else {
               self.createFieldInputCategory(category: category, formCheckBoxes: boxes, pageView,at: index)
            }
         }
         if pageSignature != nil {
            self.addSignatureField(pageView,at:index)
         }
         self.pageViews.addObject(pageView)
      }
   }
   
   func nextField() {
      let fieldCount = pageFieldCount(page: pageIndex)
      if !canSwipeField {
         return
      }
      self.canSwipeField = false
      if currentField[pageIndex]!+1 >= fieldCount {
         return
      }
      
      hideCurrentField()
      if tunnelToggled {
         progTunnel?.scrollToItem(at: IndexPath(row: currentField[pageIndex]!+1, section: 0), at: .centeredHorizontally, animated: true)
      }
   }
   
   var canSwipeField:Bool = true
   
   func previousField() {
      if !canSwipeField {
         return
      }
      self.canSwipeField = false
      if currentField[pageIndex]! < 0 {
         return
      }
      hideCurrentField(true)
      if tunnelToggled {
         progTunnel?.scrollToItem(at: IndexPath(row: currentField[pageIndex]!-1, section: 0), at: .centeredHorizontally, animated: true)
      }
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
      let saved = form.getCheckBoxes(page: pageIndex).first { checkbox in
         (checkbox.checked == true) && (pickerViewValues[0].contains(checkbox.key))
      }
      let savedIndex = fields.firstIndex { cb in
         cb.key == saved?.key
      }.map { index in
         Int(index)
      } ?? 0
      let pickerViewSelectedValue: PickerViewViewController.Index = (column:0,row:savedIndex)
      
      alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { [weak self] vc, picker, index, values in
         let selected = fields[index.row]
         fields.forEach {self?.setCheckBoxFieldValue(for: $0.key, false)}
         btn.setTitle(selected.key.textFromKey(), for: .normal)
         self?.setCheckBoxFieldValue(for: selected.key, true)
         self?.clearField()
      }
      alert.addAction(title: "סגור", style: .cancel)
      present(alert, animated: true)
   }
   
   func showLocationAlert(field:FormTextField,btn:UIButton) {
      let alert = UIAlertController(style: .actionSheet)
      alert.addLocationPicker { [weak self] location in
         guard let loc = location else {return}
         guard let strongSelf = self else {return}
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
         
         strongSelf.form.setFieldValue(for: "עיר מגורים", newValue: city.replacingOccurrences(of: postalcode, with: ""),page: strongSelf.pageIndex)
         strongSelf.form.setFieldValue(for: "רחוב", newValue: street.replacingOccurrences(of: "Street", with: ""),page: strongSelf.pageIndex)
         strongSelf.form.setFieldValue(for: "מספר רחוב", newValue: String(street_num),page: strongSelf.pageIndex)
         strongSelf.form.setFieldValue(for: "מיקוד", newValue: postalcode,page: strongSelf.pageIndex)
         strongSelf.clearField()
         btn.setAttributedTitle(NSAttributedString(string: loc.address, attributes: [.foregroundColor : strongSelf.form.getDesign().questionBoxHeaderBgColor(), .font : UIFont.boldSystemFont(ofSize: 14)]), for: .normal)
      }
      alert.addAction(title: "סגור", style: .cancel)
      present(alert, animated: true)
   }
   
   
   @IBAction func fillForm(_ sender: Any) {
      complete()
   }
   func clearedFieldCount() -> Int{
      return clearedFieldKeys.count
   }
   func allCleared() -> Bool {
      return clearedFieldCount() == totalFieldCount()
   }
   func complete() {
      //        if !allCleared() { showFormFillingToast(message: "יש למלא את כל השאלות לפני יצירת קובץ PDF! וודא שענית על כולן ונסה שוב"); return}
      let optionalPages = form.getOptionalPages()
      var fill:Bool = true
      if !optionalPages.isEmpty {
         let alert = UIAlertController(title: "AnyForm", message: "יש עוד שאלון אופציונלי \(optionalPages[0].pageTitle.textFromKey( )) האם תרצה למלא אותו?", preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "לא, המשך ליצרת הקובץ", style: .default))
         alert.addAction(UIAlertAction(title: "כן, אשמח", style: .destructive, handler: {(act) in
            fill = false
         }))
      }
      if fill {
         let alert = UIAlertController(title: "AnyForm", message: "האם אתה מוכן ליצור קובץ PDF?", preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "עדיין לא", style: .default))
         alert.addAction(UIAlertAction(title: "אני מוכן", style: .destructive, handler: { [weak self](act) in
            self?.saveUserData()
            self?.form.fill { url in
               let alert = UIAlertController(title: "AnyForm", message: "המסמך נוצר בהצלחה ונשמר בתיקיית המסמכים במכשירך \(url.path)", preferredStyle: .alert)
               alert.addAction(UIAlertAction(title: "פתח את המסמך", style: .default, handler: { [weak self] (act) in
                  guard let selfStrong = self else {return}
                  selfStrong.docController = UIDocumentInteractionController(url: url)
                  selfStrong.docController?.delegate = selfStrong
                  selfStrong.docController?.presentOpenInMenu(from: selfStrong.completionButton.frame, in: selfStrong.view, animated: true)
               }))
               alert.addAction(UIAlertAction(title: "שתף ב- WhatsApp", style: .default, handler: { [weak self] (act) in
                  guard let selfStrong = self else {return}
                  WhatsAppShare.whatsappShareWithImages(url, controller: &selfStrong.docController, viewcontroller: selfStrong)
               }))
               alert.addAction(UIAlertAction(title: "סגור", style: .cancel))
               self?.present(alert, animated: true)
            }
         }))
         self.present(alert, animated: true)
      }
   }
   
   
   /// `Hide Current Field Method`
   /// - Parameter prev: Previous button true / Next Button false
   /// - This is a little messy but works
   ///   has alot of things to consider
   func hideCurrentField(_ prev:Bool = false) {
      showFieldList { [weak self] in
         guard let strong = self else {return}
         guard let fields  = strong.fieldHolder[strong.pageIndex] else {return}
         UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: []) {
            if strong.currentField[strong.pageIndex]! < 0 {
               return}
            (fields.object(at: strong.currentField[strong.pageIndex]!) as? UIView)?.alpha = 0
         } completion: { (bool) in
            if strong.currentField[strong.pageIndex]! < 0 {
               return}
            (fields.object(at: strong.currentField[strong.pageIndex]!) as? UIView)?.isHidden = true
            if prev {
               strong.currentField[strong.pageIndex]! -= 1
               if strong.currentField[strong.pageIndex]! < 0 {
                  return}
            }else {
               if strong.currentField[strong.pageIndex]! + 1 >= fields.count {
                  return
               }
               strong.currentField[strong.pageIndex]! += 1
            }
            strong.showNextField()
         }
      }
   }
   
   func jumpToField(index:Int) {
      if index == currentField[pageIndex]! {
         return
      }
      let previous = currentField[pageIndex]!
      currentField[pageIndex]! = index
      if currentField[pageIndex]! < 0 {
         return
      }
      showFieldList { [weak self] in
         guard let strong = self else {return}
         UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: []) {
            (strong.fieldHolder[strong.pageIndex]?.object(at: previous) as? UIView)?.alpha = 0
         } completion: { (bool) in
            if strong.currentField[strong.pageIndex]! < 0 {
               return}
            (strong.fieldHolder[strong.pageIndex]?.object(at: strong.currentField[strong.pageIndex]!) as? UIView)?.isHidden = false
            (strong.fieldHolder[strong.pageIndex]?.object(at: strong.currentField[strong.pageIndex]!) as? UIView)?.alpha = 0
            
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: []) {
               (strong.fieldHolder[strong.pageIndex]?.object(at: strong.currentField[strong.pageIndex]!) as? UIView)?.alpha = 1
            }
            strong.prog?.value = CGFloat(strong.currentField[strong.pageIndex]!+1)
         }
      }
      
   }
   
   
   func showNextField() {
      guard let fields = self.fieldHolder[self.pageIndex] else {return}
      (fields.object(at: self.currentField[pageIndex]!) as? UIView)?.isHidden = false
      (fields.object(at: self.currentField[pageIndex]!) as? UIView)?.alpha = 0
      
      UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: []) {[weak self] in
         guard let strong = self else {return}
         (fields.object(at: strong.currentField[strong.pageIndex]!) as? UIView)?.alpha = 1
      } completion: { [weak self] (complete) in
         self?.canSwipeField = true
      }
      self.prog?.value = CGFloat(self.currentField[self.pageIndex]!+1)
      
   }
   func showFieldList(completion:@escaping () -> Void) {
      completion()
   }
   
   func setForm(_ form:Form) {
      self.form = form
   }
   
}

extension FormFieldsViewController : UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
   
   func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
      if !(collectionView is ChildCollection)  {return}
      let cell = cell as! ChildCell
      
      cell.alpha = 0
         cell.transform = CGAffineTransform(translationX: -200, y: 0)
         UIView.animate(withDuration: 0.25) {
           cell.alpha = 1
           cell.transform = .identity
         }
   }

   func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      if collectionView is ChildCollection {
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChildCell.identifier, for: indexPath) as! ChildCell
         cell.populateWithDelegate(delegate: collectionView.superview! as! ChildFieldView, indexPath: indexPath)
         return cell
      }
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tubecell", for: indexPath) as! Tube
      cell.initTube(tube:FieldProps.getRootFieldKey(self.fieldHeaders[pageIndex]![indexPath.row]), cleared: clearedFieldKeys)
      return cell
   }
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      if collectionView is ChildCollection {return CGSize(width: ChildCell.cellSize.width, height: ChildCell.cellSize.height)}
      if tunnelToggled {
         return CGSize(width: 200, height: 50)
      }else {
         return CGSize()
      }
   }
   func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      if collectionView is ChildCollection {return}
      if !canSwipeField {return}
      jumpToField(index: indexPath.row)
      collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
   }
   
   
   func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      if let childrenCollection =  collectionView as? ChildCollection {return childrenCollection.children.count}
      return self.fieldHolder[pageIndex]!.count
   }
   
   func numberOfSections(in collectionView: UICollectionView) -> Int {
      1
   }
   
   
}
extension FormFieldsViewController : FormFieldDelegator {
   func addHeader(header: String,pageIndex:Int) {
      fieldHeaders[pageIndex]?.append(header)
   }
   
   func addHolder(holder: UIStackView,pageIndex:Int) {
      fieldHolder[pageIndex]?.addObject(holder)
   }
   func addExtra(extra: UIView) {
      
      switch extra {
      case is SearchTextField:
         textFields.addObject(extra)
      case is UITextFieldFormGamified:
         gameFields.addObject(extra)
      case is UICheckBoxForm:
         checkBoxes.addObject(extra)
      case is UIDatePickerForm:
         datePickers.addObject(extra)
      default:
         print("Unknown field")
         // stack views,segments
      }
   }
   
   
}

extension FormFieldsViewController : ChildFieldViewDelegate {
   func presentChildDatePicker(datePickerController vc: UIViewController) {
      self.present(vc,animated:true)
   }
   func presentSomeAlert(alert: UIAlertController) {
      self.present(alert,animated:true)
   }
   
}
