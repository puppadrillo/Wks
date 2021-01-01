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
    FCount: cardinal; // requestscounter
    FWat: TStopwatch;
    FIni: TIniCls;
    FDba: TDbaCls;
    function PathInfoActionIsValid(IvPathInfo: string): boolean;
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

{$REGION 'Routine'}
function TWebModule1.PathInfoActionIsValid(IvPathInfo: string): boolean;
var
  i: integer;
begin
  for i := 0 to self.Actions.Count - 1 do begin
    Result := Actions[i].PathInfo = IvPathInfo;
    if Result then
      Exit;
  end;
end;
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

  Response.Content := htm.PageE(FDba, 'Exception', e.Message);
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
  all.BeforeDispatch(FDba, Request, Response, FIni.BooGet('WebRequest/OtpIsActive', false), FIni.BooGet('WebRequest/AuditIsActive', true), k);
  {$ENDREGION}

end;

procedure TWebModule1.WebModuleAfterDispatch(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  k: string;
begin
  ods('WEBMODULE AFTERDISPATCH', FCount.ToString);

  {$REGION 'UnprepareAll'}
  all.AfterDispatch(FDba, Request, Response, FIni.BooGet('WebRequest/OtpIsActive', false), FIni.BooGet('WebRequest/AuditIsActive', true), k);
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
  + 'Wks Isapi Web Server Application - ' + DateTimeToStr(Now())
  + h
  + '</body>'
  + '</html>';
  {$ENDREGION}

end;

procedure TWebModule1.WebModule1InitWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  t: string; // theme
  l: TStrings;
begin
  // create all w3-theme.css files
  css.W3ThemeInit(FDba, '#ffc107', 'amber');
  css.W3ThemeInit(FDba, '#0f0f0f', 'black');
  css.W3ThemeInit(FDba, '#2196f3', 'blue');
  css.W3ThemeInit(FDba, '#607d8b', 'blue-grey');
  css.W3ThemeInit(FDba, '#795548', 'brown');
  css.W3ThemeInit(FDba, '#00bcd4', 'cyan');
  css.W3ThemeInit(FDba, '#616161', 'dark-grey');
  css.W3ThemeInit(FDba, '#ff5722', 'deep-orange');
  css.W3ThemeInit(FDba, '#673ab7', 'deep-purple');
  css.W3ThemeInit(FDba, '#4caf50', 'green');
  css.W3ThemeInit(FDba, '#9e9e9e', 'grey');
  css.W3ThemeInit(FDba, '#3f51b5', 'indigo');
  css.W3ThemeInit(FDba, '#f0e68c', 'khaki');
  css.W3ThemeInit(FDba, '#87ceeb', 'light-blue');
  css.W3ThemeInit(FDba, '#8bc34a', 'light-green');
  css.W3ThemeInit(FDba, '#e7e7e7', 'light-grey');
  css.W3ThemeInit(FDba, '#cddc39', 'lime');
  css.W3ThemeInit(FDba, '#ffa500', 'orange');
  css.W3ThemeInit(FDba, '#e91e63', 'pink');
  css.W3ThemeInit(FDba, '#9c27b0', 'purple');
  css.W3ThemeInit(FDba, '#f44336', 'red');
  css.W3ThemeInit(FDba, '#c0c0c0', 'silver');
  css.W3ThemeInit(FDba, '#009688', 'teal');
  css.W3ThemeInit(FDba, '#ffffff', 'white'); // f0f0f0
  css.W3ThemeInit(FDba, '#ffeb3b', 'yellow');

  // create Default.htm customized by organization
  t := 'w3-theme-' + obj.DbaParamGet(FDba, 'System', 'Theme', 'grey') + '.css';
  l := TStringList.Create;
  try
    l.Add('<!DOCTYPE html>');
    l.Add('<html lang="en">');
    l.Add('<head>');
    l.Add('  <title>Default Page</title>');
    l.Add('  <meta charset="utf-8">');
    l.Add('  <meta http-equiv="refresh" content="0; url=/WksIsapiProject.dll/">');
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
    l.SaveToFile(sys.HomePath(FDba) + '\Default.htm');
  finally
    l.Free;
  end;

  // page
  Response.Content := htm.PageBlank(FDba,
    'Init'
  , htm.AlertS('Initialize', Format('Customized %s and %s files have been created for %s', [htm.SpanCode('Default.htm'), htm.SpanCode(t), htm.SpanCode(org.Organization)]))
  );
end;

procedure TWebModule1.WebModule1InfoWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  r, z, h, q, k: string; // reqformcharttable, reqlastN, reqhost, reqsql
  d: TDataset;
begin

  {$REGION 'PreWork'}
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

  // db
  if not FDba.DsFD(q, d, k) then begin
    r := htm.AlertW('Last Request', k);
  end else begin
    // requestform
    r := ''
    + htm.H(3, 'Filters')
    + htm.Form(['CoLast', 'CoHost', 'CoSubmit'], ['Text', 'Text', 'Submit'], [z, h, 'Refresh'], 'w3-container', '[RvWreScriptName]/Info', 'post')

    // requesttimechart
    + htm.H(3, 'Chart')
    + htm.ChartDs('CoTestChart', '100%' , '400px', 'Test Chart', d, 'FldDateTime', 'FldTimingMs', '')

    // requesttable
    + htm.H(3, 'Table')
    + htm.TableDs(d)
  end;
  {$ENDREGION}

  // page
  Response.Content := htm.Page(FDba,
    'Info'

  // pathinfoactions
  , htm.SpaceV()
  + htm.H(2, 'Actions')
  + htm.DivPathInfoActions(Request)

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
end;

procedure TWebModule1.WebModule1TestWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  Response.Content := htm.Page(FDba,
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
end;

procedure TWebModule1.WebModule1PageWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  iop, q, k: string; // pageidorpath
  i: integer; // id
  d: TDataset;
begin
  // id
  iop := wre.StrGet('CoId', '');
  if iop.IsEmpty then
    i := FDba.HIdFromPath('DbaPage.dbo.TblPage', 'FldPage', org.TreePath)
  else
    i := FDba.HIdFromIdOrPath('DbaPage.dbo.TblPage', 'FldPage', iop);

  // sql
  q := 'select FldId, FldPage, FldTitle, FldSubTitle, FldContent, FldHead, FldCss, FldJs, FldHeader, FldFooter, FldContainerOn from DbaPage.dbo.TblPage where FldState = ''Active'' and FldId = ' + i.ToString;

  // pagenotfound
  if not FDba.DsFD(q, d, k, true) then
    Response.Content := htm.PageNotFound(FDba)

  // pagenotactive
  else if false then
    Response.Content := htm.PageW(FDba, 'pagenotactive')

  // pagerestrictedforprivileges
  else if false then
    Response.Content := htm.PageW(FDba, 'pagerestrictedforprivileges')

  // pagebelongtodifferentorganization
  else if false then
    Response.Content := htm.PageW(FDba, 'pagebelongtodifferentorganization')

  // pageserve
  else
    Response.Content := htm.Page(FDba,
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
end;
{$ENDREGION}

{$REGION 'Login'}
procedure TWebModule1.WebModule1LoginWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  Response.Content := htm.PageBlank(FDba,
    'User Login'
  , htm.ModUserLogin
  );
end;

procedure TWebModule1.WebModule1LoginTryWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  s: integer;
begin
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
      Response.Content := htm.PageBlank(FDba, 'Password', htm.ModMessage('Incorrect Password', '<p>The password you have entered is not valid.</p><p>Please enter a valid password.</p><br>'));
    ;
  end else
    Response.Content := htm.PageBlank(FDba, 'Username', htm.ModMessage('Unknown Username', '<p>The username you have entered is not valid.</p><p>Please create a new acoount or try to recover your forgotten username and/or password.</p><br>'));
  ;
end;

procedure TWebModule1.WebModule1LogoutWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  r: string; // redirect
begin
  // removesessioncookiefromclient-fromnowonanewloginisnecessary
  wrs.CookieSet('CoSession', '');

  // redirect
  r := obj.DbaParamGet(FDba, 'System', 'LogoutUrl', 'http://www.google.com');
  Response.SendRedirect(r);
end;
{$ENDREGION}

{$REGION 'Account'}
procedure TWebModule1.WebModule1AccountWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  // [...] display the account here, the page have to be self-editing enabled
  Response.Content := htm.PageI(FDba, 'Account', NOT_IMPLEMENTED_STR);
end;

procedure TWebModule1.WebModule1AccountCreateWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  Response.Content := htm.PageBlank(FDba,
    'Account Create'
  , htm.ModUserAccountCreate
  );
end;

procedure TWebModule1.WebModule1AccountCreateTryWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  // [...] try to create account here
  Response.SendRedirect(wre.ScriptName + '/AccountCreateDone');
end;

procedure TWebModule1.WebModule1AccountCreateDoneWebActionAction( Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  Response.Content := htm.PageBlank(FDba,
    'Account Create Done'
  , htm.ModUserAccountCreateDone
  );
end;

procedure TWebModule1.WebModule1AccountRecoverWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  Response.Content := htm.PageBlank(FDba,
    'Account Recover'
  , htm.ModUserAccountRecover
  );
end;

procedure TWebModule1.WebModule1AccountRecoverTryWebActionAction( Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  // [...] try to recover user account here send info to the user
  Response.SendRedirect(wre.ScriptName + '/AccountRecoverDone');
end;

procedure TWebModule1.WebModule1AccountRecoverDoneWebActionAction( Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  Response.Content := htm.PageBlank(FDba,
    'Account Recovering Done'
  , htm.ModUserAccountRecoverDone
  );
end;
{$ENDREGION}

{$REGION 'Social'}
procedure TWebModule1.WebModule1SocialWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  // user's social page
  Response.Content := htm.Page(FDba,
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
end;

procedure TWebModule1.WebModule1MessageWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  Response.Content := htm.PageI(FDba, 'Message', NOT_IMPLEMENTED_STR);
end;

procedure TWebModule1.WebModule1NewsWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  Response.Content := htm.PageI(FDba, 'News', NOT_IMPLEMENTED_STR);
end;

procedure TWebModule1.WebModule1NotificationWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  Response.Content := htm.PageI(FDba, 'Notification', NOT_IMPLEMENTED_STR);
end;
{$ENDREGION}

{$REGION 'Dashboard'}
procedure TWebModule1.WebModule1DashboardWebActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  // [...] display here a dashboard tailored for the user
  // the user might be able to subscribe for different dashboards he is interested in
  // a defaul dashoard should be also provided
  // eventually the used might setup the order of dashoboards to see
  Response.Content := htm.PageI(FDba, 'Dashboard', NOT_IMPLEMENTED_STR);
end;
{$ENDREGION}

{$REGION 'Zzz'}
(*
procedure TWebModule1.WebModule1DefaultHandlerAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  r: string; // redirect
begin
  r := sys.DbaParamGet('DefaultHandlerRedirectTo', '/');
  r := rva.Rv(r);

  if r.IsEmpty then
    Response.Content := htm.HtmlPageNotFound

  else if r.Equals('/') or r.Equals('/WksIsapiProject.dll') or r.Equals('/WksIsapiProject.dll/') then
    Response.Content := htm.HtmlI('Default', Format('Wks Web Application Server - %s', [DateTimeToStr(Now)]))

  else
    Response.SendRedirect(r);
end;
*)
{$ENDREGION}

end.

