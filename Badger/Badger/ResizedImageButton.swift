import UIKit

class ResizedImageButton: UIButton {
    override func awakeFromNib() {
        self.fixImageForState(.Normal)
        self.fixImageForState(.Highlighted)
        self.fixImageForState(.Selected)
        self.fixImageForState(.Disabled)
    }

    private func fixImageForState(state: UIControlState) {
        if let image = self.backgroundImageForState(state) {
            let resized = image.resizableImageWithCapInsets(UIEdgeInsetsMake(18, 18, 18, 18))
            self.setBackgroundImage(resized, forState: state)
        }
    }
}