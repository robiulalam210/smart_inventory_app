!define APP_NAME        "Meherin Mart Release 1.0.1"
!define REG_APP_KEY     "MeherinMart_App"
!define APP_VERSION     "1.0.0"
!define EXE_NAME        "meherin_mart.exe"
!define INSTALL_DIR     "$PROGRAMFILES64\${APP_NAME}"

OutFile "${APP_NAME}_Installer.exe"
InstallDir "${INSTALL_DIR}"

RequestExecutionLevel admin
ShowInstDetails show
ShowUninstDetails show

Section "Install"
    ; Install directory
    SetOutPath "$INSTDIR"

    ; Copy flutter windows release files
    File /r "build\windows\x64\runner\Release\*"

    ; Create uninstaller
    WriteUninstaller "$INSTDIR\uninstall.exe"

    ; Desktop shortcut
    CreateShortcut "$DESKTOP\${APP_NAME}.lnk" "$INSTDIR\${EXE_NAME}"

    ; Start menu shortcut
    CreateDirectory "$SMPROGRAMS\${APP_NAME}"
    CreateShortcut "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk" "$INSTDIR\${EXE_NAME}"

    ; Registry entries for Add/Remove Programs
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${REG_APP_KEY}" "DisplayName" "${APP_NAME}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${REG_APP_KEY}" "DisplayVersion" "${APP_VERSION}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${REG_APP_KEY}" "Publisher" "Meherin Software"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${REG_APP_KEY}" "DisplayIcon" "$INSTDIR\${EXE_NAME}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${REG_APP_KEY}" "InstallLocation" "$INSTDIR"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${REG_APP_KEY}" "UninstallString" "$INSTDIR\uninstall.exe"

    ; Remove modify/repair options
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${REG_APP_KEY}" "NoModify" 1
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${REG_APP_KEY}" "NoRepair" 1

    ; Launch app after install
    IfFileExists "$INSTDIR\${EXE_NAME}" 0 +2
        Exec "$INSTDIR\${EXE_NAME}"

SectionEnd


Section "Uninstall"
    ; Remove installed files
    Delete "$INSTDIR\${EXE_NAME}"
    Delete "$INSTDIR\uninstall.exe"
    RMDir /r "$INSTDIR"

    ; Remove shortcuts
    Delete "$DESKTOP\${APP_NAME}.lnk"
    Delete "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk"
    RMDir "$SMPROGRAMS\${APP_NAME}"

    ; Remove registry entry
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${REG_APP_KEY}"
SectionEnd
