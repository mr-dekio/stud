
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
    
    var lessonName: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundImage()
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
                // create sign
            } else if allowedTime == false {
                self.presentAlertWithTitle("Помилка", message: "Час підтвердження присутності вичерпано")
            } else if allowedArea == false {
                
            } else {
                
            }
            
            print(date)
            print(coordinates)
        }
    }
    
    private func decodeInfoWithImage(image: UIImage, completion: (date: NSDate?, coordinates: CLLocationCoordinate2D?) -> Void) {
        ISSteganographer.dataFromImage(image) { data, error in
            print("fetched")
            let info = String(data: data, encoding: NSUTF8StringEncoding)
            
            var date: NSDate?
            var coordinates: CLLocationCoordinate2D?
            
            if let components = info?.componentsSeparatedByString(" ") where components.count == 3 {
                let formatter = NSDateFormatter()
                formatter.dateFormat = "HH:mm:ss"
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
        return true
    }
    
    private func compareTimestampWithCurrent(date: NSDate) -> Bool {
        return true
    }
}

extension SavedPhotosViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

extension SavedPhotosViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
//        ISSteganographer.dataFromImage(image) { data, error in
//            let info = String(data: data, encoding: NSUTF8StringEncoding)
//            print(info)
//        }
        picker.dismissViewControllerAnimated(true, completion: nil)
        analyzeImage(image)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}
