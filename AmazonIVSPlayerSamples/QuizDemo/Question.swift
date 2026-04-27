import Foundation

struct Question: Decodable {
    let question: String
    let answers: [String]
    let correctIndex: Int

    init(_ question: String, _ answers: [String], _ correctIndex: Int) {
        self.question = question
        self.answers = answers
        self.correctIndex = correctIndex
    }
}

extension Question {
    var correctAnswer: String {
        return answers[correctIndex]
    }
}
