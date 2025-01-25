//
//  ViewLifecycleAware.swift
//  RecipesForDisaster
//
//  Created by Brandon Erbschloe on 8/26/24.
//

import Foundation
import SwiftUI

protocol LifecycleAware: AnyObject {
    func onAppear()
    func onDisappear()
}

extension LifecycleAware {
    func onAppear() { }
    func onDisappear() { }
}

extension View {
    func lifecycleAware<V: LifecycleAware>(_ component: V) -> some View {
        onAppear {
            component.onAppear()
        }
        .onDisappear {
            component.onDisappear()
        }
    }
}
