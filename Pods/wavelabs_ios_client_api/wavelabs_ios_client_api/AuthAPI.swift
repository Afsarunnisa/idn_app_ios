//
//  AuthAPI.swift
//  IOSStarter
//
//  Created by afsarunnisa on 1/27/16.
//  Copyright (c) 2016 NBosTech. All rights reserved.
//

import Foundation
import Alamofire

@objc public protocol getAuthApiResponseDelegate {
    
    optional func handleLogin(userEntity:NewMemberApiModel)
    optional func handleLogOut(messageCodeEntity: MessagesApiModel)
    
    optional func handleMessages(messageCodeEntity: MessagesApiModel)
    optional func handleValidationErrors(messageCodeEntityArray: NSArray) // multiple MessagesRespApiModel - 404(Validation errors)
    optional func handleRefreshToken(JSON : AnyObject) // multiple MessagesRespApiModel - 404(Validation errors)
    
    optional func handleRefreshTokenResponse(tokenEntity : TokenApiModel)
    
    optional func handleClientTokenResponse(tokenEntity : TokenApiModel)
    
    
    optional func moveToLogin()
    
}

public class AuthApi {
    
    
    var identityApiUrl : String = "api/identity/v0/auth/"
    
    
    var loginUrl : String = "login"
    var logOutUrl : String = "logout"
    var changePswUrl : String = "changePassword"
    var forgotPswUrl : String = "forgotPassword"
    
    var refreshTokenUrl : String = "oauth/token"
    
    public var delegate: getAuthApiResponseDelegate?
    
    
    var utilities : Utilities = Utilities()
    
    
    public init() {
        
    }
    
    public func getClientToken(clientTokenDict : NSDictionary){
        
        let requestUrl = "\(WAVELABS_HOST_URL)\(refreshTokenUrl)"
        
        Alamofire.request(.POST, requestUrl, parameters: utilities.getParams(clientTokenDict)).responseJSON
            { response in switch response.result {
            case .Success(let JSON):
                //                print("Success with JSON: \(JSON)")
                
                let jsonResp = JSON as! NSDictionary
                
                if(response.response?.statusCode == 200){
                    
                    let tokenDetails : TokenApiModel = Communicator.tokenDetailsEntity(jsonResp)
                    WAVELABS_CLIENT_ACCESS_TOKEN = tokenDetails.access_token
                    self.delegate!.handleClientTokenResponse!(tokenDetails)
                    
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
    
    public func loginUser(login : NSDictionary) {
        
        let requestUrl = "\(WAVELABS_HOST_URL)\(identityApiUrl)\(loginUrl)"
        let token: AnyObject = utilities.getClientAccessToken()
        
        Alamofire.request(.POST, requestUrl, parameters: utilities.getParams(login), encoding:.JSON, headers : ["Authorization" : "Bearer \(token)"]).responseJSON
            { response in switch response.result {
            case .Success(let JSON):
                //                print("Success with JSON: \(JSON)")
                
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
    
    public func logOut() {
        
        let requestUrl = "\(WAVELABS_HOST_URL)\(identityApiUrl)\(logOutUrl)"
        let token: AnyObject = utilities.getUserAccessToken()
        
        Alamofire.request(.GET, requestUrl, parameters: nil, encoding:.JSON, headers : ["Authorization" : "Bearer \(token)"]).responseJSON
            { response in switch response.result {
            case .Success(let JSON):
                //                print("Success with JSON: \(JSON)")
                
                let jsonResp = JSON
                
                if(response.response?.statusCode == 200){
                    let messageCodeEntity : MessagesApiModel = Communicator.respMessageCodesFromJson(jsonResp)
                    self.delegate!.handleLogOut!(messageCodeEntity)
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
    
    public func changePassword(changePsw : NSDictionary) {
        
        let requestUrl = "\(WAVELABS_HOST_URL)\(identityApiUrl)\(changePswUrl)"
        let token: AnyObject = utilities.getUserAccessToken()
        
        Alamofire.request(.POST, requestUrl, parameters: utilities.getParams(changePsw), encoding:.JSON, headers : ["Authorization" : "Bearer \(token)"]).responseJSON
            { response in switch response.result {
            case .Success(let JSON):
                //                print("Success with JSON: \(JSON)")
                
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
    
    public func forgotPassword(forgotPsw : NSDictionary) {
        
        let requestUrl = "\(WAVELABS_HOST_URL)\(identityApiUrl)\(forgotPswUrl)"
        let token: AnyObject = utilities.getClientAccessToken()
        
        Alamofire.request(.POST, requestUrl, parameters: utilities.getParams(forgotPsw), encoding:.JSON, headers : ["Authorization" : "Bearer \(token)"]).responseJSON
            { response in switch response.result {
            case .Success(let JSON):
                //                print("Success with JSON: \(JSON)")
                
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
    
    public func refreshToken() {
        
        let refreshToken: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("refresh_token")!
        
        let requestUrl = "\(WAVELABS_HOST_URL)\(refreshTokenUrl)?grant_type=refresh_token&refresh_token=\(refreshToken)&client_id=\(WAVELABS_CLIENT_ID)&scope=read"
        
        let token: AnyObject = utilities.getUserAccessToken()
        
        
        
        
        Alamofire.request(.POST, requestUrl, parameters: nil, encoding:.JSON, headers : ["Authorization" : "Bearer \(token)"]).responseJSON
            { response in switch response.result {
            case .Success(let JSON):
                //                print("Success with JSON: \(JSON)")
                
                let jsonResp = JSON as! NSDictionary
                if(response.response?.statusCode == 200){
                    
                    let tokenApi : TokenApiModel = Communicator.tokenDetailsEntity(jsonResp)
                    self.delegate!.handleRefreshTokenResponse!(tokenApi)
                    
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