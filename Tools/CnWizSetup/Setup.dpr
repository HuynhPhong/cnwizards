{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2019 CnPack 开发组                       }
{                   ------------------------------------                       }
{                                                                              }
{            本开发包是开源的自由软件，您可以遵照 CnPack 的发布协议来修        }
{        改和重新发布这一程序。                                                }
{                                                                              }
{            发布这一开发包的目的是希望它有用，但没有任何担保。甚至没有        }
{        适合特定目的而隐含的担保。更详细的情况请参阅 CnPack 发布协议。        }
{                                                                              }
{            您应该已经和开发包一起收到一份 CnPack 发布协议的副本。如果        }
{        还没有，可访问我们的网站：                                            }
{                                                                              }
{            网站地址：http://www.cnpack.org                                   }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

program Setup;
{* |<PRE>
================================================================================
* 软件名称：CnWizards IDE 专家工具包
* 单元名称：简单的安装程序
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：不带参数运行时自动判断安装状态，并安装/反安装专家
*           命令行 Setup [/i|/u] [/n] [/?|/h]
*           带 /i 参数运行时安装专家
*           带 /u 参数运行时反安装专家
*           带 /n 参数运行时不显示对话框（可与前面的组合）
*           带 /? 显示支持的参数列表
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6
* 本 地 化：该单元中的字符串可处理为符合本地化处理方式
* 单元标识：$Id: Setup.dpr,v 1.19 2009/04/18 13:42:17 zjy Exp $
* 修改记录：2002.10.01 V1.1
*               新增参数支持
*           2002.09.28 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

{$I CnPack.inc}

uses
  Windows,
  SysUtils,
  Registry,
  FileCtrl,
  CnCommon,
  CnLangTranslator,
  CnLangStorage,
  CnHashLangStorage,
  CnLangMgr,
  CnWizCompilerConst,
  CnWizLangID;

{$R *.RES}
{$R SetupRes.RES}

{$IFDEF COMPILER7_UP}
{$R WindowsXP.res}
{$ENDIF}

type
  TCompilerName = (cvD5, cvD6, cvD7, cvD8, cbD2005, cbD2006, cbD2007, cbD2009,
    cbD2010, cbDXE, cbDXE2, cbDXE3, cbDXE4, cbDXE5, cbDXE6, cbDXE7, cbXE8, cb10S,
    cb101B, cb102T, cb103R, cvCB5, cvCB6);

const
  csCompilerNames: array[TCompilerName] of string = (
    'Delphi 5',
    'Delphi 6',
    'Delphi 7',
    'Delphi 8',
    'BDS 2005',
    'BDS 2006',
    'RAD Studio 2007',
    'RAD Studio 2009',
    'RAD Studio 2010',
    'RAD Studio XE',
    'RAD Studio XE2',
    'RAD Studio XE3',
    'RAD Studio XE4',
    'RAD Studio XE5',
    'RAD Studio XE6',
    'RAD Studio XE7',
    'RAD Studio XE8',
    'RAD Studio 10 Seattle',
    'RAD Studio 10.1 Berlin',
    'RAD Studio 10.2 Tokyo',
    'RAD Studio 10.3 Rio',
    'C++Builder 5',
    'C++Builder 6');

  csRegPaths: array[TCompilerName] of string = (
    '\Software\Borland\Delphi\5.0',
    '\Software\Borland\Delphi\6.0',
    '\Software\Borland\Delphi\7.0',
    '\Software\Borland\BDS\2.0',
    '\Software\Borland\BDS\3.0',
    '\Software\Borland\BDS\4.0',
    '\Software\Borland\BDS\5.0',
    '\Software\CodeGear\BDS\6.0',
    '\Software\CodeGear\BDS\7.0',
    '\Software\Embarcadero\BDS\8.0',
    '\Software\Embarcadero\BDS\9.0',
    '\Software\Embarcadero\BDS\10.0',
    '\Software\Embarcadero\BDS\11.0',
    '\Software\Embarcadero\BDS\12.0',
    '\Software\Embarcadero\BDS\14.0',
    '\Software\Embarcadero\BDS\15.0',
    '\Software\Embarcadero\BDS\16.0',
    '\Software\Embarcadero\BDS\17.0',
    '\Software\Embarcadero\BDS\18.0',
    '\Software\Embarcadero\BDS\19.0',
    '\Software\Embarcadero\BDS\20.0',
    '\Software\Borland\C++Builder\5.0',
    '\Software\Borland\C++Builder\6.0');

  csDllNames: array[TCompilerName] of string = (
    'CnWizards_D5.DLL',
    'CnWizards_D6.DLL',
    'CnWizards_D7.DLL',
    'CnWizards_D8.DLL',
    'CnWizards_D2005.DLL',
    'CnWizards_D2006.DLL',
    'CnWizards_D2007.DLL',
    'CnWizards_D2009.DLL',
    'CnWizards_D2010.DLL',
    'CnWizards_DXE.DLL',
    'CnWizards_DXE2.DLL',
    'CnWizards_DXE3.DLL',
    'CnWizards_DXE4.DLL',
    'CnWizards_DXE5.DLL',
    'CnWizards_DXE6.DLL',
    'CnWizards_DXE7.DLL',
    'CnWizards_DXE8.DLL',
    'CnWizards_D10S.DLL',
    'CnWizards_D101B.DLL',
    'CnWizards_D102T.DLL',
    'CnWizards_D103R.DLL',
    'CnWizards_CB5.DLL',
    'CnWizards_CB6.DLL');

  csLangDir = 'Lang\';
  csExperts = '\Experts';
  csLangFile = 'Setup.txt';

var
  csHintStr: string = 'Hint';
  csInstallSucc: string = 'CnPack IDE Wizards have been Installed in:' + #13#10 + '';
  csInstallSuccEnd: string = 'Run Setup again to Uninstall.';
  csUnInstallSucc: string = 'CnPack IDE Wizards have been Uninstalled From:' + #13#10 + '';
  csUnInstallSuccEnd: string = 'Run Setup again to Install.';
  csInstallFail: string = 'Can''t Find Delphi or C++Builder to Install CnPack IDE Wizards.';
  csUnInstallFail: string = 'CnPack IDE Wizards have already Disabled.';

  csSetupCmdHelp: string =
    'This Tool Supports Command Line Mode without Showing the Main Form.' + #13#10#13#10 +
    'Command Line Switch Help:' + #13#10#13#10 +
    '         -i or /i or -install or /install Install to IDE' + #13#10 +
    '         -u or /u or -uninstall or /uninstall UnInstall from IDE' + #13#10 +
    '         -n or /n or -NoMsg or /NoMsg Do NOT Show the Success Message after Setup run.' + #13#10 +
    '         -? or /? or -h or /h Show the Command Line Help.';

//==============================================================================
// 注册表访问
//==============================================================================

// 检查注册表键是否存在
function RegKeyExists(const RegPath: string): Boolean;
var
  Reg: TRegistry;
begin
  try
    Reg := TRegistry.Create;
    try
      Result := Reg.KeyExists(RegPath);
    finally
      Reg.Free;
    end;
  except
    Result := False;
  end;
end;

// 检查注册表键值是否存在
function RegValueExists(const RegPath, RegValue: string): Boolean;
var
  Reg: TRegistry;
begin
  try
    Reg := TRegistry.Create;
    try
      Result := Reg.OpenKey(RegPath, False) and Reg.ValueExists(RegValue);
    finally
      Reg.Free;
    end;
  except
    Result := False;
  end;
end;

// 删除注册表键值
function RegDeleteValue(const RegPath, RegValue: string): Boolean;
var
  Reg: TRegistry;
begin
  try
    Reg := TRegistry.Create;
    try
      Result := Reg.OpenKey(RegPath, False);
      if Result then
        Reg.DeleteValue(RegValue);
    finally
      Reg.Free;
    end;
  except
    Result := False;
  end;
end;

// 写注册表字符串
function RegWriteStr(const RegPath, RegValue, Str: string): Boolean;
var
  Reg: TRegistry;
begin
  try
    Reg := TRegistry.Create;
    try
      Result := Reg.OpenKey(RegPath, True);
      if Result then Reg.WriteString(RegValue, Str);
    finally
      Reg.Free;
    end;
  except
    Result := False;
  end;
end;

//==============================================================================
// 专家处理
//==============================================================================

var
  ParamInstall: Boolean;
  ParamUnInstall: Boolean;
  ParamNoMsg: Boolean;
  ParamCmdHelp :Boolean;

// 取专家 DLL 文件名
function GetDllName(Compiler: TCompilerName): string;
const
  RIO_10_3_2: TVersionNumber =
    (Major: 26; Minor: 0; Release: 34749; Build: 6593); // 10.3.2
var
  IDE: string;
  Reg: TRegistry;
  Version: TVersionNumber;
begin
  Result := _CnExtractFilePath(ParamStr(0)) + csDllNames[Compiler];
  // 10.3 下动态判断文件名的版本确定究竟用哪个 DLL
  if Compiler = cb103R then
  begin
    // 10.3.2 使用最新 DLL，但 10.3.1 或以下版本使用另一个 DLL
    // 读 HKEY_CURRENT_USER\Software\Embarcadero\BDS\20.0 下的 RootDir 得到安装目录
    IDE := 'C:\Program Files\Embarcadero\Studio\20.0\';
    Reg := nil;

    try
      Reg := TRegistry.Create;
      if Reg.OpenKey('\Software\Embarcadero\BDS\20.0', False) then
        IDE := Reg.ReadString('RootDir');
    finally
      Reg.Free;
    end;

    if not DirectoryExists(IDE) then
      Exit;

    IDE := IncludeTrailingPathDelimiter(IDE) + 'bin\bds.exe';
    if not FileExists(IDE) then
      Exit;

    // 读 bds.exe 的版本号
    Version := GetFileVersionNumber(IDE);
    if (Version.Major <> 26) or (Version.Minor <> 0) then
      Exit;

    if Version.Release < RIO_10_3_2.Release then
      Result := _CnExtractFilePath(ParamStr(0)) + 'CnWizards_D103R1.DLL';
  end;
end;

// 取专家名
function GetDllValue(Compiler: TCompilerName): string;
begin
  Result := _CnChangeFileExt(csDllNames[Compiler], '');
end;

// 判断专家 DLL 是否存在
function WizardExists(Compiler: TCompilerName): Boolean;
begin
  Result := FileExists(GetDllName(Compiler));
end;

// 判断是否安装
function IsInstalled: Boolean;
var
  Compiler: TCompilerName;
begin
  Result := True;
  for Compiler := Low(Compiler) to High(Compiler) do
    if WizardExists(Compiler) and RegKeyExists(csRegPaths[Compiler]) and
      not RegValueExists(csRegPaths[Compiler] + csExperts, GetDllValue(Compiler)) then
    begin
      Result := False;
      Exit;
    end;
end;

// 安装专家
procedure InstallWizards;
var
  S: string;
  Compiler: TCompilerName;
  Key: HKEY;
begin
  S := csInstallSucc;
  for Compiler := Low(Compiler) to High(Compiler) do
  begin
    if Compiler = cvD8 then // 不安装 D8 的
      Continue;

    if WizardExists(Compiler) and RegKeyExists(csRegPaths[Compiler]) then
    begin
      if not RegKeyExists(csRegPaths[Compiler] + csExperts) then
      begin
        RegCreateKey(HKEY_CURRENT_USER, PChar(csRegPaths[Compiler] + csExperts), Key);
        RegCloseKey(Key);
      end;

      if RegWriteStr(csRegPaths[Compiler] + csExperts, GetDllValue(Compiler),
        GetDllName(Compiler)) then
        S := S + #13#10 + ' - ' + csCompilerNames[Compiler];
    end;
  end;

  if not ParamNoMsg then
  begin
    if S <> csInstallSucc then
    begin
      if not ParamInstall then
        S := S + #13#10#13#10 + csInstallSuccEnd;
    end
    else
      S := csInstallFail;
    MessageBox(0, PChar(S), PChar(csHintStr), MB_OK + MB_ICONINFORMATION);
  end;
end;

// 反安装专家
procedure UnInstallWizards;
var
  s: string;
  Compiler: TCompilerName;
begin
  s := csUnInstallSucc;
  for Compiler := Low(Compiler) to High(Compiler) do
    if RegValueExists(csRegPaths[Compiler] + csExperts, GetDllValue(Compiler)) and
      RegDeleteValue(csRegPaths[Compiler] + csExperts, GetDllValue(Compiler)) then
      s := s + #13#10 + ' - ' + csCompilerNames[Compiler];

  if not ParamNoMsg then
  begin
    if s <> csUnInstallSucc then
    begin
      if not ParamUnInstall then
        s := s + #13#10#13#10 + csUnInstallSuccEnd;
    end
    else
      s := csUnInstallFail;
    MessageBox(0, PChar(s), PChar(csHintStr), MB_OK + MB_ICONWARNING);
  end;
end;

// 翻译字符串
procedure TranslateStrings;
begin
  TranslateStr(csHintStr, 'csHintStr');
  TranslateStr(csInstallSucc, 'csInstallSucc');
  TranslateStr(csInstallSuccEnd, 'csInstallSuccEnd');
  TranslateStr(csUnInstallSucc, 'csUnInstallSucc');
  TranslateStr(csUnInstallSuccEnd, 'csUnInstallSuccEnd');
  TranslateStr(csInstallFail, 'csInstallFail');
  TranslateStr(csUnInstallFail, 'csUnInstallFail');
  TranslateStr(csSetupCmdHelp, 'csSetupCmdHelp');
end;

// 初始化语言
procedure InitLanguageManager;
var
  LangID: DWORD;
  I: Integer;
begin
  CreateLanguageManager;
  with CnLanguageManager do
  begin
    LanguageStorage := TCnHashLangFileStorage.Create(CnLanguageManager);
    with TCnHashLangFileStorage(LanguageStorage) do
    begin
      StorageMode := smByDirectory;
      FileName := csLangFile;
      LanguagePath := _CnExtractFilePath(ParamStr(0)) + csLangDir;
    end;
  end;

  LangID := GetWizardsLanguageID;
  
  for I := 0 to CnLanguageManager.LanguageStorage.LanguageCount - 1 do
  begin
    if CnLanguageManager.LanguageStorage.Languages[I].LanguageID = LangID then
    begin
      CnLanguageManager.CurrentLanguageIndex := I;
      TranslateStrings;
      Break;
    end;
  end;
end;

begin
  InitLanguageManager;

  ParamInstall := FindCmdLineSwitch('Install', ['-', '/'], True) or
    FindCmdLineSwitch('i', ['-', '/'], True);
  ParamUnInstall := FindCmdLineSwitch('Uninstall', ['-', '/'], True) or
    FindCmdLineSwitch('u', ['-', '/'], True);
  ParamNoMsg := FindCmdLineSwitch('NoMsg', ['-', '/'], True) or
    FindCmdLineSwitch('n', ['-', '/'], True);
  ParamCmdHelp :=  FindCmdLineSwitch('?', ['-', '/'], True)
    or FindCmdLineSwitch('h', ['-', '/'], True)
    or FindCmdLineSwitch('help', ['-', '/'], True) ;

  if ParamCmdHelp then
    InfoDlg(csSetupCmdHelp)
  else if IsInstalled and not ParamInstall or ParamUnInstall then
    UnInstallWizards
  else
    InstallWizards;
end.
