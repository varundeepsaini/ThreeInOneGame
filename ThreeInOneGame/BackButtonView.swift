//
//  BackButtonView.swift
//  FourInOneGameApp
//
//  Created by Varun Deep Saini on 26/08/24.
//

import Foundation
import SwiftUI

struct BackButton: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .font(.system(size: 20))
                .foregroundColor(settings.isDarkMode ? .white : .black) 
                .padding()
        }
        .background(Color.clear)
        .cornerRadius(8)
    }
}
