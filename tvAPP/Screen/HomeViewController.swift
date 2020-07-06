//
//  HomeViewController.swift
//  tvAPP
//
//  Created by Felipe Petersen on 03/07/20.
//  Copyright © 2020 Zewu Chen. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var selectionView: SelectionController!
    @IBOutlet weak var playButtonOutlet: UIButton!
    
//    var instantCol = 0
//    var instantRow = 0
    var instantPos = (0,0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.playButtonOutlet.isEnabled = false
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        self.view.addGestureRecognizer(tap)

        // Do any additional setup after loading the view.
    }
    
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            print("Swipe Right")
            let finalPos = self.selectionView.changePos(instantPos: instantPos, swipe: .right)
            self.instantPos = finalPos
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            print("Swipe Left")
            let finalPos = self.selectionView.changePos(instantPos: instantPos, swipe: .left)
            self.instantPos = finalPos
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.up {
            print("Swipe Up")
            let finalPos = self.selectionView.changePos(instantPos: instantPos, swipe: .up)
            self.instantPos = finalPos
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.down {
            print("Down")
            let finalPos = self.selectionView.changePos(instantPos: instantPos, swipe: .down)
            self.instantPos = finalPos
        }
    }
    
    @objc func didTap() {
        let worked = self.selectionView.selectItem(instantPos: instantPos)
        self.view.gestureRecognizers?.removeAll()
        playButtonOutlet.isEnabled = true
        playButtonOutlet.becomeFirstResponder()
        self.playButtonOutlet.setTitleColor(.white, for: .normal)
        self.playButtonOutlet.tintColor = .white
        self.view.setNeedsDisplay()
//        self.reloadInputViews()
    }
    
    @IBAction func didTapPlay(_ sender: Any) {
        print("Play")
    }
    

}
