//
//  MapManager.swift
//  MyPlaces
//
//  Created by MAC on 12.08.2020.
//  Copyright © 2020 Litmax. All rights reserved.
//

import UIKit
import MapKit

final class MapManager {
    
    let locationManager = CLLocationManager()
    
    private let regionInMeters = 1000.0
    private var directionsArray: [MKDirections] = []
    private var placeCoordinate: CLLocationCoordinate2D?
    
    func setupPlacemark(place: Place, mapView: MKMapView) {
        guard let location = place.location else { return }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = place.name
            annotation.subtitle = place.type
            
            guard let placemarkLocation = placemark?.location else { return }
            
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate
            
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure: () -> ()) {
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAutorization(mapView: mapView, segueIdentifier: segueIdentifier)
            closure()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Location Services are Disabled", message: "Please turn on it")
            }
        }
    }
    // Проверка авторизации приложения для использования геолокации
    func checkLocationAutorization(mapView: MKMapView, segueIdentifier: String) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if segueIdentifier == "getAddress" { showUserLocation(mapView: mapView) }
            break
        case .denied:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Access denied", message: "Error")
            }
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Access restricted", message: "Error")
            }
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("New case is available")
        }
    }
    // Фокус карты на местоположение пользователя
    func showUserLocation(mapView: MKMapView) {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    // Строим маршрут от местоположения пользователя до заведения
    func getDirections(for mapView: MKMapView, previousLocation: (CLLocation) -> ()) {
        
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location not found")
            return
        }
        
        locationManager.startUpdatingLocation()
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        guard let request = createDirectionsRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return }
        
        let directions = MKDirections(request: request)
        resetMapView(mapView: mapView, withNew: directions)
        
        directions.calculate { (responce, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let responce = responce else {
                self.showAlert(title: "Error", message: "Directions is not available")
                return
            }
            
            for route in responce.routes {
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                //let distance = String(format: "%.1f", route.distance / 1000)
                //let timeInterval = route.expectedTravelTime
                
                //print("Distance: \(distance) km")
                //print("Time: \(timeInterval) sec")
            }
        }
    }
    // Настройка запроса для расчета маршрута
    private func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
        guard let destinationCoordinate = placeCoordinate else { return nil }
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
    }
    // Сброс всех ранее построенных маршрутов перед построением нового
    private func resetMapView (mapView: MKMapView, withNew directions: MKDirections) {
        
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
        directionsArray.removeAll()
    }

    // Меняем отображаемую зону области карты в соответствии с перемещением пользователя
    func startTrackingUserLocation(for mapView: MKMapView, and location: CLLocation?, closure: (_ currentLocation: CLLocation) -> ()) {
        
        guard let location = location else {return}
        let center = getCenterLocation(for: mapView)
        
        guard center.distance(from: location) > 50 else {return}
        
        closure(center)
    }
    
    // Отображение центра отображаемой области
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        
        let latitude = mapView.centerCoordinate.latitude
        let longitute = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitute)
    }
    
    
    
    // Создание алёрта
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(okButton)
            
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
            alertWindow.rootViewController = UIViewController()
            alertWindow.windowLevel = UIWindow.Level.alert + 1
            alertWindow.makeKeyAndVisible()
            alertWindow.rootViewController?.present(alert, animated: true)
        }
        
    
    
}
