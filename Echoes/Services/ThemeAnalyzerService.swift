import Foundation
import CoreML
import NaturalLanguage

@Observable
class ThemeAnalyzerService {
    
    static let shared = ThemeAnalyzerService()
    
    private var nlModel: NLModel?
    
    private init() {
        setupModel()
    }
    
    private func setupModel() {
        do {
            let config = MLModelConfiguration()
            let coreMLModel = try EchoThemeClassifier(configuration: config)
            self.nlModel = try NLModel(mlModel: coreMLModel.model)
            print("ThemeAnalyzerService: Successfully loaded EchoThemeClassifier model.")
        } catch {
            print("ThemeAnalyzerService: Failed to load CoreML model: \(error.localizedDescription)")
            self.nlModel = nil
        }
    }
    
    func predictTheme(from text: String) -> String {
        // Fallback for short transcripts
        guard text.count > 10 else {
            return ThemeCategory.wisdom.rawValue // Default for very short text
        }
        
        guard let nlModel = self.nlModel else {
            print("ThemeAnalyzerService: Model not initialized. Returning fallback theme.")
            return ThemeCategory.wisdom.rawValue
        }
        
        // Let NaturalLanguage model predict the label
        let prediction = nlModel.predictedLabel(for: text)
        
        if let theme = prediction {
            print("ThemeAnalyzerService: Predicted theme -> \(theme)")
            return theme
        } else {
            print("ThemeAnalyzerService: Low confidence or unpredicted. Returning fallback theme.")
            return ThemeCategory.wisdom.rawValue
        }
    }
}
