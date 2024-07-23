
## Pre-Deployment Steps

1. Activate the __Lead Run Lead Assignment Rules After Insert__ flow in prod

1. Manual Post Steps (This should be done after users have been updated with roles in the new role hierarchy so the new sharing rules introduced in ST00024 can grant object visibility instead of the blanket sharing rules)

    1. Go into the sharing settings in Prod and manually delete the old sharing rules to match the rules that remain in Full1

1. Set the Organization Wide Default privacy settings to "Private" for Contacts:
    1. Setup -> Sharing Setings
    1. Click __Edit__
    1. Under __Organization-Wide Defaults__, set the __Default Internal Access__ AND __Default External Access__ to
    "Private" for __Contact__.
    1. Click __Save__