//
//  ReceiveDataViewController.swift
//  StudVisit
//
//  Created by Maxim Galayko on 5/30/16.
//  Copyright © 2016 Maxim Galayko. All rights reserved.
//

import UIKit
import MultipeerConnectivity

enum SendDataType {
    case Visits
}

class SendDataViewController: UIViewController {
    
    var studentName: String!
    
    var lessonName: String!
    
    let manager = MPCManagerProvider.sharedManager
    
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        updateDependencies()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Dependencies
    
    func updateDependencies() {
        tableView.dataSource = self
        tableView.delegate = self
        
        manager.delegate = self
        manager.browser.startBrowsingForPeers()
    }
    
    // MARK: - Send data
    
    func sendStudentVisitingInfo() {
        guard let data = SVStudentVisitModel.encrypedItemsWithPredicate("lessonsName == '\(lessonName)'") else {
            presentAlertWithTitle("Помилка", message: "Неможливо підготувати дані для відпраки")
            return
        }
        let status = manager.sendData(data, toPeer: manager.session.connectedPeers.first!)
        if status {
            presentAlertWithTitle("Успішно", message: "Дані відправлені")
        } else {
            presentAlertWithTitle("Помилка", message: "Помилка відправлення даних")
        }
    }
}

extension SendDataViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return manager.foundPeers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(LessonTableViewCell.reuseIdentifier, forIndexPath: indexPath) as! LessonTableViewCell
        
        cell.titleLabel.text = manager.foundPeers[indexPath.row].displayName
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedPeer = manager.foundPeers[indexPath.row] as MCPeerID
        
        manager.browser.invitePeer(selectedPeer, toSession: manager.session, withContext: nil, timeout: 20)
    }
}

extension SendDataViewController: MPCManagerDelegate {
    
    func foundPeer() {
        tableView.reloadData()
    }
    
    func lostPeer() {
        tableView.reloadData()
    }
    
    func invitationWasReceived(fromPeer: String) {
    }
    
    func connectedWithPeer(peerID: MCPeerID) {
        dispatch_async(dispatch_get_main_queue()) {
//            let alert = UIAlertController(title: "З'єднання", message: "З'єднання встановлено", preferredStyle: .Alert)
//            alert.addAction(UIAlertAction(title: "Гаразд", style: .Default) { action in
                self.sendStudentVisitingInfo()
//            })
//            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}