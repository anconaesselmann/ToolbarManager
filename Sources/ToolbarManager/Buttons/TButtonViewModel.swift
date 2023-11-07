//  Created by Axel Ancona Esselmann on 11/6/23.
//

import Foundation
import Combine

@MainActor
class TButtonViewModel<T: ToolbarElement>: ObservableObject {

    private var bag: AnyCancellable?

    internal var registeredAction: (() -> Void)?

    private var lastEvent: AppToolbarEvent<T>?

    @MainActor
    func register(
        with manager: ToolbarManager,
        observe element: T,
        as buttonType: ToobarButtonType = .button,
        action: @escaping () -> Void
    ) {
        update(with: manager, element: element)
        bag = manager.events([.set, .release, .press, .none], for: element)
            .sink { [weak self] event in
                self?.update(with: manager, event: event)
            }
        registeredAction = {
            action()
            switch buttonType {
            case .button:
                manager.press(element)
            case .toggle:
                manager.toggle(element)
            }
        }
    }

    var visible: Bool {
        lastEvent?.isVisible ?? true
    }
    var disabled: Bool {
        lastEvent?.disabled ?? false
    }
    var isSet: Bool {
        guard let lastInteraction = lastEvent?.interaction else {
            return false
        }
        switch lastInteraction {
        case .set:
            return true
        case .release, .press, .none: return false
        }
    }

    @MainActor
    private func update(with manager: ToolbarManager, element: T) {
        lastEvent = .init(
            element: element,
            interaction: .none,
            disabled: manager.disabled(element),
            isVisible: manager.visible(element)
        )
        self.objectWillChange.send()
    }

    @MainActor
    private func update(with manager: ToolbarManager, event: AppToolbarEvent<T>) {
        lastEvent = event
        self.objectWillChange.send()
    }
}
