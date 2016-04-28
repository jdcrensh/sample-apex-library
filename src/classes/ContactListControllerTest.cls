@isTest class ContactListControllerTest {

	@testSetup static void setup() {
		Account account = new Account(
			Name = 'Most Wanted'
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
		Account acc = [ SELECT Id FROM Account LIMIT 1 ];

		ApexPages.StandardController sc = new ApexPages.StandardController(acc);
		
		Test.startTest();
		Test.setCurrentPage(Page.ContactList);
		ContactListController con = new ContactListController(sc);
		
		Test.stopTest();
	}
}