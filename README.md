# Get-DomainComputer

PowerShell function for querying Active Directory computer information using ADSI.

## Features

- Query computers by name (supports wildcards)
- Pipeline input support
- Alternate credentials and cross-domain queries
- No AD module required

## Usage

```powershell
# Get all computers
Get-DomainComputer

# Get specific computer
Get-DomainComputer -ComputerName "SERVER01"

# Wildcard search with limit
Get-DomainComputer -ComputerName "WEB*" -SizeLimit 10

# Cross-domain with credentials
Get-DomainComputer -DomainDN "CONTOSO.COM" -Credential (Get-Credential)

# Pipeline from file
Get-Content "computers.txt" | Get-DomainComputer
```

## Output

Returns objects with: Name, DNSHostName, Description, OperatingSystem, WhenCreated, DistinguishedName

## Requirements

- PowerShell 3.0+
- Domain network access
- AD read permissions

## Author

Ethan Blair
