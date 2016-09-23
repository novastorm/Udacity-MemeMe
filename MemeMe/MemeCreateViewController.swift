//
//  MemeCreateViewController.swift
//  MemeMe
//
//  Created by Adland Lee on 2/6/16.
//  Copyright © 2016 Adland Lee. All rights reserved.
//

import UIKit

class MemeCreateViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var scrollView: UIScrollView!
//    @IBOutlet weak var imageView: UIImageView!
    var imageView = UIImageView()
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var toolBar: UIToolbar!
    
    var viewShiftedForKeyboard = false
//    var memedImage: UIImage!
    
    var meme: Meme?
    
    let memeTextAttributes = [
        NSStrokeColorAttributeName: UIColor.blackColor(),
        NSForegroundColorAttributeName: UIColor.whiteColor(),
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName: -3.0 // Negative for stroke and fill
    ]
    
    
    // MARK: - View Life Cycle
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        
        topTextField.textAlignment = .Center
        bottomTextField.textAlignment = .Center
        
        imageView.userInteractionEnabled = true
        imageView.frame = scrollView.bounds
//        imageView.backgroundColor = UIColor.greenColor()
        scrollView.addSubview(imageView)
        
        resetMemeEditor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
        
        if let meme = meme {
            topTextField.text = meme.topText
            bottomTextField.text = meme.bottomText
            imageView.image = meme.image
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
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        centerScrollViewContents()
    }

    
    // MARK: - Actions
    
    @IBAction func pickImageFromAlbum(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickImageFromCamera(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func shareMeme(sender: AnyObject) {
        let memedImage = generateMemedImage()
        let controller = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        controller.completionWithItemsHandler = {
            (activityType: String?, completed: Bool, returnedItems: [AnyObject]?, activityError: NSError?) -> Void in
            if completed {
                self.saveMeme(
                    image: self.imageView.image!,
                    topText: self.topTextField.text,
                    bottomText: self.bottomTextField.text,
                    zoomScale: self.scrollView.zoomScale,
                    contentOffset: self.scrollView.contentOffset,
                    memedImage: memedImage
                )
            }
            else {
                controller.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
        presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func cancelEditing(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    // MARK: - Helpers
    
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
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        
        imageView.frame = CGRect(origin: CGPoint(x:0, y:0), size: scrollView.frame.size)
        imageView.image = nil
    }
    
    // MARK: - Keyboard
    
    func keyboardWillShow(notification: NSNotification) {
//        if !viewShiftedForKeyboard {
//            view.frame.origin.y -= getKeyboardHeight(notification)
//            viewShiftedForKeyboard = true
//        }
        view.frame.origin.y = -getKeyboardHeight(notification)
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardFrame = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardFrame.CGRectValue().height
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeCreateViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeCreateViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillHide(notification: NSNotification) {
//        if viewShiftedForKeyboard  {
//            view.frame.origin.y += getKeyboardHeight(notification)
//            viewShiftedForKeyboard = false
//        }
        view.frame.origin.y = 0
    }
    
    // MARK: - Management
    
    func generateMemedImage() -> UIImage {
        var memedImage: UIImage
        
        // Hide toolbar and navbar
        navigationBar.hidden = true
        toolBar.hidden = true
        
        // Render view into an image
        var outputFrame = view.frame
        
        // set outputFrame drawing origin
        outputFrame.origin.y = scrollView.frame.origin.y * -1

        UIGraphicsBeginImageContext(scrollView.frame.size)
        view.drawViewHierarchyInRect(outputFrame, afterScreenUpdates: true)
        memedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar
        navigationBar.hidden = false
        toolBar.hidden = false
        
        return memedImage
    }
    
    func saveMeme(image image: UIImage, topText: String?, bottomText: String?, zoomScale: CGFloat, contentOffset: CGPoint = CGPointZero, memedImage: UIImage) {
        let meme = Meme(
            topText: topText,
            bottomText: bottomText,
            image: image,
            zoomScale: zoomScale,
            contentOffset: contentOffset,
            memedImage: memedImage
        )
        
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
            
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
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
        if textField == bottomTextField {
            subscribeToKeyboardNotifications()
        }
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if textField == bottomTextField {
            unsubscribeFromKeyboardNotifications()
        }
        
        return true;
    }
    
}
