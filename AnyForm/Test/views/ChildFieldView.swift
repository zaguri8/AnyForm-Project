//
//  ChildFieldView.swift
//  AnyForm
//
//  Created by Nadav Avnon on 20/10/2021.
//

import UIKit
protocol ChildFieldViewDelegate :AnyObject {
    func presentChildDatePicker(datePickerController vc: UIViewController)
    func presentSomeAlert(alert:UIAlertController)
}
class ChildFieldView: UIStackView, ChildCollectionToolBarProtocol {
    
    
    
    func didAddChild() {
        if collection.children.count == 13  { // max children
            let alert = UIAlertController(title: "AnyForm", message: "מספר הילדים המקסימלי הוא 13", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            delegate?.presentSomeAlert(alert: alert)
            return
        }
        collection.children.append(Child())
        collection.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {[weak self] in
            guard let strong = self else {return}
            strong.collection.scrollToItem(at: IndexPath.init(row: strong.collection.children.count-1, section: 0), at: .top, animated: true)
        }
    }
    
    weak var delegate:ChildFieldViewDelegate?
    lazy var toolbar:ChildCollectionToolbar = {
        let toolbarView = ChildCollectionToolbar()
        toolbarView.delegate = self
        return toolbarView
    }()
    
    lazy var collection : ChildCollection = {
        let layout =  UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collection = ChildCollection(frame: CGRect(), collectionViewLayout: layout)
        collection.constraintHeight(280)
        collection.bounces = false
        collection.transform = CGAffineTransform.init(rotationAngle: (-(CGFloat)(Double.pi)))
        collection.register(ChildCell.self, forCellWithReuseIdentifier: ChildCell.identifier)
        return collection
    }()
    
    func initializeCollection(delegate:FormFieldsViewController) {
        self.collection.delegate = delegate
        self.collection.dataSource = delegate
    }
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        axis = .vertical
        spacing = 0
        distribution = .fill
        insertArrangedSubview(toolbar, at: 0)
        insertArrangedSubview(collection, at: 1)
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension ChildFieldView : ChildCardDelegate {
    func didEditChildName(at indexPath: IndexPath,name:String) {
        collection.children.item(at: indexPath.row)?.name = name
        print(name)
    }
    
    func didEditChildId(at indexPath: IndexPath,id:String) {
        collection.children.item(at: indexPath.row)?.id = id
    }
    
    func didEditChildDate(at indexPath: IndexPath,birthDate:Date) {
        collection.children.item(at: indexPath.row)?.birthDate = birthDate
    }
    
    func presentChildDatePicker(datePickerController vc: UIViewController) {
        delegate?.presentChildDatePicker(datePickerController: vc)
    }
    
    func removeChild(at indexPath: IndexPath) {
        if collection.children.count-1 < indexPath.row {return}
        collection.children.remove(at: indexPath.row)
        collection.deleteItems(at: [indexPath])
    }
}
