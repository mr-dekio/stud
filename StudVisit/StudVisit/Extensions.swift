//
//  Extensions.swift
//  StudVisit
//
//  Created by Maxim Galayko on 5/18/16.
//  Copyright © 2016 Maxim Galayko. All rights reserved.
//

import UIKit

extension NSFileManager {
    class func createUserDirectoryFolderWithName(name: String, forUserName userName: String?) -> Bool {
        var directory = userDirectoryPath()
        if let userName = userName {
            directory += "/\(userName)"
        }
        directory += "/\(name)"
        do {
            try NSFileManager.defaultManager().createDirectoryAtPath(directory, withIntermediateDirectories: true, attributes: nil)
            return true
        } catch {
            print("error creating directory")
            return false
        }
    }
    
    class func removeUserDirectoryFolderWithName(name: String, subfolder: String?) -> Bool {
        var directory = userDirectoryPath()
        directory += "/\(name)"
        if let subfolder = subfolder {
            directory += "/\(subfolder)"
        }
        do {
            try NSFileManager.defaultManager().removeItemAtPath(directory)
            return true
        } catch {
            print("error removing directory")
            return false
        }
    }
    
    class func userDirectoryPath() -> String {
        return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
    }
    
    class func foldersAtUserDirectory(userName: String) -> [String] {
        var directory = userDirectoryPath()
        directory += "/\(userName)"
        var folders = (try? NSFileManager.defaultManager().contentsOfDirectoryAtPath(directory)) ?? []
        if let index = folders.indexOf(".DS_Store") {
            folders.removeAtIndex(index)
        }
        return folders
    }
}

extension UIViewController {
    func presentAlertWithTitle(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Гаразд", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func setBackgroundImage() {
        view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
    }
}

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        
        get {
            return UIColor(CGColor: self.layer.borderColor!)
        }
        set {
            self.layer.borderColor = newValue?.CGColor
        }
    }
}