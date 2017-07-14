<p>
<a href="http://cocoadocs.org/docsets/AppClip"><img src="https://img.shields.io/cocoapods/v/AppClip.svg?style=flat"></a>
<a href="https://github.com/Carthage/Carthage/"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"></a>
</p>

# AppClip

Create Web Clip for App.

## Usage

As the demo IcePack shows:

1. Define a URL Scheme in Info.plist of your app

    ``` xml
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleURLName</key>
            <string>com.nixWork.IcePack</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>icepack</string>
            </array>
        </dict>
    </array>
    ```

2. Create AppClip for a specific URL Scheme

    ``` swift
    @IBAction func createAppClip(_ sender: UIButton) {
        AppClip.create(title: "First View", icon: #imageLiteral(resourceName: "icon_circle"), urlScheme: "icepack://com.nixWork.IcePack/tab1")
    }
    ```

3. Handle open URL

    ``` swift
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        guard let tabVC = window?.rootViewController as? UITabBarController else { return false }
        switch url.lastPathComponent {
        case "tab1":
            tabVC.selectedIndex = 0
        case "tab2":
            tabVC.selectedIndex = 1
        default:
            break
        }
        return true
    }
    ```

It's done!

## Implementation

When user tap the button in your app to perform the action `createAppClip(_:)`, AppClip will start a HTTP server, then open Safari to send a HTTP request.

The server will respond a 301 redirection, but the location is a data url.

This data url show a web page, and guide user to add it to the Home Screen.

When user tap the web clip in Home Screen, the JavaScript Code in it will perform to request the URL Scheme, it will open your app.

## Installation

### Carthage

``` ogdl
github "nixzhu/AppClip"
```

### CocoaPods

``` ruby
pod 'AppClip'
```

## Contact

NIX [@nixzhu](https://twitter.com/nixzhu)

## License

AppClip is available under the MIT license. See the LICENSE file for more info.

