//
//  AddFundsView.swift
//  Satodime
//
//  Created by Lionel Delvaux on 02/11/2023.
//

import Foundation
import SwiftUI
import CryptoKit

struct AddFundsViewNew: View {
    // MARK: - Properties
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var viewStackHandler: ViewStackHandlerNew
    @EnvironmentObject var cardState: CardState
    @EnvironmentObject var infoToastMessageHandler: InfoToastMessageHandler

    var index: Int
    
    @State private var showingSafariView = false
    var urlHandler = UrlHandler()

    // MARK: Helpers
    func getHeaderImageName() -> String {
        guard index < cardState.vaultArray.count else {return "bg_red_gradient"}
        return cardState.vaultArray[index].getStatus() == .sealed ? "bg_header_addfunds" : "bg_red_gradient"
    }
    
    func getCoinSymbol() -> String {
        guard index < cardState.vaultArray.count else {return ""}
        return cardState.vaultArray[index].coin.coinSymbol
    }
    
    func getAddress() -> String {
        guard index < cardState.vaultArray.count else {return ""}
        return cardState.vaultArray[index].address
    }
    
    func copyAddressToClipboard() {
        UIPasteboard.general.string = self.getAddress()
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        generator.impactOccurred()
        infoToastMessageHandler.shouldShowCopiedToClipboardMessage = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            generator.impactOccurred()
        }
    }
    
    private func openUrl() {
        let apiKey = ""
        let hmacKey = ""
        let cryptoAddress = getAddress()
        let currencyCodeTo = getCoinSymbol()
        var url = "https://widget.paybis.com/"

        var query = "?partnerId=\(apiKey)" +
        "&cryptoAddress=\(cryptoAddress)" +
        "&currencyCodeFrom=EUR" +
        "&currencyCodeTo=\(currencyCodeTo)"
        guard let decodedKeyData = Data(base64Encoded: hmacKey) else {
            return
        }
        guard let hmacKeyData = Data(base64Encoded: hmacKey),
              let queryData = query.data(using: .utf8) else {
            return
        }
        
        let key = SymmetricKey(data: hmacKeyData)
        let signature = HMAC<SHA256>.authenticationCode(for: queryData, using: key)
        let signatureData = Data(signature)
        let encodedSignature = signatureData.base64EncodedString().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        query += "&signature=\(encodedSignature)"
        
        if let urlToOpen = URL(string: url + query) {
            urlHandler.urlToOpenInApp = urlToOpen
            showingSafariView = true
        } else {
            print("Invalid URL: \(url)")
        }
    }
    
    // MARK: - View
    var body: some View {
        ZStack {
            Constants.Colors.viewBackground
                .ignoresSafeArea()
            
            // VaultCard look
            VStack {
//                // TODO: use a VaultCardNew?
//                VaultCardNew(index: UInt8(index), action: {}, useFullWidth: true)
//                    .shadow(radius: 10)
//                Spacer()
                
                ZStack {
                    VStack {
                        Image(self.getHeaderImageName())
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width, height: 269)
                            .clipped()
                            .ignoresSafeArea()
                        
                        Spacer()
                    }
                    
                    VStack {
                        Spacer()
                            .frame(height: 38)
                        
                        HStack {
                            SatoText(text: "0\(index+1)", style: .slotTitle)
                            Spacer()
                        }
                        
                        Spacer()
                            .frame(height: 4)
                        HStack {
                            if let vault = cardState.vaultArray.get(index: index) {
                                SealStatusView(status: vault.getStatus())
                                Spacer()
                                VStack {
                                    Image(vault.coinMeta.icon)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 26, height: 26)
                                        .foregroundColor(.white)
                                    if vault.coin.isTestnet {
                                        SatoText(text: "TESTNET", style: .addressText)
                                    }
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    .padding([.leading, .trailing], Constants.Dimensions.bigSideMargin)
                }
                
                Spacer()
            }// VStack
            
            // Lower part
            ZStack {
                VStack {
                    Spacer()
                        .frame(height: 158)//148
                    
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .foregroundColor(Constants.Colors.bottomSheetBackground)
                        .clipShape(RoundedCorner(radius: 20, corners: [.topLeft, .topRight]))
                        .shadow(color: Color.black.opacity(0.5), radius: 10, x: 0, y: 0)
                        .ignoresSafeArea()
                        .edgesIgnoringSafeArea(.all)

                }
                ScrollView {
                    VStack(alignment: .center) {
                        Spacer()
                            .frame(height: 178)//168
                        
                        SatoText(text: "depositAddress", style: .title)
                        Spacer()
                            .frame(height: 22)
                        SatoText(text: self.getAddress(), style: .subtitle)

                        Spacer()
                            .frame(height: 30)

                        HStack(spacing: 15) {
                            SatoText(text: "copyToClipboard", style: .addressText)
                                .lineLimit(1)
                                .frame(alignment: .trailing)
                            
                            Spacer()
                                .frame(width: 2)
                            
                            Button(action: {
                                self.copyAddressToClipboard()
                            }) {
                                Image("ic_copy_clipboard")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        Spacer()
                            .frame(height: 30)

                        if let cgImage = QRCodeHelper().getQRfromText(text: self.getAddress()) {
                            Image(uiImage: UIImage(cgImage: cgImage))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 219, height: 219, alignment: .center)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                        }
                        Spacer()
                            .frame(height: 16)
                        SatoText(text: "serviceProvidedByPaybis", style: .lightSubtitle)
                        SatoButton(text: String(localized: "buyFromPaybis") + " \(getCoinSymbol())", style: .confirm, horizontalPadding: Constants.Dimensions.secondButtonPadding) {
                            openUrl()
                        }
                        
                        Spacer()
                            .frame(height: 16)
                        SatoText(text: "youOrAnybodyCanDepositFunds", style: .lightSubtitle)
                        
                        Spacer()
                    }
                    .padding([.leading, .trailing], Constants.Dimensions.defaultSideMargin)
                }
            }// ZStack
        }// ZStack
        .sheet(isPresented: $showingSafariView) {
            if let urlToOpenInApp = self.urlHandler.urlToOpenInApp {
                SafariView(url: urlToOpenInApp)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                SatoText(text: "addFunds", style: .lightTitle)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self.viewStackHandler.navigationState = .goBackHome
        }) {
            Image("ic_flipback")
        })
    } // body
    
}


