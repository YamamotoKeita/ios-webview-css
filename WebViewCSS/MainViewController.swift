import UIKit
import WebKit

class MainViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!

    var webView: WKWebView?

    override func viewDidLoad() {
        super.viewDidLoad()
        load()
    }

    func load() {
        let webView = createWebView()
        if let htmlPath = Bundle.main.path(forResource: "pr-offer-quest", ofType: "html") {
            let htmlUrl = URL(fileURLWithPath: htmlPath, isDirectory: false)
            webView.loadFileURL(htmlUrl, allowingReadAccessTo: htmlUrl)
        }
    }

    func createWebView() -> WKWebView {
        self.webView?.removeFromSuperview()

        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: CGRect.zero, configuration: config)
        webView.isInspectable = true
        webView.navigationDelegate = self
        self.webView = webView

        containerView.addSubview(webView)

        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.leadingAnchor.constraint(equalTo:containerView.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        return webView
    }

    func setBody(html: String) {
        let escaped = escapeForStringLiteral(html)
        let script = "document.body.innerHTML = '\(escaped)';"
        webView?.evaluateJavaScript(script)
    }

    func escapeForStringLiteral(_ src: String) -> String {
        let stringLiteralConversion = [
            "\r": "",
            "\n": "\\n",
            "\"": "\\\"",
            "\'": "\\'",
            "\t": "\\t",
        ]
        var result = src
        stringLiteralConversion.forEach {key, value in
            result = result.replacingOccurrences(of: key, with: value)
        }
        return result
    }
}

extension MainViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView.url?.absoluteString == "about:blank" { return }
        setBody(html: TestData.prOfferBody)
    }
}
