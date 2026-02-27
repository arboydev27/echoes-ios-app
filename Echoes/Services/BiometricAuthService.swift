import Foundation
import LocalAuthentication

final class BiometricAuthService {
    static let shared = BiometricAuthService()
    
    private init() {}
    
    func canAuthenticate() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    func authenticate() async -> Bool {
        let context = LAContext()
        var error: NSError?
        
        // Check if biometric authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Unlock your private Library of memories."
            
            do {
                let success = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
                return success
            } catch {
                print("Biometric authentication failed: \(error.localizedDescription)")
                return false
            }
        } else {
            // Biometrics not available (not enrolled or not supported)
            print("Biometrics not available: \(error?.localizedDescription ?? "Unknown error")")
            return false
        }
    }
}
