//
//  ViewControllerExmplaeViewController.swift
//  AnyForm
//
//  Created by Nadav Avnon on 12/08/2021.
//

import UIKit
import PWSwitch
import RoundedSwitch
class ViewControllerExmplaeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let switchPicker = Switch()
        switchPicker.leftText = "Windows"
        switchPicker.rightText = "Mac"
       // switchPicker.trackOnBorderColor = .systemBlue
        switchPicker.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(switchPicker)
        switchPicker.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        switchPicker.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        switchPicker.widthAnchor.constraint(equalToConstant:250).isActive = true
        switchPicker.heightAnchor.constraint(equalToConstant: 40).isActive = true

    }
}
