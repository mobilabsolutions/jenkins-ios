#!/bin/bash

set -e;

REAL_TEST_DEVICE="model=iphonex,version=12.0,locale=en_US,orientation=portrait"

echo "Writing Google Info Plist";
echo "${GOOGLE_INFO_PLIST}" | base64 -D -o JenkinsiOS/Other/Resources/GoogleService-Info.plist;

mkdir fastlane/Certificates;
touch fastlane/Certificates/distribution.p12;
touch fastlane/Certificates/distribution_base64;
touch fastlane/Certificates/development.p12;
touch fastlane/Certificates/development_base64;

echo "${CERTIFICATE}" > fastlane/Certificates/distribution_base64;
echo "${DEVELOPMENT_CERTIFICATE}" > fastlane/Certificates/development_base64;

base64 -D fastlane/Certificates/distribution_base64 -o fastlane/Certificates/distribution.p12;
base64 -D fastlane/Certificates/development_base64 -o fastlane/Certificates/development.p12;

echo "Starting Test run";
fastlane test;

firebase_test_lab() {
    if [ ! -d ${HOME}/google-cloud-sdk ]; then
        curl https://sdk.cloud.google.com | bash;
    fi

    touch service-key.json;
    touch JenkinsiOS/Other/Resources/GoogleService-Info.plist;
    echo "${FIREBASE_KEY}" | base64 -D -o service-key.json;

    source ${HOME}/google-cloud-sdk/path.bash.inc;
    gcloud auth activate-service-account --key-file service-key.json;

    xcodebuild -workspace ./JenkinsiOS.xcworkspace -scheme JenkinsiOSTests -derivedDataPath ./tests -sdk iphoneos build-for-testing;
    (cd tests/Build/Products && zip -r ../../../tests.zip Debug-iphoneos *.xctestrun);
    gcloud firebase test ios run --test tests.zip --device ${REAL_TEST_DEVICE};
    rm -rf ./tests ./tests.zip;
}

if [ $? -eq 0 ]; then
    echo "Testing succeeded. Next steps will be taken";

    OPERATION_RESULT=0;

    if [ ! -z "${TRAVIS_TAG}" ]; then
        echo "Will release application to iTunes Connect";
        fastlane release;
	    let OPERATION_RESULT="$?";
    elif [ "$TRAVIS_PULL_REQUEST" = 'false' ] && [ "$TRAVIS_BRANCH" = 'master' ]; then
        echo "Testing on Firebase Test Lab"
        firebase_test_lab
        echo "Will distribute application to Beta";
        fastlane beta;
        let OPERATION_RESULT="$?";
    fi

    echo "Removing certificate folder";
    rm -rf fastlane/Certificates;

    echo "Operation result: $OPERATION_RESULT";

    if [ "$OPERATION_RESULT" -ne "0" ]; then
	echo "An error occurred while distributing!";
	exit 1;
    fi

else
    echo "An error occurred while testing; Will not go further";
    exit 1;
fi
