//
//  ViewController.swift
//  polyjuice
//
//  Created by DJ on 2018. 3. 7..
//  Copyright © 2018년 DJ. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let testImg = "000001.jpg"
    let testImg2 = "065084.jpg"
    @IBOutlet weak var personImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Initializing ...")
        self.personImage.image=UIImage(named: testImg)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func convertButton(_ sender: UIButton) {
        self.personImage.image=UIImage(named: testImg2)
        
    }
    
}

