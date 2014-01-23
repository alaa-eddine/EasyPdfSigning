param($config, $batchMode = "")

. (($MyInvocation.MyCommand.Definition | split-path -parent) + "\build_helpers.ps1")

Begin-BuildScript "EasyPdfSigning" ($batchMode -eq "batch")

# -----------------------------  SCRIPT CONFIGURATION  ----------------------------

# Set the path to the source files.
#
$sourcePath = $MyInvocation.MyCommand.Definition | split-path -parent | split-path -parent | split-path -parent

# Set the application version number. Disable for Git repository revision.
#
#$revId = "1.0"
#$revId = Get-AssemblyInfoVersion "EasyPdfSigning\Properties\AssemblyInfo.cs" "AssemblyInformationalVersion"
$revId = Get-GitRevision

# Disable FASTBUILD mode to always include a full version number in the assembly version info.
#
$env:FASTBUILD = ""

# ---------------------------------------------------------------------------------

Write-Host "Application version: $revId"

# -------------------------------  PERFORM ACTIONS  -------------------------------

# ---------- Debug builds ----------

if ($config -eq "all" -or $config.Contains("build-debug"))
{
	Build-Solution "EasyPdfSigning.sln" "Debug" "x86" 1

	if ($config -eq "all" -or $config.Contains("sign-app"))
	{
		Sign-File "EasyPdfSigning\bin\x86\Debug\EasyPdfSigning.exe" "signkey.pfx" "@signkey.password" 1
	}
}

# ---------- Release builds ----------

if ($config -eq "all" -or $config.Contains("build-release"))
{
	Build-Solution "EasyPdfSigning.sln" "Release" "x86" 1

	if ($config -eq "all" -or $config.Contains("sign-app"))
	{
		Sign-File "EasyPdfSigning\bin\x86\Release\EasyPdfSigning.exe" "signkey.pfx" "@signkey.password" 1
	}
}

# ---------- Release setups ----------

if ($config -eq "all" -or $config.Contains("setup-release"))
{
	Create-Setup "Setup\EasyPdfSigning.iss" Release 3

	if ($config -eq "all" -or $config.Contains("sign-setup"))
	{
		Sign-File "Setup\EasyPdfSigning-Setup-$revId.exe" "signkey.pfx" "@signkey.password" 1
	}
}

# ---------------------------------------------------------------------------------

End-BuildScript
