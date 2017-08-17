//
//  JBentity+CoreDataProperties.swift
//  jacob
//
//  Created by Nanu Jogi on 04/08/17.
//  Copyright © 2017 GL. All rights reserved.
//

import Foundation
import CoreData

extension JBentity {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<JBentity> {
        return NSFetchRequest<JBentity>(entityName: "JBentity")
    }

    @NSManaged public var title: String?
    @NSManaged public var author: String?
    @NSManaged public var category: String?
    @NSManaged public var surl: String?
    @NSManaged public var date: Date?

}
