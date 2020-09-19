unit testyandexx_synapse;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry
  ;

type

  TYandexXTest= class(TTestCase)
  published
    procedure YandexX;
  end;

implementation

uses
  sqimain_synapse
  ;

procedure TYandexXTest.YandexX;
begin
  AssertEquals(0, sqi('renat.su'));
end;



initialization

  RegisterTest(TYandexXTest);

end.

