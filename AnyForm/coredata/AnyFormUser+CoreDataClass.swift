//
//  AnyFormUser+CoreDataClass.swift
//  
//
//  Created by Nadav Avnon on 23/08/2021.
//
//

import Foundation
import CoreData

@objc(AnyFormUser)
public class AnyFormUser: NSManagedObject {
    func getUserData() -> [UserData] {
        return userdata?.allObjects as? [UserData] ?? []
    }
}
