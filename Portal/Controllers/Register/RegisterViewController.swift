//
//  RegisterViewController.swift
//  Portal
//
//  Created by Evan Renanto on 29/07/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import UIKit
import AuthenticationServices

class RegisterViewController: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    let url : URL? = URL(string: "https://start-cons.com/wp-content/uploads/2019/03/person-dummy-e1553259379744.jpg")
//    let path = Bundle.main.path(forResource: "Lounge Logo", ofType: "png")
//
//    var url : URL?
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    
    @IBOutlet weak var btnSkipForNow: UIButton!
    @IBOutlet weak var appleIDStackView: UIStackView!
    
    @IBAction func skipForNow(_ sender: Any) {
        dismissAndBack()
    }
    
    
    
//    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
////        if let navController = presentingViewController as? MainTabBarController {
////                  navController.selectedIndex = 0
////              }
//
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modalPresentationStyle = .fullScreen
        // Do any additional setup after loading the view.
        
        setupProviderLoginView()
        
        
    }
    
    func setupProviderLoginView() {
        let authorizationButton = ASAuthorizationAppleIDButton(type: .default, style: .white)
        authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
//        authorizationButton.cornerRadius = 20
        
        self.appleIDStackView.addArrangedSubview(authorizationButton)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    @objc
    func handleAuthorizationAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            let userId = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            // save preference
            PreferenceManager.instance.isUserLogin = true
            PreferenceManager.instance.userEmail = email
            PreferenceManager.instance.userName = "\(fullName?.givenName ?? "")"
            PreferenceManager.instance.userId = "\(userId)"
            self.saveNewMembers(fullName: fullName?.givenName ?? "", email: email ?? "", userId: userId)
//            delay(0.5) {
//                let predicate = NSPredicate(format: "%K == %@", argumentArray: ["email", "\(email)"])
//                User.query(predicate: predicate, result: { (users) in
//                    if let users = users, users.count == 0 {
//                        self.saveNewMembers(fullName: fullName?.givenName ?? "", email: email, userId: userId)
//                    } else {
//                        DispatchQueue.main.async {
//                            self.dismiss(animated: true, completion: nil)
//                        }
//                    }
//                }) { (error) in
//                    print(error)
//                }
//            }
        case let passwordCredential as ASPasswordCredential:
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            print("passwordCredential.username : \(username)")
            print("passwordCredential.password : \(password)")
            
            self.dismiss(animated: true, completion: nil)
        default:
            break
        }
    }
    
//      init(name: String, email: String, photoUrl: URL, userId : String, followers : Int?, following : Int?, lpm : Int?, status : String){
    
    func saveNewMembers(fullName: String, email: String, userId : String) {
//        guard let url = URL(fileURLWithPath: path ?? <#default value#>,
//                            isDirectory: ((try? Data(contentsOf: url ?? <#default value#>)) != nil),
//       else { return }
        self.showIndicator()
        User(name: "\(fullName)", email: "\(email)", userId : "\(userId)", followers: 0, following:  0, lpm:  0, status: "" ).save(result: { (result) in
            print(result!)
            DispatchQueue.main.async {
                self.dismissAndBack()
                self.hideIndicator()
            }
            
        }) { (error) in
            print(error!)
            self.hideIndicator()
        }
    }
    
    func dismissAndBack(){
        if let navController = presentingViewController as? MainTabBarController {
            navController.selectedIndex = 0
        }
        self.dismiss(animated: true, completion: nil)
    }
}
