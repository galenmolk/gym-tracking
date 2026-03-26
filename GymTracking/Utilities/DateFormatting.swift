import Foundation

enum DateFormatting {
    static let sessionDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    static let shortDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .none
        return f
    }()

    static func elapsedTime(from start: Date, to end: Date = Date()) -> String {
        let interval = end.timeIntervalSince(start)
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%d:%02d", minutes, seconds)
    }

    static func sessionDate(_ date: Date) -> String {
        sessionDateFormatter.string(from: date)
    }

    static func shortDate(_ date: Date) -> String {
        shortDateFormatter.string(from: date)
    }
}
