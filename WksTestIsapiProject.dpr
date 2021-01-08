library WksTestIsapiProject;

{$R 'Wks.res' 'Wks.rc'}

uses
  Winapi.Windows,
  Winapi.ActiveX,
  Winapi.Isapi2, // apiver2
  System.Classes,
  System.SysUtils,
  System.Win.ComObj,
  Web.WebBroker,
  Web.Win.ISAPIApp,
  Web.Win.ISAPIThreadPool,
  FireDAC.Comp.Client, // fdmanager
  WksAllUnit in 'WksAllUnit.pas',
  WksTestIsapiMainWebModuleUnit in 'WksTestIsapiMainWebModuleUnit.pas' {WebModule1: TWebModule};

{$R *.res}

{$REGION 'Export'}
function GetExtensionVersion(var Ver: THSE_VERSION_INFO): bool; stdcall;
begin

  {$REGION 'Help'}
  (*
  best places to initialize/create globals objects rather than
  in Initialization/Finalization sections of the webmodule
  this main dll's part is very restrictive (http://msdn.microsoft.com/en-us/library/ms678543%28v=vs.85%29.aspx)
  - don't call CoInitialize
  - don't call COM functions
  - don't load any dll
  *)
  {$ENDREGION}

  Result := Web.Win.ISAPIApp.GetExtensionVersion(Ver);

  ods('DLL GETEXTENSIONVERSION', 'Global resource create Begin');
  try
    try
      FDManager.ConnectionDefFileName := pat.Head(byn.FileSpec, 3) + '\WksFDConnection_' + net.Host + '.ini'; // OutputDebugString(PWideChar(FDManager.ConnectionDefFileName));
      FDManager.LoadConnectionDefFile;
      FDManager.Active := true;
    except
      on e: Exception do
        log('DLL GETEXTENSIONVERSION', 'EXCEPTION: ' + e.Message);
    end;
    ods('DLL GETEXTENSIONVERSION', 'FDManager private pooled connection created (' + FDManager.ConnectionDefFileName + ')');
  except
    on e: Exception do
      ods('DLL GETEXTENSIONVERSION', 'EXCEPTION: ' + e.Message);
  end;
  ods('DLL GETEXTENSIONVERSION', 'Global resource create End');
end;

function TerminateExtension(dwFlags: dword): bool; stdcall;
begin

  {$REGION 'Help'}
  (*
  as per Microsoft "TerminateExtension" provides a place to put
  code that cleans up threads or de-allocate global resources
  *)
  {$ENDREGION}

  ods('DLL TERMINATEEXTENSION', 'Global resource free Begin');
  try
    FDManager.Close; // close and destroy all pooled physical connections
    ods('DLL TERMINATEEXTENSION', 'FDManager private pooled connection destroyed');
  except
    on e: Exception do
      ods('DLL TERMINATEEXTENSION', 'EXCEPTION: ' + e.Message);
  end;
  ods('DLL TERMINATEEXTENSION', 'Global resource free End');

  Result := Web.Win.ISAPIThreadPool.TerminateExtension(dwFlags);
end;
{$ENDREGION}

exports
  GetExtensionVersion,
  HttpExtensionProc,
  TerminateExtension;

begin
  ReportMemoryLeaksOnShutdown := true;
  CoInitFlags := COINIT_MULTITHREADED;
  IsMultiThread := true; // already present in ...
//TISAPIApplication(Application).OnTerminate := TerminateLast; // very last finalize
//Application.MaxConnections := 5; // connectionsactivemax 32 by default
  NumberOfThreads := Application.MaxConnections;
  Application.CacheConnections := true; //not IsDebuggerPresent; // default is true, false will create/destroy isapidll with each request, do not use it in production
  Application.Initialize;
  Application.WebModuleClass := WebModuleClass;
  Application.Run;
end.
