import Foundation

/// An error used when missing or failing prerequisites or related steps preceding a main operation.
struct PrerequisiteError: LocalizedError {
	
	var errorDescription: String?
	
}
