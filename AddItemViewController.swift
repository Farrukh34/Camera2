//
//  AddItemViewController.swift
//  Camera2
//
//  Created by Farrukh Khan on 14/06/2015.
//  Copyright (c) 2015 Farrukh. All rights reserved.
//

import UIKit


class AddItemViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    @IBOutlet var Photo1: UIImageView!
    
    @IBOutlet var myActivityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func UploadPhoto(sender: AnyObject) {
        myImageUploadRequest()
    }
    
    func myImageUploadRequest()
    {
        
        let myUrl = NSURL(string: hostURL + "TEST/hello34.php")
        let request = NSMutableURLRequest(URL: myUrl!);
        request.HTTPMethod = "POST"
        
        let param = ["firstName" : "Farrukh", "lastName" : "Khan", "userId" : "21"]
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        
        let imageData = UIImageJPEGRepresentation(Photo1.image, 1)
        
        if(imageData==nil) { return }
        
        println("param = \(param)")
        
        request.HTTPBody = createBodyWithParameters(param, filePathKey: "file", imageDataKey: imageData, boundary: boundary)
        
        myActivityIndicator.startAnimating();
        println("Body: \(request.HTTPBody )")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                println("error=\(error)")
                return
            }
            
            // You can print out response object
            println("******* response = \(response)")
            
            // Print out reponse body
            let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("****** response data = \(responseString!)")
            
            dispatch_async(dispatch_get_main_queue(),{
                self.myActivityIndicator.stopAnimating()
                self.Photo1.image = nil;
            });
            
        }
        
        task.resume()
        
    }
    


    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
        
        var body = NSMutableData()
        
        if parameters != nil {
            for (key, value) in parameters! {
                println("Key: \(key)")
                body.appendString("–-\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        println("Body2: \(body)")
        
        let filename = "user-profile.jpg"
        
        let mimetype = "image/jpg"
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.appendData(imageDataKey)
        body.appendString("\r\n")
        
        body.appendString("–-\(boundary)–\r\n")
        
        return body
    }
    

    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }
    
    
    @IBAction func AddPhotoButton(sender: AnyObject) {
        var alertController = UIAlertController(title: "", message: "", preferredStyle: .ActionSheet)
        let cameraAction = UIAlertAction(title: "Use Camera", style: UIAlertActionStyle.Default){(ACTION) in
            self.useCamera()
        }
        let libraryAction = UIAlertAction(title: "Select Existing Photo", style: UIAlertActionStyle.Default){(ACTION) in
            self.useLibrary()
        }
        let alertCancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel){(ACTION) in
            println("Cancel Selected")
        }
        
        alertController.addAction(cameraAction)
        alertController.addAction(libraryAction)
        alertController.addAction(alertCancel)
        
        self.presentViewController(alertController, animated: true, completion: nil)

    }
    
    func useCamera() {
        var myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(myPickerController, animated: true, completion: nil)
    }

    
    func useLibrary() {
        var myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(myPickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        Photo1.image = info[UIImagePickerControllerOriginalImage] as?
            UIImage
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}

extension NSMutableData {
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
    }
}

