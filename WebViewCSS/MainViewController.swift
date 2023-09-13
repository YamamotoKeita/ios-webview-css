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

    func appendStyleSheet(_ css: String) {
        let escapedCss = escapeForStringLiteral(css)
        var script = "var style = document.createElement('style');"
        script += "style.type = 'text/css';"
        script += "var content = document.createTextNode('\(escapedCss)');"
        script += "style.appendChild(content);"
        script += "document.body.appendChild(style);"
        webView?.evaluateJavaScript(script)
    }

    func appendBody() {
        let escaped = escapeForStringLiteral(TestData.prOfferBody)
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

    func readResourceString(name: String, type: String) -> String? {
        if let path = Bundle.main.path(forResource: name, ofType: type) {
            do {
                return try String(contentsOfFile: path)
            } catch  {
                print(error)
            }
        }
        return nil
    }
}

extension MainViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView.url?.absoluteString == "about:blank" { return }

        if let css = readResourceString(name: "pr-offer-quest", type: "css") {
            appendStyleSheet(css)
        }
        appendBody()
    }
}
