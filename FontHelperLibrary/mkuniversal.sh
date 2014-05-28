# see: stackoverflow.com/questions/4654534/
XCBUILD="xcodebuild -target ${PROJECT}Library -configuration ${CONFIGURATION}"

$XCBUILD -sdk iphoneos  \
    ONLY_ACTIVE_ARCH=NO \
    BUILD_DIR="${BUILD_DIR}" \
    BUILD_ROOT="${BUILD_ROOT}"

$XCBUILD -sdk iphonesimulator -arch i386 \
    BUILD_DIR="${BUILD_DIR}" \
    BUILD_ROOT="${BUILD_ROOT}"

OUT="${BUILD_DIR}/${CONFIGURATION}-universal"
mkdir -p "${OUT}"
LIB="lib${PROJECT}.a"
BUILD_CONF="${BUILD_DIR}/${CONFIGURATION}"
lipo -create -output "${OUT}/${LIB}" \
    "${BUILD_CONF}-iphoneos/${LIB}"  \
    "${BUILD_CONF}-iphonesimulator/${LIB}"

cp -R "${BUILD_CONF}-iphoneos/include" "${OUT}/"
