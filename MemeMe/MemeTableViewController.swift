//
//  MemeTableViewController.swift
//  MemeMe
//
//  Created by Adland Lee on 2/21/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import UIKit

class MemeTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var memes: [Meme] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        (self.view as! UITableView).reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memes.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "MemeCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)!
        let meme = self.memes[indexPath.row]
        
        // Set the name and image
        cell.imageView?.image = meme.memedImage
        cell.textLabel?.text = "\(meme.topText!) \(meme.bottomText!)"
        
        return cell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "CreateMeme":
            break
        case "ShowMeme":
            print("ShowMeme")
            let MemeVC = segue.destinationViewController as! MemeViewController
            MemeVC.meme = memes[(self.view as! UITableView).indexPathForSelectedRow!.row]
        default:
            print("Undefined")
        }
    }
}
