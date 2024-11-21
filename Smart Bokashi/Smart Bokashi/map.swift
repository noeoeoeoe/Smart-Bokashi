import Foundation
import SwiftUI
import MapKit
import Combine

// Model
struct Bokashi: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String
    let avancement: Double
    let logoName: String
    let couleur: Color
    
    init(coordinate: CLLocationCoordinate2D, title: String, avancement: Double, logoName: String) {
        self.coordinate = coordinate
        self.title = title
        self.avancement = avancement
        self.logoName = logoName
        self.couleur = avancement == 1 ? .red : .green
    }
}

// ViewModel
class BokashiManager: ObservableObject {
    @Published var bokashis: [Bokashi] = []
    
    init() {
        fetchBokashis()
    }
    
    func fetchBokashis() {
        // Simulate network request with delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.bokashis = [
                Bokashi(coordinate: CLLocationCoordinate2D(latitude: 48.70849918234135, longitude: 2.1612690567438633), title: "Coloc WEI", avancement: 0.7, logoName: "leaf"),
                Bokashi(coordinate: CLLocationCoordinate2D(latitude: 48.710263, longitude: 2.167568), title: "RU Eiffel", avancement: 1, logoName: "house"),
                Bokashi(coordinate: CLLocationCoordinate2D(latitude: 48.710220, longitude: 2.162513), title: "Pierre Thébault", avancement: 1, logoName: "person.circle")
            ]
        }
    }
}

// Views
struct MapView: View {
    @StateObject private var manager = BokashiManager()
    @State private var selectedAnnotation: Bokashi? = nil
    @State private var selectedBokashi: Bokashi? = nil
    @State private var showingBokashiList = false
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 48.70849918234135, longitude: 2.1612690567438633),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )

    var body: some View {
        NavigationView {
            VStack {
                Map(coordinateRegion: $region,
                    annotationItems: manager.bokashis,
                    annotationContent: { item in
                        MapAnnotation(coordinate: item.coordinate) {
                            VStack {
                                Image(systemName: item.logoName)
                                    .foregroundColor(item.couleur)
                                    .onTapGesture {
                                        self.selectedAnnotation = item
                                    }
                                Text(item.title)
                                    .font(.caption)
                            }
                            .sheet(item: $selectedAnnotation) { bokashi in
                                VStack {
                                    Text("Taux d'avancement de \(bokashi.title) :")
                                    BarView(progress: bokashi.avancement)
                                }
                            }
                        }
                    })
            }
            .navigationBarTitle("Carte Bokashi")
            .navigationBarItems(trailing: Button(action: {
                self.showingBokashiList = true
            }) {
                Text("Liste des Bokashis")
            })
            .sheet(isPresented: $showingBokashiList) {
                VStack {
                    Text("Sélectionner un Bokashi")
                        .font(.headline)
                        .padding()
                    List(manager.bokashis) { bokashi in
                        Button(action: {
                            self.selectedBokashi = bokashi
                            self.region.center = bokashi.coordinate
                            self.showingBokashiList = false
                        }) {
                            HStack {
                                Image(systemName: bokashi.logoName)
                                    .foregroundColor(bokashi.couleur)
                                Text(bokashi.title)
                                    .foregroundColor(bokashi.couleur)
                            }
                            BarView(progress: bokashi.avancement)
                                .padding(.leading)
                        }
                    }
                }
            }
        }
    }
}

struct BarView: View {
    let progress: Double

    var body: some View {
        VStack {
            // Filling bar
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: 200, height: 20) // Bar dimensions
                    .foregroundColor(Color.gray.opacity(0.3)) // Background color
                
                Rectangle()
                    .frame(width: 200 * CGFloat(progress), height: 20) // Filling width based on progress
                    .foregroundColor(progress == 1 ? .red : .green) // Filling color
            }
            .cornerRadius(10) // Rounded corners for the bar
            
            // Progress label
            Text("\(Int(progress * 100))%")
                .padding(.top, 8)
        }
        .padding()
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
