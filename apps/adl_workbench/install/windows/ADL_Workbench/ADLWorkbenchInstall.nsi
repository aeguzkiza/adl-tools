# Auto-generated by EclipseNSIS Script Wizard
# 20/09/2007 13:54:00

Name "ADL Workbench"

# Defines
!define REGKEY "SOFTWARE\$(^Name)"
!define VERSION "1.5"
!define COMPANY "openEHR Foundation"
!define URL www.openehr.org

# MUI defines
!define MUI_ICON "..\..\..\app\icons\openEHR.ico"
!define MUI_WELCOMEPAGE_TEXT "This wizard will guide you through the installation of the openEHR Foundation's $(^Name).\r\n\r\nClick Next to continue."
!define MUI_LICENSEPAGE_RADIOBUTTONS
!define MUI_STARTMENUPAGE_REGISTRY_ROOT HKLM
!define MUI_STARTMENUPAGE_NODISABLE
!define MUI_STARTMENUPAGE_REGISTRY_KEY ${REGKEY}
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME StartMenuGroup
!define MUI_STARTMENUPAGE_DEFAULTFOLDER "openEHR\ADL Workbench"
!define MUI_UNICON "..\..\..\app\icons\openEHR.ico"
!define MUI_WELCOMEFINISHPAGE_BITMAP "birds_vertical.bmp"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "openEHR.bmp"
!define MUI_FINISHPAGE_RUN "$INSTDIR\adl_workbench.exe"
!define MUI_FINISHPAGE_SHOWREADME "http://www.openehr.org/svn/ref_impl_eiffel/TRUNK/apps/adl_workbench/doc/web/release_notes.html"
!define MUI_FINISHPAGE_SHOWREADME_TEXT "Show Release Notes"
!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_UNFINISHPAGE_NOAUTOCLOSE

# Included files
!include Sections.nsh
!include MUI.nsh

# Variables
Var StartMenuGroup

# Installer pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "..\..\..\doc\LICENSE.txt"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_STARTMENU Application $StartMenuGroup
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

# Installer languages
!insertmacro MUI_LANGUAGE English

# Installer attributes
InstallDir "$PROGRAMFILES\openEHR\ADL Workbench"
CRCCheck on
XPStyle on
ShowInstDetails show
VIProductVersion 1.5.0.0
VIAddVersionKey ProductName "openEHR ADL Workbench"
VIAddVersionKey ProductVersion "${VERSION}"
VIAddVersionKey CompanyName "${COMPANY}"
VIAddVersionKey CompanyWebsite "${URL}"
VIAddVersionKey FileVersion "${VERSION}"
VIAddVersionKey FileDescription "ADL Workbench Installer"
VIAddVersionKey LegalCopyright "Copyright 2003-2010 openEHR Foundation"
InstallDirRegKey HKLM "${REGKEY}" Path
ShowUninstDetails show

# Installer sections
Section -Main SEC0000
    SetOverwrite ifnewer

    SetOutPath $INSTDIR

    !ifdef ADL_WORKBENCH_EXE
        File ${ADL_WORKBENCH_EXE}
    !else
        File ..\..\..\app\EIFGENs\adl_workbench\F_code\adl_workbench.exe
    !endif

    File ..\..\..\app\ArchetypeRepositoryReport.xsl
    File ..\..\..\app\ArchetypeRepositoryReport.css

    SetOutPath $INSTDIR\icons
    File /r /x .svn ..\..\..\app\icons\*

    SetOutPath $INSTDIR\rm_schemas
    File ..\..\..\..\..\rm_schemas\*

    SetOutPath $INSTDIR\error_db
    File ..\..\..\app\error_db\*

    SetOutPath $INSTDIR\vim
    File ..\..\..\..\..\components\adl_compiler\etc\vim\*

    WriteRegStr HKLM "${REGKEY}\Components" Main 1
SectionEnd

Section -post SEC0001
    WriteRegStr HKLM "${REGKEY}" Path $INSTDIR
    SetOutPath $INSTDIR
    WriteUninstaller $INSTDIR\uninstall.exe
    !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
    SetOutPath $SMPROGRAMS\$StartMenuGroup
    SetOutPath $INSTDIR
    CreateShortcut "$SMPROGRAMS\$StartMenuGroup\Uninstall $(^Name).lnk" $INSTDIR\uninstall.exe
    CreateShortcut "$SMPROGRAMS\$StartMenuGroup\ADL Workbench.lnk" $INSTDIR\adl_workbench.exe
    !insertmacro MUI_STARTMENU_WRITE_END
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" DisplayName "$(^Name)"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" DisplayVersion "${VERSION}"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" Publisher "${COMPANY}"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" URLInfoAbout "${URL}"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" DisplayIcon $INSTDIR\uninstall.exe
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" UninstallString $INSTDIR\uninstall.exe
    WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" NoModify 1
    WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" NoRepair 1
SectionEnd

# Macro for selecting uninstaller sections
!macro SELECT_UNSECTION SECTION_NAME UNSECTION_ID
    Push $R0
    ReadRegStr $R0 HKLM "${REGKEY}\Components" "${SECTION_NAME}"
    StrCmp $R0 1 0 next${UNSECTION_ID}
    !insertmacro SelectSection "${UNSECTION_ID}"
    GoTo done${UNSECTION_ID}
next${UNSECTION_ID}:
    !insertmacro UnselectSection "${UNSECTION_ID}"
done${UNSECTION_ID}:
    Pop $R0
!macroend

# Uninstaller sections
Section /o un.Main UNSEC0000

    Delete /REBOOTOK $INSTDIR\adl_workbench.exe
    Delete /REBOOTOK $INSTDIR\ArchetypeRepositoryReport.xsl
    Delete /REBOOTOK $INSTDIR\ArchetypeRepositoryReport.css
    RMDir /r /REBOOTOK $INSTDIR\icons
    RMDir /r /REBOOTOK $INSTDIR\rm_schemas
    RMDir /r /REBOOTOK $INSTDIR\error_db
    RMDir /r /REBOOTOK $INSTDIR\vim
    DeleteRegValue HKLM "${REGKEY}\Components" Main
SectionEnd

Section un.post UNSEC0001
    DeleteRegKey HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)"
    Delete /REBOOTOK "$SMPROGRAMS\$StartMenuGroup\Uninstall $(^Name).lnk"
    Delete /REBOOTOK "$SMPROGRAMS\$StartMenuGroup\ADL Workbench.lnk"
    Delete /REBOOTOK $INSTDIR\uninstall.exe
    DeleteRegValue HKLM "${REGKEY}" StartMenuGroup
    DeleteRegValue HKLM "${REGKEY}" Path
    DeleteRegKey /IfEmpty HKLM "${REGKEY}\Components"
    DeleteRegKey /IfEmpty HKLM "${REGKEY}"
    RmDir /REBOOTOK $SMPROGRAMS\$StartMenuGroup
    RmDir /REBOOTOK $INSTDIR
SectionEnd

# Installer functions
Function .onInit
    InitPluginsDir
FunctionEnd

# Uninstaller functions
Function un.onInit
    ReadRegStr $INSTDIR HKLM "${REGKEY}" Path
    !insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuGroup
    !insertmacro SELECT_UNSECTION Main ${UNSEC0000}
FunctionEnd
