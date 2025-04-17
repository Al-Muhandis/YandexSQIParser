unit testyandexsqi;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry
  ;

type

  TYandexSQITest= class(TTestCase)
  published
    procedure YandexX;
  end;

implementation

uses
  yandexsqi
  ;

procedure TYandexSQITest.YandexX;
begin     
  sqi('freepascal.org');
  sqi('renat.su');
  sqi('google.com');
end;



initialization

  RegisterTest(TYandexSQITest);

end.

