//
//  PageView.swift
//
//  Created by nori on 2021/02/03.
//

import SwiftUI
import UIKit

public struct PageView<SelectionValue, Content> where SelectionValue: Hashable {
    
    public enum TransitionStyle {
        case pageCurl
        case scroll
    }
    
    public var axis: Axis
    
    public var transitionStyle: TransitionStyle
    
    public var selection: Binding<SelectionValue>?
    
    public var content: Content
    
    fileprivate var data: Array<SelectionValue>
    
    fileprivate var page: (SelectionValue) -> AnyView
}

extension PageView where Content: View {
    
    public init<Data, ID, InContent>(axis: Axis = .horizontal, transitionStyle: TransitionStyle = .scroll, @ViewBuilder content: () -> Content) where Content == ForEach<Data, ID, InContent>, Data: RandomAccessCollection, ID: Hashable, Data.Element == SelectionValue, InContent: View {
        self.axis = axis
        self.transitionStyle = transitionStyle
        self.content = content()
        self.data = Array(self.content.data)
        let content = self.content.content
        self.page = { data -> AnyView in
            return AnyView(content(data))
        }
    }
    
    public init<Data, InContent>(_ selection: Binding<SelectionValue>, axis: Axis = .horizontal, transitionStyle: TransitionStyle = .scroll, @ViewBuilder content: () -> Content) where Content == ForEach<Data, SelectionValue, InContent>, Data: RandomAccessCollection, Data.Element == SelectionValue, InContent: View {
        self.selection = selection
        self.axis = axis
        self.transitionStyle = transitionStyle
        self.content = content()
        self.data = Array(self.content.data)
        let content = self.content.content
        self.page = { data -> AnyView in
            return AnyView(content(data))
        }
    }
    
    public init<C0, C1>(axis: Axis = .horizontal, transitionStyle: TransitionStyle = .scroll, @ViewBuilder content: () -> Content) where Content == TupleView<(C0, C1)>, C0: View, C1: View, SelectionValue == Int {
        self.axis = axis
        self.transitionStyle = transitionStyle
        self.content = content()
        let value = self.content.value
        self.data = Array(0..<2)
        self.page = { index -> AnyView in
            switch index {
                case 0: return AnyView(value.0)
                case 1: return AnyView(value.1)
                default: fatalError()
            }
        }
    }
    
    public init<C0, C1, C2>(axis: Axis = .horizontal, transitionStyle: TransitionStyle = .scroll, @ViewBuilder content: () -> Content) where Content == TupleView<(C0, C1, C2)>, C0: View, C1: View, C2: View, SelectionValue == Int {
        self.axis = axis
        self.transitionStyle = transitionStyle
        self.content = content()
        let value = self.content.value
        self.data = Array(0..<3)
        self.page = { index -> AnyView in
            switch index {
                case 0: return AnyView(value.0)
                case 1: return AnyView(value.1)
                case 2: return AnyView(value.2)
                default: fatalError()
            }
        }
    }
    
    public init<C0, C1, C2, C3>(axis: Axis = .horizontal, transitionStyle: TransitionStyle = .scroll, @ViewBuilder content: () -> Content) where Content == TupleView<(C0, C1, C2, C3)>, C0: View, C1: View, C2: View, C3: View, SelectionValue == Int {
        self.axis = axis
        self.transitionStyle = transitionStyle
        self.content = content()
        let value = self.content.value
        self.data = Array(0..<4)
        self.page = { index -> AnyView in
            switch index {
                case 0: return AnyView(value.0)
                case 1: return AnyView(value.1)
                case 2: return AnyView(value.2)
                case 3: return AnyView(value.3)
                default: fatalError()
            }
        }
    }
    
    public init<C0, C1, C2, C3, C4>(axis: Axis = .horizontal, transitionStyle: TransitionStyle = .scroll, @ViewBuilder content: () -> Content) where Content == TupleView<(C0, C1, C2, C3, C4)>, C0: View, C1: View, C2: View, C3: View, C4: View, SelectionValue == Int {
        self.axis = axis
        self.transitionStyle = transitionStyle
        self.content = content()
        let value = self.content.value
        self.data = Array(0..<5)
        self.page = { index -> AnyView in
            switch index {
                case 0: return AnyView(value.0)
                case 1: return AnyView(value.1)
                case 2: return AnyView(value.2)
                case 3: return AnyView(value.3)
                case 4: return AnyView(value.4)
                default: fatalError()
            }
        }
    }
}

extension PageView.TransitionStyle {
    var rawValue: UIPageViewController.TransitionStyle {
        switch self {
            case .pageCurl: return .pageCurl
            case .scroll: return .scroll
        }
    }
}

extension Axis {
    
    var navigationOrientation: UIPageViewController.NavigationOrientation {
        switch self {
            case .horizontal: return .horizontal
            case .vertical: return .vertical
        }
    }
}

extension PageView: UIViewControllerRepresentable {
    
    public func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    public func makeUIViewController(context: Context) -> UIPageViewController {
        let pageViewController = UIPageViewController(
            transitionStyle: transitionStyle.rawValue,
            navigationOrientation: axis.navigationOrientation)
        pageViewController.dataSource = context.coordinator
        pageViewController.delegate = context.coordinator
        return pageViewController
    }
    
    func viewController(index: Int) -> UIViewController {
        let data = self.data[index]
        let view = self.page(data)
        let viewController = UIHostingController(rootView: view)
        viewController.view.tag = index
        return viewController
    }
    
    func updateUIView(_ viewControllers: [UIViewController]?) {
        viewControllers?.forEach({ viewController in
            if let viewController = viewController as? UIHostingController<AnyView> {
                let data = self.data[viewController.view.tag]
                let view = self.page(data)
                viewController.rootView = view
            }
        })
    }
    
    public func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
        if let selection = selection?.wrappedValue {
            if let index = self.data.firstIndex(of: selection) {
                if context.coordinator.index != index {
                    let viewController = viewController(index: index)
                    let direction: UIPageViewController.NavigationDirection = context.coordinator.index < index ? .forward : .reverse
                    pageViewController.setViewControllers([viewController], direction: direction, animated: true) { finished in
                        if finished {
                            context.coordinator.index = index
                        }
                    }
                } else {
                    let viewController = viewController(index: index)
                    pageViewController.setViewControllers([viewController], direction: .forward, animated: false, completion: nil)
                }
            } else {
                if let viewControllers = pageViewController.viewControllers, !viewControllers.isEmpty {
                    updateUIView(viewControllers)
                } else {
                    let viewController = viewController(index: context.coordinator.index)
                    pageViewController.setViewControllers([viewController], direction: .forward, animated: false, completion: nil)
                }
            }
        } else {
            if let viewControllers = pageViewController.viewControllers, !viewControllers.isEmpty {
                updateUIView(viewControllers)
            } else {
                let viewController = viewController(index: context.coordinator.index)
                pageViewController.setViewControllers([viewController], direction: .forward, animated: false, completion: nil)
            }
        }
    }
}

extension PageView {
    
    public class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        
        var parent: PageView
        
        var index: Int = 0
        
        init(_ pageViewController: PageView) {
            parent = pageViewController
        }
        
        public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
            parent.updateUIView(pageViewController.viewControllers)
        }
        
        public func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerBefore viewController: UIViewController) -> UIViewController? {
                let data = parent.data
                if 0 < index && index <= data.count - 1 {
                    let data = data[index - 1]
                    let view = self.parent.page(data)
                    let viewController: UIHostingController = UIHostingController(rootView: view)
                    viewController.view.tag = index - 1
                    return viewController
                }
                return nil
            }
        
        public func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerAfter viewController: UIViewController) -> UIViewController? {
                let data = parent.data
                if 0 <= index && index < data.count - 1 {
                    let data = data[index + 1]
                    let view = self.parent.page(data)
                    let viewController: UIHostingController = UIHostingController(rootView: view)
                    viewController.view.tag = index + 1
                    return viewController
                }
                return nil
            }
        
        public func pageViewController(
            _ pageViewController: UIPageViewController,
            didFinishAnimating finished: Bool,
            previousViewControllers: [UIViewController],
            transitionCompleted completed: Bool) {
                if completed, let visibleViewController = pageViewController.viewControllers?.first {
                    self.index = visibleViewController.view.tag
                    self.parent.selection?.wrappedValue = self.parent.data[self.index]
                }
            }
    }
}

struct PageView_Previews: PreviewProvider {
    struct ContentView: View {
        
        var body: some View {
            Group {
                PageView {
                    ForEach(0..<2) { index in
                        Text("\(index)")
                    }
                }
                
                PageView {
                    ForEach(["a", "b"], id: \.self) { index in
                        Text("\(index)")
                    }
                }
                
                PageView {
                    Text("a")
                    Text("b")
                }
            }
        }
    }
    
    static var previews: some View {
        ContentView()
    }
}
