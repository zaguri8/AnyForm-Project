//
//  SavedFields+CoreDataProperties.swift
//  
//
//  Created by Nadav Avnon on 18/09/2021.
//
//

import Foundation
import CoreData


extension SavedFields {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SavedFields> {
        return NSFetchRequest<SavedFields>(entityName: "SavedFields")
    }

    @NSManaged public var fieldKey: String?
    @NSManaged public var saved: [String]?

}
