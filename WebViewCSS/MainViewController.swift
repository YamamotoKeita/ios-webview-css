import UIKit
import WebKit

class MainViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView! {
        didSet {
            webView.navigationDelegate = self
            loadBaseHTML()
        }
    }

    private var isHTMLReady = false
    private var afterReady: (() -> Void)?

    func loadBaseHTML() {
        if let htmlPath = Bundle.main.path(forResource: "pr-offer-quest", ofType: "html") {
            let htmlUrl = URL(fileURLWithPath: htmlPath, isDirectory: false)
            webView.loadFileURL(htmlUrl, allowingReadAccessTo: htmlUrl)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        reserveBody(html: TestData.data[0])
    }


    @IBAction func body1Action(_ sender: Any) {
        reserveBody(html: TestData.data[0])
    }

    @IBAction func body2Action(_ sender: Any) {
        reserveBody(html: TestData.data[1])
    }

    @IBAction func body3Action(_ sender: Any) {
        reserveBody(html: TestData.data[2])
    }
    
    func reserveBody(html: String) {
        if isHTMLReady {
            setBody(html: html)
        } else {
            afterReady = { [weak self] in
                self?.setBody(html: html)
            }
        }
    }

    private func setBody(html: String) {
        let escaped = escapeForStringLiteral(html)
        let script = "document.body.innerHTML = '\(escaped)';"
        webView?.evaluateJavaScript(script)
    }

    func escapeForStringLiteral(_ src: String) -> String {
        let conversion = [
            "\r": "",
            "\n": "\\n",
            "\"": "\\\"",
            "\'": "\\'",
            "\t": "\\t",
        ]
        var result = src
        conversion.forEach {key, value in
            result = result.replacingOccurrences(of: key, with: value)
        }
        return result
    }
}

extension MainViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView.url?.absoluteString == "about:blank" { return }
        isHTMLReady = true
        afterReady?()
        afterReady = nil
    }
}
