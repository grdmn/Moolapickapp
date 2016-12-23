//
//  ProfileViewController.swift
//  Moolapickapp
//
//  Created by Apple Macintosh on 12/18/16.
//  Copyright © 2016 Apple Macintosh. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ProfileViewController: UIViewController {
    
    let usernameRef = FIRDatabase.database().reference().child("user")
    let savingmoneyRef = FIRDatabase.database().reference().child("savingmoney")

    
    @IBOutlet weak var emailValueLabel: UILabel!
    
    @IBOutlet weak var nameValueLabel: UILabel!
    
    @IBOutlet weak var photoUrlValueLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let user = FIRAuth.auth()?.currentUser {
            setUserDataToView(withFIRUser: user)
            
            let logoutBarButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout))
            let manageProfileBarButton = UIBarButtonItem(title: "Manage", style: .plain, target: self, action: #selector(manageProfile))
            self.navigationItem.leftBarButtonItem = logoutBarButton
            self.navigationItem.rightBarButtonItem = manageProfileBarButton
        
    }
        
}
    
    func setUserDataToView(withFIRUser user: FIRUser) {
        emailValueLabel.text = user.email
        nameValueLabel.text = user.displayName
//        photoUrlValueLabel.text = user.photoURL?.absoluteString
    }
    
    //MARK :-Method
    func logout() {
        let loginNav = self.storyboard?.instantiateViewController(withIdentifier: "NavLoginViewController")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = loginNav
        
        try! FIRAuth.auth()!.signOut()
        
    }
    
    func manageProfile() {
        let manageActionSheet = UIAlertController(title: "Select menu", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        let changeUserInfoAction = UIAlertAction(title: "Change name", style: .default) { (action: UIAlertAction) in
            self.changeUserInfo()
        }
        
        let changeEmailAction = UIAlertAction(title: "Change Email", style: .default) { (action: UIAlertAction) in
            self.changeEmail()
        }
        
        if let user = FIRAuth.auth()?.currentUser, !user.isEmailVerified {
            let verifyAccountAction = UIAlertAction(title: "Verify Account", style: .default) { (action: UIAlertAction) in
                self.sentVerifiedEmail()
            }
            manageActionSheet.addAction(verifyAccountAction)
        }
        
        let changePasswordAction = UIAlertAction(title: "Change Password", style: .default) { (action: UIAlertAction) in
            self.changePassword()
        }
        
        let deleteAccountAction = UIAlertAction(title: "Delete Account", style: .default) { (action: UIAlertAction) in
            self.deleteAccount()
        }
        
        manageActionSheet.addAction(changeUserInfoAction)
        manageActionSheet.addAction(changePasswordAction)
        manageActionSheet.addAction(changeEmailAction)
        manageActionSheet.addAction(deleteAccountAction)
        manageActionSheet.addAction(cancelAction)
        
        self.present(manageActionSheet, animated: true, completion: nil)
    }
    
    func changeUserInfo() {
        let alert = UIAlertController(title: "Change name", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Enter your name"
            textField.clearButtonMode = .whileEditing
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (action: UIAlertAction) in
            let nameTextField = alert.textFields![0]
            let imageTextField = alert.textFields![1]
            
            if let user = FIRAuth.auth()?.currentUser {
                let changeRequest = user.profileChangeRequest()
                
                changeRequest.displayName = nameTextField.text
                changeRequest.photoURL = NSURL(string: imageTextField.text!) as? URL
                changeRequest.commitChanges { error in
                    if let error = error {
                        AppDelegate.showAlertMsg(withViewController: self, message: error.localizedDescription)
                    } else {
                        AppDelegate.showAlertMsg(withViewController: self, message: "Your profile was updated")
                        self.setUserDataToView(withFIRUser: user)
                    }
                }
            }
            
        }
        
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func changePassword() {
        let alert = UIAlertController(title: "Change Password", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Enter your new password"
            textField.clearButtonMode = .whileEditing
            textField.isSecureTextEntry = true
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (action: UIAlertAction) in
        let textField = alert.textFields![0]
            
            let user = FIRAuth.auth()?.currentUser
            user?.updatePassword(textField.text!) { error in
                if let error = error {
                    AppDelegate.showAlertMsg(withViewController: self, message: error.localizedDescription)
                } else {
                    AppDelegate.showAlertMsg(withViewController: self, message: "Password was updated")
                }
            
            }
            
        }
        
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func changeEmail() {
        let alert = UIAlertController(title: "Change Email", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Enter your new email"
            textField.clearButtonMode = .whileEditing
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (action: UIAlertAction) in
            let textField = alert.textFields![0]
            
            let user = FIRAuth.auth()?.currentUser
            user?.updateEmail(textField.text!) { error in
                if let error = error {
                    AppDelegate.showAlertMsg(withViewController: self, message: error.localizedDescription)
                } else {
                    AppDelegate.showAlertMsg(withViewController: self, message: "Email was updated. You have to login again.")
                    self.logout()
                }
            }
            
        }
        
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteAccount() {
        let alert = UIAlertController(title: "Delete Account", message: "This account will be deleted. This operation can not undo. Are you sure?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (action: UIAlertAction) in
            if let user = FIRAuth.auth()?.currentUser {
                let alert = UIAlertController(title: "Delete Account", message: "[\(user.email!)] will be deleted. This operation can not undo. Are you sure?", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
                let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (action: UIAlertAction) in
                    user.delete { error in
                        if let error = error {
                            AppDelegate.showAlertMsg(withViewController: self, message: error.localizedDescription)
                        } else {
                            AppDelegate.showAlertMsg(withViewController: self, message: "[\(user.email!)] was deleted")
                            self.logout()
                        }
                    }
                }
                
                alert.addAction(cancelAction)
                alert.addAction(confirmAction)
                self.present(alert, animated: true, completion: nil)
            }

            
            
        }
        
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func sentVerifiedEmail() {
        
        if let user = FIRAuth.auth()?.currentUser {
            user.sendEmailVerification() { error in
                if let error = error {
                    AppDelegate.showAlertMsg(withViewController: self, message: error.localizedDescription)
                } else {
                    AppDelegate.showAlertMsg(withViewController: self, message: "Email verification has been sent to [\(user.email!)]. Please check your email and verify it. Then login again.")
                    self.logout()
                }
            }
        }
        
    }
}
