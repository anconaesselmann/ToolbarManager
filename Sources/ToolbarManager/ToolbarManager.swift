//  Created by Axel Ancona Esselmann on 9/13/23.
//

import SwiftUI
import Combine

@MainActor
public class ToolbarManager: ObservableObject {

    fileprivate struct ToolbarStates: OptionSet {
        let rawValue: Int
    }

    internal typealias Stream = PassthroughSubject<ToolbarEvent, Never>

    @MainActor
    internal let stream = Stream()

    @MainActor
    @AppStorage("TAS.ToolbarManager.states")
    private var states = ToolbarStates()

    @MainActor
    @AppStorage("TAS.ToolbarManager.disabled")
    private var disabled = ToolbarStates()

    @MainActor
    @AppStorage("TAS.ToolbarManager.invisible")
    private var invisible = ToolbarStates()

    public init() { }

    @MainActor
    public func initialize(
        set setElements: [any ToolbarElement] = [],
        unset unsetElements: [any ToolbarElement] = [],
        disabled disabledElements: [any ToolbarElement] = []
    ) {
        for item in setElements {
            set(item)
        }
        for item in unsetElements {
            unset(item)
        }
        for item in disabledElements {
            set(isDisabled: true, for: item)
            unset(item)
        }
    }

    @MainActor
    public func events<T>(
        _ interactions: Set<ToolbarInteraction>,
        for element: T
    ) -> AnyPublisher<AppToolbarEvent<T>, Never>
        where T: ToolbarElement, T: Equatable
    {
        stream
            .compactMap { event -> AppToolbarEvent<T>? in
                guard let appEvent = event.element as? T else {
                    return nil
                }
                return AppToolbarEvent(element: appEvent, interaction: event.interaction, disabled: event.disabled, isVisible: event.isVisible)
            }
            .filter {
                guard $0.element == element else {
                    return false
                }
                return interactions.contains($0.interaction)
            }
            .eraseToAnyPublisher()
    }

    @MainActor
    public func set(_ item: any ToolbarElement) {
        guard !states.containsElement(item) else {
            return
        }
        states.insertElement(item)
        let event = ToolbarEvent(
            element: item,
            interaction: .set,
            disabled: disabled(item),
            isVisible: visible(item)
        )
        stream.send(event)
    }

    @MainActor
    public func unset(_ item: any ToolbarElement) {
        guard states.containsElement(item) else {
            return
        }
        states.removeElement(item)
        let event = ToolbarEvent(
            element: item,
            interaction: .release,
            disabled: disabled(item),
            isVisible: visible(item)
        )
        stream.send(event)
    }

    @MainActor
    public func press(_ item: any ToolbarElement) {
        let event = ToolbarEvent(
            element: item,
            interaction: .press,
            disabled: disabled(item),
            isVisible: visible(item)
        )
        stream.send(event)
    }

    @MainActor
    public func toggle(_ item: any ToolbarElement) {
        if states.containsElement(item) {
            unset(item)
        } else {
            set(item)
        }
    }

    @MainActor
    public func set(_ item: any ToolbarElement, to isSet: Bool) {
        if states.containsElement(item) != isSet {
            toggle(item)
        }
    }

    @MainActor
    public func isPressed(_ item: any ToolbarElement) -> Bool {
        states.containsElement(item)
    }

    @MainActor
    public func disabled(_ item: any ToolbarElement) -> Bool {
        disabled.containsElement(item)
    }

    @MainActor
    public func set(isDisabled: Bool, for item: any ToolbarElement) {
        if isDisabled {
            disabled.insertElement(item)
        } else {
            disabled.removeElement(item)
        }
        let event = ToolbarEvent(
            element: item,
            interaction: .none,
            disabled: isDisabled,
            isVisible: visible(item)
        )
        stream.send(event)
    }

    @MainActor
    public func visible(_ item: any ToolbarElement) -> Bool {
        !invisible.containsElement(item)
    }

    @MainActor
    public func set(isVisible: Bool, for item: any ToolbarElement) {
        if isVisible {
            invisible.removeElement(item)
        } else {
            invisible.insertElement(item)
        }
        let event = ToolbarEvent(
            element: item,
            interaction: .none,
            disabled: disabled(item),
            isVisible: isVisible
        )
        stream.send(event)
    }

    @MainActor
    public func isSetBinding(for item: any ToolbarElement) -> Binding<Bool> {
        Binding(
            get: { [weak self] in
                self?.isPressed(item) ?? false
            },
            set: { [weak self] in
                self?.set(item, to: $0)
            }
        )
    }
}

private extension ToolbarManager.ToolbarStates {
    func containsElement(_ member: any ToolbarElement) -> Bool {
        contains(Self(rawValue: member.powerOfTwo))
    }

    mutating func insertElement(_ newMember: any ToolbarElement) {
        insert(Self(rawValue: newMember.powerOfTwo))
    }

    mutating func removeElement(_ newMember: any ToolbarElement) {
        remove(Self(rawValue: newMember.powerOfTwo))
    }
}
