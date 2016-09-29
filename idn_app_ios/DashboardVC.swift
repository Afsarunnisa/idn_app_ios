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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
//        self.navigationItem.backBarButtonItem = menuButton;

        if self.revealViewController() != nil {
//            menuButton.target = self.revealViewController()
//            menuButton.action = "revealToggle:"
            
            
            menuButton.addTarget(self.revealViewController(), action:#selector(self.revealViewController().revealToggle(_:)), forControlEvents: .TouchUpInside)

            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        
//        let gradient = CAGradientLayer()
//        gradient.name = "ImgGradientLayer"
//        gradient.frame = bannerImageView.frame
//        gradient.colors = [
//            UIColor(white: 0, alpha: 0.1).CGColor,
//            UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.7).CGColor
//        ]
//        
//        bannerImageView.layer.insertSublayer(gradient, atIndex: 0)

        let imgHeight : CGFloat = bannerImageView.frame.size.height
        utilities.addGradientLayer(bannerImageView, height: Int(imgHeight))

    }
    
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }
}