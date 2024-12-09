import SwiftUI

let transportTip = Tip(
    id: UUID(),
    coverImage: "https://dummyimage.com/600x400/07162e/ffffff",
    author: "TripTide",
    publishDate: Date(),
    title: "Transport in Tokyo",
    content: [
        .header("Introduction"),
        .text("Tokyo is a city of contrasts..."),
        .header("1. Secret Garden"),
        .text("Hidden behind the busy streets..."),
        .image("https://dummyimage.com/600x400/07162e/ffffff"),
        .quote("This place is magical - Local resident"),
        .bulletPoints([
            "Best visited during spring",
            "Open from 9 AM to 5 PM",
            "Free entrance"
        ])
    ],
    reference: "Hong Kong Tourism Board",
    referenceLink: "https://www.disneyland.com.hk"
)

let paymentTip = Tip(
    id: UUID(),
    coverImage: "https://dummyimage.com/600x400/07162e/ffffff", 
    author: "TripTide",
    publishDate: Date(),
    title: "Payment in Tokyo",
    content: [
        .header("Content"),
        .text("Lorem ipsum odor amet, consectetuer adipiscing elit. Sodales purus nulla habitant bibendum; eu curabitur. Orci integer vehicula aliquam tempus massa. Eleifend pellentesque id mi duis ligula praesent. Pulvinar aptent lacus magna eget leo interdum tellus. Dui dignissim mattis id elementum adipiscing inceptos condimentum nullam? Id nisi tellus elementum dictum feugiat id nisl. Auctor himenaeos sed sollicitudin a etiam massa. Auctor sollicitudin accumsan taciti parturient nullam mollis volutpat ultrices vel. Ante nibh ut libero maecenas tempus adipiscing vehicula auctor pretium. Non rutrum aliquet luctus venenatis justo gravida. Tempor cubilia inceptos rhoncus, pretium luctus dolor. Mauris hac curabitur venenatis himenaeos magnis. Eget eros semper eros pharetra vehicula luctus lorem maximus."),
        .image("https://dummyimage.com/600x200/07162e/ffffff")
    ],
    reference: "Hong Kong Tourism Board",
    referenceLink: "https://www.disneyland.com.hk"
)

let weatherTip = Tip(
    id: UUID(),
    coverImage: "https://dummyimage.com/600x400/07162e/ffffff",
    author: "TripTide", 
    publishDate: Date(),
    title: "Weather in Tokyo",
    content: [
        .text("Lorem ipsum odor amet, consectetuer adipiscing elit. Lobortis potenti fermentum donec faucibus orci adipiscing malesuada. Accumsan nibh netus penatibus parturient convallis nunc. Nisl primis cursus est efficitur elit curabitur. Cubilia parturient eu eu ante sit quisque mauris. Lacus conubia lacus morbi nisi; imperdiet efficitur aliquam. Cras morbi in turpis sapien finibus mauris ipsum est. Facilisis malesuada phasellus scelerisque erat maecenas libero sollicitudin magna luctus. Nibh volutpat montes integer eget cubilia ligula. Iaculis cursus congue phasellus, himenaeos porttitor neque velit. Mattis lobortis nunc convallis senectus magnis. Tempor duis urna ad curabitur tincidunt. Mauris dictum facilisis feugiat enim massa. Odio proin litora molestie lorem turpis sollicitudin mollis per. Primis dignissim euismod aliquet hendrerit sit. Conubia per fusce convallis dictumst; maecenas parturient. Vivamus ut fermentum hendrerit pharetra faucibus nec. Torquent magna at magnis commodo sem bibendum orci habitasse. Fermentum massa euismod proin porta euismod justo conubia eu maecenas. Vitae massa ad massa varius, tellus cras. Facilisis enim per magna mus mauris accumsan. Efficitur nulla sem; lorem maecenas dapibus dui magnis quam. Posuere primis malesuada quisque quam sem felis. Dui elementum facilisis congue malesuada gravida sem molestie! Augue elit vehicula placerat quisque; at penatibus est velit vehicula. Volutpat nostra fringilla massa; feugiat rhoncus metus dictum. Aenean dictum cras in a pharetra tristique aptent. Augue mus nunc lectus elit posuere habitant. Sagittis inceptos potenti accumsan laoreet fusce leo. Dolor primis sodales vestibulum condimentum faucibus purus justo a. Aliquam adipiscing a natoque elit quam euismod convallis dapibus. Enim ornare ut efficitur convallis leo. Potenti quis viverra cursus nibh augue dis? Luctus fames hendrerit laoreet dui nisi laoreet odio hac. Habitant scelerisque lectus volutpat donec ornare himenaeos pulvinar. Amollis dolor class egestas quis hendrerit tempor. Neque elit consectetur egestas gravida justo natoque massa eu. Venenatis potenti duis vitae facilisis quis pellentesque. Cras ex ex habitant dictum suscipit. Vehicula condimentum class integer; fames cursus sagittis.")
    ],
    reference: "Hong Kong Tourism Board", 
    referenceLink: "https://www.disneyland.com.hk"
)

let sampleTips = [
    transportTip,
    paymentTip,
    weatherTip,
]

// Get a tip by id
func getTip(by id: UUID) -> Tip? {
    return sampleTips.first { $0.id == id }
}
