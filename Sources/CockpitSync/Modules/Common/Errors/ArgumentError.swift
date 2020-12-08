import Foundation

/// An error used for all issues related to arguments supplied to a command.
struct ArgumentError: LocalizedError {
	
	let kind: Kind
	let errorDescription: String?
	
}

extension ArgumentError {
	
	enum Kind {
		case missingArgument
		case invalidArgument
		case extraneousArgument
	}
	
}
