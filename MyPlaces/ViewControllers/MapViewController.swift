//
//  MapViewController.swift
//  MyPlaces
//
//  Created by MAC on 08.08.2020.
//  Copyright © 2020 Litmax. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate {
    func getAdress(_ adress: String?)
}


final class MapViewController: UIViewController {
    
    let mapManager = MapManager()
    var mapViewControllerDelegate: MapViewControllerDelegate?
    var place = Place()
    let annotationIdentifier = "annotationIdentifier"
    var incomeSegueIdentifier = ""
    var previousLocation: CLLocation? {
        didSet {
            mapManager.startTrackingUserLocation(
                for: mapView,
                and: previousLocation) { (currentLocation) in
                    
                    self.previousLocation = currentLocation
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.mapManager.showUserLocation(mapView: self.mapView)
                    }
            }
        }
    }

    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var mapPinImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var goButton: UIButton!
    
    @IBAction func closeVC() {
        dismiss(animated: true)
    }
    
    @IBAction func goButtonPressed(_ sender: Any) {
        mapManager.getDirections(for: mapView) { (location) in
            self.previousLocation = location
        }
    }
    
    
    @IBAction func centerViewInUserLocation() {
        mapManager.showUserLocation(mapView: mapView)
    }
    
    @IBAction func doneAction() {
        mapViewControllerDelegate?.getAdress(addressLabel.text)
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        mapView.delegate = self
    }
    
    private func setupMapView() {
        
        goButton.isHidden = true
        
        mapManager.checkLocationServices(mapView: mapView, segueIdentifier: incomeSegueIdentifier) {
            mapManager.locationManager.delegate = self
        }
        
        if incomeSegueIdentifier == "showPlace" {
            mapManager.setupPlacemark(place: place, mapView: mapView)
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
        }
        
        if let imageData = place.imageData {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let center = mapManager.getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        if incomeSegueIdentifier == "showPlace" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.mapManager.showUserLocation(mapView: mapView)
            }
        }
        
        geocoder.cancelGeocode()
        
        geocoder.reverseGeocodeLocation(center) { (placemarks, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            let city = placemark?.locality
            let streetName = placemark?.thoroughfare
            let buildNumber = placemark?.subThoroughfare
            
            DispatchQueue.main.async {
                
                if streetName != nil && buildNumber != nil {
                    self.addressLabel.text = "\(city!), \(streetName!), \(buildNumber!)"
                } else if streetName != nil && city != nil {
                    self.addressLabel.text = "\(city!), \(streetName!)"
                } else {
                    self.addressLabel.text = ""
                }
            }
        }
    }
    
    private func mapView(_ mapView: MKMapView, renderFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.strokeColor = .red
        
        return render
    }
    
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        mapManager.checkLocationAutorization(mapView: mapView, segueIdentifier: incomeSegueIdentifier)
    }
}
