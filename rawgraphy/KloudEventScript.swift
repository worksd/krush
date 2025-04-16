//
//  KloudEventScript.swift
//  rawgraphy
//
//  Created by 이동호 on 1/24/25.
//

struct KloudEventScript {
    static func generate() -> String {
        """
        var meta = document.createElement('meta');
        meta.name = 'viewport';
        meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
        document.getElementsByTagName('head')[0].appendChild(meta);
        window.KloudEvent = {
            clearAndPush: function(data) { sendMessage('clearAndPush', data); },
            push: function(data) { sendMessage('push', data); },
            fullSheet: function(data) { sendMessage('fullSheet', data); },
            replace: function(data) { sendMessage('replace', data); },
            back: function() { sendMessage('back'); },
            rootNext: function(data) { sendMessage('rootNext', data); },
            clearToken: function() { sendMessage('clearToken'); },
            navigateMain: function(data) { sendMessage('navigateMain', data); },
            showToast: function(data) { sendMessage('showToast', data); },
            sendHapticFeedback: function() { sendMessage('sendHapticFeedback'); },
            sendAppleLogin: function() { sendMessage('sendAppleLogin'); },
            sendKakaoLogin: function() { sendMessage('sendKakaoLogin'); },
            showDialog: function(data) { sendMessage('showDialog', data); },
            requestPayment: function(data) { sendMessage('requestPayment', data); },
            registerDevice: function(data) { sendMessage('registerDevice'); },
            showBottomSheet: function(data) { sendMessage('showBottomSheet', data); },
            closeBottomSheet: function() { sendMessage('closeBottomSheet');},
            changeWebEndpoint: function(data) { sendMessage('changeWebEndpoint', data); },
            openExternalBrowser: function(data) { sendMessage('openExternalBrowser', data); },
        };

        function sendMessage(type, data = null) {
            window.webkit.messageHandlers.KloudEvent.postMessage({ type, data });
        }
        """
    }
}
