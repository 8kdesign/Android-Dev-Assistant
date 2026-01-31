//
//  StorageHelper.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 31/1/26.
//

import Foundation
import CoreData

@LogicActor
class StorageHelper {
    
    static let shared = StorageHelper()
    
    lazy var persistantContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DevAssistantModel")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                // Error
            }
        }
        return container
    }()
    
    @LogicActor func addLink(_ path: String) {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = persistantContainer.persistentStoreCoordinator
        return context.performAndWait {
            do {
                let fetchRequest = StoredAppItem.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "path == %@", path as CVarArg)
                let result = try context.fetch(fetchRequest)
                result.forEach { item in
                    context.delete(item)
                }
                let newItem = StoredAppItem(context: context)
                newItem.path = path
                try context.save()
            } catch {}
        }
    }
    
    @LogicActor func removeLink(_ path: String) {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = persistantContainer.persistentStoreCoordinator
        return context.performAndWait {
            do {
                let fetchRequest = StoredAppItem.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "path == %@", path as CVarArg)
                let result = try context.fetch(fetchRequest)
                result.forEach { item in
                    context.delete(item)
                }
                try context.save()
            } catch {}
        }
    }
    
    @LogicActor func getApkItems() -> [ApkItem] {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = persistantContainer.persistentStoreCoordinator
        return context.performAndWait {
            var items: [ApkItem] = []
            do {
                let fetchRequest = StoredAppItem.fetchRequest()
                let result = try context.fetch(fetchRequest)
                result.forEach { item in
                    if let path = item.path,
                       let url = URL(string: path),
                       let apkItem = ApkItem.fromPath(url) {
                        items.append(apkItem)
                    }
                }
            } catch {}
            return items
        }
    }
    
}
