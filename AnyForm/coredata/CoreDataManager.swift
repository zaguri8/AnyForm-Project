//
//  CoreDataManager.swift
//  AnyForm
//
//  Created by נדב אבנון on 29/07/2021.
//

import Foundation
import CoreData
class CoreDataManager {
    static let shared: CoreDataManager = CoreDataManager()
    var user:AnyFormUser?
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "AnyForm")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    func getUser() -> AnyFormUser? {
        return user
    }
    func getUserData() -> [UserData] {
        guard let data = user?.getUserData() else {return []}
        return data
    }
    
    
    func addUserData(key:String,value:String,category:String) {
        guard let user = self.user,!value.isEmpty else {
            return}
        var exists = false
        for n in user.getUserData() {
            if (n.key == key) {
                n.value = value
                exists = true
            }
        }
        if !exists {
        let userData = UserData.insertUserData(key: key, value: value, category: category)
        user.addToUserdata(userData)
        }
        saveContext()
    }
    func getSavedFieldValues(_ key:String) -> [String] {
        let context = persistentContainer.viewContext
        let request:NSFetchRequest<SavedFields> = SavedFields.fetchRequest()
        do {
        let res =  try context.fetch(request)
        guard let savedField = (res.first {$0.fieldKey == key}) else {return []}
            return savedField.saved!
        }catch{
            print(error)
            return []
        }
    }
    
    func saveFieldValue(key:String,val:String) {
        let context = persistentContainer.viewContext
        let request:NSFetchRequest<SavedFields>  = SavedFields.fetchRequest()
        guard let res = try? context.fetch(request) else {return}
        if let savedField = (res.first{$0.fieldKey == key}) {
    
            savedField.save(val)
        }else {
            SavedFields.insertNewSavedField(key: key, initial: [val])
        }
        saveContext()
    }
    
    
    func fetchUser() {
        let context = persistentContainer.viewContext
        let request:NSFetchRequest<AnyFormUser> = AnyFormUser.fetchRequest()
        do {
            let result = try context.fetch(request)
            guard !result.isEmpty else {
                let newUser  = AnyFormUser(context: context)
                newUser.firstEntrance = true
                self.user =  newUser
                saveContext()
                return
            }
            self.user =  result.first
        }catch {
            print(error)
        }
    }
    
    private init() {
        
    }
    
    
}
