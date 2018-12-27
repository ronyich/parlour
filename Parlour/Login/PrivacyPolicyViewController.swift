//
//  PrivacyPolicyViewController.swift
//  Parlour
//
//  Created by Ron Yi on 2018/12/27.
//  Copyright © 2018 Ron Yi. All rights reserved.
//

import UIKit

class PrivacyPolicyViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard
            let url = URL(string: "https://privacypolicies.com/privacy/view/9303db62f733d9e5580b46d7940ac298")
            else { print(URLError.badURL)
                return
        }

        webView.loadRequest(URLRequest(url: url))

    }

    @IBAction func cancelPrivacyPolicyPage(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)

    }

}
