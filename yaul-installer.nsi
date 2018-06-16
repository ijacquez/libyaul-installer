; Copyright (c) 2018
; See LICENSE for details.
;
; Dave Murphy <davem@devkitpro.org>
; Israel Jacquez <mrkotfw@gmail.com>

; MSYS2 latest can be obtained: http://repo.msys2.org/distrib/

; Google Drive direct download link:
; https://drive.google.com/uc?export=download&confirm=no_antivirus&id=

RequestExecutionLevel admin ; Require admin rights on NT6+ (When UAC is turned on)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Plugins required
;
; untgz          - http://nsis.sourceforge.net/UnTGZ_plug-in
; inetc          - http://nsis.sourceforge.net/Inetc_plug-in
;                  http://forums.winamp.com/showthread.php?s=&threadid=198596&perpage=40&highlight=&pagenumber=4
;                  http://forums.winamp.com/attachment.php?s=&postid=1831346
; ReplaceInFile  - http://nsis.sourceforge.net/ReplaceInFile
; NSIS 7zip      - http://nsis.sourceforge.net/Nsis7z_plug-in
; NTProfiles.nsh - http://nsis.sourceforge.net/NT_Profile_Paths
; AccessControl  - http://nsis.sourceforge.net/AccessControl_plug-in

; NSIS large strings build from http://nsis.sourceforge.net/Special_Builds

; HM NIS Edit Wizard helper defines
!define PRODUCT_NAME "Yaul"
!define PRODUCT_VERSION "0.1"
!define PRODUCT_PUBLISHER "Israel Jacquez"
!define PRODUCT_WEB_SITE "http://yaul.org"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"
!define PRODUCT_STARTMENU_REGVAL "NSIS:StartMenuDir"
!define BUILD "56"

SetCompressor /SOLID lzma

; MUI 1.67 compatible
!include "MUI2.nsh"
!include "Sections.nsh"
!include "StrFunc.nsh"
!include "InstallOptions.nsh"
!include "ReplaceInFile.nsh"
!include "NTProfiles.nsh"
!include "LogicLib.nsh"
!include "x64.nsh"

${StrRep}
${UnStrRep}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; StrContains:
;   This function does a case sensitive searches for an occurrence of a substring in a string.
;   It returns the substring if it is found.
;   Otherwise it returns null("").
;
;   Written by kenglish_hi
;   Adapted from StrReplace written by dandaman32

var STR_HAYSTACK
var STR_NEEDLE
var STR_CONTAINS_VAR_1
var STR_CONTAINS_VAR_2
var STR_CONTAINS_VAR_3
var STR_CONTAINS_VAR_4
var STR_RETURN_VAR

Function StrContains
  Exch $STR_NEEDLE
  Exch 1
  Exch $STR_HAYSTACK
    ; Uncomment to debug
    ; MessageBox MB_OK 'STR_NEEDLE = $STR_NEEDLE STR_HAYSTACK = $STR_HAYSTACK '
    StrCpy $STR_RETURN_VAR ""
    StrCpy $STR_CONTAINS_VAR_1 -1
    StrLen $STR_CONTAINS_VAR_2 $STR_NEEDLE
    StrLen $STR_CONTAINS_VAR_4 $STR_HAYSTACK
    Loop:
      IntOp $STR_CONTAINS_VAR_1 $STR_CONTAINS_VAR_1 + 1
      StrCpy $STR_CONTAINS_VAR_3 $STR_HAYSTACK $STR_CONTAINS_VAR_2 $STR_CONTAINS_VAR_1
      StrCmp $STR_CONTAINS_VAR_3 $STR_NEEDLE found
      StrCmp $STR_CONTAINS_VAR_1 $STR_CONTAINS_VAR_4 Done
      Goto Loop
    found:
      StrCpy $STR_RETURN_VAR $STR_NEEDLE
      Goto Done
    Done:
   Pop $STR_NEEDLE ; Prevent "invalid opcode" errors and keep the
   Exch $STR_RETURN_VAR
FunctionEnd

!macro _StrContainsConstructor OUT NEEDLE HAYSTACK
  Push "${HAYSTACK}"
  Push "${NEEDLE}"
  Call StrContains
  Pop "${OUT}"
!macroend

!define StrContains '!insertmacro "_StrContainsConstructor"'

; MUI Settings
!define MUI_HEADERIMAGE
; Requires a 150x57x24 BMP file
; !define MUI_HEADERIMAGE_BITMAP "logo.bmp" ; Optional
!define MUI_ABORTWARNING "Are you sure you want to quit ${PRODUCT_NAME} installer ${PRODUCT_VERSION}?"
!define MUI_COMPONENTSPAGE_SMALLDESC

; Welcome page
!define MUI_WELCOMEPAGE_TITLE "Welcome to ${PRODUCT_NAME} installer$\r$\nVersion ${PRODUCT_VERSION}"
!define MUI_WELCOMEPAGE_TEXT "${PRODUCT_NAME} installer automates the process of downloading, installing, and uninstalling ${PRODUCT_NAME}.$\r$\n$\nClick Next to continue."
!insertmacro MUI_PAGE_WELCOME

Page custom ChooseMirrorPage

; Directory page
!define MUI_PAGE_HEADER_SUBTEXT "Choose the folder in which to install ${PRODUCT_NAME}."
!define MUI_DIRECTORYPAGE_TEXT_TOP "${PRODUCT_NAME} will install in the following directory. To install in a different folder click Browse and select another folder. Click Next to continue."
!define MUI_PAGE_CUSTOMFUNCTION_PRE AbortPage
!insertmacro MUI_PAGE_DIRECTORY

; Start menu page
var ICONS_GROUP

!define MUI_STARTMENUPAGE_NODISABLE
!define MUI_STARTMENUPAGE_DEFAULTFOLDER "Yaul"
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "${PRODUCT_UNINST_ROOT_KEY}"
!define MUI_STARTMENUPAGE_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "${PRODUCT_STARTMENU_REGVAL}"
!define MUI_PAGE_CUSTOMFUNCTION_PRE AbortPage
!insertmacro MUI_PAGE_STARTMENU Application $ICONS_GROUP

; Instfiles page
!define MUI_PAGE_HEADER_SUBTEXT "Please wait while necessary ${PRODUCT_NAME} installer files downloads."
!define MUI_INSTFILESPAGE_ABORTHEADER_TEXT "Installation Aborted"
!define MUI_INSTFILESPAGE_ABORTHEADER_SUBTEXT "The installation was not completed successfully."
!insertmacro MUI_PAGE_INSTFILES

; Finish page
!define MUI_FINISHPAGE_TITLE "${PRODUCT_NAME} installer ${PRODUCT_VERSION}"
!define MUI_FINISHPAGE_TEXT "${PRODUCT_NAME} has finished installing."
!define MUI_FINISHPAGE_TEXT_LARGE "Installation complete."
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Language files
!insertmacro MUI_LANGUAGE "English"

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
Caption "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "yaul-installer-${PRODUCT_VERSION}.exe"
InstallDir "C:\yaul"
ShowInstDetails hide
ShowUnInstDetails show

var Install
var Updating
var MSYS2_FILE
var MSYS2_URL
var MSYS2_VERSION

var TOOLCHAIN_FILE
var TOOLCHAIN_URL
var TOOLCHAIN_VERSION

var INSTALL_SCRIPT_FILE
var INSTALL_SCRIPT_URL
var INSTALL_SCRIPT_VERSION

var BASEDIR
var Updates

Section "Minimal System" SectionMSYS2
SectionEnd

Section "Tool Chain" SectionToolchain
SectionEnd

Section "Install Script" SectionInstall_Script
SectionEnd

Section -installComponents

  SetAutoClose false

  StrCpy $R0 $INSTDIR 1
  StrLen $0 $INSTDIR
  IntOp $0 $0 - 2

  StrCpy $R1 $INSTDIR $0 2
  ${StrRep} $R1 $R1 "\" "/"
  StrCpy $BASEDIR /$R0$R1

  push ${SectionMSYS2}
  push $MSYS2_FILE
  push $MSYS2_URL
  Call DownloadIfNeeded

  push ${SectionToolchain}
  push $TOOLCHAIN_FILE
  push $TOOLCHAIN_URL
  Call DownloadIfNeeded

  push ${SectionInstall_Script}
  push $INSTALL_SCRIPT_FILE
  push $INSTALL_SCRIPT_URL
  Call DownloadIfNeeded

  SetDetailsView show

  CreateDirectory $INSTDIR

  SetOutPath $INSTDIR
  SetDetailsPrint both

  Nsis7z::ExtractWithDetails "$EXEDIR\$MSYS2_FILE" "Installing package %s..."
  WriteINIStr $INSTDIR\installed.ini MSYS2 Version $MSYS2_VERSION
  push $MSYS2_FILE
  call RemoveFile

  Nsis7z::ExtractWithDetails "$EXEDIR\$TOOLCHAIN_FILE" "Installing package %s..."
  WriteINIStr $INSTDIR\installed.ini MSYS2 Version $TOOLCHAIN_VERSION
  push $TOOLCHAIN_FILE
  call RemoveFile

  Nsis7z::ExtractWithDetails "$EXEDIR\$INSTALL_SCRIPT_FILE" "Installing package %s..."
  WriteINIStr $INSTDIR\installed.ini MSYS2 Version $INSTALL_SCRIPT_VERSION
  CopyFiles "$INSTDIR\install.sh" "$INSTDIR\msys2\tmp\install.sh"
  push $TOOLCHAIN_FILE
  call RemoveFile
  Delete "$INSTDIR\install.sh"

  !insertmacro _ReplaceInFile "$INSTDIR\msys2\etc\fstab" "#{DEVKITPRO}" "$INSTDIR"

  ${ProfilesPath} $0
  !insertmacro _ReplaceInFile "$INSTDIR\msys2\etc\fstab" "#{PROFILES_ROOT}" "$0"

  AccessControl::GrantOnFile "$INSTDIR\msys2\etc\fstab" "(BU)" "GenericRead"
  pop $0

  Delete "$INSTDIR\msys2\etc\fstab.old"

  ExecWait '"$INSTDIR\msys2\mingw64.exe" --login -c exit'

  ; Reset msys path to start of path
  ReadRegStr $1 HKLM "System\CurrentControlSet\Control\Session Manager\Environment" "PATH"
  ; Remove it to avoid multiple paths with separate installs
  ${StrRep} $2 $1 "$INSTDIR\msys\bin;" ""
  ${StrRep} $2 $2 "$INSTDIR\msys2\usr\bin;" ""
  StrCmp $2 "" 0 WritePath

  MessageBox mb_IconStop|mb_TopMost|mb_SetForeground "Trying to set path to blank string!$\nPlease add $INSTDIR\msys2\usr\bin; to the start of your path"
  goto AbortPath

WritePath:
  StrCpy $2 "$INSTDIR\msys2\usr\bin;$2"
  WriteRegExpandStr HKLM "System\CurrentControlSet\Control\Session Manager\Environment" "PATH" $2
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000
AbortPath:

  ExecWait '"$INSTDIR\msys2\usr\bin\pacman.exe" -Syu --noconfirm'

  ExecWait '"$INSTDIR\msys2\usr\bin\bash.exe" -c /tmp/install.sh'

  Strcpy $R1 "yaul-installer-${PRODUCT_VERSION}.exe"

  StrCmp $EXEDIR $INSTDIR SkipCopy

  CopyFiles "$EXEDIR\$R1" "$INSTDIR\$R1"

SkipCopy:
  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
  SetShellVarContext all ; Put stuff in All Users
  SetOutPath $INSTDIR

  CreateDirectory "$SMPROGRAMS\$ICONS_GROUP"
  CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Uninstall.lnk" "$INSTDIR\uninst.exe"

  ; Check MSYS2
  SetOutPath "$INSTDIR\msys2"
  CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\MingW64.lnk" "$INSTDIR\msys2\mingw64.exe" "" "$INSTDIR\msys2\mingw64.ico"
  !insertmacro MUI_STARTMENU_WRITE_END

  WriteUninstaller "$INSTDIR\uninst.exe"
  IntCmp $Updating 1 SkipInstall

  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "InstallLocation" "$INSTDIR"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"

SkipInstall:
  ; Write the version to the reg key so add/remove prograns has the right one
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
SectionEnd

Section Uninstall
  SetShellVarContext all ; remove stuff from All Users
  !insertmacro MUI_STARTMENU_GETFOLDER "Application" $ICONS_GROUP
  RMDir /r "$SMPROGRAMS\$ICONS_GROUP"
  RMDir /r $INSTDIR

  ReadRegStr $1 HKLM "System\CurrentControlSet\Control\Session Manager\Environment" "PATH"
  ${UnStrRep} $1 $1 "$INSTDIR\msys\bin;" ""
  ${UnStrRep} $1 $1 "$INSTDIR\msys2\usr\bin;" ""

  StrCmp $1 "" 0 ResetPath

  MessageBox mb_IconStop|mb_TopMost|mb_SetForeground "Trying to set path to blank string!$\nPlease reset path manually"
  goto BlankedPath

ResetPath:
  WriteRegExpandStr HKLM "System\CurrentControlSet\Control\Session Manager\Environment" "PATH" $1
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000

BlankedPath:
  DeleteRegKey HKCR ".pnproj"
  DeleteRegKey HKCR "PN2.pnproj.1\shell\open\command"
  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"

  SetAutoClose true
SectionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; .onInit:
;
Function .onInit
  ${If} ${RunningX64}
  ${Else}
    MessageBox mb_IconStop|mb_TopMost|mb_SetForeground "Sorry, this installer only supports 64 bit."
    Quit
  ${EndIf}

  StrCpy $Updating 0

  ReadRegStr $1 ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "InstallLocation"
  StrCmp $1 "" Installing

  ; If already installed, quit now
  MessageBox mb_IconStop|mb_TopMost|mb_SetForeground "${PRODUCT_NAME} is already installed in $1."
  Quit

Installing:
  Delete $EXEDIR\update.ini

  ; Quietly download the latest update.ini file
  inetc::get /NOCANCEL /SILENT "https://drive.google.com/uc?export=download&confirm=no_antivirus&id=1tle8RyHDCaWQipRzaHMV3P0ctWwHs8Ir" "$EXEDIR\update.ini" /END
  Pop $R0
  StrCmp $R0 "OK" GotINI

  ; If failed to download, quit now
  MessageBox mb_IconStop|mb_TopMost|mb_SetForeground "${PRODUCT_NAME} failed to download update.ini."
  Quit

GotINI:
  IntOp $0 ${SF_SELECTED} | ${SF_RO}
  SectionSetFlags ${SectionMSYS2} $0
  SectionSetFlags ${SectionToolchain} $0
  SectionSetFlags ${SectionInstall_Script} $0

  ReadINIStr $R0 "$EXEDIR\update.ini" "MSYS2" "Size"
  ReadINIStr $MSYS2_VERSION "$EXEDIR\update.ini" "MSYS2" "Version"
  ReadINIStr $MSYS2_URL "$EXEDIR\update.ini" "MSYS2" "URL"
  ReadINIStr $MSYS2_FILE "$EXEDIR\update.ini" "MSYS2" "File"
  SectionSetSize ${SectionMSYS2} $R0

  ReadINIStr $R0 "$EXEDIR\update.ini" "Toolchain" "Size"
  ReadINIStr $TOOLCHAIN_FILE "$EXEDIR\update.ini" "Toolchain" "File"
  ReadINIStr $TOOLCHAIN_VERSION "$EXEDIR\update.ini" "Toolchain" "Version"
  ReadINIStr $TOOLCHAIN_URL "$EXEDIR\update.ini" "Toolchain" "URL"
  SectionSetSize ${SectionToolchain} $R0

  ReadINIStr $R0 "$EXEDIR\update.ini" "Install_Script" "Size"
  ReadINIStr $INSTALL_SCRIPT_FILE "$EXEDIR\update.ini" "Install_Script" "File"
  ReadINIStr $INSTALL_SCRIPT_VERSION "$EXEDIR\update.ini" "Install_Script" "Version"
  ReadINIStr $INSTALL_SCRIPT_URL "$EXEDIR\update.ini" "Install_Script" "URL"
  SectionSetSize ${SectionInstall_Script} $R0

  Delete $EXEDIR\update.ini

  StrCpy $Updates 0

  push "MSYS2"
  push $MSYS2_VERSION
  push ${SectionMSYS2}
  call CheckVersion

  push "Toolchain"
  push $TOOLCHAIN_VERSION
  push ${SectionToolchain}
  call CheckVersion

  push "Install_Script"
  push $INSTALL_SCRIPT_VERSION
  push ${SectionInstall_Script}
  call CheckVersion
FunctionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CheckVersion:
;
var CurrentVer
var InstalledVer
var PackageSection
var PackageFlags
var Key
var IsNew

Function CheckVersion
  pop $PackageSection
  pop $CurrentVer
  pop $Key

  ReadINIStr $InstalledVEr "$INSTDIR\installed.ini" "$Key" "Version"

  IntOp $IsNew 0 + 0

  ; check for blank installed version
  StrLen $0 $InstalledVer
  IntCmp $0 0 +1 GotInstalled GotInstalled

  StrCpy $InstalledVer 0
  WriteINIStr $INSTDIR\installed.ini "$Key" "Version" "0"

  IntOp $IsNew 0 + 1

GotInstalled:

  SectionGetFlags $PackageSection $PackageFlags

  IntOp $R1 ${SF_RO} ~
  IntOp $PackageFlags $PackageFlags & $R1
  IntOp $PackageFlags $PackageFlags & ${SECTION_OFF}

  StrCmp $CurrentVer $InstalledVer NoUpdate

  Intop $Updates $Updates + 1

  IntCmp $IsNew 1 SelectIt NoSelectIt NoSelectIt

NoSelectIt:
  ; Don't select if not installed
  StrCmp $InstalledVer 0 Done

SelectIt:
  IntOp $PackageFlags $PackageFlags | ${SF_SELECTED}

  Goto Done

NoUpdate:
  SectionSetText $PackageSection ""

Done:
  SectionSetFlags $PackageSection $PackageFlags

FunctionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; .onVerifyInstDir:
;
Function .onVerifyInstDir
  ${StrContains} $0 " " $INSTDIR
  StrCmp $0 "" PathGood
    Abort
PathGood:
FunctionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; un.onUninstSuccess:
;
Function un.onUninstSuccess
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "${PRODUCT_NAME} were successfully removed from your computer."
FunctionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; un.onInit:
;
Function un.onInit
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Are you sure you want to completely remove ${PRODUCT_NAME}?" IDYES +2
  Abort

  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Are absolutely sure you want to do this?$\r$\nThis will remove the whole ${PRODUCT_NAME} folder and its contents." IDYES +2
  Abort
FunctionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; AbortPage:
;
Function AbortPage
  IntCmp $Updating 1 +1 TestInstall TestInstall
    Abort

TestInstall:
  IntCmp $Install 1 ShowPage +1 +1
    Abort

ShowPage:
FunctionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DownloadIfNeeded:
;
var DownloadURL
var FileName
var Section
var Retry

Function DownloadIfNeeded
  pop $DownloadURL ; Download URL
  pop $FileName ; Filename
  pop $Section ; Section flags

  SectionGetFlags $Section $0
  IntOp $0 $0 & ${SF_SELECTED}
  IntCmp $0 ${SF_SELECTED} +1 SkipThisDL

  ifFileExists "$EXEDIR\$FileName" ThisFileFound

  StrCpy $Retry 3

RetryLoop:
  inetc::get /RESUME "" "$DownloadURL" "$EXEDIR\$FileName" /END
  Pop $0
  StrCmp $0 "OK" ThisFileFound

  IntOp $Retry $Retry - 1
  IntCmp $Retry 0 +1 +1 RetryLoop

  Detailprint $0
  ; zero byte files tend to be left at this point
  ; delete it so the installer doesn't decide the file exists and break when trying to extract
  Delete "$EXEDIR\$Filename"
  Abort "$FileName could not be downloaded at this time."

ThisFileFound:
SkipThisDL:

FunctionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; RemoveFile:
;   Delete an archive.
Function RemoveFile
  pop $filename

  Delete "$EXEDIR\$filename"
FunctionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ChooseMirrorPage:
;
Function ChooseMirrorPage
  StrCpy $Install 1
FunctionEnd
