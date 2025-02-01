unit yandexsqi;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, basehttpclient
  ;

type

  { TYandexSQIParser }

  TYandexSQIParser = class
  private
    FDomainName: String;
    FHTTP: TBaseHTTPClient;
    FResultValue: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Execute;
    property DomainName: String read FDomainName write FDomainName;
    property ResultValue: Integer read FResultValue write FResultValue;
  end;


function sqi(const aDomainName: String): Integer;
function PNGToSQIValue(aStream: TStream): Integer;

const
  rvUnknown = -1;

implementation

uses
  FPReadPNG, fpimage, FPImgCanv, Graphics, StrUtils
  ;

const
  xFrom=30;
  yFrom=10;
  xWidth=56;
  yHeight=11;

procedure similar_str(const txt1,txt2: PAnsiChar; const len1, len2: Integer; var Pos1, Pos2, Max: Integer);
var
  l: integer;
  end1, end2, p, q: PAnsiChar;
begin
  end1 := txt1 + len1;
  end2 := txt2 + len2;

  max := 0;

  p := txt1;
  q := txt2;
  while p < end1 do
  begin
     Inc(p);
     while q < end2 do
     begin
        Inc(q);

        l := 0;
        while (p + l < end1) and (q + l < end2) and (p[l] = q[l]) do
           inc(l);

        if l > max then
        begin
            max  := l;
            pos1 := p - txt1;
            pos2 := q - txt2;
        end;
     end;
  end;
end;

function similar_char(const txt1, txt2: PAnsiChar; const len1, len2: Integer): Integer;
var
  pos1, pos2, max: Integer;
begin
  pos1:=0;
  pos2:=0;
  max:=0;
  similar_str(txt1, txt2, len1, len2, pos1, pos2, max);

  Result := max;
  if Result > 0 then
  begin
    if (Pos1 > 0) and (Pos2 > 0) then
        Inc(Result, similar_char(txt1, txt2, pos1, pos2));

    if (Pos1 + Max < Len1) and (Pos2 + Max < Len2) then
    begin
        Inc(Result, similar_char(txt1 + Pos1 + max, txt2 + Pos2 + max,
                                 len1 - pos1 - max, len2 - pos2 - max));
    end;
  end;
end;

// аналог PHP функции similar_text http://www.freepascal.ru/forum/viewtopic.php?f=38&t=6904
function similar_text(const txt1, txt2: AnsiString; var aPercent: Double): Integer;
   var
   len1, len2: integer;
begin
   len1 := length(txt1);
   len2 := length(txt2);

   if len1 + len2 > 0 then begin
      Result := similar_char(@txt1[1], @txt2[1], len1, len2);
      aPercent := (Result * 200) / (len1 + len2);
   end else
   begin
      Result   := 0;
      aPercent := 0;
   end;
end;

function PNGToCanvas(aStream: TStream; aCanvas: TFPImageCanvas): Boolean;
var
  aImage: TFPMemoryImage;
  aCanvasSrc: TFPImageCanvas;
  aReader: TFPReaderPNG;
begin
  aImage := TFPMemoryImage.Create(0, 0);
  aCanvasSrc :=TFPImageCanvas.create(aImage);
  aReader := TFPReaderPNG.Create;
  try
   aStream.Position:=0;
   aReader.ImageRead(aStream, aImage);
   if aImage.Width<>88 then
     Exit(False);
   aCanvas.CopyRect(0, 0, aCanvasSrc, Rect(xFrom, yFrom, xFrom+xWidth-1, yFrom+yHeight-1));
   Result:=True;
  finally
   aReader.Free;
   aCanvasSrc.Free;
   aImage.Free;
  end;
end;

function sqi(const aDomainName: String): Integer;
var
  aParser: TYandexSQIParser;
begin
  aParser:=TYandexSQIParser.Create;
  try
    aParser.DomainName:=aDomainName;
    aParser.Execute;
    Result:=aParser.ResultValue;
  finally
    aParser.Free;
  end;
end;

function PNGToSQIValue(aStream: TStream): Integer;
var
  i, j, aLen, aNum: Integer;
  aImageOut: TFPMemoryImage;
  aCanvasOut: TFPImageCanvas;
  aColor: TColor;
  s, r, aSym, aSQI: String;
  aRaws: TStringList;
  p: Double = 0;
const
  Reference: array[0..9] of String[88] = (
          '..xxxxxx....xxxxxxxxx.xxxxxxxxxxxxx.......xxxx.......xxxxx.....xxxxxxxxxxxxxx.xxxxxxxx..',
          '..xx........xxx.......xxx........xxxxxxxxxxxxxxxxxxxxxx',
          '.........xxxx......xxxxx......xxxxx.....xxxxxx...xxxx.xxxx.xxxx..xxxxxxxx...x.xxxx.....x',
          'x........xxxx.......xxxx...x...xxxx...x...xxxx..xxx..xxxxxxxxxxxxxxxxxxxxxxxx......xxxx.',
          '......xx.......xxxx......xxxxx....xxxx..x...xxxx...x...xxxxxxxxxxxxxxxxxxxxxx.......x...',
          '..........xxxxxxx...xxxxxxxx...xxx...xx...xxx...xx...xxx...xxxxxxxx...xxxxxxx.....xxxx..',
          '....xxxxx....xxxxxxxxx.xxxxxx.xxxxxxxxx...xxxxx.xx...xxxx..xx...xxx...xxxxxxxx....xxxxx.',
          'x..........x.........xx.......xxxx....xxxxxxx..xxxxxx..xxxxxxx....xxxxx......xxx........',
          '......xxxx.xxxxxxxxxxxxxxxxxxxxxxxx..xxx..xxxx..xxx..xxxxxxxxx..xxxxxxxxxxxxx.xxxx.xxxx.',
          '.xxxxx.....xxxxxxx...xxxx.xxx...xxx...xx..xxxx...xx.xxxxxx..xxxxx.xxxxxxxxx...xxxxxxx...'
      );
begin
  aImageOut := TFPMemoryImage.Create(xWidth, yHeight);
  aCanvasOut:= TFPImageCanvas.create(aImageOut);
  aRaws:=TStringList.Create;
  try
    if not PNGToCanvas(aStream, aCanvasOut) then
      Exit(0);
    //aImageOut.SaveToFile('~temp.png');
    for i:=0 to xWidth-1 do
    begin
      s:=EmptyStr;
      for j:=0 to yHeight-1 do
      begin
        aColor:=FPColorToTColor(aImageOut.Colors[i, j]);
        s+=IfThen($dadada=Integer(aColor), '.', 'x');
      end;
      if S<>'...........' then
        aRaws.Add(S);
    end;
    aSQI:=EmptyStr;
    aLen:=0;
    aSym:=EmptyStr;
    for r in aRaws do
    begin
      aLen+=11;
      aSym+=r;
      if aLen=88 then
      begin
        for aNum:=Low(Reference) to High(Reference) do
          if similar_text(Reference[aNum], aSym, p) > 80 then
          begin
            aSQI+=aNum.ToString;
            Break;
          end;
        aSym:=EmptyStr;
        aLen:=0;
      end
      else
        if aLen=55 then
          if similar_text(Reference[1], aSym, p)>50 then
          begin
            aSQI+='1';
            aSym:=EmptyStr;
            aLen:=0;
          end;
    end;
    Result:=StrToIntDef(aSQI, 0);
  finally
    aRaws.Free;
    aCanvasOut.Free;
    aImageOut.Free;
  end;
end;

{ TYandexSQIParser }

constructor TYandexSQIParser.Create;
begin
  FHTTP:=TBaseClientClass.GetClientClass.Create(nil);
  FHTTP.IOTimeout:=2000;
end;

destructor TYandexSQIParser.Destroy;
begin
  FHTTP.Free;
  inherited Destroy;
end;

procedure TYandexSQIParser.Execute;
var
  aStream: TMemoryStream;
begin
  FResultValue:=rvUnknown;
  aStream:=TMemoryStream.Create;
  try
    FHTTP.Get(Format('https://yandex.ru/cycounter?%s&theme=light&lang=ru', [FDomainName]), aStream);
//    {$IFDEF DEBUG}aStream.Position:=0; aStream.SaveToFile(Format('%s.png', [FDomainName]));  {$ENDIF} // Debug... to-do: delete
    FResultValue:=PNGToSQIValue(aStream);
  finally
    aStream.Free;
  end;
end;

end.

