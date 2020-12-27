unit WksWsstUtilMainFormUnit;

interface

{$REGION 'Use'}
uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, System.IniFiles
  , System.Diagnostics, VclTee.TeeGDIPlus, VCLTee.TeEngine, VCLTee.TeeProcs,
  VCLTee.Chart, VCLTee.Series    // watch
  ;
{$ENDREGION}

{$REGION 'Type'}
type
  TMainForm = class(TForm)
    TopPanel: TPanel;
    UrlLabel: TLabel;
    GoButton: TButton;
    LogMemo: TMemo;
    GoThreadButton: TButton;
    RepeatEdit: TEdit;
    ClearAtStartCheckBox: TCheckBox;
    LogResponseCheckBox: TCheckBox;
    ResultLabel: TLabel;
    ClearButton: TButton;
    LogCheckBox: TCheckBox;
    UrlComboBox: TComboBox;
    ChartPanel: TPanel;
    Splitter1: TSplitter;
    TickChart: TChart;
    Series1: TPointSeries;
    WebsiteComboBox: TComboBox;
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
    FTickCountVec: array of integer;
    function UrlGet: string;
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
    FLogResponse: boolean;
    FTickCount: cardinal;
    FRequestURL: string;
    FResponseText: string;
    procedure Execute; override;
    procedure SynchronizeResult;
  public
    constructor Create(const IvRequestURL: string; IvLogResponse: boolean = true);
    destructor Destroy; override;
  end;
{$ENDREGION}

{$REGION 'Routine'}
function GetProcessID: Cardinal; register; assembler;
{$IFDEF 32BIT}
asm
  mov eax, FS:[$20]
end;
{$ELSE}
begin
  Result := Winapi.Windows.GetCurrentProcessId;
end;
{$ENDIF}

function GetThreadId: Cardinal; register; assembler;
{$IFDEF 32BIT}
asm
  mov eax, FS:[$24]
end;
{$ELSE}
begin
  Result := Winapi.Windows.GetCurrentThreadID;
end;
{$ENDIF}

function TMainForm.UrlGet: string;
begin
  Result := WebsiteComboBox.Text + UrlComboBox.Text;
end;

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
constructor THTTPRequestThread.Create(const IvRequestURL: string; IvLogResponse: boolean);
begin
  // create and start the thread after create
  inherited Create(false);
  // free the thread after THTTPRequest.Execute returns
  FreeOnTerminate := true;
  // store the passed parameters into the fields for future use
  FLogResponse := IvLogResponse;
  FRequestURL := IvRequestURL;
end;

destructor THTTPRequestThread.Destroy;
begin
  // nothingtodo

  inherited;
end;

procedure THTTPRequestThread.Execute;
var
  r: OleVariant; // request
  t: dword; // tick
begin
  inherited;
  // COM library initialization for the current thread
  CoInitialize(nil);
  try
    // create the WinHttpRequest object instance
    r := CreateOleObject('WinHttp.WinHttpRequest.5.1');
    // open HTTP connection with GET method in synchronous mode
    r.Open('GET', FRequestURL, false);
    // set the User-Agent header value
    r.SetRequestHeader('User-Agent', USER_AGENT);

    // sends the HTTP request to the server
    t := GetTickCount;
      r.Send; // this method does not return until WinHTTP completely receives the response (synchronous mode)
    FTickCount := GetTickCount - t;

    // store the response into a field for synchronization
    FResponseText := r.ResponseText;
    // execute the SynchronizeResult method within the main thread context
    Synchronize(SynchronizeResult);
  finally
    // release the WinHttpRequest object instance
    r := Unassigned;
    // uninitialize COM library with all resources
    CoUninitialize;
  end;
end;

procedure THTTPRequestThread.SynchronizeResult;
var
  i: Integer;
  p: TPointSeries;
begin
  // because of calling this method through Synchronize it is safe to access
  // the VCL controls from the main thread here, so let's fill the memo text
  // with the HTTP response stored before
  MainForm.FTickCountVec[MainForm.FCount] := FTickCount;
  Inc(MainForm.FCount);
  if MainForm.LogCheckBox.Checked then begin
    MainForm.LogMemo.Lines.Add(Format('%4d pid:%5d tid:%5d worker:%5d ticks:%5d', [MainForm.FCount, WksWsstUtilMainFormUnit.GetProcessID, WksWsstUtilMainFormUnit.GetThreadId, Self.ThreadID, FTickCount]));
    if FLogResponse then
      MainForm.LogMemo.Lines.Add(FResponseText);
  end;

  // theend
  if MainForm.FCount = StrToInt(MainForm.RepeatEdit.Text) then begin
    // logmemo
    MainForm.ResultLabel.Caption := Format('%f s   %f req/s', [MainForm.FWatch.ElapsedMilliseconds / 1000, MainForm.FCount / (MainForm.FWatch.ElapsedMilliseconds / 1000)]);
    MainForm.LogMemo.Lines.EndUpdate;

    // chart
    for i := MainForm.TickChart.SeriesCount-1 downto 0 do
      MainForm.TickChart.Series[i].Free;

    p := TPointSeries.Create(MainForm.TickChart);
    p.Pointer.Style := psCircle;
    p.Pointer.Color := clRed;
    p.Pointer.Size  := 3;
    MainForm.TickChart.AddSeries(p);
    for i := Low(MainForm.FTickCountVec) to High(MainForm.FTickCountVec) do
      MainForm.TickChart.Series[0].AddXY(i, MainForm.FTickCountVec[i]);
    MainForm.TickChart.Repaint;

    // gui
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
  WebsiteComboBox.Items.Add('http://localhost');
  WebsiteComboBox.Items.Add('http://wks.cloud');
  WebsiteComboBox.Items.Add('http://wks.cloud:8080');
  UrlComboBox.Items.Add('/WksIsapiProject.dll');
  UrlComboBox.Items.Add('/WksTestIsapiProject.dll');

  // ini
  f := ChangeFileExt(Application.ExeName, '.ini');
  FIni := TIniFile.Create(f);
  WebsiteComboBox.Text        := FIni.ReadString('Option', 'Website'    , 'http://localhost');
  UrlComboBox.Text            := FIni.ReadString('Option', 'Url'        , '/WksTestIsapiProject.dll');
  RepeatEdit.Text             := FIni.ReadString('Option', 'Repeat'     , '10');
  LogResponseCheckBox.Checked := FIni.ReadBool  ('Option', 'LogResponse', true);
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FIni.WriteString('Option', 'Website'    , WebsiteComboBox.Text);
  FIni.WriteString('Option', 'Url'        , UrlComboBox.Text);
  FIni.WriteString('Option', 'Repeat'     , RepeatEdit.Text);
  FIni.WriteBool  ('Option', 'LogResponse', LogResponseCheckBox.Checked);
  FIni.Free;
end;
{$ENDREGION}

{$REGION 'Action'}
procedure TMainForm.ClearButtonClick(Sender: TObject);
var
  i: integer;
begin
  // memo
  LogMemo.Clear;

  // chart
  for i := MainForm.TickChart.SeriesCount-1 downto 0 do
    MainForm.TickChart.Series[i].Free;
end;

procedure TMainForm.GoButtonClick(Sender: TObject);
var
  r: string;
begin
//r := UrlContentGetWinInet(UrlGet);
//r := UrlContentGetIndy(UrlGet);
//r := UrlContentGetDelphi(UrlGet);
  r := UrlContentGetWinHttp(UrlGet);
  if ClearAtStartCheckBox.Checked then
    LogMemo.Clear;
  if MainForm.LogCheckBox.Checked then begin
    MainForm.LogMemo.Lines.Add(Format('pid:%5d tid:%5d', [GetProcessID, GetThreadId]));
    if LogResponseCheckBox.Checked then
      MainForm.LogMemo.Lines.Add(r);
  end;
end;

procedure TMainForm.GoThreadButtonClick(Sender: TObject);
var
  z, i: integer;
begin
  // thread will start (Execute) immediately after creation (createsuspended = false)
  // because the thread will be destroyed immediately after the Execute method finishes
  // (it's because FreeOnTerminate is set to True) and because we are not reading any values from
  // the thread (it fills the memo box with the response for us in SynchronizeResult method) we
  // don't need to store its object instance anywhere as well as we don't need to care about freeing it
  if ClearAtStartCheckBox.Checked then begin
    LogMemo.Clear;
    Application.ProcessMessages;
  end;
  FCount := 0;
  z := StrToIntDef(RepeatEdit.Text, 1);
  FWatch.Reset;
  FWatch.Start;
  Screen.Cursor := crHourGlass;
  LogMemo.Lines.BeginUpdate;
  SetLength(FTickCountVec, z);
  for i := 0 to z - 1 do
    THTTPRequestThread.Create(UrlGet, LogResponseCheckBox.Checked);
end;
{$ENDREGION}

end.
