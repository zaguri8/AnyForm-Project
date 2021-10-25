//
//  ZoomView.swift
//  AnyForm
//
//  Created by Nadav Avnon on 12/10/2021.
//

import UIKit

class ZoomView: UIImageView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .none
        constraintHeight(200)
        constraintWidth(200)
        isUserInteractionEnabled = true
        image = UIImage(named:"magnify")
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
