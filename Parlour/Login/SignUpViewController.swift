//
//  SignUpViewController.swift
//  Parlour
//
//  Created by Ron Yi on 2018/11/27.
//  Copyright © 2018 Ron Yi. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD
import NotificationBannerSwift
import Crashlytics

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapViewToEndEditing))
        self.view.addGestureRecognizer(tapGesture)

    }

    @IBAction func signUpNewUser(_ sender: UIButton) {

        guard
            let email = emailTextField.text,
            email.count >= 7
            else {

                let banner = NotificationBanner(title: NSLocalizedString("Notification", comment: ""), subtitle: NSLocalizedString("Please check email adress format, or this email is already in use by another account.", comment: ""), style: .info)

                banner.show()

                return
        }

        guard
            let password = passwordTextField.text,
            password.count >= 6
            else {

                let banner = NotificationBanner(title: NSLocalizedString("Notification", comment: ""), subtitle: NSLocalizedString("Password must over 5 character.", comment: ""), style: .info)

                banner.show()

                return
        }

        guard
            let confirmPassword = confirmPasswordTextField.text,
            confirmPassword == password
            else {

                let banner = NotificationBanner(title: NSLocalizedString("Password error.", comment: ""), subtitle: NSLocalizedString("ConfirmPassword is not equal Password.", comment: ""), style: .info)

                banner.show()

                return
        }

        guard
            let userName = userNameTextField.text,
            userName.count >= 1
            else {

                let banner = NotificationBanner(title: NSLocalizedString("Notification", comment: ""), subtitle: NSLocalizedString("UserName must over 0 character, or UserName already sign up.", comment: ""), style: .info)

                banner.show()

                return
        }

        Auth.auth().createUser(withEmail: email, password: password, completion: { (_, error) in

            if let error = error {

                let banner = NotificationBanner(title: NSLocalizedString("Notification", comment: ""), subtitle: NSLocalizedString("Please check email adress format, or this email is already in use by another account.", comment: ""), style: .info)

                banner.show()

                print("Create new user authorization error.", error.localizedDescription)

            } else {

                guard
                    let loginEmail = self.emailTextField.text,
                    let loginPassword = self.passwordTextField.text
                    else { print("Login Email or Password error.")
                        return
                }

                guard
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    else { print("ChangeRequest is nil.")
                        return
                }

                changeRequest.displayName = userName

                changeRequest.commitChanges(completion: { (error) in

                    if let error = error {

                        print("Fail to change displayName:\(error.localizedDescription)")

                    } else {

                        self.progressHUD(loadingText: "Registering...")

                        Auth.auth().signIn(withEmail: loginEmail, password: loginPassword, completion: nil)

                        self.progressHUD(loadingText: "Register Success!")

                        self.emailTextField.text = ""
                        self.passwordTextField.text = ""
                        self.confirmPasswordTextField.text = ""
                        self.userNameTextField.text = ""

                        self.performSegue(withIdentifier: "Segue_To_NavigationController", sender: nil)

                    }

                })

            }

        })

    }

    @IBAction func cancelSignUpPage(_ sender: UIButton) {

        self.dismiss(animated: true)

        Analytics.logEvent("Cancel_Sign_Up_Page", parameters: nil)

    }

    func progressHUD(loadingText: String) {

        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = loadingText
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 3.0)

    }

    @objc func tapViewToEndEditing() {

        emailTextField.endEditing(true)
        passwordTextField.endEditing(true)
        confirmPasswordTextField.endEditing(true)
        userNameTextField.endEditing(true)

    }

}
