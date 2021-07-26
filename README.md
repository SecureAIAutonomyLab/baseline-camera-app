# camera_app


Steps to install.
- Download VSCode. xCode and Android Studio 2019.
- Install Flutter and Dart.
    https://flutter.dev/docs/get-started/install
- Install the flutter plugin in android studio
- Install Git
- Install cocoapods
- Install emulator for android device on Visual Studio (for emulator testing).
- Install ios device emulator on xcode.
NOTE: Camera does not work on ios emulator. Emulator does not have that capability.
- Check Flutter doctor to make sure everything is installed.
- Running it on a physical device (ios)
    https://flutter.dev/docs/get-started/install/macos
    https://www.youtube.com/watch?v=Jn7o4Gy3F7Q&t=197s
- "pod install" in the ios directory.
- If "pod install" does not work delete Podfile and Podfile.lock from ios folder and run "flutter build ios" in project folder 
- Install amplify cli
    "curl -sL https://aws-amplify.github.io/amplify-cli/install | bash && $SHELL"

- Submit to app store
    https://www.youtube.com/watch?v=YPLs3xrDcm0


Steps to Connect to another backend.
- Run "amplify delete" to remove all connections with current backend
- Setup new backend on AWS
- Install API, DataStore, and Auth in that order
- Auth should be installed last

To run and build on a device: Android
- run "flutter pub get" in the root directory to get all the necessary dependencies 
- Copy the amplify configuration file from the lib folder on the current machine and put it on the new machine
- run "flutter run" to build the debug version for the connected device
    You can run "flutter run --release" to build the release version of the app on the connected device
- Alternatively you can run inside android studio by clicking the play button in the top bar 
- You can use features such as hot reloading when running the app on a device. Cmd + s will save any changes 
    you made and reload the app display without having to rerun the app.
    
To run and build on a device: Iphone
- run "flutter pub get" in the root directory to get all the necessary dependencies 
- Copy the amplify configuration file from the lib folder on the current machine and put it on the new machine
- Right click your project in Android studio and go to Flutter->Open IOS Module in Xcode
- Go to Runner->Targets->Signing and Capabilities and choose a developer account
    If you don't have one, an account by signing in with your apple ID. Then go to manage certificates and add 
    a developer certificate
- Create a unique bundle ID
- Run the app through Xcode first to make sure everything is working, then you can run it throuhg Android Studio
- You can use features such as hot reloading when running the app on a device. Cmd + s will save any changes 
    you made and reload the app display without having to rerun the app.
 
To build a release for the IOS app store
- See https://flutter.dev/docs/deployment/ios for in depth documentation about submitting to the appstore
- Open project in xcode 
- Check modify the version number/build number for the release in Runner->Targets->General
- In Signining and Capabilities, make sure your development team is selected
- Go to Product->Archive, this will build the file for app store connect

To build a release for the google play store
- See https://flutter.dev/docs/deployment/android for in depth documentation about submitting to the google play store
- Commit project to github repository 
- Go to release workstation and pull the changes
- run "flutter build appbundle" this creates the bundle file
    The keystore file for signing should already be on both machines. On the macbook it is located in the home folder
    If you want to build the release on a new machine you need to transfer this keystore file to that machine.
    Then configure the location of that file in the key.properties. See "Reference the keystore from the app" in the flutter documentation
- Sign into the google play console with the lab account and choose the app
- Go to the production tab and choose create new release
- Upload the bundle file from [project]/build/app/outputs/bundle/release/app.aab
- Submit the release

Troubleshooting : Error when building ios in Xcode
If you're sure you followed the steps correctly you may need to clean your workspace
- Run "flutter clean"

Troubleshooting: Iproxy cannot be verified
- Navigate to the directory containing the flutter SDK
- Run "sudo xattr -d com.apple.quarantine flutter/bin/cache/artifacts/usbmuxd/iproxy"
