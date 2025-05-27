#!/bin/bash

# Set Oracle Wallet Location (if needed)
export TNS_ADMIN=/home/opc/APEXDemo/wallet/dev

# Define colors
BLUE='\033[34m'
RED='\033[31m'
GREEN='\033[32m'
NC='\033[0m' # No color (reset)

# Check if the project folder already exists
if [ -d "/home/opc/APEXDemo/my_projects/demo" ]; then
    echo -e "${RED}ERROR: The folder /home/opc/APEXDemo/my_projects/demo already exists!${NC}"
    echo -e "${RED}Please remove it manually.${NC}"
    exit 1
fi

echo -e "${BLUE}📁 Moving to the project directory: /home/opc/APEXDemo/my_projects ${NC}"
cd /home/opc/APEXDemo/my_projects/

echo -e "${BLUE}⚙️  Initializing the project...${NC}"
echo -e "${GREEN}sql /nolog${NC}"
echo -e "${RED}project init -name demo -schemas WKSP_DEMO -makeroot${NC}"
echo ""
read -p "Press any key to execute..." -n 1 -s
echo ""

sql /nolog <<EOF
project init -name demo -schemas WKSP_DEMO -makeroot
exit
EOF

echo -e "${BLUE}📂 Entering the newly created project folder: /home/opc/APEXDemo/my_projects/demo ${NC}"
cd demo

echo -e "${BLUE}🧾 Displaying project folder structure...${NC}"
tree -a

read -p "Press any key to continue..." -n 1 -s
echo ""

echo -e "${BLUE}🧩 SQL Projects use filters to manage database objects to be included in this project${NC}"
echo -e "${BLUE}📝 You can edit the project.filters file to exclude grants from the export${NC}"
echo -e "${BLUE}📄   Path: /home/opc/APEXDemo/my_projects/demo/.dbtools/filters/project.filters${NC}"
echo -e "${RED}🔧   - Tip: Uncomment the line → export_type not in ... USER_SYS_PRIVS${NC}"
echo -e "${BLUE}               - Add the following lines:${NC}"
echo -e "${RED}                     -- Project Tables${NC}"
echo -e "${RED}                     object_name like 'EBA_DEMO%',${NC}"
echo -e "${RED}                     -- Project application only${NC}"
echo -e "${RED}                     application_id = 115,${NC}"

read -p "Press any key to continue after making the changes..." -n 1 -s
echo ""

rm /home/opc/APEXDemo/my_projects/demo/.dbtools/filters/project.filters
cp /home/opc/APEXDemo/aux/project.filters /home/opc/APEXDemo/my_projects/demo/.dbtools/filters/project.filters

echo -e "${BLUE}🌐 We will use GitHub as our code repository.${NC}"
echo -e "${BLUE}📦 Initializing Git repository, adding the project files, and committing changes...${NC}"
echo -e "${GREEN}    git init --initial-branch=main${NC}"
echo -e "${GREEN}    git add .${NC}" 
echo -e "${GREEN}    git commit -m 'chore: initializing repository with default project files'${NC}"
echo ""
echo -e "${BLUE}🚀 Pushing changes to the remote repository on GitHub...${NC}"
echo -e "${GREEN}    git remote add origin https://github.com/vmendo/APEX_CICD_Demo.git'${NC}"
echo -e "${GREEN}    git push -u origin main'${NC}"
echo ""
read -p "Press any key to run the commands"  -n 1 -s
echo ""

git init --initial-branch=main
git add .
git commit -m "chore: initializing repository with default project files"


git remote add origin https://github.com/vmendo/APEX_CICD_Demo.git
git push -u origin main --force

echo -e "${BLUE}✅ The project structure has been committed to the code repository. Next steps:${NC}" 
echo -e "${BLUE}  1️⃣ Create a new branch and extract the DB ojects${NC}" 
echo -e "${BLUE}  2️⃣add the exported code to the Git repository${NC}" 
echo -e "${BLUE}  3️⃣ Generate the changelogs by comparing this branchwith main${NC}" 
echo -e "${BLUE}  4️⃣ Add custom SQL scrpts to populate the database with demo data${NC}"
echo -e "${BLUE}  5️⃣ Close the changes to include them in the current elease${NC}" 
echo -e "${BLUE}  6️⃣ Generate the ZIP artifact we’ll use to deploy to production${NC}" 
echo ""
echo ""
echo -e "${BLUE}🔀 Step 1: Creating a new branch and exporting database objects...${NC}"

echo -e "${GREEN}      git checkout -b base-release${NC}"
echo -e "${RED}      project export${NC}"
echo ""
read -p "Press any key to continue..." -n 1 -s
echo ""

git checkout -b base-release
sql -name apex_dev <<EOF
project export
exit
EOF
tree

read -p "Press any key to continue..." -n 1 -s
echo ""

echo -e "${BLUE}📥 Step 2: Adding the source code to the Git repository...${NC}"
echo -e "${GREEN}    git add src${NC}"
echo -e "${GREEN}    git commit -m 'chore: base export WKSP_DEMO filtered objects and APEX demo application'${NC}"
echo -e "${GREEN}    git push -u origin base-release${NC}"
echo ""
read -p "Press any key to execute..."  -n 1 -s
echo ""

git add src
git commit -m "chore: base export WKSP_DEMO filtered objects and APEX demo application"
git push -u origin base-release

echo -e "${BLUE}🧾 Step 3: Generating the changelogs by comparing this branch with main...${NC}"
echo -e "${RED}    project stage${NC}"
echo ""
read -p "Press any key to execute..."  -n 1 -s
echo ""

sql -name apex_dev <<EOF
project stage -verbose
exit
EOF
tree

echo ""
read -p "Press any key to continue..." -n 1 -s
echo ""

echo -e "${BLUE}🛠️ Step 4: Adding custom code that we want to execute in production.${NC}"
echo -e "${BLUE}📊 In this demo, we’ll include a SQL script to insert sample data into our tables.${NC}"
echo -e "${BLUE}➕ We’ll use the 'project stage add-custom' command to register this script.${NC}"
echo -e "${RED}    project stage add-custom -file-name populate_eba_demo.sql${NC}"
echo ""
read -p "Press any key to execute..."  -n 1 -s
echo ""

sql -name apex_dev  <<EOF
project stage add-custom -file-name populate_eba_demo.sql
exit
EOF
tree

read -p "Press any key to continue..." -n 1 -s
echo ""

echo -e "${BLUE}🧾 The generated file includes only Liquibase annotations — we need to insert the actual SQL code manually.${NC}"
echo -e "${BLUE}📂 We’ll now run a shell script to append the SQL code to the appropriate file.${NC}"
echo ""
read -p "Press any key to execute..."  -n 1 -s
echo ""

cd /home/opc/APEXDemo/aux/custom 
./append_base_release_sql_files.sh
cd /home/opc/APEXDemo/my_projects/demo

echo -e "${BLUE}✅ The file now contain the SQL code to populate the application tables and the Liquibase annotations.${NC}"
echo ""
read -p "Press any key to execute..."  -n 1 -s
echo ""

echo -e "${BLUE}📦 Step 5: Closing the staged changes to finalize this release version.${NC}"
echo -e "${RED}    project release -version 1.0 -verbose${NC}"
echo ""
read -p "Press any key to execute..." -n 1 -s
echo ""

sql -name  apex_dev<<EOF
project release -version 1.0 -verbose
exit
EOF
tree

read -p "Press any key to continue..." -n 1 -s
echo ""

echo -e "${BLUE}🗜️ Step 6: Generating the ZIP artifact to deploy the application to production.${NC}"
echo -e "${RED}    project gen-artifact -name apex_demo -version 1.0 -format zip -verbose${NC}"
echo ""
read -p "Press any key to execute..." -n 1 -s
echo ""

sql -name apex_dev <<EOF
project gen-artifact -name apex_demo -version 1.0 -format zip -verbose
exit
EOF
tree

echo ""
read -p "Press any key to execute..." -n 1 -s
echo ""

echo -e "${RED}✅ The artifact for the base release is ready!${NC}"
echo -e "${BLUE}🚀 Uploading the ZIP artifact to GitHub Releases...${NC}"
echo -e "${GREEN}    gh release create v1.0 artifact/apex_demo-1.0.zip \${NC}"
echo -e "${GREEN}      --title 'Version 1.0' \${NC}"
echo -e "${GREEN}       --notes 'Base release for the Demo APEX app and database objects"


gh release create v1.0 artifact/apex_demo-1.0.zip \
  --title "Version 1.0" \
  --notes "Base release for the Demo APEX app and database objects"

echo -e "${BLUE}🏁 Base release complete — time to deploy to production.${NC}"

