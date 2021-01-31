//
//  PageView.swift
//
//  Created by nori on 2021/01/29.
//

import UIKit
import SwiftUI

struct PageViewController: UIViewControllerRepresentable {

    var controllers: [UIViewController]

    @Binding var currentPage: Int

    var direction: UIPageViewController.NavigationDirection

    var animated: Bool

    init(_ controllers: [UIViewController],
         currentPage: Binding<Int>,
         direction: UIPageViewController.NavigationDirection,
         animated: Bool) {
        self.controllers = controllers
        self._currentPage = currentPage
        self.direction = direction
        self.animated = animated
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIPageViewController {
        let pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal)
        pageViewController.dataSource = context.coordinator
        pageViewController.delegate = context.coordinator
        return pageViewController
    }

    func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
        pageViewController.setViewControllers([controllers[currentPage]],
                                              direction: direction,
                                              animated: animated)
    }

    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

        var parent: PageViewController

        init(_ pageViewController: PageViewController) {
            self.parent = pageViewController
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let index = parent.controllers.firstIndex(of: viewController) else {
                return nil
            }
            if index == 0 {
                return nil
            }
            return parent.controllers[index - 1]
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let index = parent.controllers.firstIndex(of: viewController) else {
                return nil
            }
            if index + 1 == parent.controllers.count {
                return nil
            }
            return parent.controllers[index + 1]
        }

        func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            if completed,
                let visibleViewController = pageViewController.viewControllers?.first,
                let index = parent.controllers.firstIndex(of: visibleViewController)
            {
                parent.currentPage = index
            }
        }
    }
}

public struct PageView<Page: View>: View {

    public var viewControllers: [UIHostingController<Page>]

    @Binding public var currentPage: Int

    public var direction: UIPageViewController.NavigationDirection

    public var animated: Bool

    public init(_ views: [Page],
         currentPage: Binding<Int>,
         direction: UIPageViewController.NavigationDirection = .forward,
         animated: Bool = true) {
        self.viewControllers = views.map { UIHostingController(rootView: $0) }
        self._currentPage = currentPage
        self.direction = direction
        self.animated = animated
    }

    public var body: some View {
        PageViewController(viewControllers,
                           currentPage: $currentPage,
                           direction: direction,
                           animated: animated)
    }
}
