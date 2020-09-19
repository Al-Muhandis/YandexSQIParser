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
  AssertEquals(360, sqi('freepascal.org'));
  AssertEquals(0, sqi('renat.su'));
  AssertEquals(116000, sqi('google.com'));
end;



initialization

  RegisterTest(TYandexSQITest);

end.

