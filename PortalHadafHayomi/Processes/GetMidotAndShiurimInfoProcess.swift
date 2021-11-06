//
//  GetMidotAndShiurimInfoProcess.swift
//  PortalHadafHayomi
//
//  Created by Binyamin Trachtman on 04/11/2018.
//  Copyright © 2018 Binyamin Trachtman. All rights reserved.
//

import Foundation

open class GetMidotAndShiurimInfoProcess: MSBaseProcess
{
    open override func executeWithObj(_ obj:Any?)
    {
        var linksInfo = [[String:String]]()
        
        linksInfo.append(["title":"st_mitzvot_quantity_title",
                          "subTitle":"st_mitzvot_quantity_subtitle",
                          "link":"http://www.daat.ac.il/encyclopedia/value.asp?id1=1598"])
        
        linksInfo.append(["title":"st_comparison_table_title",
                          "subTitle":"st_comparison_table_subtitle",
                          "link":"http://www.daat.ac.il/encyclopedia/value.asp?id1=1600"])
        
         linksInfo.append(["title":"st_milin_value_title",
                           "subTitle":"st_milin_value_subtitle",
                           "link":"http://www.daat.ac.il/daat/vl/tohen.asp?id=126"])
        
         linksInfo.append(["title":"st_torah_measurements_title",
                           "subTitle":"st_torah_measurements_subtitle",
                           "link":"http://www.daat.ac.il/daat/vl/tohen.asp?id=143"])
        
         linksInfo.append(["title":"st_hidorai_measurments_title",
                           "subTitle":"st_hidorai_measurments_subtitle",
                           "link":"http://daf-yomi.com/BookFiles.aspx?type=1&id=362"])
        
        linksInfo.append(["title":"st_rambam_measurements_title",
                          "subTitle":"st_rambam_measurements_subtitle",
                          "link":"http://www.daat.ac.il/daat/toshba/halacha/midot-2.htm"])
        
        linksInfo.append(["title":"st_measurments_ratio_title",
                          "subTitle":"st_measurments_ratio_subtitle",
                          "link":"http://www.daf-yomi.com/data/uploadedfiles/userfiles/tafrit-kleyezer-midotveshiurim-matbehot.pdf"])
        
        linksInfo.append(["title":"st_volume_ratio_title",
                          "subTitle":"st_volume_ratio_subtitle",
                          "link":"http://www.daf-yomi.com/data/uploadedfiles/userfiles/tafrit-kleyezer-midotveshiurim-nefach.pdf"])
        
        linksInfo.append(["title":"st_detailed_measurements_table_title",
                          "subTitle":"st_detailed_measurements_table_subtitle",
                          "link":"http://daf-yomi.com/data/uploadedfiles/userfiles/tafrit-kleyezer-midotveshiurim-tavla.pdf"])
        
    
        linksInfo.append(["title":"st_torah_weights_title",
                          "subTitle":"st_torah_weights_subtitle",
                          "link":"http://daf-yomi.com/Data/UploadedFiles/UserFilesCK/tafrit-kleyezer-midotveshiurim-swed.doc"])
      /*
        linksInfo.append(["title":"מידה כנגד מידה",
                          "subTitle":"אפליקציה להמרת מידות חז׳׳ל למידות מודרניות",
                          "link":"https://sites.google.com/site/midacenegedmida/home"])
 */
        
        linksInfo.append(["title":"st_wiki_measurements_title",
                          "subTitle":"st_wiki_measurements_subtitle",
                          "link":"https://he.wikipedia.org/wiki/%D7%A8%D7%A9%D7%99%D7%9E%D7%AA_%D7%9E%D7%99%D7%93%D7%95%D7%AA,_%D7%A9%D7%99%D7%A2%D7%95%D7%A8%D7%99%D7%9D_%D7%95%D7%9E%D7%A9%D7%A7%D7%9C%D7%95%D7%AA_%D7%91%D7%94%D7%9C%D7%9B%D7%94"])
        
        
       var links = [LinkInfo]()
        
        for linkInfo in linksInfo
        {
            let link = LinkInfo(dictionary: linkInfo)
            
            links.append(link)
        }
        
        self.onComplete?(links)
    }
}
