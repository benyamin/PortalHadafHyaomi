var arrQubHeightsNormal=[];
var arrQubHeightsShrinked=[0,92,77,45,62,33,33];

function fFormatQubsHeight(){
	var obj, expandBtn, i;
	for (i=1; i<arrQubHeightsShrinked.length; i++){
		obj=document.getElementById("oQub"+i);
		if (!obj) continue;
		arrQubHeightsNormal[i]=obj.offsetHeight;
		obj.style.height=arrQubHeightsShrinked[i] +"px";
		expandBtn = document.getElementById("oExpandBtn"+i);
		if(expandBtn && arrQubHeightsNormal[i]>(arrQubHeightsShrinked[i]+5)) {
			expandBtn.style.display="block";
		}
	}
	var tabContent1 = document.getElementById("oTabContent1");
	var tabContent2 = document.getElementById("oTabContent2");
	if (tabContent1) tabContent1.style.display="none";
	if (tabContent2) tabContent2.style.display="none";
	fChangeTab(1);
}

function fTrim(str){
	if (typeof str == "string") return( str.replace(/^\s*([\s\S]*\S+)\s*$|^\s*$/,'$1') ); 
}

function fExpandQub(nQubNum){
	var obj=document.getElementById("oQub"+nQubNum);
	var btn=document.getElementById("oExpandBtn"+nQubNum);
	
	if(fTrim(btn.innerHTML)=="עוד"){
		btn.innerHTML="סגירה";
		btn.className="clsShowLess";
		obj.style.height=arrQubHeightsNormal[nQubNum]+"px";
	}
	else{
		btn.innerHTML="עוד";
		btn.className="clsShowMore";
		obj.style.height=arrQubHeightsShrinked[nQubNum]+"px";
	}
}


var nLastTab;
function fChangeTab(nTabNum){
	var obj, tabBtn, expandBtn, qub;

	if (nLastTab) {
		if(nLastTab==nTabNum) return;
		tabBtn = document.getElementById("oTabBtn"+nLastTab);
		if (tabBtn) tabBtn.className="clsTabOff"+nLastTab;
		obj = document.getElementById("oTabContent"+nLastTab);
		if (obj) obj.style.display="none";
		
		qub = document.getElementById("oQub6");
		if (qub) qub.style.height=arrQubHeightsShrinked[6] +"px";
		expandBtn = document.getElementById("oExpandBtn6");
		if (expandBtn) {
			expandBtn.style.display="block";
			expandBtn.className="clsShowMore";
			expandBtn.innerHTML="עוד";
		}
	}

	tabBtn = document.getElementById("oTabBtn" + nTabNum);
	if (tabBtn) tabBtn.className="clsTabOn"+nTabNum;
	obj=document.getElementById("oTabContent"+nTabNum);
	if (!obj) return;
	obj.style.display="block";	
	obj.style.height="auto";
	arrQubHeightsNormal[6]=obj.offsetHeight;
	obj.style.height=arrQubHeightsShrinked[6] +"px";
	expandBtn = document.getElementById("oExpandBtn6");
	if(expandBtn && arrQubHeightsNormal[6]<=arrQubHeightsShrinked[6]) {
		expandBtn.style.display="none";
	}

	nLastTab = nTabNum;
}

function fShowPageLinks(bShow){
	if(document.getElementById("oPageLinksBox").innerHTML=="") return;
	document.getElementById("oPageLinksBox").style.display=(bShow?"block":"none");
}

function initTicker(el) {
	var inner = el.querySelector('.js-ticker-inner');
	if (!inner) return;

	var containerHeight = el.offsetHeight;
	var contentHeight = inner.scrollHeight;

	if (contentHeight <= containerHeight) return;

	// Require at least 3 items to avoid visible duplication with short lists.
	// Forum tickers are table-based (count <tr>); news tickers are link-based (count <a>).
	var rows = inner.querySelectorAll('tr');
	var itemCount = rows.length > 0 ? rows.length : inner.querySelectorAll('a').length;
	if (itemCount < 3) return;

	// Duplicate content so the second copy seamlessly follows the first
	inner.innerHTML = inner.innerHTML + inner.innerHTML;

	var scrollAmount = parseFloat(el.getAttribute('data-scrollamount')) || 1;
	var scrollDelay  = parseFloat(el.getAttribute('data-scrolldelay'))  || 85;
	var pixelsPerMs  = scrollAmount / scrollDelay;
	var durationMs   = contentHeight / pixelsPerMs;

	// CSS animation takes over; pause-on-hover handled by .js-ticker:hover rule
	el.style.setProperty('--ticker-duration', (durationMs / 1000).toFixed(1) + 's');
	inner.classList.add('js-ticker-active');
}