package com.pytomotion.gateway

import android.content.Context
import android.os.Bundle
import android.webkit.WebSettings
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.activity.ComponentActivity
import androidx.activity.compose.BackHandler
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.viewinterop.AndroidView

import com.pytomotion.gateway.webview.GatewayWebViewClient
import com.pytomotion.gateway.webview.setupWebViewSettings


class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        
        val sharedPrefs = getSharedPreferences("gateway_settings", Context.MODE_PRIVATE)

        setContent {
            // Read stored IP or fall back to default
            var currentIp by remember { 
                mutableStateOf(sharedPrefs.getString("target_ip", "192.168.1.2") ?: "192.168.1.2") 
            }
            
            // Build the complete local network URL structure
            val targetUrl = "http://$currentIp:3767"

            MainScreen(
                currentUrl = targetUrl,
                onIpChanged = { newIp ->
                    sharedPrefs.edit().putString("target_ip", newIp).apply()
                    currentIp = newIp
                }
            )
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MainScreen(currentUrl: String, onIpChanged: (String) -> void) {
    var showMenu by remember { mutableStateOf(false) }
    var webViewRef by remember { mutableStateOf<WebView?>(null) }

    // Dynamically trigger page loads when user targets a different endpoint
    LaunchedEffect(currentUrl) {
        webViewRef?.loadUrl(currentUrl)
    }

    BackHandler(enabled = webViewRef?.canGoBack() == true) {
        webViewRef?.goBack()
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("PyToMotion Gateway") },
                actions = {
                    Box {
                        IconButton(onClick = { showMenu = true }) {
                            Icon(Icons.Default.MoreVert, contentDescription = "Settings Menu")
                        }
                        DropdownMenu(
                            expanded = showMenu,
                            onDismissRequest = { showMenu = false }
                        ) {
                            DropdownMenuItem(
                                text = { Text("Switch to Gateway .2 (192.168.1.2)") },
                                onClick = {
                                    onIpChanged("192.168.1.2")
                                    showMenu = false
                                }
                            )
                            DropdownMenuItem(
                                text = { Text("Switch to Gateway .3 (192.168.1.3)") },
                                onClick = {
                                    onIpChanged("192.168.1.3")
                                    showMenu = false
                                }
                            )
                        }
                    }
                }
            )
        }
    ) { innerPadding ->
        AndroidView(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding),
            factory = { context ->
                WebView(context).apply {
                    setupWebViewSettings(this) // Configured from your isolated file
                    webViewClient = GatewayWebViewClient() // Handled by your custom routing engine
                    loadUrl(currentUrl)


                    webViewRef = this
                    
                    // Engine Optimizations
                    settings.apply {
                        javaScriptEnabled = true
                        domStorageEnabled = true
                        cacheMode = WebSettings.LOAD_DEFAULT
                    }
                    
                    webViewClient = object : WebViewClient() {
                        override fun shouldOverrideUrlLoading(
                            view: WebView, 
                            request: android.webkit.WebResourceRequest
                        ): Boolean {
                            val urlString = request.url.toString()
                            // Only load URLs targeting your Flask application locally
                            return !urlString.contains(":3767")
                        }
                    }
                    
                    loadUrl(currentUrl)
                }
            },
            update = { /* Relying on LaunchedEffect hook for updates */ }
        )
    }
}
