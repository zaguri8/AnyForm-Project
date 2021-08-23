//
//  AnyFormUser+CoreDataProperties.swift
//  
//
//  Created by Nadav Avnon on 23/08/2021.
//
//

import Foundation
import CoreData


extension AnyFormUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AnyFormUser> {
        return NSFetchRequest<AnyFormUser>(entityName: "AnyFormUser")
    }

    @NSManaged public var firstEntrance: Bool
    @NSManaged public var userdata: NSSet?

}

// MARK: Generated accessors for userdata
extension AnyFormUser {

    @objc(addUserdataObject:)
    @NSManaged public func addToUserdata(_ value: UserData)

    @objc(removeUserdataObject:)
    @NSManaged public func removeFromUserdata(_ value: UserData)

    @objc(addUserdata:)
    @NSManaged public func addToUserdata(_ values: NSSet)

    @objc(removeUserdata:)
    @NSManaged public func removeFromUserdata(_ values: NSSet)

}
