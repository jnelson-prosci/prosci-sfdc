
# Prosci SF DevOps

1. Navigate to Slalom-Release-1 and checkout a new branch for a given story.

```
git checkout Slalom-Release-1
git pull
git checkout -b feature/<storynum>-<StoryDescription>
```

2. Configure changes in sandbox
3. Retrieve configuration changes and commit them to the feature branch
4. Create a new folder in the /deployment directory with the story number.
5. create 2 new files in this folder:
* package.xml
* steps.md
6. Update the package.xml with the necessary components to deploy all committed changes
7. Update the steps.md with any necessary pre or post-deploy steps.
8. run the following command to validate that all components that will appear in your pull request will deploy together:
```
sf project deploy start --dry-run  --manifest deployment/<storynumber>/package.xml
```
9. Ensure all modifications to package.xml and steps.md are committed as well
10. Push the feature branch
11. Open pull request. One other person from the dev team will review. Can be asynchronous, can be in person if complexity warrants.
12. After approval, merge branch in github UI, and deploy the changes following these steps:

```
git checkout Slalom-Release-1
git pull
sf project deploy start --manifest deployment/<storynumber>/package.xml
```

**Notice the actual deployment does not have the `--dry-run` flag