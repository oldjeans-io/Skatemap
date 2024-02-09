import SwiftUI
import WebKit
import StoreKit
import UIKit

struct ContentView: View {
    @State var isSharePresented = false
    let texturl = "https://apps.apple.com/kr/app/skatemap/id6449299366"

    @State var showAlert: Bool = false
    @State var isAlertConfirmation: Bool = false
    @State var alertMessage: String = "error"
    
    

    var body: some View {
        ZStack(alignment: .bottom) {
            WebView(
                request: URLRequest(url: URL(string: "https://skatemap.kr/skatemap2.0.html")!),
                showAlert: self.$showAlert,
                alertMessage: self.$alertMessage
            )
            .alert(isPresented: self.$showAlert) {
                () -> Alert in
                var alert = Alert(title: Text(alertMessage))
                if isAlertConfirmation {
                    alert = Alert(
                        title: Text("알림"),
                        message: Text(alertMessage),
                        primaryButton: .default(Text("Confirm"), action: {
                            print("OK")
                        }),
                        secondaryButton: .cancel({
                            print("Cancel")
                        })
                    )
                }
                return alert
            }
        }
        .ignoresSafeArea()
        .onAppear(){
            print("webview is appeared")
        }
        .gesture(
                    // 키보드를 숨기기 위한 UITapGestureRecognizer를 추가합니다
                    TapGesture()
                        .onEnded { _ in
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                )
    }
}



struct WebView: UIViewRepresentable {
    let request: URLRequest
    @Binding var showAlert: Bool
    @Binding var alertMessage: String

    class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate {
        var parent: WebView
        var showAlert: Binding<Bool>
        var alertMessage: Binding<String>
        


        init(_ parent: WebView, showAlert: Binding<Bool>, alertMessage: Binding<String>) {
            self.parent = parent
            self.showAlert = showAlert
            self.alertMessage = alertMessage
        }
        
        @objc func keyboardWillDisappear() {
            //Do something here
            print("keyboardWillDisappear is called")
        }

        func webView(
            _ webView: WKWebView,
            runJavaScriptAlertPanelWithMessage message: String,
            initiatedByFrame frame: WKFrameInfo,
            completionHandler: @escaping () -> Void
        ) {
            self.alertMessage.wrappedValue = message
            self.showAlert.wrappedValue.toggle()
            completionHandler()
        }

        func webView(
            _ webView: WKWebView,
            runJavaScriptConfirmPanelWithMessage message: String,
            initiatedByFrame frame: WKFrameInfo,
            completionHandler: @escaping (Bool) -> Void
        ) {
            self.alertMessage.wrappedValue = message
            self.showAlert.wrappedValue.toggle()
            completionHandler(true)
        }

        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            // 새 창을 열려고 하는지 확인
            guard navigationAction.targetFrame == nil else {
                return nil // 현재 창에서 열도록 브라우저에 위임
            }
            
            if let url = navigationAction.request.url {
                // 새 창에서 열려는 URL에 대한 처리
                if url.absoluteString != "about:blank" {
                    // 외부 브라우저에서 열기
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    return nil
                }
            }
            
            // about:blank 등의 특수 URL이거나 처리할 수 없는 경우
            return nil
        }
        
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self, showAlert: self.$showAlert, alertMessage: self.$alertMessage)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webview = WKWebView()
        webview.uiDelegate = context.coordinator
        webview.navigationDelegate = context.coordinator
        webview.allowsBackForwardNavigationGestures = true
        
        // 키보드의 인터엑션 모드를 지정한다. 기본값은 none이다.
        // webview.scrollView.keyboardDismissMode = .interactiveWithAccessory
        webview.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        print("webview ui delegation is done")
        
        // 첫 페이지를 로드한다. 이 위치가 변경되면 잦은 리로드가 일어날 수 있음
        webview.load(request)
        print("Loading page")
        
        return webview
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        /*
         View의 상태가 변경될 때 호출된다
         예를 들어 레이블의 값 등을 바꾸어야 할 때 관련 코드를 추가한다.
         */
    }
    
    
}

extension WKWebView {
    override open var safeAreaInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension SKStoreReviewController {
    public static func requestReviewInCurrentScene() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            DispatchQueue.main.async {
                requestReview(in: scene)
            }
        }
    }
}
