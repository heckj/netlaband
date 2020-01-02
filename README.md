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

view destinations:

    xcodebuild -scheme netlaband -showdestinations

do a build:

    # xcodebuild -scheme netlaband -sdk iphoneos13.2 -configuration Debug
    # xcodebuild -scheme netlaband -sdk iphoneos13.2 -configuration Release
    xcodebuild -scheme netlaband

run the tests:

    # xcodebuild clean test -scheme netlaband -sdk iphoneos13.2 -destination 'platform=iOS Simulator,OS=13.3,name=iPhone 8'
    xcodebuild clean test -scheme netlaband
