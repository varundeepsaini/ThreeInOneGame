//
//  MatchingGameView.swift
//  FourInOneGameApp
//
//  Created by Varun Deep Saini on 25/08/24.
//

import SwiftUI

struct Card: Identifiable {
    var id: UUID = UUID()
    var image: String
    var isFaceUp: Bool = false
    var isMatched: Bool = false
}

struct MatchingGameView: View {
    @EnvironmentObject var settings: AppSettings

    @State private var cards: [Card]
    @State private var firstCardIndex: Int? = nil
    @State private var isAnimating: Bool = false
    @State private var isCheckingMatch: Bool = false
    @State private var showWinMessage: Bool = false

    let gridItemLayout = Array(repeating: GridItem(.flexible()), count: 4)

    let images = ["gamecontroller.fill", "heart.fill", "star.fill", "moon.fill", "bolt.fill", "hare.fill", "tortoise.fill", "ant.fill"]

    init() {
        var newCards: [Card] = []
        for image in images {
            newCards.append(Card(image: image))
            newCards.append(Card(image: image))
        }
        _cards = State(initialValue: newCards) 
        // Shuffle is turned off for testing
    }

    var body: some View {
        ZStack {
            (settings.isDarkMode ? LinearGradient(gradient: Gradient(colors: [Color.indigo, Color.black]), startPoint: .top, endPoint: .bottom)
                        : LinearGradient(gradient: Gradient(colors: [Color.indigo, Color.pink]), startPoint: .top, endPoint: .bottom))
                .ignoresSafeArea()

            VStack {
                HStack {
                    BackButton()
                        .padding(.top , 20)
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

                Text("Matching Game")
                    .font(.custom("Chalkduster", size: 40))
                    .foregroundColor(settings.isDarkMode ? .white : .black)
                    .padding()

                LazyVGrid(columns: gridItemLayout, spacing: 15) {
                    ForEach(cards.indices) { index in
                        CardView(card: cards[index])
                            .frame(width: 70, height: 100)
                            .onTapGesture {
                                if !isCheckingMatch && !cards[index].isFaceUp && !cards[index].isMatched {
                                    withAnimation {
                                        flipCard(at: index)
                                    }
                                }
                            }
                    }
                }
                .padding()

                Spacer()
            }

            if showWinMessage {
                VStack {
                    Text("Congratulations! You Won!")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()

                    Button(action: resetGame) {
                        Text("Play Again")
                            .font(.headline)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                }
                .frame(width: 300, height: 200)
                .background(Color.black.opacity(0.75))
                .cornerRadius(20)
                .shadow(radius: 20)
                .transition(.scale)
                .animation(.easeInOut, value: showWinMessage)
            }
        }
        .navigationBarHidden(true)
        .preferredColorScheme(settings.isDarkMode ? .dark : .light)
    }

    private func flipCard(at index: Int) {
        guard !cards[index].isMatched else { return }

        cards[index].isFaceUp.toggle()

        if let firstIndex = firstCardIndex {
            isCheckingMatch = true
            checkForMatch(between: firstIndex, and: index)
        } else {
            firstCardIndex = index
        }
    }

    private func checkForMatch(between firstIndex: Int, and secondIndex: Int) {
        if cards[firstIndex].image == cards[secondIndex].image {
            cards[firstIndex].isMatched = true
            cards[secondIndex].isMatched = true
            firstCardIndex = nil
            isCheckingMatch = false
            checkIfGameIsWon()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                cards[firstIndex].isFaceUp = false
                cards[secondIndex].isFaceUp = false
                firstCardIndex = nil
                isCheckingMatch = false
            }
        }
    }

    private func checkIfGameIsWon() {
        if cards.allSatisfy({ $0.isMatched }) {
            withAnimation {
                showWinMessage = true
            }
        }
    }

    private func resetGame() {
        for index in cards.indices {
            cards[index].isFaceUp = false
            cards[index].isMatched = false
        }
        firstCardIndex = nil
        showWinMessage = false
    }
}

struct CardView: View {
    var card: Card

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.4))
                .frame(width: 70, height: 100)
                .shadow(color: card.isMatched ? Color.green.opacity(1.0) : Color.black.opacity(0.2), radius: card.isMatched ? 12 : 5, x: 0, y: card.isMatched ? 0 : 5)

            if card.isFaceUp || card.isMatched {
                Image(systemName: card.image)
                    .resizable()
                    .scaledToFit()
                    .padding(10)
                    .aspectRatio(contentMode: .fit)
            } else {
                Image(systemName: "sparkles")
                    .symbolRenderingMode(.multicolor)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundStyle(.secondary, .tertiary)
            }
        }
        .rotation3DEffect(
            .degrees(card.isFaceUp ? 0 : 180),
            axis: (x: 0.0, y: 1.0, z: 0.0)
        )
        .animation(.default, value: card.isFaceUp)
        .scaleEffect(card.isMatched ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: card.isMatched)
    }
}

struct MatchingGameView_Previews: PreviewProvider {
    static var previews: some View {
        MatchingGameView().environmentObject(AppSettings())
    }
}
