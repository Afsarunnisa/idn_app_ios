//
//  ViewController.swift
//  idn_app_ios
//
//  Created by Afsarunnisa on 9/25/16.
//  Copyright © 2016 Afsarunnisa. All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import MBProgressHUD
import wavelabs_ios_client_api


class LoginVC: UIViewController,UIAlertViewDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,GIDSignInUIDelegate,GIDSignInDelegate, getAuthApiResponseDelegate,getSocialApiResponseDelegate {
    
    
    var hud : MBProgressHUD = MBProgressHUD()
    
    @IBOutlet weak var loginScrollView: UIScrollView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var LoginBtn: UIButton!
    @IBOutlet weak var cantRememberPasswordBtn: UIButton!
    @IBOutlet weak var loginFBBtn: UIButton!
    
    var loginBtnFrmae : CGRect = CGRectZero
    var webViewRedirectUrl : String = ""
    var webViewTitle : String = ""
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    @IBOutlet weak var registerBtn: UIButton!
    
    // alert views with actions
    
    var forgotPasswordAlert = UIAlertView()

    
    var authApi : AuthApi = AuthApi()
    var socialApi : SocialApi = SocialApi()
    
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!
    
    
    var bannerImg_View_Height_Constraint:NSLayoutConstraint!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        self.automaticallyAdjustsScrollViewInsets = false
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        
        
        utilities.textFieldBottomBorder(emailTextField)
        utilities.textFieldBottomBorder(passwordTextField)
        
        cantRememberPasswordBtn.contentHorizontalAlignment = .Right
        registerBtn.contentHorizontalAlignment = .Left
        LoginBtn.layer.cornerRadius = 8
        
        refreshTextFields()

        // Do any additional setup after loading the view, typically from a nib.
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        authApi.delegate = self
        socialApi.delegate = self
        
        
        signInButton.style = GIDSignInButtonStyle.IconOnly

        
        let clientTokenDict : NSMutableDictionary = NSMutableDictionary()
        clientTokenDict.setObject(CLIENT_ID, forKey: "client_id")
        clientTokenDict.setObject("client_credentials", forKey: "grant_type")
        clientTokenDict.setObject(CLIENT_SECRET, forKey: "client_secret")
        clientTokenDict.setObject("", forKey: "scope")
        
        self.addProgreeHud()
                
        
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
        utilities.addLogoImage(logoImageView)
        utilities.statusBarGradientAppear()
        
        
        authApi.getClientToken(clientTokenDict)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated);
        var failResponse = Dictionary<String, String>()
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if((utilities.nullToNil(defaults.objectForKey("webViewFailResponse") == nil)) != nil){
            failResponse = Dictionary<String, String>()
        }else{
            failResponse = defaults.objectForKey("user_id")! as! Dictionary
        }
        
        
        refreshTextFields()
        
        self.navigationController?.navigationBarHidden = true
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Button Actions
    
    
    @IBAction func loginBtnClicked(sender: AnyObject) {
        
        self.view.endEditing(true)
        
        let emailStr: String = emailTextField.text!
        let passwordStr: String = passwordTextField.text!
        
        if (emailStr.isEmpty && passwordStr.isEmpty){
            utilities.setPlaceHolder(USER_NAME_IN_VALID_PLACEHOLDER, validateText: "Invalid", textField: emailTextField)
            utilities.setPlaceHolder(PASSWORD_IN_VALID_PLACEHOLDER, validateText: "Invalid", textField: passwordTextField)
        }else if emailStr.isEmpty {
            utilities.setPlaceHolder(USER_NAME_IN_VALID_PLACEHOLDER, validateText: "Invalid", textField: emailTextField)
        }else if passwordStr.isEmpty{
            utilities.setPlaceHolder(PASSWORD_IN_VALID_PLACEHOLDER, validateText: "Invalid", textField: passwordTextField)
        }else{
            
            let loginDict : NSMutableDictionary = NSMutableDictionary()
            loginDict.setObject(emailStr, forKey: "username")
            loginDict.setObject(passwordStr, forKey: "password")
            loginDict.setObject(CLIENT_ID, forKey: "clientId")
            
            self.addProgreeHud()
            authApi.loginUser(loginDict)
        }
    }
    
    @IBAction func signUpBtnClicked(sender: AnyObject) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let registerVC: RegistrationVC = mainStoryboard.instantiateViewControllerWithIdentifier("RegistrationVC") as! RegistrationVC
        self.navigationController?.pushViewController(registerVC, animated: true)
    }
    
    @IBAction func resignBtnClikced(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    @IBAction func forgotPasswordBtnClicked(sender: AnyObject) {
        
        self.view.endEditing(true)
        refreshTextFields()
        forgotPasswordAlert.delegate = self
        forgotPasswordAlert.title = "Enter email id"
        forgotPasswordAlert.tag = 101
        forgotPasswordAlert.addButtonWithTitle("Cancel")
        forgotPasswordAlert.alertViewStyle = UIAlertViewStyle.PlainTextInput
        forgotPasswordAlert.addButtonWithTitle("Ok")
        forgotPasswordAlert.show()
    }
    
    
    // MARK: - TextField Delegate
    
    func textFieldDidBeginEditing(textField: UITextField){
        if(textField == emailTextField){
            utilities.setPlaceHolder(USER_NAME_VALID_PLACEHOLDER, validateText: "Valid", textField: emailTextField)
        }else if(textField == passwordTextField){
            utilities.setPlaceHolder(PASSWORD_VALID_PLACEHOLDER, validateText: "Valid", textField: passwordTextField)
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        
        if(textField == emailTextField){
            passwordTextField.becomeFirstResponder()
        }else{
            textField.resignFirstResponder()
        }
        return true
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
    
    
    // MARK: - Google Plus Delegate Methods
    
    
    func signInWillDispatch(signIn: GIDSignIn!, error: NSError!) {
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
//            let userId = user.userID                  // For client-side use only!
//            let idToken = user.authentication.idToken // Safe to send to the server
//            let name = user.profile.name
//            let email = user.profile.email
            let accessToken = user.authentication.accessToken // Safe to send to the server
            
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
    
    
    
    
    // MARK: - Git login
    
    @IBAction func gitLoginBtnClicked(sender: AnyObject) {
        webViewTitle = "GitHub"
        self.addProgreeHud()
        socialApi.socialWebLogin("gitHub")
    }
    
    // MARK: - Linked login
    
    @IBAction func linkedInLoginBtnClicked(sender: AnyObject) {
        webViewTitle = "Linked In"
        self.addProgreeHud()
        socialApi.socialWebLogin("linkedIn")
        
    }
    
    // MARK: - Instagram login
    
    @IBAction func instagramLoginBtnClicked(sender: AnyObject) {
        //        webViewTitle = "Instagram"
        //        self.addProgreeHud()
        //        socialApi.socialWebLogin("instagram")
        
        
        //        var instagramURL = NSURL(string:"instagram://app")
        
        UIApplication.sharedApplication().openURL(NSURL(string: "instagram://app")!)
        
        
    }
    
    
    // MARK: - Digits Login Methods
    
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        
        if(alertView == forgotPasswordAlert){
            if(buttonIndex == 1){
                let textField: UITextField = alertView.textFieldAtIndex(0)!
                if(textField.text == ""){
                    let alert = utilities.alertView("Alert", alertMsg: "Please enter email id",actionTitle: "Ok")
                    self.presentViewController(alert, animated: true, completion: nil)
                }else{
                    
                    let forgotPswDict : NSMutableDictionary = NSMutableDictionary()
                    forgotPswDict.setObject(textField.text!, forKey: "email")
                    
                    self.addProgreeHud()
                    authApi.forgotPassword(forgotPswDict)
                }
            }
        }
    }
    
    
    // MARK: - WebService Delegate Methods
    
    
    func handleClientTokenResponse(tokenEntity : TokenApiModel){
        
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        
        let accessToken = tokenEntity.access_token
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(accessToken, forKey: "access_token")
        defaults.setObject(tokenEntity.expires_in, forKey: "expires_in")
        defaults.setObject(tokenEntity.scope, forKey: "scope")
        
        defaults.synchronize()
    }
    
    func handleLogin(userEntity: NewMemberApiModel) {
        
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        
        if(userEntity.tokenApiModel != nil){
            
            let tokenEty : TokenApiModel = userEntity.tokenApiModel
            let memberEty : MemberApiModel = userEntity.memberApiModel
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
            
            
            self.performSegueWithIdentifier("LoginToDashboard", sender: self)
        }
    }
    
    func handleWebLinkLoginResponse(responseDict : NSDictionary){
        
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        
        if(responseDict["url"] != nil){
            self.webViewRedirectUrl = responseDict.objectForKey("url") as! String
            
//            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            //            var webViewVC: WebViewVC = mainStoryboard.instantiateViewControllerWithIdentifier("WebViewVC") as! WebViewVC
            //
            //            webViewVC.redirectUrl = webViewRedirectUrl
            //            webViewVC.headerTitle = webViewTitle
            //            webViewVC.parentView  = "LoginView"
            //            self.navigationController?.pushViewController(webViewVC, animated: true)
            
        }else{
            if(responseDict["message"] != nil){
                let alert = utilities.alertView("Alert", alertMsg: responseDict["message"] as! String, actionTitle: "Ok")
                self.presentViewController(alert, animated: true, completion: nil)
            }
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
        
        for i in 0 ..< messageCodeEntityArray.count {
            let messageCode : ValidationMessagesApiModel = messageCodeEntityArray.objectAtIndex(i) as! ValidationMessagesApiModel
            let messageStr = messageCode.message
            errorMessage.appendString(messageStr)
        }
        
        let alert = utilities.alertView("Alert", alertMsg: errorMessage as String,actionTitle: "Ok")
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    
    func refreshTextFields(){
        utilities.setPlaceHolder(USER_NAME_VALID_PLACEHOLDER, validateText: "Valid", textField: emailTextField)
        utilities.setPlaceHolder(PASSWORD_VALID_PLACEHOLDER, validateText: "Valid", textField: passwordTextField)
    }
    
    func addProgreeHud(){
        hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.mode = .Indeterminate
        hud.labelText = "Loading"
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "LoginToWebView") {
            // pass data to next view
            
            //            if let destinationVC = segue.destinationViewController as? WebViewVC{
            //                destinationVC.redirectUrl = webViewRedirectUrl
            //                destinationVC.headerTitle = webViewTitle
            //                destinationVC.parentView  = "LoginView"
            //            }
        }
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        if (GIDSignIn.sharedInstance().currentUser != nil) {
            let accessToken = GIDSignIn.sharedInstance().currentUser.authentication.accessToken
            // Use accessToken in your URL Requests Header
        }
    }
}