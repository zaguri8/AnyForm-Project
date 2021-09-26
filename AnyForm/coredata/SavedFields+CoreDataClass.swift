//
//  SavedFields+CoreDataClass.swift
//  
//
//  Created by Nadav Avnon on 18/09/2021.
//
//

import Foundation
import CoreData

@objc(SavedFields)
public class SavedFields: NSManagedObject {
    
    func save(_ val:String) {
        if saved != nil {
        if !saved!.contains(val) {
            saved!.append(val)
        } else {
            return
        }
        }
    }
    
    
    public static func insertNewSavedField(key:String,initial:[String] = []) {
        let savedFields = NSEntityDescription.insertNewObject(forEntityName:"SavedFields",into:CoreDataManager.shared.persistentContainer.viewContext) as! SavedFields
        savedFields.fieldKey = key
        savedFields.saved = initial
    }
}
