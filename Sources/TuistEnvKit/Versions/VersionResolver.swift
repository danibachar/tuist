import Basic
import Foundation
import TuistCore
import Utility

/// Resolved version.
///
/// - local: An existing local version.
/// - pinned: A pinned version.
/// - unspecified: When no version has been specified.
enum ResolvedVersion: Equatable {
    case bin(AbsolutePath)
    case versionFile(AbsolutePath, String)
    case undefined

    static func == (lhs: ResolvedVersion, rhs: ResolvedVersion) -> Bool {
        switch (lhs, rhs) {
        case let (.bin(lhsPath), .bin(rhsPath)):
            return lhsPath == rhsPath
        case let (.versionFile(lhsPath, lhsValue), .versionFile(rhsPath, rhsValue)):
            return lhsValue == rhsValue && lhsPath == rhsPath
        case (.undefined, .undefined):
            return true
        default:
            return false
        }
    }
}

protocol VersionResolving: AnyObject {
    func resolve(path: AbsolutePath) throws -> ResolvedVersion
}

/// Version resolver errors.
///
/// - readError: thrown when a version file cannot be read.
/// - invalidFormat: thrown when the version file contains an invalid format.
enum VersionResolverError: FatalError, Equatable {
    case readError(path: AbsolutePath)
    case invalidFormat(String, path: AbsolutePath)

    var type: ErrorType {
        switch self {
        case .readError: return .abort
        case .invalidFormat: return .bug
        }
    }

    var description: String {
        switch self {
        case let .readError(path):
            return "Cannot read the version file at path \(path.asString)."
        case let .invalidFormat(value, path):
            return "The version \(value) at path \(path.asString) doesn't have a valid semver format: x.y.z."
        }
    }

    static func == (lhs: VersionResolverError, rhs: VersionResolverError) -> Bool {
        switch (lhs, rhs) {
        case let (.readError(lhsPath), .readError(rhsPath)):
            return lhsPath == rhsPath
        case let (.invalidFormat(lhsVersion, lhsPath), .invalidFormat(rhsVersion, rhsPath)):
            return lhsVersion == rhsVersion && lhsPath == rhsPath
        default:
            return false
        }
    }
}

/// Resolves the version that should be used at the given path.
/// The tool looks up recursively the directory and its ancestors until it finds a .tuist-version
/// If a version is not defined it returns nil.
class VersionResolver: VersionResolving {

    // MARK: - Attributes

    /// Settings controller.
    private let settingsController: SettingsControlling

    /// File manager.
    private let fileManager: FileManager = .default

    /// Default verion resolver constructor.
    ///
    /// - Parameter settingsController: settings controller.
    init(settingsController: SettingsControlling = SettingsController()) {
        self.settingsController = settingsController
    }

    /// Resolves the version for the given path.
    ///
    /// - Parameter path: path for which the version will be resolved.
    /// - Returns: the resolved version that should be used at the given path.
    func resolve(path: AbsolutePath) throws -> ResolvedVersion {
        return try resolveTraversing(from: path)
    }

    /// Resolves the version by traversing through the parents looking up for a .tuist-version
    /// file or a .tuist-bin directory.
    ///
    /// - Parameter path: path to traverse from.
    /// - Returns: resolved version.
    /// - Throws: an error if the resolution fails. It can happen if the .tuist-version has an invalid format
    ///   or cannot be read or the bundled binary is in a invalid state.
    fileprivate func resolveTraversing(from path: AbsolutePath) throws -> ResolvedVersion {
        let versionPath = path.appending(component: Constants.versionFileName)
        let binPath = path.appending(component: Constants.binFolderName)
        if fileManager.fileExists(atPath: binPath.asString) {
            return .bin(binPath)
        } else if fileManager.fileExists(atPath: versionPath.asString) {
            return try resolveVersionFile(path: versionPath)
        }
        if path.components.count > 1 {
            return try resolveTraversing(from: path.parentDirectory)
        }
        return .undefined
    }

    /// Resolves a .tuist-version file.
    ///
    /// - Parameter path: path to the .tuist-version file.
    /// - Returns: resolved version.
    /// - Throws: an error if the file cannot be opened or it has an invalid format.
    fileprivate func resolveVersionFile(path: AbsolutePath) throws -> ResolvedVersion {
        var value: String!
        do {
            value = try String(contentsOf: URL(fileURLWithPath: path.asString))
        } catch {
            throw VersionResolverError.readError(path: path)
        }
        guard let version = Version(string: value) else {
            throw VersionResolverError.invalidFormat(value, path: path)
        }
        return ResolvedVersion.versionFile(path, version.description)
    }
}
