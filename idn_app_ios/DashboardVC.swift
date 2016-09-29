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
    @IBOutlet weak var menuButton:UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
      
        self.navigationItem.backBarButtonItem = menuButton;

        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }
}