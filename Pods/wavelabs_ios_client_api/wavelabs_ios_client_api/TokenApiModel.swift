//
//  TokenApiModel.swift
//  IOSStarter
//
//  Created by afsarunnisa on 1/22/16.
//  Copyright (c) 2016 NBosTech. All rights reserved.
//

import Foundation
import UIKit


public class TokenApiModel :NSObject{
    // MARK: Properties
    public var access_token: String = ""
    public var expires_in: Int = 0
    public var refresh_token: String = ""
    public var scope: String = ""
    public var token_type: String = ""
    
}
