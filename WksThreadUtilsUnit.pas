unit WksThreadUtilsUnit;

(*
  incorporated into wks framework from Chris Baldwin
  @ http://www.alivetechnology.com
  @ http://delphi.cjcsoft.net/viewthread.php?tid=45763
*)

interface

{$REGION 'Use'}
uses
    Winapi.Windows
  , System.SysUtils
  , System.Classes
  ;
{$ENDREGION}

{$REGION 'Type'}
type
  EThreadStackFinalized = class(Exception);
  TThreadSimple = class;

  // thread safe pointer queue
  TThreadQueue = class
  private
    FIOQueue: THandle;
    FFinalized: boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Finalize;
    procedure Push(Data: Pointer);
    function Pop(var Data: Pointer): boolean;
    property Finalized: boolean read FFinalized;
  end;

  TThreadExecuteEvent = procedure (Thread: TThread) of object;

  TThreadSimple = class(TThread)
  private
    FExecuteEvent: TThreadExecuteEvent;
  protected
    procedure Execute(); override;
  public
    constructor Create(CreateSuspended: boolean; ExecuteEvent: TThreadExecuteEvent; AFreeOnTerminate: boolean);
  end;

  TThreadPoolEvent = procedure(Data: pointer; AThread: TThread) of Object;

  TThreadPool = class(TObject)
  private
    FThreadList: TList;
    FThreadQueue: TThreadQueue;
    FThreadPoolEventHandle: TThreadPoolEvent;
    procedure ThreadHandleExecute(Thread: TThread);
  public
    constructor Create(ThreadPoolEventHandle: TThreadPoolEvent; MaxThreads: Integer = 1); virtual;
    destructor Destroy; override;
    procedure Add(const Data: pointer);
  end;
{$ENDREGION}

implementation

{$REGION 'TThreadQueue'}
constructor TThreadQueue.Create;
begin
  // create io completion queue
  FIOQueue := CreateIOCompletionPort(INVALID_HANDLE_VALUE, 0, 0, 0);
  FFinalized := false;
end;

destructor TThreadQueue.Destroy;
begin
  // destroy completion queue
  if (FIOQueue <> 0) then // ???
    CloseHandle(FIOQueue);

  inherited;
end;

procedure TThreadQueue.Finalize;
begin
  // post a finialize pointer on to the queue
  PostQueuedCompletionStatus(FIOQueue, 0, 0, pointer($FFFFFFFF));
  FFinalized := true;
end;

function TThreadQueue.Pop(var Data: pointer): boolean; // pop will return false if the queue is completed
var
  A: cardinal;
  OL: POverLapped;
begin
  Result := true;

  // remove/pop the first pointer from the queue or wait
  if (not FFinalized) then
    GetQueuedCompletionStatus(FIOQueue, A, ULONG_PTR(Data), OL, INFINITE);

  // check if we have finalized the queue for completion
  if FFinalized or (OL = pointer($FFFFFFFF)) then begin
    Data := nil;
    Result := false;
    Finalize;
  end;
end;

procedure TThreadQueue.Push(Data: pointer);
begin
  if FFinalized then
    raise EThreadStackFinalized.Create('Stack is finalized');

  // add/push a pointer on to the end of the queue
  PostQueuedCompletionStatus(FIOQueue, 0, Cardinal(Data), nil);
end;
{$ENDREGION}

{$REGION 'TThreadSimple'}
constructor TThreadSimple.Create(CreateSuspended: boolean; ExecuteEvent: TThreadExecuteEvent; AFreeOnTerminate: boolean);
begin
  FreeOnTerminate := AFreeOnTerminate;
  FExecuteEvent := ExecuteEvent;
  inherited Create(CreateSuspended);
end;

procedure TThreadSimple.Execute;
begin
  inherited;

  if Assigned(FExecuteEvent) then
    FExecuteEvent(Self);
end;
{$ENDREGION}

{$REGION 'TThreadPool'}
procedure TThreadPool.Add(const Data: pointer);
begin
  FThreadQueue.Push(Data);
end;

constructor TThreadPool.Create(ThreadPoolEventHandle: TThreadPoolEvent; MaxThreads: Integer);
begin
  FThreadPoolEventHandle := ThreadPoolEventHandle;
  FThreadQueue := TThreadQueue.Create;
  FThreadList := TList.Create;
  while FThreadList.Count < MaxThreads do
    FThreadList.Add(TThreadSimple.Create(false, ThreadHandleExecute, false));
end;

destructor TThreadPool.Destroy;
var
  t: Integer;
begin
  FThreadQueue.Finalize;
  for t := 0 to FThreadList.Count-1 do
    TThread(FThreadList[t]).Terminate;
  while (FThreadList.Count > 0) do begin
    TThread(FThreadList[0]).WaitFor;
    TThread(FThreadList[0]).Free;
    FThreadList.Delete(0);
  end;
  FThreadQueue.Free;
  FThreadList.Free;

  inherited;
end;

procedure TThreadPool.ThreadHandleExecute(Thread: TThread);
var
  Data: pointer;
begin
  while FThreadQueue.Pop(Data) and (not TThreadSimple(Thread).Terminated) do begin
    try
      FThreadPoolEventHandle(Data, Thread);
    except
    end;
  end;
end;
{$ENDREGION}

end.
