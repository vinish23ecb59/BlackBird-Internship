#!/usr/bin/env bash
# Propeller GitHub CLI task: update the React logo and link, then open and merge a PR.
# Prerequisites: Node.js/npm, Git, GitHub CLI (gh), and a GitHub account.
# Run these commands in a terminal. GitHub CLI authentication may prompt you to sign in.

# REPO_URL <github_url>
# After creating the public repository, replace <github_url> above with its real URL.
# Example: # REPO_URL https://github.com/YOUR-USERNAME/propeller-logo-update

set -e

# 1. Create a React app.
npx create-react-app propeller-logo-update
cd propeller-logo-update

# Initialise Git and create the first commit.
git init
git add .
git commit -m "Initial React app"

# 2. Authenticate with GitHub CLI and create a PUBLIC repository.
gh auth login
gh repo create propeller-logo-update --public --source=. --remote=origin

# Use master as the base branch, as required by the task.
git branch -M master
git push -u origin master

# 3. Create and switch to the update_logo branch.
git switch -c update_logo

# 4. Replace the Create React App logo with the Propeller Aero logo.
curl -L --fail --output src/logo.svg \
  "https://cdn-ikponof.nitrocdn.com/vGqfYAGlOLDkYkJqZhYIYKEsibdbZnkc/assets/images/optimized/rev-f684a87/www.propelleraero.com/wp-content/uploads/2023/05/footer-logo.svg"

# 5. Replace the existing React link with the DirtMate page.
# This updates the href in the default Create React App App.js.
python - <<'PY'
from pathlib import Path

path = Path("src/App.js")
text = path.read_text()
text = text.replace('href="https://reactjs.org"', 'href="https://www.propelleraero.com/dirtmate/"')
path.write_text(text)
PY

# 6. Commit and push the update_logo branch.
git add src/logo.svg src/App.js
git commit -m "Update logo and link to Propeller DirtMate"
git push -u origin update_logo

# 7. Create a pull request from update_logo into master.
gh pr create \
  --base master \
  --head update_logo \
  --title "Update Propeller logo and DirtMate link" \
  --body "Replace the default React logo with the Propeller Aero logo and update the link to the DirtMate page."

# 8. Merge the pull request using GitHub CLI.
gh pr merge update_logo --merge --delete-branch

# Optional verification.
gh repo view --web
gh pr list --state merged
