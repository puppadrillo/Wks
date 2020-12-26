library WksIsapiProject;

{$R 'Wks.res' 'Wks.rc'}

uses
  Winapi.ActiveX,
  System.Win.ComObj,
  Web.WebBroker,
  Web.Win.ISAPIApp,
  Web.Win.ISAPIThreadPool,
  WksAllUnit in 'WksAllUnit.pas',
  WksIsapiMainWebModuleUnit in 'WksIsapiMainWebModuleUnit.pas' {WebModule1: TWebModule};

{$R *.res}

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
