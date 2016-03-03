//
//  MemeCollectionViewController.swift
//  MemeMe
//
//  Created by Adland Lee on 3/2/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import UIKit

class MemeCollectionViewController: UICollectionViewController {
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!

    var memes: [Meme] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateFlowLayout(self.view.frame.size)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = false
        self.collectionView!.reloadData()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        if flowLayout != nil {
            self.updateFlowLayout(size)
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.memes.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cellIdentifier = "MemeCollectionViewCell"
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! MemeCollectionViewCell
        let meme = self.memes[indexPath.item]
        
        // Set cell properties
        cell.imageView?.image = meme.memedImage
        
        return cell
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print(indexPath.item)
        let detailVC = self.storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        
        detailVC.meme = self.memes[indexPath.item]
        
        self.navigationController!.pushViewController(detailVC, animated: true)
    }
        
    func updateFlowLayout(size: CGSize) {
        let space: CGFloat = 3.0
        var dimension: CGFloat!
        if size.height > size.width {
            dimension = (size.width - (2 * space)) / 3.0
        }
        else {
            dimension = (size.width - (4 * space)) / 5.0
        }
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSizeMake(dimension, dimension)
    }

}

class MemeCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
}
