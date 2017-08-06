; 該指令檔使用 HM VNISEdit 指令檔編輯器精靈產生

; 安裝程式初始定義常量
!define PRODUCT_NAME "SYRIS-V8";jash modify
!define PRODUCT_VERSION "v0101";jash modify
!define PRODUCT_PUBLISHER "SYRIS, Inc.";jash modify
!define PRODUCT_WEB_SITE "http://www.syris.com/";jash modify
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\SYRIS-V8.exe";jash modify
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

SetCompressor /SOLID lzma

; ------ MUI 現代介面定義 (1.67 版本以上相容) ------
!include "MUI.nsh"

; MUI 預定義常量
!define MUI_ABORTWARNING
!define MUI_ICON "Release\SYWEB-icon_100x100.ico";jash modify
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"

; 語言選擇視窗常量設定
!define MUI_LANGDLL_REGISTRY_ROOT "${PRODUCT_UNINST_ROOT_KEY}"
!define MUI_LANGDLL_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
!define MUI_LANGDLL_REGISTRY_VALUENAME "NSIS:Language"

; 歡迎頁面
!insertmacro MUI_PAGE_WELCOME
; 授權合約頁面
;!insertmacro MUI_PAGE_LICENSE "..\..\..\path\to\licence\YourSoftwareLicence.txt"
; 安裝資料夾選擇頁面
!insertmacro MUI_PAGE_DIRECTORY
; 安裝過程頁面
!insertmacro MUI_PAGE_INSTFILES
; 安裝完成頁面
;!define MUI_FINISHPAGE_RUN "$INSTDIR\BCard_WCard_Generator.exe"
!insertmacro MUI_PAGE_FINISH

; 安裝卸載過程頁面
!insertmacro MUI_UNPAGE_INSTFILES

; 安裝介麵包含的語言設定
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "SimpChinese"
!insertmacro MUI_LANGUAGE "TradChinese"

; 安裝預釋放檔案
!insertmacro MUI_RESERVEFILE_LANGDLL
!insertmacro MUI_RESERVEFILE_INSTALLOPTIONS
; ------ MUI 現代介面定義結束 ------

ReserveFile "${NSISDIR}\Plugins\splash.dll"
;ReserveFile "c:\path\to\Splash\YourSplash.bmp"
;ReserveFile "c:\path\to\Splash\YourSplashSound.wav"

ReserveFile "${NSISDIR}\Plugins\system.dll"
;ReserveFile "c:\path\to\YourMIDI.mid"

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "SYRIS-V8 Setup.exe";jash modify
InstallDir "$PROGRAMFILES\SYRIS-V8";jash modify
InstallDirRegKey HKLM "${PRODUCT_UNINST_KEY}" "UninstallString"
ShowInstDetails show
ShowUnInstDetails show

Section "MainSection" SEC01
  SetOverwrite on
  
  SetOutPath "$INSTDIR"
  CreateDirectory "$SMPROGRAMS\SYRIS-V8";jash modify
  CreateShortCut "$SMPROGRAMS\SYRIS-V8\SYRIS-V8.lnk" "$INSTDIR\SYRIS-V8.exe";jash modify
  CreateShortCut "$DESKTOP\SYRIS-V8.lnk" "$INSTDIR\SYRIS-V8.exe";jash modify

  File "Release\SYRIS-V8.exe";jash modify
  File "Release\SYRIS-V8.zip";jash modify
  
  ;使用外掛元件執行解壓縮
  nsisunz::UnzipToLog "$INSTDIR\SYRIS-V8.zip" $INSTDIR   


  Call GetNetFrameworkVersion
  Pop $R1
  ${If} $R1 < '4.0.30319'
	SetOverwrite on
	File "Release\dotNetFx40_Full_x86_x64.exe";jash modify
  ${ENDIF}
  
SectionEnd

Section -AdditionalIcons
  SetOutPath $INSTDIR
  WriteIniStr "$INSTDIR\${PRODUCT_NAME}.url" "InternetShortcut" "URL" "${PRODUCT_WEB_SITE}"
  CreateShortCut "$SMPROGRAMS\SYRIS-V8\Website.lnk" "$INSTDIR\${PRODUCT_NAME}.url";jash modify
  CreateShortCut "$SMPROGRAMS\SYRIS-V8\Uninstall.lnk" "$INSTDIR\uninst.exe";jash modify
SectionEnd

Section -Post
  WriteUninstaller "$INSTDIR\uninst.exe"
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\SYRIS-V8.exe";jash modify
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\SYRIS-V8.exe";jash modify
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
SectionEnd

#-- 依 NSIS 指令檔編輯規則，所有 Function 區段必須放置在 Section 區段之後編寫，以避免安裝程式出現未可預知的問題。--#

Function .onInit
  InitPluginsDir
  ;File "/oname=$PLUGINSDIR\Splash_YourSplash.bmp" "c:\path\to\Splash\YourSplash.bmp"
  ;File "/oname=$PLUGINSDIR\Splash_YourSplash.wav" "c:\path\to\Splash\YourSplashSound.wav"
  ; 使用閃屏外掛程式顯示閃屏
  splash::show 1000 "$PLUGINSDIR\Splash_YourSplash"
  Pop $0 ; $0 返回 '1' 表示使用者提前關閉閃屏, 返回 '0' 表示閃屏正常結束, 返回 '-1' 表示閃屏顯示出錯
  ;File "/oname=$PLUGINSDIR\bgm_YourMIDI.mid" "c:\path\to\YourMIDI.mid"
  ; 開啟音樂檔案
  System::Call "winmm.dll::mciSendString(t 'OPEN $PLUGINSDIR\bgm_YourMIDI.mid TYPE SEQUENCER ALIAS BGMUSIC', t .r0, i 130, i 0)"
  ; 開始播放音樂檔案
  System::Call "winmm.dll::mciSendString(t 'PLAY BGMUSIC NOTIFY', t .r0, i 130, i 0)"
  !insertmacro MUI_LANGDLL_DISPLAY
FunctionEnd

Function .onGUIEnd
  ; 停止播放音樂檔案
  System::Call "winmm.dll::mciSendString(t 'STOP BGMUSIC',t .r0,i 130,i 0)"
  ; 關閉音樂檔案
  System::Call "winmm.dll::mciSendString(t 'CLOSE BGMUSIC',t .r0,i 130,i 0)"
FunctionEnd

Section -.NET
  Call GetNetFrameworkVersion
  Pop $R1
  ${If} $R1 < '4.0.30319'
	  ;當有安裝就要重開機
	  SetRebootFlag true
	  IfRebootFlag 0 +2
	  ;當有安裝就要重開機
      ;MessageBox MB_OK "Because the installation .NET Framework, must now restart the computer"
	  SetOutPath "$TEMP"
	  SetOverwrite on
	  File "Release\dotNetFx40_Full_x86_x64.exe"
      ExecWait '$TEMP\dotNetFx40_Full_x86_x64.exe /q /norestart /ChainingPackage FullX64Bootstrapper' $R1
	  Delete "$TEMP\dotNetFx40_Full_x86_x64.exe"
  ${ENDIF}
SectionEnd

/******************************
 *  以下是安裝程式的卸載部分  *
 ******************************/

Section Uninstall

  Delete "$DESKTOP\SYRIS-V8.lnk";jash modify

  
  RMDir /r "$INSTDIR\*.*"
  RMDir "$INSTDIR"
  
  RMDir /r "$SMPROGRAMS\SYRIS-V8\*.*";jash modify
  RMDir "$SMPROGRAMS\SYRIS-V8";jash modify  
  
  SetShellVarContext all
  RMDir /r "$SMPROGRAMS\SYRIS-V8\*.*";jash modify
  RMDir "$SMPROGRAMS\SYRIS-V8";jash modify


  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  SetAutoClose true
SectionEnd

Function GetNetFrameworkVersion
;取.Net Framework版本支持
    Push $1
    Push $0
    ReadRegDWORD $0 HKLM "SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" "Install"
    ReadRegDWORD $1 HKLM "SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" "Version"
    StrCmp $0 1 KnowNetFrameworkVersion +1
    ReadRegDWORD $0 HKLM "SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5" "Install"
    ReadRegDWORD $1 HKLM "SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5" "Version"
    StrCmp $0 1 KnowNetFrameworkVersion +1
    ReadRegDWORD $0 HKLM "SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.0\Setup" "InstallSuccess"
    ReadRegDWORD $1 HKLM "SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.0\Setup" "Version"
    StrCmp $0 1 KnowNetFrameworkVersion +1
    ReadRegDWORD $0 HKLM "SOFTWARE\Microsoft\NET Framework Setup\NDP\v2.0.50727" "Install"
    ReadRegDWORD $1 HKLM "SOFTWARE\Microsoft\NET Framework Setup\NDP\v2.0.50727" "Version"
    StrCmp $1 "" +1 +2
    StrCpy $1 "2.0.50727.832"
    StrCmp $0 1 KnowNetFrameworkVersion +1
    ReadRegDWORD $0 HKLM "SOFTWARE\Microsoft\NET Framework Setup\NDP\v1.1.4322" "Install"
    ReadRegDWORD $1 HKLM "SOFTWARE\Microsoft\NET Framework Setup\NDP\v1.1.4322" "Version"
    StrCmp $1 "" +1 +2
    StrCpy $1 "1.1.4322.573"
    StrCmp $0 1 KnowNetFrameworkVersion +1
    ReadRegDWORD $0 HKLM "SOFTWARE\Microsoft\.NETFramework\policy\v1.0" "Install"
    ReadRegDWORD $1 HKLM "SOFTWARE\Microsoft\.NETFramework\policy\v1.0" "Version"
    StrCmp $1 "" +1 +2
    StrCpy $1 "1.0.3705.0"
    StrCmp $0 1 KnowNetFrameworkVersion +1
    StrCpy $1 "not .NetFramework"
    KnowNetFrameworkVersion:
    Pop $0
    Exch $1
FunctionEnd
#-- 依 NSIS 指令檔編輯規則，所有 Function 區段必須放置在 Section 區段之後編寫，以避免安裝程式出現未可預知的問題。--#

Function un.onInit
!insertmacro MUI_UNGETLANGUAGE
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "你確實要完全移除 $(^Name) ，及其所有的元件？" IDYES +2
  Abort
FunctionEnd

Function un.onUninstSuccess
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) 已成功地從你的電腦移除。"
FunctionEnd
