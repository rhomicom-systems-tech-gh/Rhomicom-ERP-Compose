# TO SETUP RHOMICOM ERP PROJECT

1. Install Docker
2. Download/Clone Rhomicom-ERP-Compose Project from Github
3. Download [Rhomicom-ERP-Web](https://github.com/rhomicom-systems-tech-gh/Rhomicom-ERP-Web.git) Project files and place folder contents directly into src/RHO_ERP_WEB

- NB on linux you may have to run
- chmod -R 777 Rhomicom-ERP-Project as root
- Or run the ./secure.sh script to grant appropriate folder permissions (A more secure alternative)

3. cd  to api_image/code and run

- npm install OR download https://github.com/rhomicom-systems-tech-gh/Rhomicom-DB-Scripts/raw/master/node_modules.zip and unzip into api_image/code folder

4. cd to db/initdb/pgdb and download sample db file into it if needed

- NB: Sample DB can be downloaded from
  https://gitlab.rhomicom.com:8443/admin2/rhomicom-public-stuff/-/blob/master/2_sample_database.sql

5. Alternatively sample DB can be restored after running containers via terminal

- First Login to the [pgAdmin interface](http://localhost:8091) to view Databases available
- docker exec -it rho-pgadmin sh
- cd /var/lib/pgadmin/storage/info_rhomicom.com
- psql -h rho-pgdb -p 5432 -U postgres -v -d rho_erp_db < 2_sample_database.sql
  OR
  Direct full restore of the sample backup file located at [db/initdb/pgdb](https://github.com/rhomicom-systems-tech-gh/Rhomicom-ERP-Project/tree/main/db/initdb/pgdb/2_sample_database.backup)
  from the pgadmin front-end interface

6. cd back to main Rhomicom-ERP-Project folder and Run

- docker-compose -p RHO-ERP-SET-1 up -d --remove-orphans

7. Open http://localhost:8090 to access db via adminer
8. Open http://localhost:8091 to access db via pgadmin
9. Open http://localhost:8000 to run application
10. To tear everything down Run

- docker-compose -p RHO-ERP-SET-1 down

# TO BUILD IMAGES

1. Download psol.tar.gz file from https://github.com/openbridge/nginx/tree/master/psol and place in conf/psol/psol.tar.gz
2. Navigate to Dockerfile Folder
3. In the api_image folder Run

- docker build -t rho-erp-api:v1.0 .
- docker run -p 3000:3000 --name rho-erp-api-1 rho-erp-api:v1.0

4. In the api_image folder Run

- docker build -t rho-erp-base:v1.0 .
- docker run -dp 8000:8080 --name rho-erp-base-1 rho-erp-base:v1.0

# DEFAULT PASSWORDS

1. http://localhost:8000
   - username:admin pwd: Ghana124 [Sample DB]
   - username:admin pwd: admin [Empty DB]
2. http://localhost:8000/index.php?cp=2
   - pwd: Password1
3. http://localhost:8090
   - Server: rho-mysqldb username: root pwd: Password1
   - Server: rho-pgdb username: postgres pwd: Password1
4. http://localhost:8091
   - username: info@rhomicom.com pwd: Password1

# Rhomicom-ERP-Web

Rhomicom Enterprise Resource Planning System (Web Version)

Rhomicom Enterprise Resource Planning System is a complete ERP system proudly started in Ghana by Ghanaians.
The company behind this project is Rhomicom Systems Tech. Ltd.(http://rhomicom.com)
The software can be used to manage both backend and front-end operations of all kinds of institutions and organisations.
The sample is currently hosted on https://portal.rhomicom.com
Help can be found on https://wiki.rhomicom.com

Completed or Activated Modules
==============================

1. Accounting
2. Person Data
3. Internal Payments (Payroll, Membership Fees, Dues and Contributions)
4. Sales/Inventory
5. Visits/Appointments
6. Events Management
7. Facility Rentals/Hospitality Management
8. Learning/Performance Management System
9. Self-Service
10. e-Voting
11. Chat Rooms/Forums
12. Banking & Microfinance Module
13. Vault Management Module
14. Visit https://wiki.rhomicom.com/ for more info

Typical Target institutions/organisations
=========================================

1. Hotels/Restaurants/Coffee shops
2. Super Markets/Boutiques/Wholesale and Retail Shops
3. Associations/Churches/Professional Bodies
4. Construction Firms
5. Academic Institutions

System Features
===============

- Email/SMS Alerts
- Import/Export to Excel
- Responsive Design (Able to work on any Computer,Tablet, Phone)
- Online Capable (Can be accessed anywhere in the world)
- Summary Dashboards
- Customizable Interfaces
- Customizable Reports
- Chat Rooms/Forums/Circulars/Announcements

Sofware Requirements
====================

1. All Operating Systems
2. PostgreSQL Database 9.3 or later (Can be hosted on any Operating System)
3. Java 1.6 or later

Hardware Requirements
=====================

Same hardware requirements for above Sofware requirements

Technologies/Tools Used
=======================

1. Java 1.8-(Netbeans 8.1)
2. PHP 5.6 or later
3. HTML/CSS/javascript (Bootstrap3.3.6, Datatables Plugin, Bootstrap Dialog, SummerNote,jQuery 1.11.3, fontawesome 4)
4. TIBCO JasperSoft Studio 6.2.0
5. PostgreSQL Database 9.3

# (CREDITS/ACKNOWLEDGEMENTS)

- **Platforms:** Gitlab/Github, Docker, Alpine Linux, Nginx, ModPageSpeed
- **Languages:** Java, PHP, javascript
- **Frameworks:** Bootstrap, [Agency Start Bootstrap Theme](https://startbootstrap.com/themes/agency/), jQuery, Node, ExpressJS, AMCharts, yuicompressor-2.4.8.jar
- **Database:** PostgreSQL, MySQL, Adminer
- **IDE:** vscode, TIBCO JasperSoft Studio/Library 6.2.0
- **Openbridge, Inc.:** https://github.com/openbridge/nginx

# COMMERCIAL SUPPORT AVAILABLE

- **URL:** ...coming soon...
- **Contact:** support@rhomicom.com

# TODO

1. Projects Management Module
2. Help Desk Module

# Issues

If you have any problems with or questions about this image, please contact us through a GitHub issue.

# Contributing

You are invited to contribute new features, fixes, or updates, large or small; we are always thrilled to receive pull requests, and do our best to process them as fast as we can.

Before you start to code, we recommend discussing your plans through a GitHub issue, especially for more ambitious contributions. This gives other contributors a chance to point you in the right direction, give you feedback on your design, and help you find out if someone else is working on the same thing.

# License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

# DOCKER PUSH

docker login

docker buildx create --driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=-1 --driver-opt env.BUILDKIT_STEP_LOG_MAX_SPEED=-1 --use

docker build -t rhomicom/rho-erp-base:v1.3 .
docker push rhomicom/rho-erp-base:v1.3

docker tag rhomicom/rho-erp-base:v1.3 rhomicom/rho-erp-base:latest
docker push rhomicom/rho-erp-base:latest

docker run -d -p 8005:8080 rhomicom/rho-erp-base:v1.2
