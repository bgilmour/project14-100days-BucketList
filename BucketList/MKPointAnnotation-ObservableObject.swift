//
//  MKPointAnnotation-ObservableObject.swift
//  BucketList
//
//  Created by Bruce Gilmour on 2021-07-29.
//

import MapKit

extension MKPointAnnotation: ObservableObject {
    public var wrappedTitle: String {
        get {
            title ?? "Title"
        }
        set {
            title = newValue
        }
    }

    public var wrappedSubtitle: String {
        get {
            subtitle ?? "Subtitle"
        }
        set {
            subtitle = newValue
        }
    }
}
