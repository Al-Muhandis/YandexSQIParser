program gui_synapse;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, GuiTestRunner, testyandexsqi, synapsehttpclientbroker
  ;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGuiTestRunner, TestRunner);
  Application.Run;
end.

