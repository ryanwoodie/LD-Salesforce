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


/// 2024-12-03 16:06 UTC

// Replace with the specific Campaign ID
Id campaignId = '701ON00000LJ39WYAT';

// Query CampaignMember records for the given Campaign ID where the contact has opted out
List<CampaignMember> membersToUpdate = [
    SELECT Id, Status, Contact.HasOptedOutOfEmail, Contact.IsEmailBounced
    FROM CampaignMember
    WHERE CampaignId = :campaignId
      AND Contact.IsEmailBounced = TRUE
];

// Update the Status to 'Removed' for each matching CampaignMember
for (CampaignMember member : membersToUpdate) {
    member.Status = 'Bounce';
}

// Perform the update
if (!membersToUpdate.isEmpty()) {
    update membersToUpdate;
    System.debug('Updated ' + membersToUpdate.size() + ' CampaignMember records to Status = Bounce.');
} else {
    System.debug('No CampaignMember records found where Contact.IsEmailBounced = TRUE.');
}


/// 2024-12-03 6:33 UTC

// Replace with the specific Campaign ID
Id campaignId = '701ON00000LJ39WYAT';

// Query CampaignMember records for the given Campaign ID where the contact has opted out
List<CampaignMember> membersToUpdate = [
    SELECT Id, Status, Contact.HasOptedOutOfEmail, Contact.IsEmailBounced
    FROM CampaignMember
    WHERE CampaignId = :campaignId
      AND Contact.HasOptedOutOfEmail = TRUE
      AND Status = 'Drip Started'
];

// Update the Status to 'Removed' for each matching CampaignMember
for (CampaignMember member : membersToUpdate) {
    member.Status = 'Unsubscribed';
}

// Perform the update
if (!membersToUpdate.isEmpty()) {
    update membersToUpdate;
    System.debug('Updated ' + membersToUpdate.size() + ' CampaignMember records to Status = Unsubscribed.');
} else {
    System.debug('No CampaignMember records found');
}

//2024-12-04 12:08PM

// Define the Campaign IDs
Id alumniCampaignId = '701ON00000LJ39WYAT';
Id targetCampaignId = '701ON00000LZTxWYAX';

// Step 1: Collect emails from the alumni campaign
Set<String> alumniEmails = new Set<String>();
List<CampaignMember> alumniMembers = [
    SELECT Contact.Email
    FROM CampaignMember
    WHERE CampaignId = :alumniCampaignId
      AND Contact.Email != null
];

for (CampaignMember member : alumniMembers) {
    alumniEmails.add(member.Contact.Email);
}

// Step 2: Find CampaignMembers in the target campaign with matching emails
List<CampaignMember> targetMembersToUpdate = [
    SELECT Id, Status, Merge1__c, Contact.Email
    FROM CampaignMember
    WHERE CampaignId = :targetCampaignId
      AND Contact.Email IN :alumniEmails
];

// Step 3: Update the matching CampaignMembers
if (!targetMembersToUpdate.isEmpty()) {
    for (CampaignMember member : targetMembersToUpdate) {
        member.Status = 'Removed';
        member.Merge1__c = 'Same Email address as contact in Alumni Campaign';
    }

    // Perform the update
    update targetMembersToUpdate;

    System.debug('Updated ' + targetMembersToUpdate.size() + ' CampaignMember records in the target campaign.');
} else {
    System.debug('No matching CampaignMember records found in the target campaign.');
}

//2024-12-04 12:51pm CT

// Replace with the specific Campaign ID
Id campaignId = '701ON00000LZTxWYAX';

// Query CampaignMember records for the given Campaign ID where the contact has opted out
List<CampaignMember> membersToUpdate = [
    SELECT Id, Status, Contact.HasOptedOutOfEmail, Contact.IsEmailBounced
    FROM CampaignMember
    WHERE CampaignId = :campaignId
      AND Contact.HasOptedOutOfEmail = FALSE
      AND Status = 'added'
];

// Update the Status to 'Removed' for each matching CampaignMember
for (CampaignMember member : membersToUpdate) {
    member.Status = 'Drip Started';
}

// Perform the update
if (!membersToUpdate.isEmpty()) {
    update membersToUpdate;
    System.debug('Updated ' + membersToUpdate.size() + ' CampaignMember records to Status = Unsubscribed.');
} else {
    System.debug('No CampaignMember records found');