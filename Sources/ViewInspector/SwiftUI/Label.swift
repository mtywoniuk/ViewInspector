import SwiftUI

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
public extension ViewType {
    
    struct Label: KnownViewType {
        public static let typePrefix: String = "Label"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func label() throws -> InspectableView<ViewType.Label> {
        return try .init(try child(), parent: self, index: nil)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func label(_ index: Int) throws -> InspectableView<ViewType.Label> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Custom Attributes

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
public extension InspectableView where View == ViewType.Label {
    
    func title() throws -> InspectableView<ViewType.ClassifiedView> {
        let view = try Inspector.attribute(label: "title", value: content.view)
        return try .init(try Inspector.unwrap(content: Content(view)), parent: self, index: nil)
    }
    
    func icon() throws -> InspectableView<ViewType.ClassifiedView> {
        let view = try Inspector.attribute(label: "icon", value: content.view)
        return try .init(try Inspector.unwrap(content: Content(view)), parent: self, index: nil)
    }
}

// MARK: - Global View Modifiers

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
public extension InspectableView {

    func labelStyle() throws -> Any {
        let modifier = try self.modifier({ modifier -> Bool in
            return modifier.modifierType.hasPrefix("LabelStyleModifier")
        }, call: "labelStyle")
        return try Inspector.attribute(path: "modifier|style", value: modifier)
    }
}

// MARK: - LabelStyle inspection

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
public extension LabelStyle {
    func inspect() throws -> InspectableView<ViewType.ClassifiedView> {
        let config = LabelStyleConfiguration()
        let view = try makeBody(configuration: config).inspect()
        return try .init(view.content, parent: nil, index: nil)
    }
}

// MARK: - Style Configuration initializer

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
private extension LabelStyleConfiguration {
    struct Allocator { }
    init() {
        self = unsafeBitCast(Allocator(), to: Self.self)
    }
}
