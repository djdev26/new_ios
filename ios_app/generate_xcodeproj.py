import os
import shutil

IOS_APP_DIR = r"c:\Users\Dijo Giftson\Desktop\NOVA\ios_app"
ARUVI_DIR = os.path.join(IOS_APP_DIR, "Aruvi")
XCODEPROJ_DIR = os.path.join(IOS_APP_DIR, "Aruvi.xcodeproj")

def create_structure():
    # 1. Create subdirectories
    os.makedirs(ARUVI_DIR, exist_ok=True)
    os.makedirs(XCODEPROJ_DIR, exist_ok=True)
    
    assets_dir = os.path.join(ARUVI_DIR, "Assets.xcassets")
    appiconset_dir = os.path.join(assets_dir, "AppIcon.appiconset")
    os.makedirs(appiconset_dir, exist_ok=True)
    
    # 2. Move source files into Aruvi subdirectory
    source_files = ["AruviApp.swift", "ContentView.swift", "AruviVoiceManager.swift"]
    for f in source_files:
        src = os.path.join(IOS_APP_DIR, f)
        dst = os.path.join(ARUVI_DIR, f)
        if os.path.exists(src):
            shutil.move(src, dst)
            print(f"Moved {f} to Aruvi/")
        elif os.path.exists(dst):
            print(f"{f} already in Aruvi/")
            
    # 3. Create Contents.json for Assets
    contents_json = """{
  "images" : [
    {
      "idiom" : "iphone",
      "size" : "20x20",
      "scale" : "2x"
    },
    {
      "idiom" : "iphone",
      "size" : "20x20",
      "scale" : "3x"
    },
    {
      "idiom" : "iphone",
      "size" : "29x29",
      "scale" : "2x"
    },
    {
      "idiom" : "iphone",
      "size" : "29x29",
      "scale" : "3x"
    },
    {
      "idiom" : "iphone",
      "size" : "40x40",
      "scale" : "2x"
    },
    {
      "idiom" : "iphone",
      "size" : "40x40",
      "scale" : "3x"
    },
    {
      "idiom" : "iphone",
      "size" : "60x60",
      "scale" : "2x"
    },
    {
      "idiom" : "iphone",
      "size" : "60x60",
      "scale" : "3x"
    },
    {
      "idiom" : "ios-marketing",
      "size" : "1024x1024",
      "scale" : "1x"
    }
  ],
  "info" : {
    "version" : 1,
    "author" : "xcode"
  }
}"""
    with open(os.path.join(appiconset_dir, "Contents.json"), "w") as f:
        f.write(contents_json)
        
    # 4. Create Info.plist with Microphone and Speech permissions
    info_plist = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>$(DEVELOPMENT_LANGUAGE)</string>
	<key>CFBundleExecutable</key>
	<string>$(EXECUTABLE_NAME)</string>
	<key>CFBundleIdentifier</key>
	<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>$(PRODUCT_NAME)</string>
	<key>CFBundlePackageType</key>
	<string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>LSRequiresIPhoneOS</key>
	<true/>
	<key>NSMicrophoneUsageDescription</key>
	<string>Aruvi needs microphone access to listen to your voice commands.</string>
	<key>NSSpeechRecognitionUsageDescription</key>
	<string>Aruvi needs speech recognition access to transcribe your spoken words.</string>
	<key>UIApplicationSceneManifest</key>
	<dict>
		<key>UIApplicationSupportsMultipleScenes</key>
		<false/>
	</dict>
	<key>UILaunchScreen</key>
	<dict/>
	<key>UISupportedInterfaceOrientations</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
	</array>
</dict>
</plist>
"""
    with open(os.path.join(ARUVI_DIR, "Info.plist"), "w") as f:
        f.write(info_plist)
        print("Created Info.plist with permissions")

    # 5. Create project.pbxproj
    pbxproj = """// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {

/* Begin PBXBuildFile section */
		2D02B2252D02B2250000000D /* AruviApp.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2D02B2242D02B2240000000C /* AruviApp.swift */; };
		2D02B2272D02B2270000000F /* ContentView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2D02B2262D02B2260000000E /* ContentView.swift */; };
		2D02B2292D02B22900000011 /* AruviVoiceManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2D02B2282D02B22800000010 /* AruviVoiceManager.swift */; };
		2D02B22C2D02B22C00000014 /* Assets.xcassets in Resources */ = {isa = PBXBuildFile; fileRef = 2D02B22B2D02B22B00000013 /* Assets.xcassets */; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
		2D02B21F2D02B21F0000000B /* Aruvi.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = Aruvi.app; sourceTree = BUILT_PRODUCTS_DIR; };
		2D02B2242D02B2240000000C /* AruviApp.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AruviApp.swift; sourceTree = "<group>"; };
		2D02B2262D02B2260000000E /* ContentView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ContentView.swift; sourceTree = "<group>"; };
		2D02B2282D02B22800000010 /* AruviVoiceManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AruviVoiceManager.swift; sourceTree = "<group>"; };
		2D02B22A2D02B22A00000012 /* Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; };
		2D02B22B2D02B22B00000013 /* Assets.xcassets */ = {isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; };
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		2D02B21A2D02B21A00000006 /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		2D02B2142D02B21400000008 /* CustomRoot */ = {
			isa = PBXGroup;
			children = (
				2D02B2202D02B2200000009 /* Aruvi */,
				2D02B21E2D02B21E0000000A /* Products */,
			);
			sourceTree = "<group>";
		};
		2D02B21E2D02B21E0000000A /* Products */ = {
			isa = PBXGroup;
			children = (
				2D02B21F2D02B21F0000000B /* Aruvi.app */,
			);
			name = Products;
			sourceTree = "<group>";
		};
		2D02B2202D02B2200000009 /* Aruvi */ = {
			isa = PBXGroup;
			children = (
				2D02B2242D02B2240000000C /* AruviApp.swift */,
				2D02B2262D02B2260000000E /* ContentView.swift */,
				2D02B2282D02B22800000010 /* AruviVoiceManager.swift */,
				2D02B22B2D02B22B00000013 /* Assets.xcassets */,
				2D02B22A2D02B22A00000012 /* Info.plist */,
			);
			path = Aruvi;
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		2D02B21C2D02B21C00000002 /* Aruvi */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = 2D02B2222D02B22200000004 /* Build configuration list for PBXNativeTarget "Aruvi" */;
			buildPhases = (
				2D02B2192D02B21900000005 /* Sources */,
				2D02B21A2D02B21A00000006 /* Frameworks */,
				2D02B21B2D02B21B00000007 /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = Aruvi;
			productName = Aruvi;
			productReference = 2D02B21F2D02B21F0000000B /* Aruvi.app */;
			productType = "com.apple.product-type.application";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		2D02B2152D02B21500000001 /* Project object */ = {
			isa = PBXProject;
			attributes = {
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1400;
				LastUpgradeCheck = 1400;
				TargetAttributes = {
					2D02B21C2D02B21C00000002 = {
						CreatedOnToolsVersion = 14.0;
						LastSwiftMigration = 1400;
					};
				};
			};
			buildConfigurationList = 2D02B2182D02B21800000003 /* Build configuration list for PBXProject "Aruvi" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = 2D02B2142D02B21400000008 /* CustomRoot */;
			productRefGroup = 2D02B21E2D02B21E0000000A /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				2D02B21C2D02B21C00000002 /* Aruvi */,
			);
		};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		2D02B21B2D02B21B00000007 /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				2D02B22C2D02B22C00000014 /* Assets.xcassets in Resources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		2D02B2192D02B21900000005 /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				2D02B2252D02B2250000000D /* AruviApp.swift in Sources */,
				2D02B2272D02B2270000000F /* ContentView.swift in Sources */,
				2D02B2292D02B22900000011 /* AruviVoiceManager.swift in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		2D02B2162D02B21600000015 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_CXX_LIBRARY = "libc++";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				GCC_C_LANGUAGE_STANDARD = gnu11;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"$(inherited)",
				);
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			};
			name = Debug;
		};
		2D02B2172D02B21700000016 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_CXX_LIBRARY = "libc++";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				GCC_C_LANGUAGE_STANDARD = gnu11;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = wholemodule;
				SWIFT_OPTIMIZATION_LEVEL = "-O";
				VALIDATE_PRODUCT = YES;
			};
			name = Release;
		};
		2D02B2212D02B22100000017 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = Aruvi/Info.plist;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.dijo.aruvi;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1";
			};
			name = Debug;
		};
		2D02B2232D02B22300000018 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = Aruvi/Info.plist;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.dijo.aruvi;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1";
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		2D02B2182D02B21800000003 /* Build configuration list for PBXProject "Aruvi" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				2D02B2162D02B21600000015 /* Debug */,
				2D02B2172D02B21700000016 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		2D02B2222D02B22200000004 /* Build configuration list for PBXNativeTarget "Aruvi" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				2D02B2212D02B22100000017 /* Debug */,
				2D02B2232D02B22300000018 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */
	};
	rootObject = 2D02B2152D02B21500000001 /* Project object */;
}
"""
    with open(os.path.join(XCODEPROJ_DIR, "project.pbxproj"), "w") as f:
        f.write(pbxproj)
        print("Generated Aruvi.xcodeproj/project.pbxproj")
        
    print("Project successfully created!")

if __name__ == "__main__":
    create_structure()
