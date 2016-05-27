//
//  SVStudentVisitModel.swift
//  StudVisit
//
//  Created by Admin  on 27.05.16.
//  Copyright © 2016 Maxim Galayko. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyRSA


class SVStudentVisitModel: Object, NSCoding {
    
    dynamic var studentName: String?
    dynamic var lessonsName: String?
    dynamic var date: NSDate?
    dynamic var wasPresent: String?
    
    let rsa = SwiftyRSA()
    
    func encodeWithCoder(coder: NSCoder) {
        if let studentName = studentName { coder.encodeObject(studentName, forKey: "studentName") }
        if let lessonsName = lessonsName { coder.encodeObject(lessonsName, forKey: "lessonsName") }
        if let date = date { coder.encodeObject(date, forKey: "date") }
        if let wasPresent = wasPresent { coder.encodeObject(wasPresent, forKey: "wasPresent") }
    }
    
    required convenience init(coder decoder: NSCoder) {
        self.init()
        self.studentName = decoder.decodeObjectForKey("studentName") as? String
        self.lessonsName = decoder.decodeObjectForKey("lessonsName") as? String
        self.date = decoder.decodeObjectForKey("date") as? NSDate
        self.wasPresent = decoder.decodeObjectForKey("wasPresent") as? String
    }
    
    func storeDataWithName(studentName: String, date: NSDate, lessonsName: String, isPresent: String) -> Void {
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
    
    func getItemFromDataBaseWithPredicate(predicate: String) -> NSData?  {
        let realm = try! Realm()
        let visitsData = realm.objects(SVStudentVisitModel).filter(predicate)
        var array:[SVStudentVisitModel] = []
        for item in visitsData {
            array.append(item)
        }
       
        let data: NSData = NSKeyedArchiver.archivedDataWithRootObject(array)
        let encryptedData = createCryptoData(data)
        return encryptedData
    }
    
    func createCryptoData(openData: NSData) -> NSData? {
        let pubPath = NSBundle.mainBundle().pathForResource("public", ofType: "pem")!
        let pubString: String
        do {
            pubString = try String(contentsOfFile:pubPath, encoding: NSUTF8StringEncoding) as String
        } catch {
            return nil
        }
        let pubKey    = try! rsa.publicKeyFromPEMString(pubString)
        let encryptedData = try! rsa.encryptData(openData, publicKey: pubKey, padding: .None)
        return encryptedData
    }
    
    func decryptionOfTheEncryptedData(encryptedData: NSData) -> NSData?{
        
        let privPath = NSBundle.mainBundle().pathForResource("private", ofType: "pem")!
        var privString: String
        do {
            privString = try String(contentsOfFile:privPath, encoding: NSUTF8StringEncoding) as String
        } catch {
            return nil
        }
        let privKey = try! rsa.privateKeyFromPEMString(privString)
        let decryptedData = try! rsa.decryptData(encryptedData, privateKey: privKey, padding: .None)
        
        //test case. Crash sometimes. I don't know why)
        
        var array:[SVStudentVisitModel]?
     
        array = NSKeyedUnarchiver.unarchiveObjectWithData(decryptedData) as? [SVStudentVisitModel]
        
        for item in array! {
            let it = item as SVStudentVisitModel
            print(it.studentName)
            print(it.lessonsName)
            print(it.date)
            print(it.wasPresent)
        }
        
        
        return decryptedData
    }
}
