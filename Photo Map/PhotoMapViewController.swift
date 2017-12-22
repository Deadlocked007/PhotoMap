//
//  PhotoMapViewController.swift
//  Photo Map
//
//  Created by Nicholas Aiwazian on 10/15/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class PhotoMapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var cameraButton: UIButton!
    
    var currentImage: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //one degree of latitude is approximately 111 kilometers (69 miles) at all times.
        cameraButton.layer.cornerRadius = cameraButton.frame.height / 2.0
        
        let sfRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.783333, -122.416667),
                                              MKCoordinateSpanMake(0.1, 0.1))
        mapView.setRegion(sfRegion, animated: false)
        mapView.delegate = self
    }
    
    @IBAction func onCamera(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        guard let id = segue.identifier else {
            return
        }
        
        switch id {
        case "tagSegue":
            let destination = segue.destination as! LocationsViewController
            destination.delegate = self
        case "fullImageSegue":
            let destination = segue.destination as! FullImageViewController
            destination.image = sender as! UIImage
        default:
            return
        }
    }
    

}

extension PhotoMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "myAnnotationView"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
        if (annotationView == nil) {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            annotationView!.canShowCallout = true
            annotationView!.leftCalloutAccessoryView = UIImageView(frame: CGRect(x:0, y:0, width: 50, height:50))
            annotationView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        let resizeRenderImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        resizeRenderImageView.layer.borderColor = UIColor.white.cgColor
        resizeRenderImageView.layer.borderWidth = 3.0
        resizeRenderImageView.contentMode = UIViewContentMode.scaleAspectFill
        resizeRenderImageView.image = (annotation as? PhotoAnnotation)?.photo
        
        UIGraphicsBeginImageContext(resizeRenderImageView.frame.size)
        resizeRenderImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        
        let imageView = annotationView?.leftCalloutAccessoryView as! UIImageView
        imageView.image = thumbnail
        
        annotationView?.image = thumbnail
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    
        let annotation = view.annotation as! PhotoAnnotation
        
        performSegue(withIdentifier: "fullImageSegue", sender: annotation.photo)
    }
}

extension PhotoMapViewController: LocationsViewControllerDelegate {
    func locationsPickedLocation(controller: LocationsViewController, latitude: NSNumber, longitude: NSNumber) {
        let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        
        let annotation = PhotoAnnotation()
        annotation.coordinate = coordinate
        annotation.photo = currentImage
        mapView.addAnnotation(annotation)
    }
    
    
}
extension PhotoMapViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            picker.dismiss(animated: true, completion: {
                self.currentImage = image
                self.performSegue(withIdentifier: "tagSegue", sender: nil)
            })
        }
    }
}


