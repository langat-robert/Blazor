#Building a data capture system

##Background
A new Social Assistance Fund is being established to consolidate financial resources from both government and non-government sources, with the goal of delivering timely and predictable support to needy and vulnerable individuals. Applicants will be identified on demand and assessed based on their vulnerability and income levels. Each individual may apply for one or more assistance programs through a standardized application process.

To support this initiative, a digital system is required to manage applicant data, application submissions, eligibility assessments, and communication. Applications can be submitted either electronically via a web portal or manually at designated offices. Manually submitted forms will be digitized and entered into the system by authorized data entry officers. Once eligibility is determined, applicants will be notified through email or SMS alerts.

The application form has been outlined in the file application-form.md

##Technology stack 
The system is using the following technology stack: 
1. Framework: ASP.NET Core Blazor 
2. Backend: C# 
3. Database: MSSQL 2022 
4. Frontend: HTML5, CSS3, JavaScript, jQuery, and the Bootstrap 5 CSS framework 
5. Application Server: IIS 
6. Operating System: Windows Server 2022 or Ubuntu 18.04.6 LTS (compatible with any later stable/LTS versions) 
7. Web Browser: Compatible with modern browsers such as Google Chrome, Mozilla Firefox, Edge, and Safari (optimized for Google Chrome and Mozilla Firefox). 

##Instructions 
Create a simple web application to digitize the application form outlined in file application-form.md. The application must be built using the technology stack listed above and adhere to the following 4 specifications:

1. Database Design (Mandatory) 
Develop a normalized database to 3NF, use tables, stored procedures, and views. The design must account for the following: 
    • Primary and Foreign Keys: Use integers for primary and foreign keys. 
    • Address Information: The address is derived from a geo-location master list provided by the Bureau of Statistics, which includes codes and names. The address hierarchy follows this structure: 
        o Village: A village is located within a sub-location. Each village in the geo location has a unique village code and name. 
        o Sub-location: Many sub-locations form a location. Each sub-location has a unique sub-location code and name in the geo-location. 
        o Location: Many locations form a sub-county. Each location has a unique location code and name within the geo-location. 
        o Sub-county: Many sub-counties form a county. Each sub-county is identified by a unique sub-county code and name. Each county is also identified by a unique county code and name. 
    • Configurable Items: Store parameters such as sex and marital status in lookup tables. 
    • Name Structure: Split names into first name, middle name, and last name. 
    • ID Number/Passport Number: Store as alphanumeric with a maximum length of 20 characters. 

2. Web Application Coding (Mandatory) 
    Develop a web interface with the following functionality: 
    • Application Management: Allow users to add, edit, save, and approve applications. 
    • Search and Filtering: Implement search functionality to filter saved applications by names, date of application, status, and geographic locations (county, sub-county, location, sub-location, and village). 
    • Pagination: Implement pagination for the list of applicants, with the default page size set to 2. 
    • Configurable Parameters Interface: Create an interface for capturing other configurable items (such as sex, marital status, etc.).

3. Report Design (Optional) 
    Create a report that can be exported to Excel or PDF, listing applicants in the format specified in application-form.md. 

4. Documentation (Mandatory) 
    Provide a detailed README.md file, outlining step-by-step instructions on how to set up the solution. 
