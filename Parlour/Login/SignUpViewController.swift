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

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func signUpNewUser(_ sender: UIButton) {

        guard
            let email = emailTextField.text
            else { print("Email Input error.")
                return
        }

        guard
            let password = passwordTextField.text
            else { print("Password Input error.")
                return
        }

        guard
            let confirmPassword = confirmPasswordTextField.text,
            confirmPassword == password
            else {

                let alert = UIAlertController(title: "Password error.",
                                              message: "ConfirmPassword is not equal Password.",
                                              preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                present(alert, animated: true)

                return
        }

        guard
            let userName = userNameTextField.text
            else { print("UserName Input error.")
                return
        }

        Auth.auth().createUser(withEmail: email, password: password, completion: { (_, error) in

            if let error = error {

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

                    }

                })

                self.progressHUD(loadingText: "Registering...")

                Auth.auth().signIn(withEmail: loginEmail, password: loginPassword, completion: nil)

                self.progressHUD(loadingText: "Register Success!")

                self.dismiss(animated: true)

            }

        })

    }

    @IBAction func cancelSignUpPage(_ sender: UIButton) {

        self.dismiss(animated: true)

    }

    func progressHUD(loadingText: String) {

        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = loadingText
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 3.0)

    }
}
