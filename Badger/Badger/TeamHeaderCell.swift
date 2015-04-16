import UIKit

class TeamHeaderCell: UITableViewCell {
    private var hasAwakened = false
    private var team: Team?

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var teamCircle: TeamCircle!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var metaLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.hasAwakened = true
        self.updateView()
    }

    func setTeam(team: Team) {
        self.team = team
        self.updateView()
    }

    private func updateView() {
        if self.hasAwakened {
            if let team = self.team {
                self.nameLabel.text = team.name
                self.metaLabel.text = team.description()
                self.teamCircle.setTeam(team)
            }
        }
    }
}
