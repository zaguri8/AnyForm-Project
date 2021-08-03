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
    lazy var user:AnyFormUser? = nil
    
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
    func getUserData() -> [String:Any]? {
        return user?.data
    }
    
    
    func setUserData(key:String,value:String) {
        guard let user = self.user,!value.isEmpty else {return}
        user.data?[key] = value
        saveContext()
    }
    
    func fetchUser() {
        let context = persistentContainer.viewContext
        let request:NSFetchRequest<AnyFormUser> = AnyFormUser.fetchRequest()
        do {
            let result = try context.fetch(request)
            guard !result.isEmpty else {
                let newUser  = AnyFormUser(context: context)
                newUser.data = [:]
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
