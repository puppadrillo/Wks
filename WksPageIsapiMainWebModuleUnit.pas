unit WksPageIsapiMainWebModuleUnit;

interface

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
    procedure WebModule1TestWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1InitWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1InfoWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1PageWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1LoginWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1LoginTryWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1LogoutWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1AccountWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1AccountCreateWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1AccountCreateTryWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1AccountCreateDoneWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1AccountRecoverWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1AccountRecoverTryWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1AccountRecoverDoneWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1SocialWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1NewsWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1MessageWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1NotificationWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1DashboardWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
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

procedure TWebModule1.WebModule1InitWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  t: string; // theme
  l: TStrings;
begin
try
  ods('WEBMODULE INITWEBACTION', FRun.ToString);

  {$REGION 'Go'}
  // create all w3-theme.css files
  css.W3ThemeInit('#ffc107', 'amber');
  css.W3ThemeInit('#0f0f0f', 'black');
  css.W3ThemeInit('#2196f3', 'blue');
  css.W3ThemeInit('#607d8b', 'blue-grey');
  css.W3ThemeInit('#795548', 'brown');
  css.W3ThemeInit('#00bcd4', 'cyan');
  css.W3ThemeInit('#616161', 'dark-grey');
  css.W3ThemeInit('#ff5722', 'deep-orange');
  css.W3ThemeInit('#673ab7', 'deep-purple');
  css.W3ThemeInit('#4caf50', 'green');
  css.W3ThemeInit('#9e9e9e', 'grey');
  css.W3ThemeInit('#3f51b5', 'indigo');
  css.W3ThemeInit('#f0e68c', 'khaki');
  css.W3ThemeInit('#87ceeb', 'light-blue');
  css.W3ThemeInit('#8bc34a', 'light-green');
  css.W3ThemeInit('#e7e7e7', 'light-grey');
  css.W3ThemeInit('#cddc39', 'lime');
  css.W3ThemeInit('#ffa500', 'orange');
  css.W3ThemeInit('#e91e63', 'pink');
  css.W3ThemeInit('#9c27b0', 'purple');
  css.W3ThemeInit('#f44336', 'red');
  css.W3ThemeInit('#c0c0c0', 'silver');
  css.W3ThemeInit('#009688', 'teal');
  css.W3ThemeInit('#ffffff', 'white'); // f0f0f0
  css.W3ThemeInit('#ffeb3b', 'yellow');

  // create Default.htm customized by organization
  t := 'w3-theme-' + obj.DbaParamGet('System', 'Theme', 'grey') + '.css';
  l := TStringList.Create;
  try
    l.Add('<!DOCTYPE html>');
    l.Add('<html lang="en">');
    l.Add('<head>');
    l.Add('  <title>Default Page</title>');
    l.Add('  <meta charset="utf-8">');
    l.Add('  <meta http-equiv="refresh" content="0; url=/WksPageIsapiProject.dll/">');
    l.Add('  <link rel="icon" href="' + org.IconUrl + '" type="image/png">');
    l.Add('  <link rel="stylesheet" href="/Include/w3/w3.css" />');
    l.Add('  <link rel="stylesheet" href="/Include/w3/' + t + '.css" />');
  //l.Add('  <script src="/Include/w3/w3.js"></script>');
  //l.Add('  <script src="/Include/wks/wks.js"></script>');
    l.Add('</head>');
    l.Add('<body>');
    l.Add('  <div class="w3-waitloader"></div>');
    l.Add('</body>');
    l.Add('</html>');
    l.SaveToFile(sys.HomePath() + '\Default.htm');
  finally
    FreeAndNil(l);
  end;

  // page
  Response.Content := htm.PageBlank(
    'Init'
  , htm.AlertS('Initialize', Format('Customized %s and %s files have been created for %s', [htm.SpanCode('Default.htm'), htm.SpanCode(t), htm.SpanCode(org.Organization)]))
  );
  {$ENDREGION}

except
  on e: Exception do begin
    ods('WEBMODULE ', 'EXCEPTION: ' + e.Message);
    Response.Content := 'WEBMODULE INITWEBACTION EXCEPTION: ' + e.Message;
  end;
end;
end;

procedure TWebModule1.WebModule1InfoWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  r, z, h, q, k: string; // reqformcharttable, reqlastN, reqhost, reqsql
  d: TFDDataSet;
  x: TDbaCls;
begin
try
  ods('WEBMODULE INFOWEBACTION', FRun.ToString);

  x := TDbaCls.Create(FDManager);
  try

    {$REGION 'Pre'}
    // requestforminputs
    z := wre.StrGet('CoLast', '10');
    h := wre.StrGet('CoHost', '%');

    // requestsql
    q :=           'select --top(' + z + ')'
    + sLineBreak + '    FldDateTime, FldClientAddr, FldClientHost, FldClientFingerprint'
    + sLineBreak + '  , FldUserOrganization, FldUsername'
    + sLineBreak + '  , FldSession, FldOtp'
    + sLineBreak + '  , FldRequestId, FldHttpProtocol, FldHttpMethod'
    + sLineBreak + '  , FldHost, FldUrl, FldPathInfo, FldQuery'
    + sLineBreak + '  , FldScriptVer, FldTimingMs '
    + sLineBreak + 'from'
    + sLineBreak + '    DbaClient.dbo.TblRequest ' // client_report_config.dbo.TblRequest
    + sLineBreak + 'where'
    + sLineBreak + '    FldHost like ''' + h + ''' '
    + sLineBreak + 'order by'
    + sLineBreak + '    1 '
    + sLineBreak + 'offset'
    + sLineBreak + '    (select count(*) from DbaClient.dbo.TblRequest) - ' + z + ' rows '
    + sLineBreak + 'fetch'
    + sLineBreak + '    next ' + z + ' rows only';

    // requestform
    r := ''
    + htm.H(3, 'Filters')
    + htm.Form(['CoLast', 'CoHost', 'CoSubmit'], ['Text', 'Text', 'Submit'], [z, h, 'Refresh'], 'w3-container', '[RvWreScriptName]/Info', 'post');

    // lastrequestsds
    if not x.DsFD(q, d, k) then begin
      r := r + htm.AlertW('Last Request', k);
    end else begin
      r := r

      // requesttimechart
      + htm.H(3, 'Chart')
      + htm.ChartDs('CoTestChart', '100%' , '400px', 'Test Chart', d, 'FldDateTime', 'FldTimingMs', '')

      // requesttable
      + htm.H(3, 'Table')
      + htm.TableDs(d)
    end;
  {$ENDREGION}

    {$REGION 'Go'}
    Response.Content := htm.Page(
      'Info'

    // pathinfoactions
    , htm.SpaceV()
    + htm.H(2, 'Actions')
    + htm.DivPathInfoActions(self, Request)

    // webrequest
    + htm.SpaceV()
    + htm.H(2, 'Web Request')
    + htm.TableWre

    // requests
    + htm.SpaceV()
    + htm.H(2, 'Last Requests')
    + r

    + htm.SpaceV()
    );
    {$ENDREGION}

  finally
    FreeAndNil(d);
    FreeAndNil(x);
  end;
except
  on e: Exception do begin
    ods('WEBMODULE INFOWEBACTION', 'EXCEPTION: ' + e.Message);
    Response.Content := 'WEBMODULE INFOWEBACTION EXCEPTION: ' + e.Message;
  end;
end;
end;

procedure TWebModule1.WebModule1TestWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
try
  ods('WEBMODULE TESTWEBACTION', FRun.ToString);

  {$REGION 'Go'}
  Response.Content := htm.Page(
    'Test'

  // rv
  , htm.SpaceV()
  + htm.H(2, '[RvWreUserOrganization(..1..| ..2.. |    ..3..   )]')
  + htm.P('[RvWreField(CoAudio)] , [RvWreField(CoVideo)] , [RvWreField(SERVER_SOFTWARE)] , [RvWreField(CoLast)] , [RvWreXxx(123)]')

  // theme
  + htm.SpaceV()
  + htm.H(2, 'Test Theme')
  + htm.TestTheme

  // form
  + htm.SpaceV()
  + htm.H(2, 'Test Form')
  + htm.TestForm

  // table
  + htm.SpaceV()
  + htm.H(2, 'Test Table')
  + htm.TestTable(5, 10)

  // chart
  + htm.SpaceV()
  + htm.H(2, 'Test Chart')
  + htm.TestChart(100)

  + htm.SpaceV()
  );
  {$ENDREGION}

except
  on e: Exception do begin
    ods('WEBMODULE TESTWEBACTION', 'EXCEPTION: ' + e.Message);
    Response.Content := 'WEBMODULE TESTWEBACTION EXCEPTION: ' + e.Message;
  end;
end;
end;

procedure TWebModule1.WebModule1PageWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  iop, q, k: string; // pageidorpath
  i: integer; // id
  d: TFDDataSet;
  x: TDbaCls;
begin
try
  ods('WEBMODULE PAGEWEBACTION', FRun.ToString);

  x := TDbaCls.Create(FDManager);
  try

    {$REGION 'Go'}
    // id
    iop := wre.StrGet('CoId', '');
    if iop.IsEmpty then
      i := x.HIdFromPath('DbaPage.dbo.TblPage', 'FldPage', org.TreePath)
    else
      i := x.HIdFromIdOrPath('DbaPage.dbo.TblPage', 'FldPage', iop);

    // sql
    q := 'select FldId, FldPage, FldTitle, FldSubTitle, FldContent, FldHead, FldCss, FldJs, FldHeader, FldFooter, FldContainerOn from DbaPage.dbo.TblPage where FldState = ''Active'' and FldId = ' + i.ToString;

    // pagenotfound
    if not x.DsFD(q, d, k, true) then
      Response.Content := htm.PageNotFound()

    // pagenotactive
    else if false then
      Response.Content := htm.PageW('pagenotactive')

    // pagerestrictedforprivileges
    else if false then
      Response.Content := htm.PageW('pagerestrictedforprivileges')

    // pagebelongtodifferentorganization
    else if false then
      Response.Content := htm.PageW('pagebelongtodifferentorganization')

    // pageserve
    else
      Response.Content := htm.Page(
        // title
        iif.NxD(d.FieldByName('FldTitle').AsString, d.FieldByName('FldPage').AsString)
        // content
      , iif.ExF(d.FieldByName('FldTitle').AsString, '<h2>%s</h2>')
      + iif.ExF(d.FieldByName('FldSubTitle').AsString, '<h6>%s</h6><hr>')
      +         d.FieldByName('FldContent').AsString
        // head&css&js
      , d.FieldByName('FldHead').AsString
      , d.FieldByName('FldCss').AsString
      , d.FieldByName('FldJs').AsString
        // h&f
      , d.FieldByName('FldHeader').AsString
      , d.FieldByName('FldFooter').AsString
        // others
      , d.FieldByName('FldContainerOn').AsBoolean
      );
    {$ENDREGION}

  finally
    FreeAndNil(d);
    FreeAndNil(x);
  end;
except
  on e: Exception do begin
    ods('WEBMODULE PAGEWEBACTION', 'EXCEPTION: ' + e.Message);
    Response.Content := 'WEBMODULE PAGEWEBACTION EXCEPTION: ' + e.Message;
  end;
end;
end;
{$ENDREGION}

{$REGION 'Login'}
procedure TWebModule1.WebModule1LoginWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
//d: TFDDataSet;
  x: TDbaCls;
begin
try
  ods('WEBMODULE LOGINWEBACTION', FRun.ToString);

  {$REGION 'Go'}
  Response.Content := htm.PageBlank(
    'User Login'
  , htm.ModUserLogin
  );
  {$ENDREGION}

except
  on e: Exception do begin
    ods('WEBMODULE LOGINWEBACTION', 'EXCEPTION: ' + e.Message);
    Response.Content := 'WEBMODULE LOGINWEBACTION EXCEPTION: ' + e.Message;
  end;
end;
end;

procedure TWebModule1.WebModule1LoginTryWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  s: integer;
begin
try
  ods('WEBMODULE LOGINTRYWEBACTION', FRun.ToString);

  {$REGION 'Go'}
  // try to validate username // credential here, also assign rights/levels accesses
  if wre.StrGet('CoUsername', '') = 'giarussi' then begin
    // try to validate password
    if wre.StrGet('CoPassword', '') = 'secret' then begin

      // createnewsession
      s := 1234;
      // clientremembersuccesfulloginfornextrequests
      wrs.CookieSet('CoSession', s);

      // redirecttodefault
      Response.SendRedirect(wre.ScriptName + '/');
    end else
      Response.Content := htm.PageBlank('Password', htm.ModMessage('Incorrect Password', '<p>The password you have entered is not valid.</p><p>Please enter a valid password.</p><br>'));
    ;
  end else
    Response.Content := htm.PageBlank('Username', htm.ModMessage('Unknown Username', '<p>The username you have entered is not valid.</p><p>Please create a new acoount or try to recover your forgotten username and/or password.</p><br>'));
  ;
  {$ENDREGION}

except
  on e: Exception do begin
    ods('WEBMODULE LOGINTRYWEBACTION', 'EXCEPTION: ' + e.Message);
    Response.Content := 'WEBMODULE LOGINTRYWEBACTION EXCEPTION: ' + e.Message;
  end;
end;
end;

procedure TWebModule1.WebModule1LogoutWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  r: string; // redirect
begin
try
  ods('WEBMODULE LOGOUTWEBACTION', FRun.ToString);

  {$REGION 'Go'}
  // removesessioncookiefromclient-fromnowonanewloginisnecessary
  wrs.CookieSet('CoSession', '');

  // redirect
  r := obj.DbaParamGet('System', 'LogoutUrl', 'http://www.google.com');
  Response.SendRedirect(r);
  {$ENDREGION}

except
  on e: Exception do begin
    ods('WEBMODULE LOGOUTWEBACTION', 'EXCEPTION: ' + e.Message);
    Response.Content := 'WEBMODULE LOGOUTWEBACTION EXCEPTION: ' + e.Message;
  end;
end;
end;
{$ENDREGION}

{$REGION 'Account'}
procedure TWebModule1.WebModule1AccountWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
try
  ods('WEBMODULE ACCOUNTWEBACTION', FRun.ToString);

  {$REGION 'Go'}
  // [...] display the account here, the page have to be self-editing enabled
  Response.Content := htm.PageI('Account', NOT_IMPLEMENTED_STR);
  {$ENDREGION}

except
  on e: Exception do begin
    ods('WEBMODULE ACCOUNTWEBACTION', 'EXCEPTION: ' + e.Message);
    Response.Content := 'WEBMODULE ACCOUNTWEBACTION EXCEPTION: ' + e.Message;
  end;
end;
end;

procedure TWebModule1.WebModule1AccountCreateWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
try
  ods('WEBMODULE ACCOUNTCREATEWEBACTION', FRun.ToString);

  {$REGION 'Go'}
  Response.Content := htm.PageBlank(
    'Account Create'
  , htm.ModUserAccountCreate
  );
  {$ENDREGION}

except
  on e: Exception do begin
    ods('WEBMODULE ACCOUNTCREATEWEBACTION', 'EXCEPTION: ' + e.Message);
    Response.Content := 'WEBMODULE ACCOUNTCREATEWEBACTION EXCEPTION: ' + e.Message;
  end;
end;
end;

procedure TWebModule1.WebModule1AccountCreateTryWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
//d: TFDDataSet;
  x: TDbaCls;
begin
try
  ods('WEBMODULE ACCOUNTCREATETRYWEBACTION', FRun.ToString);

  x := TDbaCls.Create(FDManager);
  try

    {$REGION 'Go'}
    // [...] try to create account here
    Response.SendRedirect(wre.ScriptName + '/AccountCreateDone');
    {$ENDREGION}

  finally
  //FreeAndNil(d);
    FreeAndNil(x);
  end;
except
  on e: Exception do begin
    ods('WEBMODULE ACCOUNTCREATETRYWEBACTION', 'EXCEPTION: ' + e.Message);
    Response.Content := 'WEBMODULE ACCOUNTCREATETRYWEBACTION EXCEPTION: ' + e.Message;
  end;
end;
end;

procedure TWebModule1.WebModule1AccountCreateDoneWebActionAction( Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
try
  ods('WEBMODULE ACCOUNTCREATEDONEWEBACTION', FRun.ToString);

  {$REGION 'Go'}
  Response.Content := htm.PageBlank(
    'Account Create Done'
  , htm.ModUserAccountCreateDone
  );
  {$ENDREGION}

except
  on e: Exception do begin
    ods('WEBMODULE ACCOUNTCREATEDONEWEBACTION', 'EXCEPTION: ' + e.Message);
    Response.Content := 'WEBMODULE ACCOUNTCREATEDONEWEBACTION EXCEPTION: ' + e.Message;
  end;
end;
end;

procedure TWebModule1.WebModule1AccountRecoverWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
try
  ods('WEBMODULE ACCOUNTRECOVERWEBACTION', FRun.ToString);

  {$REGION 'Go'}
  Response.Content := htm.PageBlank(
    'Account Recover'
  , htm.ModUserAccountRecover
  );
  {$ENDREGION}

except
  on e: Exception do begin
    ods('WEBMODULE ACCOUNTRECOVERWEBACTION', 'EXCEPTION: ' + e.Message);
    Response.Content := 'WEBMODULE ACCOUNTRECOVERWEBACTION EXCEPTION: ' + e.Message;
  end;
end;
end;

procedure TWebModule1.WebModule1AccountRecoverTryWebActionAction( Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
try
  ods('WEBMODULE ACCOUNTRECOVERTRYWEBACTION', FRun.ToString);

  {$REGION 'Go'}
  // [...] try to recover user account here send info to the user
  Response.SendRedirect(wre.ScriptName + '/AccountRecoverDone');
  {$ENDREGION}

except
  on e: Exception do begin
    ods('WEBMODULE ACCOUNTRECOVERTRYWEBACTION', 'EXCEPTION: ' + e.Message);
    Response.Content := 'WEBMODULE ACCOUNTRECOVERTRYWEBACTION EXCEPTION: ' + e.Message;
  end;
end;
end;

procedure TWebModule1.WebModule1AccountRecoverDoneWebActionAction( Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
try
  ods('WEBMODULE RECOVERDONEWEBACTION', FRun.ToString);

  {$REGION 'Go'}
  Response.Content := htm.PageBlank(
    'Account Recovering Done'
  , htm.ModUserAccountRecoverDone
  );
  {$ENDREGION}

except
  on e: Exception do begin
    ods('WEBMODULE RECOVERDONEWEBACTION', 'EXCEPTION: ' + e.Message);
    Response.Content := 'WEBMODULE RECOVERDONEWEBACTION EXCEPTION: ' + e.Message;
  end;
end;
end;
{$ENDREGION}

{$REGION 'Social'}
procedure TWebModule1.WebModule1SocialWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
try
  ods('WEBMODULE SOCIALWEBACTION', FRun.ToString);

  {$REGION 'Go'}
  Response.Content := htm.Page(
    'Social'

  , htm.D(''
    + htm.D(''
      + htm.B
      + htm.DivUserProfile('giarussi', '353992')
      + htm.B
      + htm.DivUserInterest('giarussi', '353992')
      + htm.B
      + htm.DivUserNotification('test notification')
      + htm.B
      + htm.DivUserMore('giarussi')
      + htm.B
      , 'w3-col m3', 'Column Left'
      )
    + htm.D(''
      + htm.B
      + htm.DivUserBlog(48)
      , 'w3-col m7', 'Column Middle'
      )
    + htm.D(''
      + htm.B
      + htm.DivUserUpcomingEvent('giarussi')
      + htm.B
      + htm.DivUserFrienRequest('giarussi')
      + htm.B
      + htm.DivUserAds('giarussi')
      + htm.B
      + htm.DivUserBug('giarussi')
      , 'w3-col m2', 'Column Right'
      )
    , 'w3-row', 'Grid'
    )
  );
  {$ENDREGION}

except
  on e: Exception do begin
    ods('WEBMODULE SOCIALWEBACTION', 'EXCEPTION: ' + e.Message);
    Response.Content := 'WEBMODULE SOCIALWEBACTION EXCEPTION: ' + e.Message;
  end;
end;
end;

procedure TWebModule1.WebModule1MessageWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
try
  ods('WEBMODULE MESSAGEWEBACTION', FRun.ToString);

  {$REGION 'Go'}
  Response.Content := htm.PageI('Message', NOT_IMPLEMENTED_STR);
  {$ENDREGION}

except
  on e: Exception do begin
    ods('WEBMODULE MESSAGEWEBACTION', 'EXCEPTION: ' + e.Message);
    Response.Content := 'WEBMODULE MESSAGEWEBACTION EXCEPTION: ' + e.Message;
  end;
end;
end;

procedure TWebModule1.WebModule1NewsWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
try
  ods('WEBMODULE NEWSWEBACTION', FRun.ToString);

  {$REGION 'Go'}
  Response.Content := htm.PageI('News', NOT_IMPLEMENTED_STR);
  {$ENDREGION}

except
  on e: Exception do begin
    ods('WEBMODULE NEWSWEBACTION', 'EXCEPTION: ' + e.Message);
    Response.Content := 'WEBMODULE NEWSWEBACTION EXCEPTION: ' + e.Message;
  end;
end;
end;

procedure TWebModule1.WebModule1NotificationWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
try
  ods('WEBMODULE NOTIFICATIONWEBACTION', FRun.ToString);

  {$REGION 'Go'}
  Response.Content := htm.PageI('Notification', NOT_IMPLEMENTED_STR);
  {$ENDREGION}

except
  on e: Exception do begin
    ods('WEBMODULE NOTIFICATIONWEBACTION', 'EXCEPTION: ' + e.Message);
    Response.Content := 'WEBMODULE NOTIFICATIONWEBACTION EXCEPTION: ' + e.Message;
  end;
end;
end;
{$ENDREGION}

{$REGION 'Dashboard'}
procedure TWebModule1.WebModule1DashboardWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
try
  ods('WEBMODULE DASHBOARDWEBACTION', FRun.ToString);

  {$REGION 'Go'}
  // [...] display here a dashboard tailored for the user
  // the user might be able to subscribe for different dashboards he is interested in
  // a defaul dashoard should be also provided
  // eventually the used might setup the order of dashoboards to see
  Response.Content := htm.PageI('Dashboard', NOT_IMPLEMENTED_STR);
  {$ENDREGION}

except
  on e: Exception do begin
    ods('WEBMODULE DASHBOARDWEBACTION', 'EXCEPTION: ' + e.Message);
    Response.Content := 'WEBMODULE DASHBOARDWEBACTION EXCEPTION: ' + e.Message;
  end;
end;
end;
{$ENDREGION}

{$REGION 'Zzz'}
(*
*)
{$ENDREGION}

end.

