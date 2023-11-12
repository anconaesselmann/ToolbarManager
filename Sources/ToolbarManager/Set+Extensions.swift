//  Created by Axel Ancona Esselmann on 11/12/23.
//

import Foundation

extension Set: RawRepresentable where Element == String {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode(Array<Element>.self, from: data)
        else {
            return nil
        }
        self = Set(result)
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(Array(self)),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }

    func containsElement(_ member: any ToolbarElement) -> Bool {
        contains(member.rawValue)
    }

    mutating func insertElement(_ newMember: any ToolbarElement) {
        insert(newMember.rawValue)
    }

    mutating func removeElement(_ member: any ToolbarElement) {
        remove(member.rawValue)
    }
}
