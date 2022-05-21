# Experiments with trying to make a world with better PRs

Using fswatch to watch the file current directory for writes to files in the project, taking a diff each time a write happens, and printing that to a file. That file is called history.txt, and is saved in a namespaced folder within `~/.cache/pr_history/*`

This is all happening inside of `demo.sh`

I experimented with using GitHub's Blob API to try to store the file history so that we can later retrieve it when viewing PRs, but ran into some weird encoding issues where when I decode the blob again it has a bunch of strange characters.... it looks like the Blob API supports JSON so maybe it'd be possible to parse the raw diff output into json to avoid these decoding issues... *shrug*

Here were the API calls I was using (using the GH CLI tools):

For creating a new blob for the history.txt file:

```
CONTENT=$(cat ~/.cache/pr_history/%Users%oliverswitzer%workspace%better-prs-demo/history.txt)
ORGANIZATION=oliverswitzer
REPO=better_prs

gh api \
  --method POST \
  -H "Accept: application/vnd.github.v3+json" \
  /repos/$ORGANIZATION/$REPO/git/blobs \
  -f content=$CONTENT
 -f encoding='utf-8'
```
This returns a response with a SHA that you will need to save to later retreive the blob.

For fetching the blob:

```
 gh api \
  -H "Accept: application/vnd.github.v3+json" \
  /repos/oliverswitzer/better_prs/git/blobs/<SHA OF BLOB>
```

If chrome extension that the person uses has authorization to retrieve blobs on behalf of the user, it can fetch the blob according to some namespace of org/repo/branch, process the history.txt file to display what files were created in what order. 

Later, we can display high level stats about what happened in the lifecycle of working on this branch... "Oliver created a test: test/test.exs". Oliver implemented a test. Oliver created a new file "src/test.exs" etc...
