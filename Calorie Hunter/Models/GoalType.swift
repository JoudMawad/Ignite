import Foundation

/// Types of daily goals stored in Core Data.
enum GoalType: String, CaseIterable {
  case steps
  case calories
  case water
  case burnedCalories
  case weight
}
