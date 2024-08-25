//
//  Game2048View.swift
//  FourInOneGameApp
//
//  Created by Varun Deep Saini on 26/08/24.
//

import SwiftUI

struct Game2048View: View {
    @EnvironmentObject var settings: AppSettings
    @State private var board: [[Int]] = Array(repeating: Array(repeating: 0, count: 4), count: 4)
    @State private var score: Int = 0
    @State private var isGameOver: Bool = false

    let gridSize = 4
    let boardSize: CGFloat = 320
    let cellSize: CGFloat = 70
    let spacing: CGFloat = 8

    var body: some View {
        ZStack {
            (settings.isDarkMode ? LinearGradient(gradient: Gradient(colors: [Color.indigo, Color.black]), startPoint: .top, endPoint: .bottom)
                        : LinearGradient(gradient: Gradient(colors: [Color.indigo, Color.pink]), startPoint: .top, endPoint: .bottom))
                .ignoresSafeArea()

            VStack {
                HStack {
                    BackButton()
                        .padding(.top,20)
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

                Text("2048 Game")
                    .font(.custom("Chalkduster", size: 40))
                    .foregroundColor(settings.isDarkMode ? .white : .black)
                    .padding()

                Text("Score: \(score)")
                    .font(.headline)
                    .foregroundColor(settings.isDarkMode ? .white : .black)
                    .padding(.bottom, 20)

                gameBoard
                    .frame(width: boardSize, height: boardSize)
                    .padding()

                Spacer()
            }

            if isGameOver {
                GameOverView(score: score, onRestart: resetGame)
            }
            
        }
        .navigationBarHidden(true)
        .preferredColorScheme(settings.isDarkMode ? .dark : .light)
        .onAppear(perform: startGame)
    }

    private var gameBoard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.3))
                .frame(width: boardSize, height: boardSize)

            VStack(spacing: spacing) {
                ForEach(0..<gridSize, id: \.self) { row in
                    HStack(spacing: spacing) {
                        ForEach(0..<gridSize, id: \.self) { col in
                            if board[row][col] != 0 {
                                TileView(value: board[row][col])
                                    .frame(width: cellSize, height: cellSize)
                                    .transition(.scale)
                                    .animation(.easeInOut(duration: 0.2))
                            } else {
                                Color.clear
                                    .frame(width: cellSize, height: cellSize)
                            }
                        }
                    }
                }
            }
        }
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    handleSwipe(gesture: gesture)
                }
        )
    }

    private func startGame() {
        board = Array(repeating: Array(repeating: 0, count: 4), count: 4)
        score = 0
        isGameOver = false
        addNewTile()
        addNewTile()
    }

    private func addNewTile() {
        var emptyCells = [(Int, Int)]()
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                if board[row][col] == 0 {
                    emptyCells.append((row, col))
                }
            }
        }
        
        guard let (row, col) = emptyCells.randomElement() else { return }
        board[row][col] = Bool.random() ? 2 : 4
        withAnimation(.easeInOut(duration: 0.3)) {
        }
    }

    private func handleSwipe(gesture: DragGesture.Value) {
        let horizontal = abs(gesture.translation.width) > abs(gesture.translation.height)
        let positive = horizontal ? gesture.translation.width > 0 : gesture.translation.height > 0

        var didMove = false

        if horizontal {
            if positive {
                didMove = moveRight()
            } else {
                didMove = moveLeft()
            }
        } else {
            if positive {
                didMove = moveDown()
            } else {
                didMove = moveUp()
            }
        }

        if didMove {
            addNewTile()
            checkGameOver()
        }
    }

    private func moveLeft() -> Bool {
        var didMove = false
        var newBoard = board
        for row in 0..<gridSize {
            var line = newBoard[row].filter { $0 != 0 }
            var index = 0
            while index < line.count - 1 {
                if line[index] == line[index + 1] {
                    line[index] *= 2
                    score += line[index]
                    line.remove(at: index + 1)
                    didMove = true
                }
                index += 1
            }
            while line.count < gridSize {
                line.append(0)
            }
            if line != newBoard[row] {
                didMove = true
            }
            newBoard[row] = line
        }
        if didMove {
            withAnimation(.easeInOut(duration: 0.2)) {
                board = newBoard
            }
        }
        return didMove
    }

    private func moveRight() -> Bool {
        board = board.map { $0.reversed() }
        let didMove = moveLeft()
        board = board.map { $0.reversed() }
        return didMove
    }

    private func moveUp() -> Bool {
        board = rotateLeft(board)
        let didMove = moveLeft()
        board = rotateRight(board)
        return didMove
    }

    private func moveDown() -> Bool {
        board = rotateRight(board)
        let didMove = moveLeft()
        board = rotateLeft(board)
        return didMove
    }

    private func rotateLeft(_ matrix: [[Int]]) -> [[Int]] {
        let n = matrix.count
        var result = matrix
        for i in 0..<n {
            for j in 0..<n {
                result[n - 1 - j][i] = matrix[i][j]
            }
        }
        return result
    }

    private func rotateRight(_ matrix: [[Int]]) -> [[Int]] {
        let n = matrix.count
        var result = matrix
        for i in 0..<n {
            for j in 0..<n {
                result[j][n - 1 - i] = matrix[i][j]
            }
        }
        return result
    }

    private func checkGameOver() {
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                if board[row][col] == 0 {
                    return
                }
                if col < gridSize - 1 && board[row][col] == board[row][col + 1] {
                    return
                }
                if row < gridSize - 1 && board[row][col] == board[row + 1][col] {
                    return
                }
            }
        }
        isGameOver = true
    }

    private func resetGame() {
        startGame()
    }
}

struct TileView: View {
    let value: Int

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(tileColor(for: value))
            Text("\(value)")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
        }
    }

    private func tileColor(for value: Int) -> Color {
        switch value {
        case 2: return .orange
        case 4: return .yellow
        case 8: return .green
        case 16: return .blue
        case 32: return .purple
        case 64: return .red
        case 128, 256, 512: return .pink
        case 1024, 2048: return .black
        default: return .gray
        }
    }
}

struct GameOverView: View {
    let score: Int
    let onRestart: () -> Void

    var body: some View {
        VStack {
            Text("Game Over")
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding()
            Text("Score: \(score)")
                .font(.title)
                .foregroundColor(.white)
                .padding()
            Button(action: onRestart) {
                Text("Play Again")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .frame(width: 300, height: 200)
        .background(Color.black.opacity(0.75))
        .cornerRadius(20)
    }
}

struct Game2048View_Previews: PreviewProvider {
    static var previews: some View {
        Game2048View().environmentObject(AppSettings())
    }
}
