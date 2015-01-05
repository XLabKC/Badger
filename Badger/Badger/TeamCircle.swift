import UIKit


class TeamCircle: UIImageView {
    private var team: Team?

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.clipsToBounds = true
        self.layer.borderColor = Colors.UnknownStatus.CGColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = self.frame.height / 2.0
    }

    func setTeam(team: Team) {
        self.team = team
        self.image = UIImage(named: team.logo)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.height / 2.0
    }
}