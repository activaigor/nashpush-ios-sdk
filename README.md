# NashPush

## Setup SDK

To integrate NashPush into your Xcode project using Swift Package Manager, add it to the dependencies value of your Package.swift:
```swift
dependencies: [
    .package(url: "https://github.com/activaigor/nashpush-ios-sdk.git")
]
```

## Usage
### Quick start

```swift
import NashPush

...

Push.appKey = "Channel-Token"
Push.register()
```

## Handle push notifications in background

To enable handling notifications in background you have to add `AppGroup` and enable `Background fetch` and `Remote notifications` Background Modes
