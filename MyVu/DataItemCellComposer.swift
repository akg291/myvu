/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    A class used to populate a `DataItemCollectionViewCell` for a given `DataItem`. The composer class handles processing and caching images for `DataItem`s.
*/

import UIKit
import SDWebImage

class DataItemCellComposer {
    
    // MARK: Properties
    // Cache used to store processed images, keyed on `DataItem` identifiers.
    static private var processedImageCache = NSCache()
    /**
        A dictionary of `NSOperationQueue`s for `DataItemCollectionViewCell`s. The
        queues contain operations that process images for `DataItem`s before updating
        the cell's `UIImageView`.
    */
    private var operationQueues = [DataItemCollectionViewCell: NSOperationQueue]()
    private var operationQueues_ = [DataItemCollectionViewCell_: NSOperationQueue]()
    
    // MARK: Implementation
    func composeCell(cell:SeasonEpisodeViewCell, withDataItem dataItem: EpisodeModel)          {
        // Set the cell's properties.
        //cell.representedDataItem = dataItem
        cell.episodeName.text = "\(dataItem.episode_number!) - "+"\(dataItem.title!)"
        cell.episodeDate.text = (self.getFormatedDate(dataItem.first_aired!))
        cell.imageView.image = nil
        cell.imageView.backgroundColor = UIColor .whiteColor()
        cell.imageView.alpha = 1.0
        let downlaoder : SDWebImageDownloader = SDWebImageDownloader .sharedDownloader()
        if let imgUrl = dataItem.poster {
            downlaoder.downloadImageWithURL(
                NSURL(string: imgUrl),
                options: SDWebImageDownloaderOptions.UseNSURLCache,
                progress: nil,
                completed: { (image, data, error, bool) -> Void in
                    if image != nil {
                        dispatch_async(dispatch_get_main_queue(), {
                            cell.imageView.image = image
                        })
                    }
            })
            
        }
        // No further work is necessary if the cell's image view has an image.
        guard cell.imageView.image == nil else { return }
    }
    func composeCell(cell: DataItemCollectionViewCell_, withDataItem dataItem: EpisodeModel)   {
    }
    func composeCell(cell: DataItemCollectionViewCell_, withDataItem dataItem: Result)         {
        // Cancel any queued operations to process images for the cell.
        let operationQueue = operationQueueForCell_(cell)
        operationQueue.cancelAllOperations()
        // Set the cell's properties.
        //cell.representedDataItem = dataItem
        cell.label.text = dataItem.title
        cell.imageView.image = nil
        cell.imageView.backgroundColor = UIColor .whiteColor()
        cell.imageView.alpha = 1.0
        //cell.imageView.image = DataItemCellComposer.processedImageCache.objectForKey(dataItem.identifier) as? UIImage
        let downlaoder : SDWebImageDownloader = SDWebImageDownloader .sharedDownloader()
        if ( dataItem.group == "Shows" ){
            if let imgUrl = dataItem.artWork {
                downlaoder.downloadImageWithURL(
                    NSURL(string: imgUrl),
                    options: SDWebImageDownloaderOptions.UseNSURLCache,
                    progress: nil,
                    completed: { (image, data, error, bool) -> Void in
                        if image != nil {
                            dispatch_async(dispatch_get_main_queue(), {
                                cell.imageView.image = image
                            })
                        }
                })
            }
        }else {
            if let imgUrl = dataItem.previewImage {
                downlaoder.downloadImageWithURL(
                    NSURL(string: imgUrl),
                    options: SDWebImageDownloaderOptions.UseNSURLCache,
                    progress: nil,
                    completed: { (image, data, error, bool) -> Void in
                        if image != nil {
                            dispatch_async(dispatch_get_main_queue(), {
                                cell.imageView.image = image
                            })
                        }
                })
            }
        }
        // No further work is necessary if the cell's image view has an image.
        guard cell.imageView.image == nil else { return }
    }
    func composeCell(cell: DataItemCollectionViewCell, withDataItem dataItem: Result)          {
        // Cancel any queued operations to process images for the cell.
        let operationQueue = operationQueueForCell(cell)
        operationQueue.cancelAllOperations()
        // Set the cell's properties.
        cell.representedDataItem = dataItem
        cell.label.text = dataItem.title
        cell.imageView.image = nil
        cell.imageView.backgroundColor = UIColor .whiteColor()
        // These properties are also exposed in Interface Builder.
        cell.imageView.adjustsImageWhenAncestorFocused = true
        cell.imageView.clipsToBounds = false
        cell.imageView.alpha = 1.0
        //cell.imageView.image = DataItemCellComposer.processedImageCache.objectForKey(dataItem.identifier) as? UIImage
        let downlaoder : SDWebImageDownloader = SDWebImageDownloader .sharedDownloader()
        if ( dataItem.group == "Shows" ){
            if let imgUrl = dataItem.artWork {
                downlaoder.downloadImageWithURL(
                    NSURL(string: imgUrl),
                    options: SDWebImageDownloaderOptions.UseNSURLCache,
                    progress: nil,
                    completed: { (image, data, error, bool) -> Void in
                        if image != nil {
                            dispatch_async(dispatch_get_main_queue(), {
                                cell.imageView.image = image
                            })
                        }
                })
            }
        }else {
            if let imgUrl = dataItem.previewImage {
                downlaoder.downloadImageWithURL(
                    NSURL(string: imgUrl),
                    options: SDWebImageDownloaderOptions.UseNSURLCache,
                    progress: nil,
                    completed: { (image, data, error, bool) -> Void in
                        if image != nil {
                            dispatch_async(dispatch_get_main_queue(), {
                                cell.imageView.image = image
                            })
                        }
                })
            }
        }
        // No further work is necessary if the cell's image view has an image.
        guard cell.imageView.image == nil else { return }
        /*
         Initial rendering of a jpeg image can be expensive. To avoid stalling
         the main thread, we create an operation to process the `DataItem`'s
         image before updating the cell's image view.
         The execution block is added after the operation is created to allow
         the block to check if the operation has been cancelled.
         */
    }
    private func operationQueueForCell_(cell: DataItemCollectionViewCell_) -> NSOperationQueue {
        if let queue = operationQueues_[cell] {
            return queue
        }
        let queue = NSOperationQueue()
        operationQueues_[cell] = queue
        return queue
    }
    private func operationQueueForCell(cell: DataItemCollectionViewCell) -> NSOperationQueue   {
        if let queue = operationQueues[cell] {
            return queue
        }
        let queue = NSOperationQueue()
        operationQueues[cell] = queue
        return queue
    }
    /**
        Loads a UIImage for a given name and returns a version that has been drawn
        into a `CGBitmapContext`.
    */
    private func processImageNamed(imageName: String) -> UIImage? {
        // Load the image.
        guard let image = UIImage(named: imageName) else { return nil }
        /*
            We only need to process jpeg images. Do no processing if the image
            name doesn't have a jpg suffix.
        */
        guard imageName.hasSuffix(".jpg") else { return image }
        // Create a `CGColorSpace` and `CGBitmapInfo` value that is appropriate for the device.
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.PremultipliedLast.rawValue | CGBitmapInfo.ByteOrder32Little.rawValue
        // Create a bitmap context of the same size as the image.
        let imageWidth = Int(Float(image.size.width))
        let imageHeight = Int(Float(image.size.height))
        let bitmapContext = CGBitmapContextCreate(nil, imageWidth, imageHeight, 8, imageWidth * 4, colorSpace, bitmapInfo)
        // Draw the image into the graphics context.
        guard let imageRef = image.CGImage else { fatalError("Unable to get a CGImage from a UIImage.") }
        CGContextDrawImage(bitmapContext, CGRect(origin: CGPoint.zero, size: image.size), imageRef)
        // Create a new `CGImage` from the contents of the graphics context.
        guard let newImageRef = CGBitmapContextCreateImage(bitmapContext) else { return image }
        // Return a new `UIImage` created from the `CGImage`.
        return UIImage(CGImage: newImageRef)
    }
    func getFormatedDate (dateString:String) -> String{
        var formatedDateString = String ()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY/MM/dd"
        let temp = dateFormatter.dateFromString(dateString)
        print(temp)
        // convert to required string
        dateFormatter.dateFormat = "dd MMM YYYY"
        formatedDateString = dateFormatter.stringFromDate(temp!)
        return formatedDateString
    }
}
