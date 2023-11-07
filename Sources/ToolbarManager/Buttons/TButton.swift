//  Created by Axel Ancona Esselmann on 11/6/23.
//

import SwiftUI

public struct TButton<L, T>: View
    where L: View, T: ToolbarElement
{
    private struct Registration {
        let manager: ToolbarManager
        let element: T
        let buttonType: ToobarButtonType
    }

    private struct Style {
        let set: Color
        let notSet: Color
        let disabledOpacity: Double
    }

    @StateObject
    private var vm: TButtonViewModel<T>

    @ViewBuilder
    private var label: () -> L

    private let viewAction: () -> Void
    private var registration: Registration?

    private var color: Color {
        let isPressed = vm.isSet
        let isDisabled = vm.disabled
        let color: Color = isPressed ? (style?.set ?? .blue) : (style?.notSet ?? .white)
        return isDisabled ? color.opacity(style?.disabledOpacity ?? 0.2) : color
    }

    private var style: Style?

    public var body: some View {
        VStack {
            if vm.visible {
                Button {
                    vm.registeredAction?()
                } label: {
                    label()
                        .foregroundColor(color)
                }
                .disabled(vm.disabled)
            } else {
                EmptyView()
            }
        }
        .onAppear {
            guard let registration = registration else {
                return
            }
            vm.register(with: registration.manager, observe: registration.element, as: registration.buttonType, action: viewAction)
        }
    }

    @MainActor
    public func register(
        with manager: ToolbarManager,
        observe element: T,
        as type: ToobarButtonType = .button
    ) -> Self {
        var new = self
        new.registration = Registration(
            manager: manager,
            element: element,
            buttonType: type
        )
        return new
    }

    @MainActor
    public func colorsForState(set: Color, notSet: Color, disabledOpacity: Double = 0.2) -> Self {
        var copy = self
        copy.style = .init(set: set, notSet: notSet, disabledOpacity: disabledOpacity)
        return copy
    }
}

public extension TButton where L == Label<Text, Image> {
    init(action: (() -> Void)? = nil, @ViewBuilder label: @escaping () -> Label<Text, Image>) {
        let vm = TButtonViewModel<T>()
        _vm = StateObject(wrappedValue: vm)
        self.label = label
        self.viewAction = action ?? { }
    }
}

public extension  TButton where L == Text {
    init(_ titleKey: LocalizedStringKey, action: (() -> Void)? = nil) {
        let vm = TButtonViewModel<T>()
        _vm = StateObject(wrappedValue: vm)
        self.label = {
            Text(titleKey)
        }
        self.viewAction = action ?? { }
    }
}

public extension  TButton where L == SwiftUI.Label<Text, Image> {
    init(_ titleKey: LocalizedStringKey, systemImage: String, action: (() -> Void)? = nil) {
        let vm = TButtonViewModel<T>()
        _vm = StateObject(wrappedValue: vm)
        self.label = {
            Label(titleKey, systemImage: systemImage)
        }
        self.viewAction = action ?? { }
    }

    init<S>(_ title: S, systemImage: String, action: (() -> Void)? = nil) where S : StringProtocol {
        let vm = TButtonViewModel<T>()
        _vm = StateObject(wrappedValue: vm)
        self.label = {
            Label(title, systemImage: systemImage)
        }
        self.viewAction = action ?? { }
    }

    init(_ titleKey: LocalizedStringKey, image: ImageResource, action: (() -> Void)? = nil) {
        let vm = TButtonViewModel<T>()
        _vm = StateObject(wrappedValue: vm)
        self.label = {
            Label(titleKey, image: image)
        }
        self.viewAction = action ?? { }
    }

    init<S>(_ title: S, image: ImageResource, action: (() -> Void)? = nil) where S : StringProtocol {
        let vm = TButtonViewModel<T>()
        _vm = StateObject(wrappedValue: vm)
        self.label = {
            Label(title, image: image)
        }
        self.viewAction = action ?? { }
    }
}
