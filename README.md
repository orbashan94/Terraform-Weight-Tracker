# Terraform-Weight-Tracker
## Requirements
- Terraform
- Azure account
- Azure CLI

## The Project
This Terraform project create the diagram: ![image](https://user-images.githubusercontent.com/74772340/160320127-ba27496e-a641-446c-95f4-80f04c12138a.png)

In this project we are going to create the infrastructure of the WeightTracker application with Terraform
### Create the infrastructure above including:
- Resource Group
- Virtual Network with two subnets: “public” and “private” subnets
- Load Balancer
- Deploy the web server into the public subnet and allow users to reach the application from everywhere
- Deploy the database server into the private subnet and ensure that there is no public access to the database (only from the application)
- Configure the database
- Configure the web server
- Ensure the application is up and running (and work automatically after reboot)





