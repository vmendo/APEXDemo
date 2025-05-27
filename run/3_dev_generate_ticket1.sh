#!/bin/bash

# Set Oracle Wallet Location (if needed)
export TNS_ADMIN=/home/opc/APEXDemo/wallet/dev

# Define colors
BLUE='\033[34m'
RED='\033[31m'
GREEN='\033[32m'
NC='\033[0m' # No color (reset)

cd /home/opc/APEXDemo/my_projects/demo
echo -e "${BLUE}🆕💼 Now we are starting a new feature request: ${NC}" 
echo -e "${BLUE} Add a Merchandise table and an IR to manage it${NC}"
echo ""
echo -e "${GREEN}----------------------------------------------------------${NC}"
echo -e "${BLUE}🛠️  Steps required: ${NC}"
echo -e "${BLUE}   1️⃣  Create a new Git branch for this feature${NC}"
echo -e "${BLUE}   2️⃣  Implement changes in the database Create the table and the APEX page${NC}"
echo -e "${BLUE}   3️⃣  Use SQcl project commands to stage and promote the changes${NC}"
echo -e "${GREEN}----------------------------------------------------------${NC}"
echo ""
echo -e "${GREEN}      git checkout main${NC}"
echo -e "${GREEN}      git pull origin main${NC}"
echo -e "${GREEN}      git checkout -b merchandise${NC}"
echo ""
read -p "Press any key to execute..." -n 1 -s
echo ""

git checkout main
git pull origin main
git checkout -b merchandise


echo ""
echo -e "${BLUE}🧾 Step 2: We will now create the merchandise table using our favourite tool.${NC}"
echo -e "${BLUE}              And crate the APEX page using the APEX UI${NC}"
read -p "🟢 Press any key to continue when ready..." -n 1 -s
echo ""
read -p "✅ Press any key to confirm that merchandise table and APEX page have been created ..." -n 1 -s
echo ""
echo -e "${BLUE}📤 Step 3: Generate the source code and push it to the GitHub repository.${NC}"
echo ""
echo -e "${RED}          project export${NC}"
echo -e "${GREEN}         git add src${NC}"
echo -e "${GREEN}         git commit -m 'feat:Adding merchandise functionality to our APEX application'${NC}"
echo ""
read -p "Press any key to continue..." -n 1 -s
echo ""

sql -name apex_dev <<EOF
project export
exit
EOF

git add src
git commit -m "feat:Adding merchandise functionality to our APEX application"
tree 

read -p "Press any key to continue..." -n 1 -s
echo ""

echo -e "${BLUE}⏳ Before generating changelogs and the artifact, we need approval from the project manager.${NC}"
echo -e "${BLUE}📤 We’ll push our branch to the remote repository and open a merge request for review.${NC}"
echo -e "${GREEN}           git push origin merchandise${NC}"
echo -e "${GREEN}           gh pr create \ ${NC}"
echo -e "${GREEN}            --base main \ ${NC}"
echo -e "${GREEN}            --head merchandise \ ${NC}"
echo -e "${GREEN}            --title 'Merchandise (v1.1)' \${NC}"
echo -e "${GREEN}            --body 'Adding merchandise functionality to our APEX application'${NC}"
echo ""
read -p "Press any key to continue..." -n 1 -s
echo ""

git push origin merchandise
gh pr create \
  --base main \
  --head merchandise \
  --title "Merchandise (v1.1)" \
  --body "Adding merchandise functionality to our APEX application"


echo ""
read -p "Press any key to continue..." -n 1 -s
echo ""

echo -e "${BLUE}🔁 Waiting for the merge request to be ${GREEN}approved and merged${BLUE}, or ${RED}closed without merging${BLUE}.${NC}"
echo ""

# Get PR number
PR_NUMBER=$(gh pr list --head merchandise --json number --jq '.[0].number')

if [[ -z "$PR_NUMBER" ]]; then
  echo -e "${RED} No pull request created. Exiting.${NC}"
  exit 1
fi

echo " Waiting for PR #$PR_NUMBER to be merged or closed..."

# Wait loop
while true; do
  STATUS=$(gh pr view "$PR_NUMBER" --json state --jq '.state')
  if [[ "$STATUS" == "MERGED" ]]; then
    echo -e "${RED}✅ Pull request #$PR_NUMBER has been merged!${NC}"
    echo ""
    echo -e "${BLUE}📦 Proceeding to generate the changelogs, close the release, and create the artifact for deployment.${NC}"
    echo -e "${RED}    sql -name apex_dev ${NC}"
    echo -e "${RED}    project stage -verbose${NC}"
    echo -e "${RED}    project stage add-custom -file-name eba_demo_merchandise_populate.sql${NC}"
    echo -e "${RED}    project release -version 1.1 -verbose${NC}"
    echo -e "${RED}    project gen-artifact -name apex_demo -version 1.1 -format zip -verbose${NC}"
    echo ""
    read -p "Press any key to continue..." -n 1 -s
    
    sql -name apex_dev<<EOF
project stage -verbose
project stage add-custom -file-name eba_demo_merchandise_populate.sql
exit
EOF

    cd /home/opc/APEXDemo/aux/custom/
    ./append_merchandise_release_sql_files.sh
    cd /home/opc/APEXDemo/my_projects/demo

    sql -name apex_dev<<EOF
project release -version 1.1 -verbose
project gen-artifact -name apex_demo -version 1.1 -format zip -verbose
exit
EOF
    tree
    echo ""
    echo -e "${BLUE}🏷️  A new release ${GREEN}(v1.1)${BLUE} has been successfully created.${NC}"
    echo -e "${BLUE}📌 This stage includes only the changes introduced in this branch compared to ${GREEN}main${BLUE}.${NC}"
    echo ""
    echo -e "${BLUE}🚀 Storing the generated artifact as a GitHub Release Asset...${NC}"
    echo -e "${GREEN}    gh release create v1.1 artifact/apex_demo-1.1.zip --title 'Version 1.1' --notes 'Merchandise func included'${NC}"
    echo ""
    read -p "Press any key to continue..." -n 1 -s

    gh release create v1.1 artifact/apex_demo-1.1.zip --title "Version 1.1" --notes "Merchandise func included"

    break
  elif [[ "$STATUS" == "CLOSED" ]]; then
    echo -e "${RED}❌ Pull request #$PR_NUMBER has been closed without merging.${NC}"
    echo ""
    echo -e "${BLUE}⚠️  The changes in this branch were not approved.${NC}"
    break
  else
    echo "Still open... waiting 10 seconds..."
    sleep 10
  fi
done


echo -e "${BLUE}🔄 Syncing the local repository with the remote to reflect the latest changes...${NC}"
echo -e "${BLUE}🌿 Then, we will delete the ${GREEN}merchandise${BLUE} branch locally and remotely to keep the workspace clean.${NC}"
echo ""
echo -e "${GREEN}      git checkout main${NC}"
echo -e "${GREEN}      git pull origin main${NC}"
echo -e "${GREEN}      git branch -d merchandise${NC}"
echo ""
read -p "Press any key to execute..." -n 1 -s
echo ""

# Sync local main
git checkout main
git pull origin main

# Optional: clean up local branch
git branch -d merchandise 2>/dev/null

echo -e "${BLUE}      Exiting the demo!!!${NC}"




