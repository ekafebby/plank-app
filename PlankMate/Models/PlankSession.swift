//
//  PlankSession.swift
//  PlankMate
//
//  Created by Eka Feby Ronauli Lubis on 23/04/26.
//


import Foundation

struct PlankSession: Identifiable, Codable {
    var id = UUID()
    let date: Date
    let duration: TimeInterval
    let accuracy: Double
    
    // Properti tambahan untuk membantu charting nanti
    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE" // Hasil: Sen, Sel, dsb
        return formatter.string(from: date)
    }
}