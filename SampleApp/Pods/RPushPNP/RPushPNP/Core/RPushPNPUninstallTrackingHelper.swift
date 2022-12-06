import Foundation

// MARK: - ApsModel

private struct ApsModel: Decodable {
    // MARK: - CodingKeys

    enum CodingKeys: String, CodingKey {
        case contentAvailable = "content-available"
    }

    let contentAvailable: Int
}

// MARK: - PnpModel

private struct PnpModel: Decodable {
    // MARK: - CodingKeys

    enum CodingKeys: String, CodingKey {
        case uninstallTrackingPush = "_uninstall_tracking_push"
    }

    let uninstallTrackingPush: Int
}

// MARK: - ContentModel

private struct UninstallTrackingModel: Decodable {
    // MARK: - CodingKeys

    enum CodingKeys: String, CodingKey {
        case aps
        case pnp = "_pnp_reserved"
    }

    let aps: ApsModel
    let pnp: PnpModel
}

// MARK: - RPushPNPUninstallTrackingHelper

/// RPushPNPUninstallTrackingHelper provides an API to identify if a Push Notification is a PNP Uninstall Tracking Push Notification
/// https://confluence.rakuten-it.com/confluence/display/PNPD/SDK+-+Uninstall+tracking+push
@objc public final class RPushPNPUninstallTrackingHelper: NSObject {
    private static let decoder = JSONDecoder()

    /// Checks if a push notification payload is a PNP uninstall tracking push notification payload
    ///
    /// - Parameters:
    ///     - payload: the push notification payload.
    ///
    /// - Returns: `true` or `false`.
    @objc public static func isUninstallTracking(payload: [AnyHashable: Any]) -> Bool {
        guard let data = try? JSONSerialization.data(withJSONObject: payload, options: []),
              let model = try? decoder.decode(UninstallTrackingModel.self, from: data) else {
            return false
        }

        return model.aps.contentAvailable == 1 && model.pnp.uninstallTrackingPush == 1
    }
}
