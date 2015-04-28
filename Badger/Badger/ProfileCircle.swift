import UIKit
import Haneke

class ProfileCircle: UIView {
    var status = UserStatus.Unknown
    var user: User?
    var team: Team?
    var userObserver: FirebaseObserver<User>?
    var teamObserver: FirebaseObserver<Team>?
    var circle: UIImageView
    var teamCircle: TeamCircle?

    required init(coder aDecoder: NSCoder) {
        self.circle = UIImageView()
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clearColor()

        let height = self.frame.height
        self.circle.frame = CGRect(x: 0, y: 0, width: height, height: height)
        self.circle.clipsToBounds = true
        self.circle.layer.borderColor = Colors.UnknownStatus.CGColor
        self.circle.autoresizingMask = UIViewAutoresizing.allZeros
        self.addSubview(circle)
        self.layoutView()
    }

    deinit {
        self.dispose()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutView()
    }

    func setUid(uid: String) {
        if let old = self.user {
            if old.uid == uid {
                // Already setup.
                return
            } else {
                self.dispose()
            }
        }
        let ref = User.createRef(uid)
        self.userObserver = FirebaseObserver<User>(query: ref, withBlock: self.userUpdated)
    }

    func setTeamId(id: String) {
        if let old = self.team {
            if old.id == id {
                // Already setup.
                return
            } else {
                self.dispose()
            }
        }
        let ref = Team.createRef(id)
        self.teamObserver = FirebaseObserver<Team>(query: ref, withBlock: self.teamUpdated)
    }

    func userUpdated(newUser: User) {
        self.user = newUser
        let placeholder = UIImage(named: "DefaultUserProfile")
        let imagePath = newUser.profileImages[newUser.status]

        if imagePath != nil && imagePath != "" {
            let transformation = CLTransformation()
            transformation.width = 272
            transformation.height = 272
            transformation.crop = "fill"
            transformation.gravity = "face"
            let url = NSURL(string: ApiKeys.getCloudinaryInstance().url(imagePath))
            self.circle.hnk_setImageFromURL(url!, placeholder: placeholder, format: nil, failure: nil, success: nil)
        } else {
            self.circle.image = placeholder
        }
        self.circle.layer.borderColor = Helpers.statusToColor(newUser.status).CGColor
    }

    func teamUpdated(newTeam: Team) {
        self.team = newTeam
        self.getTeamCircle().setTeam(newTeam)
    }

    private func layoutView() {
        self.circle.layer.cornerRadius = self.frame.height / 2.0
        if self.circle.frame.height > 80 {
            self.circle.layer.borderWidth = 4.0
        } else if self.circle.frame.height > 60 {
            self.circle.layer.borderWidth = 3.0
        } else {
            self.circle.layer.borderWidth = 2.0
        }

        if let teamCircle = self.teamCircle {
            teamCircle.frame = self.createTeamCircleFrame()
        }
    }

    private func dispose() {
        if let observer = self.userObserver {
            observer.dispose()
        }
        if let observer = self.teamObserver {
            observer.dispose()
        }
    }

    private func getTeamCircle() -> TeamCircle {
        if let teamCircle = self.teamCircle {
            return teamCircle
        }
        let circle = TeamCircle(frame: self.createTeamCircleFrame())
        self.addSubview(circle)
        return circle
    }

    private func createTeamCircleFrame() -> CGRect {
        let diameter = self.circle.frame.width / 2.0
        let offset = diameter * 0.20
        let x = -offset
        let y = self.circle.frame.height - diameter + offset
        return CGRect(x: x, y: y, width: diameter, height: diameter)
    }
}
