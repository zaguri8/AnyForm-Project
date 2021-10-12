//
//  ZoomView.swift
//  AnyForm
//
//  Created by Nadav Avnon on 12/10/2021.
//

import UIKit

class ZoomView: UIScrollView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .none
        layer.cornerRadius = 150
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
        constraintHeight(300)
        constraintWidth(300)
        contentSize = CGSize(width: 120, height: 120)
        isUserInteractionEnabled = true
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
