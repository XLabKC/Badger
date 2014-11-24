
protocol StatusRecipient: class {
    func statusUpdated(uid: String, newStatus: UserStatus)
}

class StatusListener {

    // Accesses the singleton.
    class func sharedInstance() -> StatusListener {
        struct Static {
            static var instance: StatusListener?
            static var token: dispatch_once_t = 0
        }
        dispatch_once(&Static.token) {
            Static.instance = StatusListener()
        }
        return Static.instance!
    }

    private var recipientsByUid: [String: [WeakRecipient]] = [:]
    private var statusByUid: [String: UserStatus] = [:]
    private var handlesByUid: [String: UInt] = [:]
    private var ref = Firebase(url: Global.FirebaseUsersUrl)


    init() {

    }

    func addRecipient(recipient: StatusRecipient, uid: String) {
        var recipients = recipientsByUid[uid]
        if recipients == nil {
            recipients = [WeakRecipient]()
        }

        if recipients!.isEmpty {
            recipients!.append(WeakRecipient(recipient: recipient))

            // Start listening for this status.
            let statusRef = self.ref.childByAppendingPath(uid).childByAppendingPath("status")
            self.handlesByUid[uid] = statusRef.observeEventType(.Value, withBlock: self.statusUpdated)
        } else {
            recipients!.append(WeakRecipient(recipient: recipient))
            if let status = self.statusByUid[uid] {
                recipient.statusUpdated(uid, newStatus: status)
            }
        }

        self.recipientsByUid[uid] = recipients!
    }

    func removeRecipient(recipient: StatusRecipient, uid: String) {
        if var recipients = self.recipientsByUid[uid]? {
            for (index, weakRecipient) in enumerate(recipients) {
                if weakRecipient.recipient === recipient {
                    recipients.removeAtIndex(index)
                    break
                }
            }
            if recipients.count == 0 {
                self.stopListening(uid)
            }
        }
    }

    private func statusUpdated(snapshot: FDataSnapshot!) {
        let uid = snapshot.ref.parent.key

        // Make sure that the snapshot is valid.
        if !(snapshot.value is String) {
            return
        }

        var status = UserStatus(rawValue: snapshot.value as String!)
        if status == nil {
            status = .Unknown
        }

        self.statusByUid[uid] = status

        if let recipients = self.recipientsByUid[uid]? {
            if recipients.count > 0 {
                var valid = [WeakRecipient]()
                for weakRecipient in recipients {
                    if let recipient = weakRecipient.recipient? {
                        recipient.statusUpdated(uid, newStatus: status!)
                        valid.append(weakRecipient)
                    }
                }
                self.recipientsByUid[uid] = valid

                // Check to make sure that there were at least one valid
                // listener. Otherwise, stop listening.
                if valid.count > 0 {
                    return
                }
            }
        }

        // There are no recipients, remove observer.
        self.stopListening(uid)
    }

    private func stopListening(uid: String) {
        if let handle = handlesByUid[uid]? {
            self.ref.removeObserverWithHandle(handle)
        }
    }
}


private class WeakRecipient {
    weak var recipient: StatusRecipient?
    init(recipient: StatusRecipient) {
        self.recipient = recipient
    }
}