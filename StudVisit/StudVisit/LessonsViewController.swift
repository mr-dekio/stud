//
//  ViewController.swift
//  StudVisit
//
//  Created by Maxim Galayko on 5/17/16.
//  Copyright © 2016 Maxim Galayko. All rights reserved.
//

import UIKit

class LessonsViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var userName: String!
    private var folders: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTableView()
        setBackgroundImage()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        folders = NSFileManager.foldersAtUserDirectory(userName)
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func prepareTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - Actions

    @IBAction func addFolder(sender: AnyObject) {
        presentFolderNameDialog { name in
            guard let name = name where name != "" else {
                self.presentAlertWithTitle("Назва відсутня", message: "Неможливо створити предмет без назви")
                return
            }
            if self.folders.contains(name) {
                self.presentAlertWithTitle("", message: "Предмет вже існує")
            } else {
                if NSFileManager.createUserDirectoryFolderWithName(name, forUserName: self.userName) {
                    self.folders.append(name)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
    private func presentFolderNameDialog(completion: (name: String?) -> Void) {
        let alert = UIAlertController(title: "Додати предмет", message: "Введіть назву предмету", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler(nil)
        alert.addAction(UIAlertAction(title: "Підтвердити", style: .Default) { action in
            let folderName = alert.textFields?.first?.text
            completion(name: folderName)
        })
        alert.addAction(UIAlertAction(title: "Відміна", style: .Default, handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let photosController = segue.destinationViewController as? SavedPhotosViewController {
            let name = folders[tableView.indexPathForSelectedRow!.row]
            photosController.lessonName = name
            photosController.userName = userName
        }
    }
}

extension LessonsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folders.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(LessonTableViewCell.reuseIdentifier, forIndexPath: indexPath) as! LessonTableViewCell
        
        cell.titleLabel?.text = folders[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            NSFileManager.removeUserDirectoryFolderWithName(userName, subfolder: folders[indexPath.row])
            folders.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
}

