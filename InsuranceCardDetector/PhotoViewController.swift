//
//  PhotoViewController.swift
//  InsuranceCardDetector
//
//  Created by Mostafijur Rahaman on 6/14/17.
//  Copyright © 2017 Mostafijur Rahaman. All rights reserved.
//

import UIKit
import Firebase

class PhotoViewController: UIViewController {
    
    var takenPhoto: UIImage?

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let availableImage = takenPhoto {
            
            imageView.image = availableImage
        }
        
        detect()
    }
    @IBAction func goBack(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func detect() {
        
        let cardImage = CIImage(image: imageView.image!)
        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyLow]
        let cardDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
        let cards = cardDetector?.features(in: cardImage!)
        
        //for converting the Core Image Coordinates to UIView Coordinates
        let ciImageSize = cardImage?.extent.size
        var transform = CGAffineTransform(scaleX: 1,y: -1)
        transform = transform.translatedBy(x: 0, y: -(ciImageSize?.height)!)
        
        if((cards as! [CIRectangleFeature]).count == 0){
            print("No Card Found")
            self.dismiss(animated: true, completion: nil)
        }else if((cards as! [CIRectangleFeature]).count > 1){
            print("Multiple Card Detect")
        }
        
        for card in cards as! [CIRectangleFeature] {
            let x1 = card.bounds.minX
            let y1 = card.bounds.minX
            let x2 = card.bounds.maxX
            let y2 = card.bounds.maxY
            
            let newBounds = CGRect(x: x1 - (imageView.bounds.size.width - (ciImageSize?.width)!)/2, y: y1 - (imageView.bounds.size.height-(ciImageSize?.height)!)/2, width: x2-x1, height: y2-y1)
            
            print("Found bounds are \(x1) \(x2) \(y1)  \(y2)")
            
            //Apply the transform to convert the coordinates
            var cardViewBounds = card.bounds.applying(transform)
            
            //calculating actual position
            let viewSize = imageView.bounds.size
            
            let scale = min(viewSize.width / (ciImageSize?.width)!,
                            viewSize.height / (ciImageSize?.height)!)
            let offsetX = (viewSize.width - (ciImageSize?.width)! * scale) / 2
            let offsetY = (viewSize.height - (ciImageSize?.height)! * scale) / 2
            
            cardViewBounds = cardViewBounds.applying(CGAffineTransform(scaleX: scale, y: scale))
            cardViewBounds.origin.x += offsetX
            cardViewBounds.origin.y += offsetY
            
            let cardBox = UIView(frame: cardViewBounds)
            
            cardBox.layer.borderWidth = 3
            cardBox.layer.borderColor = UIColor.red.cgColor
            cardBox.backgroundColor = UIColor.clear
            imageView.addSubview(cardBox)
            //break
            
            let newImg = cardImage?.cropping(to: card.bounds)
            imageView.image = convert(cmage: newImg!)
        }
        
        
    }
    
    func convert(cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
    
    @IBAction func uploadImage(_ sender: Any){
        
        let database = FIRDatabase.database().reference()
        let storage = FIRStorage.storage().reference()
        let tempImgRef = storage.child("tempDir/tempImage.jpg")
        
        let image = imageView.image
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        
        tempImgRef.put(UIImageJPEGRepresentation(image!, 0.8)!, metadata: metadata)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
