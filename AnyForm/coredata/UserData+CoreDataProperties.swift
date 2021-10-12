//
//  UserData+CoreDataProperties.swift
//  
//
//  Created by Nadav Avnon on 23/08/2021.
//
//

import Foundation
import CoreData


extension UserData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserData> {
        return NSFetchRequest<UserData>(entityName: "UserData")
    }

    @NSManaged public var category: String?
    @NSManaged public var key: String?
    @NSManaged public var value: String?
}
