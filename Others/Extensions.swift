//
//  Extensions.swift
//  ToDoList
//
//  Created by Radu Ursache on 05/03/2019.
//  Copyright © 2019 Radu Ursache. All rights reserved.
//

import Foundation
import UIKit
import LKAlertController
import ImageViewer_swift

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
    
    static var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    }
    static var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    }
    static var nextWeek: Date {
        return Calendar.current.date(byAdding: .day, value: 7, to: Date())!
    }
}

extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}

extension LKAlertController {
    public func showOK() {
        self.addAction("OK".localized(), style: .cancel, handler: nil)
        self.show()
    }
}

extension UIViewController {
    func showOK(title: String = Config.General.appName, message: String?) {
        Alert(title: title, message: message).showOK()
    }
    
    func showError(message: String) {
        Alert(title: "ERROR".localized(), message: message).showOK()
    }
    
    func topMostViewController() -> UIViewController {
        if let presented = self.presentedViewController {
            return presented.topMostViewController()
        }
        
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? navigation
        }
        
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }
        
        return self
    }
}

extension UIBarButtonItem {
    class func itemWith(colorfulImage: UIImage, target: AnyObject, action: Selector) -> UIBarButtonItem {
        let button = UIButton(type: .custom)
        button.setImage(colorfulImage.withRenderingMode(.alwaysTemplate), for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)
        
        let barButtonItem = UIBarButtonItem(customView: button)
        barButtonItem.tintColor = UIColor.white
        
        return barButtonItem
    }
}

@IBDesignable
class LeftAlignedIconButton: UIButton {
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        let titleRect = super.titleRect(forContentRect: contentRect)
        let imageSize = currentImage?.size ?? .zero
        let availableWidth = contentRect.width - imageEdgeInsets.right - imageSize.width - titleRect.width
        return titleRect.offsetBy(dx: round(availableWidth / 2), dy: 0)
    }
}

extension UITextView {
    var numberOfCurrentlyDisplayedLines: Int {
        let size = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return Int(((size.height - layoutMargins.top - layoutMargins.bottom) / font!.lineHeight))
    }
    
    func removeTextUntilSatisfying(maxNumberOfLines: Int) {
        while numberOfCurrentlyDisplayedLines > (maxNumberOfLines) {
            text = String(text.dropLast())
            layoutIfNeeded()
        }
    }
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

extension Bundle {
    var releaseVersionNumber: String {
        return "\(infoDictionary?["CFBundleShortVersionString"] as? String ?? "")"
    }
    var buildVersionNumber: String {
        return "\(infoDictionary?["CFBundleVersion"] as? String ?? "")"
    }
}

extension UIApplication {
    func topMostViewController() -> UIViewController {
        return (self.keyWindow?.rootViewController?.topMostViewController())!
    }
}

class ImageViewerExt: UIImageView {
	var customVC: UIViewController?
}

extension ImageViewerExt {
    private class TapWithDataRecognizer: UITapGestureRecognizer {
        var imageDatasource:ImageDataSource?
        var initialIndex:Int = 0
        var options:[ImageViewerOption] = []
    }
	
	public func setupImageViewer(presentFrom: UIViewController) {
		self.customVC = presentFrom
		self.setupImageViewer()
	}
    
    public func setupImageViewer(
        options:[ImageViewerOption] = []) {
        setup(datasource: nil, options: options)
    }
    
    private func setup(
        datasource:ImageDataSource?,
        initialIndex:Int = 0,
        options:[ImageViewerOption] = []) {
        
        var _tapRecognizer:TapWithDataRecognizer?
        gestureRecognizers?.forEach {
            if let _tr = $0 as? TapWithDataRecognizer {
                // if found, just use existing
                _tapRecognizer = _tr
            }
        }
        
        isUserInteractionEnabled = true
        contentMode = .scaleAspectFill
        clipsToBounds = true
        
        if _tapRecognizer == nil {
            _tapRecognizer = TapWithDataRecognizer(
                target: self, action: #selector(showImageViewer(_:)))
            _tapRecognizer!.numberOfTouchesRequired = 1
            _tapRecognizer!.numberOfTapsRequired = 1
        }
        // Pass the Data
        _tapRecognizer!.imageDatasource = datasource
        _tapRecognizer!.initialIndex = initialIndex
        _tapRecognizer!.options = options
        addGestureRecognizer(_tapRecognizer!)
    }
    
    @objc
    private func showImageViewer(_ sender:TapWithDataRecognizer) {
        guard let sourceView = sender.view as? UIImageView else { return }
        
        let imageCarousel = ImageCarouselViewController.create(
            sourceView: sourceView,
            imageDataSource: sender.imageDatasource,
            options: sender.options,
            initialIndex: sender.initialIndex)
		
		self.customVC?.present(imageCarousel, animated: false, completion: nil)
    }
}

