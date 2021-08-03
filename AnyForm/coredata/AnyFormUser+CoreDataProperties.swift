//
//  AnyFormUser+CoreDataProperties.swift
//  AnyForm
//
//  Created by נדב אבנון on 29/07/2021.
//
//

import Foundation
import CoreData


extension AnyFormUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AnyFormUser> {
        return NSFetchRequest<AnyFormUser>(entityName: "AnyFormUser")
    }

    @NSManaged public var data: [String : Any]?
    @NSManaged public var firstEntrance: Bool
}

extension AnyFormUser : Identifiable {

}
