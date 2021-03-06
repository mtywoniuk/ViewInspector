import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct TextField: KnownViewType {
        public static var typePrefix: String = "TextField"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func textField() throws -> InspectableView<ViewType.TextField> {
        return try .init(try child(), parent: self, index: nil)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func textField(_ index: Int) throws -> InspectableView<ViewType.TextField> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.TextField {
    
    func labelView() throws -> InspectableView<ViewType.ClassifiedView> {
        let view = try Inspector.attribute(label: "label", value: content.view)
        return try .init(try Inspector.unwrap(content: Content(view)), parent: self, index: nil)
    }
    
    @available(*, deprecated, message: "Please use .labelView().text() instead")
    func text() throws -> InspectableView<ViewType.Text> {
        return try labelView().text()
    }
    
    func callOnEditingChanged() throws {
        let action = try Inspector.attribute(label: "onEditingChanged", value: content.view)
        typealias Callback = (Bool) -> Void
        if let callback = action as? Callback {
            callback(false)
        }
    }
    
    func callOnCommit() throws {
        let action = try Inspector.attribute(label: "onCommit", value: content.view)
        typealias Callback = () -> Void
        if let callback = action as? Callback {
            callback()
        }
    }
    
    func input() throws -> String {
        return try inputBinding().wrappedValue
    }
    
    func setInput(_ value: String) throws {
        try inputBinding().wrappedValue = value
    }
    
    private func inputBinding() throws -> Binding<String> {
        let label: String
        if #available(iOS 13.2, macOS 10.17, tvOS 13.2, *) {
            label = "_text"
        } else {
            label = "text"
        }
        return try Inspector.attribute(label: label, value: content.view, type: Binding<String>.self)
    }
}

// MARK: - Global View Modifiers

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {

    func textFieldStyle() throws -> Any {
        let modifier = try self.modifier({ modifier -> Bool in
            return modifier.modifierType.hasPrefix("TextFieldStyleModifier")
        }, call: "textFieldStyle")
        return try Inspector.attribute(path: "modifier|style", value: modifier)
    }
}
