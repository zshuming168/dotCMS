<%@page import="com.liferay.portal.util.PortalUtil"%>
<%@page import="java.util.Calendar"%>
<%@page import="com.dotmarketing.util.WebKeys"%>
<%@page import="com.liferay.portal.model.User"%>
<%@page import="com.dotmarketing.business.APILocator"%>
<%@page import="com.dotmarketing.business.Layout"%>
<%@page import="java.util.List"%>
<%
String error=null;
String message=null;
String newLicenseMessage="";
String newLicenseURL="";
if (request.getMethod().equalsIgnoreCase("POST") ) {
	error=LicenseUtil.processForm(request);
	
	boolean isCommunity = ("100".equals(System
            .getProperty("dotcms_level")));
    newLicenseURL = "http://www.dotcms.com/buy-now";
    List<Layout> layoutListForLicenseManager=null;
    try {
        if (isCommunity) {

            layoutListForLicenseManager=APILocator.getLayoutAPI().loadLayoutsForUser(PortalUtil.getUser(request));
            for (Layout layoutForLicenseManager:layoutListForLicenseManager) {
                List<String> portletIdsForLicenseManager=layoutForLicenseManager.getPortletIds();
                if (portletIdsForLicenseManager.contains("EXT_LICENSE_MANAGER")) {
                    newLicenseURL = "/c/portal/layout?p_l_id=" + layoutForLicenseManager.getId() +"&p_p_id=EXT_LICENSE_MANAGER&p_p_action=0";
                    newLicenseMessage = LanguageUtil.get(pageContext, "Try-Enterprise-Now") + "!" ;
                    break;
                }
            }

        } else {
            boolean isPerpetual = new Boolean(System
                    .getProperty("dotcms_license_perpetual"));
            boolean isTrial = true;
            try{
                isTrial = (System.getProperty("dotcms_license_client_name").toLowerCase().indexOf("trial") >-1);
            }
            catch(Exception e){}
            Date td = new Date();
            Date ed = new Date(Long.parseLong(System
                    .getProperty("dotcms_valid_until")));

            Calendar start = Calendar.getInstance();
            Calendar end = Calendar.getInstance();
            start.setTime(td);
            start.set(Calendar.HOUR, 0);
            start.set(Calendar.MINUTE, 0);
            start.set(Calendar.SECOND, 0);
            start.set(Calendar.MILLISECOND, 0);
            end.setTime(ed);
            long milliseconds1 = start.getTimeInMillis();
            long milliseconds2 = end.getTimeInMillis();
            long diff = milliseconds2 - milliseconds1;
            long diffDays = diff / (24 * 60 * 60 * 1000);
            if (!isPerpetual && isTrial) {
                if (diffDays > 1) {
                	newLicenseMessage = LanguageUtil.format(pageContext, "days-remaining-Purchase-now",diffDays,false);
                    newLicenseURL = "http://dotcms.com/buy-now";
                }
                if (diffDays == 1) {
                	newLicenseMessage = LanguageUtil.format(pageContext, "day-remaining-Purchase-now",diffDays,false);
                    newLicenseURL = "http://dotcms.com/buy-now";
                }
                if (diffDays < 1) {
                	newLicenseMessage = LanguageUtil.get(pageContext,"Trial-Expired-Purchase-Now");
                    newLicenseURL = "http://dotcms.com/buy-now";
                }

            }else if (!isPerpetual) {
                if (diffDays > 1 && diffDays < 30) {
                	newLicenseMessage = LanguageUtil.format(pageContext, "Subscription-expires-in-days",diffDays,false);
                    newLicenseURL = "http://dotcms.com/renew-now";
                }
                if (diffDays == 1) {
                	newLicenseMessage = LanguageUtil.format(pageContext, "Subscription-expires-in-day",diffDays,false);
                    newLicenseURL = "http://dotcms.com/renew-now";
                }
                if (diffDays < 1) {
                	newLicenseMessage = LanguageUtil.get(pageContext,"Subscription-Expired-Renew-Now");
                    newLicenseURL = "http://dotcms.com/buy-now";
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

}


boolean isCommunity = ("100".equals(System.getProperty("dotcms_level")));

String expireString = "unknown";
Date expires = null;
try{
	expires = new Date(Long.parseLong(System.getProperty("dotcms_valid_until")));
    SimpleDateFormat format =
        new SimpleDateFormat("MMMM d, yyyy");
    expireString=  format.format(expires);
}
catch(Exception e){
	
}
boolean expired = (expires !=null && expires.before(new Date()));



String licenseFormStr = LicenseUtil.getRequestForm();

if(!UtilMethods.isSet(licenseFormStr)){
	licenseFormStr = LanguageUtil.get(pageContext, "Behind-A-Proxy-Request-A-License");
	
}







%>

<%@page import="com.dotmarketing.util.UtilMethods"%>
<%@page import="java.util.Date"%>
<%@page import="com.liferay.portal.language.LanguageUtil"%>
<%@page import="com.dotcms.enterprise.LicenseUtil"%>
<%@page import="java.text.SimpleDateFormat"%>
<script type="text/javascript">

<%if(UtilMethods.isSet(error)){ %>
	showDotCMSSystemMessage("<%=error %>");
<%} if(request.getMethod().equalsIgnoreCase("POST")){ %>
	var newLicenseMesssage = "<%=newLicenseMessage%>";
	var newLicenseURL = "<%=newLicenseURL%>";
	if(newLicenseMesssage != ""){
		dojo.attr('goEnterpriseLink','href',newLicenseURL);
		dojo.attr('goEnterpriseLink','innerHTML',newLicenseMesssage);
	}else{
		dojo.style("goEnterpriseLink",{display:"none"});
	}
<%}%>

	function showRequestLicense(){

       var myDialog = dijit.byId("dotRequestLicenseDialog");
       myDialog.show();

	}

function doShowHideRequest(){
	
	if(dijit.byId("pasteRadio").checked){
		dojo.style("pasteMe", "display", "");
		dojo.style("requestMe", "display", "none");
	}
	else{
		dojo.style("pasteMe", "display", "none");
		dojo.style("requestMe", "display", "");
	
	}


}

function doPaste(){
	if(!<%=isCommunity%>){
		
		if(!confirm("<%= LanguageUtil.get(pageContext, "confirm-license-override") %>")){
			return false;
		}
		
	}

	dojo.byId("uploadLicenseForm").submit();
}

</script>
<div class="portlet-wrapper">


	<div style="min-height:400px;" id="borderContainer" class="shadowBox headerBox">							
	 	<div style="padding:7px;">
		 	<div>
				<h3><%= LanguageUtil.get(pageContext, "com.dotcms.repackage.portlet.javax.portlet.title.EXT_LICENSE_MANAGER") %></h3>
		  	</div>
				<br clear="all">
	  	</div>
	  
			<%if(request.getAttribute("LICENSE_APPLIED_SUCCESSFULLY") != null){ %>
				<div style="margin-left:auto;margin-right:auto;width:600px;" class="callOutBox">
					<%= LanguageUtil.get(pageContext, "license-trial-applied-successfully") %>
				</div>
			<%} %>
			
		<form name="query" id="uploadLicenseForm" action="<%= com.dotmarketing.util.PortletURLUtil.getRenderURL(request,null,null,"EXT_LICENSE_MANAGER") %>" method="post" onsubmit="return false;">
			<div style="width:600px;margin:auto;border:1px solid silver;padding:20px;background:#eee;">
				<dl>
					<dt>
						<span class='<%if(isCommunity){  %>lockIcon<%}else{ %>unlockIcon<%} %>'></span>
							<%= LanguageUtil.get(pageContext, "license-level") %>
						</dt>
						<dd><%= System.getProperty("dotcms_level_name")  %>
					</dd>
					<% if (!isCommunity) { %>
						<dt><%= LanguageUtil.get(pageContext, "license-valid-until") %>:</dt>
						<dd><%if(expired){ %><font color="red"><%} %>
						<%= expireString%>
						<%if(expired){ %> (expired)</font><%} %>
						</dd>
						<dt><%= LanguageUtil.get(pageContext, "licensed-to") %></dt>
						<dd><%=  UtilMethods.isSet(System.getProperty("dotcms_license_client_name")) ? System.getProperty("dotcms_license_client_name") + "": "No License Found" %></dd>
						<dt><%= LanguageUtil.get(pageContext, "license-serial") %></dt>
						<dd><%=  UtilMethods.isSet(System.getProperty("dotcms_license_serial")) ? System.getProperty("dotcms_license_serial") : "No License Found" %></dd>

						</dd>
					<% } %>
				</dl>
			</div>
			
			
			<%if(isCommunity){ %>
				<div style="margin:auto;width:500px;padding-top:30px;">
					<%= LanguageUtil.get(pageContext, "license-trial-promo") %>
				</div>
			<%} %>
			<div style="margin:auto;width:600px;padding:20px;padding-top:0px;">
				<dl style="padding:20px;">
					<%if(isCommunity){ %>
						<dt><%= LanguageUtil.get(pageContext, "I-want-to") %>:</dt>
						<dd>
							
							<input onclick="doShowHideRequest()" type="radio" checked="true" name="iwantTo" id="requestRadio"  dojoType="dijit.form.RadioButton" value="request_license">
							<label for="requestRadio"><%= LanguageUtil.get(pageContext, "request-trial-license") %></label><br/>

							<input onclick="doShowHideRequest()"  type="radio" name="iwantTo" id="pasteRadio"  dojoType="dijit.form.RadioButton" value="paste_license">
							<label for="pasteRadio"><%= LanguageUtil.get(pageContext, "I-already-have-a-license") %></label><br/>

						</dd>
					<%} %>
					
			 		<dt>
					<dd id="requestMe" style="<%if(!isCommunity){ %>display:none<%} %>">
						<button  id="requestTrialButton" iconClass="keyIcon" onclick="showRequestLicense()"  dojoType="dijit.form.Button" value="request_trial"><%= LanguageUtil.get(pageContext, "request-trial-license") %></button>
						<br />&nbsp;<br><%= LanguageUtil.get(pageContext, "license-you-request-will-automatically-be-downloaded-and-installed") %>
					
					</dd>
					
					<input type="hidden" name="upload_button" value="true">
				
					<dd id="pasteMe" style="<%if(isCommunity){ %>display:none<%} %>">
						<b><%= LanguageUtil.get(pageContext, "paste-your-license") %></b>:<br><textarea rows="10" cols="60"  name="license_text" ></textarea>
						<div style="padding:10px;">
							<button type="button" onclick="doPaste()" id="uploadButton" dojoType="dijit.form.Button" name="upload_button" iconClass="keyIcon" value="upload"><%= LanguageUtil.get(pageContext, "save-license") %></button>		
						</div>
					</dd>
					
				</dl>
			</div>
		</form>

	</div>
</div>	

<div id="dotRequestLicenseDialog" dojoType="dijit.Dialog" style="display:none" title="<%= LanguageUtil.get(pageContext, "request-license") %>">
	<div dojoType="dijit.layout.ContentPane" style="width:640px;height:550px;" class="box" hasShadow="true" id="dotRequestLicenseDialogCP">
		<%=licenseFormStr %>
		
	</div>
</div>

