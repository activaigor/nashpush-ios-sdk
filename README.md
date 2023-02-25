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
