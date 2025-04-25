import Foundation

struct Exercise: Identifiable {
    let id: UUID
    let type: String          // e.g. "running", "cycling"
    let startDate: Date
    let duration: TimeInterval
    let calories: Double      // in kilocalories
}
