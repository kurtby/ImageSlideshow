//
//  MediaView.swift
//  ImageSlideshow
//
//  Created by Valentine Eyiubolu on 9/3/19.
//

import UIKit

public class MediaView: UIView {
    
    public let imageView = UIImageView()
    
 //  public let videoView = VideoView()
 
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
      //  imageView.frame = self.frame
    }
    
    internal func setup() {
     //   imageView.clipsToBounds = true
      //  imageView.contentMode = .scaleAspectFill
       // addSubview(imageView)
    }
    
}
