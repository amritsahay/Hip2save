//
//  Utility.swift
//  Basic Humanity
//
//  Created by ip-d on 14/12/17.
//  Copyright © 2017 Esferasoft Solutions. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialSnackbar
import NVActivityIndicatorView
//import SDWebImage
import AVFoundation


class Utility: NSObject {
    static let shared:Utility = Utility()
    
    
    func startProgress(message:String) {
        DispatchQueue.main.async {
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
            let activityData = ActivityData(size:nil, message: nil, messageFont: nil, messageSpacing: nil, type: NVActivityIndicatorType.lineSpinFadeLoader, color: nil, padding: nil, displayTimeThreshold: nil, minimumDisplayTime: nil, backgroundColor: nil, textColor: nil)
            NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData,nil)
            NVActivityIndicatorPresenter.sharedInstance.setMessage(message)
        }
        
    }
    
    func stopProgress() {
        DispatchQueue.main.async {
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
        }
    }
    
    // Mark:Layer function
    func roundEdge(view:UIView,point:CGFloat)
    {
        view.layer.cornerRadius = point
        view.clipsToBounds = true
    }
    
    func drawBorder(view:UIView,size:CGFloat,color:UIColor)
    {
        view.layer.borderColor = color.cgColor
        view.layer.borderWidth = size
    }
    
    func removeWhiteSpace(string: String) -> String
    {
        let trimmedString = string.trimmingCharacters(in: .whitespaces)
        return trimmedString
    }
    
    
    func leftPaddingView() -> UIView
    {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 20))
        
        return paddingView
    }
    
    func setImageViewPadding(imageName : NSString, requiredImageViewFrame : CGRect) -> UIView {
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        let paddingImageView = UIImageView(frame:requiredImageViewFrame)
        //paddingImageView.alpha = 1.0
        paddingImageView.image = UIImage(named: imageName as String)
        paddingImageView.contentMode = UIView.ContentMode.scaleAspectFit;
        paddingView.addSubview(paddingImageView)
        return paddingView
    }
    
    func convertTime(format:String,time:Date) -> String {
        var timeStr:String = ""
        let formatter = DateFormatter()
        formatter.dateFormat = format
        timeStr = formatter.string(from: time)
        return timeStr
    }
    
    func convertTime(time:String, format:String) -> Date
    {
        
        let formatter = DateFormatter()
        formatter.dateFormat = format
        let date = formatter.date(from:time)
        return date!
    }
    
    func convertTime(time:String, inputFormat:String , outputFormat:String) -> String
    {
        
        let formatter = DateFormatter()
        formatter.dateFormat = inputFormat
        let date = formatter.date(from:time)
        formatter.dateFormat = outputFormat
        let timeString:String  = formatter.string(from: date!)
        return timeString
    }
    
    func getPartOfDay(date:Date) -> String {
        let formatter = DateFormatter()
        
        formatter.dateFormat = "hh"
        let hour = formatter.string(from: date)
        
        formatter.dateFormat = "a"
        let period = formatter.string(from: date)
        
        let hourInt:Int = Int(hour)!
        if period == "AM"
        {
            if  hourInt >= 5 && hourInt <= 8
            {
                return "Early morning "
            }
            else if hourInt >= 8 && hourInt <= 11
            {
                return "Morning"
            }
            else if hourInt >= 11 && hourInt <= 12
            {
                return "Late morning"
            }
            else
            {
                return "Night"
            }
        }
        else
        {
            if  hourInt >= 12
            {
                return "Noon"
            }
            else if hourInt >= 1 && hourInt <= 3
            {
                return "Early afternoon"
            }
            else if hourInt >= 3 && hourInt <= 4
            {
                return "Afternoon"
            }
            else if hourInt >= 4 && hourInt <= 5
            {
                return "Late afternoon"
            }
            else if hourInt >= 5 && hourInt <= 7
            {
                return "Early evening"
            }
            else if hourInt >= 7 && hourInt <= 9
            {
                return "Evening"
            }
            else
            {
                return "Night"
            }
        }
    }
    
    func dateByAddingDaysToDate(startDate:Date,numberOfDays:Int) -> Date {
        var dayComponent = DateComponents()
        dayComponent.day = numberOfDays
        
        let calender = Calendar.current
        let calculatedDate = calender.date(byAdding:dayComponent, to:startDate)
        return calculatedDate!
    }
    
    //Mark: show snackbar Message
    func showSnackBarMessage(message:String){
        DispatchQueue.main.async {
            let snackbarMessage = MDCSnackbarMessage()
            snackbarMessage.text = message
            MDCSnackbarManager.show(snackbarMessage)
            MDCSnackbarManager.snackbarMessageViewBackgroundColor = Constants.headerColor
        }
        
    }
    
    //MARK: String NSNull
    func checkNull(parameter:AnyObject) ->String {
        
        if parameter.isKind(of:NSNull.self)
        {
            return ""
        }
        return parameter as! String
    }
    
    
    func generateCommaString(ids:NSMutableArray) -> String
    {
        let lastCount:Int = ids.count - 1
        var idString:String = ""
        for i in 0..<ids.count
        {
            let idStr:String = ids.object(at: i) as! String
            idString = idString + idStr
            if lastCount == i
            {
                return idString
            }
            
            idString = idString + ","
        }
        return ""
    }
    
    func convertServerTime(serverDate:String, format:String) -> String
    {
        let dateFormatter = DateFormatter()
        let tempLocale = dateFormatter.locale // save locale temporarily
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date:Date! = dateFormatter.date(from:serverDate)
        dateFormatter.dateFormat = format
        dateFormatter.locale = tempLocale // reset the locale
        let dateString = dateFormatter.string(from: date)
        print("EXACT_DATE : \(dateString)")
        return dateString
    }
    
    func convertcommentTime(serverDate:String) -> Date?
    {
        let dateFormatter = DateFormatter()
        let tempLocale = dateFormatter.locale // save locale temporarily
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
        let date:Date? = dateFormatter.date(from:serverDate)
        return date
    }
    
    func convertServerTime(serverDate:String) -> Date?
    {
        let dateFormatter = DateFormatter()
        let tempLocale = dateFormatter.locale // save locale temporarily
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date:Date? = dateFormatter.date(from:serverDate)
        return date
    }
    
    func currentUTC()-> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter.string(from:Date())
    }
    
    func stringify(json: Any, prettyPrinted: Bool = false) -> String {
        var options: JSONSerialization.WritingOptions = []
        if prettyPrinted {
            options = JSONSerialization.WritingOptions.prettyPrinted
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: options)
            if let string = String(data: data, encoding: String.Encoding.utf8) {
                return string
            }
        } catch {
            print(error)
        }
        
        return "Error"
    }
    
    static func compressImage(image: UIImage, newWidth: CGFloat) -> UIImage
    {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        
        
        image.draw(in: CGRect(x: 0, y: 0,width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    static func createThumbnailOfVideoFromFileURL(videoURL: String) -> UIImage?
    {
        let asset = AVAsset(url: URL(string: videoURL)!)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(Float64(1), preferredTimescale: 100)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
        } catch {
            return UIImage(named: "ico_placeholder")
        }
    }
    
    static func responseType(data:AnyObject) -> Int
    {
        if data.isKind(of:NSArray.self)
        {
            return 1
        }
        else if data.isKind(of:NSDictionary.self)
        {
            return 2
        }
        else
        {
            return 3
        }
    }
}

public extension Date {
    
    /*
     let yesterday = Date(timeInterval: -86400, since: Date())
     let tomorrow = Date(timeInterval: 86400, since: Date())
     let diff = tomorrow.interval(ofComponent: .day, fromDate: yesterday)
     */
    
    func interval(ofComponent comp: Calendar.Component, fromDate date: Date) -> Int {
        
        let currentCalendar = Calendar.current
        
        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: date) else { return 0 }
        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: self) else { return 0 }
        
        return end - start
    }
    
}
public extension UIView {
    
    public enum ViewSide {
        case top
        case right
        case bottom
        case left
    }
    
    func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: frame.size.width, height: width)
        self.layer.addSublayer(border)
        self.layoutIfNeeded()
    }
}

public extension String {
    static let shortDateUS: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateStyle = .short
        return formatter
    }()
    var shortDateUS: Date? {
        return String.shortDateUS.date(from: self)
    }
    
}
