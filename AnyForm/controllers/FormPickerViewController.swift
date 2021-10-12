//
//  UserInputViewController.swift
//  AnyForm
//
//  Created by עודד האינה on 24/07/2021.
//

import UIKit
protocol FormPickerDelegate: AnyObject  {
    func didPickForm(type:FormType)
}

class FormPickerViewController: UIViewController , UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,FormPickerDelegate{
    func didPickForm(type: FormType) {
        performSegue(withIdentifier: "startformedit", sender: type)
    }
    var types:[FormType] = [.form101,.loanrequest]
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        types.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? FormFieldsViewController  , let type = sender as? FormType {
            let design:FormDesign = (type == .loanrequest) ? FormProudDesign() : FormElegantDesign()
            dest.setForm(Form(type: type, design: design))
        }
    }
    
    @IBAction func unwindToRootViewController(segue: UIStoryboardSegue) {
        navigationController?.popToRootViewController(animated: true)
        showNavBar()
        showTabBar()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "formCollectionCell", for: indexPath) as! FormCollectionViewCell
        cell.delegate = self
        cell.populate(type: types[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 180, height: 200)
    }
    
    
    @IBOutlet weak var formCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formCollectionView.backgroundColor =   UIUtils.hexStringToUIColor(hex: "F8F7F5")
        self.view.backgroundColor =   UIUtils.hexStringToUIColor(hex: "F8F7F5")
        formCollectionView.delegate = self
        formCollectionView.dataSource = self
        formCollectionView.register(UINib(nibName: "FormCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "formCollectionCell")
    }
}
