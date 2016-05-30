//
//  LecturerOptionsViewController.swift
//  StudVisit
//
//  Created by Maxim Galayko on 5/22/16.
//  Copyright © 2016 Maxim Galayko. All rights reserved.
//

import UIKit
import MultipeerConnectivity

enum LecturerSegueType {
    case GenerateImage
    case CheckVisits
    case ReceiveData
}

class LecturerOptionsViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var isRecevingData = false
    
    private var dataSource: [(title: String, image: UIImage?, type: LecturerSegueType)]!
    
    private let generateImageSegueIdentifier = "GenerateImageSegueIdentifier"
    private let studentVisitsSegueIdentifier = "StudentVisitsSegueIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareDataSource()
        prepareTableView()
        setBackgroundImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func prepareTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func prepareDataSource() {
        dataSource = [
            ("Згенерувати зображення", UIImage(named: "settings")!, .GenerateImage),
            ("Переглянути відвідування", UIImage(named: "calendar")!, .CheckVisits),
            ("Отримати інформацію", UIImage(named: "share")!, .ReceiveData)
        ]
    }
    
    // MARK: - Receive info
    
    func startWaitingForInfo() {
        MPCManagerProvider.sharedManager.delegate = self
        MPCManagerProvider.sharedManager.advertiser.startAdvertisingPeer()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(receiveData(_:)), name: MPCManagerProvider.sharedManager.receiveDataNotification, object: nil)
        
        isRecevingData = true
        
        for (index, item) in dataSource.enumerate() {
            if item.type == .ReceiveData {
                dataSource[index].title = "Зупинити передачу даних"
            }
        }
        tableView.reloadData()
    }
    
    func stopWaitingForInfo() {
        MPCManagerProvider.sharedManager.advertiser.stopAdvertisingPeer()
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        isRecevingData = false
        
        for (index, item) in dataSource.enumerate() {
            if item.type == .ReceiveData {
                dataSource[index].title = "Отримати інформацію"
            }
        }
        tableView.reloadData()
    }
    
    func receiveData(notification: NSNotification) {
        let receivedDataDictionary = notification.object as! Dictionary<String, AnyObject>
        
//        let fromPeer = receivedDataDictionary["fromPeer"] as! MCPeerID
        
        guard let data = receivedDataDictionary["data"] as? NSData else {
            presentAlertWithTitle("Помилка", message: "Неможливо обробити дані")
            return
        }
        let visits = SVStudentVisitModel.decryptionOfTheEncryptedData(data)
        
        presentAlertWithTitle("дані", message: "\(visits.count)")
        
        // unarchive via alrogithms
        // save to data base
        
        
        print("Some data received")
//        MPCManagerProvider.sharedManager.session.disconnect()
    }
}


extension LecturerOptionsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(LecturerOptionsTableViewCell.reuseIdentifier, forIndexPath: indexPath) as! LecturerOptionsTableViewCell
        
        let record = dataSource[indexPath.row]
        
        cell.titleLabel.text = record.title
        cell.iconView.image = record.image
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch dataSource[indexPath.row].type {
        case .GenerateImage:
            performSegueWithIdentifier(generateImageSegueIdentifier, sender: self)
        case .CheckVisits:
            performSegueWithIdentifier(studentVisitsSegueIdentifier, sender: self)
        case .ReceiveData:
            if isRecevingData {
                stopWaitingForInfo()
            } else {
                startWaitingForInfo()
            }
        }
    }
}

extension LecturerOptionsViewController: MPCManagerDelegate {
    func foundPeer() {
    }
    
    func lostPeer() {
    }
    
    func invitationWasReceived(fromPeer: String) {
//        let alert = UIAlertController(title: "", message: "\(fromPeer) хоче передати дані", preferredStyle: UIAlertControllerStyle.Alert)
//        
//        let acceptAction = UIAlertAction(title: "Прийняти", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            MPCManagerProvider.sharedManager.invitationHandler(true, MPCManagerProvider.sharedManager.session)
//        }
        
//        let declineAction = UIAlertAction(title: "Відхилити", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
//            MPCManagerProvider.sharedManager.invitationHandler(false, MPCManagerProvider.sharedManager.session)
//        }
//        
//        alert.addAction(acceptAction)
//        alert.addAction(declineAction)
//        
//        dispatch_async(dispatch_get_main_queue()) {
//            self.presentViewController(alert, animated: true, completion: nil)
//        }
    }
    
    func connectedWithPeer(peerID: MCPeerID) {
//        dispatch_async(dispatch_get_main_queue()) {
//            self.presentAlertWithTitle("З'єднання", message: "З'єднання встановлено")
//        }
    }
}