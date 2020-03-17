# NetLaBand

Network Latency and Bandwidth tool

Connects to one or more remote sites to validate the connectivity, reviewing
and displaying visual metrics for network latency and bandwidth to those sites.

## Project Setup

build uses two secondary tools (optional really): swiftformat and swiftlint

    brew install swiftlint
    brew install swiftformat

## Command Line Building

view all the settings:

    xcodebuild -showBuildSettings

view the schemes and targets:

    xcodebuild -list

schemes:

- `netlaband` - macOS
- `CoffeeshopNetworkAdvisor` - iOS

do a build:

    #mac
    xcodebuild clean build -scheme 'netlaband' -destination 'plaform=macOS' -showBuildTimingSummary
    #ios
    xcodebuild clean build -scheme 'CoffeeshopNetworkAdvisor' -destination 'platform=iOS Simulator,OS=13.3,name=iPhone 8' -showBuildTimingSummary

run the tests:

    #mac
    xcodebuild test -scheme 'netlaband' -destination 'plaform=macOS' -showBuildTimingSummary -enableCodeCoverage YES
    #ios
    xcodebuild test -scheme 'CoffeeshopNetworkAdvisor' \
    -destination 'platform=iOS Simulator,OS=13.3,name=iPhone 8' \
    -showBuildTimingSummary -enableCodeCoverage YES



