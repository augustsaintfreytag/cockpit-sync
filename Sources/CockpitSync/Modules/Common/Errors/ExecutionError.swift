import Foundation

/// An error used when encountering unexpected failure of shell commands in a main or supporting operation.
struct ExecutionError: LocalizedError {
	
	var errorDescription: String?
	
}
