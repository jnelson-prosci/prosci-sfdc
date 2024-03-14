/* This trigger was created by the Youreka package and is integral to it. 
Please do not delete */
trigger Youreka_Contact_trigger on Contact (after update){
	try{
		// get an ApexClass so that optimizer doesn't erroneously optimize it away
		ApexClass dummy = [SELECT namespaceprefix FROM ApexClass WHERE name='Helper_Youreka_Settings' LIMIT 1];
	    disco.Util.updateObjectsFieldLinkAnswers(trigger.new,'Contact');
	}
	catch (Exception e){}
	    
}