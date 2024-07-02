# Post-Deployment Steps:

1. Delete old versions of Lead - Assign Country Code Info flow that reference Lead.Languages__c field (if applicable)
    1. Setup -> Quick Find: Flows
    1. Scroll down to __Lead - Assign Country Code Info__, on the far right, click down arrow
    1. Click __View Details and Versions__
    1. If more than one version exists of this flow, delete the __older/inactive version(s)__

1. Delete Languages__c from Lead and Contact objects (if applicable)
    1. Setup -> Object Manager -> Lead -> Fields & Relationships
    1. Search: __Language(s)__
    1. Click far right arrow in line with this field
    1. Click __Delete__
