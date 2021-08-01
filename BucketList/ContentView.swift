//
//  ContentView.swift
//  BucketList
//
//  Created by Bruce Gilmour on 2021-07-28.
//

import LocalAuthentication
import MapKit
import SwiftUI

struct ContentView: View {
    @State private var centerCoordinate = CLLocationCoordinate2D()
    @State private var locations = [CodableMKPointAnnotation]()
    @State private var selectedPlace: MKPointAnnotation?

    @State private var showingPlaceDetails = false
    @State private var showingEditScreen = false

    @State private var isUnlocked = false
    @State private var showingAuthError = false
    @State private var errorMessage = ""

    var body: some View {
        ZStack {
            if isUnlocked {
                MapView(
                    centerCoordinate: $centerCoordinate,
                    selectedPlace: $selectedPlace,
                    showingPlaceDetails: $showingPlaceDetails,
                    annotations: locations
                )
                .edgesIgnoringSafeArea(.all)

                Circle()
                    .fill(Color.blue)
                    .opacity(0.3)
                    .frame(width: 32, height: 32)

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            let newLocation = CodableMKPointAnnotation()
                            newLocation.coordinate = centerCoordinate
                            locations.append(newLocation)
                            selectedPlace = newLocation
                            showingEditScreen = true
                        }) {
                            Image(systemName: "plus")
                        }
                        .padding(8)
                        .background(Color.black.opacity(0.75))
                        .foregroundColor(.white)
                        .font(.title)
                        .clipShape(Circle())
                        .padding(.trailing)
                    }
                }
            } else {
                Button("Unlock Places") {
                    authenticate()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
                .alert(isPresented: $showingAuthError) {
                    Alert(
                        title: Text("Authentication Error"),
                        message: Text(errorMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
        .alert(isPresented: $showingPlaceDetails) {
            Alert(
                title: Text(selectedPlace?.title ?? "Unknown"),
                message: Text(selectedPlace?.subtitle ?? "Missing place information."),
                primaryButton: .default(Text("OK")),
                secondaryButton: .default(Text("Edit")) {
                    showingEditScreen = true
                }
            )
        }
        .sheet(isPresented: $showingEditScreen, onDismiss: saveData) {
            if selectedPlace != nil {
                EditView(placemark: selectedPlace!)
            }
        }
        .onAppear(perform: loadData)
    }

    func authenticate() {
        let context = LAContext()
        var error: NSError?

        print("authenticate")

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "We need to unlock your data."
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        isUnlocked = true
                    } else {
                        showingAuthError = true
                        errorMessage = authenticationError?.localizedDescription ?? "No error info"
                    }
                }
            }
        } else {
            // no biometrics
        }
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    func loadData() {
        print("loadData")
        let filename = getDocumentsDirectory().appendingPathComponent("SavedPlaces")
        print("url=\(filename.absoluteString)")

        do {
            let data = try Data(contentsOf: filename)
            locations = try JSONDecoder().decode([CodableMKPointAnnotation].self, from: data)
        } catch {
            print("Unable to load saved data: \(error.localizedDescription)")
        }
    }

    func saveData() {
        do {
            print("saveData")
            let filename = getDocumentsDirectory().appendingPathComponent("SavedPlaces")
            print("url=\(filename.absoluteString)")
            let data = try JSONEncoder().encode(locations)
            //try data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
            try data.write(to: filename, options: [.atomicWrite])
        } catch {
            print("Unable to save data: \(error.localizedDescription)")
        }
    }

}

struct BiometricsTestView: View {
    @State private var isUnlocked = false

    var body: some View {
        VStack {
            if isUnlocked {
                Text("Unlocked")
            } else {
                Text("Locked")
            }
        }
        .onAppear(perform: authenticate)
    }

    func authenticate() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "We need to unlock your data."
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        isUnlocked = true
                    } else {

                    }
                }
            }
        } else {
            // no biometrics
        }
    }
}

struct LoadingStateEnumTestView: View {
    var loadingState = LoadingState.loading

    var body: some View {
        Group {
            if loadingState == .loading {
                LoadingView()
            } else if loadingState == .success {
                SuccessView()
            } else if loadingState == .failed {
                FailedView()
            }
        }
    }
}

enum LoadingState {
    case loading, success, failed
}

struct LoadingView: View {
    var body: some View {
        Text("Loading...")
    }
}

struct SuccessView: View {
    var body: some View {
        Text("Success!")
    }
}

struct FailedView: View {
    var body: some View {
        Text("Failed.")
    }
}
struct DocumentsTestView: View {

    var body: some View {
        Text("DocumentsTestView")
            .onTapGesture {
                let str = "Test message"
                let url = getDocumentsDirectory().appendingPathComponent("message.txt")

                do {
                    try str.write(to: url, atomically: true, encoding: .utf8)
                    let input = try String(contentsOf: url)
                    print(input)
                } catch {
                    print(error.localizedDescription)
                }
            }
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

}

struct User: Identifiable, Comparable {
    let id = UUID()
    let firstName: String
    let lastName: String

    static func < (lhs: User, rhs: User) -> Bool {
        lhs.firstName < rhs.firstName
    }
}

struct ComparableUserTestView: View {
    let users = [
        User(firstName: "Arnold", lastName: "Rimmer"),
        User(firstName: "Kristine", lastName: "Kochanski"),
        User(firstName: "David", lastName: "Lister")
    ]
    .sorted()

    var body: some View {
        List(users) { user in
            Text("\(user.firstName) \(user.lastName)")
        }
    }
}

struct SortedClosureUserTestView: View {
    let users = [
        User(firstName: "Arnold", lastName: "Rimmer"),
        User(firstName: "Kristine", lastName: "Kochanski"),
        User(firstName: "David", lastName: "Lister")
    ]
    .sorted {
        $0.lastName < $1.lastName
    }

    var body: some View {
        List(users) { user in
            Text("\(user.firstName) \(user.lastName)")
        }
    }
}

struct SortedIntTestView: View {
    let values = [1, 5, 3, 6, 2, 9].sorted()

    var body: some View {
        List(values, id: \.self) {
            Text(String($0))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
