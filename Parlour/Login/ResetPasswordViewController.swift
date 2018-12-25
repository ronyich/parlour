//
//  ResetPasswordViewController.swift
//  Parlour
//
//  Created by Ron Yi on 2018/11/27.
//  Copyright © 2018 Ron Yi. All rights reserved.
//

import UIKit
import Firebase
import Crashlytics

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapViewToEndEditing))
        self.view.addGestureRecognizer(tapGesture)

    }

    @IBAction func sendResetPasswordAddressToEmail(_ sender: UIButton) {

        guard
            let email = emailTextField.text
            else {
                let alert = UIAlertController(title: NSLocalizedString("Input error.", comment: ""),
                                              message: NSLocalizedString("Please input your email address for password reset.", comment: ""),
                                              preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "OK", style: .cancel))

                present(alert, animated: true)

                return
        }

        Auth.auth().sendPasswordReset(withEmail: email) { (error) in

            let title = (error == nil) ? NSLocalizedString("Password reset Follow-up.", comment: "") : NSLocalizedString("Password reset Error.", comment: "")

            let message = (error == nil) ? NSLocalizedString("We have just sent you a password reset email. Please check your inbox and follow the instructions to reset your password.", comment: "") : error?.localizedDescription

            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: { (_) in

                if error == nil {

                    self.view.endEditing(true)

                    self.dismiss(animated: true)

                }

            })

            alert.addAction(okAction)

            self.present(alert, animated: true)

        }

        Analytics.logEvent("Send_Reset_Password_Address_To_Email", parameters: nil)

    }

    @IBAction func cancelResetPasswordPage(_ sender: UIButton) {

        self.dismiss(animated: true)

        Analytics.logEvent("Cancel_Reset_Password_Page", parameters: nil)

    }

    @objc func tapViewToEndEditing() {

        emailTextField.endEditing(true)

    }

}
