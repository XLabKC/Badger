import UIKit


class TeamCircle: UIImageView {

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.clipsToBounds = true
        self.layer.borderColor = Colors.UnknownStatus.CGColor
    }

}