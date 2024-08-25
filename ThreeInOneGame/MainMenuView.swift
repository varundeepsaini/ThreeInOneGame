//
//  MainMenuView.swift
//  FourInOneGameApp
//
//  Created by Varun Deep Saini on 26/08/24.
//

import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var settings: AppSettings
    var body: some View {
        NavigationView {
            ZStack {
                (settings.isDarkMode ? LinearGradient(gradient: Gradient(colors: [Color.indigo, Color.black]), startPoint: .top, endPoint: .bottom)
                            : LinearGradient(gradient: Gradient(colors: [Color.indigo, Color.pink]), startPoint: .top, endPoint: .bottom))
                    .ignoresSafeArea()

                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                settings.isDarkMode.toggle()
                            }
                        }) {
                            Image(systemName: settings.isDarkMode ? "sun.max.fill" : "moon.fill")
                                .font(.system(size: 24))
                                .foregroundColor(settings.isDarkMode ? .white : .black)
                                .rotationEffect(.degrees(settings.isDarkMode ? 0 : 270))
                                .scaleEffect(settings.isDarkMode ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 0.5))
                        }
                        .padding(.top, 20)
                        .padding(.trailing, 20)
                    }

                    Spacer()

                    Text("3-in-1 Game Hub")
                        .font(.custom("Chalkduster", size: 40))
                        .foregroundColor(settings.isDarkMode ? .white : .black)
                        .padding(.bottom, 40)

                    VStack(spacing: 20) {
                        NavigationLink(destination: TicTacToeView().environmentObject(settings)) {
                            GameButtonView(gameTitle: "Tic-Tac-Toe", systemImage: "xmark.square")
                        }

                        NavigationLink(destination: MatchingGameView().environmentObject(settings)) {
                            GameButtonView(gameTitle: "Matching Game", systemImage: "suit.heart.fill")
                        }

                        NavigationLink(destination: Game2048View().environmentObject(settings)) {
                            GameButtonView(gameTitle: "2048", systemImage: "number.square")
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .preferredColorScheme(settings.isDarkMode ? .dark : .light)
        }
    }
}

struct GameButtonView: View {
    let gameTitle: String
    let systemImage: String

    var body: some View {
        VStack {
            Image(systemName: systemImage)
                .font(.system(size: 50))
                .padding()
                .background(Circle().fill(Color.white.opacity(0.2)))
                .foregroundColor(.white)

            Text(gameTitle)
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 15).fill(Color.white.opacity(0.1)))
        .shadow(radius: 5)
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView().environmentObject(AppSettings())
    }
}
