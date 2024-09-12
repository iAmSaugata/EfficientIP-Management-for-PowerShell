# EfficientIP-Management-for-PowerShell
I wrote this functions/module to manage SOLIDserver EfficientIP from PowerShell, and do some automation for AWS and Azure.

You can do following tasks using this function/module.

# This function will help you set the IPAM authentication and endpoint details in memory for future use.
Set-IPAMAuthURI -URI "https://fqdn.efficientip.host" -UserName "Account-Having-Access" -Password "Password-of-this-account"

# This function will help you get Query Master Subnet
Get-IPAMQueryMaster -SiteNameLike "similar name"

Get-IPAMQueryMaster -SiteName "exact name"

Get-IPAMQueryMaster -SiteId "SiteID"

# This function will help you get the infromation about subnet(s). This function support multiple query string.
Get-IPAMSubnets -SubnetNameLike "AWS"
Get-IPAMSubnets -SubnetName "Subnet Name" -RawData
Get-IPAMSubnets -StartAddress "SubnetStartIP" -RawData
Get-IPAMSubnets -SubnetId "SubnetID"
Get-IPAMSubnets -ParentSubnetId "ParentSubnetID"
Get-IPAMSubnets -SubnetName "Subnet Name"

# This function will help you get the get the next availabel Subnet range in a parent subnet.
 Get-IPAMFreeSubnetIP -SubnetName "Subnet Name" -CIDR 22

# This function will help you create new IPAM Subnet
New-IPAMSubnet -NewSubnetName "My Subnet Name" -NewSubnetRange X.X.X.X -ParentSubnetId 12345 -CIDR 22

# This function will help you remove IPAM Subnet
Remove-IPAMSubnet -SubnetId "Subnet Id"

# This function will help you list all the IP Address in Subnet
Get-IPAMHosts "SubnetID"

# This function will help you find next avaialbel IP address on a subnet
Get-IPAMFreeHost -SubnetId "SubnetID" -MaxFind 5

# This function will help you create new IP Entry in Subnet
New-IPAMHost -IPAddress "Free IP Address" -Name "HostName" -SiteID "SiteID"

# This function will help you get IP details using IPID or HostID
Get-IPAMHostInfo -HostID "HostID"

# This function will help you get IP details using IPAddress
Get-IPAMHostIP -IPAddress "IPAddress"

# This function will help you Remove IPAddress from IPAM
Remove-IPAMHostIP -IPAddress "IPAddress"

Feel free to update code as you like and request for merge.
