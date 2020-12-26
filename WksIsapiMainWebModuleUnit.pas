unit WksIsapiMainWebModuleUnit;

interface

{$REGION 'Use'}
uses
    System.SysUtils
  , System.Classes
  , System.Diagnostics
  , Web.HTTPApp
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
  ;
{$ENDREGION}

{$REGION 'Events'}
procedure TWebModule1.WebModuleCreate(Sender: TObject);
begin
  //lgt.Tag('WEBMODULE', 'Create'); // hangiis use debugstring
end;

procedure TWebModule1.WebModuleDestroy(Sender: TObject);
begin
  //lgt.Tag('WEBMODULE', 'Destroy'); // hangiis use debugstring
end;

procedure TWebModule1.WebModuleException(Sender: TObject; E: Exception; var Handled: Boolean);
begin
  lgt.Tag('WEBMODULE EXCEPTION', E.Message);
end;

procedure TWebModule1.WebModuleBeforeDispatch(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  Inc(FCount);
  lgt.Tag('WEBMODULE', 'BeforeDispatch ' + FCount.ToString);

  {$REGION 'Objects'}
  FWat := TStopwatch.StartNew;  lgt.Tag('WEBMODULE BEFOREDISPATCH', 'TStopwatch started');
  FIni := TIniCls.Create;       lgt.Tag('WEBMODULE BEFOREDISPATCH', 'TIniCls object created');
  FDba := TDbaCls.Create();     lgt.Tag('WEBMODULE BEFOREDISPATCH', 'TDbaCls object created');
  {$ENDREGION}

  {$REGION 'Note'}
  {
    NOW THE APPLICATION SHOULD KNOW:
    - system, params, switches
    - user, authentication, session
    - organization, palette, smtp, pop3
    - member, email, role, level, structure, authorization
  }
  {$ENDREGION}

end;

procedure TWebModule1.WebModuleAfterDispatch(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  lgt.Tag('WEBMODULE', 'AfterDispatch ' + FCount.ToString);

  {$REGION 'Objects'}
  FDba.Free;                    lgt.Tag('WEBMODULE AFTERDISPATCH', 'TDbaCls object free');
  FIni.Free;                    lgt.Tag('WEBMODULE AFTERDISPATCH', 'TIniCls object free');
  FWat.Stop;                    lgt.Tag('WEBMODULE AFTERDISPATCH', 'TStopwatch stopped');
  {$ENDREGION}

end;
{$ENDREGION}

{$REGION 'Action'}
procedure TWebModule1.WebModule1DefaultHandlerAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  lgt.Tag('WEBMODULE', 'DefaultHandlerAction ' + FCount.ToString);
  Response.Content :=
    '<html>' +
    '<head><title>Web Server Application</title></head>' +
    '<body>Web Server Application</body>' +
    '</html>';
end;
{$ENDREGION}

end.
