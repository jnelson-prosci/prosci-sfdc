# Post-Deployment Steps:

1. Migrate MDT records using CSV file
    - File name: Country_Code_Info__mdt.csv
    - CSF CLI command (enter from SF project terminal VS Code): 
        - *sf cmdt generate records --csv deployment/st-00004 Country_Code_Info__mdt.csv --type-name Country_Code_Info__mdt*
        
    **Creates MDT records locally; developer will still need to deploy them to target org*
2. Activate Lead - Assign Country Code Info flow
3. Update Global Growth Base Permission Set
    * Grant access the Lead - Assign Country Code Info flow
    * Update FLS on Lead object, grant Edit access to the following:
        * Country Name
        * Language(s)
        * Queue Family
4. Ensure Prosci Global Lead Assignments lead assignment rule(s) is active

