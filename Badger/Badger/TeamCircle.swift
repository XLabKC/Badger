import UIKit
import Haneke

class TeamCircle: UIImageView {
    private var team: Team?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUp()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setUp()
    }

    func setTeam(team: Team) {
        self.team = team
        let placeholder = UIImage(named: "DefaultTeamLogo")

        if team.logo != "" {
            let url = Helpers.getProfileImageUrl(team.logo)
            self.hnk_setImageFromURL(url, placeholder: placeholder, format: nil, failure: nil, success: nil)
        } else {
            self.image = placeholder
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.height / 2.0
    }

    private func setUp() {
        self.clipsToBounds = true
        self.layer.borderColor = Colors.UnknownStatus.CGColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = self.frame.height / 2.0
    }
}