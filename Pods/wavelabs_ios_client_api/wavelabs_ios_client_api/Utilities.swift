//
//  Utilities.swift
//  APIStarters
//
//  Created by afsarunnisa on 6/19/15.
//  Copyright (c) 2015 NBosTech. All rights reserved.
//

import Foundation
import UIKit



var WAVELABS_CLIENT_ID = NSBundle.mainBundle().infoDictionary?["WavelabsAPISettings"]!.objectForKey("WAVELABS_CLIENT_ID") as! String
var WAVELABS_HOST_URL = NSBundle.mainBundle().infoDictionary?["WavelabsAPISettings"]!.objectForKey("WAVELABS_BASE_URL") as! String
var WAVELABS_CLIENT_SECRET = NSBundle.mainBundle().infoDictionary?["WavelabsAPISettings"]!.objectForKey("WAVELABS_CLIENT_SECRET") as! String

var WAVELABS_CLIENT_ACCESS_TOKEN : String = ""

public class Utilities {

    var WAVELABS_API_HOST_URL : String = ""
    
    class func nullToNil(value : AnyObject?) -> AnyObject? {
        if value is NSNull {
            return nil
        } else {
            return value
        }
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
    
    
    public func getParams(paramsDict : NSDictionary) -> [String : AnyObject]{
        var parameters : [String : AnyObject] = [:]
        
        for var index = 0; index < paramsDict.allKeys.count; ++index {
            let keysList : NSArray = paramsDict.allKeys as NSArray
            
            let key : String = keysList.objectAtIndex(index) as! String
            let value : String = paramsDict.objectForKey(key) as! String
            
            parameters[key] = value as AnyObject
        }

        return parameters
    }

    
    public func getClientAccessToken() -> String{
        return WAVELABS_CLIENT_ACCESS_TOKEN
    }

    
    public func getUserAccessToken() -> String{
        let token: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("access_token")!
        return token as! String
    }

    

}