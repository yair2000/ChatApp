// FlowController.swift
// ChatApp (Login or Not)

import UIKit
import Firebase

class FlowController: NSObject
{
    weak var window : UIWindow?
    static let shared = FlowController()
    
    func determineRootViewController(){
        
        let didLogin = Auth.auth().currentUser != nil
        let storyboardName = didLogin ? "Main" : "Login"
        let storyboad = UIStoryboard(name: storyboardName, bundle: .main)
        let vc = storyboad.instantiateInitialViewController()
        window?.rootViewController = vc
    }
}
