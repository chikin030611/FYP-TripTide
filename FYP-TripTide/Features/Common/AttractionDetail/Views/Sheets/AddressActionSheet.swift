import SwiftUI
import MapKit

struct AddressActionSheet: View {
    let address: String
    var onCopy: () -> Void
    
    @StateObject var themeManager = ThemeManager()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Button {
                    openInMaps()
                    dismiss()
                } label: {
                    Text("Open in Maps")
                        .font(themeManager.selectedTheme.bodyTextFont)
                }
                
                Button {
                    openInGoogleMaps()
                    dismiss()
                } label: {
                    Text("Open in Google Maps")
                        .font(themeManager.selectedTheme.bodyTextFont)
                }
                
                Button {
                    UIPasteboard.general.string = address
                    onCopy()
                    dismiss()
                } label: {
                    Text("Copy Address")
                        .font(themeManager.selectedTheme.bodyTextFont)
                }
            }
            .listStyle(.plain)
            .foregroundStyle(themeManager.selectedTheme.primaryColor)
            .navigationTitle("Address")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.height(200)])
    }
    
    private func openInMaps() {
        let addressString = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "maps://?address=\(addressString)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openInGoogleMaps() {
        let addressString = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "comgooglemaps://?q=\(addressString)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                // Fallback to Google Maps website
                let webUrl = URL(string: "https://www.google.com/maps/search/?api=1&query=\(addressString)")!
                UIApplication.shared.open(webUrl)
            }
        }
    }
} 