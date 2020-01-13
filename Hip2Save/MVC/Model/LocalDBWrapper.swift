//
//  LocalDBWrapper.swift
//  Hip2Save
//
//  Created by ip-d on 29/01/19.
//  Copyright © 2019 Hip Happenings. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreData
class LocalDBWrapper: NSObject {
    
    static let shared:LocalDBWrapper = LocalDBWrapper()
    private let managedContext = AppDelegate.shared.persistentContainer.viewContext
    
    func createUser(userJSON:JSON)
    {
        let status = deleteUser()
        if !status
        {
            print("fail to delete user local database")
        }
        let user = User(context:managedContext)
        
        let userDetail = userJSON["user"].dictionaryValue
        user.cookie = userJSON["cookie"].stringValue
        user.avatar = userDetail["avatar"]?.stringValue
        user.displayname = userDetail["displayname"]?.stringValue
        user.firstname =  userDetail["firstname"]?.stringValue
        user.lastname = userDetail["lastname"]?.stringValue
        user.username = userDetail["username"]?.stringValue
        user.id = userDetail["id"]?.int32Value ?? 0
        saveContext()
    }
    
    
    func readUser() -> User?
    {
        var users:[User]? = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:"User")
        do {
            users = try managedContext.fetch(fetchRequest) as? [User]
            if users != nil && (users?.count)! > 0
            {
                return users!.last
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return nil
    }
    
    func updateUser()
    {
        saveContext()
    }
    
    func deleteUser() -> Bool
    {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        do {
            try managedContext.execute(request)
            saveContext()
            return true
        }
        catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return false
        }
    }
    
    private func saveContext() {
        do
        {
            try managedContext.save()
        }
        catch
        {
            print("LocalDBWrapper:\(error.localizedDescription)")
        }
        
    }
    
}
