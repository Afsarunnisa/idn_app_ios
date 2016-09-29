//
//  UsersApi.swift
//  IOSStarter
//
//  Created by afsarunnisa on 1/27/16.
//  Copyright (c) 2016 NBosTech. All rights reserved.
//

import Foundation
import Alamofire

@objc public protocol getUsersApiResponseDelegate {
    
    optional func handleRegister(userEntity:NewMemberApiModel)
    optional func handleProfile(memberEntity:MemberApiModel)
    optional func handleUpdateProfile(memberEntity:MemberApiModel)
    
    optional func handleMessages(messageCodeEntity: MessagesApiModel)
    optional func handleValidationErrors(messageCodeEntityArray: NSArray) // multiple MessagesRespApiModel - 404(Validation errors)
    optional func handleRefreshToken(JSON : AnyObject) // multiple MessagesRespApiModel - 404(Validation errors)
}

public class UsersApi {
    
    var identityApiUrl : String = "api/identity/v0/users/"
    var rigistrationUrl : String = "signup"
    
    public var delegate: getUsersApiResponseDelegate?
    
    var utilities : Utilities = Utilities()
    
    
    public init() {
        
    }
    
    public func registerUser(userRegister : NSDictionary) {
        
        let requestUrl = "\(WAVELABS_HOST_URL)\(identityApiUrl)\(rigistrationUrl)"
        let token: AnyObject = utilities.getClientAccessToken()
        
        Alamofire.request(.POST, requestUrl, parameters: utilities.getParams(userRegister), encoding:.JSON, headers : ["Authorization" : "Bearer \(token)"]).responseJSON
            { response in switch response.result {
            case .Success(let JSON):
                let jsonResp = JSON
                if(response.response?.statusCode == 200){
                    let newMemberApi : NewMemberApiModel = Communicator.userEntityFromJSON(jsonResp)
                    self.delegate!.handleRegister!(newMemberApi)
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
    
    public func getProfile() {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        var userID : String
        
        if(Utilities.nullToNil(defaults.stringForKey("user_id")) == nil){ // checking for null
            userID = ""
        }else{
            userID = defaults.stringForKey("user_id")!
        }
        
        let requestUrl = "\(WAVELABS_HOST_URL)\(identityApiUrl)\(userID)"
        let token: AnyObject = utilities.getUserAccessToken()
        
        
        Alamofire.request(.GET, requestUrl, parameters: nil, encoding:.JSON, headers : ["Authorization" : "Bearer \(token)"]).responseJSON
            { response in switch response.result {
            case .Success(let JSON):
                print("Success with JSON: \(JSON)")
                
                let jsonResp = JSON
                if(response.response?.statusCode == 200){
                    let memberDetails : MemberApiModel = Communicator.ProfileFromJson(jsonResp)
                    self.delegate!.handleProfile!(memberDetails)
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
    
    public func updateProfile(profile : NSDictionary) {
        
        let utilities : Utilities = Utilities()
        let defaults = NSUserDefaults.standardUserDefaults()
        var userID : String
        
        if(Utilities.nullToNil(defaults.stringForKey("user_id")) == nil){ // checking for null
            userID = ""
        }else{
            userID = defaults.stringForKey("user_id")!
        }
        
        let requestUrl = "\(WAVELABS_HOST_URL)\(identityApiUrl)\(userID)"
        let token: AnyObject = utilities.getUserAccessToken()
        
        Alamofire.request(.GET, requestUrl, parameters: utilities.getParams(profile), encoding:.JSON, headers : ["Authorization" : "Bearer \(token)"]).responseJSON
            { response in switch response.result {
            case .Success(let JSON):
                print("Success with JSON: \(JSON)")
                let jsonResp = JSON
                if(response.response?.statusCode == 200){
                    let memberDetails : MemberApiModel = Communicator.ProfileFromJson(jsonResp)
                    self.delegate!.handleUpdateProfile!(memberDetails)
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
    
    public func validationErrorsCodes(JSON : AnyObject){
        let validationErrors : NSArray = Communicator.respValidationMessageCodesFromJson(JSON)
        self.delegate!.handleValidationErrors!(validationErrors)
    }
    
    public func messagesErrorsCodes(JSON : AnyObject){
        let messageCodeEntity : MessagesApiModel = Communicator.respMessageCodesFromJson(JSON)
        self.delegate!.handleMessages!(messageCodeEntity)
    }
}