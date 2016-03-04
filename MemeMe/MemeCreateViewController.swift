//
//  MemeCreateViewController.swift
//  MemeMe
//
//  Created by Adland Lee on 2/6/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import UIKit

class MemeCreateViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
//    @IBOutlet weak var imageView: UIImageView!
    var imageView = UIImageView()
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var toolBar: UIToolbar!
    
    var viewShiftedForKeyboard = false
    var memedImage: UIImage!
    
    var meme: Meme?
    
    let memeTextAttributes = [
        NSStrokeColorAttributeName: UIColor.blackColor(),
        NSForegroundColorAttributeName: UIColor.whiteColor(),
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName: -3.0 // Negative for stroke and fill
    ]

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topText.defaultTextAttributes = memeTextAttributes
        bottomText.defaultTextAttributes = memeTextAttributes
        
        topText.textAlignment = .Center
        bottomText.textAlignment = .Center
        
        imageView.userInteractionEnabled = true
        imageView.frame = scrollView.bounds
//        imageView.backgroundColor = UIColor.greenColor()
        scrollView.addSubview(imageView)
        
        resetMemeEditor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
        
        if let meme = self.meme {
            self.topText.text = meme.topText
            self.bottomText.text = meme.bottomText
            self.imageView.image = meme.image
            if let image = meme.image, contentOffset = meme.contentOffset,
                zoomScale = meme.zoomScale {
                imageView.frame = CGRect(origin: scrollView.frame.origin, size:image.size)
                scrollView.contentSize = image.size

                let scrollViewFrame = scrollView.frame
                let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
                let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
                
                let minScale = min(scaleWidth, scaleHeight)
                let initialScale = zoomScale
                
                scrollView.minimumZoomScale = minScale
                scrollView.maximumZoomScale = 1.0
                scrollView.zoomScale = initialScale
                    
                scrollView.contentOffset = contentOffset
                
                centerScrollViewContents()
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }

    @IBAction func pickImageFromAlbum(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickImageFromCamera(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func shareMeme(sender: AnyObject) {
        generateMemedImage()
        let controller = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        presentViewController(controller, animated: true, completion: nil)
        self.save()
    }
    
    @IBAction func cancelEditing(sender: AnyObject) {
//        resetMemeEditor()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        self.centerScrollViewContents()
    }
    
    func centerScrollViewContents() {
        let boundsSize = scrollView.bounds.size
        var contentsFrame = imageView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2
        }
        else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2
        }
        else {
            contentsFrame.origin.y = 0.0
        }
        
        imageView.frame = contentsFrame
    }
    
    func resetMemeEditor() {
        topText.text = "TOP"
        bottomText.text = "BOTTOM"
        
        imageView.frame = CGRect(origin: CGPoint(x:0, y:0), size: scrollView.frame.size)
        imageView.image = nil
    }
    
    // MARK: - Keyboard
    
    func keyboardWillShow(notification: NSNotification) {
        if !viewShiftedForKeyboard {
            self.view.frame.origin.y -= getKeyboardHeight(notification)
            self.viewShiftedForKeyboard = true
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardFrame = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardFrame.CGRectValue().height
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if viewShiftedForKeyboard  {
            self.view.frame.origin.y += getKeyboardHeight(notification)
            self.viewShiftedForKeyboard = false
        }
    }
    
    // MARK: - Management
    
    func generateMemedImage() {
        // Hide toolbar and navbar
        self.navigationBar.hidden = true
        self.toolBar.hidden = true
        
        // Render view into an image
        var outputFrame = self.view.frame
        
        // set outputFrame drawing origin
        outputFrame.origin.y = scrollView.frame.origin.y * -1

        UIGraphicsBeginImageContext(self.scrollView.frame.size)
        self.view.drawViewHierarchyInRect(outputFrame, afterScreenUpdates: true)
        self.memedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar
        self.navigationBar.hidden = false
        self.toolBar.hidden = false
    }
    
    func save() {
        let topText = self.topText.text
        let bottomText = self.bottomText.text
        let image = imageView.image
        let imageOffset = scrollView.contentOffset
        let memedImage = self.memedImage.copy() as! UIImage
        
        let meme = Meme(topText: topText, bottomText: bottomText, image: image, zoomScale: scrollView.zoomScale, contentOffset: imageOffset, memedImage: memedImage)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.memes.append(meme)
    }
}

// MARK: - Navigation Controller Delegate

extension MemeCreateViewController: UINavigationControllerDelegate {}

// MARK: - Image Picker Controller Delegate

extension MemeCreateViewController: UIImagePickerControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            // reset zoomescale before changing image
            scrollView.zoomScale = 1.0

            imageView.image = image
            imageView.frame = CGRect(origin: scrollView.frame.origin, size:image.size)
            
            scrollView.contentSize = image.size
            
            let scrollViewFrame = scrollView.frame
            let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
            let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
            
            let minScale = min(scaleWidth, scaleHeight)
            let initialScale = max(scaleWidth, scaleHeight)
            
            scrollView.minimumZoomScale = minScale
            scrollView.maximumZoomScale = 1.0
            scrollView.zoomScale = initialScale
            
            centerScrollViewContents()
            
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

// MARK: - Scroll View Delegate

extension MemeCreateViewController: UIScrollViewDelegate {
    func scrollViewDidZoom(scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

// MARK: - Text Field Delegate

extension MemeCreateViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(textField: UITextField) {
        if (textField.text == "TOP") || (textField.text == "BOTTOM") {
            textField.text = ""
        }
        if textField == bottomText {
            self.subscribeToKeyboardNotifications()
        }
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if textField == bottomText {
            self.unsubscribeFromKeyboardNotifications()
        }
        
        return true;
    }
    
}
