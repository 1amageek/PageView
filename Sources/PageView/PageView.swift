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

    public var selection: Binding<SelectionValue?>?

    public var content: Content

    fileprivate var lazyMapSequence: LazyMapSequence<StrideTo<Int>, (SelectionValue, AnyView)>

}

extension PageView where Content: View {

    public init<Data, ID, RowContent>(axis: Axis = .horizontal, transitionStyle: TransitionStyle = .scroll, @ViewBuilder content: () -> Content) where Content == ForEach<Data, ID, RowContent>, Data: RandomAccessCollection, ID: Hashable, Data.Element == SelectionValue, RowContent: View {
        self.axis = axis
        self.transitionStyle = transitionStyle
        self.content = content()
        let data = Array(self.content.data)
        let content = self.content.content
        self.lazyMapSequence = stride(from: 0, to: self.content.data.count, by: 1).lazy.map { index -> (Data.Element, AnyView) in
            let element = data[index]
            return (element, AnyView(content(element)))
        }
    }

    public init<Data, RowContent>(_ selection: Binding<SelectionValue?>, axis: Axis = .horizontal, transitionStyle: TransitionStyle = .scroll, @ViewBuilder content: () -> Content) where Content == ForEach<Data, SelectionValue, RowContent>, Data: RandomAccessCollection, Data.Element == SelectionValue, RowContent: View {
        self.selection = selection
        self.axis = axis
        self.transitionStyle = transitionStyle
        self.content = content()
        let data = Array(self.content.data)
        let content = self.content.content
        self.lazyMapSequence = stride(from: 0, to: self.content.data.count, by: 1).lazy.map { index -> (Data.Element, AnyView) in
            let element = data[index]
            return (element, AnyView(content(element)))
        }
    }

    public init<C0, C1>(axis: Axis = .horizontal, transitionStyle: TransitionStyle = .scroll, @ViewBuilder content: () -> Content) where Content == TupleView<(C0, C1)>, C0: View, C1: View, SelectionValue == Int {
        self.axis = axis
        self.transitionStyle = transitionStyle
        self.content = content()
        let value = self.content.value
        self.lazyMapSequence = stride(from: 0, to: 2, by: 1).lazy.map { index -> (Int, AnyView) in
            switch index {
                case 0: return (0, AnyView(value.0))
                case 1: return (1, AnyView(value.1))
                default: fatalError()
            }
        }
    }

    public init<C0, C1, C2>(axis: Axis = .horizontal, transitionStyle: TransitionStyle = .scroll, @ViewBuilder content: () -> Content) where Content == TupleView<(C0, C1, C2)>, C0: View, C1: View, C2: View, SelectionValue == Int {
        self.axis = axis
        self.transitionStyle = transitionStyle
        self.content = content()
        let value = self.content.value
        self.lazyMapSequence = stride(from: 0, to: 3, by: 1).lazy.map { index -> (Int, AnyView) in
            switch index {
                case 0: return (0, AnyView(value.0))
                case 1: return (1, AnyView(value.1))
                case 2: return (2, AnyView(value.2))
                default: fatalError()
            }
        }
    }

    public init<C0, C1, C2, C3>(axis: Axis = .horizontal, transitionStyle: TransitionStyle = .scroll, @ViewBuilder content: () -> Content) where Content == TupleView<(C0, C1, C2, C3)>, C0: View, C1: View, C2: View, C3: View, SelectionValue == Int {
        self.axis = axis
        self.transitionStyle = transitionStyle
        self.content = content()
        let value = self.content.value
        self.lazyMapSequence = stride(from: 0, to: 4, by: 1).lazy.map { index -> (Int, AnyView) in
            switch index {
                case 0: return (0, AnyView(value.0))
                case 1: return (1, AnyView(value.1))
                case 2: return (2, AnyView(value.2))
                case 3: return (3, AnyView(value.3))
                default: fatalError()
            }
        }
    }

    public init<C0, C1, C2, C3, C4>(axis: Axis = .horizontal, transitionStyle: TransitionStyle = .scroll, @ViewBuilder content: () -> Content) where Content == TupleView<(C0, C1, C2, C3, C4)>, C0: View, C1: View, C2: View, C3: View, C4: View, SelectionValue == Int {
        self.axis = axis
        self.transitionStyle = transitionStyle
        self.content = content()
        let value = self.content.value
        self.lazyMapSequence = stride(from: 0, to: 5, by: 1).lazy.map { index -> (Int, AnyView) in
            switch index {
                case 0: return (0, AnyView(value.0))
                case 1: return (1, AnyView(value.1))
                case 2: return (2, AnyView(value.2))
                case 3: return (3, AnyView(value.3))
                case 4: return (4, AnyView(value.4))
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
        let index = context.coordinator.index
        let viewController = viewController(index: index)
        pageViewController.setViewControllers([viewController], direction: .forward, animated: true)
        return pageViewController
    }

    func viewController(index: Int) -> UIViewController {
        let (_, view) = Array(lazyMapSequence)[index]
        let viewController = UIHostingController(rootView: view)
        viewController.view.tag = index
        return viewController
    }

    public func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
        if let selection = selection?.wrappedValue {
            if let index = Array(lazyMapSequence).firstIndex(where: { $0.0 == selection }), context.coordinator.index != index {
                let viewController = viewController(index: index)
                let direction: UIPageViewController.NavigationDirection = context.coordinator.index < index ? .forward : .reverse
                pageViewController.setViewControllers([viewController], direction: direction, animated: true) { finished in
                    if finished {
                        context.coordinator.index = index
                    }
                }
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

        public func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerBefore viewController: UIViewController) -> UIViewController? {
                let data = Array(parent.lazyMapSequence)
                if 0 < index && index <= data.count - 1 {
                    let (_, view) = data[index - 1]
                    let viewController: UIHostingController = UIHostingController(rootView: view)
                    viewController.view.tag = index - 1
                    return viewController
                }
                return nil
            }

        public func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerAfter viewController: UIViewController) -> UIViewController? {
                let data = Array(parent.lazyMapSequence)
                if 0 <= index && index < data.count - 1 {
                    let (_, view) = data[index + 1]
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
                    self.parent.selection?.wrappedValue = Array(parent.lazyMapSequence)[self.index].0
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
