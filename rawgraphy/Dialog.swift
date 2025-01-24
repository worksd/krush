import SwiftUI

enum KloudDialogType: String {
    case simple = "SIMPLE"
    case image = "IMAGE"
}

struct KloudDialogInfo: Codable {
    let id: String
    let type: String
    let route: String?
    let hideForeverMessage: String?
    let imageUrl: String?
    let imageRatio: Float?
    let title: String?
    let message: String?
    let ctaButtonText: String?
}

struct KloudDialog: View {
    let dialogInfo: KloudDialogInfo
    let onClick: (KloudDialogInfo) -> Void
    let onClickHideDialog: (String, Bool) -> Void
    let onDismiss: () -> Void
    
    @State private var isHideForeverClicked = false
    
    var body: some View {
        if dialogInfo.type == KloudDialogType.simple.rawValue {
            SimpleDialogScreen(
                id: dialogInfo.id,
                title: dialogInfo.title ?? "",
                message: dialogInfo.message,
                onDismiss: onDismiss
            )
        } else if dialogInfo.type == KloudDialogType.image.rawValue {
            ImageDialogScreen(
                id: dialogInfo.id,
                hideForeverMessage: dialogInfo.hideForeverMessage,
                imageUrl: dialogInfo.imageUrl ?? "",
                imageRatio: dialogInfo.imageRatio ?? 1.0,
                ctaButtonText: dialogInfo.ctaButtonText,
                onDismiss: onDismiss,
                onClick: { id in
                    onClick(dialogInfo)
                },
                onClickHideDialog: onClickHideDialog
            )
        }
    }
}

struct ImageDialogScreen: View {
    let id: String
    let hideForeverMessage: String?
    let imageUrl: String
    let imageRatio: Float
    let ctaButtonText: String?
    let onDismiss: () -> Void
    let onClick: (String) -> Void
    let onClickHideDialog: (String, Bool) -> Void
    
    var body: some View {
        VStack {
            if let hideMessage = hideForeverMessage {
                HideForeverRow(
                    id: id,
                    message: hideMessage,
                    onClickHideDialog: onClickHideDialog
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            VStack {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                } placeholder: {
                    ZStack {
                        Color.white
                    }.frame(width: 320).aspectRatio(CGFloat(imageRatio), contentMode: .fit)
                }
                .frame(maxWidth: 320)
                .aspectRatio(CGFloat(imageRatio), contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .onTapGesture {
                    onDismiss()
                    onClick(id)
                }
                
                if let buttonText = ctaButtonText {
                    Button(action: {
                        onDismiss()
                        onClick(id)
                    }) {
                        Text(buttonText)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .foregroundColor(.white)
                            .background(Color.black)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .padding(.top, 16)
                }
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            Button(action: onDismiss) {
                Image("ic_circle_close")
                    .resizable()
                    .frame(width: 44, height: 44)
            }
            .padding(.top, 16)
        }
    }
}

struct HideForeverRow: View {
    let id: String
    let message: String
    let onClickHideDialog: (String, Bool) -> Void
    
    @State private var isHideForeverClicked = false
    
    var body: some View {
        HStack(spacing: 6) {
            Image(isHideForeverClicked ? "ic_check_filled" : "ic_check")
            Text(message)
                .foregroundColor(.white)
                .lineSpacing(20)
                .fontWeight(.bold)
        }
        .padding(.leading, 12)
        .padding(.bottom, 16)
        .onTapGesture {
            isHideForeverClicked.toggle()
            onClickHideDialog(id, isHideForeverClicked)
        }
    }
}

struct SimpleDialogScreen: View {
    let id: String
    let title: String
    let message: String?
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(alignment: .center) {
            Text(title)
                .font(.system(size: 16))
                .fontWeight(.bold)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
            
            if let message = message {
                Text(message)
                    .padding(.top, 8)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: onDismiss) {
                Text("확인")
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .foregroundColor(.white)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.top, 20)
        }
        .padding(20)
        .background(Color(hex: 0xEFEFEF))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// Color Extension for hex support
extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}
