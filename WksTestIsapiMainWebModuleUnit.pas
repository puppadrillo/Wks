unit WksTestIsapiMainWebModuleUnit;

interface

{$REGION 'Use'}
uses
    System.SysUtils
  , System.Classes
  , System.Diagnostics
  , Web.HTTPApp
  , WksAllUnit, Web.HTTPProd, Web.DSProd
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
    FCount: cardinal; // requestscounter
    FWat: TStopwatch;
    FIni: TIniCls;
    FDba: TDbaCls;
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
  , Data.DB
  ;
{$ENDREGION}

{$REGION 'Events'}
procedure TWebModule1.WebModuleCreate(Sender: TObject);
begin
  ods('WEBMODULE', 'Create');

  {$REGION 'Objects'}
  FIni := TIniCls.Create;      //lgt.Tag('WEBMODULE BEFOREDISPATCH', 'TIniCls object created');
  FDba := TDbaCls.Create;      //lgt.Tag('WEBMODULE BEFOREDISPATCH', 'TDbaCls object created');
  {$ENDREGION}

end;

procedure TWebModule1.WebModuleDestroy(Sender: TObject);
begin
  ods('WEBMODULE', 'Destroy');

  {$REGION 'Objects'}
  FDba.Free;                   //lgt.Tag('WEBMODULE AFTERDISPATCH', 'TDbaCls object free');
  FIni.Free;                   //lgt.Tag('WEBMODULE AFTERDISPATCH', 'TIniCls object free');
  {$ENDREGION}

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
  Inc(FCount);
  ods('WEBMODULE BEFOREDISPATCH', FCount.ToString);

  {$REGION 'Objects'}
  FWat := TStopwatch.StartNew; //lgt.Tag('WEBMODULE BEFOREDISPATCH', 'TStopwatch started');
  {$ENDREGION}

  {$REGION 'PrepareAll'}
//  all.BeforeDispatch(FDba, Request, Response, FIni.BooGet('WebRequest/OtpIsActive', false), FIni.BooGet('WebRequest/AuditIsActive', true), k);
  {$ENDREGION}

end;

procedure TWebModule1.WebModuleAfterDispatch(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  k: string;
begin
  ods('WEBMODULE AFTERDISPATCH', FCount.ToString);

  {$REGION 'UnprepareAll'}
//  all.AfterDispatch(FDba, Request, Response, FIni.BooGet('WebRequest/OtpIsActive', false), FIni.BooGet('WebRequest/AuditIsActive', true), k);
  {$ENDREGION}

  {$REGION 'Objects'}
  FWat.Stop;                   //lgt.Tag('WEBMODULE AFTERDISPATCH', 'TStopwatch stopped');
  {$ENDREGION}

end;
{$ENDREGION}

{$REGION 'Pages'}
procedure TWebModule1.WebModule1DefaultHandlerAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  o: boolean;
  i: integer;
  h, k: string;
  d: TDataset;
begin
  ods('WEBMODULE DEFAULTHANDLER', FCount.ToString);

  {$REGION 'Load'}
  // simple
  if not true then begin
    //i := rnd.Int(900, 1100);
    //Sleep(i);
    h := Format('<p>run: %d, sleepping: %f seconds</p>', [FCount, i/1000]);

  // db
  end else begin
    o := FDba.DsFD('select top(10) FldDateTime, FldClientApp, FldRequestId, FldHost, FldUrl, FldPathInfo, FldQuery from DbaClient.dbo.TblRequest order by FldDateTime desc', d, k);
    try
      dst.ToHtml(d, h, true, true, true);
    finally
      d.Free;
    end;
    h := Format('<p>run: %d: db: %s</p>', [FCount, k]) + h;
  end;

  // log
  lgt.I(h);
  {$ENDREGION}

  {$REGION 'Response'}
  Response.Content :=
    '<html>'
  + '<head><title>Web Server Application</title></head>'
  + '<body>'
  + 'Wks Test Isapi Web Server Application - ' + DateTimeToStr(Now())
  + h
  + '</body>'
  + '</html>';
  {$ENDREGION}

end;
{$ENDREGION}

end.

