# **User Management Script**

## **Description**

This script automates the process of creating user accounts and managing group memberships on a Unix-based system. It reads a specified text file containing user information, checks for existing users and groups, creates new ones as needed, and sets random passwords for the new users. It also logs all activities for auditing purposes.

## **Prerequisites**

**-** Unix-based operating system (Linux, macOS)

**-** Bash shell

**-** **sudo** privileges to execute system commands

**-** **OpenSSL** for generating random passwords


## **Files**


**-** **user_management.sh:** The main script file.

**-** **user_info.txt:** A sample input file containing user information in **username;group1,group2,...** format.


## **Usage**

**1. Prepare the input file:**

Create a text file (**user_info.txt**) with the user information. Each line should contain a username followed by a semicolon (;) and a comma-separated list of groups.

### **Example:**


    alice;admin,developers
    bob;developers
    charlie;admin
    
2.  **Run the script:**

Execute the script with the input file as an argument. Use sudo to ensure the script has the necessary permissions to create users and groups.

    sudo ./user_management.sh user_info.txt

3.   **Check logs:**

The script logs all activities in /var/log/user_management.log. Check this log file for details about the execution.

      sudo cat /var/log/user_management.log

## **Script Details**

The script performs the following steps:

**1. Check if the input file is provided:**

If no file is provided, the script exits with a usage message.

**2. Create a secure directory:**

If the **/var/secure** directory does not exist, the script creates it with restricted permissions to store user passwords securely.

**3. Read the input file line by line:**

For each line, the script:

    Skips empty usernames.
    Checks if the user already exists and skips creation if true.
    Checks if the personal group for the user exists and creates it if not.
    Adds the user to the specified groups, skipping non-existent groups.
    Generates a random password and sets it for the user.
    Stores the password securely in /var/secure/user_passwords.txt.
    
**4. Set permissions for password file:**

Ensures the password file has restricted permissions to maintain security.

**5. Log all activities:**

Logs every significant action and decision to /var/log/user_management.log for auditing purposes.

## **Security Considerations**

    The script must be run with **sudo** to ensure it has the necessary permissions to manage users and groups.
    User passwords are stored in a secure directory (/var/secure) with restricted permissions to prevent unauthorized access.
    Log files should be monitored to detect any issues or unauthorized access attempts.

## **Troubleshooting**

Ensure openssl is installed and accessible in your system's PATH.

Verify that you have the necessary sudo privileges to create users and groups.

Check /var/log/user_management.log for any error messages or detailed information about the script's execution.

**Example**

To create users specified in **user_info.txt**, run the following command:


    sudo ./user_management.sh user_info.txt

Monitor the execution by checking the log file:

    sudo cat /var/log/user_management.log

    

# **Author**

Afolabi Ajirotutu
    
