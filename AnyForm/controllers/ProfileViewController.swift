//
//  ProfileViewController.swift
//  AnyForm
//
//  Created by נדב אבנון on 30/07/2021.
//

import UIKit


class ViewFactory {
    static func blackCenteredLabel(_ text:String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .black
        label.textAlignment = .center
        return label
    }
}

class ProfileViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        10
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        numbers.count
    }
    var numbers = [0,1,2,3,4,5,6,7,8,9]
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(numbers[component])
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        20
    }
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        30
    }
  
    @objc func selection1Option1() {
        stackSelection2?.layer.borderWidth = 0
        stackSelection1?.layer.borderWidth = 1
        stackSelection1?.layer.borderColor = UIColor.black.cgColor
    }
    
    @objc func selection1Option2() {
        stackSelection1?.layer.borderWidth = 0
        stackSelection2?.layer.borderWidth = 1
        stackSelection2?.layer.borderColor = UIColor.black.cgColor
    }
    
    var stackSelection1:UIStackView?
    var stackSelection2:UIStackView?
    lazy var SelectionView:UIView =  {
        let view:UIView = UIView(frame: self.view.bounds)
        view.backgroundColor = hexStringToUIColor(hex: "F7F7F7")
        let label = ViewFactory.blackCenteredLabel("אופן הצגת שדות המספרים:")
        let labelSelection1 = ViewFactory.blackCenteredLabel("גלגל מספרים:")
        let labelSelection2 = ViewFactory.blackCenteredLabel("שדה טקסט מספרי:")
        
        let numberPicker = UIPickerView()
        numberPicker.isUserInteractionEnabled = false
        numberPicker.dataSource = self
        numberPicker.delegate = self
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 196, height: 64))
        let textfield = UITextField()
        textfield.layer.borderColor = UIColor.black.cgColor
        textfield.layer.borderWidth = 0.5
        textfield.frame = CGRect(x: 0, y: 0, width: v.bounds.width / 1.5, height: 28)
        v.addSubview(textfield)
        textfield.center = v.convert(v.center, from: v.superview)
        textfield.textAlignment = .center
        textfield.backgroundColor = .white
        textfield.placeholder = "הכנס טקסט מספרי"
        textfield.isUserInteractionEnabled = false
        
        stackSelection1 = UIStackView(arrangedSubviews: [labelSelection1,numberPicker])
        guard let stackSelection1 = stackSelection1 else  {return view}
        stackSelection1.spacing = 0
        stackSelection1.axis = .vertical

        stackSelection1.isUserInteractionEnabled = true
        
    
        stackSelection2 = UIStackView(arrangedSubviews: [labelSelection2,v])
        guard let stackSelection2 = stackSelection2 else  {return view}
        stackSelection2.spacing = 0
        stackSelection2.axis = .vertical
       
        let selectionStack = UIStackView(arrangedSubviews: [stackSelection1,stackSelection2])
        selectionStack.axis = .horizontal
        selectionStack.distribution = .fillEqually
        selectionStack.isUserInteractionEnabled = true
        
        let stack = UIStackView(arrangedSubviews: [label,selectionStack])
        stack.axis = .vertical
        stack.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 4)
        stack.center = view.convert(view.center, from: view.superview)
        stack.center.y = stack.center.y-128
        stack.distribution = .fillEqually
        stack.spacing = 0
        stack.isUserInteractionEnabled = true
        view.addSubview(stack)
        return view
    }()
    
    class xButton:UIButton {
        override open var isHighlighted: Bool {
            didSet {
                backgroundColor = isHighlighted ? UIColor.black : hexStringToUIColor(hex: "32AFB5")
            }
        }
    }
    lazy var Animation:UIView = {
        let view:UIView = UIView(frame: self.view.bounds)
        view.backgroundColor = hexStringToUIColor(hex: "F7F7F7")
        let im = UIImageView(image: #imageLiteral(resourceName: "profile"))
        view.alpha = 0
        im.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        im.center = view.convert(view.center, from: view.superview)
        im.center.y = im.center.y-128
        let label = UILabel()
        label.text = "התאם אישית את פורמט מילוי הטפסים"
        label.font = UIFont(name: "Marker Felt", size: 24)
        label.textColor  = .black
        label.textAlignment = .center
        label.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 28)
        label.center = view.convert(view.center, from: view.superview)
        label.center.y = label.center.y-64
        
        let startButton = xButton()
        startButton.backgroundColor = hexStringToUIColor(hex: "32AFB5")
        startButton.layer.borderWidth = 0.3
        startButton.layer.borderColor = UIColor.black.cgColor
        startButton.layer.cornerRadius = 14
        startButton.setAttributedTitle(NSAttributedString(string: "התחל התאמה אישית", attributes: [NSAttributedString.Key.font : UIFont(name: "Marker Felt", size: 32)!,NSAttributedString.Key.foregroundColor : UIColor.white]), for: .normal)
        startButton.frame = CGRect(x: 0, y: 0, width: 300, height: 50)
        startButton.center = label.convert(label.center, from: view)
        startButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        startButton.center.y = label.center.y+128
        startButton.addAction(UIAction(handler: { handle in
            self.startAnimation()
        }), for: .touchUpInside)
        
        startButton.alpha = 0
        im.alpha = 0
        label.alpha = 0
        
        view.addSubview(im) // first view to be animated in
        view.addSubview(label) // second view to be animated in
        view.addSubview(startButton) // third view to be animated in
        return view
    }()
  
    
    func startAnimation() {
        animate({
            self.Animation.subviews[0].frame.origin.x =  500
            self.Animation.subviews[1].frame.origin.x =  500
            self.Animation.subviews[2].frame.origin.x =  500
        },completion: { (animC1) in
            self.Animation.removeFromSuperview()
            self.view.addSubview(self.SelectionView)
            self.stackSelection1?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.selection1Option1)))
            self.stackSelection2?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.selection1Option2)))
        }, duration: 0.8) // second animation
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = hexStringToUIColor(hex: "F7F7F7")
        self.view.addSubview(self.Animation)
        
        animate({
            self.Animation.alpha = 1
        },completion: { (animC1) in
            animate({
                self.Animation.subviews[0].alpha = 1
                self.Animation.subviews[1].alpha = 1
            },completion: { (animC2) in
                animate({
                    self.Animation.subviews[2].alpha = 1
                }, duration: 0.2) // last animation
            },delay:0.2, duration: 0.8) // second animation
        },delay:0.2, duration: 0.5) // first animation
    }
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get{
            return .portrait
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    
}
