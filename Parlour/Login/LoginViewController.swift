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

class LoginViewController: UIViewController {

    var user: User?

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

            self.performSegue(withIdentifier: "Segue_To_TabBarController", sender: self)

            self.emailTextField.text = nil
            self.passwordTextField.text = nil

        }
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

                self.progressHUD(loadingText: "Loading...")

                let alert = UIAlertController(title: "Sign in failed", message: error.localizedDescription, preferredStyle: .alert)

                let okAction = UIAlertAction(title: "OK", style: .default)

                alert.addAction(okAction)

                self.present(alert, animated: true)

            } else {

                self.performSegue(withIdentifier: "Segue_To_TabBarController", sender: self)
            }

        }

    }

    @IBAction func signUpNewUser(_ sender: UIButton) {

        performSegue(withIdentifier: "Segue_To_SignUpViewController", sender: self)

    }

    func progressHUD(loadingText: String) {

        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = loadingText
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 3.0)

    }

}
