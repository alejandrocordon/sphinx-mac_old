//
//  NewMessageCollectionViewItem+MessageTypesExtension.swift
//  Sphinx
//
//  Created by Tomas Timinskas on 20/07/2023.
//  Copyright © 2023 Tomas Timinskas. All rights reserved.
//

import Cocoa

extension NewMessageCollectionViewItem {
    
    func configureWith(
        messageReply: BubbleMessageLayoutState.MessageReply?,
        and bubble: BubbleMessageLayoutState.Bubble
    ) {
        if let messageReply = messageReply {
            messageReplyView.configureWith(messageReply: messageReply, and: bubble, delegate: self)
            messageReplyView.isHidden = false
        }
    }
    
    func configureWith(
        directPayment: BubbleMessageLayoutState.DirectPayment?,
        and bubble: BubbleMessageLayoutState.Bubble
    ) {
        if let directPayment = directPayment {
            directPaymentView.configureWith(directPayment: directPayment, and: bubble)
            directPaymentView.isHidden = false
        }
    }
    
    func configureWith(
        messageMedia: BubbleMessageLayoutState.MessageMedia?,
        mediaData: MessageTableCellState.MediaData?,
        and bubble: BubbleMessageLayoutState.Bubble
    ) {
        if let messageMedia = messageMedia {
            
            mediaMessageView.configureWith(
                messageMedia: messageMedia,
                mediaData: mediaData,
                bubble: bubble,
                and: self
            )
            mediaMessageView.isHidden = false
            
            if let messageId = messageId, mediaData == nil {
                let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.global().asyncAfter(deadline: delayTime) {
                    if messageMedia.isImage {
                        self.delegate?.shouldLoadImageDataFor(
                            messageId: messageId,
                            and: self.rowIndex
                        )
                    } else if messageMedia.isPdf {
                        self.delegate?.shouldLoadPdfDataFor(
                            messageId: messageId,
                            and: self.rowIndex
                        )
                    } else if messageMedia.isVideo {
                        self.delegate?.shouldLoadVideoDataFor(
                            messageId: messageId,
                            and: self.rowIndex
                        )
                    } else if messageMedia.isGiphy {
                        self.delegate?.shouldLoadGiphyDataFor(
                            messageId: messageId,
                            and: self.rowIndex
                        )
                    }
                }
            }
        }
    }
    
    func configureWith(
        genericFile: BubbleMessageLayoutState.GenericFile?,
        mediaData: MessageTableCellState.MediaData?
    ) {
        if let _ = genericFile {
            
            fileDetailsView.configureWith(
                mediaData: mediaData,
                and: self
            )
            
            fileDetailsView.isHidden = false
            
            if let messageId = messageId, mediaData == nil {
                let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.global().asyncAfter(deadline: delayTime) {
                    self.delegate?.shouldLoadFileDataFor(
                        messageId: messageId,
                        and: self.rowIndex
                    )
                }
            }
        }
    }
    
    func configureWith(
        messageContent: BubbleMessageLayoutState.MessageContent?,
        searchingTerm: String?
    ) {
        urlRanges = []

        if let messageContent = messageContent {
            if messageContent.linkMatches.isEmpty && searchingTerm == nil {
                messageLabel.attributedStringValue = NSMutableAttributedString(string: "")

                messageLabel.stringValue = messageContent.text ?? ""
                messageLabel.font = messageContent.font
            } else {
                let messageC = messageContent.text ?? ""
                let term = searchingTerm ?? ""

                let attributedString = NSMutableAttributedString(string: messageC)
                attributedString.addAttributes(
                    [
                        NSAttributedString.Key.font: messageContent.font,
                        NSAttributedString.Key.foregroundColor: NSColor.Sphinx.Text
                    ]
                    , range: messageC.nsRange
                )

                let searchingTermRange = (messageC.lowercased() as NSString).range(of: term.lowercased())
                attributedString.addAttributes(
                    [
                        NSAttributedString.Key.backgroundColor: NSColor.Sphinx.PrimaryGreen
                    ]
                    , range: searchingTermRange
                )

                for match in messageContent.linkMatches {

                    attributedString.setAttributes(
                        [
                            NSAttributedString.Key.foregroundColor: NSColor.Sphinx.PrimaryBlue,
                            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
                            NSAttributedString.Key.font: messageContent.font
                        ],
                        range: match.range
                    )

                    urlRanges.append(match.range)
                }

                messageLabel.attributedStringValue = attributedString
//                messageLabel.isUserInteractionEnabled = true
            }
            
            textMessageView.isHidden = false
        }

//        let tap = UITapGestureRecognizer(target: self, action: #selector(labelTapped(gesture:)))

//        if urlRanges.isEmpty {
//            messageLabel.removeGestureRecognizer(tap)
//        } else {
//            messageLabel.addGestureRecognizer(tap)
//        }
    }
    
    func configureWith(
        callLink: BubbleMessageLayoutState.CallLink?
    ) {
        if let callLink = callLink {
            callLinkView.configureWith(callLink: callLink, and: self)
            callLinkView.isHidden = false
        }
    }
    
    func configureWith(
        podcastBoost: BubbleMessageLayoutState.PodcastBoost?
    ) {
        if let podcastBoost = podcastBoost {
            podcastBoostView.configureWith(podcastBoost: podcastBoost)
            podcastBoostView.isHidden = false
        }
    }
    
    func configureWith(
        webLink: BubbleMessageLayoutState.WebLink?,
        linkData: MessageTableCellState.LinkData?
    ) {
        if let _ = webLink {
            
            linkPreviewView.configureWith(
                linkData: linkData,
                delegate: self
            )
            
            linkPreviewView.isHidden = false
            
            if let messageId = messageId, linkData == nil {
                let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.global().asyncAfter(deadline: delayTime) {
                    self.delegate?.shouldLoadLinkDataFor(
                        messageId: messageId,
                        and: self.rowIndex
                    )
                }
            }
        }
    }
    
    func configureWith(
        contactLink: BubbleMessageLayoutState.ContactLink?,
        and bubble: BubbleMessageLayoutState.Bubble
    ) {
        if let contactLink = contactLink {
            contactLinkPreviewView.configureWith(contactLink: contactLink, and: bubble, delegate: self)
            contactLinkPreviewView.isHidden = false
        }
    }
    
    func configureWith(
        tribeLink: BubbleMessageLayoutState.TribeLink?,
        tribeData: MessageTableCellState.TribeData?,
        and bubble: BubbleMessageLayoutState.Bubble
    ) {
        if let _ = tribeLink {
            if let tribeData = tribeData {
                tribeLinkPreviewView.configureWith(tribeData: tribeData, and: bubble, delegate: self)
                tribeLinkPreviewView.isHidden = false
            } else if let messageId = messageId {
                let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.global().asyncAfter(deadline: delayTime) {
                    self.delegate?.shouldLoadTribeInfoFor(
                        messageId: messageId,
                        and: self.rowIndex
                    )
                }
            }
        }
    }
    
    func configureWith(
        boosts: BubbleMessageLayoutState.Boosts?,
        and bubble: BubbleMessageLayoutState.Bubble
    ) {
        if let boosts = boosts {
            messageBoostView.configureWith(boosts: boosts, and: bubble)
            messageBoostView.isHidden = false
        }
    }
}