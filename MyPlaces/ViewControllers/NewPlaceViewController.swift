//
//  NewPlaceViewController.swift
//  MyPlaces
//
//  Created by MAC on 29.07.2020.
//  Copyright © 2020 Litmax. All rights reserved.
//

import UIKit
import Cosmos

class NewPlaceViewController: UITableViewController {
    
    var currentPlace: Place!
    var imageIsChanged = false
    var currentRating = 0.0

    @IBOutlet weak var imageOfPlace: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var namePlace: UITextField!
    @IBOutlet weak var locationPlace: UITextField!
    @IBOutlet weak var typePlace: UITextField!
    @IBOutlet weak var cosmosView: CosmosView!
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: CGRect(x: 0,
                                                         y: 0,
                                                         width: tableView.frame.size.width,
                                                         height: 1))
        saveButton.isEnabled = false
        namePlace.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        setupEditScreen()
        
        cosmosView.didTouchCosmos = { rating in
            self.currentRating = rating
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            let cameraIcon = UIImage.init(systemName: "camera")
            let photoIcon = UIImage.init(systemName: "photo")
            //let exemple = ImageLiteral - for pick from menu

            
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseImagePicker(source: .camera)
            }
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                self.chooseImagePicker(source: .photoLibrary)
            }
            photo.setValue(photoIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            
            present(actionSheet, animated: true)
        } else {
            view.endEditing(true)
        }
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard
            let identifier = segue.identifier,
            let mapVC = segue.destination as? MapViewController
            else { return }
        
        mapVC.incomeSegueIdentifier = identifier
        mapVC.mapViewControllerDelegate = self
        
        if identifier == "showPlace" {

            mapVC.place.name = namePlace.text!
            mapVC.place.location = locationPlace.text
            mapVC.place.type = typePlace.text
            mapVC.place.imageData = imageOfPlace.image?.pngData()
            
        } else { return }
    }
    
    func savePlace () {

        let image = imageIsChanged ? imageOfPlace.image : #imageLiteral(resourceName: "logo 13")
        
        let imageData = image?.pngData()
        
        let newPlace = Place(name: namePlace.text!,
                             location: locationPlace.text,
                             type: typePlace.text,
                             imageData: imageData,
                             rating: currentRating)
        
        if currentPlace != nil {
            try! realm.write {
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.type = newPlace.type
                currentPlace?.imageData = newPlace.imageData
                currentPlace?.rating = newPlace.rating
                }
            } else {
                StorageManager.saveObject(newPlace)
            }
        }
    
    private func setupEditScreen() {
        if currentPlace != nil {
            
            setupNavigatorBar()
            imageIsChanged = true
            
            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else {return}
            
            imageOfPlace.image = image
            imageOfPlace.contentMode = .scaleAspectFill
            namePlace.text = currentPlace?.name
            locationPlace.text = currentPlace?.location
            typePlace.text = currentPlace?.type
            cosmosView.rating = currentPlace.rating
        }
    }
    
    private func setupNavigatorBar() {
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        navigationItem.leftBarButtonItem = nil
        title = currentPlace?.name
        saveButton.isEnabled = true
    }
}

extension NewPlaceViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func textFieldChanged() {
        
        if namePlace.text?.isEmpty == false {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
}

extension NewPlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            
            present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageOfPlace.image = info[.editedImage] as? UIImage
        imageOfPlace.contentMode = .scaleAspectFill
        imageOfPlace.clipsToBounds = true
        
        imageIsChanged = true
        
        dismiss(animated: true)
    }
}

extension NewPlaceViewController: MapViewControllerDelegate {
    func getAdress(_ address: String?) {
        locationPlace.text = address
    }
}
