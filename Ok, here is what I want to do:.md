Ok, here is what I want to do:

- Create an "event registration" Visualforce page for table or ticket buyers where they can register the names and emails of all guests including themselves. It should do the following:
- Use the opportunity (ie. table or ticket purchase) to retreive all "Campaign Members" that are related (children of) that opportunity via the Opportunity__c field on Campaign Members. Require OppID AND Opp CreatedDate in the URL to retrieve data (user is not signed in).
- Display (read only) FirstName, LastName, Email (ContactId and Table__c in the background) of all campaign member(s) that are related to the opportunity where Event_guest_level__c picklist != "Removed". Have a "Remove" button beside each contact.
-- The first row should be the Ticket/Table purchaser (use Event_guest_level__c = "Table Head" then "Ticket Purchaser" then "Table Guest" to return Campaign Members in correct order)
-- Upon clicking remove, update Campaign Member: Event_guest_level__c picklist to "Removed" | Merge2__c (Text) to say "Guest removed (date/time), previous Event guest level was '(insert Event_guest_level__c)'" | Status to "Registration removed"
-- Page should likely then be refreshed with updated data after the remove.
- Using the Number_Tickets__c field on Opp, also show empty rows with editable fields if number of tickets is higher than number of Campaign Members returned.
- Upon page save: attempt to find newly added contacts with matching FirstName, LastName and Email, otherwise create contact (and placeholder account using First and Last name)
-- Search if this Contact is already associated with the Campaign (CampaignId field on Opportunity). Then Add or update contact as Campaign Member with CampaignID = CampaignId field on Opportunity) | Event_guest_level__c (picklist) = "Ticket Guest" | Status = "Registered" | Opportunity__c = Id of the Opp | Table__c (lookup field) can default to the table ID of the first row (ie. Table Head or Ticket Purchaser)
-Append all updates and edits that happen in a task named "Registration page log" that is on the opportunity's CampaignID (create if it does not exist yet). 