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

    //MARK: -- store/get data methods
    
    func storeDataWithName(studentName: String, date: NSDate, lessonsName: String, isPresent: String) -> Void {
        
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
        } catch {}
    }
    
    func getItemFromDataBaseWithPredicate(predicate: String) -> NSData?  {
        var encryptedData: NSData?
        
        let config = Realm.Configuration(encryptionKey: getKey())
        do {
            let realm = try Realm(configuration: config)
            let visitsData = realm.objects(SVStudentVisitModel).filter(predicate)
            var array:[SVStudentVisitModel] = []
            for item in visitsData {
                array.append(item)
            }
            
            let data: NSData = NSKeyedArchiver.archivedDataWithRootObject(array)
            encryptedData = createCryptoData(data)
        } catch {}
        
        
        return encryptedData
    }
    
    //MARK: -- encryption/decription
    
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
    
    
    //MARK: -- encryption of database
    
    func getKey() -> NSData {
        
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
        
        let keyData = NSMutableData(length: 64)!
        let result = SecRandomCopyBytes(kSecRandomDefault, 64, UnsafeMutablePointer<UInt8>(keyData.mutableBytes))
        assert(result == 0, "failed")
        
        query = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: keychainIdentifierData,
            kSecAttrKeySizeInBits: 512,
            kSecValueData: keyData
        ]
        
        status = SecItemAdd(query, nil)
        assert(status == errSecSuccess, "Failed to insert the new key in the keychain")
        
        return keyData
    }
}
