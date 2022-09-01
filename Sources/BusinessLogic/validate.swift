import Foundation
import kubewardenSdk
import Logging
import SwiftPath


public func validate(payload: String) -> String {
  let logger = Logger(label: "testing")
  logger.info("Hello World!")

  let name = "flavio"
  logger.info("interpolation in action \(name)")

  logger.info("Another message",
              metadata: [
                "foo": "bar",
                "number": .stringConvertible(42),
                "more-numbers": [.stringConvertible(1), .stringConvertible(2)],
              ])

  let vr : ValidationRequest<Settings> = try! JSONDecoder().decode(
    ValidationRequest<Settings>.self, from: Data(payload.utf8))

  let jsonPath = SwiftPath("$.request.object.metadata.name")!

  if let match = try? jsonPath.evaluate(with: payload),
    let objectName = match as? String
  {
    if vr.settings.deniedNames.contains(objectName) {
      return rejectRequest(
        message: "resource name '\(objectName)' is not allowed",
        code: nil)
    }
    return acceptRequest()
  }

  // we're here because no name is specified, this shouldn't happen
  // because Kubernetes enforces all the object must have a name
  return rejectRequest(
    message: "resource must have a name",
    code: nil)
}
