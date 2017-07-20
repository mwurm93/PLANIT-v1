////
////  DataController.swift
////  planit v0.2
////
////  Created by MICHAEL WURM on 7/19/17.
////  Copyright © 2017 MICHAEL WURM. All rights reserved.
////
//
//import UIKit
//import CoreData
//
//class DataController: NSObject {
//
//    private(set) var persistentContainer: NSPersistentContainer?
//
////    var managedObjectContext: NSManagedObjectContext
//    init(completionClosure: @escaping () -> ()) {
//        persistentContainer = NSPersistentContainer(name: "Model")
//        persistentContainer?.loadPersistentStores() { (description, error) in
//            if let error = error {
//                fatalError("Failed to load Core Data stack: \(error)")
//            }
//            completionClosure()
//        }
//    }
//}
