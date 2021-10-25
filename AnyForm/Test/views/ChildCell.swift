//
//  ChildCollection.swift
//  AnyForm
//
//  Created by Nadav Avnon on 16/10/2021.
//

import UIKit

protocol ChildCellDelegate: AnyObject {
    func didEditChildName(at indexPath:IndexPath,name:String)
    func didEditChildId(at indexPath:IndexPath,id:String)
    func didEditChildDate(at indexPath:IndexPath,birthDate:Date)
}
class ChildCell: UICollectionViewCell , ChildCellDelegate{
    func didEditChildName(at indexPath: IndexPath,name:String) {
        delegate?.didEditChildName(at: indexPath,name:name)
    }
    
    func didEditChildId(at indexPath: IndexPath,id:String) {
        delegate?.didEditChildId(at: indexPath,id:id)
    }
    
    func didEditChildDate(at indexPath: IndexPath,birthDate:Date) {
        delegate?.didEditChildDate(at: indexPath,birthDate:birthDate)
    }
    
    
    static let cellSize:CGSize = CGSize(width: 300, height: 180)
    
    static let identifier = "childViewcell"
    var indexPath:IndexPath?
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }
    weak var delegate:ChildCardDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        
    }
    
    func populateWithDelegate(delegate:ChildCardDelegate,indexPath:IndexPath) {
        if contentView.subviews.isEmpty {
        let frame = contentView.frame
        let childCard = ChildCard(frame: frame,delegate: delegate,indexPath:indexPath)
        childCard.delegate = delegate
        self.indexPath = indexPath
        contentView.addSubview(childCard)
            
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
