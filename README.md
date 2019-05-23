
# react-native-pinch-zoom-image

## Getting started

`$ npm install react-native-pinch-zoom-image --save`

### Mostly automatic installation

`$ react-native link react-native-pinch-zoom-image`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-pinch-zoom-image` and add `RNPinchZoomImage.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNPinchZoomImage.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import info.moonjava.RNPinchZoomImagePackage;` to the imports at the top of the file
  - Add `new RNPinchZoomImagePackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-pinch-zoom-image'
  	project(':react-native-pinch-zoom-image').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-pinch-zoom-image/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-pinch-zoom-image')
  	```

#### Windows
[Read it! :D](https://github.com/ReactWindows/react-native)

1. In Visual Studio add the `RNPinchZoomImage.sln` in `node_modules/react-native-pinch-zoom-image/windows/RNPinchZoomImage.sln` folder to their solution, reference from their app.
2. Open up your `MainPage.cs` app
  - Add `using Pinch.Zoom.Image.RNPinchZoomImage;` to the usings at the top of the file
  - Add `new RNPinchZoomImagePackage()` to the `List<IReactPackage>` returned by the `Packages` method


## Usage
```javascript
import RNPinchZoomImage from 'react-native-pinch-zoom-image';

// TODO: What to do with the module?
RNPinchZoomImage;
```
  