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
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var toolBar: UIToolbar!
    
    var viewShiftedForKeyboard = false
//    var memedImage: UIImage!

    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    var meme: Meme?
    
    let memeTextAttributes: [AnyHashable: Any] = [
        NSAttributedStringKey.strokeColor: UIColor.black,
        NSAttributedStringKey.foregroundColor: UIColor.white,
        NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedStringKey.strokeWidth: -3.0 // Negative for stroke and fill
    ]

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topTextField.defaultTextAttributes = memeTextAttributes as! [String:Any]
        bottomTextField.defaultTextAttributes = memeTextAttributes as! [String : Any]
        
        topTextField.textAlignment = .center
        bottomTextField.textAlignment = .center
        
        imageView.isUserInteractionEnabled = true
        imageView.frame = scrollView.bounds
//        imageView.backgroundColor = UIColor.greenColor()
        scrollView.addSubview(imageView)
        
        resetMemeEditor()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        if let meme = meme {
            topTextField.text = meme.topText
            bottomTextField.text = meme.bottomText
            imageView.image = meme.image
            if let image = meme.image, let contentOffset = meme.contentOffset,
                let zoomScale = meme.zoomScale {
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    @IBAction func pickImageFromAlbum(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickImageFromCamera(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func shareMeme(sender: AnyObject) {
        let memedImage = generateMemedImage()
        let controller = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        controller.completionWithItemsHandler = {
            (activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, activityError: Error?) -> Void in
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
                controller.dismiss(animated: true, completion: nil)
            }
        }
        
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func cancelEditing(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        centerScrollViewContents()
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
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        
        imageView.frame = CGRect(origin: CGPoint(x:0, y:0), size: scrollView.frame.size)
        imageView.image = nil
    }
    
    // MARK: - Keyboard
    
    @objc
    func keyboardWillShow(notification: NSNotification) {
        if !viewShiftedForKeyboard {
            view.frame.origin.y -= getKeyboardHeight(notification: notification)
            viewShiftedForKeyboard = true
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardFrame = userInfo![UIKeyboardFrameEndUserInfoKey] as! CGRect // of CGRect
        return keyboardFrame.height
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc
    func keyboardWillHide(notification: NSNotification) {
        if viewShiftedForKeyboard  {
            view.frame.origin.y = 0
            viewShiftedForKeyboard = false
        }
    }
    
    // MARK: - Management
    
    func generateMemedImage() -> UIImage {
        var memedImage: UIImage
        
        // Hide toolbar and navbar
        navigationBar.isHidden = true
        toolBar.isHidden = true
        
        // Render view into an image
        var outputFrame = view.frame
        
        // set outputFrame drawing origin
        outputFrame.origin.y = scrollView.frame.origin.y * -1

        UIGraphicsBeginImageContext(scrollView.frame.size)
        view.drawHierarchy(in: outputFrame, afterScreenUpdates: true)
        memedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar
        navigationBar.isHidden = false
        toolBar.isHidden = false
        
        return memedImage
    }
    
    func saveMeme(image: UIImage, topText: String?, bottomText: String?, zoomScale: CGFloat, contentOffset: CGPoint = .zero, memedImage: UIImage) {
        let meme = Meme(
            topText: topText,
            bottomText: bottomText,
            image: image,
            zoomScale: zoomScale,
            contentOffset: contentOffset,
            memedImage: memedImage
        )
        
        appDelegate.memes.append(meme)
    }
}

// MARK: - Navigation Controller Delegate

extension MemeCreateViewController: UINavigationControllerDelegate {}

// MARK: - Image Picker Controller Delegate

extension MemeCreateViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
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
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - Scroll View Delegate

extension MemeCreateViewController: UIScrollViewDelegate {
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

// MARK: - Text Field Delegate

extension MemeCreateViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField.text == "TOP") || (textField.text == "BOTTOM") {
            textField.text = ""
        }
        if textField == bottomTextField {
            subscribeToKeyboardNotifications()
        }
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if textField == bottomTextField {
            unsubscribeFromKeyboardNotifications()
        }
        
        return true;
    }
    
}
