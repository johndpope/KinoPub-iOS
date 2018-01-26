# NTDownload

<p align="center">
<a href="https://github.com/ntian2/NTDownload/"><img src="https://img.shields.io/cocoapods/v/NTDownload.svg?style=flat"></a>
<a href="https://raw.githubusercontent.com/ntian2/NTDownload/master/LICENSE"><img src="https://img.shields.io/cocoapods/l/NTDownload.svg?style=flat"></a>
<a href="https://github.com/ntian2/NTDownload/"><img src="https://img.shields.io/cocoapods/p/NTDownload.svg?style=flat"></a>
<a href="https://github.com/ntian2/NTDownload/"><img src="https://img.shields.io/badge/Swift-4.0%2B-orange.svg"></a>
<a href="https://github.com/ntian2/NTDownload/blob/master/README.zh-cn.md/"><img src="https://img.shields.io/badge/%E4%B8%AD%E6%96%87-README-blue.svg?style=flat"></a>
</p>


NTDownlaod is a lightweight Swift 4 library for download files.

## Features
- [x] Support for resume breakpoint 
- [x] Download files when the app is in the background.
- [x] `URLSession` -based networking.
- [x] It can resume or pause any download tasks.
- [x] This library contains only 4 files.

## Requirements
* iOS 8.0+
* Swift 4

## Installation
NTDownlaod is available through Cocoapods. So you can add the following line to your Podfile.

```ruby
pod 'NTDownload'
```

## Usages
```swift
let urlString = "url_of_you_file"
NTDownloadManager.shared.addDownloadTask(urlString: urlString)
```
You can also clone the repo, and run the example project.

## GIF Demo
![GIFDemo](https://github.com/ntian2/NTDownload/raw/master/NTDownload.gif)

## License
NTDownload is released under the MIT license. See LICENSE for details.