//
//  SplashScreenViewController.swift
//  AnyForm
//
//  Created by נדב אבנון on 28/07/2021.
//

import UIKit

class SplashScreenViewController: UIViewController {

    @IBOutlet weak var logo: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        logo.alpha = 0
        UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.8, options: []) {
            self.logo.alpha = 1
        } completion: { (act) in
            let selector  = #selector(self.transitionToHome)
            self.perform(selector, with: nil, afterDelay: 0.5)
        }
   
    }
    @objc func transitionToHome() {
        let tabBar = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "tabBarController")
        tabBar.modalPresentationStyle = .overCurrentContext
        tabBar.modalTransitionStyle = .flipHorizontal
        
        guard let sb:UIStoryboard = self.storyboard else {return}

        self.dismiss(animated: false, completion: {
            let newController:UIViewController = sb.instantiateViewController(identifier: "tabBarController")
            newController.modalTransitionStyle = .crossDissolve
            newController.modalPresentationStyle = .fullScreen
            UIApplication.shared.keyWindow?.rootViewController?.present(newController, animated: true)
        })
        
        }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
