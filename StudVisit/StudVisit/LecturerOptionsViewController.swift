//
//  LecturerOptionsViewController.swift
//  StudVisit
//
//  Created by Maxim Galayko on 5/22/16.
//  Copyright © 2016 Maxim Galayko. All rights reserved.
//

import UIKit

enum LecturerSegueType {
    case GenerateImage
    case CheckVisits
}

class LecturerOptionsViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
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
            ("Переглянути відвідування", UIImage(named: "calendar")!, .CheckVisits)
        ]
    }
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if let generateImageController = segue.destinationViewController as? GenerateImageViewController {
//            
//        }
//        if let visitsViewController = segue.destinationViewController as? StudentVisitsViewController {
//            
//        }
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
        }
    }
}