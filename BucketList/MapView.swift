//
//  MapView.swift
//  BucketList
//
//  Created by Bruce Gilmour on 2021-07-29.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        //
    }

}
