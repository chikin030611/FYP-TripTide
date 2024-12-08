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
                Group {
                    Button {
                        openInMaps()
                        dismiss()
                    } label: {
                        Text("Open in Maps")
                            .frame(maxWidth: .infinity)
                    }
                    .foregroundStyle(themeManager.selectedTheme.primaryColor)
                    
                    Button {
                        openInGoogleMaps()
                        dismiss()
                    } label: {
                        Text("Open in Google Maps")
                            .frame(maxWidth: .infinity)
                    }
                    .foregroundStyle(themeManager.selectedTheme.primaryColor)
                    
                    Button {
                        UIPasteboard.general.string = address
                        onCopy()
                        dismiss()
                    } label: {
                        Text("Copy Address")
                            .frame(maxWidth: .infinity)
                    }
                    .foregroundStyle(themeManager.selectedTheme.primaryColor)
                }
                .listRowBackground(Color.clear)
                .buttonStyle(.plain)
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