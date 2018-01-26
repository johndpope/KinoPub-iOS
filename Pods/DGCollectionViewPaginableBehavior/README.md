DGCollectionViewPaginableBehavior
=================================

[![Build Status](https://travis-ci.org/Digipolitan/collection-view-paginable-behavior-swift.svg?branch=master)](https://travis-ci.org/Digipolitan/collection-view-grid-layout-swift)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/DGCollectionViewPaginableBehavior.svg)](https://img.shields.io/cocoapods/v/DGCollectionViewPaginableBehavior.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/DGCollectionViewPaginableBehavior.svg?style=flat)](http://cocoadocs.org/docsets/DGCollectionViewPaginableBehavior)
[![Twitter](https://img.shields.io/badge/twitter-@Digipolitan-blue.svg?style=flat)](http://twitter.com/Digipolitan)

The `PaginableBehavior` is a partial implentation of a `UICollectionViewDelegateFlowLayout` that allows you to paginate your collection of data with only few lines of code.

![Demo](https://github.com/Digipolitan/collection-view-paginable-behavior-swift/blob/develop/Screenshots/capture.gif?raw=true "Demo")

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

Works with iOS 8+, tested on Xcode 8.2

### Installing

To install the `DGCollectionViewPaginableBehavior` using **cocoapods**

- Add an entry in your Podfile  

```
# Uncomment this line to define a global platform for your project
platform :ios, '8.0'

target 'YourTarget' do
  frameworks
   use_frameworks!

  # Pods for YourTarget
  pod 'DGCollectionViewPaginableBehavior'
end
```

- Then install the dependency with the `pod install` command.

## Usage

Initialize your behavior

```swift
	let behavior = DGCollectionViewPaginableBehavior()
```

### Configuration

You can customize the component by enabling few options:

```swift
    var options = DGCollectionViewPaginableBehavior.Options(automaticFetch: false)
    options.countPerPage = 20 		// default value used for all section, avoiding to implement the delegate
    options.animatedUpdates = true	// defines if the method reloadSections will be used after fetching the data
    behavior.options = options
```

### Interacting with the component

To communicate with the PaginableBehavior, set its `delegate`. Then put the behavior as the delegate of your `CollectionView`.

```swift
behavior.delegate = self
self.collectionView.delegate = behavior
```

Since the `DGCollectionViewPaginableBehavior` inherits from `UICollectionViewDelegateFlowLayout` you can implement the methods of `UICollectionViewDelegate` to respond to interactions with the `collectionView`.
 Implements `UICollectionViewDelegateFlowLayout` for sizing information and finally
the `DGCollectionViewPaginableBehavior`, as you imagine, to adopt a paginable behavior.

- DGCollectionViewPaginableBehaviorDelegate

```swift
	/**
	* Gives the number of items to fetch for a given section.
	*/
	@objc optional func paginableBehavior(_ paginableBehavior: DGCollectionViewPaginableBehavior, countPerPageInSection section: Int) -> Int
	/**
	* Core methods that will be called every time the user reach the end of the collection. Depending on the mode set for automatic fetch.
	*/
	@objc optional func paginableBehavior(_ paginableBehavior: DGCollectionViewPaginableBehavior, fetchDataFrom indexPath: IndexPath, count: Int, completion: @escaping (Error?, Int) -> Void)
```

## Work with custom layout

You might want to use custom layout. If so, extend the behavior of the Paginable component. Here an example with our custom layout [DGCollectionViewGridLayout](https://github.com/Digipolitan/collection-view-grid-layout-swift)

```swift
/**
Since the Paginable behavior is a partial implementation of UICollecitonViewDelegate,
It's the direct instance interacting with the collection View.
If your custom layout needs a delegate with specific methods, just extend the behavior of the Paginable component.
**/
extension DGCollectionViewPaginableBehavior: DGCollectionGridLayoutDelegate {
	public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: DGCollectionViewGridLayout, heightForItemAt indexPath: IndexPath, columnWidth: CGFloat) -> CGFloat {
		return 90
	}

	public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: DGCollectionViewGridLayout, heightForHeaderIn section: Int) -> CGFloat {
		return 42
	}

	public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: DGCollectionViewGridLayout, heightForFooterIn section: Int) -> CGFloat {
		return 90
	}
}
```

## Built With

[Fastlane](https://fastlane.tools/)
Fastlane is a tool for iOS, Mac, and Android developers to automate tedious tasks like generating screenshots, dealing with provisioning profiles, and releasing your application.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for more details!

This project adheres to the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md).
By participating, you are expected to uphold this code. Please report
unacceptable behavior to [contact@digipolitan.com](mailto:contact@digipolitan.com).

## License

DGCollectionViewPaginableBehavior is licensed under the [BSD 3-Clause license](LICENSE).
