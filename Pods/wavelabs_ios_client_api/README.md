# wavelabs-ios-client-api


## Requirements

- iOS 8.0+ / Mac OS X 10.9+
- Xcode 6.4


## Installation


### CocoaPods

CocoaPods is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

create the Podfile by uisng following commands 

```bash
$ cd <path-to-project/>
$ pod init
$ open -a Xcode Podfile

```


To integrate this library into your Xcode project using CocoaPods, specify it in your Podfile:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
source 'httpshttps://github.com/nbostech/wavelabs_ios_client_api.git'

platform :ios, '8.0'
use_frameworks!

pod 'wavelabs_ios_client_api', '~> 0.1.0'
```

  
  and using terminal, run the following command:

```bash
$ pod install
```


## Usage

### Add Url and ClientId
  
   Add Baseurl and clientId in Targets/info as WavelabsAPISettings

### Making a Request

#### User Registration

```swift
import StarteriOSClientAPI

  var rigisterDict : NSMutableDictionary = NSMutableDictionary()
  rigisterDict.setObject(userNameStr, forKey: "username")
  rigisterDict.setObject(emailStr, forKey: "email")
  rigisterDict.setObject(passwordStr, forKey: "password")
  rigisterDict.setObject(firstNameStr, forKey: "firstName")
  rigisterDict.setObject(lastNameStr, forKey: "lastName")
  rigisterDict.setObject(CLIENT_ID, forKey: "clientId")
  
  usersApi.registerUser(rigisterDict)
  ```

### Response Data Handler

```swift

    func handleRegister(newApiModel: NewMemberApiModel) {
    
    // save access token in NSUserDefaults 
    
      defaults.setObject(accessToken, forKey: "access_token")

       println("Newmember details \(newApiModel)")        
    }
    
        
    func handleMessages(messageCodeEntity : MessagesApiModel){
      println("mmessage details \(messageCodeEntity)")        
    }
    
    
    func handleValidationErrors(messageCodeEntityArray: NSArray){
      MBProgressHUD.hideHUDForView(self.view, animated: true)
      var errorMessage: NSMutableString = ""
        
      for var i = 0; i < messageCodeEntityArray.count; i++ {
        var messageCode : ValidationMessagesApiModel = messageCodeEntityArray.objectAtIndex(i) as! ValidationMessagesApiModel
        let messageStr = messageCode.message
        errorMessage.appendString(messageStr)
      }
      var alert = utilities.alertView("Alert", alertMsg: errorMessage as String,actionTitle: "Ok")
      self.presentViewController(alert, animated: true, completion: nil)
    }


  ```
