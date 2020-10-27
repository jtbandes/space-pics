import Foundation
import Combine

public extension DateComponents {
  init(YMDString string: String) throws {
    let components = string.split(separator: "-")
    guard components.count == 3,
       let year = Int(components[0]),
       let month = Int(components[1]),
       let day = Int(components[2]) else {
      throw APODErrors.invalidDate(string)
    }
    self = DateComponents(year: year, month: month, day: day)
  }
}

extension DateFormatter {
  static let monthDay = configure(DateFormatter()) {
    $0.setLocalizedDateFormatFromTemplate("MMM dd")
  }
}