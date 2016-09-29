//
//  Utilities.swift
//  APIStarters
//
//  Created by afsarunnisa on 6/19/15.
//  Copyright (c) 2015 NBosTech. All rights reserved.
//

import Foundation
import UIKit



//    Side menu list


var USER_DASHBOARD_STR           = "Dashboard"
var USER_PROFILE_STR             = "My Profile"

var USER_SETTINGS_STR           = "Settings"
var USER_CHANGE_PASSWORD_STR    = "Change Password"
var USER_SOCIAL_LINKS_STR       = "Social Links"
var USER_LOGOUT_STR             = "Logout"


//    Socail Buttons list

var SOCIAL_FACEBOOK_BTN         = "Facebook"
var SOCIAL_GOOGLE_BTN           = "GooglePlus"
var SOCIAL_LINKEDIN_BTN         = "LinkedIn"
var SOCIAL_GITHUB_BTN           = "GitHub"
var SOCIAL_INSTAGRAM_BTN        = "Instagram"


// Validations Errors

let USER_NAME_VALID_PLACEHOLDER = "Username"
let USER_NAME_IN_VALID_PLACEHOLDER = "Please enter username!"

let PASSWORD_VALID_PLACEHOLDER = "Password"
let PASSWORD_IN_VALID_PLACEHOLDER = "Please enter password!"


let EMAIL_VALID_PLACEHOLDER = "Email"
let EMAIL_IN_VALID_PLACEHOLDER = "Please enter email id!"

let FIRST_NAME_VALID_PLACEHOLDER = "First Name"
let FIRST_NAME_IN_VALID_PLACEHOLDER = "Please enter first name!"

let LAST_NAME_VALID_PLACEHOLDER = "Last Name"



var USER_SOCIAL_CONNECTS : NSMutableArray!



var CLIENT_ID = NSBundle.mainBundle().infoDictionary?["WavelabsAPISettings"]!.objectForKey("WAVELABS_CLIENT_ID") as! String
var BASE_URL = NSBundle.mainBundle().infoDictionary?["WavelabsAPISettings"]!.objectForKey("WAVELABS_BASE_URL") as! String
var CLIENT_SECRET = NSBundle.mainBundle().infoDictionary?["WavelabsAPISettings"]!.objectForKey("WAVELABS_CLIENT_SECRET") as! String


class utilities {
    
    
    static var serviceUrl = "http://starterapp.com:8080/starter-app-rest-grails/api/v0/"
//    static var clientID = "my-client"

    
    // padding view callback
    
    class func setLeftIcons(imgName: String,textField: UITextField) {
    
        var width : CGFloat = 0
        var height : CGFloat = 0
        
        if (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad){
            width = 40
            height = 40
            
        }else{
            width = 32
            height = 32
        }
        
        
//        let imageView = UIImageView(frame: CGRectMake(0, 0, width, height)); // set as you want
  //      let image: UIImage = UIImage(named: imgName)!
    //    imageView.image = image;
      //  imageView.contentMode = UIViewContentMode.Center
        
  //      let paddingView=UIView(frame: CGRectMake(0, 0, width, height))
    //    paddingView.addSubview(imageView)

      //  textField.leftViewMode = UITextFieldViewMode.Always
//        textField.leftView = paddingView

    }
    
    // alert view call back
    
    
    class func alertView(alertTitle: String, alertMsg:String, actionTitle: String) -> UIAlertController{
        var alert = UIAlertController(title:alertTitle, message:alertMsg, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title:actionTitle, style: UIAlertActionStyle.Default, handler: nil))
        return alert
    }
    
    
    class func nullToNil(value : AnyObject?) -> AnyObject? {
        if value is NSNull {
            return nil
        } else {
            return value
        }
    }

    
    
    class func  deviceType() -> AnyObject{
    
        var screenHeight : CGFloat = UIScreen.mainScreen().bounds.size.height
        var screenWidth : CGFloat = UIScreen.mainScreen().bounds.size.width
        
        if( screenHeight < screenWidth ){
            screenHeight = screenWidth;
        }
        
        if (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad){
            // Ipad
            return "iPad";
        }else{
            // Iphone
            
            if( screenHeight > 480 && screenHeight < 667 ){
                return "iPhone 5/5s"
            } else if ( screenHeight > 480 && screenHeight < 736 ){
                return "iPhone 6"
            } else if ( screenHeight > 480 ){
                return "iPhone 6 Plus"
            } else {
                return "iPhone 4/4s"
            }
        }
    }
    
    class func setPlaceHolder(text : String, validateText : String, textField : UITextField) {
        var semiColor : AnyObject = ""
        
        if(validateText == "Invalid"){
            let redColor = UIColor.redColor() // 1.0 alpha
            semiColor = redColor.colorWithAlphaComponent(0.5)
        }else{
            let lightGrayColor = UIColor.lightGrayColor() // 1.0 alpha
            semiColor = lightGrayColor.colorWithAlphaComponent(0.5)
            
        }
        
        let placeHolder=NSAttributedString(string:text, attributes:    [NSForegroundColorAttributeName : semiColor])
        textField.attributedPlaceholder = placeHolder

    }

    class func isValueNull(value : AnyObject) -> AnyObject {

        var str : AnyObject!
        
        if((value.isKindOfClass(NSNull)) == true){
            str = ""
        }else{
            str = value
        }
        
        return str
    }
    
    
    
    
    class func getParamsFromDict(paramsDict : NSDictionary) -> [String: AnyObject?] {
        
        let paramsStr = NSMutableString()
        var parameters: [String: AnyObject?] = [:]
        
        for var index = 0; index < paramsDict.allKeys.count; ++index {
            let keysList : NSArray = paramsDict.allKeys as NSArray
            
            let key : String = keysList.objectAtIndex(index) as! String
            let value : String = paramsDict.objectForKey(key) as! String

            parameters[key] = value
        }
        print("parameters \(parameters)")
        return parameters
    }
    
    
    
    
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    

    
    
    class func textFieldBottomBorder(textField: UITextField) {
        
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.lightGrayColor().CGColor
        border.frame = CGRect(x: 0, y: textField.frame.size.height - width, width:  textField.frame.size.width, height: textField.frame.size.height)
        
        border.borderWidth = width
        textField.layer.addSublayer(border)
        textField.layer.masksToBounds = true

    }
    
    
    
    
    
    
    
    
    
}