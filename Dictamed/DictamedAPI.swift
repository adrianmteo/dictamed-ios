//
//  DictamedAPI.swift
//  Dictamed
//
//  Created by Adrian Mateoaea on 25.04.2016.
//  Copyright © 2016 Adrian Mateoaea. All rights reserved.
//


import UIKit
import Alamofire
import SwiftyJSON

enum AudioLanguage: String {
    case Romana  = "ro-ro"
    case English = "en-us"
}

enum DictamedDeviceType: String {
    case Phone = "Sent from iPhone"
    case Watch = "Sent from Watch"
}

class DictamedAPI {
    
    static let sharedInstance = DictamedAPI()
    
    private let speechAPIKey = "AIzaSyA3QauQzWiq8sNp-13WZVkv5MLHoehjkrM"
    
    private let speechAPIURL = "https://www.google.com/speech-api/v2/recognize?output=json&lang=%@&key=%@"
    
    private let websiteAPIURL = "http://192.168.1.41:3000"
    
    func transcribeAudio(file: NSURL, language: AudioLanguage, callback: (String?) -> Void) {
        let url = String(format: self.speechAPIURL, language.rawValue, self.speechAPIKey)
        Alamofire.upload(.POST, url, headers: ["Content-Type": "audio/l16; rate=16000;"], file: file)
            .responseString { (response) -> Void in
                var string = response.result.value
                if let index = response.result.value?.characters.indexOf("\n") {
                    string = response.result.value?.substringFromIndex(index)
                }
                
                if let string = string, let data = string.dataUsingEncoding(NSUTF8StringEncoding) {
                    let json = JSON(data: data)
                    let text = json["result", 0, "alternative", 0, "transcript"].string
                    callback(text)
                }
        }
    }
    
    func submitAudio(file: NSURL, translation: String?, device: DictamedDeviceType, callback: (() -> Void)? = nil) {
        let url = websiteAPIURL + "/api/transcripts"
        
        let params = [
            "title": device.rawValue,
            "translation": translation ?? "..."
        ]
        
        Alamofire.request(.POST, url, parameters: params).responseJSON { (res) in
            switch res.result {
            case .Failure(let error):
                print(error)
            case .Success(let value):
                if let id = value.valueForKeyPath("data._id") as? String {
                    let uploadURL = self.websiteAPIURL + "/api/upload/" + id
                    Alamofire.upload(.POST, uploadURL,
                        multipartFormData: { (form) in
                            form.appendBodyPart(fileURL: file, name: "audio")
                    }) { (result) in
                        callback?()
                    }
                }
            }
        }
    }
    
    func getAllPosts(callback: ([AnyObject]) -> Void) {
        let url = websiteAPIURL + "/api/transcripts"
        Alamofire.request(.GET, url).responseJSON { (res) in
            switch res.result {
            case .Failure:
                callback([])
            case .Success:
                callback([])
            }
        }
    }
    
}
