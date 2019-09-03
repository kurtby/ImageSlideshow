//
//  MediaSource.swift
//  ImageSlideshow
//
//  Created by Valentine
//
//

import Alamofire
import AlamofireImage

public enum MediaType: Int {
    case image
    case video
}

/// Input Source to image using Alamofire
@objcMembers
public class MediaSource: NSObject, InputSource {
    /// url to load
    public var url: URL
    
    /// placeholder used before image is loaded
    public var placeholder: UIImage?
    
    public var sourceType: Int

    /// Initializes a new source with a URL
    /// - parameter url: a url to load
    /// - parameter placeholder: a placeholder used before image is loaded
    public init(url: URL, placeholder: UIImage? = nil, type: MediaType) {
        self.url = url
        self.placeholder = placeholder
        self.sourceType = type.rawValue
        super.init()
    }

    /// Initializes a new source with a URL string
    /// - parameter urlString: a string url to load
    /// - parameter placeholder: a placeholder used before image is loaded
    public init?(urlString: String, placeholder: UIImage? = nil, type: MediaType) {
        if let validUrl = URL(string: urlString) {
            self.url = validUrl
            self.placeholder = placeholder
            self.sourceType = type.rawValue
            super.init()
        } else {
            return nil
        }
    }

    public func load(to imageView: UIImageView, with callback: @escaping (UIImage?) -> Void) {
        imageView.af_setImage(withURL: self.url, placeholderImage: placeholder, filter: nil, progress: nil) { [weak self] (response) in                                                              
            if response.result.isSuccess {
                callback(response.result.value)
            } else if let strongSelf = self {
                callback(strongSelf.placeholder)
            } else {
                callback(nil)
            }                                                                                                 
        }
    }

    public func cancelLoad(on imageView: UIImageView) {
        imageView.af_cancelImageRequest()
    }
}
