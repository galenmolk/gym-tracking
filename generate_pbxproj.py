#!/usr/bin/env python3
"""Generate a minimal but valid project.pbxproj for GymTracking."""

import uuid
import os

def gen_id():
    return uuid.uuid4().hex[:24].upper()

# All Swift source files (relative to GymTracking/)
swift_files = [
    ("GymTrackingApp.swift", "GymTracking"),
    ("ContentView.swift", "GymTracking"),
    ("Models/SchemaV1.swift", "Models"),
    ("Models/GymTrackingSchemaVersions.swift", "Models"),
    ("Models/Enums/Sentiment.swift", "Enums"),
    ("Views/Session/SessionTabView.swift", "Session"),
    ("Views/Session/ActiveSessionView.swift", "Session"),
    ("Views/Session/ExerciseLogEntryView.swift", "Session"),
    ("Views/Session/SessionSummaryView.swift", "Session"),
    ("Views/Exercises/ExerciseLibraryView.swift", "Exercises"),
    ("Views/Exercises/AddExerciseView.swift", "Exercises"),
    ("Views/Exercises/ExerciseDetailView.swift", "Exercises"),
    ("Views/History/SessionHistoryView.swift", "History"),
    ("Views/History/PastSessionDetailView.swift", "History"),
    ("Components/SentimentPicker.swift", "Components"),
    ("Components/ExerciseLogCard.swift", "Components"),
    ("Components/TrendRow.swift", "Components"),
    ("Utilities/DateFormatting.swift", "Utilities"),
]

# Generate stable IDs
project_id = gen_id()
main_group_id = gen_id()
products_group_id = gen_id()
app_product_id = gen_id()
native_target_id = gen_id()
build_config_list_project_id = gen_id()
build_config_list_target_id = gen_id()
debug_config_project_id = gen_id()
release_config_project_id = gen_id()
debug_config_target_id = gen_id()
release_config_target_id = gen_id()
sources_phase_id = gen_id()
resources_phase_id = gen_id()
frameworks_phase_id = gen_id()

# Source group IDs
gymtracking_group_id = gen_id()
models_group_id = gen_id()
enums_group_id = gen_id()
views_group_id = gen_id()
session_group_id = gen_id()
exercises_group_id = gen_id()
history_group_id = gen_id()
components_group_id = gen_id()
utilities_group_id = gen_id()
preview_group_id = gen_id()

# Asset catalog IDs
assets_file_id = gen_id()
assets_build_id = gen_id()
preview_assets_file_id = gen_id()
preview_assets_build_id = gen_id()

# Generate file ref + build file IDs for each swift file
file_entries = []
for path, group in swift_files:
    file_entries.append({
        "path": path,
        "name": os.path.basename(path),
        "group": group,
        "file_ref_id": gen_id(),
        "build_file_id": gen_id(),
    })

# Map groups to their children
group_children = {
    "GymTracking": [],
    "Models": [],
    "Enums": [],
    "Session": [],
    "Exercises": [],
    "History": [],
    "Components": [],
    "Utilities": [],
}

for entry in file_entries:
    group_children[entry["group"]].append(entry["file_ref_id"])

# Build the pbxproj content
lines = []
def w(line=""):
    lines.append(line)

w("// !$*UTF8*$!")
w("{")
w("\tarchiveVersion = 1;")
w("\tclasses = {")
w("\t};")
w("\tobjectVersion = 56;")
w("\tobjects = {")
w("")

# PBXBuildFile section
w("/* Begin PBXBuildFile section */")
for entry in file_entries:
    w(f'\t\t{entry["build_file_id"]} /* {entry["name"]} in Sources */ = {{isa = PBXBuildFile; fileRef = {entry["file_ref_id"]} /* {entry["name"]} */; }};')
w(f'\t\t{assets_build_id} /* Assets.xcassets in Resources */ = {{isa = PBXBuildFile; fileRef = {assets_file_id} /* Assets.xcassets */; }};')
w(f'\t\t{preview_assets_build_id} /* Preview Assets.xcassets in Resources */ = {{isa = PBXBuildFile; fileRef = {preview_assets_file_id} /* Preview Assets.xcassets */; }};')
w("/* End PBXBuildFile section */")
w("")

# PBXFileReference section
w("/* Begin PBXFileReference section */")
for entry in file_entries:
    w(f'\t\t{entry["file_ref_id"]} /* {entry["name"]} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {entry["name"]}; sourceTree = "<group>"; }};')
w(f'\t\t{assets_file_id} /* Assets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; }};')
w(f'\t\t{preview_assets_file_id} /* Preview Assets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = "Preview Assets.xcassets"; sourceTree = "<group>"; }};')
w(f'\t\t{app_product_id} /* GymTracking.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = GymTracking.app; sourceTree = BUILT_PRODUCTS_DIR; }};')
w("/* End PBXFileReference section */")
w("")

# PBXFrameworksBuildPhase
w("/* Begin PBXFrameworksBuildPhase section */")
w(f"\t\t{frameworks_phase_id} /* Frameworks */ = {{")
w("\t\t\tisa = PBXFrameworksBuildPhase;")
w("\t\t\tbuildActionMask = 2147483647;")
w("\t\t\tfiles = (")
w("\t\t\t);")
w("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
w("\t\t};")
w("/* End PBXFrameworksBuildPhase section */")
w("")

# PBXGroup section
w("/* Begin PBXGroup section */")

# Main group (root)
w(f"\t\t{main_group_id} = {{")
w("\t\t\tisa = PBXGroup;")
w("\t\t\tchildren = (")
w(f"\t\t\t\t{gymtracking_group_id} /* GymTracking */,")
w(f"\t\t\t\t{products_group_id} /* Products */,")
w("\t\t\t);")
w('\t\t\tsourceTree = "<group>";')
w("\t\t};")

# Products group
w(f"\t\t{products_group_id} /* Products */ = {{")
w("\t\t\tisa = PBXGroup;")
w("\t\t\tchildren = (")
w(f"\t\t\t\t{app_product_id} /* GymTracking.app */,")
w("\t\t\t);")
w('\t\t\tname = Products;')
w('\t\t\tsourceTree = "<group>";')
w("\t\t};")

# GymTracking group
w(f"\t\t{gymtracking_group_id} /* GymTracking */ = {{")
w("\t\t\tisa = PBXGroup;")
w("\t\t\tchildren = (")
for entry in file_entries:
    if entry["group"] == "GymTracking":
        w(f'\t\t\t\t{entry["file_ref_id"]} /* {entry["name"]} */,')
w(f"\t\t\t\t{models_group_id} /* Models */,")
w(f"\t\t\t\t{views_group_id} /* Views */,")
w(f"\t\t\t\t{components_group_id} /* Components */,")
w(f"\t\t\t\t{utilities_group_id} /* Utilities */,")
w(f"\t\t\t\t{assets_file_id} /* Assets.xcassets */,")
w(f"\t\t\t\t{preview_group_id} /* Preview Content */,")
w("\t\t\t);")
w('\t\t\tpath = GymTracking;')
w('\t\t\tsourceTree = "<group>";')
w("\t\t};")

# Models group
w(f"\t\t{models_group_id} /* Models */ = {{")
w("\t\t\tisa = PBXGroup;")
w("\t\t\tchildren = (")
for fid in group_children["Models"]:
    name = next(e["name"] for e in file_entries if e["file_ref_id"] == fid)
    w(f'\t\t\t\t{fid} /* {name} */,')
w(f"\t\t\t\t{enums_group_id} /* Enums */,")
w("\t\t\t);")
w('\t\t\tpath = Models;')
w('\t\t\tsourceTree = "<group>";')
w("\t\t};")

# Enums group
w(f"\t\t{enums_group_id} /* Enums */ = {{")
w("\t\t\tisa = PBXGroup;")
w("\t\t\tchildren = (")
for fid in group_children["Enums"]:
    name = next(e["name"] for e in file_entries if e["file_ref_id"] == fid)
    w(f'\t\t\t\t{fid} /* {name} */,')
w("\t\t\t);")
w('\t\t\tpath = Enums;')
w('\t\t\tsourceTree = "<group>";')
w("\t\t};")

# Views group
w(f"\t\t{views_group_id} /* Views */ = {{")
w("\t\t\tisa = PBXGroup;")
w("\t\t\tchildren = (")
w(f"\t\t\t\t{session_group_id} /* Session */,")
w(f"\t\t\t\t{exercises_group_id} /* Exercises */,")
w(f"\t\t\t\t{history_group_id} /* History */,")
w("\t\t\t);")
w('\t\t\tpath = Views;')
w('\t\t\tsourceTree = "<group>";')
w("\t\t};")

# Session group
w(f"\t\t{session_group_id} /* Session */ = {{")
w("\t\t\tisa = PBXGroup;")
w("\t\t\tchildren = (")
for fid in group_children["Session"]:
    name = next(e["name"] for e in file_entries if e["file_ref_id"] == fid)
    w(f'\t\t\t\t{fid} /* {name} */,')
w("\t\t\t);")
w('\t\t\tpath = Session;')
w('\t\t\tsourceTree = "<group>";')
w("\t\t};")

# Exercises group
w(f"\t\t{exercises_group_id} /* Exercises */ = {{")
w("\t\t\tisa = PBXGroup;")
w("\t\t\tchildren = (")
for fid in group_children["Exercises"]:
    name = next(e["name"] for e in file_entries if e["file_ref_id"] == fid)
    w(f'\t\t\t\t{fid} /* {name} */,')
w("\t\t\t);")
w('\t\t\tpath = Exercises;')
w('\t\t\tsourceTree = "<group>";')
w("\t\t};")

# History group
w(f"\t\t{history_group_id} /* History */ = {{")
w("\t\t\tisa = PBXGroup;")
w("\t\t\tchildren = (")
for fid in group_children["History"]:
    name = next(e["name"] for e in file_entries if e["file_ref_id"] == fid)
    w(f'\t\t\t\t{fid} /* {name} */,')
w("\t\t\t);")
w('\t\t\tpath = History;')
w('\t\t\tsourceTree = "<group>";')
w("\t\t};")

# Components group
w(f"\t\t{components_group_id} /* Components */ = {{")
w("\t\t\tisa = PBXGroup;")
w("\t\t\tchildren = (")
for fid in group_children["Components"]:
    name = next(e["name"] for e in file_entries if e["file_ref_id"] == fid)
    w(f'\t\t\t\t{fid} /* {name} */,')
w("\t\t\t);")
w('\t\t\tpath = Components;')
w('\t\t\tsourceTree = "<group>";')
w("\t\t};")

# Utilities group
w(f"\t\t{utilities_group_id} /* Utilities */ = {{")
w("\t\t\tisa = PBXGroup;")
w("\t\t\tchildren = (")
for fid in group_children["Utilities"]:
    name = next(e["name"] for e in file_entries if e["file_ref_id"] == fid)
    w(f'\t\t\t\t{fid} /* {name} */,')
w("\t\t\t);")
w('\t\t\tpath = Utilities;')
w('\t\t\tsourceTree = "<group>";')
w("\t\t};")

# Preview Content group
w(f"\t\t{preview_group_id} /* Preview Content */ = {{")
w("\t\t\tisa = PBXGroup;")
w("\t\t\tchildren = (")
w(f'\t\t\t\t{preview_assets_file_id} /* Preview Assets.xcassets */,')
w("\t\t\t);")
w('\t\t\tpath = "Preview Content";')
w('\t\t\tsourceTree = "<group>";')
w("\t\t};")

w("/* End PBXGroup section */")
w("")

# PBXNativeTarget
w("/* Begin PBXNativeTarget section */")
w(f"\t\t{native_target_id} /* GymTracking */ = {{")
w("\t\t\tisa = PBXNativeTarget;")
w(f"\t\t\tbuildConfigurationList = {build_config_list_target_id} /* Build configuration list for PBXNativeTarget \"GymTracking\" */;")
w("\t\t\tbuildPhases = (")
w(f"\t\t\t\t{sources_phase_id} /* Sources */,")
w(f"\t\t\t\t{frameworks_phase_id} /* Frameworks */,")
w(f"\t\t\t\t{resources_phase_id} /* Resources */,")
w("\t\t\t);")
w("\t\t\tbuildRules = (")
w("\t\t\t);")
w("\t\t\tdependencies = (")
w("\t\t\t);")
w('\t\t\tname = GymTracking;')
w(f'\t\t\tproductName = GymTracking;')
w(f"\t\t\tproductReference = {app_product_id} /* GymTracking.app */;")
w('\t\t\tproductType = "com.apple.product-type.application";')
w("\t\t};")
w("/* End PBXNativeTarget section */")
w("")

# PBXProject
w("/* Begin PBXProject section */")
w(f"\t\t{project_id} /* Project object */ = {{")
w("\t\t\tisa = PBXProject;")
w(f"\t\t\tbuildConfigurationList = {build_config_list_project_id} /* Build configuration list for PBXProject \"GymTracking\" */;")
w('\t\t\tcompatibilityVersion = "Xcode 14.0";')
w("\t\t\tdevelopmentRegion = en;")
w("\t\t\thasScannedForEncodings = 0;")
w("\t\t\tknownRegions = (")
w("\t\t\t\ten,")
w('\t\t\t\tBase,')
w("\t\t\t);")
w(f"\t\t\tmainGroup = {main_group_id};")
w(f"\t\t\tproductRefGroup = {products_group_id} /* Products */;")
w('\t\t\tprojectDirPath = "";')
w('\t\t\tprojectRoot = "";')
w("\t\t\ttargets = (")
w(f"\t\t\t\t{native_target_id} /* GymTracking */,")
w("\t\t\t);")
w("\t\t};")
w("/* End PBXProject section */")
w("")

# PBXResourcesBuildPhase
w("/* Begin PBXResourcesBuildPhase section */")
w(f"\t\t{resources_phase_id} /* Resources */ = {{")
w("\t\t\tisa = PBXResourcesBuildPhase;")
w("\t\t\tbuildActionMask = 2147483647;")
w("\t\t\tfiles = (")
w(f"\t\t\t\t{assets_build_id} /* Assets.xcassets in Resources */,")
w(f"\t\t\t\t{preview_assets_build_id} /* Preview Assets.xcassets in Resources */,")
w("\t\t\t);")
w("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
w("\t\t};")
w("/* End PBXResourcesBuildPhase section */")
w("")

# PBXSourcesBuildPhase
w("/* Begin PBXSourcesBuildPhase section */")
w(f"\t\t{sources_phase_id} /* Sources */ = {{")
w("\t\t\tisa = PBXSourcesBuildPhase;")
w("\t\t\tbuildActionMask = 2147483647;")
w("\t\t\tfiles = (")
for entry in file_entries:
    w(f'\t\t\t\t{entry["build_file_id"]} /* {entry["name"]} in Sources */,')
w("\t\t\t);")
w("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
w("\t\t};")
w("/* End PBXSourcesBuildPhase section */")
w("")

# XCBuildConfiguration section
common_project_settings = """
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;"""

w("/* Begin XCBuildConfiguration section */")

# Debug - Project
w(f"\t\t{debug_config_project_id} /* Debug */ = {{")
w("\t\t\tisa = XCBuildConfiguration;")
w("\t\t\tbuildSettings = {")
w(common_project_settings)
w("\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;")
w("\t\t\t\tENABLE_TESTABILITY = YES;")
w("\t\t\t\tGCC_DYNAMIC_NO_PIC = NO;")
w("\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;")
w('\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = (')
w('\t\t\t\t\t"DEBUG=1",')
w('\t\t\t\t\t"$(inherited)",')
w('\t\t\t\t);')
w("\t\t\t\tMTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;")
w("\t\t\t\tMTL_FAST_MATH = YES;")
w("\t\t\t\tONLY_ACTIVE_ARCH = YES;")
w("\t\t\t};")
w('\t\t\tname = Debug;')
w("\t\t};")

# Release - Project
w(f"\t\t{release_config_project_id} /* Release */ = {{")
w("\t\t\tisa = XCBuildConfiguration;")
w("\t\t\tbuildSettings = {")
w(common_project_settings.replace('SWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";', 'SWIFT_ACTIVE_COMPILATION_CONDITIONS = "$(inherited)";'))
w("\t\t\t\tCOPY_PHASE_STRIP = NO;")
w("\t\t\t\tDEBUG_INFORMATION_FORMAT = \"dwarf-with-dsym\";")
w("\t\t\t\tENABLE_NS_ASSERTIONS = NO;")
w("\t\t\t\tMTL_ENABLE_DEBUG_INFO = NO;")
w("\t\t\t\tMTL_FAST_MATH = YES;")
w("\t\t\t\tSWIFT_COMPILATION_MODE = wholemodule;")
w("\t\t\t\tVALIDATE_PRODUCT = YES;")
w("\t\t\t};")
w('\t\t\tname = Release;')
w("\t\t};")

target_settings = """
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_ASSET_PATHS = "\"GymTracking/Preview Content\"";
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.galenmolk.gymtracking;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				TARGETED_DEVICE_FAMILY = "1,2";"""

# Debug - Target
w(f"\t\t{debug_config_target_id} /* Debug */ = {{")
w("\t\t\tisa = XCBuildConfiguration;")
w("\t\t\tbuildSettings = {")
w(target_settings)
w("\t\t\t};")
w('\t\t\tname = Debug;')
w("\t\t};")

# Release - Target
w(f"\t\t{release_config_target_id} /* Release */ = {{")
w("\t\t\tisa = XCBuildConfiguration;")
w("\t\t\tbuildSettings = {")
w(target_settings)
w("\t\t\t};")
w('\t\t\tname = Release;')
w("\t\t};")

w("/* End XCBuildConfiguration section */")
w("")

# XCConfigurationList section
w("/* Begin XCConfigurationList section */")
w(f"\t\t{build_config_list_project_id} /* Build configuration list for PBXProject \"GymTracking\" */ = {{")
w("\t\t\tisa = XCConfigurationList;")
w("\t\t\tbuildConfigurations = (")
w(f"\t\t\t\t{debug_config_project_id} /* Debug */,")
w(f"\t\t\t\t{release_config_project_id} /* Release */,")
w("\t\t\t);")
w("\t\t\tdefaultConfigurationIsVisible = 0;")
w('\t\t\tdefaultConfigurationName = Release;')
w("\t\t};")
w(f"\t\t{build_config_list_target_id} /* Build configuration list for PBXNativeTarget \"GymTracking\" */ = {{")
w("\t\t\tisa = XCConfigurationList;")
w("\t\t\tbuildConfigurations = (")
w(f"\t\t\t\t{debug_config_target_id} /* Debug */,")
w(f"\t\t\t\t{release_config_target_id} /* Release */,")
w("\t\t\t);")
w("\t\t\tdefaultConfigurationIsVisible = 0;")
w('\t\t\tdefaultConfigurationName = Release;')
w("\t\t};")
w("/* End XCConfigurationList section */")

w("\t};")
w(f"\trootObject = {project_id} /* Project object */;")
w("}")

output = "\n".join(lines) + "\n"
output_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "GymTracking.xcodeproj", "project.pbxproj")
os.makedirs(os.path.dirname(output_path), exist_ok=True)
with open(output_path, "w") as f:
    f.write(output)

print(f"Generated {output_path}")
print(f"Total Swift files: {len(file_entries)}")
print(f"Total build files: {len(file_entries) + 2} (+ 2 asset catalogs)")
