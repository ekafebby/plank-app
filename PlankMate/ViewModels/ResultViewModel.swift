import SwiftUI
import Combine

class ResultViewModel: ObservableObject {
    @Published var currentSession: PlankSession?
    
    // Properti untuk HomeView
    @Published var totalMinutes: String = "0m"
    @Published var currentStreak: String = "0"
    @Published var practiceCountText: String = ""
    
    @AppStorage("plank_history") private var historyData: Data = Data()
    
    func saveSession(duration: TimeInterval, accuracy: Double) {
        let newSession = PlankSession(date: Date(), duration: duration, accuracy: accuracy)
        self.currentSession = newSession
        
        var history = getHistory()
        history.append(newSession)
        
        if let encoded = try? JSONEncoder().encode(history) {
            historyData = encoded
        }
        calculateStats() // Update angka setelah simpan
    }
    
    func getHistory() -> [PlankSession] {
        guard let decoded = try? JSONDecoder().decode([PlankSession].self, from: historyData) else {
            return []
        }
        return decoded
    }
    
    // Fungsi yang dipanggil HomeView di .onAppear
    func calculateStats() {
        let history = getHistory()
        
        // 1. Hitung Total Waktu
        let totalSeconds = history.reduce(0) { $0 + $1.duration }
        self.totalMinutes = "\(Int(totalSeconds / 60))m"
        
        // 2. Hitung Streak
        self.currentStreak = "\(calculateSimpleStreak(from: history))"
        
        // 3. Update Teks Deskripsi
        if history.isEmpty {
            self.practiceCountText = "0 practices this week,\nyour practice trend will appear here."
        } else {
            self.practiceCountText = "\(history.count) practices this week,\nkeep up the good work!"
        }
    }
    
    private func calculateSimpleStreak(from history: [PlankSession]) -> Int {
        let calendar = Calendar.current
        let dates = history.map { calendar.startOfDay(for: $0.date) }
        let uniqueDates = Set(dates).sorted(by: >)
        
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())
        
        for date in uniqueDates {
            if date == checkDate {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else if date < checkDate {
                break
            }
        }
        return streak
    }
    
    func timeString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
