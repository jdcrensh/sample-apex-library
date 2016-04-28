@isTest class ContactListControllerTest {

	@testSetup static void setup() {
		Account account = new Account(
		    Name = 'Rebels'
		);
		insert account;
		
		List<Contact> contacts = new List<Contact> {
			new Contact(FirstName = 'Luke', LastName = 'Skywalker', AccountId = account.Id),
			new Contact(FirstName = 'Han', LastName = 'Solo', AccountId = account.Id),
			new Contact(FirstName = 'Leia', LastName = 'Organa', AccountId = account.Id)
		};
		insert contacts;
	}
	
	@isTest static void testContactList() {
		ApexPages.StandardController sc = new ApexPages.StandardController(new Account());
		
		Test.startTest();
		Test.setCurrentPage(Page.ContactList);
		
		ContactListController con = new ContactListController(sc);
		
		con.dummyContact.AccountId = [ SELECT Id FROM Account ].Id;
		con.next();
		
		System.assertEquals(3, con.contacts.size());
		
		con.simulateError();
		
		System.debug(con.record);
		for (ContactListController.ContactWrapper contact : con.contacts) {
			contact.selected = true;
		}
		con.save();
		Test.stopTest();
		
		System.assertEquals(1, ApexPages.getMessages().size());
	}
	
	@isTest static void testContactListExistingAccount() {
		ApexPages.StandardController sc = new ApexPages.StandardController([ SELECT Id FROM Account ]);
		
		Test.startTest();
		Test.setCurrentPage(Page.ContactList);
		
		ContactListController con = new ContactListController(sc);
		System.assertEquals(3, con.contacts.size());
		
		for (ContactListController.ContactWrapper contact : con.contacts) {
			contact.selected = true;
		}
		con.save();
		Test.stopTest();
		
		System.assertEquals(true, ApexPages.getMessages().isEmpty());
	}
	
	@isTest static void testThrowsSaveError() {
		ApexPages.StandardController sc = new ApexPages.StandardController([ SELECT Id FROM Account ]);
		
		Test.startTest();
		Test.setCurrentPage(Page.ContactList);
		
		ContactListController con = new ContactListController(sc);
		System.assertEquals(3, con.contacts.size());
		
		for (ContactListController.ContactWrapper contact : con.contacts) {
			contact.selected = true;
			contact.record.Id = null;
		}
		con.save();
		Test.stopTest();
		
		System.assertEquals(false, ApexPages.getMessages().isEmpty());
	}
}