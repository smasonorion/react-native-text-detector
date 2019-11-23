installing RNTextDetector is a bit awkward without pods

simply install as a library and put product output .a in build phases linked libraries
then
add int TesseractOCR code 
  if needed, install cocoapods with 'sudo gem install cocoapods'
  then pod init, if no pod file 
  then in podFile add "  pod 'TesseractOCRiOS'"  as per https://www.raywenderlich.com/2010498-tesseract-ocr-tutorial-for-ios
  then run pod install
    if frameworks are used, the header files are stored in 
      ${BUILD_DIR}/$(CONFIGURATION)$(EFFECTIVE_PLATFORM_NAME)/TesseractOCRiOS/TesseractOCR.framework/Headers"
    otherwise they are in 
      $(SRCROOT)/../../ios/Pods/Headers/Public/TesseractOCRiOS (recursive)
  then modify RNTextDetector headerSearchPaths to look in 


add TessearactOCR data as defined in the RNTextDetector readme.md on github - ie, add with "create folder reference" checked


note on pods
  running pod install, creates a project called Pods.xcodeproj in the /Pods subdirectory 
    automatically populates the header files 
  this project creates all the subprojects (pods) and then generates the final product
  to reinstall pods, just delete the Pods directory and rerun...

eventually gave up and just installed Tesseract project as a submodule and directly linked in xcode project into mine
one minor touch needed as suggested in https://stackoverflow.com/questions/28244468/dyld-library-not-loaded-rpath-with-ios8
1. In the framework project settings change the install directory from '/Library/Frameworks' to '@executable_path/../Frameworks'

2. In the project that includes this framework, add a copy files phase and copy this framework to the 'Frameworks' folder. Once you do this ensure that this framework is listed under the 'Embedded Binaries' section.
<!-- Tesseract pod, generates xconfig files that have extra LD flags which cause problems



_PRODUCTS_DIR = /Users/stevenmason/Library/Developer/Xcode/DerivedData/sphb-dzvodmowroxobadxacwdqspzltrd/Build/Products/Debug-iphoneos
_BUILD_DIR = /Users/stevenmason/Library/Developer/Xcode/DerivedData/sphb-dzvodmowroxobadxacwdqspzltrd/Build/Intermediates.noindex/sphb.build/Debug-iphoneos/sphb.build/Objects-normal/arm64

Ld _PRODUCTS_DIR/sphb.app/sphb normal arm64 (in target 'sphb' from project 'sphb')
    cd /Users/stevenmason/Documents/__projects/stpauls_billing/sphb/ios

    .../clang 
      -target arm64-apple-ios11.2 
      -isysroot /Applications/Xcode11_1.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS13.1.sdk 
      -L_PRODUCTS_DIR 
      -L/Users/stevenmason/Documents/__projects/stpauls_billing/sphb/ios/Pods/TesseractOCRiOS/TesseractOCR/lib 
      -F_PRODUCTS_DIR 
      -F_PRODUCTS_DIR/TesseractOCRiOS 
      -filelist _BUILD_DIR/sphb.LinkFileList 
      -Xlinker -rpath 
      -Xlinker @executable_path/Frameworks 
      -Xlinker -rpath 
      -Xlinker @loader_path/Frameworks 
      -Xlinker -rpath 
      -Xlinker @executable_path/Frameworks 
      -Xlinker -object_path_lto 
      -Xlinker _BUILD_DIR/sphb_lto.o 
      -Xlinker -export_dynamic 
      -Xlinker -no_deduplicate 
      -fembed-bitcode-marker 
      -fobjc-arc 
      -fobjc-link-runtime 
      -ObjC 
      -lz 
      -framework Foundation 
      -framework TesseractOCR 
      -framework UIKit 
      -ObjC 
      -lc++ 
      -framework JavaScriptCore 
      _PRODUCTS_DIR/libRCTBlob.a 
      _PRODUCTS_DIR/libRCTAnimation.a 
      _PRODUCTS_DIR/libReact.a 
      _PRODUCTS_DIR/libRCTActionSheet.a 
      _PRODUCTS_DIR/libRCTGeolocation.a 
      _PRODUCTS_DIR/libRCTImage.a 
      _PRODUCTS_DIR/libRCTLinking.a 
      _PRODUCTS_DIR/libRCTNetwork.a 
      _PRODUCTS_DIR/libRCTSettings.a 
      _PRODUCTS_DIR/libRCTText.a 
      _PRODUCTS_DIR/libRCTVibration.a 
      _PRODUCTS_DIR/libRCTWebSocket.a 
      -framework Pods_sphb 
      _PRODUCTS_DIR/libRNTextDetector.a 
      -Xlinker -dependency_info 
      -Xlinker _BUILD_DIR/sphb_dependency_info.dat 
      -o _PRODUCTS_DIR/sphb.app/sphb

ld: warning: directory not found for option '-F_PRODUCTS_DIR/TesseractOCRiOS'
ld: framework not found TesseractOCR
clang: error: linker command failed with exit code 1 (use -v to see invocation) -->