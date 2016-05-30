
//
//  SavedPhotosViewController.swift
//  StudVisit
//
//  Created by Maxim Galayko on 5/22/16.
//  Copyright © 2016 Maxim Galayko. All rights reserved.
//

import UIKit
import ISStego
import MapKit

class SavedPhotosViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var lessonName: String!
    var userName: String!
    
    var dataSource: [SVStudentVisitModel] {
        return SVStudentVisitModel.itemsWithPredicate("lessonsName == '\(lessonName)'")
    }
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundImage()
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = lessonName
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func checkIn(sender: AnyObject) {
        presentImagePickerController()
    }
    
    @IBAction func shareVisits(sender: AnyObject) {
//        guard let data = SVStudentVisitModel.encrypedItemsWithPredicate("lessonsName == '\(lessonName)'") else {
//            presentAlertWithTitle("Помилка", message: "Неможливо підготувати дані для відпраки")
//            return
//        }
//        let students = SVStudentVisitModel.decryptionOfTheEncryptedData(data)
//        print(students.count)
        let sendDataControllerStoryboardIdentifier = "SendDataSegueIdentifier"
        performSegueWithIdentifier(sendDataControllerStoryboardIdentifier, sender: self)
    }
    
    // MARK: - Actions
    
    private func presentImagePickerController() {
        let imageController = UIImagePickerController()
        imageController.sourceType = .PhotoLibrary
        imageController.delegate = self
        presentViewController(imageController, animated: true, completion: nil)
    }
    
    private func analyzeImage(image: UIImage) {
        decodeInfoWithImage(image) { date, coordinates in
            guard let date = date, coordinates = coordinates else {
                self.presentAlertWithTitle("Помилка", message: "Неможливо проаналізувати зображення")
                return
            }
            let allowedArea = self.compareCoordinatesWithCurrent(coordinates)
            let allowedTime = self.compareTimestampWithCurrent(date)
            
            if allowedArea && allowedTime {
                SVStudentVisitModel.storeDataWithName(self.userName, date: date, lessonsName: self.lessonName, isPresent: "true")
                self.presentAlertWithTitle("Підтверджено", message: "Ваша присутність підтверджена")
                self.tableView.reloadData()
                
            } else if allowedTime == false {
                self.presentAlertWithTitle("Помилка", message: "Час підтвердження присутності вичерпано")
            } else if allowedArea == false {
                self.presentAlertWithTitle("Помилка", message: "Місце підтвердження присутності не правильне")
            } else {
                self.presentAlertWithTitle("Помилка", message: "Час і місце підтвердження присутності не правильні")
            }
        }
    }
    
    private func decodeInfoWithImage(image: UIImage, completion: (date: NSDate?, coordinates: CLLocationCoordinate2D?) -> Void) {
        ISSteganographer.dataFromImage(image) { data, error in
            let info = String(data: data, encoding: NSUTF8StringEncoding)
            
            var date: NSDate?
            var coordinates: CLLocationCoordinate2D?
            
            if let components = info?.componentsSeparatedByString(";") where components.count == 3 {
                let formatter = NSDateFormatter()
                formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
                date = formatter.dateFromString(components[0])
                
                if let latitude = Double(components[1]), let longitude = Double(components[2]) {
                    coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                completion(date: date, coordinates: coordinates)
            }
        }
    }
    
    private func compareCoordinatesWithCurrent(coordinates: CLLocationCoordinate2D) -> Bool {
        guard let currentLocation = locationManager.location else {
            return false
        }
        let distance = distanceBetweenCoordinates(coordinates, second: currentLocation.coordinate)
        return distance < 50 // meters
    }
    
    private func compareTimestampWithCurrent(date: NSDate) -> Bool {
        let allowedDate = date.dateByAddingTimeInterval(20 * 60) // 20 minutes
        let currentDate = NSDate()
        
        let isValidDate = currentDate.compare(allowedDate) == .OrderedAscending
        return isValidDate
    }
    
    
    // MARK: - Calculate distance
    
    private func distanceBetweenCoordinates(first: CLLocationCoordinate2D, second: CLLocationCoordinate2D) -> Double {
        let r: Double = 6371 // earth radius
        let dLat = degreesToRadians(second.latitude - first.latitude)
        let dLon = degreesToRadians(second.longitude - first.longitude)
        let a = sin(dLat / 2.0) * sin(dLat / 2.0)
            + cos(degreesToRadians(first.latitude)) * cos(degreesToRadians(second.latitude))
            * sin(dLon / 2.0) * sin(dLon / 2.0)
        let c = 2.0 * atan2(sqrt(a), sqrt(1 - a))
        let distance = r * c * 1000 // in meters
        
        return distance
    }
    
    private func degreesToRadians(degrees: Double) -> Double {
        return degrees * (M_PI / 180.0)
    }
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let controller = segue.destinationViewController as? SendDataViewController {
            controller.lessonName = lessonName
            controller.studentName = userName
        }
    }
}

extension SavedPhotosViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(LessonTableViewCell.reuseIdentifier, forIndexPath: indexPath) as! LessonTableViewCell
        
        let visit = dataSource[indexPath.row]
        if let date = visit.date {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
            
            cell.titleLabel.text = dateFormatter.stringFromDate(date)
        }
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
            let visit = dataSource[indexPath.row]
            let state = SVStudentVisitModel.removeItem(visit)
            if state {
                tableView.reloadData()
            }
        }
    }
}

extension SavedPhotosViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        analyzeImage(image)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}
