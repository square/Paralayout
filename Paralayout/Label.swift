//
//  Copyright © 2017 Square, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

public protocol LabelDelegate: class {

    /// Called when the user taps a link in the label. This method should handle opening the link in the appropriate
    /// manner.
    func label(_ label: Label, didTapLink url: URL, in range: NSRange)
}

/// This class exists purely to create a valid signature for `openURL` that can be used with #selector.
private class FakeApplication: NSObject {
    @objc func openURL(_ url: URL) -> Bool { return true }
}

/// A UILabel subclass which adds additional functionality. Notably, it adds additional attributes, such as `kerning`
/// and `lineSpacing`, that can tailor the appearance of the label without needing to compose a new `attributedText`
/// each time. It also adds the `lineWrapBehavior` attribute which allows tailoring of the wrapping behavior for the
/// text for improved asthetics.
public final class Label : UILabel {
    
    // MARK: - Public Types
    
    /// A letter case modification (always applied in the current locale).
    /// - Uppercase: make all characters uppercase.
    /// - Lowercase: make all characters lowercase.
    /// - Capitalized: make the first character of each word uppercase.
    public enum LetterCase {
        case uppercase
        case lowercase
        case capitalized
    }
    
    public enum LineWrapBehavior {

        /// Text wrapping is not customized, i.e. lazy word-by-word line wrapping provided by the OS.
        case standard
        
        /// Text wraps to its narrowest width without increasing the height. Newlines in the text are respected.
        case compact

    }
    
    // MARK: - Private Types
    
    private struct Link: Equatable {
        let url: URL
        let range: NSRange
        
        static func ==(lhs: Label.Link, rhs: Label.Link) -> Bool {
            return lhs.url == rhs.url && NSEqualRanges(lhs.range, rhs.range)
        }
    }
    
    // MARK: - Public Properties
    
    public weak var delegate: LabelDelegate? = nil
    
    public var lineWrapBehavior: LineWrapBehavior = .compact {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var kerning: Double = 0 {
        didSet {
            setBaseAttributedTextAttribute(NSAttributedString.Key.kern, value: NSNumber(value: kerning))
            updateAttributedText()
        }
    }
    
    /// The letter case modification to apply, or nil to leave unchanged.
    public var letterCase: LetterCase? = nil {
        didSet {
            updateAttributedText()
        }
    }
    
    // Unfortunately this can't be named `lineSpacing` because `UILabel` has a hidden property of the same name (but an
    // `int`), and overriding it causes issues.
    public var lineSpacingDistance: CGFloat = 0 {
        didSet {
            updateExistingParagraphStyle { $0.lineSpacing = self.lineSpacingDistance }
            updateAttributedText()
        }
    }
    
    private static let defaultLinkTextAttributes = [
        NSAttributedString.Key.underlineStyle: NSNumber(value: NSUnderlineStyle.single.rawValue)
    ]
    
    public var linkTextAttributes: [NSAttributedString.Key : Any] = Label.defaultLinkTextAttributes {
        didSet {
            updateAttributedText()
        }
    }
    
    private static let defaultActiveLinkTextAttributes = [
        NSAttributedString.Key.underlineStyle: NSNumber(value: NSUnderlineStyle.single.rawValue),
        NSAttributedString.Key.backgroundColor: UIColor.black.withAlphaComponent(0.1)
    ]
    
    public var activeLinkTextAttributes: [NSAttributedString.Key : Any] = Label.defaultActiveLinkTextAttributes {
        didSet {
            updateAttributedText()
        }
    }
    
    public var preferredMaximumAspectRatio: CGFloat = 6.0
    
    // MARK: - Private Properties
    
    // Text containers dont quite calculate size properly unless they're offset by >5 pixels.
    private static let magicTextContainerHorizontalOffset: CGFloat = -6
    
    private static let defaultLabel = UILabel()
    
    private var internalAttributedText: NSMutableAttributedString?
    private var internalFont: UIFont = defaultLabel.font
    private var internalTextColor: UIColor = defaultLabel.textColor
    
    private var cachedCompactTextRect: CGRect?
    
    // Links found in the current text.
    private var links = [Link]() {
        didSet {
            isUserInteractionEnabled = !links.isEmpty
            updateAccessibilityElements()
        }
    }
    
    // The link currently being pressed (if any).
    private var activeLink: Link? {
        didSet {
            updateAttributedText()
        }
    }
    
    // MARK: - Life Cycle
    
    // We have to re-declare this init since we override `init?(coder:)`.
    override public init(frame: CGRect = .zero) {
        super.init(frame: frame)
    }
    
    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        // Label doesn't bother to properly encode some of its attributes, so block coding.
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UILabel
    
    override public var text: String? {
        didSet {
            if let text = self.text {
                internalAttributedText = NSMutableAttributedString(string: text)
            } else {
                internalAttributedText = nil
            }
            updateAttributedText()
            updateLinks()
        }
    }
    
    override public var attributedText: NSAttributedString? {
        willSet {
            internalAttributedText = newValue?.mutableCopy() as? NSMutableAttributedString
        }
        didSet {
            updateAttributedText()
            updateLinks()
        }
    }

    override public var font: UIFont! {
        willSet {
            internalFont = newValue ?? Label.defaultLabel.font
        }
        didSet {
            setBaseAttributedTextAttribute(NSAttributedString.Key.font, value: font)
            updateAttributedText()
        }
    }

    override public var textColor: UIColor! {
        willSet {
            internalTextColor = newValue ?? Label.defaultLabel.textColor
        }
        didSet {
            setBaseAttributedTextAttribute(NSAttributedString.Key.foregroundColor, value: textColor)
            updateAttributedText()
        }
    }

    override public var lineBreakMode: NSLineBreakMode {
        didSet {
            updateExistingParagraphStyle { $0.lineBreakMode = self.lineBreakMode }
            updateAttributedText()
        }
    }

    override public var numberOfLines: Int {
        didSet {
            clearCachedMetrics()
        }
    }
    
    override public func drawText(in rect: CGRect) {
        if shouldWrapCompact {
            if cachedCompactTextRect == nil {
                cachedCompactTextRect = compactTextRect(forBounds: rect)
            }
            
            super.drawText(in: cachedCompactTextRect!)
            
        } else {
            super.drawText(in: rect)
        }
    }
    
    // MARK: - UIView
    
    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        
        // Preserve the width if limited.
        if numberOfLines != 1 && size.width != CGFloat.greatestFiniteMagnitude {
            sizeThatFits.width = max(sizeThatFits.width, size.width)
        }
        
        if shouldWrapCompact && numberOfLines != 1 {
            let maximumAspectRatio = preferredMaximumAspectRatio
            // Make sure the text doesn't wrap to too wide an aspect ratio
            let maxHeight = (size.height == CGFloat.greatestFiniteMagnitude)
                ? sizeThatFits.height
                : max(sizeThatFits.height, size.height)
            var textRectForBounds = compactTextRect(forBounds: CGRect(origin: CGPoint.zero, size: sizeThatFits))
            
            while (textRectForBounds.height <= maxHeight) && (textRectForBounds.height > 0.0 && (textRectForBounds.width / textRectForBounds.height) > maximumAspectRatio) {
                // See how we'd have to wrap at a width just narrower than the width we'd wrap to.
                let narrowerBounds = CGSize(
                    width: textRectForBounds.width - 2.0,
                    height: CGFloat.greatestFiniteMagnitude
                )
                let sizeThatFitsNarrowerBounds = super.sizeThatFits(narrowerBounds)
                
                if sizeThatFitsNarrowerBounds.width > narrowerBounds.width || sizeThatFitsNarrowerBounds.height > maxHeight {
                    break
                }
                
                textRectForBounds = compactTextRect(
                    forBounds: CGRect(origin: CGPoint.zero, size: sizeThatFitsNarrowerBounds)
                )
            }
            
            // Cache for use during draw time.
            cachedCompactTextRect = textRectForBounds
            
            sizeThatFits.height = textRectForBounds.height
        }
        
        return sizeThatFits
    }
    
    override public var frame: CGRect {
        didSet {
            clearCachedMetrics()
        }
    }
    
    override public var bounds: CGRect {
        didSet {
            clearCachedMetrics()
        }
    }
    
    // MARK: - UIResponder
    
    override public var canBecomeFirstResponder: Bool {
        return !links.isEmpty
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if let touch = touches.first, let activeLink = link(at: touch.location(in: self)) {
            self.activeLink = activeLink
        }
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        if let touch = touches.first, activeLink != nil {
            // If we moved off of the link we started on, then cancel the pressed state.
            let newActiveLink = link(at: touch.location(in: self))
            if newActiveLink != activeLink {
                activeLink = nil
            }
        }
    }

    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if let activeLink = self.activeLink {
            self.activeLink = nil
            
            openLink(activeLink)
        }
    }

    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        if activeLink != nil {
            activeLink = nil
        }
    }
    
    // MARK: - Public Methods
    
    public func compactTextRect(forBounds bounds: CGRect) -> CGRect {
        var textBounds = bounds
        let sizeThatFits = super.sizeThatFits(textBounds.size)
        
        // A single-line label doesn't need to do any special computation.
        if numberOfLines == 1 {
            textBounds.size = sizeThatFits
            return textBounds
        }
        
        // If the height is unlimited, return the measured height.
        if textBounds.height == CGFloat.greatestFiniteMagnitude {
            textBounds.size.height = sizeThatFits.height
            return textBounds
        }
        
        // If the text will get truncated, don't modify the text rect.
        if sizeThatFits.height > textBounds.height {
            return textBounds
        }
        
        let maxHeight = textBounds.height
        
        // If there's no text at all, bail out.
        guard let text = attributedText, text.length > 0 else {
            return textBounds
        }
        
        // The minWidth is the longest word that's narrower than the originalWidth (to avoid forced line breaks
        // mid-word).
        let originalWidth = bounds.width
        var minWidth: CGFloat = 0.0
        let words = text.nonEmptyComponentsSeparated(by: CharacterSet.whitespacesAndNewlines)
        for word in words {
            let wordWidth = ceil(word.size().width)
            if wordWidth <= originalWidth && wordWidth > minWidth {
                minWidth = wordWidth
            }
        }
        
        // Do a binary search to find the narrowest width that fits the maxHeight.
        var bestWidth = originalWidth
        var maxWidth = originalWidth
        
        while minWidth < maxWidth - 1.0 {
            let midWidth: CGFloat = CGFloat(round((Double(minWidth) + Double(maxWidth)) / 2.0))
            
            let heightAtMidWidth = textHeight(forWidth: midWidth, limited: false)
            
            if heightAtMidWidth > maxHeight {
                // We just got an extra line--get bigger.
                minWidth = midWidth
            } else {
                // No extra lines--get smaller.
                maxWidth = midWidth
                bestWidth = midWidth
            }
        }
        
        // Align the text rect within the bounds based on the text alignment.
        switch textAlignment {
        case .left:
            break // No-op. Text bounds are already left-alignment.
            
        case .center:
            textBounds.origin.x = textBounds.minX + floor((textBounds.width - bestWidth) / 2.0)
            
        case .right:
            textBounds.origin.x = textBounds.maxX - bestWidth
            
        case .natural, .justified:
            let layoutDirection = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute)
            switch layoutDirection {
            case .leftToRight:
                break // No-op. Text bounds are already left-alignment.
                
            case .rightToLeft:
                textBounds.origin.x = textBounds.maxX - bestWidth

            @unknown default:
                fatalError("Unknown user interface layout direction: \(layoutDirection)")
            }

        @unknown default:
            fatalError("Unknown text alignment: \(textAlignment)")
        }
        
        textBounds.size.width = bestWidth
        return textBounds
    }
    
    // MARK: - Private Methods - Text Attributes
    
    /// Apply the attributes of the receiver to an attributed string, preserving attributes already specified in the
    /// string.
    /// - parameter string: The original attributed string.
    /// - returns: A new attributed string, with individual and paragraph-style attributes configured as appropriate.
    private func applyAttributes(to string: NSAttributedString) -> NSAttributedString {
        let attributedString = string.mutableCopy() as! NSMutableAttributedString

        let fullRange = NSMakeRange(0, attributedString.length)
        attributedString.enumerateAttributes(in: fullRange, options: []) { attributes, range, stop in
            
            var attributes = attributes
            
            // Apply the link (or active link) attributes if this is a link area. We'll apply the link attributes first
            // so that the other label-level attributes don't override them. If the attributed string already includes
            // an explicit attribute (font, underline, etc) we won't override them. This allows for customization of a
            // single link within the label if so desired.
            if attributes[NSAttributedString.Key.link] != nil {
                var linkAttributes: [NSAttributedString.Key : Any]
                let overrideUserAttributes: Bool
                if let activeLink = self.activeLink, NSEqualRanges(activeLink.range, range) {
                    linkAttributes = linkTextAttributes
                    activeLinkTextAttributes.forEach { key, value in
                        linkAttributes.updateValue(value, forKey: key)
                    }
                    overrideUserAttributes = true
                } else {
                    linkAttributes = linkTextAttributes
                    overrideUserAttributes = false
                }
                
                for (key, value) in linkAttributes {
                    if attributes[key] == nil || overrideUserAttributes {
                        attributedString.addAttribute(key, value: value, range: range)
                        attributes[key] = value
                    }
                }
            }
            
            // Apply label's font if this section of the string doesn't have an explicit font.
            if attributes[NSAttributedString.Key.font] == nil {
                attributedString.addAttribute(NSAttributedString.Key.font, value: internalFont, range: range)
            }
            
            if attributes[NSAttributedString.Key.foregroundColor] == nil {
                attributedString.addAttribute(
                    NSAttributedString.Key.foregroundColor,
                    value: internalTextColor,
                    range: range
                )
            }
            
            // Apply label's kerning if this section of the string doesn't have an explicit kerning.
            if attributes[NSAttributedString.Key.kern] == nil {
                attributedString.addAttribute(
                    NSAttributedString.Key.kern,
                    value: NSNumber(value: kerning as Double),
                    range: range
                )
            }
            
            // Apply attributes within the paragraph style. We can't detect whether or not individual attributes of the
            // paragraph style were explicitly set, so only set any of them if the incoming string has no paragraph
            // style at all. This matches the behavior used by `UILabel` for things like `textAlignment`.
            if attributes[NSAttributedString.Key.paragraphStyle] == nil {
                let paragraphStyle = NSMutableParagraphStyle()
                
                // Because we're setting a paragraph style, the base class won't be able to tell if we tried to
                // explicitly set a text alignment or line break mode. As such, we need to set it ourselves on the
                // paragraph style we created.
                paragraphStyle.alignment = textAlignment
                paragraphStyle.lineBreakMode = lineBreakMode
                paragraphStyle.lineSpacing = lineSpacingDistance
                
                attributedString.addAttribute(
                    NSAttributedString.Key.paragraphStyle,
                    value: paragraphStyle,
                    range: range
                )
            }
            
            // Convert the characters' case if appropriate.
            if let letterCase = self.letterCase {
                let newLetterCaseString: String
                switch letterCase {
                case .uppercase:
                    newLetterCaseString = attributedString.attributedSubstring(from: range).string.uppercased(with: nil)
                case .lowercase:
                    newLetterCaseString = attributedString.attributedSubstring(from: range).string.lowercased(with: nil)
                case .capitalized:
                    newLetterCaseString = attributedString.attributedSubstring(from: range).string.capitalized(with: nil)
                }
                
                attributedString.replaceCharacters(in: range, with: newLetterCaseString)
            }
            
        }
        
        return attributedString
    }
    
    private func updateAttributedText() {
        if let string = internalAttributedText {
            super.attributedText = applyAttributes(to: string)
            clearCachedMetrics()
            setNeedsDisplay()
        }
    }
    
    private func setBaseAttributedTextAttribute(_ attribute: NSAttributedString.Key, value: AnyObject) {
        guard let attributedString = internalAttributedText else {
            return
        }
        attributedString.addAttribute(attribute, value: value, range: NSMakeRange(0, attributedString.length))
    }
    
    // If all or part of the attribute string have an explicit paragraph style defined, then change one of the
    // attributes to be the newly set value. The parts of the string that don't have a paragraph style will have it
    // filled in as part of `applyAttributes`.
    private func updateExistingParagraphStyle(updateBlock: @escaping (NSMutableParagraphStyle) -> Void) {
        guard let attributedString = internalAttributedText else {
            return
        }

        let fullRange = NSMakeRange(0, attributedString.length)
        attributedString.enumerateAttributes(in: fullRange, options: []) { (attributes, range, stop) -> Void in
            guard let attribute = attributes[NSAttributedString.Key.paragraphStyle] as? NSParagraphStyle else {
                return
            }
            let paragraphStyle = attribute.mutableCopy() as! NSMutableParagraphStyle
            updateBlock(paragraphStyle)
            
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: range)
        }
    }
    
    // MARK: - Private Methods - Links
    
    private func boundingRectForText(in range: NSRange) -> CGRect {
        guard let string = internalAttributedText else {
            return .zero
        }
        
        let textStorage = NSTextStorage(attributedString: string)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        let textContainer = NSTextContainer(
            size: bounds.insetBy(dx: 0, dy: Label.magicTextContainerHorizontalOffset).size
        )
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = lineBreakMode
        layoutManager.addTextContainer(textContainer)
        
        let linkGlyphRange = layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)

        let entireRange = layoutManager.glyphRange(
            forCharacterRange: NSMakeRange(0, string.length),
            actualCharacterRange: nil
        )
        
        let entireRect = layoutManager.boundingRect(forGlyphRange: entireRange, in: textContainer)
        var linkRect = layoutManager.boundingRect(forGlyphRange: linkGlyphRange, in: textContainer)

        let verticalOffset = (bounds.height - entireRect.height) / 2
        
        linkRect.origin.x = floor(linkRect.origin.x)
        linkRect.origin.y = floor(linkRect.origin.y + verticalOffset)
        linkRect.size.height = ceil(linkRect.size.height)
        linkRect.size.width = ceil(linkRect.size.width)
        
        return linkRect
    }
    
    private func link(at point: CGPoint) -> Link? {
        // Stop quickly if none of the points to be tested are in the bounds.
        guard
            let string = internalAttributedText,
            bounds.insetBy(dx: -15, dy: -15).contains(point),
            !links.isEmpty
        else {
            return nil;
        }
        
        let textStorage = NSTextStorage(attributedString: string)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        let textContainer = NSTextContainer(
            size: bounds.insetBy(dx: 0, dy: Label.magicTextContainerHorizontalOffset).size
        )
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = lineBreakMode
        layoutManager.addTextContainer(textContainer)
        
        let characterRange = NSMakeRange(0, string.length)
        layoutManager.ensureLayout(forCharacterRange: characterRange)
        let glyphRange = layoutManager.glyphRange(forCharacterRange: characterRange, actualCharacterRange: nil)

        var textOffset = CGPoint.zero
        let textBounds = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
        let paddingHeight = floor((bounds.height - textBounds.height) / 2)
        if paddingHeight > 0 {
            textOffset.y = paddingHeight
        }
        
        // Get the touch location and use text offset to convert to text cotainer coords
        var point = point
        point.x -= textOffset.x
        point.y -= textOffset.y
        
        let glyphIndex = layoutManager.glyphIndex(for: point, in: textContainer)
        let tappedIndex = layoutManager.characterIndexForGlyph(at: glyphIndex)
        
        for link in links {
            if tappedIndex >= link.range.location && tappedIndex <= link.range.location + link.range.length {
                return link
            }
        }
    
        return nil
    }

    private func updateLinks() {
        guard let string = internalAttributedText else {
            return
        }
        
        var links = [Link]()

        let fullRange = NSMakeRange(0, string.length)
        string.enumerateAttribute(NSAttributedString.Key.link, in: fullRange, options: []) { value, range, stop in
            let url: URL
            if let val = value as? String {
                if let urlValue = URL(string: val) {
                    url = urlValue
                } else {
                    print("Link attribute string value is not a valid URL: \(val)")
                    return
                }
            } else if let val = value as? URL {
                url = val
            } else if value == nil {
                return
            } else {
                print("Unknown link attribute type: \(String(describing: value))")
                return
            }
            
            links.append(Link(url: url, range: range))
        }
        
        self.links = links
    }
    
    // MARK: - Private Methods - Accessibility
    
    private func accessibilityPathForLink(in range: NSRange) -> UIBezierPath? {
        guard let string = internalAttributedText else {
            return nil
        }
        
        // This all assumes left -> right text layout.
        if range.length == string.length {
            return nil
        }
        
        if !isMultiline(range: range) {
            // Early return if link is single line.
            return nil
        }
        
        let entireTextRect = boundingRectForText(in: range)
        
        var firstCharacterFrame = boundingRectForText(in: NSMakeRange(range.location, 1))
        var lastCharacterFrame = boundingRectForText(in: NSMakeRange(range.location + range.length - 1, 1))
        
        // Expand frames by 2.0 so the path doesen't overlap the characters
        let expansion: CGFloat = 2.0
        firstCharacterFrame.origin.x -= expansion;
        lastCharacterFrame.size.width += expansion;
        
        let horizontalOverlap = firstCharacterFrame.minX - lastCharacterFrame.midX
        
        if horizontalOverlap > 0 {
            // Link spans adjacent lines but is non-contiguous, create two rects and join them as one path.
            let firstLineY = firstCharacterFrame.origin.y
            var lineBreakIndex = 0
            while lineBreakIndex < range.length {
                let letterRect = boundingRectForText(in: NSMakeRange(range.location + lineBreakIndex, 1))
                if letterRect.origin.y != firstLineY {
                    break
                }
                lineBreakIndex += 1
            }
            
            let firstLineFrame = boundingRectForText(in: NSMakeRange(range.location, lineBreakIndex))
            let secondLineFrame = boundingRectForText(
                in: NSMakeRange(range.location + lineBreakIndex, range.length - lineBreakIndex)
            )
            
            let path = UIBezierPath()
            path.append(UIBezierPath(roundedRect: firstLineFrame, cornerRadius: 4))
            path.append(UIBezierPath(roundedRect: secondLineFrame, cornerRadius: 4))
            
            return path
        }
        
        // In all other cases draw a path around the entire text block
        let path = UIBezierPath()
        // Top left corner of selection
        path.move(to: firstCharacterFrame.origin)
        
        // Draw right to top right corner
        let topRight = CGPoint(
            x: entireTextRect.origin.x + entireTextRect.size.width,
            y: firstCharacterFrame.origin.y
        )
        path.addLine(to: topRight)
        
        // Draw down to termination of last full width line
        let lastFullWidthPoint = CGPoint(x: topRight.x, y: lastCharacterFrame.origin.y)
        path.addLine(to: lastFullWidthPoint)
        
        // Draw left to last character termination
        let linkTerminationOrigin = CGPoint(
            x: (lastCharacterFrame.origin.x + lastCharacterFrame.size.width),
            y: lastCharacterFrame.origin.y
        )
        path.addLine(to: linkTerminationOrigin)
        
        // Draw down to bottom of link
        let bottomRight = CGPoint(
            x: (lastCharacterFrame.origin.x + lastCharacterFrame.size.width),
            y: (lastCharacterFrame.origin.y + lastCharacterFrame.size.height)
        )
        path.addLine(to: bottomRight)
        
        // Draw left to origin of full width line
        let bottomLeft = CGPoint(x: entireTextRect.origin.x, y: bottomRight.y)
        path.addLine(to: bottomLeft)
        
        // Draw Up to first full Width line
        let firstFullWithPoint = CGPoint(
            x: bottomLeft.x,
            y: (firstCharacterFrame.origin.y + firstCharacterFrame.size.height)
        )
        path.addLine(to: firstFullWithPoint)
        
        // Draw right to beginning of link
        let linkOriginBottomLeft = CGPoint(x: firstCharacterFrame.origin.x, y: firstFullWithPoint.y)
        path.addLine(to: linkOriginBottomLeft)
        
        // Return to orign
        path.addLine(to: firstCharacterFrame.origin)
        path.close()
        
        return path
    }
    
    private func updateAccessibilityElements() {
        var accessibilityElements = [UIAccessibilityElement]()
        
        // Create a base element to represent the entire label.
        let baseElement = UIAccessibilityElement(accessibilityContainer: self)
        baseElement.accessibilityLabel = super.accessibilityLabel
        baseElement.accessibilityHint = super.accessibilityHint
        baseElement.accessibilityValue = super.accessibilityValue
        baseElement.accessibilityFrame = convert(bounds, to: window)
        baseElement.accessibilityTraits = super.accessibilityTraits
        baseElement.accessibilityActivationPoint = .zero
        accessibilityElements.append(baseElement)
        
        if let string = internalAttributedText {
            string.enumerateAttributes(in: NSMakeRange(0, string.length), options: []) { (attributes, range, stop) in
                guard attributes[NSAttributedString.Key.link] != nil else {
                    return
                }
                
                let linkElement = UIAccessibilityElement(accessibilityContainer: self)
                linkElement.accessibilityLabel = string.attributedSubstring(from: range).string
                linkElement.accessibilityTraits = UIAccessibilityTraits.link
                linkElement.accessibilityFrame = UIAccessibility.convertToScreenCoordinates(
                    boundingRectForText(in: range),
                    in: self
                )
                if let path = accessibilityPathForLink(in: range) {
                    linkElement.accessibilityPath = UIAccessibility.convertToScreenCoordinates(path, in: self)
                } else {
                    linkElement.accessibilityPath = nil
                }
                accessibilityElements.append(linkElement)
            }
        }
        
        self.isAccessibilityElement = (accessibilityElements.count > 1)
        self.accessibilityElements = accessibilityElements
    }
    
    // MARK: - Private Methods - Open URL
    
    private func openLink(_ link: Link) {
        
        guard let delegate = self.delegate else {
            openURLInSafari(link.url)
            return
        }
        
        delegate.label(self, didTapLink:link.url, in: link.range)
    }
    
    /**
     Open the URL in Safari.
     
     This method uses the UIResponder chain and dynamic dispatch so that it works in both Applications and Extensions.
     */
    private func openURLInSafari(_ url: URL) {
        var nextResponder = self as UIResponder?
        
        let openURLSelector = #selector(FakeApplication.openURL(_:))
        while let responder = nextResponder {
            if responder.responds(to: openURLSelector) {
                responder.performSelector(onMainThread: openURLSelector, with: url, waitUntilDone: false)
            }
            nextResponder = responder.next
        }
    }
    
    // MARK: - Private Methods
    
    private var shouldWrapCompact: Bool {
        guard numberOfLines != 1 else {
            return false
        }
        
        return lineWrapBehavior == .compact
    }
    
    private func clearCachedMetrics() {
        cachedCompactTextRect = nil
    }
    
    private func height(forWidth width: CGFloat) -> CGFloat {
        let bounds = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        return sizeThatFits(bounds).height
    }
    
    private func isMultiline(range: NSRange) -> Bool {
        guard let string = internalAttributedText else {
            return false
        }
        
        let firstLetterFrame = boundingRectForText(in: NSMakeRange(range.location, 1))
        let lastLetterFrame = boundingRectForText(in: NSMakeRange(range.location + range.length - 1, 1))
        let font: UIFont = string.attribute(
            NSAttributedString.Key.font,
            at: range.location,
            effectiveRange: nil
        ) as? UIFont ?? self.font
        let lineHeight = font.lineHeight
        
        // Individual letter frames can have some vertical variation because of ascenders and descenders, but shouldn't
        // differ by more than half the leading size.
        let lineOriginDifference = lastLetterFrame.minY - firstLetterFrame.minY
        let acceptableVariation = lineHeight / 2
        
        return lineOriginDifference >= acceptableVariation
    }
    
    private func textHeight(forWidth width: CGFloat, limited: Bool) -> CGFloat {
        let sizeToFit = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        
        if limited {
            // Call super to avoid max-aspect-ratio logic.
            return super.sizeThatFits(sizeToFit).height
            
        } else {
            // Change and restore our number of lines to measure the unlimited height of the text.
            let numberOfLines = self.numberOfLines
            super.numberOfLines = 0
            
            let height = super.sizeThatFits(sizeToFit).height
            
            super.numberOfLines = numberOfLines
            return height
        }
    }
}

// MARK: -

private extension NSAttributedString {
    
    func nonEmptyComponentsSeparated(by separatorSet: CharacterSet) -> [NSAttributedString] {
        var components = [NSAttributedString]()
        let string = self.string as NSString
        let stringLength = string.length
        var searchRange = NSRange(location: 0, length: stringLength)
        
        while searchRange.length > 0 {
            let rangeOfNextSeparator = string.rangeOfCharacter(from: separatorSet, options: [], range: searchRange)
            
            if rangeOfNextSeparator.length == 0 {
                // No more separators left. Add the remainder of the string and be done.
                components.append(attributedSubstring(from: searchRange))
                break
                
            } else if rangeOfNextSeparator.location > searchRange.location {
                // A separator is futher ahead. Add the substring up to that point.
                let rangeToNextSeparator = NSRange(
                    location: searchRange.location,
                    length: rangeOfNextSeparator.location - searchRange.location
                )
                components.append((attributedSubstring(from: rangeToNextSeparator)))
            }
            
            // Continue the search from the end of the separator range.
            let endOfNextSeparator = NSMaxRange(rangeOfNextSeparator)
            searchRange = NSRange(location: endOfNextSeparator, length: stringLength - endOfNextSeparator)
        }
        
        return components
    }

}
