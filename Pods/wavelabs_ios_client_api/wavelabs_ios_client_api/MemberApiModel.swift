//
//  MemberApiModel.swift
//  IOSStarter
//
//  Created by afsarunnisa on 1/22/16.
//  Copyright (c) 2016 NBosTech. All rights reserved.
//

import Foundation
@objc public class MemberApiModel :NSObject{
    // MARK: Properties
    
    public var desc: String = ""
    public var id: Int = 0
    public var email: String = ""
    public var firstName: String = ""
    public var lastName: String = ""
    public var phone: String = ""
    public var userName: String = ""
    
    public var socialAccounts : NSArray! // Array of socail accounts
}