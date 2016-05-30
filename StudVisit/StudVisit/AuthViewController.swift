//
//  AuthViewController.swift
//  StudVisit
//
//  Created by Maxim Galayko on 5/17/16.
//  Copyright © 2016 Maxim Galayko. All rights reserved.
//

import UIKit

class AuthViewController: UIViewController {

    @IBOutlet var roleSegmentControl: UISegmentedControl!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var confirmButton: UIButton!
    @IBOutlet var tableView: UITableView!
    
    private let lessonsSegueIdentifier = "AuthToUserGroupsSegueIdentifier"
    private let lecturerOptionsSegueIdentifier = "LecturerOptionsSegueIdentifier"
    
    private let lastUserName = "kLastUserName"
    private let lastUserRole = "kLastUserRole"
    
    private var users: [(name: String, role: Int)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateAppearance()
        
        nameTextField.delegate = self
        prepareTableView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateUsersList()
        tableView.reloadData()
        
        
//    //Test case storage
//       let studVisit = SVStudentVisitModel()
//       let date = NSDate()
//        
//       SVStudentVisitModel.storeDataWithName("Pavlo", date: date, lessonsName: "Matem", isPresent: "true")
//       SVStudentVisitModel.decryptionOfTheEncryptedData(SVStudentVisitModel.getItemFromDataBaseWithPredicate("studentName == 'Pavlo'")!)!
        
       
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func updateAppearance() {
        setBackgroundImage()
        
        roleSegmentControl.tintColor = UIColor.whiteColor()
    }
    
    // MARK: - Dependencies
    
    private func prepareTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
    }
    
    // MARK: - Actions
    
    @IBAction func authorizeUser(sender: AnyObject) {
        guard let userName = nameTextField.text where userName != "" else {
            presentAlertWithTitle("Пусте поле", message: "Введіть ім'я та прізвище")
            return
        }
        
        let userRole = roleSegmentControl.selectedSegmentIndex
        let matches = users.filter { name, role in
            return name == userName && role == userRole
        }
        
        if matches.count == 0 {
            if let savedUserName = users.first {
                NSFileManager.removeUserDirectoryFolderWithName(savedUserName.name, subfolder: nil)
            }
            SVStudentVisitModel.clearDataBase()
            createNewUserWithCredentials(userName, role: userRole)
            updateUsersList()
        }
        presentNextController(userRole)
    }
    
    private func createNewUserWithCredentials(name: String, role: Int) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(name, forKey: lastUserName)
        defaults.setObject(role, forKey: lastUserRole)
        defaults.synchronize()
        
        NSFileManager.createUserDirectoryFolderWithName(name, forUserName: nil)
    }

    private func presentNextController(role: Int) {
        if role == 0 { // student
            performSegueWithIdentifier(lessonsSegueIdentifier, sender: self)
        } else {
            performSegueWithIdentifier(lecturerOptionsSegueIdentifier, sender: self)
        }
    }
    
    private func updateUsersList() {
        users.removeAll()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let name = defaults.stringForKey(lastUserName) {
            let role = defaults.integerForKey(lastUserRole)
            users.append((name: name, role: role))
        }
    }
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let lessonsController = segue.destinationViewController as? LessonsViewController {
            lessonsController.userName = users.first?.name ?? "unknown"
        }
    }
}


extension AuthViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(UserTableViewCell.reuseIdentifier, forIndexPath: indexPath) as! UserTableViewCell
        
        let user = users[indexPath.row]
        cell.clear()
        cell.fillWithUserName(user.name, role: user.role)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let role = users[indexPath.row].role
        presentNextController(role)
    }
}

extension AuthViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}