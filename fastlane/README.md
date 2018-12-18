fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios test
```
fastlane ios test
```
Runs all the tests
### ios abc
```
fastlane ios abc
```

### ios build_for_test_lab
```
fastlane ios build_for_test_lab
```
Build for testing on Firebase test lab
### ios beta
```
fastlane ios beta
```
This will also make sure the profile is up to date
### ios release
```
fastlane ios release
```
Deploy a new version to the App Store
### ios documentation
```
fastlane ios documentation
```

### ios prepare_distribution
```
fastlane ios prepare_distribution
```
Prepares the build for distribution

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
