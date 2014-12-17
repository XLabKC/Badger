import UIKit

class TeamHeaderCell: UITableViewCell, TeamObserver {
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

    deinit {
        if let team = self.team? {
            TeamStore.sharedInstance().removeObserver(self, id: team.id)
        }
    }

    func setTeam(team: Team) {
        self.team = team
        TeamStore.sharedInstance().addObserver(self, id: team.id)
    }

    func teamUpdated(newTeam: Team) {
        self.team = newTeam
        self.updateView()
    }

    private func updateView() {
        if self.hasAwakened {
            if let team = self.team? {
                self.nameLabel.text = team.name
                self.metaLabel.text = team.description()
                // TODO: set team circle
            }
        }
    }
}
