function Get-DomainComputer {
    <#
    .EXAMPLE
        Get-DomainComputer

    .EXAMPLE
        Get-DomainComputer -ComputerName "Workstation001"

    .EXAMPLE
        Get-DomainComputer -ComputerName "Workstation001", "Workstation002"

    .EXAMPLE
        Get-Content -Path "c:\WorkstationsList.txt" | Get-DomainComputer

    .EXAMPLE
        Get-DomainComputer -ComputerName "Workstation0*" -SizeLimit 10 -Verbose

    .EXAMPLE
        Get-DomainComputer -ComputerName "Workstation0*" -SizeLimit 10 -DomainDN "DC=FX,DC=LAB" -Credential (Get-Credential)

    .NOTES
        Author: Ethan Blair
    #>

    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName, ValueFromPipeline)]
        [Alias("Computer")]
        [string[]]$ComputerName,

        [Alias("ResultLimit", "Limit")]
        [int]$SizeLimit = 100,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias("Domain")]
        [string]$DomainDN = ([adsisearcher]"").SearchRoot.Path,

        [Alias("RunAs")]
        [System.Management.Automation.PSCredential]$Credential = [System.Management.Automation.PSCredential]::Empty
    )

    process {
        if ($ComputerName) {
            foreach ($computer in $ComputerName) {
                try {
                    $searcher = New-Object System.DirectoryServices.DirectorySearcher -ErrorAction Stop
                    $searcher.Filter = "(&(objectCategory=Computer)(name=$computer))"
                    $searcher.SizeLimit = $SizeLimit
                    $searcher.SearchRoot = $DomainDN

                    if ($PSBoundParameters.ContainsKey('DomainDN')) {
                        if ($DomainDN -notlike "LDAP://*") {
                            $DomainDN = "LDAP://$DomainDN"
                        }
                        $searcher.SearchRoot = $DomainDN
                    }

                    if ($PSBoundParameters.ContainsKey('Credential')) {
                        $domain = New-Object System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDN, $Credential.UserName, $Credential.GetNetworkCredential().Password -ErrorAction Stop
                        $searcher.SearchRoot = $domain
                    }

                    foreach ($result in $searcher.FindAll()) {
                        [PSCustomObject]@{
                            Name               = $result.Properties.name[0]
                            DNSHostName        = $result.Properties.dnshostname[0]
                            Description        = $result.Properties.description[0]
                            OperatingSystem    = $result.Properties.operatingsystem[0]
                            WhenCreated        = $result.Properties.whencreated[0]
                            DistinguishedName  = $result.Properties.distinguishedname[0]
                        }
                    }
                }
                catch {
                    Write-Warning "$computer`: $($_.Exception.Message)"
                }
            }
        }
        else {
            try {
                $searcher = New-Object System.DirectoryServices.DirectorySearcher -ErrorAction Stop
                $searcher.Filter = "(objectCategory=Computer)"
                $searcher.SizeLimit = $SizeLimit

                if ($PSBoundParameters.ContainsKey('DomainDN')) {
                    if ($DomainDN -notlike "LDAP://*") {
                        $DomainDN = "LDAP://$DomainDN"
                    }
                    $searcher.SearchRoot = $DomainDN
                }

                if ($PSBoundParameters.ContainsKey('Credential')) {
                    $domain = New-Object System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDN, $Credential.UserName, $Credential.GetNetworkCredential().Password -ErrorAction Stop
                    $searcher.SearchRoot = $domain
                }

                foreach ($result in $searcher.FindAll()) {
                    try {
                        [PSCustomObject]@{
                            Name               = $result.Properties.name[0]
                            DNSHostName        = $result.Properties.dnshostname[0]
                            Description        = $result.Properties.description[0]
                            OperatingSystem    = $result.Properties.operatingsystem[0]
                            WhenCreated        = $result.Properties.whencreated[0]
                            DistinguishedName  = $result.Properties.distinguishedname[0]
                        }
                    }
                    catch {
                        Write-Warning "Error processing computer $($result.Properties.name): $($_.Exception.Message)"
                    }
                }
            }
            catch {
                Write-Warning "Error during search operation: $($_.Exception.Message)"
            }
        }
    }

    end {
    }
}
