# Paralayout

[![CI Status](https://img.shields.io/github/actions/workflow/status/square/paralayout/ci.yml?branch=master)](https://github.com/square/paralayout/actions?query=workflow%3ACI+branch%3Amaster)
[![Carthage Compatibility](https://img.shields.io/badge/carthage-✓-e2c245.svg)](https://github.com/Carthage/Carthage/)
[![Version](https://img.shields.io/cocoapods/v/Paralayout.svg)](http://cocoadocs.org/docsets/Paralayout)
[![License](https://img.shields.io/cocoapods/l/Paralayout.svg)](http://cocoadocs.org/docsets/Paralayout)
[![Platform](https://img.shields.io/cocoapods/p/Paralayout.svg)](http://cocoadocs.org/docsets/Paralayout)

Paralayout is a set of simple, useful, and straightforward utilities that enable pixel-perfect layout in iOS. Your designers will love you.


## Getting Started

<details>
<summary>CocoaPods</summary>

To install Paralayout via [CocoaPods](http://cocoapods.org), add the following to your `Podfile`:

```ruby
pod 'Paralayout'
```
</details>

<details>
<summary>Swift Package Manager</summary>

To install Paralayout via [Swift Package Manager](https://swift.org/package-manager/), add the following to your `Package.swift`:

```swift
dependencies: [
    .package(name: "Paralayout", url: "https://github.com/square/Paralayout.git", from: "2.0.0"),
]
```
</details>

<details>
<summary>Bazel</summary>

To install Paralayout via [Bazel](https://github.com/bazelbuild/bazel), add the following to your `MODULE.bazel`:

```starlark
bazel_dep(name = "paralayout", version = "2.0.0")
```
</details>

<details>
<summary>Carthage</summary>

To install Paralayout via [Carthage](https://github.com/Carthage/Carthage), add the following to your `Cartfile`:

```ogdl
github "Square/Paralayout"
```
</details>


## Usage

Paralayout is a set of *à la carte* utilities, of which you can use as much or as little functionality as you like.

### View Sizing

The first basic set of layout utilities is around sizing views. Paralayout extends `UIView.sizeThatFits(_:)` and `UIView.sizeToFit()` to include constraints, which gives you more control over how your subviews are sized.

For example, say you have a header bar you want to always be the full width of your container view, but use its ideal height (its `sizeThatFits(_:)`) clamped to the height of the container. You can easily achieve this in a single method call by combining the `.fixedWidth` and `.maxHeight` constraints.

```swift
headerBar.sizeToFit(
    bounds.size,
    constraints: [.fixedWidth, .maxHeight]
)
```

### View Alignment

Once you have your subviews sized, the next basic action you often take is aligning your subviews. Paralayout provides a powerful set of alignment methods to align one view to another.

For example, you'll commonly want to align one subview to another subview with a certain amount of spacing between them. Let's say we want our first subview to be 16 pt beneath our second subview.

```swift
firstSubview.align(
    .topCenter,
    with: secondSubview,
    .bottomCenter,
    verticalOffset: 16
)
```

Alignments are automatically snapped to the nearest pixel, saving you from fuzzy edges on your views due to bad layout math.

There are also conveniences for aligning views to their superview, one of the most common alignment scenarios. For example, we can center a subview in our superview using this simple call:

```swift
someSubview.align(withSuperview: .center)
```

Paralayout also supports more complex alignment concepts for specialized use cases, such as aligning a label by its first line of text.

```swift
label.firstLineAlignmentProxy.align(
    .leftCenter,
    with: icon,
    .rightCenter,
    horizontalOffset: 8
)
```

### View Distribution

In addition to simplifying the math for sizing and aligning views, Paralayout also builds layout abstractions on top of these simple concepts. View distribution solves the very common scenario of distributing views across a view, on either the vertical or horizontal axis.

For example, we can distribute a series of views within a container view. Here we'll put 16 pt of space between each subview and distribute any additional space equally above and below the subviews.

```swift
containerView.applyVerticalSubviewDistribution(
    [
        1.flexible,
        titleLabel,
        16.fixed,
        bodyLabel,
        16.fixed,
        actionButton,
        1.flexible,
    ]
)
```

### AspectRatio

Working with aspect ratios has traditionally involved some easy-to-mess-up math, but Paralayout's `AspectRatio` type makes it a breeze. Create an aspect ratio from any size, rect, or width/height value, and use it to compute pixel-snapped frame rectangles.

```swift
videoPlayer.frame = AspectRatio.widescreen.rect(toFit: bounds, at: .topCenter, in: view)
```

### Interpolations

Get the math right for multi-phase layout transitions and animations without tearing your hair out! Under the hood, Paralayout's `Interpolation` type is simply a value between 0 and 1, but it makes computing that value, and deriving a new value from it, effortless.

```swift
// Determine how far we are into the transition of collapsing the header.
let headerCollapseAmount = Interpolation(of: header.bounds.height, from: maxHeaderHeight, to: minHeaderHeight)

// The icon shrinks to half its usual size...
let avatarSize = headerCollapseAmount.interpolate(from: 80, to: 40)
avatar.bounds.size = CGSize(width: avatarSize, height: avatarSize)

// ...as it completely fades out.
avatar.alpha = headerCollapseAmount.interpolate(from: 1, to: 0)
```

### UIFont Extensions

The extra space within a label above the "cap height" and below the "baseline" of its font is deterministic but non-obvious, especially at different scale factors. The simple `LabelCapInsets` value type encapsulates that logic.


## Requirements

* iOS 13.0 or later
* Xcode 15.0 or later
* Swift 5.9


## Contributing

We’re glad you’re interested in Paralayout, and we’d love to see where you take it. Please read our [contributing guidelines](Contributing.md) prior to submitting a pull request.
