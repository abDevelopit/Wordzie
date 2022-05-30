//
//  ContentView.swift
//  Wordzie
//
//  Created by Perayil, Abhilash on 3/16/22.
//

import SwiftUI

class MyModel: ObservableObject {
    let keyboardAlphabets = Array("QWERTYUIOPASDFGHJKLZXCVBNM<")
    var greenLetters = Array("")
    var yellowLetters = Array("")
    var grayLetters = Array("")
    
    @Published var onGoingWords = Array("******************************")
    @Published var colorsArray  = Array("******************************")

    @Published var currentAlphaCount = 0
    @Published var completedWordsCount = 0
    var completedAlphaCounts = 0
    var wordzieWord = wordzieWordPicker()
}

@available(iOS 15.0, *)
struct GameView: View {
    @StateObject var  myModel = MyModel()
    @State private var showingAlert = false
    let keyboardColumns = Array(repeating: GridItem(.adaptive(minimum:50)), count: 9)
    let alphaColumns = Array(repeating: GridItem(.adaptive(minimum:30)), count: 5)

    var buttonColor: Color {
        return myModel.currentAlphaCount != 5 ? .gray : .purple
    }
    var body: some View {
        ScrollView(.vertical) {
            Spacer()
            HStack{
                Spacer(minLength: 30)
                LazyVGrid(columns: alphaColumns, alignment: .trailing, spacing: 7) {
                    ForEach(0..<myModel.onGoingWords.count, id:\.self) {  index in
                        VStack{
                            if(String(myModel.onGoingWords[index]) == "*") {
                                ColorView(anAlphabet: "", color: Color.clear)
                            } else {
                                switch (myModel.colorsArray[index]) {
                                case "G": ColorView(anAlphabet: String(myModel.onGoingWords[index]), color: Color(red: 170/255, green: 210/255, blue: 117/255))
                                case "Y": ColorView(anAlphabet: String(myModel.onGoingWords[index]), color: Color(red: 244/255, green: 204/255, blue: 71/255))
                                case "D":  ColorView(anAlphabet: String(myModel.onGoingWords[index]), color: Color(red: 128/255, green: 127/255, blue: 137/255))
                                default:
                                    ColorView(anAlphabet: String(myModel.onGoingWords[index]), color: Color.clear)
                                }
                            }
                        }
                    }
                }
                Spacer(minLength: 30)
            }
            Spacer().frame(height: 50)
            HStack{
                Button("Submit") {
                    let startingIndex = myModel.completedWordsCount * 5
                    let endIndex = myModel.completedWordsCount * 5 + 5
                    let mySubstring = String(myModel.onGoingWords).substring(with: startingIndex..<endIndex)
                    if (mySubstring.firstIndex(of: "*") == nil) {
                        for (index, char) in myModel.wordzieWord.enumerated() {
                            if(myModel.onGoingWords[startingIndex + index] == char) {
                                myModel.colorsArray.insert(contentsOf: "G", at: startingIndex + index)
                                myModel.greenLetters.append(char)
                                myModel.colorsArray.removeLast()
                            } else if(myModel.wordzieWord.firstIndex(of: myModel.onGoingWords[startingIndex + index]) != nil) {
                                myModel.colorsArray.insert(contentsOf: "Y", at: startingIndex + index)
                                myModel.yellowLetters.append(myModel.onGoingWords[startingIndex + index])
                                myModel.colorsArray.removeLast()
                            } else {
                                myModel.colorsArray.insert(contentsOf: "D", at: startingIndex + index)
                                myModel.grayLetters.append(myModel.onGoingWords[startingIndex + index])
                                myModel.colorsArray.removeLast()
                            }
                        }
                    }
                    myModel.currentAlphaCount = 0
                    myModel.completedAlphaCounts += 5
                    myModel.completedWordsCount += 1
                }
                .frame(width: 100, height: 40, alignment: Alignment.center)
                .disabled(myModel.currentAlphaCount != 5)
                .background(buttonColor)
                .buttonStyle(GrowingButton())
                Button("Reset Game") {
                    showingAlert = true
                    myModel.greenLetters.removeAll()
                    myModel.grayLetters.removeAll()
                    myModel.yellowLetters.removeAll()
                    myModel.onGoingWords = Array("******************************")
                    myModel.colorsArray = Array("******************************")
                    myModel.completedAlphaCounts = 0
                    myModel.currentAlphaCount = 0
                    myModel.completedWordsCount = 0
                }
                .alert("Wordzie word was : " + myModel.wordzieWord, isPresented: $showingAlert) {
                    Button("Restart") {
                        myModel.wordzieWord = wordzieWordPicker()
                    }
                }
                
                .frame(width: 150, height: 40, alignment: Alignment.center)
                .background(Color.purple)
                .buttonStyle(GrowingButton())
                Spacer().frame(height: 50)
            }
            LazyVGrid(columns: keyboardColumns, alignment: .leading, spacing: 5) {
                ForEach(myModel.keyboardAlphabets.indices){ item in
                    VStack{
                        ZStack {
                            if(myModel.greenLetters.firstIndex(of: myModel.keyboardAlphabets[item]) != nil) {
                                Color.green
                                    .frame(width: 30, height: 50, alignment: .center)
                                    .cornerRadius(1)
                            } else if(myModel.yellowLetters.firstIndex(of: myModel.keyboardAlphabets[item]) != nil) {
                                Color.yellow
                                    .frame(width: 30, height: 50, alignment: .center)
                                    .cornerRadius(1)
                            } else if(myModel.grayLetters.firstIndex(of: myModel.keyboardAlphabets[item]) != nil) {
                                Color.gray
                                    .frame(width: 30, height: 50, alignment: .center)
                                    .cornerRadius(1)
                            } else {
                                Color.white
                                    .frame(width: 30, height: 50, alignment: .center)
                                    .cornerRadius(1)
                            }
                            Text(String(myModel.keyboardAlphabets[item])).fontWeight(.bold)
                                .foregroundColor(Color.black)
                                .gesture(
                                    TapGesture()
                                        .onEnded { _ in
                                            //---------- BACKSPACE -----------------------
                                            if(myModel.keyboardAlphabets[item] == "<") {
                                                if let index = myModel.onGoingWords.firstIndex(of: "*") {
                                                    if (index > (0 + myModel.completedAlphaCounts)) {
                                                        myModel.onGoingWords.remove(at: index-1)
                                                        myModel.onGoingWords.append("*")
                                                        myModel.currentAlphaCount -= 1
                                                    }
                                                }
                                            } else {
                                                //---------- ALPHA ENTRY -----------------------
                                                if (myModel.currentAlphaCount < 5) {
                                                    if let index = myModel.onGoingWords.firstIndex(of: "*") {
                                                        myModel.onGoingWords.insert(contentsOf: String(myModel.keyboardAlphabets[item]), at: index)
                                                        myModel.onGoingWords.removeLast()
                                                        myModel.currentAlphaCount += 1
                                                    }
                                                }
                                            }
                                        }
                                )
                        }
                    }
                }
            }
        }.padding()
    }
}

func ColorView(anAlphabet: String, color: Color) -> some View {
    ZStack {
        if (color == Color.clear) {
            color
                .frame(width: 50, height: 50, alignment: .center)
                .border(Color.gray)
            Text(anAlphabet).font(.largeTitle).bold()
                .foregroundColor(Color.gray)
        } else {
            color
                .frame(width: 50, height: 50, alignment: .center)
                .cornerRadius(5)
            Text(anAlphabet).font(.largeTitle).bold()
                .foregroundColor(Color.white)
        }
    }
}

func wordzieWordPicker() -> String {
    var wordzieWord = "WORDZ"
    if let path = Bundle.main.path(forResource: "Dataset", ofType: "plist") {
        let randomInt = Int.random(in: 0..<499)
        if let anArray = NSArray(contentsOfFile: path) {
            wordzieWord = anArray[randomInt] as! String
            wordzieWord = wordzieWord.uppercased()
        }
    }
    return wordzieWord
}

@available(iOS 15.0, *)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }

    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }

    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }

    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
}

struct GrowingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .foregroundColor(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
