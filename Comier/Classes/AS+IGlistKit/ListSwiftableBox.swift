import Foundation
import IGListKit

public protocol ListSwiftable {
    var identifier: String {get}
    func isEqual(to value: ListSwiftable) -> Bool
}

public extension ListSwiftable {
    func isEqual(to value: ListSwiftable) -> Bool {
        return true
    }
}

public final class ListDiffableBox: ListDiffable {

    /**
     The boxed value.
     */
    public let value: ListSwiftable

    private let _diffIdentifier: NSObjectProtocol

    /**
     Initialize a new `ListDiffableBox` object.
     @param value The value to be boxed.
     */
    public init(value: ListSwiftable) {
        self.value = value
        // namespace the identifier with the value type to help prevent collisions
        self._diffIdentifier = "\(type(of: value))\(value.identifier)" as NSObjectProtocol
    }

    // MARK: ListDiffable
    /**
     :nodoc:
     */
    public func diffIdentifier() -> NSObjectProtocol {
        return _diffIdentifier as NSObjectProtocol
    }

    /**
     :nodoc:
     */
    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        // always true when using section models since ListSwiftSectionController handles updates at the cell level
        guard let box = object as? ListDiffableBox
            else { return false }
        return value.isEqual(to: box.value)
    }
}
