//
//  ChildCollectionToolbar.swift
//  AnyForm
//
//  Created by Nadav Avnon on 20/10/2021.
//

import UIKit

protocol ChildCollectionToolBarProtocol :AnyObject {
    func didAddChild()
}
class ChildCollectionToolbar: UIView {
    
    weak var delegate:ChildCollectionToolBarProtocol?
    lazy var draggble:UIImageView = {
        let imageview = UIImageView(image:UIImage(named: "addbtn")!)
        imageview.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(drag)))
        imageview.isUserInteractionEnabled = true
        return imageview
    }()
    
    @objc func drag(_ gesture:UIPanGestureRecognizer) {
        var pos = gesture.location(in: self)
        pos.y = draggble.center.y
        if pos.x < draggble.bounds.origin.x + draggble.bounds.size.width/2 {
            pos.x = draggble.bounds.origin.x + draggble.bounds.size.width/2 + 16
        }
        var end = false
        if pos.x > ChildCell.cellSize.width + draggble.bounds.origin.x {
            end = true
            pos.x = draggble.bounds.origin.x + draggble.bounds.size.width/2 + 16
        }
        if end {
            
            UIUtils.animateDuration({[weak self] in
                guard let strong = self else {return}
                
                strong.draggble.center = pos
            }, duration: 0.2)
        }else {
            draggble.center = pos
        }
        if let indicator = arrowIndicator{
            if indicator.isHidden {
                if gesture.state == .ended {
                    indicator.isHidden = false
                    arrowIndicatorLabel.isHidden = false
                }
            }else {
                if gesture.state != .ended  && !indicator.isHidden{
                    indicator.isHidden = true
                    arrowIndicatorLabel.isHidden = true
                }
            }
        }
        if gesture.state == .ended  && !end {
            UIUtils.animateDuration({[weak self] in
                guard let strong = self else {return}
                pos.x = strong.draggble.bounds.origin.x + strong.draggble.bounds.size.width/2 + 16
                strong.draggble.center = pos
            }, duration: 0.2)
        }
        if gesture.state == .ended && end {
            delegate?.didAddChild()
        }
                                    
    }
    lazy var arrowIndicator:UIButton? = {
       return nil
    }()
    lazy var arrowIndicatorLabel:UILabel = {
       let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .systemOrange
        label.text = "החלק ימינה להוספת ילד"
        return label
    }()
    
    let arrowUp = UIImage(named: "arrowRight")
    override init(frame: CGRect) {
        super.init(frame:frame)
        constraintHeight(50)
        backgroundColor = .white
        addSubview(draggble)
        draggble.constraintStartToStartOf(self,16)
        draggble.constraintWidth(50)
        draggble.constraintHeight(50)
        draggble.constraintBottomToBottomOf(self)
        arrowIndicator = UIButton()
        addSubview(arrowIndicator!)
        addSubview(arrowIndicatorLabel)
        arrowIndicator?.constraintStartToEndOf(draggble,8)
       // arrowIndicator?.transform = CGAffineTransform(rotationAngle: 180 / .pi / 2)
        arrowIndicator?.constraintWidth(35)
        arrowIndicator?.constraintHeight(35)
        arrowIndicatorLabel.constraintCenterVerticallyIn(self)
        arrowIndicatorLabel.constraintStartToEndOf(arrowIndicator!,8)
        arrowIndicator?.constraintCenterVerticallyIn(self)
        arrowIndicator?.setImage(arrowUp, for: .normal)
        
        arrowIndicator?.setTitleColor(.systemRed, for: .normal)
        UIView.animate(withDuration: 0.4, delay: 0, options: [.repeat,.autoreverse]) {[weak self] in
           self?.arrowIndicator?.transform = CGAffineTransform(translationX: 6, y: 0)
            self?.arrowIndicatorLabel.transform = CGAffineTransform(translationX: 6, y: 0)
        }
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
