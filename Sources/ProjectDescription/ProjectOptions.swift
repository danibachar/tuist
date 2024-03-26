import Foundation

extension Project {
    /// Options to configure a project.
    public struct Options: Codable, Equatable {
        /// Configures automatic target schemes generation.
        public var automaticSchemesOptions: AutomaticSchemesOptions

        /// Configures the default known regions
        public var defaultKnownRegions: [String]?

        /// Configures the development region.
        public var developmentRegion: String?

        /// Defines if and how bundle accessors are generated
        public var bundleAccessorsOptions: BundleAccessorOptions

        /// Suppress logging of environment in Run Script build phases.
        public var disableShowEnvironmentVarsInScriptPhases: Bool

        /// Disable synthesized resource accessors.
        public var disableSynthesizedResourceAccessors: Bool

        /// Configures text settings.
        public var textSettings: TextSettings

        /// Configures the name of the generated .xcodeproj.
        public var xcodeProjectName: String?

        public static func options(
            automaticSchemesOptions: AutomaticSchemesOptions = .enabled(),
            defaultKnownRegions: [String]? = nil,
            developmentRegion: String? = nil,
            disableBundleAccessors: Bool = false,
            disableShowEnvironmentVarsInScriptPhases: Bool = false,
            disableSynthesizedResourceAccessors: Bool = false,
            textSettings: TextSettings = .textSettings(),
            xcodeProjectName: String? = nil
        ) -> Self {
            var bundleAccessorsOptions: BundleAccessorOptions = .enabled(includeObjcAccessor: true)
            if disableBundleAccessors {
                bundleAccessorsOptions = .disabled
            }
            return self.init(
                automaticSchemesOptions: automaticSchemesOptions,
                defaultKnownRegions: defaultKnownRegions,
                developmentRegion: developmentRegion,
                bundleAccessorsOptions: bundleAccessorsOptions,
                disableShowEnvironmentVarsInScriptPhases: disableShowEnvironmentVarsInScriptPhases,
                disableSynthesizedResourceAccessors: disableSynthesizedResourceAccessors,
                textSettings: textSettings,
                xcodeProjectName: xcodeProjectName
            )
        }

        public static func projectOptions(
            automaticSchemesOptions: AutomaticSchemesOptions = .enabled(),
            defaultKnownRegions: [String]? = nil,
            developmentRegion: String? = nil,
            bundleAccessorsOptions: BundleAccessorOptions = .enabled(includeObjcAccessor: true),
            disableShowEnvironmentVarsInScriptPhases: Bool = false,
            disableSynthesizedResourceAccessors: Bool = false,
            textSettings: TextSettings = .textSettings(),
            xcodeProjectName: String? = nil
        ) -> Self {
            self.init(
                automaticSchemesOptions: automaticSchemesOptions,
                defaultKnownRegions: defaultKnownRegions,
                developmentRegion: developmentRegion,
                bundleAccessorsOptions: bundleAccessorsOptions,
                disableShowEnvironmentVarsInScriptPhases: disableShowEnvironmentVarsInScriptPhases,
                disableSynthesizedResourceAccessors: disableSynthesizedResourceAccessors,
                textSettings: textSettings,
                xcodeProjectName: xcodeProjectName
            )
        }
    }
}

// MARK: - AutomaticSchemesOptions

extension Project.Options {
    /// Automatic schemes options allow customizing the generation of the target schemes.
    public enum AutomaticSchemesOptions: Codable, Equatable {
        /// Allows you to define what targets will be enabled for code coverage data gathering.
        public enum TargetSchemesGrouping: Codable, Equatable {
            /// Generate a single scheme for each project.
            case singleScheme

            /// Group schemes according to the suffix of their names.
            case byNameSuffix(build: Set<String>, test: Set<String>, run: Set<String>)

            /// Generate a scheme for each target.
            case notGrouped
        }

        /// Enable autogenerated schemes
        case enabled(
            targetSchemesGrouping: TargetSchemesGrouping = .byNameSuffix(
                build: ["Implementation", "Interface", "Mocks", "Testing"],
                test: ["Tests", "IntegrationTests", "UITests", "SnapshotTests"],
                run: ["App", "Demo"]
            ),
            codeCoverageEnabled: Bool = false,
            testingOptions: TestingOptions = [],
            testLanguage: SchemeLanguage? = nil,
            testRegion: String? = nil,
            testScreenCaptureFormat: ScreenCaptureFormat? = nil,
            runLanguage: SchemeLanguage? = nil,
            runRegion: String? = nil
        )

        /// Disable autogenerated schemes
        case disabled
    }

    /// The text settings options
    public struct TextSettings: Codable, Equatable {
        /// Whether tabs should be used instead of spaces
        public var usesTabs: Bool?

        /// The width of space indent
        public var indentWidth: UInt?

        /// The width of tab indent
        public var tabWidth: UInt?

        /// Whether lines should be wrapped or not
        public var wrapsLines: Bool?

        public static func textSettings(
            usesTabs: Bool? = nil,
            indentWidth: UInt? = nil,
            tabWidth: UInt? = nil,
            wrapsLines: Bool? = nil
        ) -> Self {
            self.init(usesTabs: usesTabs, indentWidth: indentWidth, tabWidth: tabWidth, wrapsLines: wrapsLines)
        }
    }
}

// MARK: - BundleAccessorOptions

extension Project.Options {
    /// Defines if and how bundle accessors are generated
    public enum BundleAccessorOptions: Codable, Hashable {
        /// Enables generated bundle accessors
        /// Option to control wether an accessor for Objective-C run time will be added as well
        case enabled(includeObjcAccessor: Bool)

        /// Disables generated bundle accessors
        case disabled
    }
}
