//
//  FirstViewController.swift
//  WKWebViewSample
//
//  Created by Xing He on 9/22/17.
//  Copyright © 2017 Xing He. All rights reserved.
//

import UIKit
import WebKit

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pushButtonDidClicked(_ sender: Any) {
        let webViewController = WebViewController()
        navigationController?.pushViewController(webViewController, animated: true)
    }
}

