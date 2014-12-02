import UIKit

class MenuTeamCell: UITableViewCell {
    private var hasAwakened = false
    private var team: Team?

    @IBOutlet weak var teamCircle: TeamCircle!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var metaLabel: UILabel!

    override func awakeFromNib() {
        self.hasAwakened = true
        self.updateView()
    }

    func setTeam(team: Team) {
        self.team = team
        self.updateView()
    }

    func getTeam() -> Team? {
        return self.team
    }

    private func updateView() {
        if self.team != nil && self.hasAwakened {
            self.nameLabel.text = self.team!.name
        }
    }
}
