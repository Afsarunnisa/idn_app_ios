//
//  MediaApi.swift
//  IOSStarter
//
//  Created by afsarunnisa on 1/27/16.
//  Copyright (c) 2016 NBosTech. All rights reserved.
//

import Foundation
import Alamofire

@objc public protocol getMediaApiResponseDelegate {
    
    optional func handleMedia(mediaEntity:MediaApiModel)
    
    optional func handleMessages(messageCodeEntity: MessagesApiModel)
    optional func handleValidationErrors(messageCodeEntityArray: NSArray) // multiple MessagesRespApiModel - 404(Validation errors)
    optional func handleRefreshToken(JSON : AnyObject) // multiple MessagesRespApiModel - 404(Validation errors)
    
}


public class MediaApi {
    
    public var delegate: getMediaApiResponseDelegate?
    var apiUrl : String = "api/media/v0/"
    
    var mediaUrl : String = "media"
    
    public init() {
        
    }
    
    public func getMedia(){
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let userID = defaults.stringForKey("user_id")
        
        let requestUrl =  "\(WAVELABS_HOST_URL)\(apiUrl)\(mediaUrl)?id=\(userID!)&mediafor=profile"
        let token: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("access_token")!
        
        Alamofire.request(.GET, requestUrl, parameters: nil, encoding:.JSON, headers : ["Authorization" : "Bearer \(token)"]).responseJSON
            { response in switch response.result {
            case .Success(let JSON):
                let jsonResp = JSON as! NSDictionary
                
                if(response.response?.statusCode == 200){
                    let mediaApiEntity : MediaApiModel = Communicator.respMediaFromJson(jsonResp)
                    self.delegate!.handleMedia!(mediaApiEntity)
                }else if(response.response?.statusCode == 400){
                    self.validationErrorsCodes(jsonResp)
                }else{
                    self.messagesErrorsCodes(jsonResp)
                }
                
            case .Failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    
    
    public func uploadMedia(mediaFor : NSString, imgName: NSString,userID : NSString){
        let requestUrl = "\(WAVELABS_HOST_URL)\(apiUrl)\(mediaUrl)"
        
        let token: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("access_token")!
        
        let nsDocumentDirectory = NSSearchPathDirectory.DocumentDirectory
        let nsUserDomainMask    = NSSearchPathDomainMask.UserDomainMask
        
        var fileName : String = ""
        var storePath : String = ""
        var imageData : NSData = NSData()
        
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        if let dirPath = paths.first {
            let imagesDirectory = (dirPath as NSString).stringByAppendingPathComponent("Images")
            
            fileName  =  NSString(format:"%@.png", userID) as String
            storePath = (imagesDirectory as NSString).stringByAppendingPathComponent(fileName)
            imageData = UIImageJPEGRepresentation(UIImage(contentsOfFile: storePath)!, 1)!
        }
        
        
        let key = "id"
        let value = userID
        
        let key1 = "mediafor"
        let value1 = mediaFor
        
        let filename = "file"
        
        
        Alamofire.upload(
            .POST,
            requestUrl,
            headers : ["Authorization" : "Bearer \(token)"],
            multipartFormData: { multipartFormData in
                multipartFormData.appendBodyPart(data: (value.dataUsingEncoding(NSUTF8StringEncoding)!), name: key)
                multipartFormData.appendBodyPart(data: (value1.dataUsingEncoding(NSUTF8StringEncoding)!), name: key1)
                multipartFormData.appendBodyPart(data: imageData, name: "\(filename)",fileName: imgName as String,mimeType: "image/png")
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { response in switch response.result {
                    case .Success(let JSON):
                        print("Success with JSON: \(JSON)")
                        
                        let jsonResp = JSON as! NSDictionary
                        
                        if(response.response?.statusCode == 200){
                            let messageCodeEntity : MessagesApiModel = Communicator.respMessageCodesFromJson(jsonResp)
                            self.delegate!.handleMessages!(messageCodeEntity)
                        }else if(response.response?.statusCode == 400){
                            self.validationErrorsCodes(jsonResp)
                        }else{
                            self.messagesErrorsCodes(jsonResp)
                        }
                        
                    case .Failure(let error):
                        print("Request failed with error: \(error)")
                    }
                        
                        debugPrint(response)
                    }
                case .Failure(let encodingError):
                    print(encodingError)
                }
            }
        )
    }
    
    
    public func validationErrorsCodes(JSON : AnyObject){
        let validationErrors : NSArray = Communicator.respValidationMessageCodesFromJson(JSON)
        self.delegate!.handleValidationErrors!(validationErrors)
    }
    
    public func messagesErrorsCodes(JSON : AnyObject){
        let messageCodeEntity : MessagesApiModel = Communicator.respMessageCodesFromJson(JSON)
        self.delegate!.handleMessages!(messageCodeEntity)
    }    
}