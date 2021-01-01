unit WksWsstUtilMainFormUnit;

interface

{$REGION 'Use'}
uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, System.IniFiles
  , Vcl.OleCtrls, SHDocVw, Vcl.ComCtrls
  , System.Diagnostics
  , VclTee.TeeGDIPlus, VCLTee.TeEngine, VCLTee.TeeProcs, VCLTee.Chart, VCLTee.Series,
  SynEdit
  ;
{$ENDREGION}

{$REGION 'Type'}
type
  TMainForm = class(TForm)
    TopPanel: TPanel;
    UrlLabel: TLabel;
    GoButton: TButton;
    StartButton: TButton;
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
    MainPageControl: TPageControl;
    WsstTabSheet: TTabSheet;
    WsstMemo: TMemo;
    IeTabSheet: TTabSheet;
    IeWebBrowser: TWebBrowser;
    PortComboBox: TComboBox;
    RepeatComboBox: TComboBox;
    ThreadGoButton: TButton;
    AgentRadioGroup: TRadioGroup;
    LogTabSheet: TTabSheet;
    LogPanel: TPanel;
    LogRefreshButton: TButton;
    PathInfoComboBox: TComboBox;
    QueryEdit: TEdit;
    LogClearButton: TButton;
    LogSynEdit: TSynEdit;
    LogScrollDownButton: TButton;
    LogDeleteButton: TButton;
    ChromeTabSheet: TTabSheet;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure GoButtonClick(Sender: TObject);
    procedure StartButtonClick(Sender: TObject);
    procedure ClearButtonClick(Sender: TObject);
    procedure IeWebBrowserBeforeNavigate2(ASender: TObject; const pDisp: IDispatch; const URL, Flags, TargetFrameName, PostData, Headers: OleVariant; var Cancel: WordBool);
    procedure IeWebBrowserDocumentComplete(ASender: TObject; const pDisp: IDispatch; const URL: OleVariant);
    procedure IeWebBrowserNavigateComplete2(ASender: TObject; const pDisp: IDispatch; const URL: OleVariant);
    procedure ThreadGoButtonClick(Sender: TObject);
    procedure AgentRadioGroupClick(Sender: TObject);
    procedure LogRefreshButtonClick(Sender: TObject);
    procedure LogClearButtonClick(Sender: TObject);
    procedure LogScrollDownButtonClick(Sender: TObject);
    procedure LogDeleteButtonClick(Sender: TObject);
  private
    { Private declarations }
    FIni: TIniFile;
    FCount: integer;
    FWatch: TStopwatch;
    FDispatch: IDispatch;
    FIeLoaded: boolean;
    FTickCountVec: array of integer;
    function UrlGet: string;
    function RepeatGet: integer;
    function ResultsGet(IvMs, IvRepeat: integer): string;
    function ResultLineGet(IvLineNo, IvTicks: integer): string;
    function LogFileNameGet: string;
    procedure ChartDraw();
    procedure GuiClear;
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
  , System.DateUtils      // datetime
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
  Result := WebsiteComboBox.Text + PortComboBox.Text + UrlComboBox.Text + PathInfoComboBox.Text + QueryEdit.Text;
end;

function TMainForm.RepeatGet: integer;
begin
  Result := StrToIntDef(RepeatComboBox.Text, 1);
end;

function TMainForm.ResultLineGet(IvLineNo, IvTicks: integer): string;
begin
  Result := Format('%4d pid:%5d tid:%5d worker:%5d ticks:%5d', [IvLineNo, GetProcessID, GetThreadId, -1, IvTicks])
end;

function TMainForm.ResultsGet(IvMs, IvRepeat: integer): string;
begin
  Result := Format('%f s   %f req/s', [IvMs / 1000, IvRepeat / (IvMs / 1000)]);
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

procedure TMainForm.ChartDraw;
var
  i: integer;
  p: TPointSeries;
begin
  for i := TickChart.SeriesCount-1 downto 0 do
    TickChart.Series[i].Free;
  p := TPointSeries.Create(TickChart);
  p.Pointer.Style := psCircle;
  p.Pointer.Color := clRed;
  p.Pointer.Size  := 3;
  p.Pointer.Pen.Visible := false;
  TickChart.AddSeries(p);
  for i := Low(FTickCountVec) to High(FTickCountVec) do
    TickChart.Series[0].AddXY(i, FTickCountVec[i]);
  TickChart.Repaint;
end;

procedure TMainForm.GuiClear;
var
  i: integer;
begin
  // memo
  WsstMemo.Clear;

  // results
  ResultLabel.Caption := '';

  // chart
  for i := MainForm.TickChart.SeriesCount-1 downto 0 do
    MainForm.TickChart.Series[i].Free;

  // ie
  IeWebBrowser.Navigate('about:blank');

  Application.ProcessMessages;
end;
{$ENDREGION}

{$REGION 'THTTPRequestThread'}
constructor THTTPRequestThread.Create(const IvRequestURL: string; IvLogResponse: boolean);
begin
  inherited Create(false);       // create and start the thread after create
  FreeOnTerminate := true;       // free the thread after THTTPRequest.Execute returns
  FLogResponse := IvLogResponse; // store the passed parameters into the fields for future use
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
  CoInitialize(nil); // com library initialization for the current thread
  try
    r := CreateOleObject('WinHttp.WinHttpRequest.5.1'); // create the WinHttpRequest object instance
    r.Open('GET', FRequestURL, false);                  // open HTTP connection with GET method in synchronous mode
    r.SetRequestHeader('User-Agent', USER_AGENT);       // set the User-Agent header value
    t := GetTickCount;
    r.Send;                                            // sends the HTTP request to the server, this method does not return until WinHTTP completely receives the response (synchronous mode)
    FTickCount := GetTickCount - t;                    // store the ticks into a field for synchronization
    FResponseText := r.ResponseText;                   // store the response into a field for synchronization
    Synchronize(SynchronizeResult);                    // execute the SynchronizeResult method within the main thread context
  finally
    r := Unassigned; // release the WinHttpRequest object instance
    CoUninitialize;  // uninitialize COM library with all resources
  end;
end;

procedure THTTPRequestThread.SynchronizeResult;
var
  i: Integer;
  p: TPointSeries;
begin
  // Synchronize execute in the main thread context so it is safe to access the vcl controls and other variaboel in that context
  // so lets save the ticks and log the HTTP response stored before
  MainForm.FTickCountVec[MainForm.FCount] := FTickCount;
  Inc(MainForm.FCount);
  if MainForm.LogCheckBox.Checked then begin
    MainForm.WsstMemo.Lines.Add(Format('%4d pid:%5d tid:%5d worker:%5d ticks:%5d', [MainForm.FCount, WksWsstUtilMainFormUnit.GetProcessID, WksWsstUtilMainFormUnit.GetThreadId, Self.ThreadID, FTickCount]));
    if FLogResponse then
      MainForm.WsstMemo.Lines.Add(FResponseText);
  end;

  // end
  if MainForm.FCount = StrToInt(MainForm.RepeatComboBox.Text) then begin
    MainForm.ResultLabel.Caption := MainForm.ResultsGet(MainForm.FWatch.ElapsedMilliseconds, MainForm.FCount);
    MainForm.ChartDraw;
    MainForm.WsstMemo.Lines.EndUpdate;
    Screen.Cursor := crDefault;
  end;
end;
{$ENDREGION}

{$REGION 'Ie'}
procedure TMainForm.IeWebBrowserBeforeNavigate2(ASender: TObject; const pDisp: IDispatch; const URL, Flags, TargetFrameName, PostData, Headers: OleVariant; var Cancel: WordBool);
begin
  FDispatch := nil;
  FIeLoaded := false;
end;

procedure TMainForm.IeWebBrowserDocumentComplete(ASender: TObject; const pDisp: IDispatch; const URL: OleVariant);
begin
  if (pDisp = FDispatch) then begin
    FDispatch := nil;
    FIeLoaded := true;
  end;
end;

procedure TMainForm.IeWebBrowserNavigateComplete2(ASender: TObject; const pDisp: IDispatch; const URL: OleVariant);
begin
  if FDispatch = nil then
    FDispatch := pDisp;
end;
{$ENDREGION}

{$REGION 'Form'}
procedure TMainForm.FormCreate(Sender: TObject);
var
  f: string;
begin
  // init
  WsstMemo.Clear;
  LogSynEdit.Clear;
  Caption := 'WKS Web Site Strees Test';
  WebsiteComboBox.Items.Add('http://localhost');
  WebsiteComboBox.Items.Add('http://wks.cloud');
  PortComboBox.Items.Add(':80');
  PortComboBox.Items.Add(':8080');
  UrlComboBox.Items.Add('/WksIsapiProject.dll');
  UrlComboBox.Items.Add('/WksTestCgiProject.exe');
  UrlComboBox.Items.Add('/WksTestIsapiProject.dll');
  PathInfoComboBox.Items.Add('');
  PathInfoComboBox.Items.Add('/');
  PathInfoComboBox.Items.Add('/Default');
  PathInfoComboBox.Items.Add('/Info');

  // ini
  f := ChangeFileExt(Application.ExeName, '.ini');
  FIni := TIniFile.Create(f);
  WebsiteComboBox.Text         := FIni.ReadString ('Option', 'Website'     , 'http://localhost');
  PortComboBox.Text            := FIni.ReadString ('Option', 'Port'        , ':80');
  UrlComboBox.Text             := FIni.ReadString ('Option', 'Url'         , '/WksTestIsapiProject.dll');
  PathInfoComboBox.Text        := FIni.ReadString ('Option', 'PathInfo'    , '');
  QueryEdit.Text               := FIni.ReadString ('Option', 'Query'       , '');
  RepeatComboBox.Text          := FIni.ReadString ('Option', 'Repeat'      , '10');
  LogCheckBox.Checked          := FIni.ReadBool   ('Option', 'Log'         , true);
  LogResponseCheckBox.Checked  := FIni.ReadBool   ('Option', 'LogResponse' , true);
  AgentRadioGroup.ItemIndex    := FIni.ReadInteger('Option', 'Agent'       , 0);
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // ini
  FIni.WriteString ('Option', 'Website'     , WebsiteComboBox.Text);
  FIni.WriteString ('Option', 'Port'        , PortComboBox.Text);
  FIni.WriteString ('Option', 'Url'         , UrlComboBox.Text);
  FIni.WriteString ('Option', 'PathInfo'    , PathInfoComboBox.Text);
  FIni.WriteString ('Option', 'Query'       , QueryEdit.Text);
  FIni.WriteString ('Option', 'Repeat'      , RepeatComboBox.Text);
  FIni.WriteBool   ('Option', 'Log'         , LogCheckBox.Checked);
  FIni.WriteBool   ('Option', 'LogResponse' , LogResponseCheckBox.Checked);
  FIni.WriteInteger('Option', 'Agent'       , AgentRadioGroup.ItemIndex);
  FIni.Free;
end;
{$ENDREGION}

{$REGION 'Option'}
procedure TMainForm.AgentRadioGroupClick(Sender: TObject);
begin
  MainPageControl.ActivePageIndex := AgentRadioGroup.ItemIndex;
end;
{$ENDREGION}

{$REGION 'Action'}
procedure TMainForm.ClearButtonClick(Sender: TObject);
begin
  GuiClear;
end;

procedure TMainForm.GoButtonClick(Sender: TObject);
var
  r: string;
begin
  // clear
  if ClearAtStartCheckBox.Checked then
    GuiClear;

  // timer
  FWatch.Reset;
  FWatch.Start;

  // wsst
  if AgentRadioGroup.ItemIndex = 0 then begin
  //r := UrlContentGetWinInet(UrlGet);
  //r := UrlContentGetIndy(UrlGet);
  //r := UrlContentGetDelphi(UrlGet);
    r := UrlContentGetWinHttp(UrlGet);

  // ie
  end else begin
    IeWebBrowser.Navigate(UrlGet);
    repeat Application.ProcessMessages until FIeLoaded;
    r := 'not available';
  end;

  // results
  ResultLabel.Caption := ResultsGet(FWatch.ElapsedMilliseconds, 1);

  // log
  if LogCheckBox.Checked then begin
    WsstMemo.Lines.Add(Format('pid:%5d tid:%5d %d ms', [GetProcessID, GetThreadId, FWatch.ElapsedMilliseconds]));
    if LogResponseCheckBox.Checked then
      WsstMemo.Lines.Add(r);
  end;
end;

procedure TMainForm.StartButtonClick(Sender: TObject);
var
  z, i, t: integer; // range, counter, tick
  r: OleVariant; // request
  s: string;
begin
  // init
  GuiClear;
  FCount := 0;
  z := RepeatGet;
  SetLength(FTickCountVec, z);
  FWatch.Reset;
  FWatch.Start;

  // go
  Screen.Cursor := crHourGlass;
  WsstMemo.Lines.BeginUpdate;
  try
    // wsst
    if AgentRadioGroup.ItemIndex = 0 then begin
      CoInitialize(nil); // com library initialization
      try
        r := CreateOleObject('WinHttp.WinHttpRequest.5.1'); // create the WinHttpRequest object instance
        r.Open('GET', UrlGet, false); // open HTTP connection with GET method in synchronous mode
        r.SetRequestHeader('User-Agent', USER_AGENT); // set the User-Agent header value
        // mainthreadsequentially
        for i := 0 to z - 1 do begin
          t := GetTickCount;
          r.Send; // sends the HTTP request to the server, this method does not return until WinHTTP completely receives the response (synchronous mode)
          s := r.ResponseText;
          FTickCountVec[FCount] := GetTickCount - t;
          if LogCheckBox.Checked then begin
            WsstMemo.Lines.Add(ResultLineGet(i, FTickCountVec[FCount]));
            if LogResponseCheckBox.Checked then
              WsstMemo.Lines.Add(s);
          end;
          Inc(FCount);
        end;
      finally
        r := Unassigned; // release the WinHttpRequest object instance
        CoUninitialize; // uninitialize COM library with all resources
      end;

    // ie
    end else begin
      // iesequentially
      for i := 0 to z - 1 do begin
        t := GetTickCount;
        IeWebBrowser.Navigate(UrlGet);
        repeat Application.ProcessMessages until FIeLoaded;
        s := 'not available';
        FTickCountVec[FCount] := GetTickCount - t;
        if LogCheckBox.Checked then begin
          WsstMemo.Lines.Add(ResultLineGet(i, FTickCountVec[FCount]));
          if LogResponseCheckBox.Checked then
            WsstMemo.Lines.Add(s);
        end;
        Inc(FCount);
      end;
    end;

  finally
    WsstMemo.Lines.EndUpdate;
    Screen.Cursor := crDefault;
  end;

  // results
  ResultLabel.Caption := ResultsGet(FWatch.ElapsedMilliseconds, z);;
  ChartDraw;
end;

procedure TMainForm.ThreadGoButtonClick(Sender: TObject);
var
  i: integer;
begin
  // thread will start (Execute) immediately after creation (createsuspended = false)
  // because the thread will be destroyed immediately after the Execute method finishes
  // (it's because FreeOnTerminate is set to True) and because we are not reading any values from
  // the thread (it fills the memo box with the response for us in SynchronizeResult method) we
  // don't need to store its object instance anywhere as well as we don't need to care about freeing it
  Screen.Cursor := crHourGlass;
  WsstMemo.Lines.BeginUpdate;
  for i := 0 to RepeatGet - 1 do
    THTTPRequestThread.Create(UrlGet, LogResponseCheckBox.Checked);
end;
{$ENDREGION}

{$REGION 'Log'}
procedure TMainForm.LogClearButtonClick(Sender: TObject);
begin
  LogSynEdit.Clear;
  LogSynEdit.Lines.SaveToFile(LogFileNameGet);
end;

procedure TMainForm.LogDeleteButtonClick(Sender: TObject);
var
  f: string;
begin
  f := LogFileNameGet;
  if DeleteFile(f) then begin
    LogClearButton.Click;
    ShowMessage(f + ' deleted');
  end;
end;

function TMainForm.LogFileNameGet: string;
begin
  Result := Format('_%d-%.*d.log', [YearOf(Date), 2, MonthOf(Date)]);
  Result := ChangeFileExt(UrlComboBox.Text, Result);
  Result := StringReplace(Result, '/', '\', [rfReplaceAll]);
  Result := Format('.%s', [Result]); // WksTestIsapiProject_2021-01
end;

procedure TMainForm.LogRefreshButtonClick(Sender: TObject);
begin
  LogSynEdit.Lines.LoadFromFile(LogFileNameGet);
end;

procedure TMainForm.LogScrollDownButtonClick(Sender: TObject);
begin
//SendMessage(LogSynEdit.Handle, EM_LINESCROLL, 0, LogSynEdit.Lines.Count);
  LogSynEdit.TopLine := LogSynEdit.Lines.Count - LogSynEdit.LinesInWindow;
end;
{$ENDREGION}

end.
