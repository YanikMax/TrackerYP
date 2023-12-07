import Foundation
import YandexMobileMetrica

final class AnalyticsService {
    enum Screen: String {
        case main
    }
    
    enum Event: String {
        case open
        case close
        case click
    }
    
    enum Item: String {
        case add_track
        case track
        case filter
        case edit
        case delete
    }
    
    static let shared = AnalyticsService()
    
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "edc8dd70-6af6-472c-9148-f03346f60628") else { return }
        
        YMMYandexMetrica.activate(with: configuration)
    }
    
    private func sendEvent(_ eventName: Event, screen: Screen, item: Item? = nil) {
        let params: [AnyHashable: Any] = [
            "event": eventName.rawValue,
            "screen": screen.rawValue,
            "item": item?.rawValue ?? ""
        ]
        
        YMMYandexMetrica.reportEvent("EVENT", parameters: params, onFailure: { error in
            print("REPORT ERROR: \(error.localizedDescription)")
        })
        
        print("Event Sent: \(params)")
    }
    
    func sendOpenScreenEvent(screen: Screen) {
        sendEvent(.open, screen: screen)
    }
    
    func sendCloseScreenEvent(screen: Screen) {
        sendEvent(.close, screen: screen)
    }
    
    func sendButtonClickEvent(screen: Screen, item: Item) {
        sendEvent(.click, screen: screen, item: item)
    }
}
