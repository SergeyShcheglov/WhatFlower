//
//  ViewController.swift
//  WhatFlower
//
//  Created by Sergey Shcheglov on 16.12.2021.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var flowerInfoLabel: UILabel!
    
    let imagePicker = UIImagePickerController()
    var flowerName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        imagePicker.cameraFlashMode = .off
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickerImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView?.image = userPickerImage
            
            guard let ciImage = CIImage(image: userPickerImage) else {
                fatalError("Cannot convert photo to CIImage")
            }
            detect(flowerImage: ciImage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(flowerImage: CIImage) {
        guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else {
            fatalError("Loading coreML Model failed")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("model failed to process image")
            }
        
        if let firstResult = results.first {
            self.flowerName = firstResult.identifier
            
            self.navigationItem.title = self.flowerName.capitalized
            flowerInfoLabel.text = WikipediaManager()
        }
        }
        
        let handler = VNImageRequestHandler(ciImage: flowerImage)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
        
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
}

//MARK: - WikipediaManagerDelegate

extension ViewController: WikipediaManagerDelegate {
    func didUpdateFlowerInfo(_ wikipediaManager: WikipediaManager, wikipedia: WikipediaModel) {
        DispatchQueue.main.async {
            self.flowerInfoLabel.text = wikipedia.definition
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}

