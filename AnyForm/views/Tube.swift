//
//  Tube.swift
//  AnyForm
//
//  Created by Nadav Avnon on 25/08/2021.
//

import UIKit

class Tube: UICollectionViewCell {
    @IBOutlet weak var tubeLabel: UILabel!
    @IBOutlet weak var rightPipe: UIView!
    @IBOutlet weak var leftPipe: UIView!
    var cleared:Bool = false
    @IBOutlet weak var tubeView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func initTube(tube:String,cleared:[String] = []) {
        tubeLabel.text = tube
        tubeLabel.textColor = .black
        rightPipe.addBorders(edges: [.top,.bottom], color: .black, width: 0.6)
        leftPipe.addBorders(edges: [.top,.bottom], color: .black, width: 0.6)
        contentView.bringSubviewToFront(tubeView)
        if !isCleared(from: cleared) {
            tubeView.backgroundColor = .white
        }else {
            tubeView.backgroundColor = .systemGreen
            tubeLabel.textColor = .white
        }
    }
    func isCleared(from:[String]) -> Bool {
        return from.contains(tubeLabel.text!)
    }
    func clear() {
        cleared = true
        tubeView.backgroundColor = .systemGreen
        tubeLabel.textColor = .white
    }
}
