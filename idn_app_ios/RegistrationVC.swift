//
//  RegistrationVC.swift
//  APIStarters
//
//  Created by afsarunnisa on 6/19/15.
//  Copyright (c) 2015 NBosTech. All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import MBProgressHUD
import wavelabs_ios_client_api

//GPPSignInDelegate

class RegistrationVC: UIViewController,GIDSignInUIDelegate,GIDSignInDelegate,getUsersApiResponseDelegate,getSocialApiResponseDelegate {
    
    
    @IBOutlet weak var bannerImageView: UIImageView!
    var hud : MBProgressHUD = MBProgressHUD()

    var kPreferredTextFieldToKeyboardOffset: CGFloat = 600.0
    var keyboardFrame: CGRect = CGRect.null
    var keyboardIsShowing: Bool = false
    weak var activeTextField: UITextField?
    
    var textFieldOffset: CGFloat = 0

    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var signUpScrollView: UIScrollView!
//    @IBOutlet weak var userNameTF: UITextField!
    
    @IBOutlet weak var googleSignInButton: GIDSignInButton!

    
    var usersApi = UsersApi()
    var socialApi : SocialApi = SocialApi()

    @IBOutlet weak var loginButton: UIButton!
    
    var bannerImg_View_Height_Constraint:NSLayoutConstraint!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // navigation bar title
        self.title = "Registration"
        
//        self.automaticallyAdjustsScrollViewInsets = false
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        
        
        utilities.textFieldBottomBorder(firstNameTF)
        utilities.textFieldBottomBorder(lastNameTF)
        utilities.textFieldBottomBorder(emailTF)
        utilities.textFieldBottomBorder(passwordTF)


        signUpBtn.layer.cornerRadius = 8
        loginButton.contentHorizontalAlignment = .Left

        googleSignInButton.style = GIDSignInButtonStyle.IconOnly

        
        
        if(utilities.deviceType() as! String == "iPhone 4/4s" || utilities.deviceType() as! String == "iPhone 5/5s"){
            textFieldOffset = 70
        }else if(utilities.deviceType() as! String == "iPhone 6" || utilities.deviceType() as! String == "iPhone 6 Plus"){
            textFieldOffset = 100
        }
        
        refreshTextFields()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        
        usersApi.delegate = self
        socialApi.delegate = self
        
        
        
        var imgHeight : Int = 140
        
        
        if(DeviceType.IS_IPHONE_5 || DeviceType.IS_IPHONE_4_OR_LESS){
            imgHeight = 140
        }else if(DeviceType.IS_IPHONE_6){
            imgHeight = 160
            
        }else if(DeviceType.IS_IPHONE_6P){
            imgHeight = 200
        }
        
        
        if(bannerImg_View_Height_Constraint != nil){
            self.view.removeConstraint(bannerImg_View_Height_Constraint)
        }
        
        bannerImg_View_Height_Constraint  = (NSLayoutConstraint(
            item:bannerImageView, attribute:NSLayoutAttribute.Height,
            relatedBy:NSLayoutRelation.Equal,
            toItem:nil, attribute:NSLayoutAttribute.NotAnAttribute,
            multiplier:0, constant:CGFloat(imgHeight)))
        
        
        self.view.addConstraint(bannerImg_View_Height_Constraint)
        
        utilities.addGradientLayer(bannerImageView, height: imgHeight)

    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }

    // MARK: - Textfield Delegate Methods

    
    @IBAction func textFieldDidReturn(textField: UITextField!){
        textField.resignFirstResponder()
        self.activeTextField = nil
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        
        if(textField == firstNameTF){
            lastNameTF.becomeFirstResponder()
        }else if(textField == lastNameTF){
            emailTF.becomeFirstResponder()
        }else if(textField == emailTF){
            passwordTF.becomeFirstResponder()
        }else{
            textField.resignFirstResponder()
        }
        return true
        
    }
    
    
    func textFieldDidBeginEditing(textField: UITextField){
        self.activeTextField = textField
        
        if(utilities.deviceType() as! String != "iPad"){
            signUpScrollView.setContentOffset(CGPointMake(0, textField.frame.origin.y-textFieldOffset), animated: true)
        }else{
            if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)){
                signUpScrollView.setContentOffset(CGPointMake(0, textField.frame.origin.y-140), animated: true)
            }
        }

        if(textField == firstNameTF){
            utilities.setPlaceHolder("First Name", validateText: "Valid", textField: firstNameTF)
        }else if(textField == lastNameTF){
            utilities.setPlaceHolder("Last Name", validateText: "Valid", textField: lastNameTF)
        }else if(textField == emailTF){
            utilities.setPlaceHolder("Email", validateText: "Valid", textField: emailTF)
        }else if(textField == passwordTF){
            utilities.setPlaceHolder("Password", validateText: "Valid", textField: passwordTF)
        }
    }
    

    func textFieldDidEndEditing(textField: UITextField) {
        
        if(utilities.deviceType() as! String != "iPad"){
            signUpScrollView.setContentOffset(CGPointMake(0, 0), animated: true)
        }else{
            if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)){
                signUpScrollView.setContentOffset(CGPointMake(0, -60), animated: true)
            }
        }
    }
    
    
    // MARK: - Button Actions

    @IBAction func resignBtnClikced(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    @IBAction func signUpBtnClicked(sender: AnyObject) {
        
        let firstNameStr: String = firstNameTF.text!
        let emailStr: String = emailTF.text!
        let passwordStr: String = passwordTF.text!
        let lastNameStr: String = lastNameTF.text!
//        let userNameStr: String = userNameTF.text!
        
        if(firstNameStr.isEmpty && emailStr.isEmpty && passwordStr.isEmpty){
            
            utilities.setPlaceHolder(FIRST_NAME_IN_VALID_PLACEHOLDER, validateText: "Invalid", textField: firstNameTF)
//            utilities.setPlaceHolder(USER_NAME_IN_VALID_PLACEHOLDER, validateText: "Invalid", textField: userNameTF)
            utilities.setPlaceHolder(EMAIL_IN_VALID_PLACEHOLDER, validateText: "Invalid", textField: emailTF)
            utilities.setPlaceHolder(PASSWORD_IN_VALID_PLACEHOLDER, validateText: "Invalid", textField: passwordTF)
            
        }else if(firstNameStr.isEmpty || emailStr.isEmpty || passwordStr.isEmpty){
            
            if firstNameStr.isEmpty {
                utilities.setPlaceHolder(FIRST_NAME_IN_VALID_PLACEHOLDER, validateText: "Invalid", textField: firstNameTF)
            }
//            if userNameStr.isEmpty{
//                utilities.setPlaceHolder(USER_NAME_IN_VALID_PLACEHOLDER, validateText: "Invalid", textField: userNameTF)
//            }
            if emailStr.isEmpty{
                utilities.setPlaceHolder(EMAIL_IN_VALID_PLACEHOLDER, validateText: "Invalid", textField: emailTF)
            }
            
            if passwordStr.isEmpty{
                utilities.setPlaceHolder(PASSWORD_IN_VALID_PLACEHOLDER, validateText: "Invalid", textField: passwordTF)
            }
        }else{
            
            let rigisterDict : NSMutableDictionary = NSMutableDictionary()
//            rigisterDict.setObject(userNameStr, forKey: "username")
            rigisterDict.setObject(emailStr, forKey: "email")
            rigisterDict.setObject(passwordStr, forKey: "password")
            rigisterDict.setObject(firstNameStr, forKey: "firstName")
            rigisterDict.setObject(lastNameStr, forKey: "lastName")
            rigisterDict.setObject(CLIENT_ID, forKey: "clientId")
            
            self.addProgreeHud()
            usersApi.registerUser(rigisterDict)
        }
    }


    @IBAction func loginButtonClicked(sender: AnyObject) {
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        }
    }
    
    @IBAction func goBackBtnClick(sender: AnyObject) {
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        }
    }

    
    
    // MARK: - Google Plus Delegate Methods
    
    func signInWillDispatch(signIn: GIDSignIn!, error: NSError!) {
        //        myActivityIndicator.stopAnimating()
    }
    
    // Present a view that prompts the user to sign in with Google
    func signIn(signIn: GIDSignIn!,
        presentViewController viewController: UIViewController!) {
            self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func signIn(signIn: GIDSignIn!,
        dismissViewController viewController: UIViewController!) {
            self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
        withError error: NSError!) {
            if (error == nil) {
                // Perform any operations on signed in user here.
                let userId = user.userID                  // For client-side use only!
                let idToken = user.authentication.idToken // Safe to send to the server
                let name = user.profile.name
                let email = user.profile.email
                
                let expiry = user.authentication // Safe to send to the server
                let accessToken = user.authentication.accessToken
                
                
                let socialLoginDict : NSMutableDictionary = NSMutableDictionary()
                socialLoginDict.setObject(accessToken, forKey: "accessToken")
                socialLoginDict.setObject("", forKey: "expiresIn")
                socialLoginDict.setObject(CLIENT_ID, forKey: "clientId")
                
                self.addProgreeHud()
                socialApi.socialLogin(socialLoginDict, socialType: "googlePlus")
                
            } else {
                print("\(error.localizedDescription)")
            }
    }

    // MARK: - Facebook Delegate Methods

    @IBAction func loginFbBtnClicked(sender: AnyObject) {
        
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logInWithReadPermissions(["email"], fromViewController: self, handler: { (result, error) -> Void in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result
                
                if(fbloginresult.grantedPermissions != nil){
                    if(fbloginresult.grantedPermissions.contains("email")){
                        self.getFBUserData()
                        fbLoginManager.logOut()
                    }
                }
            }
        })
    }
    
    
    func getFBUserData(){

        let fbAccessToken = FBSDKAccessToken.currentAccessToken().tokenString
        
        let socialLoginDict : NSMutableDictionary = NSMutableDictionary()
        socialLoginDict.setObject(fbAccessToken, forKey: "accessToken")
        socialLoginDict.setObject("", forKey: "expiresIn")
        socialLoginDict.setObject(CLIENT_ID, forKey: "clientId")
        
        self.addProgreeHud()
        socialApi.socialLogin(socialLoginDict, socialType: "facebook")

    }


    // MARK: - WebService Delegate Methods
    
    func handleRegister(newApiModel: NewMemberApiModel) {
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        
        if(newApiModel.tokenApiModel != nil){
            
            var tokenEty : TokenApiModel = newApiModel.tokenApiModel
            let memberEty : MemberApiModel = newApiModel.memberApiModel
            let defaults = NSUserDefaults.standardUserDefaults()
            let accessToken = tokenEty.access_token
            
            let date = NSDate()
            
          
            defaults.setObject(memberEty.firstName, forKey: "currentMemberName")
            
            defaults.setObject(memberEty.id, forKey: "user_id")
            defaults.setObject(accessToken, forKey: "access_token")
            defaults.setObject(tokenEty.refresh_token, forKey: "refresh_token")
            defaults.setObject(tokenEty.expires_in, forKey: "expires_in")
            defaults.setObject(date, forKey: "startDate")
            
            defaults.synchronize()
            self.performSegueWithIdentifier("SignUpToDashboard", sender: self)
        }
    }
    
    func handleLogin(userEntity: NewMemberApiModel) {
        
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        if(userEntity.tokenApiModel != nil){
            
            let tokenEty : TokenApiModel = userEntity.tokenApiModel
            let memberEty : MemberApiModel = userEntity.memberApiModel
            let defaults = NSUserDefaults.standardUserDefaults()
            let accessToken = tokenEty.access_token
            
            let date = NSDate()
            
            defaults.setObject(memberEty, forKey: "currentMember")
            
            defaults.setObject(memberEty.id, forKey: "user_id")
            defaults.setObject(accessToken, forKey: "access_token")
            defaults.setObject(tokenEty.refresh_token, forKey: "refresh_token")
            defaults.setObject(tokenEty.expires_in, forKey: "expires_in")
            defaults.setObject(date, forKey: "startDate")
            
            defaults.synchronize()
            self.performSegueWithIdentifier("SignUpToDashboard", sender: self)
        }
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
        
        for var i = 0; i < messageCodeEntityArray.count; i++ {
            let messageCode : ValidationMessagesApiModel = messageCodeEntityArray.objectAtIndex(i) as! ValidationMessagesApiModel
            let messageStr = messageCode.message
            errorMessage.appendString(messageStr)
        }
        
        let alert = utilities.alertView("Alert", alertMsg: errorMessage as String,actionTitle: "Ok")
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func alertView(View: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        }
    }
    
    
    func addProgreeHud(){
        hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.mode = .Indeterminate
        hud.labelText = "Loading"
    }

    func refreshTextFields(){
        utilities.setPlaceHolder("First Name", validateText: "Valid", textField: firstNameTF)
        utilities.setPlaceHolder("Last Name", validateText: "Valid", textField: lastNameTF)
//        utilities.setPlaceHolder("User Name", validateText: "Valid", textField: userNameTF)
        utilities.setPlaceHolder("Email", validateText: "Valid", textField: emailTF)
        utilities.setPlaceHolder("Password", validateText: "Valid", textField: passwordTF)
    }
}
