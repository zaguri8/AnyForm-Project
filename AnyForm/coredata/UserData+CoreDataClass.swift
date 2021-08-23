//
//  UserData+CoreDataClass.swift
//  
//
//  Created by Nadav Avnon on 23/08/2021.
//
//

import Foundation
import CoreData

@objc(UserData)
public class UserData: AnyFormUser {
    static func insertUserData(key:String,value:String,category:String) -> UserData {
        let userData = NSEntityDescription.insertNewObject(forEntityName: "UserData", into: CoreDataManager.shared.persistentContainer.viewContext) as! UserData
        userData.key = key
        userData.value = value
        userData.category = category
        return userData
    }
}
