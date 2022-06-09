# EfficientIP-Management-for-PowerShell
I wrote this functions/module to manage SOLIDserver EfficientIP from Powershell, and do some autiomation for AWS and Azure. 

You can do following tasks using this function/module.
>Set-IPAMAuthURI - To store access url and credentials in the memory.
>Get-IPAMQueryMaster - To query about master subnet.
>Get-IPAMSubnets - To get details about subnet.
Get-IPAMFreeIP - To get next available subnet form IPAM.
New-IPAMSubnet - To create new subnet in IPAM.
Remove-IPAMSubnet - To remove existing subnet in IPAM.


Sample tasks:
>#Set-IPAMAuthURI -URI "https://url.of.efficient.in" -UserName "UserName-of-efficient-ip" -Password "Password-of-this-account"
#Get-IPAMQueryMaster -SiteNameLike "similar name"
#Get-IPAMQueryMaster -SiteName "exact name"
#Get-IPAMSubnets -SubnetNameLike "similar name"
#Get-IPAMSubnets -SubneteName "exact name"
#Get-IPAMFreeIP -SubnetName "Subnet Name" -CIDR 22
#New-IPAMSubnet -NewSubnetName "My Subnet Name" -NewSubnetRange X.X.X.X -ParentSubnetId 123456 -CIDR 22
#Remove-IPAMSubnet -SubnetId "Subnet Id"

Feel free to update code as you like and request for merge.
