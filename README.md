# EfficientIP Management for PowerShell

A PowerShell module to interact with EfficientIP SOLIDserver IPAM via its REST API. This script provides functions to manage subnets and IP addresses programmatically.

Author: Saugata Datta  
License: GPL-3.0

---

## 🔧 Setup

### Function: `Set-IPAMAuthURI`
Set the EfficientIP IPAM API URI and credentials.

```powershell
Set-IPAMAuthURI -URI "https://solidserver.company.com" -UserName "admin" -Password "securepassword"
```

**Parameters:**
- `URI` (string) [Mandatory]: Base URI of the EfficientIP SOLIDserver API.
- `UserName` (string) [Mandatory]: Username for API authentication.
- `Password` (string) [Mandatory]: Password for API authentication.

---

## 🌍 Master Subnet Query

### Function: `Get-IPAMQueryMaster`
Query master subnet using site information.

```powershell
Get-IPAMQueryMaster -SiteNameLike "Europe"
Get-IPAMQueryMaster -SiteName "Europe_Location01"
Get-IPAMQueryMaster -SiteId 42
```

**Parameters:**
- `SiteNameLike` (string): Partial match of site name.
- `SiteName` (string): Exact name of the site.
- `SiteId` (int): Site ID.

---

## 📍 Subnet Information

### Function: `Get-IPAMSubnets`
Retrieve subnet details by different filters.

```powershell
Get-IPAMSubnets -SubnetNameLike "DB"
Get-IPAMSubnets -SubnetName "DB-Prod-Subnet"
Get-IPAMSubnets -SubnetId 1001
Get-IPAMSubnets -ParentSubnetId 200
Get-IPAMSubnets -StartAddress "192.168.10.0"
```

**Parameters:**
- `SubnetNameLike` (string): Partial match of subnet name.
- `SubnetName` (string): Exact name of the subnet.
- `SubnetId` (int): ID of the subnet.
- `ParentSubnetId` (int): ID of the parent subnet.
- `StartAddress` (string): Starting IP address of the subnet.
- `EndAddress` (string): Ending IP address range filter.
- `StartAddressLike` (string): Starting IP address of the subnet like.

---

## 📦 Free Subnet Discovery

### Function: `Get-IPAMFreeSubnetIP`
Get the next available subnet within a parent subnet.

```powershell
Get-IPAMFreeSubnetIP -SubnetName "ParentSubnet01" -CIDR 24
```

**Parameters:**
- `SubnetName` (string) [Mandatory]: Name of the parent subnet.
- `CIDR` (int) [Mandatory]: CIDR block (e.g., 24 for /24).

---

## ➕ Create Subnet

### Function: `New-IPAMSubnet`
Create a new subnet in the IPAM system.

```powershell
New-IPAMSubnet -NewSubnetName "Web-Servers" -NewSubnetRange "10.1.10.0" -ParentSubnetId 101 -CIDR 24
```

**Parameters:**
- `NewSubnetName` (string) [Mandatory]: Name of the new subnet.
- `NewSubnetRange` (string) [Mandatory]: Starting IP address of the new subnet.
- `ParentSubnetId` (int) [Mandatory]: ID of the parent subnet.
- `CIDR` (int) [Mandatory]: CIDR size of the new subnet.

---

## ❌ Remove Subnet

### Function: `Remove-IPAMSubnet`
Delete a subnet using its ID.

```powershell
Remove-IPAMSubnet -SubnetId 1001
```

**Parameters:**
- `SubnetId` (int) [Mandatory]: ID of the subnet to delete.

---

## 💻 List Hosts in Subnet

### Function: `Get-IPAMHosts`
Retrieve all hosts in a specific subnet.

```powershell
Get-IPAMHosts -SubnetId 1001
```

**Parameters:**
- `SubnetId` (int) [Mandatory]: ID of the subnet.

---

## 🔍 Get Free IP Address

### Function: `Get-IPAMFreeHost`
Retrieve an available IP address within a subnet.

```powershell
Get-IPAMFreeHost -SubnetId 1001 -MaxFind 5
```

**Parameters:**
- `SubnetId` (int) [Mandatory]: ID of the subnet.
- `MaxFind` (int): Maximum number of available IPs to retrieve.

---

## 🆕 Add Host Entry

### Function: `New-IPAMHost`
Create a new host reservation for a specific IP address.

```powershell
New-IPAMHost -IPAddress "10.1.10.5" -Name "web01" -SiteID 42
```

**Parameters:**
- `IPAddress` (string) [Mandatory]: IP address to assign.
- `Name` (string) [Mandatory]: Hostname.
- `SiteID` (int): Site ID where the host resides.

---

## ℹ️ Host Details

### Function: `Get-IPAMHostInfo`
Retrieve information about a host using its ID.

```powershell
Get-IPAMHostInfo -HostID 3005
```

**Parameters:**
- `HostID` (int) [Mandatory]: Host ID.

### Function: `Get-IPAMHostIP`
Get host entry using IP address.

```powershell
Get-IPAMHostIP -IPAddress "10.1.10.5"
```

**Parameters:**
- `IPAddress` (string) [Mandatory]: IP address to query.

---

## 🗑️ Remove IP Address Entry

### Function: `Remove-IPAMHostIP`
Delete a host/IP entry from the IPAM.

```powershell
Remove-IPAMHostIP -IPAddress "10.1.10.5"
```

**Parameters:**
- `IPAddress` (string) [Mandatory]: IP address to remove.

---

## 📄 License

This project is licensed under the [GPL-3.0 License](LICENSE).

## 🤝 Contributions

Fork the repository, make enhancements, and submit pull requests. Contributions are welcome!

---
