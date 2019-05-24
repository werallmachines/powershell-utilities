################################################################
# Connect to Windows servers in given list using PS remoting.  #
# Stop set of same named websites and app pools.             #
# Authour: Web Admin Team (Matt Sanderson)                     #
# Version: 1.0                                                 #
################################################################

Import-Module WebAdministration

[System.Collections.ArrayList]$server_list = get-content windows_servers_test.txt
$site_name = "Default Web Site"
$pool_name = "DefaultAppPool"
$from = "matt.sanderson@encana.com"
$to = @("matt.sanderson@encana.com", "adam.stewart@encana.com", "logan.noonan@encana.com")
$subject = "IIS Default Site Shut Down Results"
$body = "Please see attachment."
$attachment = ".\iis_18_6.log"
$smtp = "mailhost"

# Results in non-terminating errors if host doesn't respond, 
# but to make it in-step with Linux script, check and remove

function define_hosts {
    foreach ($server in $server_list) {
        try {
            Resolve-Dnsname -name $server -ErrorAction "Stop"
        }
        catch {
            $server_list.Remove($server)
        }
    }
}

function stop_sites {
    foreach ($server in $server_list) {
        $success = "[+] $($server) ===> SUCCESS"
        $failure = "[-] $($server) ===> FAILURE"

        $cmds = {(Set-ExecutionPolicy Unrestricted -force), `
                 (Import-Module WebAdministration), `
                 (Stop-Website -name $args[0]), `
                 (Stop-WebAppPool -name $args[1]), `
                 (Set-ExecutionPolicy Restricted -force)}
        $session = New-PSSession -ComputerName $server

            Invoke-Command -Session $session -ScriptBlock $cmds -ArgumentList $site_name, $pool_name

        try {
            Invoke-WebRequest -Uri $server -ErrorAction "Stop"
            $failure >> iis_18_6.log
        }
        catch [System.Net.WebException] {
            $success >> iis_18_6.log
        }
    }
}
function send_email {
    Send-MailMessage -From $from -To $to -Subject $subject -Body $body -Attachment $attachment -SMTP $smtp
}

define_hosts
stop_sites
send_email