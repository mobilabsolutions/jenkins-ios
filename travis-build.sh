#!/bin/bash
fastlane test;

if [ $? -eq 0 ]; then

    mkdir fastlane/Certificates;
    touch fastlane/Certificates/distribution.p12;
    touch fastlane/Certificates/distribution_base64;

    echo "${CERTIFICATE}" > fastlane/Certificates/distribution_base64;

    base64 -D fastlane/Certificates/distribution_base64 -o fastlane/Certificates/distribution.p12;

    echo "Testing succeeded. Next steps will be taken";

    if [ ! -z "${TRAVIS_TAG}" ]; then
        echo "Will release application to iTunes Connect";
        fastlane release;
    elif [ "$TRAVIS_PULL_REQUEST" = 'false' ] && [ "$TRAVIS_BRANCH" = 'master' ]; then
        echo "Will distribute application to Beta";
        fastlane beta;
    fi

    OPERATION_RESULT = $?

    echo "Removing certificate folder";
    rm -rf fastlane/Certificates;

    if [ $OPERATION_RESULT -ne 0 ]; then
	echo "An error occurred while distributing!";
	exit 1;
    fi	

else
    echo "An error occurred while testing; Will not go further";
    exit 1;
fi
