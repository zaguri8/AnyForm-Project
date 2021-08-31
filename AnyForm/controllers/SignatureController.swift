//
//  SignatureController.swift
//  AnyForm
//
//  Created by Nadav Avnon on 31/08/2021.
//

import UIKit

class SignatureController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()

        (view as! AnyFormSignatureField).setStrokeColor(color: .black)
    }

    func setupViews(){

        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.cornerRadius = 10
    }

    @IBAction func clearBtnTapped(_ sender: UIButton) {

        (view as! AnyFormSignatureField).clear()
    }
}
