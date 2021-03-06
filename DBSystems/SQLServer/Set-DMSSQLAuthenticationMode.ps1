#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    Configures the authentication mode of the target instance of SQL Server

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Module SQLServer
    Requires the library script DMSSqlServer.ps1
    
.LINK
    https://github.com/scriptrunner/ActionPacks/blob/master/DBSystems/SQLServer
 
.Parameter ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.Parameter ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.

.Parameter Mode
    Specifies the authentication mode that will be configured on the target instance of SQL Server

.Parameter AutomaticallyAcceptUntrustedCertificates
    Indicates that this cmdlet automatically accepts untrusted certificates

.Parameter ForceServiceRestart
    Indicates that this cmdlet forces the SQL Server service to restart, if necessary, without prompting the user
    
.Parameter ManagementPublicPort
    Specifies the public management port on the target computer

.Parameter NoServiceRestart
    Indicates that this cmdlet prevents a restart of the SQL Server service without prompting the user

.Parameter RetryTimeout
    Specifies the time period to retry the command on the target sever

.Parameter ConnectionTimeout
    Specifies the time period to retry the command on the target server
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [Parameter(Mandatory = $true)]   
    [pscredential]$ServerCredential,
    [ValidateSet('Normal', 'Integrated', 'Mixed')]
    [string]$Mode = 'Normal',
    [switch]$AutomaticallyAcceptUntrustedCertificates,
    [switch]$ForceServiceRestart,
    [int]$ManagementPublicPort,
    [switch]$NoServiceRestart,
    [int]$RetryTimeout,
    [int]$ConnectionTimeout = 30
)

Import-Module SQLServer

try{
    $instance = GetSQLServerInstance -ServerInstance $ServerInstance -ServerCredential $ServerCredential -ConnectionTimeout $ConnectionTimeout

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'InputObject' = $instance
                            'Credential' = $ServerCredential
                            'Mode' = $Mode
                            'Confirm' = $false
                            'NoServiceRestart' = $NoServiceRestart.ToBool()
                            'ForceServiceRestart' = $ForceServiceRestart
                            'AutomaticallyAcceptUntrustedCertificates' = $AutomaticallyAcceptUntrustedCertificates.ToBool()
                            }
    if($ManagementPublicPort -gt 0){
        $cmdArgs.Add("ManagementPublicPort",$ManagementPublicPort)
    }
    if($RetryTimeout -gt 0){
        $cmdArgs.Add("RetryTimeout",$RetryTimeout)
    }
    
    $result = Set-SqlAuthenticationMode @cmdArgs
    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $result
    }
    else{
        Write-Output $result
    }
}
catch{
    throw
}
finally{
}