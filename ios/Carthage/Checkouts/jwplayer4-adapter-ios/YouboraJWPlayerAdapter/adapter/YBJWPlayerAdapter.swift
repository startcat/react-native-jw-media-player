//
//  YBJWPlayerAdapter.swift
//  YouboraJWPlayerAdapter
//
//  Created by Elisabet Massó on 27/1/22.
//  Copyright © 2022 NPAW. All rights reserved.
//

import YouboraLib
import JWPlayerKit

public class YBJWPlayerAdapter: YBPlayerAdapter<AnyObject> {
    
    private var delegate: JWPlayerDelegate?
    private var stateDelegate: JWPlayerStateDelegate?
    private var metadataDelegate: JWMediaMetadataDelegate?
    private var logMetadataDelegate: JWAccessLogMetadataDelegate?
    
    private var bitrate: Double?
    private var throughput: Double?
    private var width: Double?
    private var height: Double?
    private var title: String?

    private override init() {
        super.init()
    }
    
    public init(player: JWPlayer) {
        super.init(player: player)
    }
    
    public override func registerListeners() {
        super.registerListeners()
        if let player = player as? JWPlayer {
            delegate = player.delegate
            stateDelegate = player.playbackStateDelegate
            metadataDelegate = player.metadataDelegates.mediaMetadataDelegate
            logMetadataDelegate = player.metadataDelegates.accessLogMetadataDelegate
            player.delegate = self
            player.playbackStateDelegate = self
            player.metadataDelegates.mediaMetadataDelegate = self
            player.metadataDelegates.accessLogMetadataDelegate = self
        }
        if plugin?.adsAdapter != nil {
            plugin?.adsAdapter?.fireStop()
        }
        resetValues()
    }
    
    public override func unregisterListeners() {
        if let player = player as? JWPlayer {
            player.delegate = delegate
            player.playbackStateDelegate = stateDelegate
            player.metadataDelegates.mediaMetadataDelegate = metadataDelegate
            player.metadataDelegates.accessLogMetadataDelegate = logMetadataDelegate
        }
        delegate = nil
        stateDelegate = nil
        metadataDelegate = nil
        logMetadataDelegate = nil
        resetValues()
        super.unregisterListeners()
    }
    
    private func resetValues() {
        bitrate = nil
        throughput = nil
        width = nil
        height = nil
        title = nil
    }
    
    // MARK: - Getters
    
    public override func getBitrate() -> NSNumber? {
        guard let bitrate = bitrate else { return super.getBitrate() }
        return NSNumber(value: bitrate)
    }
    
    public override func getDuration() -> NSNumber? {
        guard let player = player as? JWPlayer else { return super.getDuration() }
        return NSNumber(value: player.time.duration)
    }
    
    public override func getIsLive() -> NSValue? {
        var val: NSNumber? = nil
        if let player = player as? JWPlayer {
            if player.time.position != 0 && player.time.duration > 0 {
                val = NSNumber(value: false)
            } else if player.time.duration == .nan || player.time.duration == -1 {
                val = NSNumber(value: true)
            }
        }
        return val
    }
    
    public override func getPlayhead() -> NSNumber? {
        guard let player = player as? JWPlayer else { return super.getPlayhead() }
        return NSNumber(value: player.time.position)
    }
    
    public override func getPlayrate() -> NSNumber {
        guard let player = player as? JWPlayer else { return super.getPlayrate() }
        if flags.paused { return 0 }
        return NSNumber(value: player.playbackRate)
    }
    
    public override func getRendition() -> String? {
        guard let width = width, let height = height, let bitrate = bitrate else { return super.getRendition() }
        return YBYouboraUtils.buildRenditionString(withWidth: Int32(width), height: Int32(height), andBitrate: bitrate)
    }
    
    public override func getResource() -> String? {
        guard let player = player as? JWPlayer, player.visualQualityLevels.count > 0, let resource = player.visualQualityLevels[player.currentVisualQuality].file else { return super.getResource() }
        return resource.absoluteString
    }
    
    public override func getTitle() -> String? {
        guard let title = title else { return super.getResource() }
        return title
    }
    
    public override func getThroughput() -> NSNumber? {
        guard let throughput = throughput else { return super.getThroughput() }
        return NSNumber(value: throughput)
    }
    
    public override func fireStop(_ params: [String : String]?) {
        resetValues()
        super.fireStop(params)
    }
    
    // MARK: - Adapter info
    
    public override func getPlayerName() -> String? {
        return Constants.getAdapterName()
    }
    
    public override func getPlayerVersion() -> String? {
        return Constants.getName(version: false)
    }
    
    public override func getVersion() -> String {
        return Constants.getAdapterVersion()
    }
    
}

extension YBJWPlayerAdapter: JWPlayerStateDelegate {
    
    public func jwplayerContentWillComplete(_ player: JWPlayer) {
        stateDelegate?.jwplayerContentWillComplete(player)
    }
    
    public func jwplayer(_ player: JWPlayer, willPlayWithReason reason: JWPlayReason) {
        stateDelegate?.jwplayer(player, willPlayWithReason: reason)
    }
    
    public func jwplayer(_ player: JWPlayer, isBufferingWithReason reason: JWBufferReason) {
        stateDelegate?.jwplayer(player, isBufferingWithReason: reason)
        if reason == .stalled {
            fireBufferBegin()
        }
    }
    
    public func jwplayerContentIsBuffering(_ player: JWPlayer) {
        stateDelegate?.jwplayerContentIsBuffering(player)
    }
    
    public func jwplayer(_ player: JWPlayer, updatedBuffer percent: Double, position time: JWTimeData) {
        stateDelegate?.jwplayer(player, updatedBuffer: percent, position: time)
    }
    
    public func jwplayerContentDidComplete(_ player: JWPlayer) {
        stateDelegate?.jwplayerContentDidComplete(player)
    }
    
    public func jwplayer(_ player: JWPlayer, didFinishLoadingWithTime loadTime: TimeInterval) {
        stateDelegate?.jwplayer(player, didFinishLoadingWithTime: loadTime)
    }
    
    public func jwplayer(_ player: JWPlayer, isPlayingWithReason reason: JWPlayReason) {
        stateDelegate?.jwplayer(player, isPlayingWithReason: reason)
        fireStart()
        fireJoin()
        fireResume()
        if flags.buffering {
            fireBufferEnd()
        }
    }
    
    public func jwplayer(_ player: JWPlayer, isAttemptingToPlay playlistItem: JWPlayerItem, reason: JWPlayReason) {
        stateDelegate?.jwplayer(player, isAttemptingToPlay: playlistItem, reason: reason)
    }
    
    public func jwplayer(_ player: JWPlayer, didPauseWithReason reason: JWPauseReason) {
        stateDelegate?.jwplayer(player, didPauseWithReason: reason)
        firePause()
    }
    
    public func jwplayer(_ player: JWPlayer, didBecomeIdleWithReason reason: JWIdleReason) {
        stateDelegate?.jwplayer(player, didBecomeIdleWithReason: reason)
    }
    
    public func jwplayer(_ player: JWPlayer, isVisible: Bool) {
        stateDelegate?.jwplayer(player, isVisible: isVisible)

    }
    
    public func jwplayer(_ player: JWPlayer, didLoadPlaylist playlist: [JWPlayerItem]) {
        stateDelegate?.jwplayer(player, didLoadPlaylist: playlist)
    }
    
    public func jwplayer(_ player: JWPlayer, didLoadPlaylistItem item: JWPlayerItem, at index: UInt) {
        stateDelegate?.jwplayer(player, didLoadPlaylistItem: item, at: index)
        fireStop()
        title = item.title
        fireStart()
    }
    
    public func jwplayerPlaylistHasCompleted(_ player: JWPlayer) {
        stateDelegate?.jwplayerPlaylistHasCompleted(player)
        fireStop()
    }
    
    public func jwplayer(_ player: JWPlayer, usesMediaType type: JWMediaType) {
        stateDelegate?.jwplayer(player, usesMediaType: type)
    }
    
    public func jwplayer(_ player: JWPlayer, seekedFrom oldPosition: TimeInterval, to newPosition: TimeInterval) {
        stateDelegate?.jwplayer(player, seekedFrom: oldPosition, to: newPosition)
        fireSeekBegin()
    }
    
    public func jwplayerHasSeeked(_ player: JWPlayer) {
        stateDelegate?.jwplayerHasSeeked(player)
        fireSeekEnd()
    }
    
    public func jwplayer(_ player: JWPlayer, playbackRateChangedTo rate: Double, at time: TimeInterval) {
        stateDelegate?.jwplayer(player, playbackRateChangedTo: rate, at: time)
    }
    
    public func jwplayer(_ player: JWPlayer, updatedCues cues: [JWCue]) {
        stateDelegate?.jwplayer(player, updatedCues: cues)
    }
    
}

extension YBJWPlayerAdapter: JWPlayerDelegate {
    
    public func jwplayerIsReady(_ player: JWPlayer) {
        delegate?.jwplayerIsReady(player)
    }
    
    public func jwplayer(_ player: JWPlayer, failedWithError code: UInt, message: String) {
        delegate?.jwplayer(player, failedWithError: code, message: message)
        fireFatalError(withMessage: message, code: "\(code)", andMetadata: nil)
    }
    
    public func jwplayer(_ player: JWPlayer, failedWithSetupError code: UInt, message: String) {
        delegate?.jwplayer(player, failedWithSetupError: code, message: message)
        fireFatalError(withMessage: message, code: "\(code)", andMetadata: nil)
    }
    
    public func jwplayer(_ player: JWPlayer, encounteredWarning code: UInt, message: String) {
        delegate?.jwplayer(player, encounteredWarning: code, message: message)
        if code != 0 {
            fireError(withMessage: message, code: "\(code)", andMetadata: nil)
        }
    }
    
    public func jwplayer(_ player: JWPlayer, encounteredAdWarning code: UInt, message: String) {
        delegate?.jwplayer(player, encounteredAdWarning: code, message: message)
    }
    
    public func jwplayer(_ player: JWPlayer, encounteredAdError code: UInt, message: String) {
        delegate?.jwplayer(player, encounteredAdError: code, message: message)
    }
    
}

extension YBJWPlayerAdapter: JWMediaMetadataDelegate, JWAccessLogMetadataDelegate {
    
    public func jwplayer(_ player: JWPlayer, didReceiveMediaMetadata metadata: JWMediaMetadata) {
        metadataDelegate?.jwplayer(player, didReceiveMediaMetadata: metadata)
        width = metadata.width
        height = metadata.height
    }
    
    public func jwplayer(_ player: JWPlayer, didReceiveAccessLogMetadata metadata: JWAccessLogMetadata) {
        logMetadataDelegate?.jwplayer(player, didReceiveAccessLogMetadata: metadata)
        bitrate = metadata.indicatedBitrate
        throughput = metadata.observedBitrate
    }
    
}
