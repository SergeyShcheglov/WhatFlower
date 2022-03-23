//
//  WikipediaManager.swift
//  WhatFlower
//
//  Created by Sergey Shcheglov on 28.12.2021.
//

import Foundation


protocol WikipediaManagerDelegate {
    func didUpdateFlowerInfo(_ wikipediaManager: WikipediaManager, wikipedia: WikipediaModel)
    func didFailWithError(error: Error)
}
struct WikipediaManager {
    let wikiURL = "https://en.wikipedia.org/api/rest_v1/page/mobile-sections/"
    var flowerNameManager: String = ""
    
    var delegate: WikipediaManagerDelegate
        
    func fetchFlower() {
        let urlString = "\(wikiURL)/\(flowerNameManager)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        
        //1. create url
        if let url = URL(string: urlString) {
            
            //2.create url session
            let session = URLSession(configuration: .default)
            
            
            //3. give the session task
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let wikipediaDefinition = self.parseJSON(safeData) {
                        self.delegate.didUpdateFlowerInfo(self, wikipedia: wikipediaDefinition)
                    }
                }
            }
            
            //start the task
            task.resume()
        }
        
    }
    
    func parseJSON(_ wikipediaData: Data) -> WikipediaModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WikipediaData.self, from: wikipediaData)
            let descriptions = decodedData.lead.sections.text
            
            print(descriptions)
        } catch {
            delegate.didFailWithError(error: error)
            return nil
        }
    }
    
}
