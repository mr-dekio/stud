//
//  GenerateImageViewController.swift
//  StudVisit
//
//  Created by Maxim Galayko on 5/22/16.
//  Copyright © 2016 Maxim Galayko. All rights reserved.
//

import UIKit
import MapKit
import ISStego
import AssetsLibrary

class GenerateImageViewController: UIViewController {
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        return manager
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func shareImage(sender: AnyObject) {
        buildImage { image in
            if let image = image {
                self.presentSharingOptionsWithImage(image)
            }
        }
    }

    @IBAction func generateImage(sender: AnyObject) {
        (view as! DrawingView).shouldRedraw = true
        view.setNeedsDisplay()
    }
    
    @IBAction func saveImage(sender: AnyObject) {
        buildImage { image in
            if let image = image {
                let data = UIImagePNGRepresentation(image)
                let library = ALAssetsLibrary()
                library.writeImageDataToSavedPhotosAlbum(data, metadata: nil, completionBlock: nil)
            }
        }
    }
    
    
    // MARK: - Actions
    
    private func buildImage(completion: (image: UIImage?) -> Void) {
        guard let image = receiveImageFromView(view) else {
            presentAlertWithTitle("Помилка", message: "Неможливо зберегти зображення")
            return
        }
        guard let location = locationManager.location else {
            presentAlertWithTitle("Помилка", message: "Неможливо отримати ваші координати")
            return
        }
        let date = NSDate()
        
        subscribeImage(image, withDate: date, coordinates: location.coordinate) { resultImage in
            guard let resultImage = resultImage else {
                self.presentAlertWithTitle("Помилка", message: "Неможливо підготувати зображення")
                return
            }
            completion(image: resultImage)
        }
    }
    
    private func receiveImageFromView(view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0)
        view.layer.drawInContext(UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    private func subscribeImage(image: UIImage, withDate date: NSDate, coordinates: CLLocationCoordinate2D, completion: (image: UIImage?) -> Void) {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        let dateInfo = dateFormatter.stringFromDate(date)
        let hiddenInfo = "\(dateInfo);\(coordinates.latitude);\(coordinates.longitude)"
        
        ISSteganographer.hideData(hiddenInfo, withImage: image) { subscribedImage, error in
            dispatch_async(dispatch_get_main_queue()) {
                completion(image: subscribedImage as? UIImage)
            }
        }
    }
    
    private func presentSharingOptionsWithImage(image: UIImage) {
        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        presentViewController(activityController, animated: true, completion: nil)
    }
}
