import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct View<T>: KnownViewType, CustomViewType where T: Inspectable {
        public static var typePrefix: String {
            return Inspector.typeName(type: T.self, prefixOnly: true)
        }
        
        public static func inspectionCall(index: Int?) -> String {
            if let index = index {
                return ".view(\(typePrefix).self, \(index))"
            }
            return ".view(\(typePrefix).self)"
        }
    }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.View: SingleViewContent {
    
    public static func child(_ content: Content) throws -> Content {
        let inspectable = try Inspector.cast(value: content.view, type: Inspectable.self)
        return try Inspector.unwrap(view: inspectable.content, modifiers: [])
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.View: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let inspectable = try Inspector.cast(value: content.view, type: Inspectable.self)
        return try Inspector.viewsInContainer(view: inspectable.content,
                                              resetModifiersForSingleChild: true)
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func view<T>(_ type: T.Type) throws -> InspectableView<ViewType.View<T>> where T: Inspectable {
        let child = try View.child(content)
        let prefix = Inspector.typeName(type: type, prefixOnly: true)
        let call = View.inspectionCall(index: nil)
        try Inspector.guardType(value: child.view, prefix: prefix, inspectionCall: call)
        return try .init(child, parent: self, index: nil)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func view<T>(_ type: T.Type, _ index: Int) throws -> InspectableView<ViewType.View<T>> where T: Inspectable {
        let content = try child(at: index)
        let prefix = Inspector.typeName(type: type, prefixOnly: true)
        let call = View.inspectionCall(index: index)
        try Inspector.guardType(value: content.view, prefix: prefix, inspectionCall: call)
        return try .init(content, parent: self, index: index)
    }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: CustomViewType {
    
    func actualView() throws -> View.T {
        return try Inspector.cast(value: content.view, type: View.T.self)
    }

    @available(*, deprecated, message: "You can remove .viewBuilder()")
    func viewBuilder() throws -> InspectableView<View> {
        return self
    }
}

#if os(macOS)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension NSViewRepresentable where Self: Inspectable {
    func nsView() throws -> NSViewType {
        return try ViewHosting.lookup(Self.self)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension NSViewControllerRepresentable where Self: Inspectable {
    func viewController() throws -> NSViewControllerType {
        return try ViewHosting.lookup(Self.self)
    }
}
#else
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension UIViewRepresentable where Self: Inspectable {
    func uiView() throws -> UIViewType {
        return try ViewHosting.lookup(Self.self)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension UIViewControllerRepresentable where Self: Inspectable {
    func viewController() throws -> UIViewControllerType {
        return try ViewHosting.lookup(Self.self)
    }
}
#endif
