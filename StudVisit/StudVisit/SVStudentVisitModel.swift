//
//  SVStudentVisitModel.swift
//  StudVisit
//
//  Created by Admin  on 27.05.16.
//  Copyright © 2016 Maxim Galayko. All rights reserved.
//

import UIKit
import RealmSwift

class SVStudentVisitModel: Object {
    
    dynamic var studentName: String?
    dynamic var lessonsName: String?
    dynamic var date: NSDate?
    dynamic var wasPresent: Bool = false
    
    
    func storeDataWithName(studentName: String, date: NSDate, lessonsName: String, isPresent: Bool) -> Void {
        let studentVisits = SVStudentVisitModel()
        studentVisits.studentName = studentName
        studentVisits.date = date
        studentVisits.lessonsName = lessonsName
        studentVisits.wasPresent = isPresent
    
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(studentVisits)
        }
    }
    
    func getAllItemsFromDataBase() -> AnyObject {
       //TODO: get all items from database
        return "TODO"
    }
    
    func getItemFromDataBaseWithPredicate(predicate: String) -> AnyObject  {
        //TODO: get items with predicate
        return "TODO"
    }
}
