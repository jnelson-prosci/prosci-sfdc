# Post-Deployment Steps:

1. Ensure Org-Wide Default for the Price Book object is 'No Access'
2. Using Dataloader.io or your data loading tool of choice, import the following CSV file containing 1 Pricebook2 record(s):
    * Pricebook2 - Prosci Global Growth Pricebook.csv
3. Verify the creation of this record 
    * Switch to Salesforce Classic
    *  using the resulting record ID query for or navigate to the new record in Salesforce UI
    * Ensure the field values match that of the CSV file
4. Share this Price Book with Prosci Global Grow
    * In Prosci Global Growth Pricebook  record -- while still in Salesforce Classic -- click the Sharing button
    * In the quick find field, search 'Prosci Global Growth Team'
    * Select and add the Group of the same name
    * Price Book Access: 'View Only'
    * Save
5. Remove Manual Sharing from the other active Growth Price Books by repeating these steps:
    * Navigate to [Price Book Name]
    * Click the Sharing button
    * Delete sharing rule that shares with All Internal Users (if applicable)

