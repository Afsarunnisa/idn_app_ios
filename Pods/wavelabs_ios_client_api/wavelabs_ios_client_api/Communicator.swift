//
//  Communicator.swift
//  IOSStarter
//
//  Created by afsarunnisa on 1/27/16.
//  Copyright (c) 2016 NBosTech. All rights reserved.
//

import Foundation
class Communicator {
    
    
    class func userEntityFromJSON(JSONdata : AnyObject) -> NewMemberApiModel{
        
        let userEntity = NewMemberApiModel()
        var tokenDetails : NSDictionary!
        var memberDetails : NSDictionary!
        
        if(JSONdata.objectForKey("token") != nil){
            tokenDetails = JSONdata.objectForKey("token") as! NSDictionary
        }
        
        if(JSONdata.objectForKey("member") != nil){
            memberDetails = JSONdata.objectForKey("member") as! NSDictionary
        }
        
        if(tokenDetails != nil && memberDetails != nil){
            
            let tokenEntity : TokenApiModel = self.tokenDetailsEntity(tokenDetails)
            let memberEntity : MemberApiModel = self.memberDetailsEntity(memberDetails)
            
            userEntity.tokenApiModel = tokenEntity
            userEntity.memberApiModel = memberEntity
        }
        
        return userEntity
    }
    
    
    
    class func tokenDetailsEntity(tokenDetails: NSDictionary) -> TokenApiModel{
        
        let tokenEntity = TokenApiModel()
        
        if(tokenDetails.objectForKey("access_token") != nil){
            tokenEntity.access_token = Utilities.isValueNull(tokenDetails.objectForKey("access_token")!) as! String
        }
        
        if(tokenDetails.objectForKey("expires_in") != nil){
            tokenEntity.expires_in = Utilities.isValueNull(tokenDetails.objectForKey("expires_in")!) as! Int
        }
        
        if(tokenDetails.objectForKey("refresh_token") != nil){
            tokenEntity.refresh_token = Utilities.isValueNull(tokenDetails.objectForKey("refresh_token")!) as! String
        }
        
        if(tokenDetails.objectForKey("scope") != nil){
            tokenEntity.scope = Utilities.isValueNull(tokenDetails.objectForKey("scope")!) as! String
        }
        
        
        if(tokenDetails.objectForKey("token_type") != nil){
            tokenEntity.token_type = Utilities.isValueNull(tokenDetails.objectForKey("token_type")!) as! String
        }
        
        return tokenEntity
    }
    
    
    
    class func memberDetailsEntity(memberDetails: NSDictionary) -> MemberApiModel{
        
        let socialActAry : NSMutableArray = NSMutableArray()
        let socialActs : NSArray = memberDetails.objectForKey("socialAccounts") as! NSArray
        
        for var i = 0; i < socialActs.count; i++ {
            
            let socialActsEntity = SocialApiModel()
            
            let dict : NSDictionary = socialActs.objectAtIndex(i) as! NSDictionary
            
            socialActsEntity.email = Utilities.isValueNull(dict.objectForKey("email")!) as! String
            socialActsEntity.id = Utilities.isValueNull(dict.objectForKey("id")!) as! Int
            socialActsEntity.imageUrl = Utilities.isValueNull(dict.objectForKey("imageUrl")!) as! String
            socialActsEntity.socialType = Utilities.isValueNull(dict.objectForKey("socialType")!) as! String
            
            socialActAry.addObject(socialActsEntity)
        }
        
        let memberEntity = MemberApiModel()
        
        print("memberDetails \(memberDetails)")
        print("phone \(memberDetails.objectForKey("phone")!)")
        
        memberEntity.desc = Utilities.isValueNull(memberDetails.objectForKey("description")!) as! String
        memberEntity.email = Utilities.isValueNull(memberDetails.objectForKey("email")!) as! String
        memberEntity.firstName = Utilities.isValueNull(memberDetails.objectForKey("firstName")!) as! String
        memberEntity.id = Utilities.isValueNull(memberDetails.objectForKey("id")!) as! Int
        memberEntity.lastName = Utilities.isValueNull(memberDetails.objectForKey("lastName")!) as! String
        memberEntity.phone = Utilities.isValueNull(memberDetails.objectForKey("phone")!) as! String
        memberEntity.socialAccounts = socialActAry as NSArray
        
        return memberEntity
    }
    
    
    
    class func webLinkLoginFromJSON(JSONdata : AnyObject) -> NSDictionary{
        return JSONdata as! NSDictionary
    }
    
    
    
    class func respMediaFromJson(JSONdata : AnyObject) -> MediaApiModel {
        let mediaApi = MediaApiModel()
        
        mediaApi.mediaExtension = Utilities.isValueNull(JSONdata.objectForKey("extension")!) as! String
        mediaApi.supportedsizes = Utilities.isValueNull(JSONdata.objectForKey("supportedsizes")!) as! String
        
        
        
        let mediaDetailsList : NSMutableArray = NSMutableArray()
        let mediaDetails : NSArray = JSONdata.objectForKey("mediaFileDetailsList") as! NSArray
        
        for var i = 0; i < mediaDetails.count; i++ {
            
            let mediaFileDetails = MediaFileDetailsApiModel()
            
            let dict : NSDictionary = mediaDetails.objectAtIndex(i) as! NSDictionary
            
            mediaFileDetails.mediapath = Utilities.isValueNull(dict.objectForKey("mediapath")!) as! String
            mediaFileDetails.mediatype = Utilities.isValueNull(dict.objectForKey("mediatype")!) as! String
            
            mediaDetailsList.addObject(mediaFileDetails)
        }
        
        mediaApi.mediaFileDetailsList = mediaDetailsList
        
        return mediaApi
    }
    
    
    class func ProfileFromJson(JSONdata : AnyObject) -> MemberApiModel {
        var memberEntity : MemberApiModel!
        memberEntity = self.memberDetailsEntity(JSONdata as! NSDictionary)
        return memberEntity
    }
    
    
    class func respMessageCodesFromJson(JSONdata : AnyObject) -> MessagesApiModel {
        
        let messagesEntity = MessagesApiModel()
        
        if(JSONdata.objectForKey("message") != nil){
            messagesEntity.message = Utilities.isValueNull(JSONdata.objectForKey("message")!) as! String
            messagesEntity.messageCode = Utilities.isValueNull(JSONdata.objectForKey("messageCode")!) as! String
        }
        
        if(JSONdata.objectForKey("error") != nil){
            messagesEntity.message = Utilities.isValueNull(JSONdata.objectForKey("error_description")!) as! String
            messagesEntity.messageCode = Utilities.isValueNull(JSONdata.objectForKey("error")!) as! String
        }
        
        return messagesEntity
    }
    
    
    class func respValidationMessageCodesFromJson(JSONdata : AnyObject) -> NSArray {
        
        let validationArray : NSMutableArray = NSMutableArray()
        var errorsDict : NSDictionary!
        
        
        if(JSONdata.objectForKey("errors") != nil){
            let errorsArray : NSArray = JSONdata.objectForKey("errors") as! NSArray
            
            for var i = 0; i < errorsArray.count; i++ {
                errorsDict = errorsArray.objectAtIndex(i) as! NSDictionary
                let messagesEntity = ValidationMessagesApiModel()
                
                messagesEntity.message = Utilities.isValueNull(errorsDict.objectForKey("message")!) as! String
                messagesEntity.messageCode = Utilities.isValueNull(errorsDict.objectForKey("messageCode")!) as! String
                messagesEntity.objectName = Utilities.isValueNull(errorsDict.objectForKey("objectName")!) as! String
                messagesEntity.propertyName = Utilities.isValueNull(errorsDict.objectForKey("propertyName")!) as! String
                
                validationArray.addObject(messagesEntity)
            }
        }else{
            errorsDict = JSONdata as! NSDictionary
            
            let messagesEntity = MessagesApiModel()
            messagesEntity.message = Utilities.isValueNull(JSONdata.objectForKey("message")!) as! String
            messagesEntity.messageCode = Utilities.isValueNull(JSONdata.objectForKey("messageCode")!) as! String
            validationArray.addObject(messagesEntity)
        }
        return validationArray
    }
    
}