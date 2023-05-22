#!/bin/bash -l
set -ex

sudo mkdir -p /Library/Developer/CoreSimulator/Profiles/Runtimes

case $1 in
	iOS_12)
		sudo ln -s /Applications/Xcode_10.3.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Library/CoreSimulator/Profiles/Runtimes/iOS.simruntime /Library/Developer/CoreSimulator/Profiles/Runtimes/iOS\ 12.4.simruntime
		;;

	iOS_13)
		sudo ln -s /Applications/Xcode_11.7.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime /Library/Developer/CoreSimulator/Profiles/Runtimes/iOS\ 13.7.simruntime
		;;

	iOS_14)
		sudo ln -s /Applications/Xcode_12.4.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime /Library/Developer/CoreSimulator/Profiles/Runtimes/iOS\ 14.4.simruntime
		;;

	iOS_15)
		sudo ln -s /Applications/Xcode_13.4.1.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime /Library/Developer/CoreSimulator/Profiles/Runtimes/iOS\ 15.5.simruntime
		;;
esac

xcrun simctl list runtimes
