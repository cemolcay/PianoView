PianoView
===

Fully custumisable piano keyboard view with `@IBDesignable` properties in swift.

![alt tag](https://github.com/cemolcay/PianoView/blob/master/demo.png?raw=true)

Requirements
----

* Swift 3+
* iOS 8.0+
* tvOS 9.0+
* macOS 10.9+

Install
----

```
pod 'PianoView'
```

You need to add this post installer script to your podfile in order to use @IBDesignable libraries with pods.     
More information on this [cocoapods issue](https://github.com/CocoaPods/CocoaPods/issues/5334)

```
post_install do |installer|
installer.pods_project.build_configurations.each do |config|
config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = ['$(FRAMEWORK_SEARCH_PATHS)']
end
end
```

Usage
----

* PianoView is just a regular UIView.  
* Either setup inside storyboard or initilize from code.
* Draws desired key count in its view rectangle.
* Could be draw notes on keys with or without octaves.
* You could use octave to show pressed note in physical device.
