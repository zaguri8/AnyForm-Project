//
//  AnyFormUser+CoreDataClass.swift
//  AnyForm
//
//  Created by Nadav Avnon on 09/08/2021.
//
//

import Foundation
import CoreData

@objc(AnyFormUser)
public class AnyFormUser: NSManagedObject {
    func getUserData() -> [UserData] {
        return self.userdata?.array as? [UserData] ?? []
    }
}
