//
//  NLScrollingNavigationBar.swift
//  NLScrollingNavigationBarDemo
//
//  Created by songhailiang on 09/06/2017.
//  Copyright © 2017 hailiang.song. All rights reserved.
//

import UIKit

/**
 The state of the navigation bar
 
 - collapsed: the navigation bar is fully collapsed
 - expanded: the navigation bar is fully visible
 - scrolling: the navigation bar is transitioning to either `Collapsed` or `Scrolling`
 */
public enum NLNavigationBarState {
    case collapsed, expanded, scrolling
}

public extension UINavigationController {
    
    /// enable the navigation bar scrollable
    public var nl_navBarScrollable: Bool {
        get { return proxy.navBarScrollable }
        set { proxy.navBarScrollable = newValue }
    }
    
    /// Returns the `NavigationBarState` of the navigation bar
    public var nl_navBarState: NLNavigationBarState {
        return proxy.state
    }
    
    /// observing a scrollView to scrolling the navigation bar
    ///
    /// - Parameter scrollView: scrollView to observing
    public func nl_followScrollView(_ scrollView: UIScrollView) {
        let proxy = self.proxy
        proxy.navigationController = self
        proxy.scrollView = scrollView
        //        self.proxy = proxy
    }
    
    /// show navigation bar
    ///
    /// - Parameters:
    ///   - animated: if true the scrolling is animated
    ///   - duration: animation duration
    public func nl_showNavigationBar(animated: Bool = true, duration: TimeInterval = 0.1) {
        proxy.showNavbar(animated: animated, duration: duration)
    }
    
    /// hide navigation bar
    ///
    /// - Parameters:
    ///   - animated: if true the scrolling is animated
    ///   - duration: animation duration
    public func nl_hideNavigationBar(animated: Bool = true, duration: TimeInterval = 0.1) {
        proxy.hideNavbar(animated: animated, duration: duration)
    }
    
}

extension UINavigationController {
    
    fileprivate var proxy: NavigationBarScrollableProxy {
        get {
            var proxy = objc_getAssociatedObject(self, &Key.proxyKey) as? NavigationBarScrollableProxy
            if proxy == nil {
                proxy = NavigationBarScrollableProxy()
                objc_setAssociatedObject(self, &Key.proxyKey, proxy, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return proxy!
        }
        set {
            objc_setAssociatedObject(self, &Key.proxyKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private struct Key {
        static var proxyKey: Void?
    }
}

fileprivate class NavigationBarScrollableProxy: NSObject, UIGestureRecognizerDelegate {
    
    weak var navigationController: UINavigationController?
    
    var navBarScrollable: Bool = true
    var lastContentOffset: CGFloat = 0
    var delayDistance: CGFloat = 0
    var maxDelay: CGFloat = 0
    var shouldScrollWhenContentFits: Bool = false
    
    var scrollView: UIScrollView? {
        didSet {
            if let scroll = scrollView {
                scroll.addGestureRecognizer(panGesture)
            }
        }
    }
    
    var state: NLNavigationBarState = .expanded {
        didSet {
            navigationController?.navigationBar.isUserInteractionEnabled = (state == .expanded)
        }
    }
    
    lazy var panGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        gesture.maximumNumberOfTouches = 1
        gesture.delegate = self
        return gesture
    }()
    
    
    // MARK: - GestureRecognizer
    
    func handlePan(_ gesture: UIPanGestureRecognizer) {
        if gesture.state != .failed {
            if let superview = self.scrollView?.superview {
                let translation = gesture.translation(in: superview)
                let delta = lastContentOffset - translation.y
                lastContentOffset = translation.y
                
                if shouldScrollWithDelta(delta) {
                    scrollWithDelta(delta)
                }
            }
        }
        if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
            checkForPartialScroll()
            lastContentOffset = 0
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panGesture {
            return true
        }
        return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return navBarScrollable
    }
    
    // MARK: - Scroll Methods
    
    func showNavbar(animated: Bool = true, duration: TimeInterval = 0.1) {
        guard let scrollableView = self.scrollView,
            let visibleViewController = navigationController?.visibleViewController,
            let navigationBar = navigationController?.navigationBar else { return }
        
        if state == .collapsed {
            panGesture.isEnabled = false
            let animations = {
                self.lastContentOffset = 0;
                self.scrollWithDelta(-self.fullNavbarHeight, ignoreDelay: true)
                visibleViewController.view.setNeedsLayout()
                if navigationBar.isTranslucent {
                    let currentOffset = scrollableView.contentOffset
                    scrollableView.contentOffset = CGPoint(x: currentOffset.x, y: currentOffset.y - self.navbarHeight)
                }
            }
            if animated {
                self.state = .scrolling
                UIView.animate(withDuration: duration, animations: animations) { _ in
                    self.state = .expanded
                    self.panGesture.isEnabled = true
                }
            } else {
                animations()
                self.state = .expanded
                panGesture.isEnabled = true
            }
        } else {
            updateNavbarAlpha()
        }
    }
    
    func hideNavbar(animated: Bool = true, duration: TimeInterval = 0.1) {
        guard let scrollableView = self.scrollView,
            let visibleViewController = navigationController?.visibleViewController,
            let navigationBar = navigationController?.navigationBar else { return }
        
        if state == .expanded {
            self.state = .scrolling
            UIView.animate(withDuration: animated ? duration : 0, animations: { () -> Void in
                self.scrollWithDelta(self.fullNavbarHeight)
                visibleViewController.view.setNeedsLayout()
                if navigationBar.isTranslucent {
                    let currentOffset = scrollableView.contentOffset
                    scrollableView.contentOffset = CGPoint(x: currentOffset.x, y: currentOffset.y + self.navbarHeight)
                }
            }) { _ in
                self.state = .collapsed
            }
        } else {
            updateNavbarAlpha()
        }
    }
    
    private func shouldScrollWithDelta(_ delta: CGFloat) -> Bool {
        guard let scrollableView = scrollView else { return false }
        
        let scrollDelta = delta
        // Check for rubberbanding
        if scrollDelta < 0 {
            if scrollableView.contentOffset.y + scrollableView.frame.size.height > scrollableView.contentSize.height && scrollableView.frame.size.height < scrollableView.contentSize.height {
                // Only if the content is big enough
                return false
            }
        }
        return true
    }
    
    private func scrollWithDelta(_ delta: CGFloat, ignoreDelay: Bool = false) {
        
        guard let scrollableView = scrollView else { return }
        
        var scrollDelta = delta
        let frame = navigationController?.navigationBar.frame ?? .zero
        
        // View scrolling up, hide the navbar
        if scrollDelta > 0 {
            // Update the delay
            if !ignoreDelay {
                delayDistance -= scrollDelta
                
                // Skip if the delay is not over yet
                if delayDistance > 0 {
                    return
                }
            }
            
            // No need to scroll if the content fits
            if !shouldScrollWhenContentFits && state != .collapsed &&
                scrollableView.frame.size.height >= scrollableView.contentSize.height {
                return
            }
            
            // Compute the bar position
            if frame.origin.y - scrollDelta < -deltaLimit {
                scrollDelta = frame.origin.y + deltaLimit
            }
            
            // Detect when the bar is completely collapsed
            if frame.origin.y <= -deltaLimit {
                state = .collapsed
                delayDistance = maxDelay
            } else {
                state = .scrolling
            }
        }
        
        if scrollDelta < 0 {
            // Update the delay
            if !ignoreDelay {
                delayDistance += scrollDelta
                
                // Skip if the delay is not over yet
                if delayDistance > 0 && maxDelay < scrollableView.contentOffset.y {
                    return
                }
            }
            
            // Compute the bar position
            if frame.origin.y - scrollDelta > statusBarHeight {
                scrollDelta = frame.origin.y - statusBarHeight
            }
            
            // Detect when the bar is completely expanded
            if frame.origin.y >= statusBarHeight {
                state = .expanded
                delayDistance = maxDelay
            } else {
                state = .scrolling
            }
        }
        
        if scrollDelta < 0 || (scrollDelta > 0 && !isBouncingTop) {
            updateSizing(scrollDelta)
            updateNavbarAlpha()
            restoreContentOffset(scrollDelta)
        }
        //        updateFollowers(scrollDelta)
    }
    
    private func updateSizing(_ delta: CGFloat) {
        guard let topViewController = navigationController?.topViewController else { return }
        guard let navigationBar = navigationController?.navigationBar else { return }
        
        // Move the navigation bar
        navigationBar.frame.origin.y -= delta
        
        // Resize the view if the navigation bar is not translucent
        if !navigationBar.isTranslucent {
            let navBarY = navigationBar.frame.origin.y + navigationBar.frame.size.height
            var frame = topViewController.view.frame
            frame.origin = CGPoint(x: frame.origin.x, y: navBarY)
            frame.size = CGSize(width: frame.size.width, height: navigationController!.view.frame.size.height - (navBarY) - tabBarOffset)
            topViewController.view.frame = frame
        }
    }
    
    private func restoreContentOffset(_ delta: CGFloat) {
        guard let scrollableView = scrollView,
            let navigationBar = navigationController?.navigationBar else { return }
        
        print("scrollView.contentOffset:\(scrollableView.contentOffset.y), delta:\(delta)")
        
        if delta == 0 {
            return
        }
        
        if navigationBar.isTranslucent {
            
            if state == .collapsed && scrollableView.contentOffset.y < -statusBarHeight {
                scrollableView.contentOffset.y = -statusBarHeight
            }
        } else {
            
            // Hold the scroll steady until the navbar appears/disappears
            scrollableView.setContentOffset(CGPoint(x: scrollableView.contentOffset.x, y: scrollableView.contentOffset.y - delta), animated: false)
        }
    }
    
    private func checkForPartialScroll() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        
        let frame = navigationBar.frame
        var duration = TimeInterval(0)
        var delta = CGFloat(0.0)
        
        // Scroll back down
        let threshold = statusBarHeight - (frame.size.height / 2)
        if navigationBar.frame.origin.y >= threshold {
            delta = frame.origin.y - statusBarHeight
            state = .expanded
        } else {
            // Scroll up
            delta = frame.origin.y + deltaLimit
            state = .collapsed
        }
        
        let distance = delta / (frame.size.height / 2)
        duration = TimeInterval(abs(distance * 0.2))
        
        delayDistance = maxDelay
        print("partial scroll detla:\(delta)")
        
        UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
            self.updateSizing(delta)
            self.restoreContentOffset(delta)
            //            self.updateFollowers(delta)
            self.updateNavbarAlpha()
        }, completion: nil)
    }
    
    private func updateNavbarAlpha() {
        guard let navigationItem = navigationController?.visibleViewController?.navigationItem,
            let navigationBar = navigationController?.navigationBar else { return }
        
        let frame = navigationBar.frame
        
        // Change the alpha channel of every item on the navbr
        let alpha = (frame.origin.y + deltaLimit) / frame.size.height
        
        // Hide all the possible titles
        navigationItem.titleView?.alpha = alpha
        navigationBar.tintColor = navigationBar.tintColor.withAlphaComponent(alpha)
        if let titleColor = navigationBar.titleTextAttributes?[NSForegroundColorAttributeName] as? UIColor {
            navigationBar.titleTextAttributes?[NSForegroundColorAttributeName] = titleColor.withAlphaComponent(alpha)
        } else {
            navigationBar.titleTextAttributes?[NSForegroundColorAttributeName] = UIColor.black.withAlphaComponent(alpha)
        }
        
        // Hide all possible button items and navigation items
        func shouldHideView(_ view: UIView) -> Bool {
            let className = view.classForCoder.description()
            return className == "UINavigationButton" ||
                className == "UINavigationItemView" ||
                className == "UIImageView" ||
                className == "UISegmentedControl"
        }
        navigationBar.subviews
            .filter(shouldHideView)
            .forEach { $0.alpha = alpha }
        
        // Hide the left items
        navigationItem.leftBarButtonItem?.customView?.alpha = alpha
        if let leftItems = navigationItem.leftBarButtonItems {
            leftItems.forEach { $0.customView?.alpha = alpha }
        }
        
        // Hide the right items
        navigationItem.rightBarButtonItem?.customView?.alpha = alpha
        if let rightItems = navigationItem.rightBarButtonItems {
            rightItems.forEach { $0.customView?.alpha = alpha }
        }
    }
    
    // MARK: - Size
    
    var fullNavbarHeight: CGFloat {
        return navbarHeight + statusBarHeight
    }
    
    var deltaLimit: CGFloat {
        return navbarHeight - statusBarHeight
    }
    
    var navbarHeight: CGFloat {
        return navigationController?.navigationBar.frame.size.height ?? 0
    }
    
    var statusBarHeight: CGFloat {
        return CGFloat.minimum(20, UIApplication.shared.statusBarFrame.size.height)
    }
    
    var tabBarOffset: CGFloat {
        // Only account for the tab bar if a tab bar controller is present and the bar is not translucent
        if let tabBarController = navigationController?.tabBarController {
            return tabBarController.tabBar.isTranslucent ? 0 : tabBarController.tabBar.frame.height
        }
        return 0
    }
    
    var isBouncingTop: Bool {
        guard let scrollableView = scrollView else { return false }
        return scrollableView.contentOffset.y + scrollableView.contentInset.top < 0
    }
    
    deinit {
        print("\(self.classForCoder) \(#function)")
    }
}

