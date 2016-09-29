//
//  SettingsVC.swift
//  APIStarters
//
//  Created by afsarunnisa on 6/19/15.
//  Copyright (c) 2015 NBosTech. All rights reserved.
//

import Foundation
import UIKit
import wavelabs_ios_client_api
import MBProgressHUD

class SettingsVC: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,getUsersApiResponseDelegate,getMediaApiResponseDelegate,getAuthApiResponseDelegate {

    var hud : MBProgressHUD = MBProgressHUD()

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var logoImageView: UIImageView!
    
    var uploadImageButton : UIButton!
    var photoSheet : UIActionSheet!
    var popOver:UIPopoverController?
    let imagePicker = UIImagePickerController()

    var usersApi = UsersApi()
    var mediaApi = MediaApi()
    var authApi : AuthApi = AuthApi()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hud : MBProgressHUD = MBProgressHUD()

        
//        self.automaticallyAdjustsScrollViewInsets = false
        updateBtn.layer.cornerRadius = 8

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true

        
        utilities.textFieldBottomBorder(firstNameTF)
        utilities.textFieldBottomBorder(lastNameTF)
        utilities.textFieldBottomBorder(emailTF)

        
        imagePicker.delegate = self

        // navigation bar title
        self.title = "Settings"
        
        // navigation bar background and title colors
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.Default
        nav?.tintColor = UIColor.darkGrayColor()
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.darkGrayColor()]
        nav?.backgroundColor = UIColor.darkGrayColor()

        // for slider menu
        if self.revealViewController() != nil {
            menuButton.addTarget(self.revealViewController(), action:#selector(self.revealViewController().revealToggle(_:)), forControlEvents: .TouchUpInside)

            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        
        let defaults = NSUserDefaults.standardUserDefaults()
        var userID : String
        
        if(utilities.nullToNil(defaults.stringForKey("user_id")) == nil){ // checking for null
            userID = ""
        }else{
            userID = defaults.stringForKey("user_id")! 
        }

//        let url = NSString(format:"%@users/%@", utilities.serviceUrl,userID) as String
        
        
        usersApi.delegate = self
        mediaApi.delegate = self
        authApi.delegate = self

        self.addProgreeHud()
        usersApi.getProfile()
        
        let imgHeight : CGFloat = bannerImageView.frame.size.height
        utilities.addGradientLayer(bannerImageView, height: Int(imgHeight))
        utilities.addLogoImage(logoImageView)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }

    
    // MARK: - Button actions

    @IBAction func updateBtnClicked(sender: AnyObject) {
        let firstNameStr : String = firstNameTF.text!
        let lastNameStr : String = lastNameTF.text!
        let emailStr : String = emailTF.text!
        
        if firstNameStr.isEmpty{
            let alert = utilities.alertView("Alert", alertMsg: FIRST_NAME_IN_VALID_PLACEHOLDER,actionTitle: "Ok")
            self.presentViewController(alert, animated: true, completion: nil)
        }else{
            
            let profileDict : NSMutableDictionary = NSMutableDictionary()
            profileDict.setObject(firstNameStr, forKey: "firstName")
            profileDict.setObject(lastNameStr, forKey: "lastName")
            profileDict.setObject("", forKey: "phone")
            profileDict.setObject("", forKey: "description")
            profileDict.setObject(emailStr, forKey: "email")
            
            self.addProgreeHud()
            usersApi.updateProfile(profileDict)
        }
    }
    
    
    @IBAction func uploadProfilePhotoBtnClicked(sender: AnyObject) {
        
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad{
            
            uploadImageButton = sender as! UIButton

            photoSheet = UIActionSheet()
            photoSheet.delegate = self
            photoSheet = UIActionSheet(title: "", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Camera Roll", "Camera","")
            photoSheet.showFromRect(CGRectMake(uploadImageButton.frame.origin.x,uploadImageButton.frame.origin.y, 100, 100), inView: self.view, animated: true)
            photoSheet.showInView(self.view)
        }else{
            let alert = UIAlertController(title: "Please choose source", message: nil, preferredStyle:
                .ActionSheet) // Can also set to .Alert if you prefer
            
            let cameraAction = UIAlertAction(title: "Camera", style: .Default) { (action) -> Void in
                self.showPhotoPicker(.Camera)
            }
            
            alert.addAction(cameraAction)
            
            let libraryAction = UIAlertAction(title: "Library", style: .Default) { (action) -> Void in
                self.showPhotoPicker(.PhotoLibrary)
            }
            
            
            alert.addAction(libraryAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
                (alert: UIAlertAction!) -> Void in
            })
            alert.addAction(cancelAction)
            
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    
    
    // MARK: - Image picker delegate methods

    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int){
        if(buttonIndex == 1){
            self.showPhotoPopOver(.PhotoLibrary)
        }else if(buttonIndex == 2){
            self.showPhotoPopOver(.Camera)
        }
    }

    
    func showPhotoPicker(source: UIImagePickerControllerSourceType) {
        
        if(source == UIImagePickerControllerSourceType.Camera){
            if(UIDevice.currentDevice().model == "iPhone Simulator"){
                return
            }
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = source
        imagePicker.delegate = self
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    func showPhotoPopOver(source: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = source
        imagePicker.delegate = self
        self.popOver  = UIPopoverController(contentViewController: imagePicker)
    
        let backgroundQueue = NSOperationQueue()
        
        backgroundQueue.addOperationWithBlock(){
            NSOperationQueue.mainQueue().addOperationWithBlock(){
                self.popOver?.presentPopoverFromRect(CGRectMake(self.uploadImageButton.frame.origin.x,self.uploadImageButton.frame.origin.y,100,80), inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
            }
        }
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {

        
        let selectedImg = info[UIImagePickerControllerOriginalImage] as! UIImage
        userImageView.contentMode = .ScaleAspectFit //3
        userImageView.image = selectedImg //4
        dismissViewControllerAnimated(true, completion: nil) //5
    
        
        let nsDocumentDirectory = NSSearchPathDirectory.DocumentDirectory
        let nsUserDomainMask    = NSSearchPathDomainMask.UserDomainMask
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let userID = defaults.stringForKey("user_id")
        
        let fileName : String =  NSString(format:"%@.png", userID!) as String
        
        
        
        let fileManager = NSFileManager.defaultManager()
        let docsURL = try! fileManager.URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)

        let imageDirURL = docsURL.URLByAppendingPathComponent("Images")
        
        if !fileManager.fileExistsAtPath(imageDirURL.path!) {
            do {
                try fileManager.createDirectoryAtURL(imageDirURL, withIntermediateDirectories: false, attributes:nil)
            } catch let error as NSError{
                print("Error creating SwiftData image folder", error)
            }
        }

        let storePath = NSURL(fileURLWithPath: imageDirURL.path!).URLByAppendingPathComponent(fileName)
        let imgData : NSData = UIImagePNGRepresentation(selectedImg)!
        imgData.writeToURL(storePath, atomically: false)
        
        self.addProgreeHud()
        mediaApi.uploadMedia("profile", imgName: fileName, userID: userID!)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    
    // MARK: - API call response delegate

    func handleRefreshTokenResponse(tokenEntity:TokenApiModel){
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let accessToken = tokenEntity.access_token
        
        let date = NSDate()
        
        defaults.setObject(accessToken, forKey: "access_token")
        defaults.setObject(tokenEntity.refresh_token, forKey: "refresh_token")
        defaults.setObject(tokenEntity.expires_in, forKey: "expires_in")
        defaults.setObject(date, forKey: "startDate")
        
        defaults.synchronize()
    }

    
    func handleProfile(memberEntity: MemberApiModel) {
        MBProgressHUD.hideHUDForView(self.view, animated: true)

        self.firstNameTF.text = memberEntity.firstName
        self.lastNameTF.text = memberEntity.lastName
        self.emailTF.text = memberEntity.email
        
        
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(memberEntity.firstName, forKey: "currentMemberName")
        defaults.synchronize()
        
        USER_SOCIAL_CONNECTS = memberEntity.socialAccounts as! NSMutableArray
        
        self.addProgreeHud()
        
        
        mediaApi.getMedia()
    }
    
    func handleUpdateProfile(memberEntity: MemberApiModel) {
        MBProgressHUD.hideHUDForView(self.view, animated: true)

        self.firstNameTF.text = memberEntity.firstName
        self.lastNameTF.text = memberEntity.lastName
        self.emailTF.text = memberEntity.email
        
        let alert = utilities.alertView("Alert", alertMsg: "Profile updated",actionTitle: "Ok")
        self.presentViewController(alert, animated: true, completion: nil)

        let defaults = NSUserDefaults.standardUserDefaults()
        USER_SOCIAL_CONNECTS = memberEntity.socialAccounts as! NSMutableArray
    }
    
    func handleMedia(mediaApiResp: MediaApiModel){
        
        MBProgressHUD.hideHUDForView(self.view, animated: true)

        let imgsArray = mediaApiResp.mediaFileDetailsList as NSArray
        
        print("imgsArray \(imgsArray)")
        
        for i in 0 ..< imgsArray.count {
            
            let mediaFileApiModel : MediaFileDetailsApiModel = imgsArray.objectAtIndex(i) as! MediaFileDetailsApiModel
            let mediaType = mediaFileApiModel.mediatype
            
            if(mediaType == "medium"){
                
                let mediaPathStr = mediaFileApiModel.mediapath
                let mediaPathUrl: NSURL = NSURL(string: mediaPathStr)!
                let data = NSData(contentsOfURL: mediaPathUrl) //make sure your image in this url does exist, otherwise unwrap in a if let check
                if(data != nil){
                    self.userImageView.image = UIImage(data: data!)
                }
            }
        }
    }

    
    func handleRefreshToken(JSON : AnyObject){
        MBProgressHUD.hideHUDForView(self.view, animated: true)

        self.addProgreeHud()
        authApi.refreshToken()
    }
    

    func moveToLogin(){
       
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC: UINavigationController = mainStoryboard.instantiateViewControllerWithIdentifier("mainNavigation") as! UINavigationController
        self.presentViewController(loginVC, animated: true, completion: nil)
    }
    
    
    func handleMessages(messageCodeEntity : MessagesApiModel){
        MBProgressHUD.hideHUDForView(self.view, animated: true)

        let messageStr = messageCodeEntity.message
        let alert = utilities.alertView("Alert", alertMsg: messageStr,actionTitle: "Ok")
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func handleValidationErrors(messageCodeEntityArray: NSArray){
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        let errorMessage: NSMutableString = ""
        for i in 0 ..< messageCodeEntityArray.count {
            let messageCode : ValidationMessagesApiModel = messageCodeEntityArray.objectAtIndex(i) as! ValidationMessagesApiModel
            let messageStr = messageCode.message
            errorMessage.appendString(messageStr)
        }
        
        let alert = utilities.alertView("Alert", alertMsg: errorMessage as String,actionTitle: "Ok")
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func addProgreeHud(){
        hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.mode = .Indeterminate
        hud.labelText = "Loading"
    }

    
}


extension UIImage {
    var uncompressedPNGData: NSData      { return UIImagePNGRepresentation(self)!        }
    var highestQualityJPEGNSData: NSData { return UIImageJPEGRepresentation(self, 1.0)!  }
    var highQualityJPEGNSData: NSData    { return UIImageJPEGRepresentation(self, 0.75)! }
    var mediumQualityJPEGNSData: NSData  { return UIImageJPEGRepresentation(self, 0.5)!  }
    var lowQualityJPEGNSData: NSData     { return UIImageJPEGRepresentation(self, 0.25)! }
    var lowestQualityJPEGNSData:NSData   { return UIImageJPEGRepresentation(self, 0.0)!  }
}


