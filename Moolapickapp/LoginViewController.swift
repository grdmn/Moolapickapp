//
//  LoginViewController.swift
//  Moolapickapp
//
//  Created by Apple Macintosh on 12/18/16.
//  Copyright © 2016 Apple Macintosh. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase


class LoginViewController: UIViewController {
    
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    var authListener: FIRAuthStateDidChangeListenerHandle?
    
    
    @IBAction func loginButtonTouch(_ sender: Any) {
        goToProfilePage()
        
        FIRAnalytics.logEvent(withName: "press_button", parameters: nil)
        
        FIRAuth.auth()?.signIn(withEmail: usernameTextField.text!, password: passwordTextField.text!) { (user, error) in
            if let error = error {
                AppDelegate.showAlertMsg(withViewController: self, message: error.localizedDescription)
            }
        }
        
        
    }
    

    @IBAction func registerButtonTouch(_ sender: Any) {
        
        guard let _ = usernameTextField.text, let _ = passwordTextField.text else{
            print("form is not valid")
            return
        }
        
        FIRAuth.auth()?.createUser(withEmail: usernameTextField.text!, password: passwordTextField.text!) { (user: FIRUser?, error) in
            if let error = error {
                AppDelegate.showAlertMsg(withViewController: self, message: error.localizedDescription)
            }
        
            guard let uid = user?.uid else{
                return
            }
            
            let email = self.usernameTextField.text!
            let password = self.passwordTextField.text!
            
            let ref = FIRDatabase.database().reference(fromURL: "https://moolapickapplication.firebaseio.com/")
            let userRef = ref.child("users").child(uid)
            let values = ["email":email, "password":password]
            userRef.updateChildValues(values, withCompletionBlock: {
                (err,ref) in
                
                if err != nil{
                    print(err)
                    return
                }
                
                self.dismiss(animated: true, completion: nil)
                
            })
            
            
            
            
            
        }
        
    
    
        
    }
    
    @IBAction func resetPasswordButtonTouch(_ sender: Any) {
        
        let resetPasswordAlert = UIAlertController(title: "Reset Password", message: nil, preferredStyle: .alert)
        resetPasswordAlert.addTextField { (textField: UITextField) in
            textField.placeholder = "Enter your email"
            textField.clearButtonMode = .whileEditing
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (action: UIAlertAction) in
            let textField = resetPasswordAlert.textFields![0]
            
            FIRAuth.auth()?.sendPasswordReset(withEmail: textField.text!) { error in
                if let error = error {
                    AppDelegate.showAlertMsg(withViewController: self, message: error.localizedDescription)
                } else {
                    AppDelegate.showAlertMsg(withViewController: self, message: "Password reset email was sent")
                }
            }
            
        }
        
        resetPasswordAlert.addAction(cancelAction)
        resetPasswordAlert.addAction(confirmAction)
        self.present(resetPasswordAlert, animated: true, completion: nil)
    }
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        authListener = FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            if let _ = user {
                self.goToProfilePage()
            }
        })
        
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        FIRAuth.auth()?.removeStateDidChangeListener(authListener!)
        
    }
    
    func goToProfilePage() {
        let profileNav = self.storyboard?.instantiateViewController(withIdentifier: "NavProfileViewController")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = profileNav
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
