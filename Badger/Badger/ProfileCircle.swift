import UIKit


class ProfileCircle: UIImageView {
    var status = UserStatus.Unknown
    var user: User?

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.borderColor = Colors.UnknownStatus.CGColor
        self.layoutView()
    }

    func setUser(user: User) {
        self.user = user
        // TODO: Set profile image

    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutView()
    }

    private func layoutView() {
        self.layer.cornerRadius = self.frame.height / 2.0
        self.layer.borderWidth = (self.frame.height > 80) ? 4.0 : 2.0
    }
}