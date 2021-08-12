//
//  AnyFormHelper.swift
//  AnyForm
//
//  Created by Nadav Avnon on 05/08/2021.
//

import Foundation
import UIKit
class AnyFormHelper {
    static let shared = AnyFormHelper()
    var data = CoreDataManager.shared.getUserData()
    private init() {
        
    }
    
    func getUserStoredData() -> [(String , String)] {
        guard let nData = CoreDataManager.shared.getUserData() else {return []}
        var nDataClean:[(String,String)] = []
        nData.forEach { data in
            guard let key = data.key, let val = data.value else {return}
            let userFriendlyKey = key.replacingOccurrences(of: "_", with: " ")
            var userFriendlyVal:String  = ""
            userFriendlyVal = val.replacingOccurrences(of: "_", with: " ")
            if userFriendlyVal == "false" {
                userFriendlyVal = "לא נכון"
            } else if userFriendlyVal == "true" {
                userFriendlyVal = "נכון"
            }
            nDataClean.append((userFriendlyKey,userFriendlyVal))
            }
            return nDataClean
        }

}

extension FormFieldsViewController {
    func showUserStoredInformation() {
        let dataTable:UserDataTableView = UserDataTableView()
        present(dataTable, animated: true)
    }

}
class UserDataTableView : UITableViewController {
    
    var data:[(String,String)] {
        return [("","")]
    }
    
    override func viewDidLoad() {
        tableView.register(UserDataTableCell.self, forCellReuseIdentifier: UserDataTableCell.id)
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserDataTableCell.id, for: indexPath) as! UserDataTableCell
        let nData = data[indexPath.row]
        cell.populate(data: nData)
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }

}
class UserDataTableCell : UITableViewCell {
    static var id = "userDataCell"
    var keyLabel:UILabel = {
        let label = ViewFactory.blackCenteredLabel("")
        let s = label.font.pointSize
        label.font = UIFont.boldSystemFont(ofSize: s)
        return label
    }()
    var valueLabel:UILabel = {
        let label = ViewFactory.blackCenteredLabel("")
        return label
    }()
    lazy var stack:UIStackView = {
        let stack = UIStackView(arrangedSubviews: [valueLabel,keyLabel])
        stack.distribution = .fillEqually
        stack.axis = .horizontal
        return stack
    }()
    override func setSelected(_ selected: Bool, animated: Bool) {
        
    }
    override class func awakeFromNib() {
    }
    func populate(data:(String,String)) {
        self.keyLabel.text = data.0
        self.valueLabel.text = data.1
        self.contentView.addSubview(stack)
        stack.center = self.contentView.convert(self.contentView.center, from:self.contentView.superview)
        stack.bounds.size.width = self.contentView.bounds.width
        stack.bounds.size.height = self.contentView.bounds.height
    }
}
