//
//  ResetPasswordViewController.swift
//  Parlour
//
//  Created by Ron Yi on 2018/11/27.
//  Copyright © 2018 Ron Yi. All rights reserved.
//

import UIKit
import Firebase

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()


    }

    @IBAction func sendResetPasswordAddressToEmail(_ sender: UIButton) {

        guard
            let email = emailTextField.text
            else {
                let alert = UIAlertController(title: "Input error.",
                                              message: "Please input your email address for password reset.",
                                              preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "OK", style: .cancel))

                present(alert, animated: true)

                return
        }

        Auth.auth().sendPasswordReset(withEmail: email) { (error) in

            let title = (error == nil) ? "Password reset Follow-up." : "Password reset Error."

            let message = (error == nil) ? "We have just sent you a password reset email. Please check your inbox and follow the instructions to reset your password." : error?.localizedDescription

            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: { (action) in

                if error == nil {

                    self.view.endEditing(true)

                    self.dismiss(animated: true)

                }

            })

            alert.addAction(okAction)

            self.present(alert, animated: true)

        }

    }

    @IBAction func cancelResetPasswordPage(_ sender: UIButton) {
        
        self.dismiss(animated: true)
        
    }

}
