import UIKit

class AddMessageViewController: UIViewController {

    var user: User?

    override func viewDidLoad() {
    }

    func setUser(user: User) {
        self.user = user
    }

    @IBAction func addMessage(sender: AnyObject) {
        if let user = self.user {
            let message = [
                "author": Global.AuthData!.uid,
                "content": "Some new message content goes here",
                "open": true,
                "priority": 3
            ]
            let messageRef = Firebase(url: Global.FirebaseMessagesUrl).childByAppendingPath(user.uid)
            messageRef.childByAutoId().setValue(message)
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}