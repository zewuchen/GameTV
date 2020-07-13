//
//  SearchViewController.swift
//  iosAPP
//
//  Created by Zewu Chen on 08/07/20.
//  Copyright © 2020 Zewu Chen. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class SearchViewController: UIViewController, MultipeerHandler {

    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    var enableConnectivity = true

    override func viewDidLoad() {
        super.viewDidLoad()
        MultipeerController.shared().delegate = self
    }

    func peerDiscovered(_ id: MCPeerID) -> Bool {

        if enableConnectivity {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let vc = storyboard.instantiateViewController(identifier: "viewController") as? ViewController {
                vc.host = id
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }

            return true
        }
        
        return false
    }

    override func viewWillAppear(_ animated: Bool) {
        loadingView.startAnimating()
    }

    override func viewWillDisappear(_ animated: Bool) {
        loadingView.stopAnimating()
        enableConnectivity = false
    }

    func peerLost(_ id: MCPeerID) { }

}
