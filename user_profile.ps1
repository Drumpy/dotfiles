$PROFILE="C:\Users\ddosa\.config\powershell\user_profile.ps1"

# Prompt
Import-Module posh-git
Import-Module oh-my-posh
Set-PoshPrompt star-mod

# Terminal Icons
Import-Module -Name Terminal-Icons

# PSReadLine
Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView

# Alias
Set-Alias l ls
Set-Alias c clear

function rmrf {
    <#
      .DESCRIPTION
      Deletes the specified file or directory.
      .PARAMETER target
      Target file or directory to be deleted.
      .NOTES
      This is an equivalent command of "rm -rf" in Unix-like systems.
    #>
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Target
    )
    Remove-Item -Recurse -Force $Target
}

function wget {
    <#
      .DESCRIPTION
      Download an asset from url.
      .PARAMETER url
      Target url to download the asset.
      .PARAMETER output
      The path to save the asset.
      Include the name and extension.
    #>
    [Alias('get')]
    Param(
        [string]$url,
        [string]$output
    )
    Invoke-WebRequest -Uri $url -OutFile $output
}

function Edit-HostsFile {
  <#
    .SYNOPSIS
    Opens the Windows hosts file in an editor.
  #>
  [Alias('hosts')]
  [CmdletBinding()]
  Param()
  # TO CONSIDER: Should we take a
  # Make sure we're on Windows...
  if ($PSVersionTable.PSVersion.Major -lt 6 -or $IsWindows) {
    # Default editor to notepad.exe
    $fileEditor = 'notepad'
    # Find code if it exists. Giving preference to Stable code over insiders.
    if (Get-Command code -ErrorAction SilentlyContinue) {
      $fileEditor = 'code'
    }
    elseif (Get-Command code-insiders -ErrorAction SilentlyContinue) {
      $fileEditor = 'code-insiders'
    }
    # Use Start-Process to ensure that we're elevated. If already elevated, will not reprompt.
    Start-Process -FilePath $fileEditor -ArgumentList "C:\Windows\System32\drivers\etc\hosts" -Verb RunAs
  }
}

Function repo {
  param ([string]$repoName)
  git init;
  gh repo create $repoName --public --source=. --remote=origin;
  git branch -M main;
  New-Item -Name README.md -ItemType File;
  git add README.md;
  git commit -m "initial commit";
  git push origin main;
  Write-Host "Repository $repoName created successfully! $([char]0xd83c)$([char]0xdf89)" -ForegroundColor green
}

# Run SpeedTest
function speedtest {
  $SpeedTestEXEPath = "C:\temp\speedtest.exe"
  $stest = & $SpeedTestEXEPath --accept-license
  $stest
}

# Public IP
function ipp { "🌐 Public IP: " + (Invoke-WebRequest ifconfig.me/ip).Content.Trim() }

# Git Functions
function gll() { git pull }
function glog() {	git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %b %Cgreen(%cd) %C(bold blue)<%an>%Creset" --abbrev-commit }
function gcmsg() {
  param ([string]$message)
  git commit -m "$message"
}

# TODO: Fix this
function gp() { git push }
function gamend() { git commit --verbose --amend --reuse-message=HEAD }
function ga() { git add }
function gco() { git checkout }
function glast() { git log -1 HEAD --stat }