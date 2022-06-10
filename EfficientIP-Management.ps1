# Name: EfficientIP-Management
# Created By: Saugata Datta
# Version: 1.1
###########################
#Set-IPAMAuthURI -URI "https://fqdn.efficientip.host" -UserName "Account-Having-Access" -Password "Password-of-this-account"
function Set-IPAMAuthURI{
Param (
    [Parameter(Mandatory=$true)][string] $URI,
    [Parameter(Mandatory=$true)][string] $UserName,
    [Parameter(Mandatory=$true)][string] $Password
)
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    $Base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "$UserName","$Password")))
    $global:IPAMAuth = @{Authorization=("Basic {0}" -f $base64AuthInfo)}
    $global:IPAMURI = $URI
    $global:CIDRMapping = @{
    "31"="1"
    "30"="2"
    "29"="3"
    "28"="4"
    "27"="5"
    "26"="6"
    "25"="7"
    "24"="8"
    "23"="9"
    "22"="10"
    "21"="11"
    "20"="12"
    "19"="13"
    "18"="14"
    "17"="15"
    "16"="16"
    "15"="17"
    "14"="18"
    "13"="19"
    "12"="20"
    "11"="21"
    "10"="22"
    "9"="23"
    "8"="24"
    "7"="25"
    "6"="26"
    "5"="27"
    "4"="28"
    "3"="29"
    "2"="30"
    "1"="31"
    "0"="32"
    }
}

#Get-IPAMQueryMaster -SiteNameLike "similar name"
#Get-IPAMQueryMaster -SiteName "exact name"
function Get-IPAMQueryMaster{
Param (
    [Parameter()][string] $SiteName,
    [Parameter()][string] $SiteNameLike,
    [Switch]$RawData
)
    if($IPAMAuth)
    {
        if($SiteName)
        {
            $getMaster = Invoke-RestMethod -Headers $IPAMAuth -Method Get -Uri "$IPAMURI/rest/ip_site_list?WHERE=site_name='$SiteName'"
            if(!$RawData.IsPresent)
            {
                if($getMaster)
                {
                    $MyObject = New-Object -TypeName PSObject
                    $MyObject | Add-Member @{MasterSiteName=$($getMaster.site_name)}
                    $MyObject | Add-Member @{MasterSiteId=$($getMaster.site_id)}
                    $MyObject | Add-Member @{MasterSiteDescription=$($getMaster.site_description)}
                    $MyObject | Add-Member @{ParentSiteName=$($getMaster.parent_site_name)}
                    $MyObject | Add-Member @{ParentSitetId=$($getMaster.parent_site_id)}                 
                    return $MyObject
                }
                else
                {
                    Write-Host -ForegroundColor Yellow "Nothing found, please search with correct value."
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
                    Write-Host -ForegroundColor Yellow "Nothing found, please search with correct value."
                }
            }
        }
        if($SiteNameLike)
        {
            $getMaster = Invoke-RestMethod -Headers $IPAMAuth -Method Get -Uri "$IPAMURI/rest/ip_site_list?WHERE=site_name+like+'%$SiteNameLike%'"
            if(!$RawData.IsPresent)
            {
                if($getMaster)
                {
                    $MyObjects=@()
                    foreach($gM in $getMaster)
                    {
                        $MyObject = New-Object -TypeName PSObject
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
                    Write-Host -ForegroundColor Yellow "Nothing found, please search with correct value."
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
                    Write-Host -ForegroundColor Yellow "Nothing found, please search with correct value."
                }
            }
        }        
    }
    else
    {
        Write-Host -ForegroundColor Red "No authentication stored, please store it using Set-IPAMAuthURI command."
    }
}

#Get-IPAMSubnets -SubnetNameLike "similar name"
#Get-IPAMSubnets -SubneteName "exact name"
function Get-IPAMSubnets{
Param (
    [Parameter()][string] $SubnetId,
    [Parameter()][string] $SubnetName,
    [Parameter()][string] $SubnetNameLike,
    [Parameter()][string] $ParentSubnetId,
    [Parameter()][string] $StartAddress,
    [Switch]$Quite,
    [Switch]$RawData
)
    if($IPAMAuth)
    {
        if($SubnetName)
        {
            $getSubnets = Invoke-RestMethod -Headers $IPAMAuth -Method Get -Uri "$IPAMURI/rest/ip_block_subnet_list?WHERE=subnet_name='$SubnetName'"
            if(!$RawData.IsPresent)
            {
                if($getSubnets)
                {
                    $MyObjects=@()
                    foreach ($subnet in $getSubnets)
                    {
                        $MyObject = New-Object -TypeName PSObject
                        $MyObject | Add-Member @{SubnetName=$($subnet.subnet_name)}       
                        $MyObject | Add-Member @{SubnetId=$($subnet.subnet_id)}
                        $MyObject | Add-Member @{StartAddress=$($subnet.start_hostaddr)}
                        $MyObject | Add-Member @{EndAddress=$($subnet.end_hostaddr)}
                        $MyObject | Add-Member @{CIDR=$CIDRMapping["$([math]::log($($subnet.subnet_size),2))"]}
                        $MyObject | Add-Member @{SubnetUsedPercent=$($subnet.subnet_allocated_percent)}
                        $MyObject | Add-Member @{ParentSubnetId=$($subnet.parent_subnet_id)}
                        $MyObjects += $MyObject
                    }                    
                    return $MyObjects
                }
                else
                {
                    if(!$Quite.IsPresent)
                    {
                        Write-Host -ForegroundColor Yellow "Nothing found, please search with correct value."
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
                        Write-Host -ForegroundColor Yellow "Nothing found, please search with correct value."
                    }
                }
            }
        }
        if($StartAddress)
        {
            $getSubnets = Invoke-RestMethod -Headers $IPAMAuth -Method Get -Uri "$IPAMURI/rest/ip_block_subnet_list?WHERE=start_hostaddr='$StartAddress'"
            if(!$RawData.IsPresent)
            {
                if($getSubnets)
                {
                    $MyObjects=@()
                    foreach ($subnet in $getSubnets)
                    {
                        $MyObject = New-Object -TypeName PSObject
                        $MyObject | Add-Member @{SubnetName=$($subnet.subnet_name)}       
                        $MyObject | Add-Member @{SubnetId=$($subnet.subnet_id)}
                        $MyObject | Add-Member @{StartAddress=$($subnet.start_hostaddr)}
                        $MyObject | Add-Member @{EndAddress=$($subnet.end_hostaddr)}
                        $MyObject | Add-Member @{CIDR=$CIDRMapping["$([math]::log($($subnet.subnet_size),2))"]}
                        $MyObject | Add-Member @{SubnetUsedPercent=$($subnet.subnet_allocated_percent)}
                        $MyObject | Add-Member @{ParentSubnetId=$($subnet.parent_subnet_id)}
                        $MyObjects += $MyObject
                    }                    
                    return $MyObjects
                }
                else
                {
                    if(!$Quite.IsPresent)
                    {
                        Write-Host -ForegroundColor Yellow "Nothing found, please search with correct value."
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
                        Write-Host -ForegroundColor Yellow "Nothing found, please search with correct value."
                    }
                }
            }
        }
        if($SubnetNameLike)
        {
            $getSubnets = Invoke-RestMethod -Headers $IPAMAuth -Method Get -Uri "$IPAMURI/rest/ip_block_subnet_list?WHERE=subnet_name+like+'%$SubnetNameLike%'"
            if(!$RawData.IsPresent)
            {
                if($getSubnets)
                {
                    $MyObjects=@()
                    foreach ($subnet in $getSubnets)
                    {
                        $MyObject = New-Object -TypeName PSObject
                        $MyObject | Add-Member @{SubnetName=$($subnet.subnet_name)}       
                        $MyObject | Add-Member @{SubnetId=$($subnet.subnet_id)}
                        $MyObject | Add-Member @{StartAddress=$($subnet.start_hostaddr)}
                        $MyObject | Add-Member @{EndAddress=$($subnet.end_hostaddr)}
                        $MyObject | Add-Member @{CIDR=$CIDRMapping["$([math]::log($($subnet.subnet_size),2))"]}
                        $MyObject | Add-Member @{SubnetUsedPercent=$($subnet.subnet_allocated_percent)}
                        $MyObject | Add-Member @{ParentSubnetId=$($subnet.parent_subnet_id)}
                        $MyObjects += $MyObject
                    }                    
                    return $MyObjects
                }
                else
                {
                    if(!$Quite.IsPresent)
                    {
                        Write-Host -ForegroundColor Yellow "Nothing found, please search with correct value."
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
                        Write-Host -ForegroundColor Yellow "Nothing found, please search with correct value."
                    }
                }
            }
        }
        if($ParentSubnetId)
        {
            $getSubnets = Invoke-RestMethod -Headers $IPAMAuth -Method Get -Uri "$IPAMURI/rest/ip_block_subnet_list?WHERE=parent_subnet_id=$parentSubnetID"
            #$getSubnets
            if(!$RawData.IsPresent)
            {
                if($getSubnets)
                {
                    $MyObjects=@()
                    foreach ($subnet in $getSubnets)
                    {
                        $MyObject = New-Object -TypeName PSObject
                        $MyObject | Add-Member @{SubnetName=$($subnet.subnet_name)}       
                        $MyObject | Add-Member @{SubnetId=$($subnet.subnet_id)}
                        $MyObject | Add-Member @{StartAddress=$($subnet.start_hostaddr)}
                        $MyObject | Add-Member @{EndAddress=$($subnet.end_hostaddr)}
                        $MyObject | Add-Member @{CIDR=$CIDRMapping["$([math]::log($($subnet.subnet_size),2))"]}
                        $MyObject | Add-Member @{SubnetUsedPercent=$($subnet.subnet_allocated_percent)}
                        $MyObject | Add-Member @{ParentSubnetId=$($subnet.parent_subnet_id)}
                        $MyObjects += $MyObject                        
                    }                    
                    return $MyObjects
                }
                else
                {
                    if(!$Quite.IsPresent)
                    {
                        Write-Host -ForegroundColor Yellow "Nothing found, please search with correct value."
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
                        Write-Host -ForegroundColor Yellow "Nothing found, please search with correct value."
                    }
                }
            }
        }
        if($SubnetId)
        {
            $getSubnets = Invoke-RestMethod -Headers $IPAMAuth -Method Get -Uri "$IPAMURI/rest/ip_block_subnet_list?WHERE=subnet_id='$subnetID'"
            #$getSubnets
            if(!$RawData.IsPresent)
            {
                if($getSubnets)
                {                    
                    $MyObjects=@()
                    foreach ($subnet in $getSubnets)
                    {
                        $MyObject = New-Object -TypeName PSObject
                        $MyObject | Add-Member @{SubnetName=$($subnet.subnet_name)}       
                        $MyObject | Add-Member @{SubnetId=$($subnet.subnet_id)}
                        $MyObject | Add-Member @{StartAddress=$($subnet.start_hostaddr)}
                        $MyObject | Add-Member @{EndAddress=$($subnet.end_hostaddr)}
                        $MyObject | Add-Member @{CIDR=$CIDRMapping["$([math]::log($($subnet.subnet_size),2))"]}
                        $MyObject | Add-Member @{SubnetUsedPercent=$($subnet.subnet_allocated_percent)}
                        $MyObject | Add-Member @{ParentSubnetId=$($subnet.parent_subnet_id)}
                        $MyObjects += $MyObject
                    }                    
                    return $MyObjects
                }
                else
                {
                    if(!$Quite.IsPresent)
                    {
                        Write-Host -ForegroundColor Yellow "Nothing found, please search with correct value."
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
                        Write-Host -ForegroundColor Yellow "Nothing found, please search with correct value."
                    }
                }
            }
        }
    }
    else
    {
        Write-Host -ForegroundColor Red "No authentication stored, please store it using Set-IPAMAuthURI command."
    }
}

#Get-IPAMFreeIP -SubnetName "Subnet Name" -CIDR 22 -
function Get-IPAMFreeIP{
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
            $getFreeSubnet = Invoke-RestMethod -Headers $IPAMAuth -Method Get -Uri "$IPAMURI/rpc/ip_find_free_subnet?prefix=$CIDR&WHERE=subnet_name='$SubnetName'"
            if(!$RawData.IsPresent)
            {
                if($getFreeSubnet)
                {   
                    if(!$All.IsPresent)
                    {
                        #$($getFreeSubnet).start_ip_addr | % { (($_-Split '(..)' -ne '' |  % { [int]"0x$_" }) -join '.')} 
                        $MyObject = New-Object -TypeName PSObject
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
                            $MyObject = New-Object -TypeName PSObject
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
                        Write-Host -ForegroundColor Yellow "Nothing found, please search with correct value."
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
                    Write-Host -ForegroundColor Yellow "Missing information, you have to specify correct SubnetName and CIDR value."
                }
            }
        }
        if($SubnetId -and $CIDR)
        {
            $getFreeSubnet = Invoke-RestMethod -Headers $IPAMAuth -Method Get -Uri "$IPAMURI/rpc/ip_find_free_subnet?prefix=$CIDR&WHERE=block_id='$SubnetId'"
            if(!$RawData.IsPresent)
            {
                if($getFreeSubnet)
                {   
                    if(!$All.IsPresent)
                    {
                        #$($getFreeSubnet).start_ip_addr | % { (($_-Split '(..)' -ne '' |  % { [int]"0x$_" }) -join '.')} 
                        $MyObject = New-Object -TypeName PSObject
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
                            $MyObject = New-Object -TypeName PSObject
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
                        Write-Host -ForegroundColor Yellow "Nothing found, please search with correct value."
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
                    Write-Host -ForegroundColor Yellow "Missing information, you have to specify correct SubnetName and CIDR value."
                }
            }
        }     
    }
    else
    {
        Write-Host -ForegroundColor Red "No authentication stored, please store it using Set-IPAMAuthURI command."
    }
}

#New-IPAMSubnet -NewSubnetName "My Subnet Name" -NewSubnetRange X.X.X.X -ParentSubnetId 67951 -CIDR 22
function New-IPAMSubnet{
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
            $newSubnet = Invoke-RestMethod -Headers $IPAMAuth -Method Post -Uri "$IPAMURI/rpc/ip_subnet_add?subnet_addr=$NewSubnetRange&subnet_prefix=$CIDR&parent_subnet_id=$ParentSubnetId&subnet_name=$NewSubnetName"            
            if(!$RawData.IsPresent)
            {
                $($newSubnet.errno)
                if($($newSubnet.errno))
                {
                    Write-Host -ForegroundColor Yellow "$($newSubnet.errmsg), you have to specify correct value."
                    break;
                }
                if($newSubnet)
                {                
                    $MyObject = New-Object -TypeName PSObject
                    $MyObject | Add-Member @{NewSubnetName=$NewSubnetName}
                    $MyObject | Add-Member @{NewSubnetID=$newSubnet.ret_oid}
                    $MyObject | Add-Member @{NewSubnetCIDR=$CIDR}
                    #$MyObject | Add-Member @{ParentSubnetId=$ParentSubnetId} 
                    Write-Host -ForegroundColor Green "Subnet created successfully with SubnetId : $($newSubnet.ret_oid)"              
                    return $MyObject
                }                
                else
                {
                    Write-Host -ForegroundColor Yellow "Missing information, you have to specify correct value."
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
                    Write-Host -ForegroundColor Yellow "Missing information, you have to specify correct SubnetName, SubnetRange, Parent Subnet Id and CIDR value."
                }
            }
        }      
    }
    else
    {
        Write-Host -ForegroundColor Red "No authentication stored, please store it using Set-IPAMAuthURI command."
    }
}

#Remove-IPAMSubnet -SubnetId "Subnet Id"
function Remove-IPAMSubnet{
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
Param (
    [Parameter(Mandatory=$true)][string] $SubnetId,
    [Switch]$RawData
)
    if($IPAMAuth)
    {
        if($SubnetId)
        {
            $verifySubnet = Invoke-RestMethod -Headers $IPAMAuth -Method Get -Uri "$IPAMURI/rest/ip_block_subnet_list?WHERE=subnet_id='$SubnetId'"
            if($verifySubnet)
            {
                if($(Get-IPAMSubnets -ParentSubnetId $SubnetId -Quite))
                {
                    Write-Host -ForegroundColor Red "'$($verifySubnet.subnet_name)' is a master subnet, not allowed to delete from here."
                    break;
                }
                $SiteId = $($verifySubnet.site_id)
                if ($PSCmdlet.ShouldProcess("Subnet Name - '$($verifySubnet.subnet_name)' : Subnet Id - $SubnetId"))
                {
                    $removeSubnet = Invoke-RestMethod -Headers $IPAMAuth -Method Post -Uri "$IPAMURI/rpc/ip_subnet_delete?subnet_id=$SubnetId&site_id=$SiteId"                    
                    if(!$RawData.IsPresent)
                    {
                        if($removeSubnet)
                        {                
                            $MyObject = New-Object -TypeName PSObject
                            $MyObject | Add-Member @{SubnetName=$($verifySubnet.subnet_name)}
                            $MyObject | Add-Member @{SubnetId=$SubnetId}
                            $MyObject | Add-Member @{SiteId=$SiteId} 
                            Write-Host -ForegroundColor Green "Subnet deleted successfully."            
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
                            Write-Host -ForegroundColor Yellow "Missing information, you have to specify correct SubnetId."
                        }
                    }
                }
            }
            else
            {
                Write-Host -ForegroundColor Yellow "You have to specify correct SubnetId."
            }
        }      
    }
    else
    {
        Write-Host -ForegroundColor Red "No authentication stored, please store it using Set-IPAMAuthURI command."
    }
}
