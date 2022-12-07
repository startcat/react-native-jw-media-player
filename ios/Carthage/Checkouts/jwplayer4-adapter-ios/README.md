# YouboraJWPlayerAdapter #

A framework that will collect several video events from the JWPlayer and send it to the back end.

# Installation #

#### CocoaPods ####

Insert this pod to your target

```bash
pod 'YouboraJWPlayer4Adapter'
```

Then run the command

```bash
pod install
```

#### Carthage ####

Create your Cartfile and insert 

```bash
git "https://bitbucket.org/npaw/jwplayer4-adapter-ios.git"
```

Then run the command

```bash
carthage update --use-xcframeworks
```

Go to **{YOUR_SCHEME} > Build Settings > Framework Search Paths** and add **\$(PROJECT_DIR)/Carthage/Build**

## How to use ##

### Start plugin and options ###

```swift
// Import
import YouboraLib

...

// Config Options and init plugin (do it just once for each play session)

let options = YBOptions()
options.contentResource = "http://example.com"
options.accountCode = "accountCode"
options.adResource = "http://example.com"
options.contentIsLive = NSNumber(value: false)
    
var plugin = YBPlugin(options: options)
```

For more information about the options you can check [here](https://documentation.npaw.com/npaw-integration/docs/setting-options-and-metadata)

### YBJWPlayerAdapter & YBJWPlayerAdsAdapter ###

```swift
import YouboraJWPlayer4Adapter
...

// Once you have your player and plugin initialized you can set the adapter
plugin.adapter = YBJWPlayerAdapter(player: player)

...

// If you want to setup the ads adapter as well
plugin.adsAdapter = YBJWPlayerAdsAdapter(player: player)

...

// When the view is going to be destroyed you can force stop and clean the adapters in order to make sure you avoid retain cycles  
plugin.fireStop()
plugin.removeAdapter()
plugin.removeAdsAdapter()
```

## Run samples project ##

###### Via cocoapods ######

Navigate to Example folder and execute: 

```bash
pod install
```
