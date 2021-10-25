//
//  ViewTesterViewController.swift
//  AnyForm
//
//  Created by Nadav Avnon on 13/10/2021.
//

import UIKit

class ViewTesterViewController: UIViewController {
    func presentChildDatePicker(datePickerController vc: UIViewController) {
        present(vc,animated: true)
    }
    
    lazy var draggble: UIView = {
        let view = UIView()
        view.backgroundColor = .systemOrange
        view.constraintWidth(50)
        view.constraintHeight(50)
        view.layer.cornerRadius = 25
    
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(drag)))
        return view
    }()
    
    @objc func drag(_ target:UIPanGestureRecognizer) {
        let pos = target.location(in: self.view)
        draggble.center = pos
        if target.state == .ended {
            print(addChildButton.bounds.maxX,pos.x)
            if pos.x >= addChildButton.bounds.minX && pos.x <= addChildButton.bounds.maxX && pos.y >= addChildButton.bounds.minY {
                addChild()
            }else {
                print(pos.x,addChildButton.bounds.minX,pos.x,addChildButton.bounds.maxX,pos.y,addChildButton.bounds.minY ,pos.y,addChildButton.bounds.midY)
            }
        }
    }
    
    class ChildCard : UIView {
        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }
        override init(frame: CGRect) {
            super.init(frame: CGRect())
        }
        convenience init() {
            self.init(frame: CGRect())
            layer.borderWidth = 0.5
            layer.borderColor = UIColor.black.cgColor
            layer.cornerRadius = 12
            constraintHeight(150)
            constraintWidth(200)
        }
    }
    
    func addChild() {
        let newChild = Child()
        testchildren.append(newChild)
        collection.reloadData()
    }
    var testchildren : [Child]  = []

    
    func isEditing() -> Bool {
        return edit
    }

    lazy var collection : UICollectionView = {
        let layout =  UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: ChildCell.cellSize.width, height: ChildCell.cellSize.height)
        layout.scrollDirection = .vertical
        let collection = UICollectionView(frame: CGRect(), collectionViewLayout: layout)
        collection.delegate = self
        collection.dataSource = self
        collection.register(ChildCell.self, forCellWithReuseIdentifier: ChildCell.identifier)
        return collection
    }()
    
    lazy var addChildButton : UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "child"), for: .normal)
        
        btn.addAction(UIAction(handler: { [weak self ] act in
            self?.addChild()
        }), for: .touchUpInside)
        btn.layer.borderWidth  = 0.5
        btn.layer.borderColor = UIColor.black.cgColor
        return btn
    }()
    
    var edit: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(addChildButton)
        view.addSubview(collection)
        addChildButton.constraintStartToStartOf(view)
        addChildButton.constraintTopToTopOf(view,32,safe: true)
        
        collection.constraintTopToBottomOf(addChildButton,16)
        collection.constraintBottomToBottomOf(view)
        collection.constraintWidth(ChildCell.cellSize.width)
        collection.constraintCenterHorizontallyIn(view)
        view.addSubview(draggble)
        draggble.constraintCenterVerticallyIn(view)
    }
    
}
extension ViewTesterViewController : UICollectionViewDelegate,
                                     UICollectionViewDataSource,
                                     UICollectionViewDelegateFlowLayout {
    
func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return testchildren.count
}

func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChildCell.identifier, for: indexPath) as! ChildCell
    //cell.populateWithDelegate(delegate: self)
    return cell
}
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: ChildCell.cellSize.width, height: ChildCell.cellSize.height)
    }
}
extension ViewTesterViewController : UITextFieldDelegate {
    
}
