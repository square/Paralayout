# Paralayout

[![CI Status](https://img.shields.io/github/workflow/status/square/paralayout/CI/master)](https://github.com/square/paralayout/actions?query=workflow%3ACI+branch%3Amaster)
[![Carthage Compatibility](https://img.shields.io/badge/carthage-✓-e2c245.svg)](https://github.com/Carthage/Carthage/)
[![Version](https://img.shields.io/cocoapods/v/Paralayout.svg)](http://cocoadocs.org/docsets/Paralayout)
[![License](https://img.shields.io/cocoapods/l/Paralayout.svg)](http://cocoadocs.org/docsets/Paralayout)
[![Platform](https://img.shields.io/cocoapods/p/Paralayout.svg)](http://cocoadocs.org/docsets/Paralayout)

Paralayout is a set of simple, useful, and straightforward utilities that enable pixel-perfect layout in iOS. Your designers will love you.


## Getting Started

### CocoaPods

Integrating Paralayout into your iOS project via [CocoaPods](http://cocoapods.org) is simple:

```ruby
pod 'Paralayout'
```

### Swift Package Manager

Installing Paralayout via [Swift Package Manager](https://swift.org/package-manager/) by adding the following to your `Package.swift`:

```swift
dependencies: [
    .package(name: "Paralayout", url: "https://github.com/square/Paralayout.git", from: "1.0.0"),
]
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate Paralayout into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "Square/Paralayout"
```

Run `carthage` to build the framework and drag the built `Paralayout.framework` into your Xcode project.

### Submodules

Or, manually check out the submodule with `git submodule add git@github.com:Square/Paralayout.git`, drag Paralayout.xcodeproj to your workspace, and add Paralayout as a build dependency.

---

## Usage

Paralayout is a set of *à la carte* utilities, of which you can use as much or as little functionality as you like.


#### UILabel Subclass: Label

The `Label` class makes text look its best, and takes less cumbersome code to configure:
* Style text without directly interacting with `NSAttributedString` or `NSParagraphStyle` (any more than you want to)
* Get "compact" line wrapping that makes it unnecessary to introduce artificial line breaks into your copy
* Hyperlinks are tappable (no need to use a `UITextView`)


#### UIView Subclass: Hairline

A `Hairline` will size itself correctly on any screen resolution, and provides conveniences for positioning within its superview.

```swift
/// Put a line at the bottom of the view, inset 20 points on each side.
let separator = Hairline.new(in: view, at: .maxYEdge, inset: 20)
```

#### New Value Type: Interpolation

Get the math right for multi-phase layout transitions and animations without tearing your hair out! Under the hood it’s simply a value between 0 and 1, but it makes computing that value, and deriving a new value from it, effortless.

```swift
// Determine how far we are into the transition of collapsing the header.
let headerCollapseAmount = Interpolation(of: header.frame.height, from: maxHeaderHeight, to: minHeaderHeight)

// The icon shrinks to half its usual size...
let avatarSize = headerCollapseAmount.interpolate(from: 80, to: 40)
avatar.frame.size = CGSize(width: avatarSize, height: avatarSize)

// ...as it completely fades out.
avatar.alpha = headerCollapseAmount.interpolate(from: 1, to: 0)
```

#### New Value Type: AspectRatio

Create an aspect ratio from any size, rect, or width/height value, and use it to compute pixel-snapped frame rectangles.

```swift
videoPlayer.frame = AspectRatio.widescreen.rect(toFit: bounds, at: .topCenter, in: view)
```

#### CGGeometry Extensions

These extensions provide numerous conveniences for computing rectangles and snapping coordinates to pixel dimensions. The `ScaleFactorProviding` protocol encapsulates the latter, allowing a view to provide the context necessary to align its subviews to pixels. One benefit of this approach is that unit tests can cover both 2x and 3x scale factors regardless of the simulator used to run the test.

#### UIFont Extensions

The extra space within a label above the "cap height" and below the "baseline" of its font is deterministic but non-obvious, especially at different scale factors. The simple `LabelCapInsets` value type encapsulates that logic.

#### UIView Alignment Extensions

The core positioning function (and its numerous derived convenience functions) allows one view to be positioned relative to another view:

```swift
titleLabel.align(.leftCenter, with: icon, .rightCenter, horizontalOffset: 8)
icon.alignToSuperview(.topCenter, inset: 20)
```

#### UIView Sizing Extensions

These methods extend `UIView.sizeThatFits(:)` and `UIView.sizeToFit()` to include constraints, which is particularly useful for labels and other views whose width and height are related to each other.

```swift
let labelSize = label.frameSize(thatFits: bounds.insetBy(dx: 20, dy: 20).size, constraints: [ .fixedWidth, .maxHeight ])
titleLabel.wrap(toFitWidth: boundsWidth, margins: 20)
```

#### UIView Distribution Extensions

Distribute a set of views vertically or horizontally using fixed and/or proportional spacing between them:

```swift
/// Vertically stack an icon, header, and button, with twice as much space at the bottom as the top.
selectionScreen.applySubviewDistribution([ 1.flexible, headerIcon, 8.fixed, headerLabel, 1.flexible, button, 2.flexible])

/// Left-align a pair of labels, one above the other, with equal space above the title and below the subtext (despite the subtext being a smaller font).
cell.applySubviewDistribution([ 1.flexible, titleLabel, 8.fixed, subtextLabel, 1.flexible ], alignment: .leading(inset: 10))

/// Adjust a "standard" distribution to filter out invisible views (hidden, alpha=0, uninstalled, or empty UILabels), and collapse adjacent spacers.
let distribution = ViewDistributionItem.collapsing(
    1.flexible,
    iconFPOView,
    Metrics.iconMargin.fixed,
    
    Metrics.titleTextMargin.fixed,
    titleLabel,
    Metrics.titleTextMargin.fixed,
    
    Metrics.subtextMargin.fixed,
    subtextLabel,
    1.flexible)

/// Equally size a pair of buttons with a hairline divider between them, and size/position them at the bottom of the alert.
alert.spreadOutSubviews([ cancelButton, acceptButton ], axis: .horizontal, margin: alert.hairlineWidth, inRect: alert.bounds.slice(from: .maxYEdge, amount: buttonHeight))
```

#### Debugging

Fixing layout issues is as simple as using the Xcode debugger. Remember that on a 2x device, view frame coordinates will be snapped to half-point boundaries (`x.0` and `x.5` only), while on 3x devices they are on 1/3-point boundaries (`x.0`, `x.333`, and `x.667`). The offsets used for view alignment do *not* need to be rounded (and generally shouldn’t be, to avoid accumulating rounding error), but view *sizes* should be.

---

## Requirements

* iOS 12.0 or later
* Xcode 10.0 or later
* Swift 5.0


## Contributing

We’re glad you’re interested in Paralayout, and we’d love to see where you take it. Please read our [contributing guidelines](Contributing.md) prior to submitting a pull request.
