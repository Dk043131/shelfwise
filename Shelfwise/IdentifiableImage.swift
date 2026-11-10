import UIKit

extension UIImage: @retroactive Identifiable {
    public var id: String {
        "\(self.hashValue)"
    }
}
