Import-Module posh-git
Import-Module -Name Terminal-Icons

# Theme
oh-my-posh init pwsh --config $env:POSH_THEMES_PATH\drumpy.omp.json | Invoke-Expression
$env:POSH_GIT_ENABLED = $true

# PSReadLine
Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -Colors @{ InlinePrediction = '#626c80'}

Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

# PSFzf
Import-Module PSFzf
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'

# Alias
Set-Alias -Name d -Value dir
Set-Alias -Name c -Value clear

Function fz {
  fzf --preview 'bat --theme=OneHalfDark --color=always --style=numbers {}'
}

Function commands {
  Get-Content -Path $profile | Select-String -Pattern "^function.+" | ForEach-Object {
    # Find function names that contains letters, numbers and dashes
    [Regex]::Matches($_, "^function ([a-z0-9.-]+)","IgnoreCase").Groups[1].Value
  } | Where-Object { $_ -ine "prompt" } | Sort-Object
}

# Creates a new empty repository on Github
Function repo {
  param ([string]$repoName)
  New-Item -Path ".\" -Name $repoName -ItemType Directory | Out-Null;
  cd $repoName;
  git init;
  Write-Host "`r";
  gh repo create $repoName --public --source=. --remote=origin;
  Write-Host "`r";
  git branch -M main;
  New-Item -Name README.md -ItemType File | Out-Null;
  Set-Content -Path .\README.md -Value "# $($repoName)";
  git add README.md;
  git commit -m "initial commit";
  Write-Host "`r";
  git push origin main;
  Write-Host "`nRepository '$repoName' created successfully! $([char]0xd83c)$([char]0xdf89)`n" -ForegroundColor green
}

Function template {
	Param(
		[Parameter(Mandatory=$true)]
		[string]$repoName
	)
	Write-Host "`r";
	npx degit Drumpy/gh-demo $repoName;
	cd $repoName;
	git init --quiet;
	Write-Host "`r";
	gh repo create $repoName --public --source=. --remote=origin;
  git branch -M main;
  git add .;
  git commit --quiet -m "feat: initial commit";
  Write-Host "`r";
  vercel --confirm;
  vercel git connect 2>&1 | Out-Null;
  git push origin main --quiet;
  Write-Host "`nYour '$repoName' repository was created and deployed in Vercel! $([char]0xd83c)$([char]0xdf89)`n" -ForegroundColor green;
}

Function rmrf {
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

Function wget {
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

Function Edit-HostsFile {
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

# Run SpeedTest
Function speedtest {
  $SpeedTestEXEPath = "C:\temp\speedtest.exe"
  $stest = & $SpeedTestEXEPath --accept-license
  $stest
}

# Public IP
Function ipp {
  Write-Host "`r";
  "$([char]0xd83c)$([char]0xdf10) Public IP: " + (Invoke-WebRequest ifconfig.me/ip).Content.Trim();
  Write-Host "`r";
}

# Git Functions
Function ggpull() { git pull }
Function ggpush() { git push }
Function glog() {	git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %b %Cgreen(%cd) %C(bold blue)<%an>%Creset" --abbrev-commit }
Function gcmsg() {
  param ([string]$message)
  git commit -m "$message"
}
Function gaa() { git add . }
Function gst() { git status }
Function ggamend() { git commit --verbose --amend --reuse-message=HEAD }

# TODO: Fix this
# Function gco() { git checkout }
# Function glast() { git log -1 HEAD --stat }