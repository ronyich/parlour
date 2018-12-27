//
//  ViewController.swift
//  Parlour
//
//  Created by Ron Yi on 2018/11/27.
//  Copyright © 2018 Ron Yi. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD
import Crashlytics
import NotificationBannerSwift

class LoginViewController: UIViewController {

    var user: User?

    var userDefault = UserDefaults.standard

    static let shared: LoginViewController = LoginViewController()

    weak var delegate: UserManagerDelegate?

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        Auth.auth().addStateDidChangeListener { (_, user) in

            guard
                let user = user
                else {
                    print("User is nil.")
                    return
            }

            self.user = User(authData: user)

            self.performSegue(withIdentifier: "Segue_To_NavigationController", sender: self)

            self.emailTextField.text = ""
            self.passwordTextField.text = ""

            guard
                let userID = self.user?.uid
                else { print("userID is nil in Login.")
                    return
            }

            self.userDefault.set(userID, forKey: "userID")
            self.userDefault.synchronize()

        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapViewToEndEditing))
        self.view.addGestureRecognizer(tapGesture)

    }

    @IBAction func loginToHomePage(_ sender: UIButton) {

        guard
            let email = emailTextField.text,
            let password = passwordTextField.text,
            email.count > 0,
            password.count > 0
            else {
                return
        }

        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in

            if let error = error, user == nil {

                let banner = NotificationBanner(title: NSLocalizedString("Login Failed", comment: ""), subtitle: NSLocalizedString("Please check email adress and password.", comment: ""), style: .info)

                banner.show()

                print(error)

            } else {

                self.progressHUD(loadingText: "Loading...")

                self.emailTextField.text = ""
                self.passwordTextField.text = ""

                self.performSegue(withIdentifier: "Segue_To_NavigationController", sender: self)

            }

        }

        Analytics.logEvent("Login_To_Home_Page", parameters: nil)

    }

    @IBAction func signUpNewUser(_ sender: UIButton) {

        performSegue(withIdentifier: "Segue_To_SignUpViewController", sender: self)

        Analytics.logEvent("Go_To_Sign_Up_New_User_Page", parameters: nil)

    }

    func progressHUD(loadingText: String) {

        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = loadingText
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 3.0)

        Analytics.logEvent("Sign_Up_New_User", parameters: nil)

    }

    @objc func tapViewToEndEditing() {

        emailTextField.endEditing(true)
        passwordTextField.endEditing(true)

    }

}
