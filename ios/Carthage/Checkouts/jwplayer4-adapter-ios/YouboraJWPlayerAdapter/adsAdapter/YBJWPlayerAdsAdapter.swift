//
//  YBJWPlayerAdsAdapter.swift
//  YouboraJWPlayerAdapter
//
//  Created by Elisabet Massó on 27/1/22.
//  Copyright © 2022 NPAW. All rights reserved.
//

import YouboraLib
import JWPlayerKit

public class YBJWPlayerAdsAdapter: YBPlayerAdapter<AnyObject>  {

    private var delegate: JWPlayerDelegate?
    private var adDelegate: JWAdDelegate?

    private var adPosition: YBAdPosition = .unknown
    public var adPlayhead: Double = 0
    private var adTag: URL?
    private var currentQuartile: Int32 = 0
    
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
            adDelegate = player.adDelegate
            player.delegate = self
            player.adDelegate = self
        }
        monitorPlayhead(withBuffers: true, seeks: false, andInterval: 800)
        if plugin?.adsAdapter != nil {
            plugin?.adsAdapter?.fireStop()
        }
        resetValues()
    }
    
    public override func unregisterListeners() {
        if let player = player as? JWPlayer {
            player.delegate = delegate
            player.adDelegate = adDelegate
        }
        delegate = nil
        adDelegate = nil
        monitor?.stop()
        resetValues()
        super.unregisterListeners()
    }
    
    private func resetValues() {
        adPosition = .unknown
        adPlayhead = 0
        adTag = nil
        currentQuartile = 0
    }
    
    // MARK: - Getters
    
    public override func getPlayhead() -> NSNumber? {
        return NSNumber(value: adPlayhead)
    }
    
    public override func getPosition() -> YBAdPosition {
        return adPosition
    }
    
    public override func getResource() -> String? {
        guard let adTag = adTag else { return super.getResource() }
        return adTag.absoluteString
    }
    
    public override func fireStop(_ params: [String : String]?) {
        super.fireStop(params)
        resetValues()
    }
    
    // MARK: - Adapter info
    
    public override func getPlayerName() -> String? {
        return Constants.getAdsAdapterName()
    }
    
    public override func getPlayerVersion() -> String? {
        return Constants.getName()
    }
    
    public override func getVersion() -> String {
        return Constants.getAdsAdapterVersion()
    }

}

extension YBJWPlayerAdsAdapter: JWPlayerDelegate {
    
    public func jwplayerIsReady(_ player: JWPlayer) {
        delegate?.jwplayerIsReady(player)
    }
    
    public func jwplayer(_ player: JWPlayer, failedWithError code: UInt, message: String) {
        delegate?.jwplayer(player, failedWithError: code, message: message)
    }
    
    public func jwplayer(_ player: JWPlayer, failedWithSetupError code: UInt, message: String) {
        delegate?.jwplayer(player, failedWithSetupError: code, message: message)
    }
    
    public func jwplayer(_ player: JWPlayer, encounteredWarning code: UInt, message: String) {
        delegate?.jwplayer(player, encounteredWarning: code, message: message)
    }
    
    public func jwplayer(_ player: JWPlayer, encounteredAdWarning code: UInt, message: String) {
        delegate?.jwplayer(player, encounteredAdWarning: code, message: message)
        if code != 0 {
            fireError(withMessage: message, code: "\(code)", andMetadata: nil)
        }
    }

    public func jwplayer(_ player: JWPlayer, encounteredAdError code: UInt, message: String) {
        delegate?.jwplayer(player, encounteredAdError: code, message: message)
        fireFatalError(withMessage: message, code: "\(code)", andMetadata: nil)
    }
    
}

extension YBJWPlayerAdsAdapter: JWAdDelegate {
    
    public func jwplayer(_ player: AnyObject, adEvent event: JWAdEvent) {
        adDelegate?.jwplayer(player, adEvent: event)
        switch event.type {
            case .adBreakEnd:
                fireAdBreakStop()
            case .adBreakStart:
                fireAdBreakStart()
            case .clicked:
                let adUrl = event[JWAdEventKey.clickThroughUrl] as? String
                fireClick(withAdUrl: adUrl)
            case .complete:
                fireStop()
            case .impression:
                fireStart()
                fireJoin()
            case .meta: break
            case .pause:
                firePause()
            case .play:
                fireStart()
                fireJoin()
                fireResume()
            case .request:
                if let jwAdPosition = event[JWAdEventKey.adPosition] as? JWAdPosition {
                    if jwAdPosition == .pre {
                        adPosition = .pre
                    } else if jwAdPosition == .mid {
                        adPosition = .mid
                    } else if jwAdPosition == .post {
                        adPosition = .post
                    } else {
                        adPosition = .mid
                    }
                }
                if let jwAdTag = event[JWAdEventKey.tag] as? URL {
                    adTag = jwAdTag
                }
                fireAdManifest(nil)
            case .schedule: break
            case .skipped:
                fireStop(["skipped" : "true"])
            case .started: break
            case .companion: break
            default: break
        }
    }
    
}
