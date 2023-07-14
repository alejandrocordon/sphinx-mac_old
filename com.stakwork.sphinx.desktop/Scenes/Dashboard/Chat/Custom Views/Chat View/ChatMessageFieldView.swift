//
//  ChatMessageFieldView.swift
//  Sphinx
//
//  Created by Tomas Timinskas on 07/07/2023.
//  Copyright © 2023 Tomas Timinskas. All rights reserved.
//

import Cocoa

class ChatMessageFieldView: NSView, LoadableNib {

    @IBOutlet var contentView: NSView!
    
    @IBOutlet var messageTextView: PlaceHolderTextView!
    @IBOutlet weak var messageTextViewContainer: NSBox!
    
    @IBOutlet weak var attachmentsButton: CustomButton!
    @IBOutlet weak var sendButton: CustomButton!
    @IBOutlet weak var micButton: CustomButton!
    @IBOutlet weak var emojiButton: CustomButton!
    @IBOutlet weak var giphyButton: CustomButton!
    
    @IBOutlet weak var priceContainer: NSBox!
    @IBOutlet weak var priceTextField: CCTextField!
    @IBOutlet weak var priceTextFieldWidth: NSLayoutConstraint!
    
    @IBOutlet weak var messageContainerHeightConstraint: NSLayoutConstraint!
    
    let kTextViewVerticalMargins: CGFloat = 41
    let kCharacterLimit = 1000
    let kTextViewLineHeight: CGFloat = 19
    let kMinimumPriceFieldWidth: CGFloat = 50
    let kPriceFieldPadding: CGFloat = 10
    
    var macros : [MentionOrMacroItem] = []
    
    var chat: Chat? = nil
    var contact: Chat? = nil
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadViewFromNib()
        setupView()
        setupData()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        loadViewFromNib()
        setupView()
        setupData()
    }
    
    func setupView() {
        setupButtonsCursor()
        setupMessageField()
        setupPriceField()
        setupAttachmentButton()
        setupSendButton()
        
        self.addShadow(
            location: VerticalLocation.top,
            color: NSColor.black,
            opacity: 0.3,
            radius: 5.0
        )
    }
    
    func setupButtonsCursor() {
        attachmentsButton.cursor = .pointingHand
        sendButton.cursor = .pointingHand
        micButton.cursor = .pointingHand
        emojiButton.cursor = .pointingHand
        giphyButton.cursor = .pointingHand
    }
    
    func setupMessageField() {
        messageTextViewContainer.wantsLayer = true
        messageTextViewContainer.layer?.cornerRadius = messageTextViewContainer.frame.height / 2
        
        messageTextView.isEditable = true
        
        messageTextView.setPlaceHolder(
            color: NSColor.Sphinx.PlaceholderText,
            font: NSFont(name: "Roboto-Regular", size: 16.0)!,
            string: "message.placeholder".localized
        )
        
        messageTextView.font = NSFont(
            name: "Roboto-Regular",
            size: 16.0
        )!
        
        messageTextView.delegate = self
        messageTextView.fieldDelegate = self
    }
    
    func setupPriceField() {
        priceContainer.wantsLayer = true
        priceContainer.layer?.cornerRadius = priceContainer.frame.height / 2
        priceTextField.color = NSColor.Sphinx.SphinxWhite
        priceTextField.formatter = IntegerValueFormatter()
        priceTextField.delegate = self
        priceTextField.isEditable = false
    }
    
    func setupAttachmentButton() {
        attachmentsButton.wantsLayer = true
        attachmentsButton.layer?.cornerRadius = attachmentsButton.frame.height / 2
        attachmentsButton.layer?.backgroundColor = NSColor.Sphinx.PrimaryBlue.cgColor
        attachmentsButton.isEnabled = false
    }
    
    func setupSendButton() {
        sendButton.wantsLayer = true
        sendButton.layer?.cornerRadius = sendButton.frame.height / 2
        sendButton.layer?.backgroundColor = NSColor.Sphinx.PrimaryBlue.cgColor
        sendButton.isEnabled = false
    }
    
    func updateBottomBarHeight() -> Bool {
        let messageFieldContentHeight = messageTextView.contentSize.height
        let updatedHeight = messageFieldContentHeight + kTextViewVerticalMargins
        let newFieldHeight = min(updatedHeight, kTextViewLineHeight * 6)
        
        if messageContainerHeightConstraint.constant == newFieldHeight {
            scrollMessageTextViewToBottom()
            return false
            
        }
        
        messageContainerHeightConstraint.constant = newFieldHeight
        layoutSubtreeIfNeeded()
        scrollMessageTextViewToBottom()
        
        return true
    }
    
    func scrollMessageTextViewToBottom() {
        messageTextView.scrollRangeToVisible(
            NSMakeRange(
                messageTextView.string.length,
                0
            )
        )
    }
    
    func setupData() {
        initializeMacros()
    }
}
