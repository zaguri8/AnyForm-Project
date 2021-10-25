//
//  ChildCard.swift
//  AnyForm
//
//  Created by Nadav Avnon on 18/10/2021.
//

import Foundation
import UIKit
protocol ChildCardDelegate : AnyObject {
    func presentChildDatePicker(datePickerController vc:UIViewController)
    func removeChild(at indexPath: IndexPath)
    func didEditChildName(at indexPath:IndexPath,name:String)
    func didEditChildId(at indexPath:IndexPath,id:String)
    func didEditChildDate(at indexPath:IndexPath,birthDate:Date)
}

class ChildCard : UIView, UITextFieldDelegate {
    
    
    weak var delegate:ChildCardDelegate?
    var indexPath:IndexPath?
    lazy var datePickerAction:UIAction = {
        let action = UIAction(handler:
                                { [weak self ] act in
            guard let strong = self else {return}
            let pickerVC = UIAlertController(title: "AnyForm", message: "בחר תאריך לידה של הילד", preferredStyle: .alert)
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            datePicker.preferredDatePickerStyle = .compact
            datePicker.constraintHeight(50)
            pickerVC.view.constraintHeight(180)
            pickerVC.view.constraintWidth(300)
            pickerVC.view.addSubview(datePicker)
            datePicker.constraintCenterVerticallyIn(pickerVC.view)
            datePicker.constraintCenterHorizontallyIn(pickerVC.view)
            pickerVC.addAction(UIAlertAction(title: "שמור", style: .default, handler: {[weak strong] act in
                guard let strongSelf = strong else {return }
                strongSelf.delegate?.didEditChildDate(at: strongSelf.indexPath!, birthDate: datePicker.date)
                strongSelf.childBirthDateLabel.text = datePicker.date.string()
            }))
            pickerVC.addAction(UIAlertAction(title: "בטל", style: .destructive, handler:nil))
            strong.delegate?.presentChildDatePicker(datePickerController:pickerVC)
        })
        return action
    }()
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text, !text.isEmpty else {return}
        switch textField.placeholder {
        case "שם הילד":
            delegate?.didEditChildName(at: indexPath!, name: text)
        case "מספר תעודת זהות":
            delegate?.didEditChildId(at: indexPath!, id: text)
        default:
            print("Unrecognized child-card Textfield")
        }
    }
    
    lazy var childNameTextField:UITextField = {
        let textField = UITextField()
        textField.constraintHeight(40)
        textField.placeholder = "שם הילד"
        textField.textAlignment = .right
        textField.layer.cornerRadius = 8
        textField.backgroundColor = .white
        textField.delegate = self
        textField.keyboardType = .alphabet
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 40))
        textField.rightView = paddingView
        textField.rightViewMode = .always
        return textField
    }()
    
    lazy var childIdTextField:UITextField = {
        let textField = UITextField()
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 40))
        textField.rightView = paddingView
        textField.rightViewMode = .always
        textField.delegate = self
        textField.constraintHeight(40)
        textField.keyboardType = .numberPad
        textField.placeholder = "מספר תעודת זהות"
        textField.textAlignment = .right
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 8
        return textField
    }()
    
    lazy var childBirthDateLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        label.textAlignment = .center
        label.constraintHeight(30)
        return label
    }()
    
    lazy var childBirthDatePickerButtonL:UIButton = {
        let button = UIButton()
        
        button.setAttributedTitle(NSAttributedString(string:"שנה תאריך לידה",attributes: [.font : UIFont.boldSystemFont(ofSize: 16),.foregroundColor : UIColor.white.cgColor]), for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        button.layer.cornerRadius = 8
        button.backgroundColor = .systemOrange
        button.addAction(datePickerAction, for: .touchUpInside)
        button.constraintHeight(40)
        return button
    }()
    lazy var detailsStack:UIStackView = {
       let stack = UIStackView(arrangedSubviews: [childNameTextField,childIdTextField,childBirthDatePickerButtonL,childBirthDateLabel])
        stack.distribution = .fill
        stack.spacing = 4
        stack.axis = .vertical
        return stack
    }()
    
    
    convenience init(frame:CGRect,delegate:ChildCardDelegate,indexPath:IndexPath) {
        self.init(frame: frame)
        self.delegate = delegate
        setGradient()
        self.indexPath = indexPath
        layer.cornerRadius = 8
        clipsToBounds = true
        let images:[UIImage?] = [UIImage(named: "boy1"),UIImage(named:"boy2"),UIImage(named:"boy3"),
                                UIImage(named: "girl1"),UIImage(named: "girl2")]
        
        let choose = images[Int.random(in: 0...images.count-1)]
        if let childImage = choose {
            let childImageView = UIImageView(image: childImage)
            addSubview(childImageView)
            childImageView.constraintStartToStartOf(self,8)
            childImageView.constraintWidth(128)
            childImageView.constraintHeight(128)
            childImageView.constraintBottomToBottomOf(self)
            
            
            addSubview(detailsStack)
            detailsStack.constraintStartToEndOf(childImageView)
            detailsStack.constraintEndToEndOf(self,8)
            detailsStack.constraintTopToTopOf(self,8)
        }
        let removalButton = UIButton()
        removalButton.setImage(UIImage(named:"remove")!, for: .normal)
        addSubview(removalButton)
        removalButton.constraintTopToTopOf(self,4)
        removalButton.constraintStartToStartOf(self,4)
        let removeAction:UIAction = UIAction(handler: { [weak self] act in
            guard let strong = self else {return}
            strong.delegate?.removeChild(at: indexPath)
            strong.releaseCard()
        })
        removalButton.addAction(removeAction, for: .touchUpInside)
    }
    
    func releaseCard() {
        childIdTextField.text = nil
        childNameTextField.text = nil
        childBirthDateLabel.text = nil
        indexPath = nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    func setGradient() {
        let colorTop =  UIColor(red: 255.0/255.0, green: 149.0/255.0, blue: 0.0/255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 255.0/255.0, green: 94.0/255.0, blue: 58.0/255.0, alpha: 1.0).cgColor
                    
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = bounds
                
        layer.insertSublayer(gradientLayer, at:0)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
