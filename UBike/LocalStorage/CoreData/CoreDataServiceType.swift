//
//  CoreDataServiceType.swift
//  UBike
//
//  Created by Vince on 2023/4/19.
//

import RxSwift
import CoreData

protocol CoreDataServiceType: LocalDataSourceType {
    var container: NSPersistentContainer { get }
}

extension CoreDataServiceType {
    var container: NSPersistentContainer {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    }
}
