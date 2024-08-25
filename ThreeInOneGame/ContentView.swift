//
//  ContentView.swift
//  FourInOneGameApp
//
//  Created by Varun Deep Saini on 25/08/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MainMenuView()
            .environmentObject(AppSettings())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppSettings())
    }
}
