import CoreMedia

extension CMTime {
    var roundedSeconds: TimeInterval { return seconds.rounded() }
    var hours: Int { return Int(roundedSeconds / 3600) }
    var minutes: Int { return Int(roundedSeconds.truncatingRemainder(dividingBy: 3600) / 60) }
    var sec: Int { return Int(roundedSeconds.truncatingRemainder(dividingBy: 60)) }
    var positionalTime: String {
        return hours > 0 ? String(format: "%d:%02d:%02d", hours, minutes, sec) : String(format: "%02d:%02d", minutes, sec)
    }
}
