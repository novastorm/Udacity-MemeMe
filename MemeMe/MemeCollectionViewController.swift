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
        return (UIApplication.shared.delegate as! AppDelegate).memes
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateFlowLayout(view.frame.size)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        collectionView!.reloadData()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if flowLayout != nil {
            updateFlowLayout(size)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdentifier = "MemeCollectionViewCell"
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! MemeCollectionViewCell
        let meme = memes[(indexPath as NSIndexPath).item]
        
        // Set cell properties
        cell.imageView?.image = meme.memedImage
        
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print((indexPath as NSIndexPath).item)
        let detailVC = storyboard!.instantiateViewController(withIdentifier: "MemeDetailViewController") as! MemeDetailViewController
        
        detailVC.meme = memes[(indexPath as NSIndexPath).item]
        
        navigationController!.pushViewController(detailVC, animated: true)
    }
        
    func updateFlowLayout(_ size: CGSize) {
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
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }

}

class MemeCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
}
