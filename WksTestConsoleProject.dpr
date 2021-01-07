program WksTestConsoleProject;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  WksThreadUtilsUnit in 'WksThreadUtilsUnit.pas';

begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
    Writeln('WKS Test Console Application');
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.