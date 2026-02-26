import Foundation
import CreateML

let arguments = CommandLine.arguments

let fileManager = FileManager.default
let currentDirectory = fileManager.currentDirectoryPath

let csvFilename = "ThemeData.csv"
let csvURL = URL(fileURLWithPath: currentDirectory).appendingPathComponent(csvFilename)

guard fileManager.fileExists(atPath: csvURL.path) else {
    print("Error: Could not find \(csvFilename) in \(currentDirectory)")
    exit(1)
}

do {
    print("Loading data from \(csvURL.path)...")
    let dataTable = try MLDataTable(contentsOf: csvURL)
    
    print("Training MLTextClassifier...")
    let classifier = try MLTextClassifier(trainingData: dataTable, textColumn: "Text", labelColumn: "Label")
    
    let metadata = MLModelMetadata(
        author: "Echoes",
        shortDescription: "Text classifier to categorize journal echoes by theme",
        version: "1.0"
    )
    
    let modelFilename = "EchoThemeClassifier.mlmodel"
    let modelURL = URL(fileURLWithPath: currentDirectory).appendingPathComponent(modelFilename)
    
    print("Saving model to \(modelURL.path)...")
    try classifier.write(to: modelURL, metadata: metadata)
    
    print("Successfully trained and saved model: \(modelFilename)")
    
} catch {
    print("Failed to train model: \(error)")
    exit(1)
}
