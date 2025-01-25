//
//  WebEventHandler.swift
//  rawgraphy
//
//  Created by 이동호 on 1/24/25.
//
import WebKit

class WebEventHandler {
    static func sendWebEvent(functionName: String, data: [String: Any], webView: WKWebView?) {
        print("📱 Sending Web Event - Function: \(functionName)")
        print("📦 Data: \(data)")
        
        do {
            if webView == nil {
                throw WebEventError.webViewNotFound
            }
            
            let jsonData: Data
            do {
                jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                print("✅ JSON Serialization successful")
            } catch {
                print("❌ JSON Serialization failed: \(error)")
                throw WebEventError.jsonSerializationFailed
            }
            
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                throw WebEventError.jsonStringEncodingFailed
            }
            
            let script = """
                (function() {
                    try {
                        \(functionName)(\(jsonString));
                        return true;
                    } catch(e) {
                        console.error('Error executing \(functionName):', e);
                        return false;
                    }
                })();
            """
            
            DispatchQueue.main.async { [weak webView] in
                webView?.evaluateJavaScript(script) { (result, error) in
                    if let error = error {
                        print("❌ WebView Evaluation Error:")
                        print("   - Description: \(error.localizedDescription)")
                        print("   - Debug Description: \(String(describing: (error as NSError).debugDescription))")
                        print("   - Error Code: \((error as NSError).code)")
                        print("   - Error Domain: \((error as NSError).domain)")
                    } else {
                        print("✅ Script executed successfully")
                        if let result = result {
                            print("📤 Result: \(result)")
                        }
                    }
                }
            }
            
        } catch WebEventError.webViewNotFound {
            print("❌ Error: WebView instance not found")
        } catch WebEventError.jsonSerializationFailed {
            print("❌ Error: Failed to serialize data to JSON")
        } catch WebEventError.jsonStringEncodingFailed {
            print("❌ Error: Failed to encode JSON data to string")
        } catch {
            print("❌ Unexpected error: \(error.localizedDescription)")
        }
    }
}

enum WebEventError: Error {
    case webViewNotFound
    case jsonSerializationFailed
    case jsonStringEncodingFailed
    case evaluationFailed(String)
}
