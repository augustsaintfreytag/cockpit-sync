import ArgumentParser

enum Scope: String, Hashable, CaseIterable, ExpressibleByArgument {
	
	case everything
	case structure
	case records
	
}

extension Scope: CustomStringConvertible {
	
	var defaultValueDescription: String {
		return self.rawValue
	}
	
	var description: String {
		switch self {
		case .everything:
			return "all structure and records"
		default:
			return self.rawValue
		}
	}
	
}

enum Mode: String, Hashable, CaseIterable, ExpressibleByArgument {
	
	case clear
	case save
	case restore
	
	case probeArchive
	case probeVolume
	
}
