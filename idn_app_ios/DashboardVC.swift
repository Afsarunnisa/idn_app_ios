//
//  DashboardVC.swift
//  APIStarters
//
//  Created by afsarunnisa on 6/19/15.
//  Copyright (c) 2015 NBosTech. All rights reserved.
//

import Foundation
import UIKit

class DashboardVC: UIViewController {
//    @IBOutlet weak var menuButton:UIBarButtonItem!

    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var logoImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
//        self.navigationItem.backBarButtonItem = menuButton;

        if self.revealViewController() != nil {
            menuButton.addTarget(self.revealViewController(), action:#selector(self.revealViewController().revealToggle(_:)), forControlEvents: .TouchUpInside)

            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

        let imgHeight : CGFloat = bannerImageView.frame.size.height
        utilities.addGradientLayer(bannerImageView, height: Int(imgHeight))
        utilities.addLogoImage(logoImageView)

    }
    
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }
}