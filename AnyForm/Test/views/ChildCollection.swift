//
//  ChildCollection.swift
//  AnyForm
//
//  Created by Nadav Avnon on 19/10/2021.
//

import UIKit

class ChildCollection :UICollectionView {
    var children:[Child] = []
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    convenience init(collectionViewLayout layout: UICollectionViewLayout,delegate:ChildCardDelegate)  {
        self.init(frame: CGRect(), collectionViewLayout: layout)
    }
}
