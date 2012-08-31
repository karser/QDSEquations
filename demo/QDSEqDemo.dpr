program QDSEqDemo;

uses
  Forms,
  main in 'main.pas' {frmMain},
  UsefulUtils in 'UsefulUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'QDS Eqations';
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
