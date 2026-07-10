package com.pytomotion.gateway.webview

import android.webkit.WebResourceRequest
import android.webkit.WebView
import android.webkit.WebViewClient

class GatewayWebViewClient : WebViewClient() {
    override fun shouldOverrideUrlLoading(view: WebView, request: WebResourceRequest): Boolean {
        val urlString = request.url.toString()
        
        // Return false to let the WebView render pages that target your custom Flask port
        return if (urlString.contains(":3767")) {
            false 
        } else {
            // Return true to block unknown external links or pass them to an intent browser
            true 
        }
    }
}
