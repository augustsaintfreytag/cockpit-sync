import ArgumentParser

enum Scope: String, Hashable, CaseIterable, ExpressibleByArgument {
	case everything
	case structure
	case records
}

enum Mode: String, Hashable, CaseIterable, ExpressibleByArgument {
	case clear
	case save
	case restore
}
