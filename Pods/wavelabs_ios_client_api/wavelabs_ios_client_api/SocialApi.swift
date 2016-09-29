//
//  SocialApi.swift
//  IOSStarter
//
//  Created by afsarunnisa on 1/29/16.
//  Copyright (c) 2016 NBosTech. All rights reserved.
//

import Foundation
import Alamofire


@objc public protocol getSocialApiResponseDelegate {
    
    optional func handleLogin(userEntity:NewMemberApiModel)
    optional func handleWebLinkLoginResponse(response:NSDictionary)
    
    
    optional func handleMessages(messageCodeEntity: MessagesApiModel)
    optional func handleValidationErrors(messageCodeEntityArray: NSArray) // multiple MessagesRespApiModel - 404(Validation errors)
    optional func handleRefreshToken(JSON : AnyObject) // multiple MessagesRespApiModel - 404(Validation errors)
    
}


public class SocialApi {
        
    public init() {
        
    }
    
    
    var socialIdentityApiUrl : String = "api/identity/v0/auth/social/"
    
    var fbConnectUrl : String = "facebook/connect"
    var googleConnectUrl : String = "googlePlus/connect"
    var digitsLoginUrl : String = "digits/connect"
    
    var gitLoginUrl : String = "gitHub/login"
    var linkedInLoginUrl : String = "linkedIn/login"
    var instagramLoginUrl : String = "instagram/login"
    
    var utilities : Utilities = Utilities()
    
    
    public var delegate: getSocialApiResponseDelegate?
    
    public func socialLogin(socialLoginDetails : NSDictionary, socialType : String){
        let socialConnectUrl : String = "\(socialType)/connect"
        
        let requestUrl = "\(WAVELABS_HOST_URL)\(socialIdentityApiUrl)\(socialConnectUrl)"
        let token: AnyObject = utilities.getClientAccessToken()
        
        Alamofire.request(.POST, requestUrl, parameters: utilities.getParams(socialLoginDetails), encoding:.JSON, headers : ["Authorization" : "Bearer \(token)"]).responseJSON
            { response in switch response.result {
            case .Success(let JSON):
                print("Success with JSON: \(JSON)")
                
                let jsonResp = JSON
                if(response.response?.statusCode == 200){
                    let userEntity : NewMemberApiModel = Communicator.userEntityFromJSON(jsonResp)
                    self.delegate!.handleLogin!(userEntity)
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
    
    public func socialWebLogin(socialType : String) {
        
        
        let socialwebLinkUrl : String = "\(socialType)/login"
        
        let requestUrl = "\(WAVELABS_HOST_URL)\(socialIdentityApiUrl)\(socialwebLinkUrl)"
        let token: AnyObject = utilities.getClientAccessToken()
        
        Alamofire.request(.GET, requestUrl, parameters: nil, encoding:.JSON, headers : ["Authorization" : "Bearer \(token)"]).responseJSON
            { response in switch response.result {
            case .Success(let JSON):
                print("Success with JSON: \(JSON)")
                
                let jsonResp = JSON
                if(response.response?.statusCode == 200){
                    let respDict : NSDictionary = Communicator.webLinkLoginFromJSON(jsonResp)
                    self.delegate!.handleWebLinkLoginResponse!(respDict)
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
    
    public func digitsLoginUser(digitsLogin : NSDictionary) {
        
        
        let requestUrl = "\(WAVELABS_HOST_URL)\(socialIdentityApiUrl)\(digitsLoginUrl)"
        let token: AnyObject = utilities.getClientAccessToken()
        
        Alamofire.request(.POST, requestUrl, parameters: utilities.getParams(digitsLogin), encoding:.JSON, headers : ["Authorization" : "Bearer \(token)"]).responseJSON
            { response in switch response.result {
            case .Success(let JSON):
                print("Success with JSON: \(JSON)")
                
                let jsonResp = JSON
                
                if(response.response?.statusCode == 200){
                    let userEntity : NewMemberApiModel = Communicator.userEntityFromJSON(jsonResp)
                    self.delegate!.handleLogin!(userEntity)
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
    
    public func socialConnect(socialLoginDetails : NSDictionary, socialType : String){
        
        
        let socialConnectUrl : String = "\(socialType)/connect"
        let requestUrl = "\(WAVELABS_HOST_URL)\(socialIdentityApiUrl)\(socialConnectUrl)"
        
        let token: AnyObject = utilities.getUserAccessToken()
        
        
        
        Alamofire.request(.POST, requestUrl, parameters: utilities.getParams(socialLoginDetails), encoding:.JSON, headers : ["Authorization" : "Bearer \(token)"]).responseJSON
            { response in switch response.result {
            case .Success(let JSON):
                print("Success with JSON: \(JSON)")
                
                let jsonResp = JSON
                
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
        }
    }
    
    public func socialWebConnect(socialType : String){
        
        let socialwebLinkUrl : String = "\(socialType)/login"
        let requestUrl = "\(WAVELABS_HOST_URL)\(socialIdentityApiUrl)\(socialwebLinkUrl)"
        
        let token: AnyObject = utilities.getUserAccessToken()
        
        
        Alamofire.request(.GET, requestUrl, parameters: nil, encoding:.JSON, headers : ["Authorization" : "Bearer \(token)"]).responseJSON
            { response in switch response.result {
            case .Success(let JSON):
                print("Success with JSON: \(JSON)")
                
                let jsonResp = JSON
                
                if(response.response?.statusCode == 200){
                    let respDict : NSDictionary = Communicator.webLinkLoginFromJSON(jsonResp)
                    self.delegate!.handleWebLinkLoginResponse!(respDict)
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