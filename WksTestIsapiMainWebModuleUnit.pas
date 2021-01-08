unit WksTestIsapiMainWebModuleUnit;

interface

{$REGION 'Note'}
{
  https://en.delphipraxis.net/topic/1632-isapi-dll-concurrent-requests
  https://en.delphipraxis.net/topic/1799-firebird-tfdconnection-and-concurrency
  https://mathiaspannier.wordpress.com/2016/07/17/how-to-properly-cleanupshutdown-a-delphi-isapi-which-uses-threads
  http://codeverge.com/embarcadero.delphi.general/tthread-in-delphi-dll-s-with-initi/1057724
  https://wiert.me/2019/10/03/how-to-properly-cleanup-shutdown-a-delphi-isapi-which-uses-threads-mathias-pannier-programmiert
  https://flylib.com/books/en/2.37.1/web_programming_with_webbroker_and_websnap.html
  https://stackoverflow.com/questions/26363747/getting-the-current-context-id-in-a-apache-hosted-delphi-created-isapi-dll
  https://en.delphipraxis.net/topic/1799-firebird-tfdconnection-and-concurrency

  I am trying to build a system that will handle concurrent DB requests efficiently, there's not a lot of load, but it should be able to handle more than 1 query concurrently.
  I am using FireBird v3.0.4 and Delphi 10.3.2 with the TFDConnection component.
  I am hosting the code in an ISAPI DLL that runs on IIS 7.5.
  This is the first time I'm writing an ISAPI dll with DB access and the threading model is not exactly clear to me.
  My original (perhaps flawed) assumption was that IIS will load additional DLLs in separate threads to handle concurrent http requests.
  In multithread application you must use separated connection per thread
  This is the first time I'm writing an ISAPI dll with DB access and the threading model is not exactly clear to me
}
{$ENDREGION}

{$REGION 'Use'}
uses
    System.SysUtils
  , System.Classes
  , System.Diagnostics
  , Web.HTTPApp
  , FireDAC.Comp.Client //, FireDAC.Stan.Def, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Phys
  , WksAllUnit
  ;
{$ENDREGION}

{$REGION 'Type'}
type
  TWebModule1 = class(TWebModule)
    procedure WebModuleCreate(Sender: TObject);
    procedure WebModuleDestroy(Sender: TObject);
    procedure WebModuleException(Sender: TObject; E: Exception; var Handled: Boolean);
    procedure WebModuleBeforeDispatch(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModuleAfterDispatch(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1DefaultHandlerAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
  private
    { Private declarations }
    FWat: TStopwatch;
    FIni: TIniCls;
    FRun: cardinal;
  public
    { Public declarations }
  end;
{$ENDREGION}

{$REGION 'Var'}
var
  WebModuleClass: TComponentClass = TWebModule1;
{$ENDREGION}

implementation

{$REGION 'Use'}
{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses
    Winapi.Windows
  , Web.WebBroker
  , Web.Win.ISAPIHTTP
  , FireDAC.Comp.DataSet
  ;
{$ENDREGION}

{$REGION 'Events'}
procedure TWebModule1.WebModuleCreate(Sender: TObject);
begin
try
  ods('WEBMODULE CREATE', 'Create');

  {$REGION 'WebModuleObjects'}
  //ods('WEBMODULE CREATE', 'Nothing done');
  FIni := TIniCls.Create;       ods('WEBMODULE CREATE', 'TIniCls created');
  {$ENDREGION}

except
  on e: Exception do ods('WEBMODULE CREATE', 'EXCEPTION: ' + e.Message);
end;
end;

procedure TWebModule1.WebModuleDestroy(Sender: TObject);
begin
try
  ods('WEBMODULE DESTROY', 'Destroy');

  {$REGION 'WebModuleObjects'}
  //ods('WEBMODULE DESTROY', 'Nothing done');
  FIni.Free;                    ods('WEBMODULE DESTROY', 'TIniCls free');
  {$ENDREGION}

except
  on e: Exception do ods('WEBMODULE DESTROY', 'EXCEPTION: ' + e.Message);
end;
end;

procedure TWebModule1.WebModuleException(Sender: TObject; E: Exception; var Handled: Boolean);
begin
  ods('WEBMODULE EXCEPTION', E.Message);

  Response.Content := e.Message;
end;

procedure TWebModule1.WebModuleBeforeDispatch(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  k: string;
begin
try
  Inc(FRun);

  ods('WEBMODULE BEFOREDISPATCH', FRun.ToString);

  {$REGION 'RequestObjects'}
  FWat := TStopwatch.StartNew;  ods('WEBMODULE BEFOREDISPATCH', 'TStopwatch started');
  {$ENDREGION}

  {$REGION 'BeforeDispatch'}
  all.BeforeDispatch(Request, Response, FIni.BooGet('WebRequest/OtpIsActive', false), FIni.BooGet('WebRequest/AuditIsActive', true), k);
  {$ENDREGION}

except
  on e: Exception do ods('WEBMODULE BEFOREDISPATCH', 'EXCEPTION: ' + e.Message);
end;
end;

procedure TWebModule1.WebModuleAfterDispatch(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  k: string;
begin
try
  ods('WEBMODULE AFTERDISPATCH', FRun.ToString);

  {$REGION 'AfterDispatch'}
  all.AfterDispatch(FWat, Request, Response, FIni.BooGet('WebRequest/OtpIsActive', false), FIni.BooGet('WebRequest/AuditIsActive', true), k);
  {$ENDREGION}

  {$REGION 'RequestObjects'}
  FWat.Stop;                    ods('WEBMODULE AFTERDISPATCH', 'TStopwatch stopped (' + FWat.ElapsedMilliseconds.ToString + ' ms)');
  {$ENDREGION}

except
  on e: Exception do ods('WEBMODULE AFTERDISPATCH', 'EXCEPTION: ' + e.Message);
end;
end;
{$ENDREGION}

{$REGION 'Pages'}
procedure TWebModule1.WebModule1DefaultHandlerAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  o: boolean;
  h, k: string;
  i: integer;
  d: TFDDataSet;
  x: TDbaCls;
begin
try
  ods('WEBMODULE DEFAULTHANDLER', FRun.ToString);

  {$REGION 'Activity'}
  // simple
  if not true then begin
    i := 0; //rnd.Int(900, 1100);
    //Sleep(i);
    h := Format('sleepping: %f s', [i/1000]);

  // db
  end else begin
    x := TDbaCls.Create(FDManager);
    try
      o := x.DsFD('select top(10) FldDateTime, FldClientApp, FldRequestId, FldHost, FldUrl, FldPathInfo, FldQuery from DbaClient.dbo.TblRequest order by FldDateTime desc', d, k);
      dst.ToHtml(d, h, true, true, true);
      h := Format('%s', [k]) + ' ' + h;
    finally
      FreeAndNil(d);
      FreeAndNil(x);
    end;
  end;

  // log
  ods('WEBMODULE DEFAULTHANDLER', h);
  {$ENDREGION}

  {$REGION 'Response'}
  Response.Content :=
                 '<html>'
  + sLineBreak + '<head><title>Web Server Application</title></head>'
  + sLineBreak + '<body>'
  + sLineBreak + '<pre>'
  + sLineBreak + 'Wks Test Isapi Web Server Application'
  + sLineBreak + 'datetime            : ' + DateTimeToStr(Now)
  + sLineBreak + 'pid                 : ' + Winapi.Windows.GetCurrentProcessId.ToString
  + sLineBreak + 'tid                 : ' + Winapi.Windows.GetCurrentThreadID.ToString
  + sLineBreak + 'webmodule           : ' + Format('%p', [@self])
  + sLineBreak + 'requestconnid       : ' + (Request as TISAPIRequest).Ecb^.ConnId.ToString
  + sLineBreak + 'maxconnections      : ' + Application.MaxConnections.ToString
  + sLineBreak + 'activeconnections   : ' + Application.ActiveCount.ToString
  + sLineBreak + 'inactiveconnections : ' + Application.InActiveCount.ToString
  + sLineBreak + 'cachedconnections   : ' + Ord(Application.CacheConnections).ToString
  + sLineBreak + 'run                 : ' + FRun.ToString
  + sLineBreak + h
  + sLineBreak + 'If you are getting this message your are providing a wrong PathInfo or the action is no more available'
  + sLineBreak + '<pre>'
  + sLineBreak + '</body>'
  + sLineBreak + '</html>';
  {$ENDREGION}

  Handled := true;

except
  on e: Exception do begin
    Response.Content := 'WEBMODULE DEFAULTHANDLER EXCEPTION: ' + e.Message;
    ods('WEBMODULE DEFAULTHANDLER', 'EXCEPTION: ' + e.Message);
  end;
end;
end;
{$ENDREGION}

end.

