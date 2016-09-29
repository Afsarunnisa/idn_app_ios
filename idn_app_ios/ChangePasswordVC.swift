//
//  ChangePasswordVC.swift
//  APIStarters
//
//  Created by afsarunnisa on 6/22/15.
//  Copyright (c) 2015 NBosTech. All rights reserved.
//

import Foundation
import UIKit
import wavelabs_ios_client_api
import MBProgressHUD

class ChangePasswordVC: UIViewController,getAuthApiResponseDelegate{
    
//    @IBOutlet weak var menuButton:UIBarButtonItem!
    @IBOutlet weak var currentPasswordTF: UITextField!
    @IBOutlet weak var newPasswordTF: UITextField!
    @IBOutlet weak var changePasswordBtn: UIButton!
    @IBOutlet weak var resetPasswordByEmailBtn: UIButton!
    var authApi : AuthApi = AuthApi()

    var hud : MBProgressHUD = MBProgressHUD()
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigation bar title
        self.title = "Change Password"
        
        // navigation bar background and title colors
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.Default
        nav?.tintColor = UIColor.darkGrayColor()
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.darkGrayColor()]
        nav?.backgroundColor = UIColor.darkGrayColor()
        
        if self.revealViewController() != nil {
            menuButton.addTarget(self.revealViewController(), action:#selector(self.revealViewController().revealToggle(_:)), forControlEvents: .TouchUpInside)
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        
        changePasswordBtn.layer.cornerRadius = 8

        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true

        utilities.textFieldBottomBorder(currentPasswordTF)
        utilities.textFieldBottomBorder(newPasswordTF)

        
        authApi.delegate = self
        
        let imgHeight : CGFloat = bannerImageView.frame.size.height
        utilities.addGradientLayer(bannerImageView, height: Int(imgHeight))
        utilities.addLogoImage(logoImageView)

    }
    
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }

    
    // MARK: - Button Actions

    @IBAction func resetPswdByEmailBtnClicked(sender: AnyObject) {
    }
    
    @IBAction func changePasswordBtnClicked(sender: AnyObject) {
        self.view.endEditing(true)

        let currentPswdStr: String = currentPasswordTF.text!
        let newPswdStr: String = newPasswordTF.text!
        
        if currentPswdStr.isEmpty {
            let alert = utilities.alertView("Alert", alertMsg: "Please enter current password",actionTitle: "Ok")
            self.presentViewController(alert, animated: true, completion: nil)
        }else if newPswdStr.isEmpty{
            let alert = utilities.alertView("Alert", alertMsg: "Please enter new password",actionTitle: "Ok")
            self.presentViewController(alert, animated: true, completion: nil)
        }else{
            
            let changePswDict : NSMutableDictionary = NSMutableDictionary()
            changePswDict.setObject(currentPswdStr, forKey: "password")
            changePswDict.setObject(newPswdStr, forKey: "newPassword")
            
            self.addProgreeHud()
            authApi.changePassword(changePswDict)
        }
    }
    
    
    @IBAction func resignBtnClikced(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    
    func handleRefreshToken(JSON : AnyObject){
        self.addProgreeHud()
        authApi.refreshToken()
    }
    
    
    func moveToLogin(){
        
        print("Self \(self)")
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC: UINavigationController = mainStoryboard.instantiateViewControllerWithIdentifier("mainNavigation") as! UINavigationController
        
        self.presentViewController(loginVC, animated: true, completion: nil)
    }
    
//    func handleRefreshTokenResponse(tokenEntity:TokenApiModel){
//        print("tokenEntity \(tokenEntity)")
//
//        MBProgressHUD.hideHUDForView(self.view, animated: true)
//        let defaults = NSUserDefaults.standardUserDefaults()
//        let accessToken = tokenEntity.access_token
//        
//        let date = NSDate()
//        
//        defaults.setObject(accessToken, forKey: "access_token")
//        defaults.setObject(tokenEntity.refresh_token, forKey: "refresh_token")
//        defaults.setObject(tokenEntity.expires_in, forKey: "expires_in")
//        defaults.setObject(date, forKey: "startDate")
//        
//        defaults.synchronize()
//    }

        
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

