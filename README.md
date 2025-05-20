EfficientIP-Management
Created By: Saugata Datta
Version: 2.7

Overview
EfficientIP-Management is a PowerShell module designed to interact with an EfficientIP IPAM (IP Address Management) solution. It provides a set of functions to manage various aspects of IPAM, including authentication, querying sites and subnets, finding free IP addresses/subnets, and creating or deleting subnets and host IP entries via the EfficientIP REST API.

Prerequisites
PowerShell

Access to an EfficientIP instance with REST API enabled.

Credentials for an account with necessary permissions on the EfficientIP instance.

Setup
Save the PowerShell script (e.g., EfficientIP-Management.psm1 or EfficientIP-Management.ps1).

Import the module into your PowerShell session:

# If saved as a .psm1 module file
Import-Module .\EfficientIP-Management.psm1
Or if it's a .ps1 script file, you might need to dot-source it to make functions available in the current scope:

. .\EfficientIP-Management.ps1
Core Authentication Function
All subsequent API calls depend on the authentication and endpoint details set by this function. It's crucial to run this function first.

Set-IPAMAuthURI
This function will help you set the IPAM authentication and endpoint details in memory for future use during the current PowerShell session.

Syntax:

Set-IPAMAuthURI -URI <string> -UserName <string> -Password <string>
Parameters:

URI (Mandatory) [string]: The base URI of your EfficientIP host (e.g., "https://fqdn.efficientip.host").

UserName (Mandatory) [string]: The username for an account with access to the IPAM API.

Password (Mandatory) [string]: The password for the specified account.

Example:

Set-IPAMAuthURI -URI "[https://efficientip.example.com](https://efficientip.example.com)" -UserName "api-user" -Password "yourSecurePassword"
Available Functions
Once authentication is set using Set-IPAMAuthURI, you can use the following functions:

Get-IPAMQueryMaster
This function will help you get Query Master Site information.

Usage Examples:

# Get site details by partial name match
Get-IPAMQueryMaster -SiteNameLike "central-office"

# Get site details by exact name
Get-IPAMQueryMaster -SiteName "MainDataCenter"

# Get site details by Site ID
Get-IPAMQueryMaster -SiteId "1001"

# Get raw API response for an exact site name
Get-IPAMQueryMaster -SiteName "MainDataCenter" -RawData
Parameters:

SiteName [string]: Exact name of the site.

SiteId [string]: ID of the site.

SiteNameLike [string]: Partial name of the site for a 'like' query.

RawData [SwitchParameter]: If present, returns the raw JSON response from the API instead of a formatted PowerShell object.

Get-IPAMSubnets
This function will help you get information about subnet(s) based on various criteria.

Usage Examples:

# Get subnets with names containing "AWS"
Get-IPAMSubnets -SubnetNameLike "AWS"

# Get a specific subnet by name and view raw API data
Get-IPAMSubnets -SubnetName "DMZ-Subnet-01" -RawData

# Get subnet by its starting IP address
Get-IPAMSubnets -StartAddress "192.168.10.0"

# Get subnet by its ID
Get-IPAMSubnets -SubnetId "5005"

# Get child subnets of a parent subnet ID
Get-IPAMSubnets -ParentSubnetId "5000"

# Get subnets with a start address like "10.20."
Get-IPAMSubnets -StartAddressLike "10.20." -Quite
Parameters:

SubnetId [string]: ID of the subnet.

SubnetName [string]: Exact name of the subnet.

SubnetNameLike [string]: Partial name of the subnet for a 'like' query.

ParentSubnetId [string]: ID of the parent subnet to find its children.

StartAddress [string]: Start IP address of the subnet.

EndAddress [string]: End IP address of the subnet.

StartAddressLike [string]: Partial start IP address for a 'like' query.

Quite [SwitchParameter]: If present, suppresses "Nothing found" messages.

RawData [SwitchParameter]: If present, returns the raw JSON response from the API.

Get-IPAMFreeSubnetIP
This function will help you get the next available Subnet range(s) within a parent subnet.

Usage Examples:

# Find the next available /24 subnet in a parent subnet named "Corp-Network"
Get-IPAMFreeSubnetIP -SubnetName "Corp-Network" -CIDR "24"

# Find all available /28 subnets in a parent subnet with ID 12345
Get-IPAMFreeSubnetIP -SubnetId 12345 -CIDR "28" -All

# Get raw API response
Get-IPAMFreeSubnetIP -SubnetName "Corp-Network" -CIDR "24" -RawData
Parameters:

SubnetId [int]: ID of the parent subnet.

SubnetName [string]: Name of the parent subnet.

CIDR (Mandatory) [string]: The CIDR prefix for the new free subnet you are looking for (e.g., 22, 24, 28).

All [SwitchParameter]: If present, returns multiple available free subnet ranges of the specified CIDR within the parent, not just the first one (which is the default if -All is omitted). For instance, the API might return up to 10 such ranges, or more, depending on availability.

Quite [SwitchParameter]: If present, suppresses "Nothing found" messages.

RawData [SwitchParameter]: If present, returns the raw JSON response from the API.

New-IPAMSubnet
This function will help you create a new IPAM Subnet.

Usage Example:

New-IPAMSubnet -NewSubnetName "My-New-VLAN" -NewSubnetRange "10.50.10.0" -ParentSubnetId "12345" -CIDR "24"
Parameters:

NewSubnetName (Mandatory) [string]: The name for the new subnet.

NewSubnetRange (Mandatory) [string]: The starting IP address of the new subnet range (network address).

ParentSubnetId (Mandatory) [string]: The ID of the parent subnet under which this new subnet will be created.

CIDR (Mandatory) [string]: The CIDR prefix for the new subnet (e.g., "24").

RawData [SwitchParameter]: If present, returns the raw JSON response from the API.

Remove-IPAMSubnet
This function will help you remove an IPAM Subnet. It includes a confirmation prompt due to its destructive nature.

Usage Example:

Remove-IPAMSubnet -SubnetId "5010"
Parameters:

SubnetId (Mandatory) [string]: The ID of the subnet to be removed.

RawData [SwitchParameter]: If present, returns the raw JSON response from the API.

Note: This function uses [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]. It will prompt for confirmation before deleting unless -Confirm:$false is specified. It also checks if the subnet is a master subnet (has child subnets) and prevents deletion if it is, to avoid orphaning child subnets.

Get-IPAMHosts
This function will help you list all the IP Address entries (hosts) in a specified Subnet.

Usage Example:

Get-IPAMHosts -SubnetId "5010"
Get-IPAMHosts -SubnetId "5010" -RawData
Parameters:

SubnetId [string]: The ID of the subnet for which to list IP host entries.

RawData [SwitchParameter]: If present, returns the raw JSON response from the API.

Quite [SwitchParameter]: If present, suppresses "No hosts found" messages.

Get-IPAMFreeHost
This function will help you find the next available IP address(es) on a specified subnet.

Usage Example:

# Get the next single available IP in subnet 5010 (default behavior)
Get-IPAMFreeHost -SubnetId "5010"

# Get up to 10 available IPs in subnet 5010
Get-IPAMFreeHost -SubnetId "5010" -MaxFind 10

# Get raw API response
Get-IPAMFreeHost -SubnetId "5010" -RawData
Parameters:

SubnetId [string]: The ID of the subnet in which to find free IP addresses.

MaxFind [int] (Default: 1): The maximum number of free IP addresses to find and return. If not specified, one IP address is returned.

RawData [SwitchParameter]: If present, returns the raw JSON response from the API.

Quite [SwitchParameter]: If present, suppresses "No free IP addresses found" messages.

New-IPAMHost
This function will help you create a new IP Host entry in a subnet.

Usage Examples:

New-IPAMHost -IPAddress "10.50.10.5" -Name "webserver01" -SiteID "1001"
New-IPAMHost -IPAddress "10.50.10.6" -Name "dbserver01" -SiteID "1001" -IPClass "Static Servers"
New-IPAMHost -IPAddress "10.50.10.7" -Name "temp-vm" -SiteID "1001" -RawData
Parameters:

IPAddress (Mandatory) [string]: The IP address to assign to the new host entry.

Name (Mandatory) [string]: The hostname or descriptive name for this IP entry.

SiteID (Mandatory) [string]: The ID of the site to associate this IP address with.

IPClass [string]: (Optional) The IP class name (e.g., "Static Server", "DHCP Client").

RawData [SwitchParameter]: If present, returns the raw JSON response from the API.

Quite [SwitchParameter]: If present, suppresses "No IP address was added" messages in some error scenarios.

Get-IPAMHostInfo
This function will help you get details for a specific IP host entry using its IPAM HostID (ip_id).

Usage Example:

Get-IPAMHostInfo -HostID "70532"
Get-IPAMHostInfo -HostID "70532" -RawData
Parameters:

HostID (Mandatory) [string]: The unique identifier (ip_id) of the IP host entry in IPAM.

RawData [SwitchParameter]: If present, returns the raw JSON response from the API.

Get-IPAMHostIP
This function will help you get IP host details using the IP Address itself.

Usage Example:

Get-IPAMHostIP -IPAddress "10.50.10.5"
Get-IPAMHostIP -IPAddress "10.50.10.5" -RawData
Parameters:

IPAddress (Mandatory) [string]: The IP address for which to retrieve details.

RawData [SwitchParameter]: If present, returns the raw JSON response from the API.

Remove-IPAMHostIP
This function will help you remove an IP Address host entry from IPAM. It includes a confirmation prompt.

Usage Example:

Remove-IPAMHostIP -IPAddress "10.50.10.5"
Remove-IPAMHostIP -IPAddress "10.50.10.5" -RawData
Parameters:

IPAddress (Mandatory) [string]: The IP address of the host entry to remove.

RawData [SwitchParameter]: If present, returns the raw JSON response from the API.

Note: This function uses [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]. It will prompt for confirmation before deleting unless -Confirm:$false is specified. It also prevents the deletion of IPs identified as "Gateway" or other non-assignable IPs based on its logic.

General Notes
Error Handling: Most functions include basic error handling and will output messages if an operation fails or if no data is found. For more detailed error information or the raw API response, use the -RawData switch where available.

TLS 1.2: The Set-IPAMAuthURI function explicitly sets the security protocol to TLS 1.2 for communication with the IPAM API.

CIDR Mapping: A global CIDR mapping is initialized by Set-IPAMAuthURI for converting subnet sizes (derived from [math]::log($($subnet.subnet_size),2)) to CIDR notation in some function outputs.

Contributing
Feel free to fork this repository, make improvements, and submit pull requests. If you encounter any bugs or have feature requests, please open an issue on the GitHub repository.

License
This project is provided as-is. You are free to
