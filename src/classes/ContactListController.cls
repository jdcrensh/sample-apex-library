public with sharing class ContactListController {

	private final ApexPages.StandardController sc;
	
	public Account record {get; set;}
	public List<ContactWrapper> contacts {get; set;}
	
	// Allows for selecting an Account if one is not initially given
	public Contact dummyContact {get; set;}
	
	public ContactListController(ApexPages.StandardController sc) {
		this.sc = sc;
		
		if (!Test.isRunningTest()) {
			sc.addFields(new List<String> {
				// Include any Account fields used in Apex but not in VF
			});
			record = (Account) sc.getRecord();
		}
		else {
			// Select fields referenced in this class for unit testing purposes
			record =
			    [ SELECT Id, Name, (SELECT Id FROM Contacts ORDER BY Name ASC)
			      FROM Account
			      WHERE Id = :sc.getId()
			    ];
		}
		contacts = new List<ContactWrapper>();
		for (Contact contact : record.Contacts) {
			contacts.add(new ContactWrapper(contact));
		}
		dummyContact = new Contact();
	}
	
	public PageReference next() {
		PageReference ref = Page.ContactList;
		ref.getParameters().put('id', dummyContact.AccountId);
		ref.setRedirect(true);
		return ref;
	}
	
	public PageReference save() {
		try {
			// Finalize field values here...
			sc.save(); // save the master record
			saveContacts(); // save the detail records
		}
		catch (Exception e) {
			addApexPageError(e);
			return null;
		}
		return new PageReference('/' + record.Id);
	}
	
	private void saveContacts() {
		List<Contact> recs = new List<Contact>();
		for (ContactWrapper contact : contacts) {
			if (contact.selected) {
				recs.add(contact.record);
			}
		}
		update recs;
	}
	
	public PageReference simulateError() {
		try {
			throw new SampleException('Whoops!');
		}
		catch (Exception e) {
			addApexPageError(e);
		}
		return null;
	}
	
	private String getStackTraceMarkup(Exception e) {
		return e.getMessage() + '<br/>' +
		       '<a href="javascript:showStacktrace();//" class="stacktrace-link">Stacktrace</a>' +
		       '<span class="stacktrace">' + e.getStackTraceString() + '</span>';
	}
	
	private ApexPages.Message buildErrorMessage(String str) {
		return new ApexPages.Message(ApexPages.Severity.ERROR, str);
	}
	
	public void addApexPageError(Exception e) {
		String markup = getStackTraceMarkup(e);
		ApexPages.Message m = buildErrorMessage(markup);
		ApexPages.addMessage(m);
	}
	
	public class ContactWrapper {
		public Contact record {get; set;}
		public Boolean selected {get; set;}
		
		public ContactWrapper(Contact record) {
			this.record = record;
			selected = false;
		}
	}
	
	private class SampleException extends Exception {}
}