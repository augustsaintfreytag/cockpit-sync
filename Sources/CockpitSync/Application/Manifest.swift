/// The application's manifest.
enum Manifest {
	
	static let name = "Cockpit Sync"
	static let releaseVersion = "1.2.1"
	static let debugVersion =  "\(releaseVersion) Debug Preview"
	
	static var versionDescription: String {
		#if DEBUG
		return debugVersion
		#else
		return releaseVersion
		#endif
	}
	
}
