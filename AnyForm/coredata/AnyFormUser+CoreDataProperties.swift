//
//  AnyFormUser+CoreDataProperties.swift
//  AnyForm
//
//  Created by Nadav Avnon on 09/08/2021.
//
//

import Foundation
import CoreData


extension AnyFormUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AnyFormUser> {
        return NSFetchRequest<AnyFormUser>(entityName: "AnyFormUser")
    }

    @NSManaged public var firstEntrance: Bool
    @NSManaged public var userdata: NSOrderedSet?

}

// MARK: Generated accessors for userdata
extension AnyFormUser {

    @objc(insertObject:inUserdataAtIndex:)
    @NSManaged public func insertIntoUserdata(_ value: UserData, at idx: Int)

    @objc(removeObjectFromUserdataAtIndex:)
    @NSManaged public func removeFromUserdata(at idx: Int)

    @objc(insertUserdata:atIndexes:)
    @NSManaged public func insertIntoUserdata(_ values: [UserData], at indexes: NSIndexSet)

    @objc(removeUserdataAtIndexes:)
    @NSManaged public func removeFromUserdata(at indexes: NSIndexSet)

    @objc(replaceObjectInUserdataAtIndex:withObject:)
    @NSManaged public func replaceUserdata(at idx: Int, with value: UserData)

    @objc(replaceUserdataAtIndexes:withUserdata:)
    @NSManaged public func replaceUserdata(at indexes: NSIndexSet, with values: [UserData])

    @objc(addUserdataObject:)
    @NSManaged public func addToUserdata(_ value: UserData)

    @objc(removeUserdataObject:)
    @NSManaged public func removeFromUserdata(_ value: UserData)

    @objc(addUserdata:)
    @NSManaged public func addToUserdata(_ values: NSOrderedSet)

    @objc(removeUserdata:)
    @NSManaged public func removeFromUserdata(_ values: NSOrderedSet)

}

extension AnyFormUser : Identifiable {

}
