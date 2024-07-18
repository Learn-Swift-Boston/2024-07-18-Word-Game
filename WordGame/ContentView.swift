//
//  ContentView.swift
//  WordGame
//
//  Created by Zev Eisenberg on 7/18/24.
//

import SwiftUI

struct Letter {
  var value: Character?
  var validation: Validation = .unknown

  var displayString: String {
    return value.map(String.init) ?? ""
  }

}

enum Validation {
  case unknown
  case notPresent // dark gray
  case wrongPlace // yellow
  case correct // green

  var backgroundColor: Color {
    switch self {
    case .unknown:
        .init(white: 0.5)
    case .notPresent:
        .init(white: 0.2)
    case .wrongPlace:
        .yellow
    case .correct:
        .green
    }
  }
}

struct KeyboardKey: Hashable {
  var key: Key
  var validation: Validation = .unknown

  @ViewBuilder
  func visibleContent(onTap: @escaping () -> Void) -> some View {
    Button(action: onTap) {
      Group {
        switch key {
        case .letter(let character):
          Text(String(character))
        case .enter:
          Text("Enter")
            .textCase(.uppercase)
        case .delete:
          Image(systemName: "delete.left")
        }
      }
      .font(.system(size: 22, weight: .bold))
      .padding(4)
      .foregroundColor(.white)
      .background(validation.backgroundColor)
      .clipShape(.rect(cornerRadius: 3))
    }
  }

}

enum Key: Hashable {
  case letter(Character)
  case enter
  case delete
}

struct Game {
  var targetWord: String

  var currentRow: Int = 0
  var currentColumn: Int = 0

  var rows: [[Letter]] = Array(
    repeating: Array(
      repeating: Letter(),
      count: 5
    ),
    count: 6
  )

  var keyboard: [[KeyboardKey]] = [
    "QWERTYUIOP".map { KeyboardKey(key: .letter($0)) },
    "ASDFGHJKL".map{ KeyboardKey(key: .letter($0)) },
    [KeyboardKey(key: .enter)]
    + "ZXCVBNM".map { KeyboardKey(key: .letter($0)) }
    + [KeyboardKey(key: .delete)],
  ]

  mutating func keyPressed(_ key: Key) {
    if currentColumn == 5, rows[currentRow][currentColumn].value != nil {
      // we are at the end of a row. Check row and move on to next row or go into win/lose state
    } else {
      // we are not at the end of a row. Add a guess.
      if case .letter(let letter) = key {
        rows[currentRow][currentColumn].value = letter
      }
    }
  }
}

struct ContentView: View {

  @State var game: Game

  var body: some View {
    VStack {
      board
      keyboard
    }
  }

  @ViewBuilder private var board: some View {
    VStack {
      ForEach(Array(game.rows.enumerated()), id: \.offset) { rowIndex, row in
        HStack { // row
          ForEach(Array(row.enumerated()), id: \.offset) { letterIndex, letter in
            Text(letter.displayString)
              .padding()
              .fixedSize()
              .frame(width: 60, height: 60)
              .background(letter.validation.backgroundColor)
              .foregroundStyle(.white)
              .fontWeight(.bold)
              .font(.system(size: 40))
          }
        }
      }
    }
  }

  @ViewBuilder private var keyboard: some View {
    VStack {
      ForEach(game.keyboard, id: \.self) { row in
        HStack {
          ForEach(row, id: \.self) { keyboardKey in
            keyboardKey.visibleContent(onTap: {
              game.keyPressed(keyboardKey.key)
            })
          }
        }
      }
    }
  }
}

#Preview("New Game") {
  var game = Game(targetWord: "NERDY")

  return ContentView(
    game: game
  )
}

#Preview("Visible Words") {
  var game = Game(targetWord: "NERDY")

  game.rows[0][0].value = "E"
  game.rows[0][0].validation = .wrongPlace
  game.rows[0][1].value = "I"
  game.rows[0][1].validation = .notPresent
  game.rows[0][2].value = "G"
  game.rows[0][2].validation = .notPresent
  game.rows[0][3].value = "H"
  game.rows[0][3].validation = .notPresent
  game.rows[0][4].value = "T"
  game.rows[0][4].validation = .correct

  game.keyboard[0][0].validation = .correct

  return ContentView(
    game: game
  )
}
