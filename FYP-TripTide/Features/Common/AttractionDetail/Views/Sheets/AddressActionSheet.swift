import SwiftUI
import MapKit

struct AddressActionSheet: View {
    let address: String

    @StateObject var themeManager = ThemeManager()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Button {
                    openInMaps()
                    dismiss()
                } label: {
                    Label("Open in Maps", systemImage: "map")
                }
                .foregroundStyle(themeManager.selectedTheme.primaryColor)
                
                Button {
                    openInGoogleMaps()
                    dismiss()
                } label: {
                    Label("Open in Google Maps", systemImage: "map.fill")
                }
                .foregroundStyle(themeManager.selectedTheme.primaryColor)
                
                Button {
                    UIPasteboard.general.string = address
                    dismiss()
                } label: {
                    Label("Copy Address", systemImage: "doc.on.doc")
                }
                .foregroundStyle(themeManager.selectedTheme.primaryColor)
            }
            .listStyle(.plain)
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