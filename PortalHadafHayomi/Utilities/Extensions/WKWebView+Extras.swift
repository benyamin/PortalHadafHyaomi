//
//  WKWebView+Extras.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 13/03/2023.
//  Copyright © 2023 Binyamin Trachtman. All rights reserved.
//

import Foundation
import WebKit

extension WKWebView {
    
    func highlightText(_ searchString: String) {
        
        if let plistPath = Bundle.main.path(forResource: "UIWebViewSearch", ofType: "js"){
            
            do {
                let jsCode = try String(contentsOfFile: plistPath, encoding: String.Encoding.utf8)
                self.evaluateJavaScript(jsCode, completionHandler: nil)
                
                let startSearch = "uiWebview_HighlightAllOccurencesOfString('\(searchString)')"
                self.evaluateJavaScript(startSearch, completionHandler: nil)
                
                let result = self.evaluateJavaScript("uiWebview_SearchResultCount", completionHandler: nil)
               
            } catch {
            }
        }
    }
    
    func clearHighlightedText() {
        self.evaluateJavaScript("uiWebview_RemoveAllHighlights()", completionHandler: nil)
    }
    
    /*
     - (void)scrollTo:(int)index {
         [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"uiWebview_ScrollTo('%d')",index]];
     }

     - (void)removeAllHighlights
     {
         [self stringByEvaluatingJavaScriptFromString:@"uiWebview_RemoveAllHighlights()"];
     }
     */
}
