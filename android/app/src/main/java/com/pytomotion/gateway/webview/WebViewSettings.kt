package com.pytomotion.gateway.webview

import android.annotation.SuppressLint
import android.webkit.WebSettings
import android.webkit.WebView

@SuppressLint("SetJavaScriptEnabled")
fun setupWebViewSettings(webView: WebView) {
    webView.settings.apply {
        javaScriptEnabled = true
        domStorageEnabled = true
        databaseEnabled = true
        
        // Cache Strategy for responsive IoT dashboards
        cacheMode = WebSettings.LOAD_DEFAULT 
        
        // Security parameters for embedded interfaces
        allowFileAccess = false
        allowContentAccess = false
    }
}
