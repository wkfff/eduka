{-------------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: SynExportHTML.pas, released 2000-04-16.

The Original Code is partly based on the mwHTMLExport.pas file from the
mwEdit component suite by Martin Waldenburg and other developers, the Initial
Author of this file is Michael Hieke.
Portions created by Michael Hieke are Copyright 2000 Michael Hieke.
Portions created by James D. Jacobson are Copyright 1999 Martin Waldenburg.
All Rights Reserved.

Contributors to the SynEdit project are listed in the Contributors.txt file.

Alternatively, the contents of this file may be used under the terms of the
GNU General Public License Version 2 or later (the "GPL"), in which case
the provisions of the GPL are applicable instead of those above.
If you wish to allow use of your version of this file only under the terms
of the GPL and not to allow others to use your version of this file
under the MPL, indicate your decision by deleting the provisions above and
replace them with the notice and other provisions required by the GPL.
If you do not delete the provisions above, a recipient may use your version
of this file under either the MPL or the GPL.

$Id: SynExportHTML.pas,v 1.7 2001/11/09 07:48:57 plpolak Exp $
     Modified by Ciobanu Alexander 2004

You may retrieve the latest version of this file at the SynEdit home page,
located at http://SynEdit.SourceForge.net

Known Issues:
-------------------------------------------------------------------------------}

unit SynEdukaExportHTML;

{$I SynEdit.inc}

interface

uses
  Classes,
{$IFDEF SYN_CLX}
  Qt,
  QGraphics,
{$ELSE}
  Windows,
  Graphics,
{$ENDIF}
  SynEditExport;

type
  THTMLFontSize = (fs01, fs02, fs03, fs04, fs05, fs06, fs07, fsDefault);        //eb 2000-10-12

  TSynEdukaExporterHTML = class(TSynCustomExporter)
  private
 //   fOpened  : Integer;
    fFontSize: THTMLFontSize;
    function ColorToHTML(AColor: TColor): string;
  protected
    fCreateHTMLFragment: boolean;
    procedure FormatAfterLastAttribute; override;
    procedure FormatAttributeDone(BackgroundChanged, ForegroundChanged: boolean;
      FontStylesChanged: TFontStyles); override;
    procedure FormatAttributeInit(BackgroundChanged, ForegroundChanged: boolean;
      FontStylesChanged: TFontStyles); override;
{begin}                                                                         //mh 2000-10-10
    procedure FormatBeforeFirstAttribute(BackgroundChanged,
      ForegroundChanged: boolean; FontStylesChanged: TFontStyles); override;
{end}                                                                           //mh 2000-10-10
    procedure FormatNewLine; override;
    function GetFooter: string; override;
    function GetFormatName: string; override;
    function GetHeader: string; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Color;
    property CreateHTMLFragment: boolean read fCreateHTMLFragment
      write fCreateHTMLFragment default FALSE;
    property DefaultFilter;
    property Font;
    property Highlighter;
    property HTMLFontSize: THTMLFontSize read fFontSize write fFontSize;        //eb 2000-10-12
    property Title;
    property UseBackground;
  end;

implementation

uses
  SysUtils,
  SynEditStrConst;

{ TSynExporterHTML }

constructor TSynEdukaExporterHTML.Create(AOwner: TComponent);
const
  CF_HTML = 'HTML Format';
begin
  inherited Create(AOwner);
  {**************}
  {$IFNDEF SYN_CLX}
  fClipboardFormat := RegisterClipboardFormat(CF_HTML);
  {$ENDIF}
  fFontSize := fs03;
  fDefaultFilter := SYNS_FilterHTML;

  // setup array of chars to be replaced

  fReplaceReserved['&'] := '&amp;';
  fReplaceReserved['<'] := '&lt;';
  fReplaceReserved['>'] := '&gt;';
  fReplaceReserved['"'] := '&quot;';

 // fOpened := 0;
end;

function TSynEdukaExporterHTML.ColorToHTML(AColor: TColor): string;
var
  RGBColor: longint;
  RGBValue: byte;
const
  Digits: array[0..15] of char = '0123456789ABCDEF';
begin
  RGBColor := ColorToRGB(AColor);
  Result := '"#000000"';
 {****************}
{$IFNDEF SYN_CLX}
  RGBValue := GetRValue(RGBColor);
{$ENDIF}
  if RGBValue > 0 then begin
    Result[3] := Digits[RGBValue shr  4];
    Result[4] := Digits[RGBValue and 15];
  end;
 {****************}
{$IFNDEF SYN_CLX}
  RGBValue := GetGValue(RGBColor);
{$ENDIF}
  if RGBValue > 0 then begin
    Result[5] := Digits[RGBValue shr  4];
    Result[6] := Digits[RGBValue and 15];
  end;
 {****************}
{$IFNDEF SYN_CLX}
  RGBValue := GetBValue(RGBColor);
{$ENDIF}
  if RGBValue > 0 then begin
    Result[7] := Digits[RGBValue shr  4];
    Result[8] := Digits[RGBValue and 15];
  end;
end;

procedure TSynEdukaExporterHTML.FormatAfterLastAttribute;
begin
  if fsStrikeout in fLastStyle then
    AddData('</strike>');
  if fsUnderline in fLastStyle then
    AddData('</u>');
  if fsItalic in fLastStyle then
    AddData('</i>');
  if fsBold in fLastStyle then
    AddData('</b>');
  if fLastFG <> fFont.Color then
//    begin
    AddData('</font>');
//    Dec( fOpened )
//    end;
  if UseBackground and (fLastBG <> fBackgroundColor) then
    AddData('</span>');
end;

procedure TSynEdukaExporterHTML.FormatAttributeDone(BackgroundChanged,
  ForegroundChanged: boolean; FontStylesChanged: TFontStyles);
begin
  if BackgroundChanged or ForegroundChanged or (FontStylesChanged <> []) then
  begin
    if fsStrikeout in fLastStyle then
      AddData('</strike>');
    if fsUnderline in fLastStyle then
      AddData('</u>');
    if fsItalic in fLastStyle then
      AddData('</i>');
    if fsBold in fLastStyle then
      AddData('</b>');
  end;
  if (BackgroundChanged or ForegroundChanged) and (fLastFG <> fFont.Color) then //mh 2000-10-10
//    begin
    AddData('</font>');
//    Dec( fOpened );
//    end;
  if BackgroundChanged then
    AddData('</span>');
end;

procedure TSynEdukaExporterHTML.FormatAttributeInit(BackgroundChanged,
  ForegroundChanged: boolean; FontStylesChanged: TFontStyles);
begin
  if BackgroundChanged then
    AddData('<span style="background-color: ' +
      Copy(ColorToHtml(fLastBG), 2, 9) + '>');
  if (BackgroundChanged or ForegroundChanged) and (fLastFG <> fFont.Color) then
  //  begin
    AddData('<font color=' + ColorToHtml(fLastFG) + '>');
 //   Inc( fOpened );
 //   end;
  if BackgroundChanged or ForegroundChanged or (FontStylesChanged <> []) then
  begin
    if fsBold in fLastStyle then
      AddData('<b>');
    if fsItalic in fLastStyle then
      AddData('<i>');
    if fsUnderline in fLastStyle then
      AddData('<u>');
    if fsStrikeout in fLastStyle then
      AddData('<strike>');
  end;
end;

{begin}                                                                         //mh 2000-10-10
procedure TSynEdukaExporterHTML.FormatBeforeFirstAttribute(BackgroundChanged,
  ForegroundChanged: boolean; FontStylesChanged: TFontStyles);
begin
  if BackgroundChanged then
    AddData('<span style="background-color: ' +
      Copy(ColorToHtml(fLastBG), 2, 9) + '>');

//  begin
  AddData('<font color=' + ColorToHtml(fLastFG) + '>');
//  Inc( fOpened );
//  end;

  if FontStylesChanged <> [] then begin
    if fsBold in fLastStyle then
      AddData('<b>');
    if fsItalic in fLastStyle then
      AddData('<i>');
    if fsUnderline in fLastStyle then
      AddData('<u>');
    if fsStrikeout in fLastStyle then
      AddData('<strike>');
  end;
end;
{end}                                                                           //mh 2000-10-10

procedure TSynEdukaExporterHTML.FormatNewLine;
begin
  AddNewLine;
end;

function TSynEdukaExporterHTML.GetFooter: string;
begin
  Result := '';
  if fExportAsText then
   begin
    Result := Result + '</font>';
    Result := Result + '</font>'#13#10'</code></pre>'#13#10;
   end;

  if not fCreateHTMLFragment then
    Result := Result + '</body>'#13#10'</html>';
end;

function TSynEdukaExporterHTML.GetFormatName: string;
begin
  Result := SYNS_ExporterFormatHTML;
end;

function TSynEdukaExporterHTML.GetHeader: string;
const
  DescriptionSize = 105;
  HeaderSize = 47;
  FooterSize1 = 58;
  FooterSize2 = 24;
  NativeHeader = 'Version:0.9'#13#10 +
                 'StartHTML:%.10d'#13#10 +
                 'EndHTML:%.10d'#13#10 +
                 'StartFragment:%.10d'#13#10 +
                 'EndFragment:%.10d'#13#10;

  HTMLAsTextHeader = '<html>'#13#10 +
                     '<head>'#13#10 +
                     '<title>%s</title>'#13#10 +
                     '</head>'#13#10 +
                     '<!-- Generated by SynEdit HTML exporter -->'#13#10 +
                     '<body text=%s bgcolor=%s>'#13#10;
var
  sFontSize: string;                                                            //eb 2000-10-12
begin
  Result := '';
  if fExportAsText then begin
    if not fCreateHTMLFragment then
      Result := Format(HTMLAsTextHeader, [Title, ColorToHtml(fFont.Color),
        ColorToHTML(fBackgroundColor)]);
{begin}                                                                         //eb 2000-10-12
    if fFontSize <> fsDefault then
      sFontSize := Format(' size=%d', [1 + Ord(fFontSize)])
    else
      sFontSize := '';
    Result := Result + Format('<pre>'#13#10'<code>'#13#10'<font %s face="%s">',
      [sFontSize, fFont.Name]);
{end}                                                                           //eb 2000-10-12
  end else begin
    // Described in http://msdn.microsoft.com/library/sdkdoc/htmlclip/htmlclipboard.htm
    Result := Format(NativeHeader, [DescriptionSize,
      DescriptionSize + HeaderSize + GetBufferSize + FooterSize1,
      DescriptionSize + HeaderSize,
      DescriptionSize + HeaderSize + GetBufferSize + FooterSize2]);
    if not fCreateHTMLFragment then
      Result := Result + '<html>'#13#10'<head></head>'#13#10'<body>';
    Result := Result + '<!--StartFragment--><pre><code>';
    AddData('</code></pre><!--EndFragment-->');
  end;
end;

end.

