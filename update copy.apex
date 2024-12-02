// // Query all Contacts where HasOptedOutOfEmail is TRUE
// List<Contact> optedOutContacts = [
//     SELECT Id, Email 
//     FROM Contact
//     WHERE HasOptedOutOfEmail = TRUE AND Email != null
// ];

// // Create a set to hold emails of opted-out contacts
// Set<String> optedOutEmails = new Set<String>();
// for (Contact contact : optedOutContacts) {
//     optedOutEmails.add(contact.Email.toLowerCase());
// }

// // Query all Contacts where email matches but they are not opted out
// Integer matchCount = [
//     SELECT COUNT()
//     FROM Contact
//     WHERE Email IN :optedOutEmails
//       AND HasOptedOutOfEmail = FALSE
//       AND Email != null
// ];

// // Output the number of matches
// System.debug('Number of matching contacts with the same email but not opted out: ' + matchCount);

// Step 1: Retrieve all contacts who have opted out of email and have a non-null email address
List<Contact> optedOutContacts = [
    SELECT Id, Email
    FROM Contact
    WHERE HasOptedOutOfEmail = TRUE AND Email != null
];

// Step 2: Create a set to store the lowercase emails of opted-out contacts
Set<String> optedOutEmails = new Set<String>();
for (Contact contact : optedOutContacts) {
    optedOutEmails.add(contact.Email.toLowerCase());
}

// Step 3: Retrieve contacts that share the same email (case-insensitively) but are not opted out
List<Contact> contactsToUpdate = [
    SELECT Id, Email
    FROM Contact
    WHERE Email IN :optedOutEmails AND HasOptedOutOfEmail = FALSE
];

// Step 4: Update the 'HasOptedOutOfEmail' field to TRUE for the identified contacts
for (Contact contact : contactsToUpdate) {
    contact.HasOptedOutOfEmail = TRUE;
}

// Step 5: Perform the update operation and capture the result
Database.SaveResult[] updateResults = Database.update(contactsToUpdate, false);

// Step 6: Create a list to store the IDs of successfully updated contacts
List<Id> updatedContactIds = new List<Id>();
for (Database.SaveResult result : updateResults) {
    if (result.isSuccess()) {
        updatedContactIds.add(result.getId());
    } else {
        // Handle errors if necessary
        for (Database.Error error : result.getErrors()) {
            System.debug('Error updating contact ID ' + result.getId() + ': ' + error.getMessage());
        }
    }
}

// Output the IDs of the successfully updated contacts
System.debug('Successfully updated contact IDs: ' + updatedContactIds);






List<Contact> recentContacts = [
    SELECT Id, Name, LastModifiedDate, LastModifiedBy.Name
    FROM Contact
    WHERE LastModifiedDate = LAST_N_MINUTES:10
      AND LastModifiedBy.Name = 'Ryan Wood'
];

System.debug('Contacts modified by Ryan Wood in the last 10 minutes: ' + recentContacts);


List<Contact> recentContacts = [
    SELECT Id, Name, LastModifiedDate, LastModifiedBy.Name
    FROM Contact
    WHERE LastModifiedDate = LAST_N_MINUTES:10
      AND LastModifiedBy.Name = 'Ryan Wood'
];

System.debug('Contacts modified by Ryan Wood in the last 10 minutes: ' + recentContacts);




/// 2024-12-02 7:06 UTC

// Replace with the specific Campaign ID
Id campaignId = '701ON00000LJ39WYAT';

// Query CampaignMember records for the given Campaign ID where the contact has opted out
List<CampaignMember> membersToUpdate = [
    SELECT Id, Status, Contact.HasOptedOutOfEmail
    FROM CampaignMember
    WHERE CampaignId = :campaignId
      AND Contact.HasOptedOutOfEmail = TRUE
];

// Update the Status to 'Removed' for each matching CampaignMember
for (CampaignMember member : membersToUpdate) {
    member.Status = 'Removed';
}

// Perform the update
if (!membersToUpdate.isEmpty()) {
    update membersToUpdate;
    System.debug('Updated ' + membersToUpdate.size() + ' CampaignMember records to Status = Removed.');
} else {
    System.debug('No CampaignMember records found where Contact.HasOptedOutOfEmail = TRUE.');
}