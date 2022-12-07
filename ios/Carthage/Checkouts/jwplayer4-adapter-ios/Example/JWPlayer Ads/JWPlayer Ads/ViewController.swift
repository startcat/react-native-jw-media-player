//
//  ViewController.swift
//  JWPlayer Ads
//
//  Created by David Almaguer on 09/08/21.
//

import UIKit
import JWPlayerKit
import YouboraLib
import YouboraConfigUtils
import YouboraJWPlayerAdapter

class ViewController: JWPlayerViewController {
    
    var resource: String?
    var containAds: Bool!
    
    private let adUrlString = "https://playertest.longtailvideo.com/pre-60s.xml"
    private let videoUrlString = "https://cdn.jwplayer.com/videos/CXz339Xh-sJF8m8CA.mp4"
    private let posterUrlString = "https://cdn.jwplayer.com/thumbs/CXz339Xh-720.jpg"
    
    var plugin: YBPlugin?
    var adsAdapter: YBJWPlayerAdsAdapter?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let options = YouboraConfigManager.getOptions()
        
        plugin = YBPlugin(options: options)

        // Set up the player.
        setUpPlayer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.isMovingFromParent {
            plugin?.fireStop()
            plugin?.removeAdapter()
            plugin?.removeAdsAdapter()
        }
    }

    /**
     Sets up the player with an advertising configuration.
     */
    private func setUpPlayer() {
        let videoUrl = URL(string:resource ?? videoUrlString)!
        let posterUrl = URL(string:posterUrlString)!
        let adURL = URL(string: adUrlString)!

        // Open a do-catch block to handle possible errors with the builders.
        do {
            // First, use the JWPlayerItemBuilder to create a JWPlayerItem that will be used by the player configuration.
            let playerItem = try JWPlayerItemBuilder()
                .file(videoUrl)
                .posterImage(posterUrl)
                .build()

            // Second, use the JWAdsAdvertisingConfigBuilder to create a JWAdvertisingConfig that will be used by the player configuration.
            // Third, create a player config with the created JWPlayerItem and JWAdvertisingConfig
            let config: JWPlayerConfiguration
            if containAds {
                let adConfig = try JWAdsAdvertisingConfigBuilder()
                    // Set the VAST tag for the builder to use.
                    .tag(adURL)
                    .build()
                
                config = try JWPlayerConfigurationBuilder()
                    .playlist([playerItem])
                    .advertising(adConfig)
                    .autostart(true)
                    .build()
            } else {
                config = try JWPlayerConfigurationBuilder()
                    .playlist([playerItem])
                    .autostart(true)
                    .build()
            }

            // Lastly, use the created JWPlayerConfiguration to set up the player.
            player.configurePlayer(with: config)
            
            plugin?.adapter = YBJWPlayerAdapter(player: player)
            
            if containAds {
                adsAdapter = YBJWPlayerAdsAdapter(player: player)
                plugin?.adsAdapter = adsAdapter
            }
            
        } catch {
            print(error.localizedDescription)
            return
        }
    }

    //pragma MARK: - Related advertising methods

    // Reports when an event is emitted by the player.
    override func jwplayer(_ player: AnyObject, adEvent event: JWAdEvent) {
        super.jwplayer(player, adEvent: event)

        switch event.type {
        case .adBreakStart:
            print("Ad break has begun")
        case .schedule:
            print("The ad(s) has been scheduled")
        case .request:
            print("The ad has been requested")
        case .started:
            print("The ad playback has started")
        case .impression:
            print("The ad impression has been fulfilled")
        case .meta:
            print("The ad metadata is ready")
        case .clicked:
            print("The ad has been tapped")
        case .pause:
            print("The ad playback has been paused")
        case .play:
            print("The ad playback has been resumed")
        case .skipped:
            print("The ad has been skipped")
        case .complete:
            print("The ad playback has finished")
        case .adBreakEnd:
            print("The ad break has finished")
        default:
            break
        }
    }

    // This method is triggered when a time event fires for a currently playing ad.
    override func onAdTimeEvent(_ time: JWTimeData) {
        super.onAdTimeEvent(time)
        // If you are not interested in the ad time data, avoid overriding this method due to performance reasons.
        adsAdapter?.adPlayhead = time.position
    }

    // When the player encounters an ad warning within the SDK, this method is called on the delegate.
    // Ad warnings do not prevent the ad from continuing to play.
    override func jwplayer(_ player: JWPlayer, encounteredAdWarning code: UInt, message: String) {
        super.jwplayer(player, encounteredAdWarning: code, message: message)

        print("An ad warning has been encountered: (\(code))-\(message)")
    }

    // When the player encounters an ad error within the SDK, this method is called on the delegate.
    // Ad errors prevent ads from playing, but do not prevent media playback from continuing.
    override func jwplayer(_ player: JWPlayer, encounteredAdError code: UInt, message: String) {
        super.jwplayer(player, encounteredAdError: code, message: message)

        print("An ad error has been encountered: (\(code))-\(message)")
    }

}
