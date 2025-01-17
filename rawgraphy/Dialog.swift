//
//  Dialog.swift
//  rawgraphy
//
//  Created by 이동호 on 1/17/25.
//

import SwiftUI

struct KrushDialog: View {
    
    let onDismissRequest: () -> Void
    let title: String
    let bodyText: String
    let cancelText: String
    let confirmText: String
    let onClickConfirm: () -> Void
    
    var body: some View {
        ZStack {
            
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading) {
                    Headline2(text: title)
                    Spacer().frame(height:12)
                    Body2(text: bodyText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.all, 28)
                .background(.white)
                Rectangle().fill(.gray).frame(maxWidth: .infinity, maxHeight: 1)
                GeometryReader { geo in
                    HStack(spacing :0) {
                        Text(cancelText)
                            .frame(width: geo.size.width * 0.5, height: geo.size.height)
                            .background(.white)
                            .onTapGesture {
                                onDismissRequest()
                            }
                        
                        Subtitle1(text: confirmText, color: .white)
                            .frame(width: geo.size.width * 0.5, height: geo.size.height)
                            .background(.black)
                            .onTapGesture {
                                onClickConfirm()
                            }
                    }
                }.frame(maxWidth: .infinity, maxHeight: 44, alignment: .center)
            }
            .frame(width: 300, alignment: .leading)
            .cornerRadius(8)
            .onTapGesture {
                
            }

            
        }.frame(maxWidth: .infinity, maxHeight: .infinity).background(.white)
            .onTapGesture {
                onDismissRequest()
            }
        
    }
    
    
}


func Headline1(text: String, color: Color = .black, textAlign: TextAlignment = .leading) -> some View {
    Text(text).font(.system(size: 22, weight: .bold)).kerning(-0.2).foregroundColor(color).multilineTextAlignment(textAlign)
}

func Headline2(text: String, color: Color = .black, textAlignment: TextAlignment = .leading) -> some View {
    Text(text).font(.system(size: 20, weight: .bold)).kerning(-0.4).foregroundColor(color).multilineTextAlignment(textAlignment)
}

func Title1(text: String, color: Color = .black, textAlign: TextAlignment = .leading) -> some View {
    Text(text).font(.system(size: 18, weight: .regular)).kerning(-0.4).foregroundColor(color).multilineTextAlignment(textAlign)
}

func Title2(text: String, color: Color = .black, textAlign: TextAlignment = .leading) -> some View {
    Text(text).font(.system(size: 16, weight: .bold, design: .rounded)).kerning(0.2).foregroundColor(color).multilineTextAlignment(textAlign)
}

func Subtitle1(text: String, color: Color = .black, textAlign: TextAlignment = .leading) -> some View {
    Text(text).font(.system(size: 16, weight: .medium)).kerning(0.2).foregroundColor(color).multilineTextAlignment(textAlign)
}

func Subtitle2(text: String, color: Color = .black) -> some View {
    Text(text).font(.system(size: 14, weight: .bold, design: .rounded)).kerning(0.4).foregroundColor(color)
}

func Body1(text: String, color: Color = .black, textAlign: TextAlignment = .leading) -> some View {
    Text(text).font(.system(size: 14, weight: .regular)).kerning(0.2).foregroundColor(color).multilineTextAlignment(textAlign)
}

func Body2(text: String, color: Color = .black, textAlign: TextAlignment = .leading) -> some View {
    Text(text).font(.system(size: 12, weight: .regular)).kerning(0.4).foregroundColor(color).multilineTextAlignment(textAlign)
}

func Body3(text: String, color: Color = .black, textAlign: TextAlignment = .leading) -> some View {
    Text(text).font(.system(size: 10, weight: .regular)).kerning(0.4).foregroundColor(color).multilineTextAlignment(textAlign)
}
