/* List<CampaignMember> membersToUpdate = [
    SELECT Id 
    FROM CampaignMember
    WHERE Campaign.Name LIKE '%PMC email blast%' 
      AND Contact.LastActivityDate < 2024-10-09
      AND Contact.HasOptedOutOfEmail = FALSE
      AND Status = 'Drip completed'
      AND Contact.IsEmailBounced = FALSE
    LIMIT 10000
];

for (CampaignMember member : membersToUpdate) {
    member.Status = 'added';
}

update membersToUpdate; */

// List<CampaignMember> membersToUnsubscribe = [
//     SELECT Id 
//     FROM CampaignMember
//     WHERE Campaign.Name = 'Circles PMC email blast' 
//       AND Contact.HasOptedOutOfEmail = TRUE
//       AND Status != 'Unsubscribed'
//       AND Status != 'Responded'
//     LIMIT 10000
// ];

// for (CampaignMember member : membersToUnsubscribe) {
//     member.Status = 'Unsubscribed';
// }

// update membersToUnsubscribe;

// // Fetch all email templates
// List<EmailTemplate> templates = [
//     SELECT Id, Name, DeveloperName, Subject, Folder.DeveloperName
//     FROM EmailTemplate
// ];

// Boolean found = false;

// System.debug('Checking templates for subject containing "Registration error in site"...');

// for (EmailTemplate template : templates) {
//     if (template.Subject != null && template.Subject.contains('Registration error in site')) {
//         System.debug('Match Found:');
//         System.debug('Name: ' + template.Name);
//         System.debug('Developer Name: ' + template.DeveloperName);
//         System.debug('Subject: ' + template.Subject);
//         System.debug('Folder: ' + template.Folder.DeveloperName);
//         System.debug('Template Id: ' + template.Id);
//         found = true;
//     }
// }

// if (!found) {
//     System.debug('No email templates found with the specified subject.');
// }

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