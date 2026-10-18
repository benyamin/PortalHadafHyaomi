// ============================================================
// GENERAL.JS - MODERNIZED VERSION
// Updated to use modern JavaScript and jQuery patterns
// Removed IE6/7 specific hacks and deprecated methods
// ============================================================

// Modern browser detection using feature detection instead of user agent sniffing
var BrowserDetect = {
	isIE: function() {
		// Check for IE 11 and below
		return 'ActiveXObject' in window || navigator.userAgent.indexOf('Trident/') > -1;
	},
	isEdge: function() {
		return navigator.userAgent.indexOf('Edge/') > -1 || navigator.userAgent.indexOf('Edg/') > -1;
	},
	isChrome: function() {
		return navigator.userAgent.indexOf('Chrome') > -1 && !this.isEdge();
	},
	isFirefox: function() {
		return navigator.userAgent.indexOf('Firefox') > -1;
	},
	isSafari: function() {
		return navigator.userAgent.indexOf('Safari') > -1 && !this.isChrome() && !this.isEdge();
	}
};

// Legacy variables for backward compatibility (deprecated - use BrowserDetect methods instead)
var bChrome = BrowserDetect.isChrome();
var bIE = BrowserDetect.isIE();
var bIE6 = false; // IE6 support removed - no longer needed
var bIE7 = false; // IE7 support removed - no longer needed

$(document).ready(function(){
	// IE6/7 specific code removed - no longer needed in modern web
	// Modern browsers handle CSS consistently
});

function fComboRewrite(){
	// IE6 specific code removed - no longer needed
	// Modern browsers handle select elements consistently
}

// Get mouse Y position (cross-browser compatible)
function fMousePozTop(e) {
	e = e || window.event;
	return e.pageY || (e.clientY + document.documentElement.scrollTop);
}

// Get mouse X position (cross-browser compatible)
function fMousePozLeft(e) {
	e = e || window.event;
	return e.pageX || (e.clientX + document.documentElement.scrollLeft);
}

function fShowTooltip(sTip){
	var $tooltip = $('#oTooltip');
	$tooltip.html(sTip)
		.css({
			top: fMousePozTop() + 10 + 'px',
			left: fMousePozLeft() - 210 + 'px'
		})
		.show();
}

function fHideTooltip(){
	$('#oTooltip').html('').hide();
}

// NOTE: Flash is deprecated and no longer supported by modern browsers
// These functions are kept for legacy compatibility only
// Consider migrating to HTML5 video/audio elements

function fWriteFlashObject(sID, sUrl, nWidth, nHeight, sBG, bTransparent, sCssClass, bLiveCon, bAutoResize){
	console.warn('Flash is deprecated. Consider using HTML5 video/audio instead.');
	document.write('<object id="'+ sID +'" width="'+ nWidth +'" height="'+ nHeight +'" class="'+ sCssClass +'" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,0,0" classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000">')
	document.write('<param name="movie" value="'+ sUrl +'">')
	if(bTransparent) document.write('<param name="wmode" value="transparent" />');
	document.write('<param name="bgcolor" value="'+ sBG +'" />');
	document.write('<param name="quality" value="high">');
	document.write('<embed id="'+ sID +'" src="'+ sUrl +'" width="'+ nWidth +'" height="'+ nHeight +'" class="'+ sCssClass +'" bgcolor="'+ sBG +'" '+ (bTransparent ? 'wmode="transparent"' : '') +' quality="high"  TYPE="application/x-shockwave-flash" PLUGINSPAGE="http://www.macromedia.com/go/getflashplayer"></embed>')
	document.write('</object>');

	if(bAutoResize){
		var obj = document.getElementById(sID);
		obj.width = obj.GetVariable('Stage.width');
		obj.height = obj.GetVariable('Stage.height');
		obj.style.display = "block";
	}
}

function fReturnFlashObject(sID, sUrl, nWidth, nHeight, sBG, bTransparent, sCssClass, bLiveCon){
	console.warn('Flash is deprecated. Consider using HTML5 video/audio instead.');
	var sSSL = location.protocol === 'https:' ? 's' : '';
	var str = '';
	str += '<object id="'+ sID +'" width="'+ nWidth +'" height="'+ nHeight +'" class="'+ sCssClass +'" swLiveConnect="'+ (bLiveCon ? 'true' : 'false') +'" codebase="http' + sSSL + '://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,0,0" classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000">';
	str += '<param name="movie" value="'+ sUrl +'">';
	if(bTransparent) str += '<param name="wmode" value="transparent" />';
	str += '<param name="bgcolor" value="'+ sBG +'" />';
	str += '<param name="quality" value="high">';
	str += '<embed id="'+ sID +'" src="'+ sUrl +'" width="'+ nWidth +'" height="'+ nHeight +'" class="'+ sCssClass +'" bgcolor="'+ sBG +'" '+ (bTransparent ? 'wmode="transparent"' : '') +' quality="high"  TYPE="application/x-shockwave-flash" PLUGINSPAGE="http' + sSSL + '://www.macromedia.com/go/getflashplayer"></embed>';
	str += '</object>';
	return str;
}

// Generate email link with obfuscation to prevent spam harvesting
function fPrintEmailLink(sUserName, sDomain, linkText, linkTitle, cssClass, sSubject, sBody){
	if(!sUserName || !sDomain) return false;
	
	var sLinkText = linkText || (sUserName + "@" + sDomain);
	var sQS = '';
	
	if(sSubject || sBody) sQS += "?";
	if(sSubject) sQS += "subject=" + encodeURIComponent(sSubject);
	if(sSubject && sBody) sQS += "&";
	if(sBody) sQS += "body=" + encodeURIComponent(sBody);
	
	var titleAttr = sLinkTitle ? ' title="' + sLinkTitle + '"' : '';
	var classAttr = cssClass ? ' class="' + cssClass + '"' : '';
	
	document.write('<a' + titleAttr + classAttr + ' href="m&#97;ilto:' + sUserName + '&#64;' + sDomain + sQS + '">' + sLinkText + '</a>');
}

function fSendMsg(sUserName){
	fPopupLayer("/forums/messages/im_send.asp?to=" + sUserName);
}

function fChangeCssClass(sObjName, sClass){
	var $obj = $('#' + sObjName);
	if (!$obj.hasClass('clsSelected')) {
		// Note: This replaces ALL classes with sClass
		// If you need to preserve other classes, use .addClass() instead
		$obj.attr('class', sClass);
	}
}

function fChangeDisplay(sObjName){
	$('#' + sObjName).toggle();
}

function fChangeTablerowDisplay(num){
	var $row = $('#oDescTR' + num);
	var $btn = $('#oTrToggleBtn' + num);
	$btn.html($btn.html() === '(סגור)' ? '(קרא עוד)' : '(סגור)');
	$row.toggle();
}

function fTableRow(sObjTR, sObjRow){
	$('#' + sObjTR).toggle();
	$('#' + sObjRow).toggleClass('clsSelected');
}

function fIsHeb(str){
	return /[א-ת]/.test(str);
}

function PopUp(url, width, height){
	window.open(url, null, "width=" + (width || 500) + ", height=" + (height || 300) + ", scrollbars=yes, resizable=no");
}

function fPopupImage(url){
	if(url) window.open("/imgPopUp.asp?url=" + url, "winPopupImage", "width=5,height=5");
}

function fImagePopup(url){
	if(url) window.open("/imgPopUp.asp?url=" + url, "winPopupImage", "width=5,height=5");
}

function fSendToFriend(){
	window.open("/Send2Friend.asp?title=" + encodeURIComponent(document.title), "winSendToFriend", "width=400,height=470");
}

function fPrintPage(){
	window.open('/print.htm', 'winPrint', 'width=750, height=400, scrollbars=yes');
}

function fAddToFavorites(){
	// Modern browsers use Ctrl+D / Cmd+D to bookmark
	// Legacy IE and Firefox methods no longer work in modern browsers
	if (window.sidebar && window.sidebar.addPanel) {
		// Old Firefox (deprecated)
		window.sidebar.addPanel(document.title, top.location.href, '');
	} else {
		// Inform user to use browser's built-in bookmark feature
		var shortcut = navigator.userAgent.indexOf('Mac') !== -1 ? 'Cmd+D' : 'Ctrl+D';
		alert('לחץ ' + shortcut + ' כדי להוסיף דף זה למועדפים');
	}
}

// NOTE: Windows Media Player is deprecated
// Consider migrating to HTML5 <audio> or <video> elements
function fWriteMovieObject(sUrl){
	if(!sUrl) return false;
	
	console.warn('Windows Media Player is deprecated. Consider using HTML5 video/audio instead.');
	
	var nHeight = 0;
	var sExt = sUrl.substr(sUrl.length - 3);
	
	if(sExt === "wma" || sExt === "mp3") {
		nHeight = 150;
	} else if(sExt === "wmv") {
		nHeight = 320;
	} else {
		return false;
	}

	document.write('<object width="320" height="' + nHeight + '" classid="CLSID:6BF52A52-394A-11d3-B153-00C04F79FAA6">');
	document.write('<param name="url" value="' + sUrl + '">');
	document.write('<param name="uimode" value="full">');
	document.write('<param name="autostart" value="0">');
	document.write('<param name="rate" value="1">');
	document.write('<param name="balance" value="0">');
	document.write('<param name="currentPosition" value="-1">');
	document.write('<param name="defaultFrame" value>');
	document.write('<param name="playCount" value="1">');
	document.write('<param name="currentMarker" value="0">');
	document.write('<param name="invokeURLs" value="-1">');
	document.write('<param name="baseURL" value>');
	document.write('<param name="volume" value="50">');
	document.write('<param name="mute" value="0">');
	document.write('<param name="stretchToFit" value="0">');
	document.write('<param name="windowlessVideo" value="0">');
	document.write('<param name="enabled" value="-1">');
	document.write('<param name="enableContextMenu" value="-1">');
	document.write('<param name="fullScreen" value="0">');
	document.write('<param name="SAMIStyle" value>');
	document.write('<param name="SAMILang" value>');
	document.write('<param name="SAMIFilename" value>');
	document.write('<param name="captioningID" value>');
	document.write('<param name="enableErrorDialogs" value="0">');
	document.write('<embed width="320" height="320" src="' + sUrl + '" filename="' + sUrl + '" autostart="false" showcontrols="True" showstatusbar="True" showdisplay="True" autorewind="True"></embed>');
	document.write('</object>');
}

// Disable form buttons to prevent double submission
function blockFormButtons(elem) {
	var $form = elem._form ? $(elem._form) : $(elem);
	var $buttons = $form.find('input[type="submit"], input[type="button"]');
	
	$buttons.prop('disabled', true).css('cursor', 'wait');
	
	return true;
}
