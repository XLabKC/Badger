class FirebaseUtil {
    class func adjustValueForRef(ref: Firebase, delta: Int) {
        ref.runTransactionBlock({ (data:FMutableData!) in
            var active = data.value as? Int
            if active == nil {
                active = 0
            }
            active! += delta
            if active! < 0 {
                active! = 0
            }
            data.value = active!
            return FTransactionResult.successWithValue(data)
        })
    }
}