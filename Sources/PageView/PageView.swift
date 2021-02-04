//
//  PageView.swift
//
//  Created by nori on 2021/02/03.
//

import SwiftUI
import UIKit

public struct PageNavigation {

    public var page: Int

    public var direction: UIPageViewController.NavigationDirection
    
    public var animated: Bool

    public init(_ page: Int, direction: UIPageViewController.NavigationDirection = .forward, animated: Bool = true) {
        self.page = page
        self.direction = direction
        self.animated = animated
    }

    public static func forward(_ page: Int) -> PageNavigation {
        return .init(page, direction: .forward)
    }

    public static func reverse(_ page: Int) -> PageNavigation {
        return .init(page, direction: .reverse)
    }
}

public struct PageConfiguration {

    public var orientation: UIPageViewController.NavigationOrientation

    public var transitionStyle: UIPageViewController.TransitionStyle

    public var looping: Bool

    public init(orientation: UIPageViewController.NavigationOrientation = .horizontal,
                transitionStyle: UIPageViewController.TransitionStyle = .scroll,
                looping: Bool = false) {
        self.orientation = orientation
        self.transitionStyle = transitionStyle
        self.looping = looping
    }
}

public struct PageView<Page: View>: View {

    public var pages: [Page]

    @Binding public var navigation: PageNavigation

    public var configuration: PageConfiguration

    public init(_ pages: [Page], navigation: Binding<PageNavigation>, configuration: PageConfiguration = PageConfiguration()) {
        self.pages = pages
        self._navigation = navigation
        self.configuration = configuration
    }

    public var body: some View {
        PageViewController(pages: pages,
                           currentPage: $navigation[keyPath: \.page],
                           orientation: configuration.orientation,
                           direction: navigation.direction,
                           transitionStyle: configuration.transitionStyle,
                           animated: navigation.animated,
                           looping: configuration.looping)
    }
}

struct PageView_Previews: PreviewProvider {
    struct ContentView: View {

        @State var navigation: PageNavigation = .init(0)

        var body: some View {
            PageView([
                Button("0", action: {
                    self.navigation.page += 1
                }),
                Button("1", action: {
                    self.navigation.page += 1
                }),
                Button("2", action: {
                    self.navigation = .reverse(0)
                })
            ], navigation: $navigation)
        }
    }

    static var previews: some View {
        ContentView()
    }
}
