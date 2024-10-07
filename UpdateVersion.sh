cd $SRCROOT

if [ ! -f 'Version.xcconfig' ]; then
    cp 'VersionTemplate.txt' 'Version.xcconfig'
fi

# Get the last tag
# dirty versions have + appended to them, which App Store Connect will prevent from being deployed
VERSION=$(git describe --tags --always --abbrev=0 --dirty=+ | cut -c2-)

BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [ $BRANCH != "master" ]; then
    VERSION="$VERSION-$BRANCH"
fi

TOTAL_COMMITS=$(git rev-list --count HEAD)

sed -i '' "s/\(MARKETING_VERSION = \)[^ ]*/\1$VERSION/" 'Version.xcconfig'
sed -i '' "s/\(CURRENT_PROJECT_VERSION = \)[^ ]*/\1$TOTAL_COMMITS/" 'Version.xcconfig'

