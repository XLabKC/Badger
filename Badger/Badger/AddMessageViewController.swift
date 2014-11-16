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
            let messageIdRef = messageRef.childByAutoId()
            let newMessageRef = Firebase(url: Global.FirebaseNewMessagesUrl).childByAppendingPath(messageIdRef.name)
            messageIdRef.setValue(message)
            newMessageRef.setValue(user.uid)
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}