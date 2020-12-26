program WksWsstUtilProject;

{$R 'Wks.res' 'Wks.rc'}

uses
  Vcl.Forms,
  WksWsstUtilMainFormUnit in 'WksWsstUtilMainFormUnit.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
