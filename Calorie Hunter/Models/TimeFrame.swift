//
//  TimeFrame.swift
//  Calorie Hunter
//
//  Created by Jude Mawad on 05.03.25.
//

import Foundation

enum Timeframe: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
    
    var days: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .year: return 365
        }
    }
}
