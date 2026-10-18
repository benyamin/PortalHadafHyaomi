function fDisplayPollResults(pollId){
	//window.setTimeout(function(){
	 $.ajax({
		 type: "GET",
		 url: "/xml_files/pollresults.aspx?id=" + pollId + "&rnd=" + Math.random(),
		 dataType: "xml",
		 success: function(xml) {
		     var oAnsArr=[], i=0;
		     $(xml).find('answer').each(function(){
				var title= $(this).find('title').text()
				var votes= $(this).find('votes').text()
				oAnsArr[i++]=[title,votes]
			 }); //close each(
			 fBuildGraph(oAnsArr,pollId);
		 }
	 }); //close $.ajax(
	//},Math.floor(Math.random()*2000+100));
 }; //close $(

function fBuildGraph(g,qid){
	var total=0, output, calpercentage, calwidth, gwidth=125, percentTotal=0
	var arrColors=["#971d68","#fdb458","#97b762","#83bdb1"], colorsI=0
	for (var i=0;i<g.length;i++)
		total+=parseInt(g[i][1])
	output='<table border="0" cellspacing="0" cellpadding="0">'
	for  (i=0;i<g.length;i++){
		calpercentage=Math.round(g[i][1]*100/total)
		if(!calpercentage)calpercentage=0
		percentTotal+=calpercentage

		if(i+1==g.length){
			if(percentTotal>100){
				calpercentage-=(percentTotal-100)
			}
			if(percentTotal<100){
				calpercentage+=(100-percentTotal)
			}
		}
		calwidth=Math.round(gwidth*(calpercentage/100))
		if(!calwidth || g[i][0]==0)calwidth=1

		output+='<tr><td></td><td style=\"color:#000066; font-size:11px; padding-top:5px;\"><div class=\"clsSpacer\" style=\"height:10px; width:'+calwidth+'px; background-color:' + arrColors[colorsI] + ';\" ></div>'+g[i][0]+' ('+calpercentage+'%)</td></tr>'
		colorsI++
		if(colorsI>=arrColors.length) colorsI=0
	}
	output+='</table>'
	document.getElementById("oPollDiv"+qid).innerHTML=output
	try{document.getElementById("oPollDivOpts"+qid).style.display="none";}catch(e){}
}

function fPollVote(pollId, frm){
    var ansId=0, grp=frm.PL_Answers;
    for(var i=0;i<grp.length && ansId==0;i++){
        if(grp[i].checked){
            ansId=grp[i].value
        }
    }

    if(ansId==0){
        alert("עליך לבחור תשובה")
        return
    }

    //window.open("/ajaxfiles/pollvote.aspx?id=" + pollId + "&ansId=" + ansId + "&rnd=" + Math.random())
    $.ajax({
        type: "GET",
        url: "/ajaxfiles/pollvote.aspx?id=" + pollId + "&ansId=" + ansId + "&rnd=" + Math.random(),
        dataType: "xml",
        success: function(xml) {
            var msg
            $(xml).find('msg').each(function() {
                var msg = $(this).find('msg').text()
            }); //close each(
            if (msg) {
                alert(msg)
            }
            if (window.location.href.toLowerCase().indexOf('mobile') < 0) {
                location.href = "/pollResults.aspx?id=" + pollId;
            }
            else {
                location.href = "/pollResults.aspx?mobile=1&id=" + pollId;
            }
        }
    });

}

function fBuildVerticalGraph(g){
	var total=0, output="", calpercentage, calwidth, gwidth=100, percentTotal=0
	var arrColors = ["#971d68", "#fdb458", "#97b762", "#83bdb1", "#7e6faa", "#ff6f69", "#5f4b8b", "#88b04b", "#92a8d1"], colorsI = 0
	for (var i=0;i<g.length;i++)
		total+=parseInt(g[i][1])

	for  (i=0;i<g.length;i++){
		calpercentage=Math.round(g[i][1]*100/total)
		percentTotal+=calpercentage
		if(!calpercentage)calpercentage=0
		if(i+1==g.length && percentTotal){
			if(percentTotal>100){
				calpercentage-=(percentTotal-100)
			}
			if(percentTotal<100){
				calpercentage+=(100-percentTotal)
			}
		}
		calwidth=Math.round(gwidth*(calpercentage/100))
		if(!calwidth)calwidth=1
		output+='<div class="clsBar"><span style="color:' + arrColors[colorsI] + ';">'+calpercentage+'%</span><span class="clsBarInner" style="border-bottom:'+(calwidth*2)+'px solid ' + arrColors[colorsI] + ';"></span><div style="height:30px;">'+g[i][0] + '</div></div>'
		//output+='<div class="clsBar">'+calpercentage+'%<span class="clsBarInner" style="height:'+calwidth+'px; margin-top:'+ (200-calwidth) +'px; background-color:' + arrColors[colorsI] + ';" ></span>'+g[i][0] + '</div>'
		colorsI++
		if(colorsI>=arrColors.length) colorsI=0
	}
	
	document.getElementById("oPollDiv").innerHTML=output
}
