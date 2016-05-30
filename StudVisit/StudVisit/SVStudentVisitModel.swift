//
//  SVStudentVisitModel.swift
//  StudVisit
//
//  Created by Maxim Galayko on 27.05.16.
//  Copyright © 2016 Maxim Galayko. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyRSA

class SVStudent: NSObject, NSCoding {
    init(model: SVStudentVisitModel) {
        self.studentName = model.studentName
        self.lessonsName = model.lessonsName
        self.date = model.date
        self.wasPresent = model.wasPresent
    }
    
    var studentName: String?
    var lessonsName: String?
    var date: NSDate?
    var wasPresent: String?
    
    func encodeWithCoder(coder: NSCoder) {
        if let studentName = studentName { coder.encodeObject(studentName, forKey: "studentName") }
        if let lessonsName = lessonsName { coder.encodeObject(lessonsName, forKey: "lessonsName") }
        if let date = date { coder.encodeObject(date, forKey: "date") }
        if let wasPresent = wasPresent { coder.encodeObject(wasPresent, forKey: "wasPresent") }
    }
    
    required init(coder decoder: NSCoder) {
        self.studentName = decoder.decodeObjectForKey("studentName") as? String
        self.lessonsName = decoder.decodeObjectForKey("lessonsName") as? String
        self.date = decoder.decodeObjectForKey("date") as? NSDate
        self.wasPresent = decoder.decodeObjectForKey("wasPresent") as? String
    }
}

class SVStudentVisitModel: Object, NSCoding {
    
    dynamic var studentName: String?
    dynamic var lessonsName: String?
    dynamic var date: NSDate?
    dynamic var wasPresent: String?
    
    static let rsa = SwiftyRSA()
    static let dataBaseKey = "37c3baab 93632e50 fa36469f 744aaaba 7e5f7c9e 80057986 412fe772 d0b14ad1 50608b3a e22280fe 2b7e42c8 446e0ef2 0bfc2972 cf5605f8 c85c63ee 674fd31a"
    
    //MARK: -- serialization/ deserialization
    
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
    
}

extension SVStudentVisitModel {

    //MARK: -- store/get data methods
    
    class func printKeys() {
        let pubPath = NSBundle.mainBundle().pathForResource("public", ofType: "pem")!
        let pubString: String
        do {
            pubString = try String(contentsOfFile:pubPath, encoding: NSUTF8StringEncoding) as String
            let pubKey    = try! rsa.publicKeyFromPEMString(pubString)
            print("public: \(pubKey)")
        } catch {
        }
        let privPath = NSBundle.mainBundle().pathForResource("private", ofType: "pem")!
        var privString: String
        do {
            privString = try String(contentsOfFile:privPath, encoding: NSUTF8StringEncoding) as String
            let privKey = try! rsa.privateKeyFromPEMString(privString)
            print("private \(privKey)")
        } catch {
        }
    }
    
    class func clearDataBase() {
        let config = Realm.Configuration(encryptionKey: getKey())
        do {
            let realm = try Realm(configuration: config)
            realm.beginWrite()
            realm.deleteAll()
            try realm.commitWrite()
        } catch {
        }
    }
    
    class func storeDataWithStudent(student: SVStudent) {
        if let name = student.studentName, date = student.date, lesson = student.lessonsName, present = student.wasPresent {
            storeDataWithName(name, date: date, lessonsName: lesson, isPresent: present)
        } else {
            print("\n\n\nNOT SAVED RECORD")
        }
    }
    
    class func storeDataWithName(studentName: String, date: NSDate, lessonsName: String, isPresent: String) -> Void {
        
        let config = Realm.Configuration(encryptionKey: getKey())
        do {
            let realm = try Realm(configuration: config)
            let studentVisits = SVStudentVisitModel()
            studentVisits.studentName = studentName
            studentVisits.date = date
            studentVisits.lessonsName = lessonsName
            studentVisits.wasPresent = isPresent
            try! realm.write {
                realm.add(studentVisits)
            }
        } catch {
        }
    }
    
    class func itemsWithPredicate(predicate: String) -> [SVStudentVisitModel] {
        var array: [SVStudentVisitModel] = []
        let config = Realm.Configuration(encryptionKey: getKey())
        do {
            let realm = try Realm(configuration: config)
            let visitsData = realm.objects(SVStudentVisitModel).filter(predicate)
            for item in visitsData {
                array.append(item)
            }
        } catch {
        }
        return array
    }
    
    class func removeItem(model: SVStudentVisitModel) -> Bool {
        let config = Realm.Configuration(encryptionKey: getKey())
        do {
            let realm = try Realm(configuration: config)
            realm.beginWrite()
            realm.delete(model)
            try realm.commitWrite()
        } catch {
            return false
        }
        return true
    }
    
    class func encrypedItemsWithPredicate(predicate: String) -> NSData?  {
        let array = itemsWithPredicate(predicate)
        var studentsArray: [SVStudent] = []
        for item in array {
            studentsArray.append(SVStudent(model: item))
        }
        
        let data: NSData = NSKeyedArchiver.archivedDataWithRootObject(studentsArray)
        let encryptedData = createCryptoData(data)
        return encryptedData
    }
    
    //MARK: -- encryption/decription
    
    class func createCryptoData(openData: NSData) -> NSData? {
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
    
    class func decryptionOfTheEncryptedData(encryptedData: NSData) -> [SVStudent] {
        
        let privPath = NSBundle.mainBundle().pathForResource("private", ofType: "pem")!
        var privString: String
        do {
            privString = try String(contentsOfFile:privPath, encoding: NSUTF8StringEncoding) as String
        } catch {
            return []
        }
        let privKey = try! rsa.privateKeyFromPEMString(privString)
        let decryptedData = try! rsa.decryptData(encryptedData, privateKey: privKey, padding: .None)
        
        let array: [SVStudent] = (NSKeyedUnarchiver.unarchiveObjectWithData(decryptedData) as? [SVStudent]) ?? []
        return array
    }
    
    
    //MARK: -- encryption of database
    
    class func getKey() -> NSData {
        
        let keychainIdentifier = "io.Realm.EncryptionExampleKey"
        let keychainIdentifierData = keychainIdentifier.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        
        var query: [NSString: AnyObject] = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: keychainIdentifierData,
            kSecAttrKeySizeInBits: 512,
            kSecReturnData: true
        ]
        
        var dataTypeRef: AnyObject?
        var status = withUnsafeMutablePointer(&dataTypeRef) { SecItemCopyMatching(query, UnsafeMutablePointer($0)) }
        if status == errSecSuccess {
            return dataTypeRef as! NSData
        }
        
        var keyData =  dataBaseKey.dataUsingEncoding(NSASCIIStringEncoding)
        if keyData?.length != 64 {
            let mutableData = (keyData?.mutableCopy()) as? NSMutableData
            mutableData?.length = 64
            keyData = mutableData?.copy() as? NSData
        }
      
        query = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: keychainIdentifierData,
            kSecAttrKeySizeInBits: 512,
            kSecValueData: keyData!
        ]
        
        status = SecItemAdd(query, nil)
        assert(status == errSecSuccess, "Failed to insert the new key in the keychain")
        
        return keyData!
    }
}

