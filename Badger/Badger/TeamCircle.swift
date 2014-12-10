import UIKit


class TeamCircle: UIImageView {

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.clipsToBounds = true
        self.layer.borderColor = Colors.UnknownStatus.CGColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = self.frame.height / 2.0
    }

    func setTeam(team: Team) {
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.height / 2.0
    }
}