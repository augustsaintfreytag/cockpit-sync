import Foundation
import ArgumentParser

enum Scope: String, Hashable, CaseIterable, ExpressibleByArgument {
	case everything
	case structure
	case data
}

enum Mode: String, Hashable, CaseIterable, ExpressibleByArgument {
	case save
	case restore
}
