enum ActivityLevel: Int, CaseIterable, Identifiable {
    case sedentary    // barely any exercise
    case lightlyActive
    case moderatelyActive
    case veryActive   // burns ~1000 kcal/day

    var id: Int { rawValue }

    /// A human‐readable label
    var title: String {
        switch self {
        case .sedentary:        return "Sedentary"
        case .lightlyActive:    return "Lightly Active"
        case .moderatelyActive: return "Moderate"
        case .veryActive:       return "Very Active"
        }
    }

    /// Approximate extra calories burned per day
    var extraBurned: Int {
        switch self {
        case .sedentary:        return   0
        case .lightlyActive:    return 200
        case .moderatelyActive: return 500
        case .veryActive:       return 1000
        }
    }
}
