//
//  MenuViewController.swift
//  JWPlayer Ads
//
//  Created by Elisabet Massó on 28/1/22.
//  Copyright © 2022 NPAW. All rights reserved.
//

import UIKit
import YouboraLib
import YouboraConfigUtils

class MenuViewController: UIViewController {
    
    @IBOutlet weak var resourceTf: UITextField!
    @IBOutlet weak var adsSwitch: UISwitch!
    @IBOutlet weak var playBtn: UIButton!
    
    var plugin: YBPlugin?

    override func viewDidLoad() {
        super.viewDidLoad()

        YBLog.setDebugLevel(.debug)
        
        addSettingsButton()
        
        resourceTf.text = "http://qthttp.apple.com.edgesuite.net/1010qwoeiuryfg/sl.m3u8"
        adsSwitch.isOn = false
    }
    
    public static func initFromXIB() -> MenuViewController? {
        return MenuViewController(nibName: String(describing: MenuViewController.self), bundle: Bundle(for: MenuViewController.self))
    }

}

// MARK: - Settings Section
extension MenuViewController {
    
    func addSettingsButton() {
        guard let navigationController = self.navigationController else { return }
        addSettingsToNavigation(navigationBar: navigationController.navigationBar)
    }
    
    func addSettingsToNavigation(navigationBar: UINavigationBar) {
        let settingsButton = UIBarButtonItem(title: "Settings", style: .done, target: self, action: #selector(navigateToSettings))
        navigationBar.topItem?.rightBarButtonItem = settingsButton
    }
    
}

// MARK: - Navigation Section
extension MenuViewController {
    
    @IBAction func sendOfflineEvents(_ sender: UIButton) {
        let options = YouboraConfigManager.getOptions()
        options.offline = false
        
        plugin = YBPlugin(options: options)
        
        for _ in 1...3 {
            plugin?.fireOfflineEvents()
        }
    }
    
    @IBAction func playButton(_ sender: UIButton) {
        if sender == playBtn {
            let playerViewController = ViewController()
            
            playerViewController.resource = resourceTf.text
            playerViewController.containAds = adsSwitch.isOn
            
            navigateToViewController(viewController: playerViewController)
            return
        }
    }

    @objc func navigateToSettings() {
        guard let _ = navigationController else {
            navigateToViewController(viewController: YouboraConfigViewController.initFromXIB(animatedNavigation: false))
            return
        }
        
        navigateToViewController(viewController: YouboraConfigViewController.initFromXIB())
    }
    
    func navigateToViewController(viewController: UIViewController) {
        guard let navigationController = navigationController else {
            present(viewController, animated: true, completion: nil)
            return
        }
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
}
