//
//  ViewController.swift
//  Travel Map Book
//
//  Created by MAC-DIN-002 on 22/05/2019.
//  Copyright © 2019 MAC-DIN-002. All rights reserved.
//

import UIKit
import MapKit
import CoreData
/*pour importer CoreLocation il faut aller dans Travel Map Book à la racine puis dans Build phasses puis dans link binari with libraries et ajouter coreLocation.framework*/
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var commentText: UITextField!
    var chosenLongitude : Double = 0
    var chosenLatitude : Double = 0
    
    var locationManager = CLLocationManager()
    
    var transmittedTitle = ""
    var transmittedSubtitle = ""
    var transmittedLatitude : Double = 0
    var transmittedLongitude : Double = 0
    
    var requestCLLocation = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*mapView and*/
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        /*on demande l'autorisation à l'utilisateur de récupérer sa localisation quand l'appli est utilisée (ne pas oublier d'ajouter "Privacy - Location When In Use Usage Description" dans info.plist)*/
        locationManager.requestWhenInUseAuthorization()
        /*on commence à récupérer puis mettre à jour la localisation*/
        locationManager.startUpdatingLocation()
        
        /*on créé la reconnaissance de geste sur la map pour que quand l'utilisateur maintient son doigt plus de 3 sec sur la map on lance chooseLocation*/
        let recogniser = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.chooseLocation(gestureRecognizer:)))
        recogniser.minimumPressDuration = 3
        mapView.addGestureRecognizer(recogniser)
        
        
        if self.transmittedTitle != "" {
            let annotation = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: self.transmittedLatitude, longitude: self.transmittedLongitude)
            annotation.coordinate = coordinate
            annotation.title = self.transmittedTitle
            annotation.subtitle = self.transmittedSubtitle
            self.mapView.addAnnotation(annotation)
            self.nameText.text = transmittedTitle
            self.commentText.text = transmittedSubtitle
            
        }
        
    }
    
    /*fonction qui est appellée à chaque fois que la localisation est mise à jour*/
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        /*on récupère les données de localisation de l'utilisateur */
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        /*span est le zoom*/
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        /*on assemble la localisation et le zoom*/
        let region = MKCoordinateRegion(center: location, span: span)
        /*On affiche la région */
        self.mapView.setRegion(region, animated: true)
    }

    @objc func chooseLocation(gestureRecognizer : UILongPressGestureRecognizer){
        
        if gestureRecognizer.state == UIGestureRecognizer.State.began{
            let touchedPoint = gestureRecognizer.location(in:  self.mapView)
            /*convertit l'endroit ou l'utilisateur à appuyer sur la carte en coordonées geographique*/
            let chosenCoordinates = self.mapView.convert(touchedPoint, toCoordinateFrom : self.mapView)
            
            self.chosenLatitude = chosenCoordinates.latitude
            self.chosenLongitude = chosenCoordinates.longitude
            
            /*on créé une annotation à mettre sur la carte là où l'utilisateur à appuyer 3 sec*/
            let annotation = MKPointAnnotation()
            annotation.coordinate = chosenCoordinates
            annotation.title = nameText.text
            annotation.subtitle = commentText.text
            /*on affiche l'annotation*/
            self.mapView.addAnnotation(annotation)
        }
    }
    /*customise annotation*/
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil
        }
        let reuseId = "myAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            /*on ajoute un bouton a notre annotation*/
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.pinTintColor = UIColor.red
            
            let button = UIButton(type: .detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
        }else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    /*OnClick du bouton de l'annotation*/
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if (transmittedLatitude != 0 && transmittedLongitude != 0) {
            self.requestCLLocation = CLLocation(latitude: transmittedLatitude, longitude: transmittedLongitude)
        }
        /*on ajoute une navigation a la carte*/
        CLGeocoder().reverseGeocodeLocation(requestCLLocation) { (placemarks, error) in
            if let placemark = placemarks {
                if placemark.count > 0{
                    let newPlaceMark = MKPlacemark(placemark: placemark[0])
                    let item = MKMapItem(placemark: newPlaceMark)
                    item.name = self.transmittedTitle
                    /*on dit que la navigation est faite pour un véhicule avec MKLaunchOptionsDirectionsModeDriving*/
                    let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                    item.openInMaps(launchOptions: launchOptions)
                }
            }
        }
        
    }
    
    
    
    
    @IBAction func SavePlaceBtnClicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newLocation = NSEntityDescription.insertNewObject(forEntityName: "Locations", into: context)
        newLocation.setValue(nameText.text, forKey: "title")
        newLocation.setValue(commentText.text, forKey: "subtitle")
        newLocation.setValue(self.chosenLatitude, forKey: "latitude")
        newLocation.setValue(self.chosenLongitude, forKey: "longitude")
        
        do{
            try context.save()
            print("save succed")
        }catch{
            print("save failed")
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newLocationCreated"), object: nil)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
}

