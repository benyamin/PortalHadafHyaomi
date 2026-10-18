
var oLastMenuBtn, oLastMenuObj, oMenuBtn, oMenuObj;
var oLastSubMenuBtn, oLastSubMenuObj, oMenuBtn, oMenuObj;

function fMainMenu(oMenuBtn){
	oMenuBtn=document.getElementById(oMenuBtn)

	if(oLastSubMenuObj){
		oLastSubMenuObj.style.display="none";
		$(".clsOpened").removeClass("clsOpened");
		oLastSubMenuBtn=null;
		oLastSubMenuObj=null;
	}
	
	if(oLastMenuBtn || oLastMenuBtn==oMenuBtn){
		$(".clsOpened").removeClass("clsOpened");
		$(oLastSubMenuBtn).removeClass("clsOpened");
		if(oLastMenuObj) oLastMenuObj.style.display="none";
		if(oLastMenuBtn==oMenuBtn){
			oLastMenuBtn=null;
			oLastMenuObj=null;
			return;
		}
	}

	oMenuObj=$(oMenuBtn).next().get(0)

	if(oMenuObj){
		oMenuObj.style.display="block";
		$(oMenuBtn).addClass("clsOpened");
	}

	oLastMenuBtn=oMenuBtn;
	oLastMenuObj = oMenuObj;	
}


function fSubMenu(oSubMenuBtn){
	oSubMenuBtn=document.getElementById(oSubMenuBtn)
	
	if(oLastSubMenuBtn || oLastSubMenuBtn==oSubMenuBtn){
		$("ul li ul li .clsOpened").removeClass("clsOpened");
		if(oLastSubMenuObj) oLastSubMenuObj.style.display="none";
		if(oLastSubMenuBtn==oSubMenuBtn) {oLastSubMenuBtn=null; oLastSubMenuObj=null; return;}
	}
	
	oSubMenuBtn=$(oSubMenuBtn).parent().children().get(0);
	oSubMenuObj=$(oSubMenuBtn).parent().children().next().get(0);
		
	if(oSubMenuBtn && !$(oSubMenuBtn).hasClass("clsSelected") && !$(oSubMenuBtn).hasClass("clsNoChilds")) oSubMenuBtn.className="clsOpened";
	if(oSubMenuObj) oSubMenuObj.style.display="block";

	oLastSubMenuBtn=oSubMenuBtn;
	oLastSubMenuObj = oSubMenuObj;	
}

