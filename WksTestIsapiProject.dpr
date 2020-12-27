library WksTestIsapiProject;

{$R 'Wks.res' 'Wks.rc'}

uses
  Winapi.Windows,
  Winapi.ActiveX,
  System.SysUtils,
  System.Win.ComObj,
  Web.WebBroker,
  Web.Win.ISAPIApp,
  Web.Win.ISAPIThreadPool,
  WksAllUnit in 'WksAllUnit.pas',
  WksTestIsapiMainWebModuleUnit in 'WksTestIsapiMainWebModuleUnit.pas' {WebModule1: TWebModule};

{$R *.res}

function TerminateExtension(dwFlags: dword): bool; stdcall;
begin
  // as per Microsoft "TerminateExtension" provides a place to put
  // code that cleans up threads or de-allocate global resources

  ods('TERMINATEEXTENSION', 'Begin');
  try
    lgt.Free;
    ods('TERMINATEEXTENSION', 'TThreadFileLog free');
  except
    on e: Exception do
      ods('TERMINATEEXTENSION', 'EXCEPTION: ' + e.Message);
  end;
  ods('TERMINATEEXTENSION', 'End');

  Result := Web.Win.ISAPIThreadPool.TerminateExtension(dwFlags);
end;

exports
  GetExtensionVersion,
  HttpExtensionProc,
  TerminateExtension;

begin
  CoInitFlags := COINIT_MULTITHREADED;
  Application.Initialize;
  Application.WebModuleClass := WebModuleClass;
  Application.Run;
end.
