//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Adland Lee on 3/2/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {

    var meme: Meme!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = meme.memedImage
    }
    
    @IBAction func editMeme(sender: AnyObject) {
        let createMemeVC = storyboard!.instantiateViewControllerWithIdentifier("MemeCreateViewController") as! MemeCreateViewController
        createMemeVC.meme = meme
        navigationController!.presentViewController(createMemeVC, animated: true, completion: {
                createMemeVC.toolBar.hidden = true
            })
    }
}
