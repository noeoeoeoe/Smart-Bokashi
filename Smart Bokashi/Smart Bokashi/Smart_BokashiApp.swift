//
//  Smart_BokashiApp.swift
//  Smart Bokashi
//
//  Created by Noé Madranges on 23/05/2024.
//

/*import SwiftUI

@main
struct MultiTabApp: App {
    var body: some Scene {
        WindowGroup {
            menu()
        }
    }
}

struct menu: View {
    var bluetoothManager = BluetoothManager()
    var body: some View {
        TabView {
            // Tab 1
            Text("oe")
                .tabItem {
                    Label("Tab 1", systemImage: "star")
                }
                .tag(0)
            
            // Tab 2
            MapView()
                .tabItem {
                    Label("Tab 2", systemImage: "heart")
                }
                .tag(1)
            
            // Tab 3
            
            VStack {
                if bluetoothManager.temperature != "N/A" {
                    Text("Température: \(bluetoothManager.temperature)")
                        .padding()
                } else {
                    ProgressView() // Ajout d'une vue de progression pendant la récupération de la température
                        .padding()
                }
            }
            .tabItem {
                Label("Tab 3", systemImage: "square.and.pencil")
            }
            .tag(2)
        }
    }
}

struct menu_Previews: PreviewProvider {
    static var previews: some View {
        menu()
    }
}*/
