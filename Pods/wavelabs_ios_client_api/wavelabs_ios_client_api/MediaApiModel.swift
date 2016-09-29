//
//  MediaApiModel.swift
//  IOSStarter
//
//  Created by afsarunnisa on 1/22/16.
//  Copyright (c) 2016 NBosTech. All rights reserved.
//

import Foundation

@objc public class MediaApiModel:NSObject {
    // MARK: Properties
    public var mediaExtension : String = ""
    public var supportedsizes : String = ""
    
    public var mediaFileDetailsList : NSArray!
}