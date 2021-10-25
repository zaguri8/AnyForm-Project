//
//  FieldWithSubs.swift
//  AnyForm
//
//  Created by Nadav Avnon on 13/10/2021.
//

import UIKit

protocol FormFieldDelegator :AnyObject {
    func addHeader(header:String,pageIndex:Int)
    func addHolder(holder:UIStackView,pageIndex:Int)
    func addExtra(extra:UIView)
}
class FieldWithSubs: UIStackView {
    
    
    lazy var design:FormElegantDesign = {
        return FormElegantDesign()
    }()
    var key:String = ""
    var pageIndex:Int = 0
    var contentSize:CGSize = .zero
    weak var delegate:FormFieldDelegator?
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    @objc func anim() {
        print("click")
    }
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    convenience init(delegate:FormFieldDelegator,key:String,content:UIView,pageIndex:Int,contentSize:CGSize,submitFieldAction:UIAction? = nil,design:FormDesign = FormElegantDesign()) {
        let header = FieldWithSubs.headerLabel(key,design)
        var subviews:[UIView] = [header,content]
        if let action = submitFieldAction  {
            let submitbtn = FieldWithSubs.submitBtn(key: key.textFromKey())
            submitbtn.addAction(action, for: .touchUpInside)
            subviews.append(submitbtn)
        }
        self.init(arrangedSubviews: subviews)
        self.delegate = delegate
        self.pageIndex = pageIndex
        self.key = key
        self.contentSize = contentSize
        determine(key: key,content:content,submitFieldAction:submitFieldAction)
        isUserInteractionEnabled = true
    }
    

    
    private static func submitBtn(key: String) -> UIButton {
        let submitBtn = UIButton()
        submitBtn.setAttributedTitle(NSAttributedString(string:"אשר" + " " + key , attributes: [.foregroundColor : UIColor.systemGreen,.font : UIFont.boldSystemFont(ofSize: 14)]), for: .normal)
        submitBtn.isEnabled = true
        submitBtn.constraintHeight(50)
        return submitBtn
    }
    
    private static func headerLabel(_ title:String,_ design:FormDesign) -> UILabel{
       let header = UILabel()
       header.attributedText = design.questionTextAttributes(text: title)
       header.textAlignment = .center
       header.layoutMargins = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
       header.backgroundColor = design.questionBoxHeaderBgColor()
       return header
    }
    func determine(key:String,content:UIView,submitFieldAction:UIAction?) {
        isHidden = true
        applyCardHeaderStyle(content)
        applyContentStyle()
        applyCardStackViewStyle()
        delegate?.addHeader(header: key,pageIndex: pageIndex)
        delegate?.addHolder(holder: self,pageIndex: pageIndex)
        delegate?.addExtra(extra: content)
    }
    
    func applyContentStyle() {
        let content = arrangedSubviews[1]
        if contentSize.height > 0 {
        content.constraintHeight(contentSize.height)
        }
        content.clipsToBounds = true
        let cornerRad:CGFloat = content is UITextFieldFormGamified ? 8 : 0
        content.layer.cornerRadius = cornerRad
    }
    
    func applyCardHeaderStyle(_ content:UIView) {
        let header = arrangedSubviews[0]
        header.clipsToBounds = true
        header.layer.cornerRadius = 8
        header.layer.borderWidth = 0.5
        header.layer.borderColor = UIColor.white.cgColor
        header.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        header.constraintHeight(50)
    }
        
    func applyCardStackViewStyle() {
        axis = .vertical
        distribution = .fill
        layer.borderColor = UIColor.white.cgColor
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 2, right: 0)
        layer.borderWidth = 1
        layer.cornerRadius = design.questionBoxCornerRadius()
        backgroundColor = design.questionBoxColor()
        let sHeight = arrangedSubviews.map {$0.constraints.first {($0.identifier ?? "").contains("height")}?.constant ?? 0}.reduce(0){$0 + $1}
        layer.shadowRadius = 10
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.2
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowPath = UIBezierPath(rect: CGRect(x: bounds.midX+5, y: bounds.midY+5, width: 300, height: sHeight)).cgPath
        isUserInteractionEnabled = true
        
    }
}
