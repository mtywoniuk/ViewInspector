import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct Picker: KnownViewType {
        public static let typePrefix: String = "Picker"
    }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.Picker: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let content = try Inspector.attribute(label: "content", value: content.view)
        return try Inspector.viewsInContainer(view: content)
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func picker() throws -> InspectableView<ViewType.Picker> {
        return try .init(try child(), parent: self, index: nil)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func picker(_ index: Int) throws -> InspectableView<ViewType.Picker> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.Picker {
    
    @available(*, deprecated, renamed: "labelView")
    func label() throws -> InspectableView<ViewType.ClassifiedView> {
        return try labelView()
    }
    
    func labelView() throws -> InspectableView<ViewType.ClassifiedView> {
        let view = try Inspector.attribute(label: "label", value: content.view)
        return try .init(try Inspector.unwrap(content: Content(view)), parent: self, index: nil)
    }
    
    func select<SelectionValue>(value: SelectionValue) throws where SelectionValue: Hashable {
        let binding = try Inspector.attribute(path: "selection", value: content.view)
        let typeName = Inspector.typeName(value: binding)
        guard let casted = binding as? Binding<SelectionValue> else {
            let expected = String(Array(Array(typeName)[8..<typeName.count - 1]))
            let factual = Inspector.typeName(type: SelectionValue.self)
            throw InspectionError
            .notSupported("select(value:) expects a value of type \(expected) but received \(factual)")
        }
        casted.wrappedValue = value
    }
}

// MARK: - Global View Modifiers

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {

    func pickerStyle() throws -> Any {
        let modifier = try self.modifier({ modifier -> Bool in
            return modifier.modifierType.hasPrefix("PickerStyleWriter")
        }, call: "pickerStyle")
        return try Inspector.attribute(path: "modifier|style", value: modifier)
    }
}
