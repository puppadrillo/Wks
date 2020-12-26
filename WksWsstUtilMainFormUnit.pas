unit WksWsstUtilMainFormUnit;

interface

{$REGION 'Use'}
uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, System.IniFiles
  , System.Diagnostics    // watch
  ;
{$ENDREGION}

{$REGION 'Type'}
type
  TMainForm = class(TForm)
    TopPanel: TPanel;
    WebsiteEdit: TEdit;
    UrlLabel: TLabel;
    GoButton: TButton;
    LogMemo: TMemo;
    GoThreadButton: TButton;
    RepeatEdit: TEdit;
    ClearAtStartCheckBox: TCheckBox;
    LogActivityOnlyCheckBox: TCheckBox;
    ResultLabel: TLabel;
    ClearButton: TButton;
    LogCheckBox: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure GoButtonClick(Sender: TObject);
    procedure GoThreadButtonClick(Sender: TObject);
    procedure ClearButtonClick(Sender: TObject);
  private
    { Private declarations }
    FIni: TIniFile;
    FCount: integer;
    FWatch: TStopwatch;
  public
    { Public declarations }
  end;
{$ENDREGION}

{$REGION 'Var'}
var
  MainForm: TMainForm;
{$ENDREGION}

implementation

{$REGION 'Use'}
{$R *.dfm}

uses
    Winapi.WinInet        // uses the same stuff of internetexplorer (if IE is misconfigured to use a proxy this is down, obscure, and frustrating if it happens)
  , Winapi.ActiveX        // com
  , System.Win.ComObj     // winhttp
  , System.Net.HttpClient // delphi
  , Vcl.ExtActns          // delphi
  , IdHTTP                // indy
  ;
{$ENDREGION}

{$REGION 'Const'}
const
  USER_AGENT = 'WKS Web Site Strees Test'; // 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0'
{$ENDREGION}

{$REGION 'Type'}
type
  THTTPRequestThread = class(TThread) // thread descendant for single request
  private
    FLogActivityOnly: boolean;
    FRequestURL: string;
    FResponseText: string;
    procedure Execute; override;
    procedure SynchronizeResult;
  public
    constructor Create(const IvRequestURL: string; IvLogActivityOnly: boolean = true);
    destructor Destroy; override;
  end;
{$ENDREGION}

{$REGION 'Routine'}
function  UrlContentGetWinInet(const IvUrl: string): string;
var
  NetHandle: HINTERNET;
  UrlHandle: HINTERNET;
  Buffer: array[0..1024] of char;
  BytesRead: dword;
  StrBuffer: UTF8String;
begin
  Result := '';
  NetHandle := InternetOpen(USER_AGENT, INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  if not Assigned(NetHandle) then begin
    raise Exception.Create('Unable to initialize Wininet');
  end else begin
    try
      UrlHandle := InternetOpenUrl(NetHandle, PChar(IvUrl), nil, 0, INTERNET_FLAG_RELOAD, 0);
      if not Assigned(UrlHandle) then begin
        raise Exception.CreateFmt('Cannot open url %s', [IvUrl]);
      end else begin
        try
          // proceed with download
          FillChar(Buffer, SizeOf(Buffer), 0);
          repeat
            Result := Result + Buffer;
            FillChar(Buffer, SizeOf(Buffer), 0);
            InternetReadFile(UrlHandle, @Buffer, SizeOf(Buffer), BytesRead);
          until BytesRead = 0;
        finally
          InternetCloseHandle(UrlHandle);
        end;
      end;
    finally
      InternetCloseHandle(NetHandle);
    end;
  end;
end;

function  UrlContentGetIndy(const IvUrl: string): string;
var
  h: TIdHTTP;
begin
  h := TIdHTTP.Create;
  try
    Result := h.Get(IvUrl);
  finally
    h.Free;
  end;
end;

function  UrlContentGetDelphi(const IvUrl: string): string;
var
  c: THttpClient;
  r: IHttpResponse;
begin
  c := THTTPClient.Create;
  try
    r := c.Get(IvUrl);
    Result := r.ContentAsString();
  finally
    c.Free;
  end;
end;

function  UrlContentGetWinHttp(const IvUrl: string): string;
var
  r: variant; // winhttprequest
begin
  r := CreateOleObject('WinHttp.WinHttpRequest.5.1');
  r.Open('GET', IvUrl, false);
  r.SetRequestHeader('User-Agent', USER_AGENT);
  r.Send();
  Result := r.ResponseText;
end;

function  UrlContentGetWinHttpThreaded(const IvUrl: string): string;
begin
  TThread.CreateAnonymousThread(
    procedure
    var
      r: OleVariant; // winhttprequest
    begin
      // COM library initialization for the current thread
      CoInitialize(nil);
      try
        // create the WinHttpRequest object instance
        r := CreateOleObject('WinHttp.WinHttpRequest.5.1');
        // open HTTP connection with GET method in synchronous mode
        r.Open('GET', IvUrl, false);
        // set the User-Agent header value
        r.SetRequestHeader('User-Agent', USER_AGENT);
        // sends the HTTP request to the server
        r.Send(); // this method does not return until WinHTTP completely receives the response (synchronous mode)
        ShowMessage(r.ResponseText);
        // store the response into a field for synchronization
      //FResponseText := r.ResponseText;
        // execute the SynchronizeResult method within the main thread context
      //Synchronize(SynchronizeResult);
      finally
        // release the WinHttpRequest object instance
        r := Unassigned;
        // uninitialize COM library with all resources
        CoUninitialize;
      end;
    end
  ).Start;
end;

procedure UrlFileDownload(const IvUrl, IvFileDest: string);
var
  d: TDownloadURL;
begin
  d := TDownloadURL.Create(nil);
  try
    d.URL := IvUrl;
    d.FileName := IvFileDest;
    d.ExecuteTarget(nil); // this downloads the file
  finally
    d.Free;
  end;
end;
{$ENDREGION}

{$REGION 'THTTPRequestThread'}
constructor THTTPRequestThread.Create(const IvRequestURL: string; IvLogActivityOnly: boolean);
begin
  // create and start the thread after create
  inherited Create(false);
  // free the thread after THTTPRequest.Execute returns
  FreeOnTerminate := true;
  // store the passed parameters into the fields for future use
  FLogActivityOnly := IvLogActivityOnly;
  FRequestURL := IvRequestURL;
end;

destructor THTTPRequestThread.Destroy;
begin
  // nothingtodo

  inherited;
end;

procedure THTTPRequestThread.Execute;
var
  Request: OleVariant;
begin
  inherited;
  // COM library initialization for the current thread
  CoInitialize(nil);
  try
    // create the WinHttpRequest object instance
    Request := CreateOleObject('WinHttp.WinHttpRequest.5.1');
    // open HTTP connection with GET method in synchronous mode
    Request.Open('GET', FRequestURL, False);
    // set the User-Agent header value
    Request.SetRequestHeader('User-Agent', USER_AGENT);
    // sends the HTTP request to the server
    Request.Send; // this method does not return until WinHTTP completely receives the response (synchronous mode)
    // store the response into the field for synchronization
    FResponseText := Request.ResponseText;
    // execute the SynchronizeResult method within the main thread context
    Synchronize(SynchronizeResult);
  finally
    // release the WinHttpRequest object instance
    Request := Unassigned;
    // uninitialize COM library with all resources
    CoUninitialize;
  end;
end;

procedure THTTPRequestThread.SynchronizeResult;
begin
  // because of calling this method through Synchronize it is safe to access
  // the VCL controls from the main thread here, so let's fill the memo text
  // with the HTTP response stored before
  Inc(MainForm.FCount);
  if MainForm.LogCheckBox.Checked then begin
    MainForm.LogMemo.Lines.Add(Format('thread %3d', [MainForm.FCount]));
    if FLogActivityOnly then
      MainForm.LogMemo.Lines.Add(Self.ThreadID.ToString)
    else
      MainForm.LogMemo.Lines.Add(FResponseText);
  end;
  if MainForm.FCount = StrToInt(MainForm.RepeatEdit.Text) then begin
    MainForm.ResultLabel.Caption := Format('%f s   %f req/s', [MainForm.FWatch.ElapsedMilliseconds / 1000, MainForm.FCount / (MainForm.FWatch.ElapsedMilliseconds / 1000)]);
    Screen.Cursor := crDefault;
  end;
end;
{$ENDREGION}

{$REGION 'Form'}
procedure TMainForm.FormCreate(Sender: TObject);
var
  f: string;
begin
  // init
  Caption := 'WKS Web Site Strees Test';
  LogMemo.Clear;

  // ini
  f := ChangeFileExt(Application.ExeName, '.ini');
  FIni := TIniFile.Create(f);
  WebsiteEdit.Text                := FIni.ReadString('Option', 'Website'        , 'http://localhost/WksTestIsapiProject.dll');
  RepeatEdit.Text                 := FIni.ReadString('Option', 'Repeat'         , '10');
  LogActivityOnlyCheckBox.Checked := FIni.ReadBool  ('Option', 'LogActivityOnly', true);
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FIni.WriteString('Option', 'Website'        , WebsiteEdit.Text);
  FIni.WriteString('Option', 'Repeat'         , RepeatEdit.Text);
  FIni.WriteBool  ('Option', 'LogActivityOnly', LogActivityOnlyCheckBox.Checked);
  FIni.Free;
end;
{$ENDREGION}

{$REGION 'Action'}
procedure TMainForm.ClearButtonClick(Sender: TObject);
begin
  LogMemo.Clear;
end;

procedure TMainForm.GoButtonClick(Sender: TObject);
var
  r: string;
begin
//r := UrlContentGetWinInet(WebsiteEdit.Text);
//r := UrlContentGetIndy(WebsiteEdit.Text);
//r := UrlContentGetDelphi(WebsiteEdit.Text);
  r := UrlContentGetWinHttp(WebsiteEdit.Text);
  if ClearAtStartCheckBox.Checked then
    LogMemo.Clear;
  LogMemo.Lines.Add(r);
end;

procedure TMainForm.GoThreadButtonClick(Sender: TObject);
var
  i: integer;
begin
  // thread will start (Execute) immediately after creation (createsuspended = false)
  // because the thread will be destroyed immediately after the Execute method finishes
  // (it's because FreeOnTerminate is set to True) and because we are not reading any values from
  // the thread (it fills the memo box with the response for us in SynchronizeResult method) we
  // don't need to store its object instance anywhere as well as we don't need to care about freeing it
  if ClearAtStartCheckBox.Checked then
    LogMemo.Clear;
  FCount := 0;
  FWatch.Reset;
  FWatch.Start;
  Screen.Cursor := crHourGlass;
  for i := 0 to StrToIntDef(RepeatEdit.Text, 1) - 1 do
    THTTPRequestThread.Create(WebsiteEdit.Text, LogActivityOnlyCheckBox.Checked);
end;
{$ENDREGION}

end.
