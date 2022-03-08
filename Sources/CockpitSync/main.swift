import Foundation
import ArgumentParser

struct CockpitSync: ParsableCommand, VolumePreparer, InVolumeDirectoryPreparer, ArchiveDirectoryPreparer, CockpitSaveOperation, CockpitRestoreOperation, CanonicalPathProvider {
	
	// MARK: Configuration
	
	static var configuration = CommandConfiguration(
		abstract: "Saves or restores data of a Cockpit CMS instance.",
		discussion: lines(
			"Handles saving and restoring of internal data stores of Cockpit CMS (getcockpit.com),",
			"an open source content management system, developed and maintained by Agentejo.",
			"",
			"Assumes that Cockpit runs in a Docker container with its own dedicated volume mounted",
			"at `/var/www/html/storage` inside the container environment. If the targeted Cockpit instance",
			"runs openly outside of containerization, no special tools are required to save and restore its data."
		),
		version: "\(Manifest.name), Version \(Manifest.versionDescription)"
	)
	
	// MARK: Properties
	
	var workingDirectoryPath: Path? {
		return runInShell("pwd")?.outputString
	}

	var canonicalArchivePath: Path? {
		resolvedCanonicalPath(from: archivePath)
	}
	
	// MARK: Arguments & Options
	
	@Argument(help: "The mode of the operation. (run options: save|restore|clear, validation options: probeArchive|probeVolume)")
	var mode: Mode

	@Option(name: [.long, .short], help: "The scope of the operation. (options: structure|records|everything)")
	var scope: Scope = .everything
	
	@Option(name: [.customLong("docker-volume"), .customShort("v")], help: "The name of the Docker volume used by Cockpit to store data.")
	var dockerVolumeName: String?

	@Option(name: [.customLong("archive"), .customShort("a")], help: "The path to the archive directory used to read and write data.")
	var archivePath: String
	
	@Flag(name: [.short, .long], help: "Force save or restore operations even if not all directories are present.")
	var force: Bool = false

	// MARK: Run

	func run() throws {
		// Mode
		switch mode {
		case .clear:
			try runModeClear()
		case .save:
			try runModeSave()
		case .restore:
			try runModeRestore()
		case .probeArchive:
			guard let archivePath = canonicalArchivePath else {
				throw PrerequisiteError(errorDescription: "Archive path can not be determined or canonically resolved.")
			}
			
			guard try archiveDirectoriesExist(for: scope, archivePath: archivePath) else {
				throw PrerequisiteError(errorDescription: "Archive directory '\(archivePath)' may exist but expected subdirectories are missing.")
			}
			
			print("Archive path '\(archivePath)' and all expected subdirectories exists.")
		case .probeVolume:
			guard let dockerVolumeName = dockerVolumeName else {
				throw PrerequisiteError(errorDescription: "Missing argument for Docker volume name.")
			}
			
			guard dockerVolumeExists(dockerVolumeName) else {
				throw PrerequisiteError(errorDescription: "Docker volume '\(dockerVolumeName)' does not exist.")
			}
			
			print("Docker volume '\(dockerVolumeName)' exists.")
		}
	}
	
	private func runModeClear() throws {
		try clearArchiveDirectories(for: scope, in: archivePath)
	}
	
	private func runModeSave() throws {
		let volumeName = try assertVolume()
		
		guard let archivePath = canonicalArchivePath else {
			throw PrerequisiteError(errorDescription: "Archive path can not be determined or canonically resolved.")
		}
		
		try clearArchiveDirectories(for: scope, in: archivePath)
		try setUpArchiveDirectories(for: scope, in: archivePath)
		try saveCockpitToArchive(for: scope, volumeName: volumeName, archivePath: archivePath)
	}
	
	private func runModeRestore() throws {
		let volumeName = try assertVolume()

		guard let archivePath = canonicalArchivePath else {
			throw PrerequisiteError(errorDescription: "Archive directory '\(archivePath)' can not be resolved.")
		}
		
		guard try archiveDirectoriesExist(for: scope, archivePath: archivePath) || force else {
			throw PrerequisiteError(errorDescription: "Archive directory '\(archivePath)' may exist but is missing directories. Use '-f' or '--force' to restore with missing sources.")
		}
		
		if !inVolumeDirectoriesExist(for: scope, volumeName: volumeName) {
			try setUpInVolumeDirectories(for: scope, volumeName: volumeName)
		}
		
		try restoreDataFromArchive(for: scope, volumeName: volumeName, archivePath: archivePath)
		try setPermissionsInVolume(volumeName: volumeName)
	}
	
	// MARK: Prerequisites
	
	private func assertVolume() throws -> String {
		guard let volumeName = dockerVolumeName else {
			throw ArgumentError(kind: .missingArgument, errorDescription: "Docker volume not supplied. The Cockpit instance to read from is expected to use a Docker volume for storage.")
		}
		
		guard dockerVolumeExists(volumeName) else {
			throw PrerequisiteError(errorDescription: "Docker volume '\(dockerVolumeName ?? "<None>")' does not exist. The volume used by Cockpit must be created and named beforehand.")
		}
		
		return volumeName
	}
	
}

// MARK: Entry

CockpitSync.main()
