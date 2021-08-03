//
//  UIViewController.swift
//  AnyForm
//
//  Created by נדב אבנון on 18/07/2021.
//

import UIKit

class FormViewController: UIViewController {
    var form:FormView?
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let form = self.form else{
            return}
        self.view = form
    }
}
