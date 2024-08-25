//
//  TicTacToeView.swift
//  FourInOneGameApp
//
//  Created by Varun Deep Saini on 26/08/24.
//

import SwiftUI

struct TicTacToeView: View {
    @EnvironmentObject var settings: AppSettings

    @State private var board = Array(repeating: "", count: 9)
    @State private var currentPlayer = "X"
    @State private var gameOver = false
    @State private var winner: String?
    @State private var winningCells: [Int] = []
    @State private var animateWinningCells = false

    let gridItemLayout = Array(repeating: GridItem(.flexible()), count: 3)
    
    let cellGradient = LinearGradient(
        gradient: Gradient(colors: [Color.purple, Color.pink]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    let lightBackgroundGradient = LinearGradient(
        gradient: Gradient(colors: [Color.indigo, Color.lightPink]),
        startPoint: .top,
        endPoint: .bottom
    )

    let darkBackgroundGradient = LinearGradient(
        gradient: Gradient(colors: [Color.indigo, Color.black]),
        startPoint: .top,
        endPoint: .bottom
    )

    var body: some View {
        ZStack(alignment: .topTrailing) {
            
            (settings.isDarkMode ? darkBackgroundGradient : lightBackgroundGradient)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Text("Tic-Tac-Toe")
                    .font(.custom("Chalkduster", size: 54))
                    .foregroundColor(settings.isDarkMode ? .white : .black)
                    .shadow(color: settings.isDarkMode ? .black.opacity(0.7) : .gray.opacity(0.3), radius: 4, x: 0, y: 3)
                    .padding(.top, 70)
                
                Text("Current Player: \(currentPlayer)")
                    .font(.custom("Chalkduster", size: 24))
                    .foregroundColor(settings.isDarkMode ? .white : .black)
                    .shadow(color: settings.isDarkMode ? .black.opacity(0.7) : .gray.opacity(0.3), radius: 2, x: 0, y: 2)
                    .padding(.bottom, 20)
                Spacer()
                
                LazyVGrid(columns: gridItemLayout, spacing: 15) {
                    ForEach(0..<9) { index in
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(cellGradient)
                                .frame(width: 100, height: 100)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.black, lineWidth: 3)
                                )
                                .scaleEffect(winningCells.contains(index) && animateWinningCells ? 1.1 : 1.0)
                                .rotationEffect(winningCells.contains(index) && animateWinningCells ? .degrees(360) : .degrees(0))

                            Text(board[index])
                                .font(.system(size: 60, weight: .bold))
                                .foregroundColor(.black)
                                .scaleEffect(winningCells.contains(index) && animateWinningCells ? 1.2 : 1.0)
                                .rotationEffect(winningCells.contains(index) && animateWinningCells ? .degrees(-360) : .degrees(0))
                        }
                        .onTapGesture {
                            if board[index] == "" && !gameOver {
                                board[index] = currentPlayer
                                withAnimation(.easeIn) {
                                    checkForWinner()
                                }
                                currentPlayer = currentPlayer == "X" ? "O" : "X"
                            }
                        }
                    }
                }
                
                if gameOver {
                    VStack {
                        Text(winner != nil ? "\(winner!) wins!" : "It's a Draw!")
                            .font(.custom("Chalkduster", size: 28))
                            .foregroundColor(.black)
                            .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 3)
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
                        .padding(.top, 20)
                    }
                    .transition(.opacity)
                }
                
                Spacer()
            }
            .padding()
            HStack {
                BackButton()
                    .padding(.top, 20)
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
        }
        .navigationBarHidden(true)
        .preferredColorScheme(settings.isDarkMode ? .dark : .light)
    }

    private func checkForWinner() {
        let winPatterns: [[Int]] = [
            [0, 1, 2], [3, 4, 5], [6, 7, 8],
            [0, 3, 6], [1, 4, 7], [2, 5, 8],
            [0, 4, 8], [2, 4, 6]
        ]
        
        for pattern in winPatterns {
            if board[pattern[0]] == currentPlayer &&
                board[pattern[1]] == currentPlayer &&
                board[pattern[2]] == currentPlayer {
                winner = currentPlayer
                gameOver = true
                winningCells = pattern
                startAnimation()
                return
            }
        }
        
        if !board.contains("") {
            gameOver = true
        }
    }

    private func startAnimation() {
        animateWinningCells = true
        withAnimation(Animation.easeInOut(duration: 0.5).repeatCount(2, autoreverses: true)) {
            animateWinningCells.toggle()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            animateWinningCells = false
        }
    }

    private func resetGame() {
        board = Array(repeating: "", count: 9)
        currentPlayer = "X"
        gameOver = false
        winner = nil
        winningCells.removeAll()
        animateWinningCells = false
    }
}

struct TicTacToeView_Previews: PreviewProvider {
    static var previews: some View {
        TicTacToeView().environmentObject(AppSettings())
    }
}
