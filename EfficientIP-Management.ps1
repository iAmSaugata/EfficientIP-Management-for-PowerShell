# Name: EfficientIP-Management
# Created By: Saugata Datta
# Version: 2.7
############################

# This function will help you set the IPAM authentication and endpoint details in memory for future use.
# Set-IPAMAuthURI -URI "https://fqdn.efficientip.host" -UserName "Account-Having-Access" -Password "Password-of-this-account"
function Set-IPAMAuthURI {
Param (
    [Parameter(Mandatory=$true)][string] $URI,
    [Parameter(Mandatory=$true)][string] $UserName,
    [Parameter(Mandatory=$true)][string] $Password
)
    [System.Net.ServicePointManager]::SecurityProtocol=[System.Net.SecurityProtocolType]::Tls12
    $Base64AuthInfo=[Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "$UserName","$Password")))
    $global:IPAMAuth=@{Authorization=("Basic {0}" -f $base64AuthInfo)}
    $global:IPAMURI=$URI
    $global:CIDRMapping = @{}
    1..31 | ForEach-Object { $global:CIDRMapping["$_"] = (32 - $_).ToString() }
}

# This function will help you get Query Master Subnet
# Get-IPAMQueryMaster -SiteNameLike "similar name"
# Get-IPAMQueryMaster -SiteName "exact name"
# Get-IPAMQueryMaster -SiteId "SiteID"
function Get-IPAMQueryMaster {
Param (
    [Parameter()][string] $SiteName,
    [Parameter()][string] $SiteId,
    [Parameter()][string] $SiteNameLike,
    [Switch]$RawData
)
    if($IPAMAuth)
    {
        if($SiteName)
        {
            $getMaster=Invoke-RestMethod -Headers $IPAMAuth -Method Get -Uri "$IPAMURI/rest/ip_site_list?WHERE=site_name='$SiteName'" -SkipCertificateCheck
            if(!$RawData.IsPresent)
            {
                if($getMaster)
                {
                    $MyObject=New-Object -TypeName PSObject
                    $MyObject | Add-Member @{MasterSiteName=$($getMaster.site_name)}
                    $MyObject | Add-Member @{MasterSiteId=$($getMaster.site_id)}
                    $MyObject | Add-Member @{MasterSiteDescription=$($getMaster.site_description)}
                    $MyObject | Add-Member @{ParentSiteName=$($getMaster.parent_site_name)}
                    $MyObject | Add-Member @{ParentSitetId=$($getMaster.parent_site_id)}                 
                    return $MyObject
                }
                else
                {
                    Write-Output "Nothing found, please search with correct value."
                }
            }
            else
            {
                if($getMaster)
                {
                    return $getMaster
                }
                else
                {
                    Write-Output "Nothing found, please search with correct value."
                }
            }
        }
        if($SiteID)
        {
            $getMaster=Invoke-RestMethod -Headers $IPAMAuth -Method Get -Uri "$IPAMURI/rest/ip_site_list?WHERE=site_id='$SiteID'" -SkipCertificateCheck
            if(!$RawData.IsPresent)
            {
                if($getMaster)
                {
                    $MyObject=New-Object -TypeName PSObject
                    $MyObject | Add-Member @{MasterSiteName=$($getMaster.site_name)}
                    $MyObject | Add-Member @{MasterSiteId=$($getMaster.site_id)}
                    $MyObject | Add-Member @{MasterSiteDescription=$($getMaster.site_description)}
                    $MyObject | Add-Member @{ParentSiteName=$($getMaster.parent_site_name)}
                    $MyObject | Add-Member @{ParentSitetId=$($getMaster.parent_site_id)}                 
                    return $MyObject
                }
                else
                {
                    Write-Output "Nothing found, please search with correct value."
                }
            }
            else
            {
                if($getMaster)
                {
                    return $getMaster
                }
                else
                {
                    Write-Output "Nothing found, please search with correct value."
                }
            }
        }
        if($SiteNameLike)
        {
            $getMaster=Invoke-RestMethod -Headers $IPAMAuth -Method Get -Uri "$IPAMURI/rest/ip_site_list?WHERE=site_name+like+'%$SiteNameLike%'" -SkipCertificateCheck
            if(!$RawData.IsPresent)
            {
                if($getMaster)
                {
                    $MyObjects=@()
                    foreach($gM in $getMaster)
                    {
                        $MyObject=New-Object -TypeName PSObject
                        $MyObject | Add-Member @{MasterSiteName=$($gM.site_name)}
                        $MyObject | Add-Member @{MasterSiteId=$($gM.site_id)}
                        $MyObject | Add-Member @{MasterSiteDescription=$($gM.site_description)}
                        $MyObject | Add-Member @{ParentSiteName=$($gM.parent_site_name)}
                        $MyObject | Add-Member @{ParentSitetId=$($gM.parent_site_id)}
                        $MyObjects += $MyObject
                    }                 
                    return $MyObjects
                }
                else
                {
                    Write-Output "Nothing found, please search with correct value."
                }
            }
            else
            {
                if($getMaster)
                {
                    return $getMaster
                }
                else
                {
                    Write-Output "Nothing found, please search with correct value."
                }
            }
        }        
    }
    else
    {
        Write-Output "No authentication stored, please store it using Set-IPAMAuthURI command."
    }
}

# This function will help you get the infromation about subnet(s). This function support multiple query string.
# Get-IPAMSubnets -SubnetNameLike "AWS"
# Get-IPAMSubnets -SubnetName "Subnet Name" -RawData
# Get-IPAMSubnets -StartAddress "SubnetStartIP" -RawData
# Get-IPAMSubnets -SubnetId "SubnetID"
# Get-IPAMSubnets -ParentSubnetId "ParentSubnetID"
# Get-IPAMSubnets -SubnetName "Subnet Name"
function Get-IPAMSubnets {
Param (
    [Parameter()][string] $SubnetId,
    [Parameter()][string] $SubnetName,
    [Parameter()][string] $SubnetNameLike,
    [Parameter()][string] $ParentSubnetId,
    [Parameter()][string] $StartAddress,
    [Parameter()][string] $EndAddress,
    [Parameter()][string] $StartAddressLike,
    [Switch]$Quite,
    [Switch]$RawData
)
    if($IPAMAuth)
    {
        if($SubnetName)
        {
            $getSubnets=Invoke-RestMethod -Headers $IPAMAuth -Method Get -Uri "$IPAMURI/rest/ip_block_subnet_list?WHERE=subnet_name='$SubnetName'" -SkipCertificateCheck
            if(!$RawData.IsPresent)
            {
                if($getSubnets)
                {
                    $MyObjects=@()
                    foreach ($subnet in $getSubnets)
                    {
                        $MyObject=New-Object -TypeName PSObject
                        $MyObject | Add-Member @{SubnetName=$($subnet.subnet_name)}       
                        $MyObject | Add-Member @{SubnetId=$($subnet.subnet_id)}
                        $MyObject | Add-Member @{StartAddress=$($subnet.start_hostaddr)}
                        $MyObject | Add-Member @{EndAddress=$($subnet.end_hostaddr)}
                        $MyObject | Add-Member @{CIDR=$CIDRMapping["$([math]::log($($subnet.subnet_size),2))"]}
                        $MyObject | Add-Member @{SubnetUsedPercent=$($subnet.subnet_ip_used_percent)}
                        $MyObject | Add-Member @{ParentSubnetId=$($subnet.parent_subnet_id)}
                        $MyObject | Add-Member @{IPAMSiteName=$($subnet.site_name)}
                        $MyObject | Add-Member @{IPAMSiteId=$($subnet.site_id)}
                        $MyObjects += $MyObject
                        #$ipAddress=-join ((0..3 | ForEach-Object { [convert]::ToInt32($hexValue.Substring($_ * 2, 2), 16) }) -join '.'); Write-Output $ipAddress
                    }                    
                    return $MyObjects
                }
                else
                {
                    if(!$Quite.IsPresent)
                    {
                        Write-Output "Nothing found, please search with correct value."
                    }
                }
            }
            else
            {
                if($getSubnets)
                {
                    return $getSubnets
                }
                else
                {
                    if(!$Quite.IsPresent)
                    {
                        Write-Output "Nothing found, please search with correct value."
                    }
                }
            }
        }
        if($StartAddress)
        {
            $getSubnets=Invoke-RestMethod -Headers $IPAMAuth -Method Get -Uri "$IPAMURI/rest/ip_block_subnet_list?WHERE=start_hostaddr='$StartAddress'" -SkipCertificateCheck
            if(!$RawData.IsPresent)
            {
                if($getSubnets)
                {
                    $MyObjects=@()
                    foreach ($subnet in $getSubnets)
                    {
                        $MyObject=New-Object -TypeName PSObject
                        $MyObject | Add-Member @{SubnetName=$($subnet.subnet_name)}       
                        $MyObject | Add-Member @{SubnetId=$($subnet.subnet_id)}
                        $MyObject | Add-Member @{StartAddress=$($subnet.start_hostaddr)}
                        $MyObject | Add-Member @{EndAddress=$($subnet.end_hostaddr)}
                        $MyObject | Add-Member @{CIDR=$CIDRMapping["$([math]::log($($subnet.subnet_size),2))"]}
                        $MyObject | Add-Member @{SubnetUsedPercent=$($subnet.subnet_ip_used_percent)}
                        $MyObject | Add-Member @{ParentSubnetId=$($subnet.parent_subnet_id)}
                        $MyObject | Add-Member @{IPAMSiteName=$($subnet.site_name)}
                        $MyObject | Add-Member @{IPAMSiteId=$($subnet.site_id)}
                        $MyObjects += $MyObject
                    }                    
                    return $MyObjects
                }
                else
                {
                    if(!$Quite.IsPresent)
                    {
                        Write-Output "Nothing found, please search with correct value."
                    }
                }
            }
            else
            {
                if($getSubnets)
                {
                    return $getSubnets
                }
                else
                {
                    if(!$Quite.IsPresent)
                    {
                        Write-Output "Nothing found, please search with correct value."
                    }
                }
            }
        }
        if($EndAddress)
        {
            $getSubnets=Invoke-RestMethod -Headers $IPAMAuth -Method Get -Uri "$IPAMURI/rest/ip_block_subnet_list?WHERE=end_hostaddr='$EndAddress'" -SkipCertificateCheck
            if(!$RawData.IsPresent)
            {
                if($getSubnets)
                {
                    $MyObjects=@()
                    foreach ($subnet in $getSubnets)
                    {
                        $MyObject=New-Object -TypeName PSObject
                        $MyObject | Add-Member @{SubnetName=$($subnet.subnet_name)}       
                        $MyObject | Add-Member @{SubnetId=$($subnet.subnet_id)}
                        $MyObject | Add-Member @{StartAddress=$($subnet.start_hostaddr)}
                        $MyObject | Add-Member @{EndAddress=$($subnet.end_hostaddr)}
                        $MyObject | Add-Member @{CIDR=$CIDRMapping["$([math]::log($($subnet.subnet_size),2))"]}
                        $MyObject | Add-Member @{SubnetUsedPercent=$($subnet.subnet_ip_used_percent)}
                        $MyObject | Add-Member @{ParentSubnetId=$($subnet.parent_subnet_id)}
                        $MyObject | Add-Member @{IPAMSiteName=$($subnet.site_name)}
                        $MyObject | Add-Member @{IPAMSiteId=$($subnet.site_id)}
                        $MyObjects += $MyObject
                    }                    
                    return $MyObjects
                }
                else
                {
                    if(!$Quite.IsPresent)
                    {
                        Write-Output "Nothing found, please search with correct value."
                    }
                }
            }
            else
            {
                if($getSubnets)
                {
                    return $getSubnets
                }
                else
                {
                    if(!$Quite.IsPresent)
                    {
                        Write-Output "Nothing found, please search with correct value."
                    }
                }
            }
        }
        if($StartAddressLike)
        {
            $getSubnets=Invoke-RestMethod -Headers $IPAMAuth -Method Get -Uri "$IPAMURI/rest/ip_block_subnet_list?WHERE=start_hostaddr+like+'%$StartAddressLike%'" -SkipCertificateCheck
            if(!$RawData.IsPresent)
            {
                if($getSubnets)
                {
                    $MyObjects=@()
                    foreach ($subnet in $getSubnets)
                    {
                        $MyObject=New-Object -TypeName PSObject
                        $MyObject | Add-Member @{SubnetName=$($subnet.subnet_name)}       
                        $MyObject | Add-Member @{SubnetId=$($subnet.subnet_id)}
                        $MyObject | Add-Member @{StartAddress=$($subnet.start_hostaddr)}
                        $MyObject | Add-Member @{EndAddress=$($subnet.end_hostaddr)}
                        $MyObject | Add-Member @{CIDR=$CIDRMapping["$([math]::log($($subnet.subnet_size),2))"]}
                        $MyObject | Add-Member @{SubnetUsedPercent=$($subnet.subnet_ip_used_percent)}
                        $MyObject | Add-Member @{ParentSubnetId=$($subnet.parent_subnet_id)}
                        $MyObject | Add-Member @{IPAMSiteName=$($subnet.site_name)}
                        $MyObject | Add-Member @{IPAMSiteId=$($subnet.site_id)}
                        $MyObjects += $MyObject
                    }                    
                    return $MyObjects
                }
                else
                {
                    if(!$Quite.IsPresent)
                    {
                        Write-Output "Nothing found, please search with correct value."
                    }
                }
            }
            else
            {
                if($getSubnets)
                {
                    return $getSubnets
                }
                else
                {
                    if(!$Quite.IsPresent)
                    {
                        Write-Output "Nothing found, please search with correct value."
                    }
                }
            }
        }
        if($SubnetNameLike)
        {
            $getSubnets=Invoke-RestMethod -Headers $IPAMAuth -Method Get -Uri "$IPAMURI/rest/ip_block_subnet_list?WHERE=subnet_name+like+'%$SubnetNameLike%'" -SkipCertificateCheck
            if(!$RawData.IsPresent)
            {
                if($getSubnets)
                {
                    $MyObjects=@()
                    foreach ($subnet in $getSubnets)
                    {
                        $MyObject=New-Object -TypeName PSObject
                        $MyObject | Add-Member @{SubnetName=$($subnet.subnet_name)}       
                        $MyObject | Add-Member @{SubnetId=$($subnet.subnet_id)}
                        $MyObject | Add-Member @{StartAddress=$($subnet.start_hostaddr)}
                        $MyObject | Add-Member @{EndAddress=$($subnet.end_hostaddr)}
                        $MyObject | Add-Member @{CIDR=$CIDRMapping["$([math]::log($($subnet.subnet_size),2))"]}
                        $MyObject | Add-Member @{SubnetUsedPercent=$($subnet.subnet_ip_used_percent)}
                        $MyObject | Add-Member @{ParentSubnetId=$($subnet.parent_subnet_id)}
                        $MyObject | Add-Member @{IPAMSiteName=$($subnet.site_name)}
                        $MyObject | Add-Member @{IPAMSiteId=$($subnet.site_id)}
                        $MyObjects += $MyObject
                    }                    
                    return $MyObjects
                }
                else
                {
                    if(!$Quite.IsPresent)
                    {
                        Write-Output "Nothing found, please search with correct value."
                    }
                }
            }
            else
            {
                if($getSubnets)
                {
                    return $getSubnets
                }
                else
                {
                    if(!$Quite.IsPresent)
                    {
                        Write-Output "Nothing found, please search with correct value."
                    }
                }
            }
        }
        if($ParentSubnetId)
        {
            $getSubnets=Invoke-RestMethod -Headers $IPAMAuth -Method Get -Uri "$IPAMURI/rest/ip_block_subnet_list?WHERE=parent_subnet_id=$parentSubnetID" -SkipCertificateCheck
            #$getSubnets
            if(!$RawData.IsPresent)
            {
                if($getSubnets)
                {
                    $MyObjects=@()
                    foreach ($subnet in $getSubnets)
                    {
                        $MyObject=New-Object -TypeName PSObject
                        $MyObject | Add-Member @{SubnetName=$($subnet.subnet_name)}       
                        $MyObject | Add-Member @{SubnetId=$($subnet.subnet_id)}
                        $MyObject | Add-Member @{StartAddress=$($subnet.start_hostaddr)}
                        $MyObject | Add-Member @{EndAddress=$($subnet.end_hostaddr)}
                        $MyObject | Add-Member @{CIDR=$CIDRMapping["$([math]::log($($subnet.subnet_size),2))"]}
                        $MyObject | Add-Member @{SubnetUsedPercent=$($subnet.subnet_ip_used_percent)}
                        $MyObject | Add-Member @{ParentSubnetId=$($subnet.parent_subnet_id)}
                        $MyObject | Add-Member @{IPAMSiteName=$($subnet.site_name)}
                        $MyObject | Add-Member @{IPAMSiteId=$($subnet.site_id)}
                        $MyObjects += $MyObject                        
                    }                    
                    return $MyObjects
                }
                else
                {
                    if(!$Quite.IsPresent)
                    {
                        Write-Output "Nothing found, please search with correct value."
                    }
                }
            }
            else
            {
                if($getSubnets)
                {
                    return $getSubnets
                }
                else
                {
                    if(!$Quite.IsPresent)
                    {
                        Write-Output "Nothing found, please search with correct value."
                    }
                }
            }
        }
        if($SubnetId)
        {
            $getSubnets=Invoke-RestMethod -Headers $IPAMAuth -Method Get -Uri "$IPAMURI/rest/ip_block_subnet_list?WHERE=subnet_id='$subnetID'" -SkipCertificateCheck
            #$getSubnets
            if(!$RawData.IsPresent)
            {
                if($getSubnets)
                {                    
                    $MyObjects=@()
                    foreach ($subnet in $getSubnets)
                    {
                        $MyObject=New-Object -TypeName PSObject
                        $MyObject | Add-Member @{SubnetName=$($subnet.subnet_name)}       
                        $MyObject | Add-Member @{SubnetId=$($subnet.subnet_id)}
                        $MyObject | Add-Member @{StartAddress=$($subnet.start_hostaddr)}
                        $MyObject | Add-Member @{EndAddress=$($subnet.end_hostaddr)}
                        $MyObject | Add-Member @{CIDR=$CIDRMapping["$([math]::log($($subnet.subnet_size),2))"]}
                        $MyObject | Add-Member @{SubnetUsedPercent=$($subnet.subnet_ip_used_percent)}
                        $MyObject | Add-Member @{ParentSubnetId=$($subnet.parent_subnet_id)}
                        $MyObject | Add-Member @{IPAMSiteName=$($subnet.site_name)}
                        $MyObject | Add-Member @{IPAMSiteId=$($subnet.site_id)}
                        $MyObjects += $MyObject
                    }                    
                    return $MyObjects
                }
                else
                {
                    if(!$Quite.IsPresent)
                    {
                        Write-Output "Nothing found, please search with correct value."
                    }
                }
            }
            else
            {
                if($getSubnets)
                {
                    return $getSubnets
                }
                else
                {
                    if(!$Quite.IsPresent)
                    {
                        Write-Output "Nothing found, please search with correct value."
                    }
                }
            }
        }
    }
    else
    {
        Write-Output "No authentication stored, please store it using Set-IPAMAuthURI command."
    }
}

# This function will help you get the get the next availabel Subnet range in a parent subnet.
# Get-IPAMFreeSubnetIP -SubnetName "Subnet Name" -CIDR 22
function Get-IPAMFreeSubnetIP {
Param (
    [Parameter()][int] $SubnetId,
    [Parameter()][string] $SubnetName,
    [Parameter(Mandatory=$true)][string] $CIDR,
    [Switch]$All,
    [Switch]$Quite,
    [Switch]$RawData
)
    if($IPAMAuth)
    {
        if($SubnetName -and $CIDR)
        {
            $getFreeSubnet=Invoke-RestMethod -Headers $IPAMAuth -Method Get -Uri "$IPAMURI/rpc/ip_find_free_subnet?prefix=$CIDR&WHERE=subnet_name='$SubnetName'" -SkipCertificateCheck
            if(!$RawData.IsPresent)
            {
                if($getFreeSubnet)
                {   
                    if(!$All.IsPresent)
                    {
                        #$($getFreeSubnet).start_ip_addr | % { (($_-Split '(..)' -ne '' |  % { [int]"0x$_" }) -join '.')} 
                        $MyObject=New-Object -TypeName PSObject
                        $MyObject | Add-Member @{NewSubnetCIDR=($(($getFreeSubnet)[0].start_ip_addr -split '(..)' -ne '' | % { [int]"0x$_" }) -join '.')}
                        $MyObject | Add-Member @{CIDR=$CIDR}
                        $MyObject | Add-Member @{ParentSubnetName=$($getFreeSubnet[0].block_name)}
                        $MyObject | Add-Member @{ParentSubnetId=$($getFreeSubnet[0].block_id)}
                        $MyObject | Add-Member @{MasterSiteId=$($getFreeSubnet[0].site_id)}                   
                        return $MyObject
                    }
                    else
                    {
                        $MyObjects=@()
                        foreach($gfs in $getFreeSubnet)
                        {
                            #$($getFreeSubnet).start_ip_addr | % { (($_-Split '(..)' -ne '' |  % { [int]"0x$_" }) -join '.')} 
                            $MyObject=New-Object -TypeName PSObject
                            $MyObject | Add-Member @{NewSubnetCIDR=($(($gfs).start_ip_addr -split '(..)' -ne '' | % { [int]"0x$_" }) -join '.')}
                            $MyObject | Add-Member @{CIDR=$CIDR}
                            $MyObject | Add-Member @{ParentSubnetName=$($gfs.block_name)}
                            $MyObject | Add-Member @{ParentSubnetId=$($gfs.block_id)}
                            $MyObject | Add-Member @{MasterSiteId=$($gfs.site_id)}
                            $MyObjects += $MyObject
                        }
                        return $MyObjects
                    }
                }
                else
                {
                    if(!$Quite.IsPresent)
                    {
                        Write-Output "Nothing found, please search with correct value."
                    }
                }
            }
            else
            {
                if($getFreeSubnet)
                {
                    return $getFreeSubnet
                }
                else
                {
                    Write-Output "Missing information, you have to specify correct SubnetName and CIDR value."
                }
            }
        }
        if($SubnetId -and $CIDR)
        {
            $getFreeSubnet=Invoke-RestMethod -Headers $IPAMAuth -Method Get -Uri "$IPAMURI/rpc/ip_find_free_subnet?prefix=$CIDR&WHERE=block_id='$SubnetId'" -SkipCertificateCheck
            if(!$RawData.IsPresent)
            {
                if($getFreeSubnet)
                {   
                    if(!$All.IsPresent)
                    {
                        #$($getFreeSubnet).start_ip_addr | % { (($_-Split '(..)' -ne '' |  % { [int]"0x$_" }) -join '.')} 
                        $MyObject=New-Object -TypeName PSObject
                        $MyObject | Add-Member @{NewSubnetCIDR=($(($getFreeSubnet)[0].start_ip_addr -split '(..)' -ne '' | % { [int]"0x$_" }) -join '.')}
                        $MyObject | Add-Member @{CIDR=$CIDR}
                        $MyObject | Add-Member @{ParentSubnetName=$($getFreeSubnet[0].block_name)}
                        $MyObject | Add-Member @{ParentSubnetId=$($getFreeSubnet[0].block_id)}
                        $MyObject | Add-Member @{MasterSiteId=$($getFreeSubnet[0].site_id)}                   
                        return $MyObject
                    }
                    else
                    {
                        $MyObjects=@()
                        foreach($gfs in $getFreeSubnet)
                        {
                            #$($getFreeSubnet).start_ip_addr | % { (($_-Split '(..)' -ne '' |  % { [int]"0x$_" }) -join '.')} 
                            $MyObject=New-Object -TypeName PSObject
                            $MyObject | Add-Member @{NewSubnetCIDR=($(($gfs).start_ip_addr -split '(..)' -ne '' | % { [int]"0x$_" }) -join '.')}
                            $MyObject | Add-Member @{CIDR=$CIDR}
                            $MyObject | Add-Member @{ParentSubnetName=$($gfs.block_name)}
                            $MyObject | Add-Member @{ParentSubnetId=$($gfs.block_id)}
                            $MyObject | Add-Member @{MasterSiteId=$($gfs.site_id)}
                            $MyObjects += $MyObject
                        }
                        return $MyObjects
                    }
                }
                else
                {
                    if(!$Quite.IsPresent)
                    {
                        Write-Output "Nothing found, please search with correct value."
                    }
                }
            }
            else
            {
                if($getFreeSubnet)
                {
                    return $getFreeSubnet
                }
                else
                {
                    Write-Output "Missing information, you have to specify correct SubnetName and CIDR value."
                }
            }
        }     
    }
    else
    {
        Write-Output "No authentication stored, please store it using Set-IPAMAuthURI command."
    }
}

# This function will help you create new IPAM Subnet
# New-IPAMSubnet -NewSubnetName "My Subnet Name" -NewSubnetRange X.X.X.X -ParentSubnetId 12345 -CIDR 22
function New-IPAMSubnet {
Param (
    [Parameter(Mandatory=$true)][string] $NewSubnetName,
    [Parameter(Mandatory=$true)][string] $NewSubnetRange,
    [Parameter(Mandatory=$true)][string] $ParentSubnetId,
    [Parameter(Mandatory=$true)][string] $CIDR,
    [Switch]$RawData
)
    if($IPAMAuth)
    {
        if($NewSubnetName -and $CIDR)
        {
            $newSubnet=Invoke-RestMethod -Headers $IPAMAuth -Method Post -Uri "$IPAMURI/rpc/ip_subnet_add?subnet_addr=$NewSubnetRange&subnet_prefix=$CIDR&parent_subnet_id=$ParentSubnetId&subnet_name=$NewSubnetName" -SkipCertificateCheck
            if(!$RawData.IsPresent)
            {
                $($newSubnet.errno)
                if($($newSubnet.errno))
                {
                    Write-Output "$($newSubnet.errmsg), you have to specify correct value."
                    break;
                }
                if($newSubnet)
                {                
                    $MyObject=New-Object -TypeName PSObject
                    $MyObject | Add-Member @{NewSubnetName=$NewSubnetName}
                    $MyObject | Add-Member @{NewSubnetID=$newSubnet.ret_oid}
                    $MyObject | Add-Member @{NewSubnetCIDR=$CIDR}
                    #$MyObject | Add-Member @{ParentSubnetId=$ParentSubnetId} 
                    Write-Output "Subnet created successfully with SubnetId : $($newSubnet.ret_oid)"              
                    return $MyObject
                }                
                else
                {
                    Write-Output "Missing information, you have to specify correct value."
                }
            }
            else
            {
                if($newSubnet)
                {
                    return $newSubnet
                }
                else
                {
                    Write-Output "Missing information, you have to specify correct SubnetName, SubnetRange, Parent Subnet Id and CIDR value."
                }
            }
        }      
    }
    else
    {
        Write-Output "No authentication stored, please store it using Set-IPAMAuthURI command."
    }
}

# This function will help you remove IPAM Subnet
# Remove-IPAMSubnet -SubnetId "Subnet Id"
function Remove-IPAMSubnet {
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
Param (
    [Parameter(Mandatory=$true)][string] $SubnetId,
    [Switch]$RawData
)
    if($IPAMAuth)
    {
        if($SubnetId)
        {
            $verifySubnet=Invoke-RestMethod -Headers $IPAMAuth -Method Get -Uri "$IPAMURI/rest/ip_block_subnet_list?WHERE=subnet_id='$SubnetId'" -SkipCertificateCheck
            if($verifySubnet)
            {
                if($(Get-IPAMSubnets -ParentSubnetId $SubnetId -Quite))
                {
                    Write-Output "'$($verifySubnet.subnet_name)' is a master subnet, not allowed to delete from here."
                    break;
                }
                $SiteId=$($verifySubnet.site_id)
                if ($PSCmdlet.ShouldProcess("Subnet Name - '$($verifySubnet.subnet_name)' : Subnet Id - $SubnetId"))
                {
                    $removeSubnet=Invoke-RestMethod -Headers $IPAMAuth -Method Post -Uri "$IPAMURI/rpc/ip_subnet_delete?subnet_id=$SubnetId&site_id=$SiteId" -SkipCertificateCheck                   
                    if(!$RawData.IsPresent)
                    {
                        if($removeSubnet)
                        {                
                            $MyObject=New-Object -TypeName PSObject
                            $MyObject | Add-Member @{SubnetName=$($verifySubnet.subnet_name)}
                            $MyObject | Add-Member @{SubnetId=$SubnetId}
                            $MyObject | Add-Member @{SiteId=$SiteId} 
                            Write-Output "Subnet deleted successfully."            
                            return $MyObject
                        }
                    }
                    else
                    {
                        if($removeSubnet)
                        {
                            return $removeSubnet
                        }
                        else
                        {
                            Write-Output "Missing information, you have to specify correct SubnetId."
                        }
                    }
                }
            }
            else
            {
                Write-Output "You have to specify correct SubnetId."
            }
        }      
    }
    else
    {
        Write-Output "No authentication stored, please store it using Set-IPAMAuthURI command."
    }
}

# This function will help you list all the IP Address in Subnet
# Get-IPAMHosts "SubnetID"
function Get-IPAMHosts {
    Param (
        [Parameter()][string] $SubnetId,
        [Switch] $RawData,
        [Switch] $Quite
    )

    if ($IPAMAuth) {
        if ($SubnetId) {
            $getHosts=Invoke-RestMethod -Headers $IPAMAuth -Method Get -Uri "$IPAMURI/rest/ip_address_list?WHERE=subnet_id='$SubnetId'" -SkipCertificateCheck
            if (!$RawData.IsPresent) {
                if ($getHosts) {
                    $HostObjects=@()
                    foreach ($hostx in $getHosts) {
                        $HostObject=New-Object -TypeName PSObject
                        $HostObject | Add-Member @{IPAddress=$($hostx.hostaddr)}
                        $HostObject | Add-Member @{HostID=$($hostx.ip_id)}
                        $HostObject | Add-Member @{HostName=$($hostx.name)}
                        $HostObject | Add-Member @{SubnetName=$($hostx.subnet_name)}
                        $HostObject | Add-Member @{SubnetId=$($hostx.subnet_id)}
                        $HostObjects += $HostObject
                    }
                    return $HostObjects
                } else {
                    if (!$Quite.IsPresent) {
                        Write-Output "No hosts found in the specified subnet."
                    }
                }
            } else {
                if ($getHosts) {
                    return $getHosts
                } else {
                    if (!$Quite.IsPresent) {
                        Write-Output "No hosts found in the specified subnet."
                    }
                }
            }
        } else {
            Write-Output "Please provide a SubnetId to fetch host information."
        }
    } else {
        Write-Output "No authentication stored, please store it using Set-IPAMAuthURI command."
    }
}

# This function will help you find next avaialbel IP address on a subnet
# Get-IPAMFreeHost -SubnetId "SubnetID" -MaxFind 5
function Get-IPAMFreeHost {
    Param (
        [Parameter()][string] $SubnetId,
        [Parameter()][int] $MaxFind=1,
        [Switch] $RawData,
        [Switch] $Quite
    )

    if ($IPAMAuth) {
        if ($SubnetId) {
            # Define the API endpoint
            $url="$IPAMURI/rpc/ip_find_free_address?subnet_id=$SubnetId&max_find=$MaxFind"

            try {
                $response=Invoke-RestMethod -Uri $url -Method Get -Headers $IPAMAuth -SkipCertificateCheck

                if (!$RawData.IsPresent) {
                    if ($response) {
                        $FreeIPList=@()
                        foreach ($ipx in $response) {
                            $FreeIP=New-Object -TypeName PSObject
                            $FreeIP | Add-Member @{IPAddress=$($ipx.hostaddr)}
                            $FreeIP | Add-Member @{SubnetId=$($ipx.subnet_id)}
                            $FreeIP | Add-Member @{SiteId=$($ipx.site_id)}
                            $FreeIP | Add-Member @{Sitename=$($ipx.site_name)}
                            #$FreeIP | Add-Member @{SubnetName=$($ipx.subnet_name)}
                            $FreeIPList += $FreeIP
                        }
                        return $FreeIPList
                    } else {
                        if (!$Quite.IsPresent) {
                            Write-Host -ForegroundColor Yellow "No free IP addresses found in the specified subnet."
                        }
                    }
                } else {
                    if ($response) {
                        return $response
                    } else {
                        if (!$Quite.IsPresent) {
                            Write-Host -ForegroundColor Yellow "No free IP addresses found in the specified subnet."
                        }
                    }
                }
            } catch {
                Write-Host -ForegroundColor Red "Error retrieving free IP addresses: $_"
            }
        } else {
            Write-Host -ForegroundColor Red "Please provide a SubnetId to fetch free IP addresses."
        }
    } else {
        Write-Host -ForegroundColor Red "No authentication stored, please store it using Set-IPAMAuthURI command."
    }
}

# This function will help you create new IP Entry in Subnet
# New-IPAMHost -IPAddress "Free IP Address" -Name "HostName" -SiteID "SiteID"
# New-IPAMHost -IPAddress "Free IP Address" -Name "HostName" -SiteID "SiteID" -IPClass "IP-Class-Type"
function New-IPAMHost {
    Param (
        [Parameter(Mandatory=$true)][string] $IPAddress,
        [Parameter(Mandatory=$true)][string] $Name,
        [Parameter(Mandatory=$true)][string] $SiteID,
        [Parameter()][string] $IPClass,     
        [Switch] $RawData,
        [Switch] $Quite
    )

    if ($IPAMAuth) {
        # Construct the API URL
        if($IPClass)
        {
            $url="$IPAMURI/rest/ip_add?hostaddr=$IPAddress&name=$Name&site_id=$SiteID&ip_class_name=$IPClass"
        }
        else
        {
            $url="$IPAMURI/rest/ip_add?hostaddr=$IPAddress&name=$Name&site_id=$SiteID"
        }        

        try {
            # Make the API call
            $response=Invoke-RestMethod -Uri $url -Method Post -Headers $IPAMAuth -SkipCertificateCheck -ErrorAction SilentlyContinue

            # Check for a successful response
            if (!$RawData.IsPresent) {
                if ($response.ret_oid) {
                    # Create the result object and add properties using the short form
                    $HostObject=New-Object -TypeName PSObject
                    $HostObject | Add-Member @{IPAddress=$IPAddress}
                    $HostObject | Add-Member @{HostID=$response.ret_oid}
                    $HostObject | Add-Member @{HostName=$Name}
                    $HostObject | Add-Member @{SiteName=(Get-IPAMQueryMaster -SiteId $SiteID).MasterSiteName}
                    $HostObject | Add-Member @{SiteID=$SiteID}

                    # Return the result object
                    return $HostObject
                } else {
                    if (-not $Quite.IsPresent) {
                        Write-Output "No IP address was added. Check the response for more details."
                    }
                }
            } else {
                if ($response) {
                    return $response
                } else {
                    if (!$Quite.IsPresent) {
                        Write-Output "No free IP addresses found in the specified subnet."
                    }
                }
            }
        } catch {
            # Error handling with detailed error message
            $exception = $_.ToString().Trim() | ConvertFrom-Json
            # Write-Output $exception
            if($($exception.ip_addr)) {                
                Write-Output "Failed to create entry for $IPAddress in IPAM with error code $($exception.errno). Name $Name already used by $($exception.ip_addr)."
            } else {
                Write-Output "$_"
            }
            # Write-Output "Severity: $($exception.severity)"
            # Write-Output "Error Number: $($exception.errno)"
            # Write-Output "Error Message: $($exception.errmsg)"
            # Write-Output "IP Address: $($exception.ip_addr)"
            # Write-Output "Site Name: $($exception.site_name)"
            # Write-Host -ForegroundColor Red "$jsonObject"
        }
    } else {
        # Handle missing authentication
        Write-Output "No authentication stored. Please use the Set-IPAMAuthURI command to store authentication."
    }
}

# This function will help you get IP details using IPID or HostID
# Get-IPAMHostInfo -HostID "HostID"
function Get-IPAMHostInfo {
    Param (
        [Parameter(Mandatory=$true)][string] $HostID,
        [Switch] $RawData
    )

    if ($IPAMAuth) {
        # Construct the API URL
        $url="$IPAMURI/rest/ip_address_info?ip_id=$HostID"
        
        try {
            # Make the API call
            $response=Invoke-RestMethod -Uri $url -Method Get -Headers $IPAMAuth -SkipCertificateCheck

            if ($response) {
                if ($RawData.IsPresent) {
                    # Return raw data if RawData switch is present
                    return $response
                } else {
                    # Create the result object and add properties using the short form
                    $HostInfo=New-Object -TypeName PSObject
                    $HostInfo | Add-Member @{HostID=$HostID}
                    $HostInfo | Add-Member @{IPAddress=$response.hostaddr}
                    $HostInfo | Add-Member @{HostName=$response.name}                    
                    $HostInfo | Add-Member @{SubnetName=$response.subnet_name}
                    $HostInfo | Add-Member @{SubnetID=$response.subnet_id}
                    $HostInfo | Add-Member @{SiteName=$response.site_name}
                    $HostInfo | Add-Member @{SiteID=$response.site_id}

                    # Return the result object
                    return $HostInfo
                }
            } else {
                Write-Output "No information found for HostID: $HostID"
            }
        } catch {
            # Error handling with detailed error message
            Write-Output "Error retrieving information for HostID $HostID : $_"
        }
    } else {
        # Handle missing authentication
        Write-Output "No authentication stored. Please use the Set-IPAMAuthURI command to store authentication."
    }
}

# This function will help you get IP details using IPAddress
# Get-IPAMHostIP -IPAddress "IPAddress"
function Get-IPAMHostIP {
    Param (
        [Parameter(Mandatory=$true)][string] $IPAddress,
        [Switch] $RawData
    )

    if ($IPAMAuth) {
        # Construct the API URL
        $url="$IPAMURI/rest/ip_address_list?WHERE=hostaddr='$IPAddress'"        
        try {
            # Make the API call
            $response=Invoke-RestMethod -Uri $url -Method Get -Headers $IPAMAuth -SkipCertificateCheck

            if ($response) {
                if ($RawData.IsPresent) {
                    # Return raw data if RawData switch is present
                    return $response
                } else {
                    # Create the result object and add properties using the short form
                    $HostInfo=New-Object -TypeName PSObject
                    $HostInfo | Add-Member @{HostID=$response.ip_id}
                    $HostInfo | Add-Member @{IPType=$response.type}
                    $HostInfo | Add-Member @{IPClass=$response.ip_class_name}
                    $HostInfo | Add-Member @{IPAddress=$response.hostaddr}
                    $HostInfo | Add-Member @{HostName=$response.name}                    
                    $HostInfo | Add-Member @{SubnetName=$response.subnet_name}
                    $HostInfo | Add-Member @{SubnetID=$response.subnet_id}
                    $HostInfo | Add-Member @{SiteName=$response.site_name}
                    $HostInfo | Add-Member @{SiteID=$response.site_id}

                    # Return the result object
                    return $HostInfo
                }
            } else {
                # Keep Write-Host - This will not stored in variable.
                Write-Host "No information found for IPAddress: $IPAddress"
            }
        } catch {
            # Error handling with detailed error message
            Write-Output "Error retrieving information for IPAddress $IPAddress : $_"
        }
    } else {
        # Handle missing authentication
        Write-Output "No authentication stored. Please use the Set-IPAMAuthURI command to store authentication."
    }
}

# This function will help you Remove IPAddress from IPAM
# Remove-IPAMHostIP -IPAddress "IPAddress"
function Remove-IPAMHostIP {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    Param (
        [Parameter(Mandatory = $true)][string]$IPAddress,
        [Switch]$RawData
    )

    if (-not $IPAMAuth) {
        Write-Output "No authentication stored. Please store it using Set-IPAMAuthURI command."
        return
    }

    # Fetch IP details from IPAM
    $verifyIPAddress = Invoke-RestMethod -Headers $IPAMAuth -Method Get -Uri "$IPAMURI/rest/ip_address_list?WHERE=hostaddr='$IPAddress'" -SkipCertificateCheck

    if (-not $verifyIPAddress) {
        Write-Output "The specified IP address '$IPAddress' was not found in IPAM."
        return
    }

    # Check if the IP is a gateway or non-assignable IP
    if ($verifyIPAddress.name -like "Gatewa*" -or 
        $verifyIPAddress.hostaddr -eq $verifyIPAddress.subnet_start_hostaddr -or 
        $verifyIPAddress.hostaddr -eq $verifyIPAddress.subnet_end_hostaddr) {
        Write-Output "The IP address '$IPAddress' is a Gateway or a Non-Assignable IP, and cannot be deleted."
        return
    }

    $SiteId = $verifyIPAddress.site_id

    if ($PSCmdlet.ShouldProcess("Host Name - '$($verifyIPAddress.name)' : IPAddress - $IPAddress", "Delete")) {
        $removeIPAddress = Invoke-RestMethod -Headers $IPAMAuth -Method Post -Uri "$IPAMURI/rpc/ip_delete?hostaddr=$IPAddress&site_id=$SiteId" -SkipCertificateCheck

        if (-not $removeIPAddress) {
            Write-Output "Failed to delete IP address '$IPAddress'."
            return
        }

        if ($RawData.IsPresent) {
            return $removeIPAddress
        }

        # Create and return a PowerShell object with deleted IP details
        $MyObject = [PSCustomObject]@{
            HostID    = $verifyIPAddress.ip_id
            IPAddress = $IPAddress
            HostName  = $verifyIPAddress.name
            SubnetName = $verifyIPAddress.subnet_name
            SubnetID  = $verifyIPAddress.subnet_id
            SiteName  = $verifyIPAddress.site_name
            SiteId    = $SiteId
        }

        Write-Output "IP address '$IPAddress' deleted successfully."
        return $MyObject
    }
}
