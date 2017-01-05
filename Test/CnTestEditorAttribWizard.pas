{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2017 CnPack 开发组                       }
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

unit CnTestEditorAttribWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：简单的专家演示单元
* 单元作者：CnPack 开发组
* 备    注：该单元可获取并弹出代码编辑器当前光标所在的行以及字符属性的内容
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 单元标识：$Id$
* 修改记录：2016.04.25 V1.1
*               修改成子菜单专家以集成另一个测试用例
*           2009.01.07 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnCommon, CnWizClasses, CnWizUtils, CnWizConsts,
  CnEditControlWrapper;

type

//==============================================================================
// 编辑器属性获取子菜单专家
//==============================================================================

{ TCnTestEditorAttribWizard }

  TCnTestEditorAttribWizard = class(TCnSubMenuWizard)
  private
    FIdAttrib: Integer;
    FIdLine: Integer;
    procedure TestAttributeAtCursor;
    procedure TestAttributeLine;
  protected
    function GetHasConfig: Boolean; override;
  public
    function GetState: TWizardState; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;

    procedure AcquireSubActions; override;
    procedure SubActionExecute(Index: Integer); override;
  end;

implementation

uses
  CnDebug;

const
  SCnAttribCommand = 'CnAttribCommand';
  SCnLineAttribCommand = 'CnLineAttribCommand';
  SCnAttribCaption = 'Show Attribute at Cursor';
  SCnLineAttribCaption = 'Show Attribute in Whole Line';

//==============================================================================
// 编辑器属性获取子菜单专家
//==============================================================================

{ TCnTestEditorAttribWizard }

procedure TCnTestEditorAttribWizard.AcquireSubActions;
begin
  FIdAttrib := RegisterASubAction(SCnAttribCommand, SCnAttribCaption);
  FIdLine := RegisterASubAction(SCnLineAttribCommand, SCnLineAttribCaption);
end;

procedure TCnTestEditorAttribWizard.Config;
begin

end;

procedure TCnTestEditorAttribWizard.TestAttributeAtCursor;
var
  EditPos: TOTAEditPos;
  EditControl: TControl;
  EditView: IOTAEditView;
  LineFlag, Element: Integer;
  S, T: string;
  Block: IOTAEditBlock;
begin
  EditControl := CnOtaGetCurrentEditControl;
  EditView := CnOtaGetTopMostEditView;

  Block := EditView.Block;
  S := Format('Edit Block %8.8x. ', [Integer(Block)]);
  if Block <> nil then
  begin
    if Block.IsValid then
      S := S + 'Is Valid.'
    else
      S := S + 'NOT Valid.';
  end;

  EditPos := EditView.CursorPos;
  EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False, Element, LineFlag);

  S := S + #13#10 +Format('EditPos Line %d, Col %d. LineFlag %d. Element: %d, ',
    [EditPos.Line, EditPos.Col, LineFlag, Element]);
  case Element of
    0:  T := 'atWhiteSpace  ';
    1:  T := 'atComment     ';
    2:  T := 'atReservedWord';
    3:  T := 'atIdentifier  ';
    4:  T := 'atSymbol      ';
    5:  T := 'atString      ';
    6:  T := 'atNumber      ';
    7:  T := 'atFloat       ';
    8:  T := 'atOctal       ';
    9:  T := 'atHex         ';
    10: T := 'atCharacter   ';
    11: T := 'atPreproc     ';
    12: T := 'atIllegal     ';
    13: T := 'atAssembler   ';
    14: T := 'SyntaxOff     ';
    15: T := 'MarkedBlock   ';
    16: T := 'SearchMatch   ';
  else
    T := 'Unknown';
  end;
  ShowMessage(S + T);

  if EditPos.Col > 1 then
    Dec(EditPos.Col);

  EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False, Element, LineFlag);

  S := Format('EditPos Line %d, Col %d. LineFlag %d. Element: %d, ',
    [EditPos.Line, EditPos.Col, LineFlag, Element]);
  case Element of
    0:  T := 'atWhiteSpace  ';
    1:  T := 'atComment     ';
    2:  T := 'atReservedWord';
    3:  T := 'atIdentifier  ';
    4:  T := 'atSymbol      ';
    5:  T := 'atString      ';
    6:  T := 'atNumber      ';
    7:  T := 'atFloat       ';
    8:  T := 'atOctal       ';
    9:  T := 'atHex         ';
    10: T := 'atCharacter   ';
    11: T := 'atPreproc     ';
    12: T := 'atIllegal     ';
    13: T := 'atAssembler   ';
    14: T := 'SyntaxOff     ';
    15: T := 'MarkedBlock   ';
    16: T := 'SearchMatch   ';
  else
    T := 'Unknown';
  end;
  ShowMessage(S + T);
end;

function TCnTestEditorAttribWizard.GetCaption: string;
begin
  Result := 'Test Editor Attribute';
end;

function TCnTestEditorAttribWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestEditorAttribWizard.GetHasConfig: Boolean;
begin
  Result := False;
end;

function TCnTestEditorAttribWizard.GetHint: string;
begin
  Result := 'Show Attributes in Current Editor';
end;

function TCnTestEditorAttribWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestEditorAttribWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Editor Attribute Menu Wizard';
  Author := 'CnPack Team';
  Email := 'liuxiao@cnpack.org';
  Comment := 'Test Editor Attribute Menu Wizard';
end;

procedure TCnTestEditorAttribWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestEditorAttribWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestEditorAttribWizard.SubActionExecute(Index: Integer);
begin
  if Index = FIdAttrib then
    TestAttributeAtCursor
  else if Index = FIdLine then
    TestAttributeLine;
end;

procedure TCnTestEditorAttribWizard.TestAttributeLine;
var
  EdPos: TOTAEditPos;
  View: IOTAEditView;
  Line: AnsiString;
  ULine: string;
{$IFDEF UNICODE}
  ALine: AnsiString;
  UCol: Integer;
{$ENDIF}
  EditControl: TControl;
  I, Element, LineFlag: Integer;
begin
  View := CnOtaGetTopMostEditView;
  if View = nil then
    Exit;

  EditControl := EditControlWrapper.GetEditControl(View);
  if EditControl = nil then
    Exit;

  EdPos := View.CursorPos;

  ULine := EditControlWrapper.GetTextAtLine(EditControl, EdPos.Line);
  CnDebugger.LogRawString(ULine);
  Line := AnsiString(ULine);
  CnDebugger.LogRawAnsiString(Line);

  CnDebugger.LogInteger(EdPos.Col, 'Before Possible UTF8 Convertion CursorPos Col');
{$IFDEF UNICODE}
  // Unicode 环境下 GetTextAtLine 返回的是 Unicode，
  // GetAttributeAtPos 要求的是 UTF8，
  // 但 CursorPos 对应 Ansi，所以需要复杂的转换：
  // 先把 Unicode 转换成 Ansi，用 Col 截断，转回 Unicode，其长度就是 Col在 Unicode中的位置，
  // 再把整行 Unicode 用新 Col 截断，再转换成 Ansi-Utf8，其长度就是 UTF8 的 Col

  ALine := Copy(Line, 1, EdPos.Col - 1);            // 截断
  CnDebugger.LogRawAnsiString(ALine);

  UCol := Length(string(ALine)) + 1;                // 转回 Unicode
  CnDebugger.LogInteger(UCol, 'Temp Unicode Col');

  ULine := Copy(ULine, 1, UCol - 1);                // 重新截断
  CnDebugger.LogRawString(ULine);

  ALine := CnAnsiToUtf8(AnsiString(ULine));         // 转成 Ansi-Utf8
  CnDebugger.LogRawAnsiString(ALine);

  EdPos.Col := Length(CnAnsiToUtf8(ALine)) + 1;     // 取长度

  Line := CnAnsiToUtf8(Line);                       // 最后整行转成 Utf8，以让下面的处理一致
{$ENDIF}

  CnDebugger.LogInteger(EdPos.Col, 'After Possible UTF8 Conversion. CursorPos Col');

  if EdPos.Col > Length(Line) then
    Exit;

  if Line <> '' then
  begin
    for I := 1 to Length(Line) do
    begin
      if EdPos.Col = I then
        CnDebugger.LogInteger(I, 'Here is the Cursor Position.');
      EditControlWrapper.GetAttributeAtPos(EditControl, OTAEditPos(I, EdPos.Line),
        False, Element, LineFlag);
      case Element of
        atWhiteSpace:
          CnDebugger.LogAnsiChar(Line[I], IntToStr(I) + ' WhiteSpace');
        atComment:
          CnDebugger.LogAnsiChar(Line[I], IntToStr(I) + ' Comment');
        atReservedWord:
          CnDebugger.LogAnsiChar(Line[I], IntToStr(I) + ' ReservedWord');
        atIdentifier:
          CnDebugger.LogAnsiChar(Line[I], IntToStr(I) + ' Identifier');
        atSymbol:
          CnDebugger.LogAnsiChar(Line[I], IntToStr(I) + ' Symbol');
        atString:
          CnDebugger.LogAnsiChar(Line[I], IntToStr(I) + ' String');
        atNumber:
          CnDebugger.LogAnsiChar(Line[I], IntToStr(I) + ' Number');
      else
        CnDebugger.LogAnsiChar(Line[I], IntToStr(I) + ' Unknown');
      end;
    end;
  end;
  ShowMessage('Information Sent to CnDebugViewer for Current Line.');
end;

initialization
  RegisterCnWizard(TCnTestEditorAttribWizard); // 注册专家

end.
