<#
    Filename: Get-CWComputerInfo.ps1
    Author: Cole Lavallee
    Date:   23 July 2020
    Version: 1.0
#>

function Get-CWComputerInfo {    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)][String]$AutomateServer,
        [Parameter(Mandatory = $True)][String]$ClientName
    )
    #Requires -Modules AutomateAPI, PSSharedGoods
    try {
        Import-Module AutomateAPI, PSSharedGoods
    }
    catch {
        Write-Warning "Required modules not installed, installing..."
        Install-Module AutomateAPI, PSSharedGoods
    }
    # try {

    # }
    # try {
    #     Connect-AutomateAPI -Server $AutomateServer
    # }
    # catch {
    #     Write-Error "Failed to connect to automate server, check credentials..."
    # }

    $Computers = Get-AutomateComputer -ClientName $ClientName | Where-Object { $_.Type -eq "Workstation" }
    
    $CompObjs = @()

    $Computers | foreach {
        $CompObj = [PSCustomObject][ordered]@{
            Name              = $_.ComputerName
            User              = ($_.LastUserName).TrimStart("WORKGROUP\")
            OperatingSystem   = $_.OperatingSystemName
            Edition           = $null
            WindowsUpdateDate = $_.WindowsUpdateDate
            EndOfLife         = $null
        }
        if ($_.OperatingSystemName -notlike "Microsoft*") {
            $CompObj.Edition = $_.OperatingSystemName
            $CompObj.WindowsUpdateDate = "Not Applicable"
            $CompObj.Edition = $null
        }
        else {
            $OSName = ($_.OperatingSystemName).TrimStart("Microsoft ")
            $v = [version]$_.OperatingSystemVersion
            $OSVersion = "$($v.major).$($v.Minor)" + " ($($v.Build))"
            $CompObj.Edition = (ConvertTo-OperatingSystem -OperatingSystem $OSName -OperatingSystemVersion $OSVersion).Split(" ")[2]

            if ($OperatingSystem -notlike "*Enterprise*" -and $CompObj.Edition -lt "1809") {
            
                $CompObj.EndOfLife = $True
    
            }
            elseif ($OperatingSystem -like "*Enterprise*" -and $CompObj.Edition -lt "1703") {
                $CompObj.EndOfLife = $True
            }
            else {
                $CompObj.EndOfLife = $False
            }
        }

        

        $CompObjs += $CompObj
    }


    return $CompObjs

}