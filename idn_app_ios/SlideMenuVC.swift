//
//  SlideMenuVC.swift
//  APIStarters
//
//  Created by afsarunnisa on 6/19/15.
//  Copyright (c) 2015 NBosTech. All rights reserved.
//

import Foundation
import UIKit
import wavelabs_ios_client_api
import MBProgressHUD

class SlideMenuVC: UIViewController,UITableViewDelegate,getAuthApiResponseDelegate{

    
    var hud : MBProgressHUD = MBProgressHUD()

    @IBOutlet weak var sliderTableView: UITableView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    let menuArray: NSArray = [USER_DASHBOARD_STR, USER_PROFILE_STR, USER_CHANGE_PASSWORD_STR]
    
    var authApi : AuthApi = AuthApi()

    
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var userImage: UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authApi.delegate = self
        
        sliderTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.view.backgroundColor = UIColor(red: 56/255.0, green: 63/255.0, blue: 69/255.0, alpha: 1.0)
    
        let currentMemberName : String = NSUserDefaults.standardUserDefaults().objectForKey("currentMemberName") as! String
        userName.text = currentMemberName
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        let statusBar: UIView = UIApplication.sharedApplication().valueForKey("statusBar") as! UIView
        if statusBar.respondsToSelector(Selector("setBackgroundColor:")) {
            statusBar.backgroundColor = UIColor(red: 56/255.0, green: 63/255.0, blue: 69/255.0, alpha: 1.0)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        let statusBar: UIView = UIApplication.sharedApplication().valueForKey("statusBar") as! UIView
        if statusBar.respondsToSelector(Selector("setBackgroundColor:")) {
            statusBar.backgroundColor = UIColor.clearColor()
        }
    }
    
    @IBAction func logoutBtnClick(sender: AnyObject) {
        self.addProgreeHud()
        authApi.logOut()
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return menuArray.count
    }

    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell!  {

        let cell = tableView.dequeueReusableCellWithIdentifier("CELL", forIndexPath: indexPath)

        //we know that cell is not empty now so we use ! to force unwrapping
        
        cell.contentView.backgroundColor = UIColor.clearColor()
        cell.textLabel!.text = menuArray.objectAtIndex(indexPath.row) as? String
        cell.textLabel!.textColor = UIColor.whiteColor()
        cell.selectionStyle  = UITableViewCellSelectionStyle.None
        
        return cell
    }

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cellText: String = menuArray.objectAtIndex(indexPath.row) as! String
        
        if(cellText == USER_LOGOUT_STR){
            self.addProgreeHud()
            authApi.logOut()
            
        }else if(cellText == USER_DASHBOARD_STR){
            performSegueWithIdentifier("menuToDashboard", sender: self)
        }else if(cellText == USER_PROFILE_STR){
            performSegueWithIdentifier("menuToSettings", sender: self)
        }else if(cellText == USER_CHANGE_PASSWORD_STR){
            performSegueWithIdentifier("menuToChangepassword", sender: self)
        }else if(cellText == USER_SOCIAL_LINKS_STR){
            performSegueWithIdentifier("menuToSocialLinks", sender: self)
        }
    }

    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 48
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

    
    func handleLogOut(messageCodeEntity : MessagesApiModel){
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        self.performSegueWithIdentifier("menuToLogin", sender: self)
    }

    func addProgreeHud(){
        hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.mode = .Indeterminate
        hud.labelText = "Loading"
    }
}