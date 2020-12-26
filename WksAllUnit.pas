unit WksAllUnit;

// TODO
//
// - remove : TEMPORARYCOMMENT

interface

{$REGION 'Help'}
(*
  USE SOURCE CODE
  ---------------
  If you need to be able to step through the source, use the Project->Options->Compiler page, and check the Use debug DCUs option under Debugging instead.

  CODE FOLDING
  ---------------
  Ctrl + Shift + K + O    toggles between on and off
  Ctrl + Shift + K + E    collapse current block of code
  Ctrl + Shift + K + R    collapses all regions
  Ctrl + Shift + K + M    collapse all methods
  Ctrl + Shift + K + C    collapse all classes & records
  Ctrl + Shift + K + P    collapse nested procedures

  SCALAR, LIST, VECTOR, MATRIX
  ----------------------------
  point, vector, matrix in N2, N3, R2, R3 spaces

  List   --> Lx  *** list and switchbox should be merged or some switchbox method should be moved to list (ex. add/remove/mix) ***
  Vector --> Vx
  Matrix --> Mx

  Scalar/Item

    s   = a number or a string that should be camelcase without spaces

  List = csv of scalars

    l = s1, s2, ... sn

  Vector = array of scalars

    v[i] = [s1, s2, ... sn]

  Matrix = vector of vectors
                            ______________ Col j
    m[i, j] = [            |
      v1 = [s11, s12, ... s1j ... s1n]
    , v2 = [s21, s22, ... s2j ... s2n]
    , ...
    , vi = [si1, si2, ... sij ... sin] --- Row i
    , ...
    , vm = [sm1, sm2, ... smj ... smn]
    ]
*)
{$ENDREGION}

{$REGION 'Use'}
uses
    Winapi.Windows                  // outdebugstring, trgbtriple
  , System.Types                    // tstringdynarray
  , System.Classes                  // tcomponent, tacenter, tstrings, tthread
  , System.SysUtils                 // exception
  , System.Diagnostics              // stopwatch
  , System.RegularExpressionsConsts // regex
  , System.RegularExpressionsCore   // regex
  , System.RegularExpressionsAPI    // regex
  , System.RegularExpressions       // regex
  , System.IniFiles                 // ini
//, System.SyncObjs                 // tcriticalsection
  , Data.DB                         // dataset
//, Data.DBXJson                    // dupl?
  , Data.Win.ADODB                  // adoconnection
  , Soap.SOAPHTTPClient             // soapconnection
  , Soap.SOAPConn                   // thttprio
  , Soap.InvokeRegistry             // tremotable
  , Web.HTTPApp                     // twebrequest, twebresponse
  , Vcl.Graphics                    // tgraphic tpicture
  , FireDAC.Comp.Client             // fd core components for data access
  , FireDAC.Comp.DataSet            // fddataset
  , FireDAC.DApt                    //
  , FireDAC.DApt.Intf               //
  , FireDAC.DatS                    //
  , FireDAC.Phys                    //
  , FireDAC.Phys.Intf               //
  , FireDAC.Phys.MSSQL              //
  , FireDAC.Phys.MSSQLDef           //
  , FireDAC.Phys.MSSQLWrapper       //
  , FireDAC.Phys.Oracle             //
  , FireDAC.Phys.OracleDef          //
  , FireDAC.Stan.Async              //
  , FireDAC.Stan.Def                //
  , FireDAC.Stan.Error              //
  , FireDAC.Stan.Intf               //
  , FireDAC.Stan.Option             //
  , FireDAC.Stan.Param              //
  , FireDAC.Stan.Pool               //
  , FireDAC.UI.Intf                 //
  , FireDAC.VCLUI.Wait              //
  , WksThreadUtilsUnit              // tthreadpool
  ;
{$ENDREGION}

{$REGION 'Const'}
const

  {$REGION 'General'}
  DELIMITER_CHAR             = ',';
  SORROUND_CHAR              = '"';
//ASTERISC_CHAR              = '*';
//PERCENT_CHAR               = '%';
//X_CHAR                     = '×';
  UNDEFINED_STR              = 'Undefined';
  UNKNOWN_STR                = 'Unknown';
  NULL_STR                   = 'NULL';
  BLOB_STR                   = 'BLOB';
  NA_STR                     = 'NA';
  OK_STR                     = 'OK';
//FAILED_STR                 = 'FAILED';
//SUCCESS_STR                = 'SUCCESS';
//NO_DATA                    = 'No Data';
//NOT_FOUND                  = 'Not found';
//NOT_ASSIGNED               = 'Not assigned';
//NOT_AVAILABLE              = 'Not available';
//NOT_AUTHORIZED             = 'Not authorized';
  NOT_IMPLEMENTED            = 'Not implemented';
//NOT_AN_OPTION              = 'Not an option';
//FIRST_STR                  = 'First';
//LAST_STR                   = 'Last';
//STATE_ACTIVE               = 'Active';
  KIND_CSV    = ',Bat,Css,Csv,Dws,Etl,Folder,Html,Js,Json,Link,Member,Organization,Param,Pas,Person,Py,R,Root,Sql,Txt'; // *** WARNING, DUPLICATE, INCOMPLETE, REMOVE ***
  {$ENDREGION}

  {$REGION 'Defaults'}
  ID_DEFAULT                 = -1;
  PID_DEFAULT                = 1;
  STATE_DEFAULT              = 'Active';
  ORDER_DEFAULT              = 1;
  ROOT_NEW_ID                = 8;
  {$ENDREGION}

  {$REGION 'Format'}
//DATETIME_FORMAT            = 'yyyy mm dd hh:mm:ss'; // for daily log activities
//DAYTIME_FORMAT             =         'dd hh:mm:ss'; // for montly log activities
  EXCEPTION_FORMAT           = 'EXCEPTION: %s';       // only e.Message
  EXCEPTION2_FORMAT          = 'EXCEPTION: %s, %s';   // only e.Message and e.Classname
  WARNING_FORMAT             = 'WARNING  : %s';
//INFO_FORMAT                = 'INFO     : %s';
  {$ENDREGION}

  {$REGION 'Log'}
//LOG_DATETIME_FORMAT        = 'yyyy-mm-dd hh:mm:ss';
//LOG_FILE_RESCUE            = '.\_WksLogRescue.txt';
//LOG_FILE_DATETIME_FORMAT   = 'yyyymm';
//LOG_ENTRY_DATETIME_FORMAT  = 'dd hh:mm:ss';
//LOG_ENTRY_EX_FORMAT        = 'process %d thread %d';
//LOG_LEVEL_FORMAT           = '%-10s';
//LOG_TAG_FORMAT             = '%-25s';
//LOG_INDENT_CHARS           = 3;
  LOG_INDENT_ENTER           = '-->';
  LOG_INDENT_LEAVE           = '<--';
//LOG_SEP                    = ': ';
  {$ENDREGION}

  {$REGION 'Ini'}
  INI_CLIENT_DEFAULT =  '[Server]'
  + sLineBreak + 'WwwProd=www.wks.cloud'
  + sLineBreak + 'WwwTest=www.wks.cloud:8080'
  + sLineBreak + 'WwwDev=localhost'
  + sLineBreak + 'Environment=Dev'
  + sLineBreak
  + sLineBreak + '[User]'
  + sLineBreak + 'Organization='
  + sLineBreak + 'Username='
  + sLineBreak + 'Password='
  + sLineBreak
  + sLineBreak + '[Proxy]'
  + sLineBreak + 'Use=0'
  + sLineBreak + 'AddressAndPort='
  + sLineBreak + 'Username='
  + sLineBreak + 'Password='
  ;
  INI_SERVER_DEFAULT =  '[Database]'
//+ sLineBreak + 'Db0CsADO=Provider=SQLNCLI11.1;Data Source=LOCALHOST;Initial Catalog=DbaClient;User ID=sa;Password=secret;Persist Security Info=True'
  + sLineBreak + 'Db0CsFD=DriverID=Mssql;Server=LOCALHOST;Database=DbaClient;User_Name=sa;Password=secret'
  ;
  INI_DEMON_DEFAULT =  '[Database]'
//+ sLineBreak + 'Db0CsADO=Provider=SQLNCLI11.1;Data Source=LOCALHOST;Initial Catalog=DbaClient;User ID=sa;Password=secret;Persist Security Info=True'
  + sLineBreak + 'Db0CsFD=DriverID=Mssql;Server=LOCALHOST;Database=DbaClient;User_Name=sa;Password=secret'
  ;
  {$ENDREGION}

  {$REGION 'Connectionstring'}
//ADO_DB_PROVIDER0 = 'SQLOLEDB.1';  //
//ADO_DB_PROVIDER1 = 'SQLNCLI11.1'; //

  CS0_ADO          = 'Provider=SQLNCLI11.1;Data Source=LOCALHOST            ;Initial Catalog=DbaClient           ;User ID=sa          ;Password=secret     ;Persist Security Info=True';
  CS1_ADO          = 'Provider=SQLNCLI11.1;Data Source=WKS                  ;Initial Catalog=DbaClient           ;User ID=sa          ;Password=Igi0Ade    ;Persist Security Info=True';
  CS2_ADO          = 'Provider=SQLNCLI11.1;Data Source=AIWYMSTEST\SQLEXPRESS;Initial Catalog=DbaClient           ;User ID=sa          ;Password=Lfoundry123;Persist Security Info=True';
  CS3_ADO          = 'Provider=SQLNCLI11.1;Data Source=AIWYMSDB             ;Initial Catalog=DbaClient           ;User ID=sa          ;Password=Lfoundry123;Persist Security Info=True';
  CS4_ADO          = 'Provider=SQLNCLI11.1;Data Source=AIMSSPROD02          ;Initial Catalog=client_report_config;User ID=MES_REPORT_1;Password=changeme   ;Persist Security Info=True;Application Intent=ReadOnly';

  CS0_FD           = 'DriverID=Mssql;Server=LOCALHOST            ;Database=DbaClient               ;User_Name=sa          ;Password=secret     ';
  CS1_FD           = 'DriverID=Mssql;Server=WKS                  ;Database=DbaClient               ;User_Name=sa          ;Password=Igi0Ade    ';
  CS2_FD           = 'DriverID=Mssql;Server=AIWYMSTEST\SQLEXPRESS;Database=DbaClient               ;User_Name=sa          ;Password=Lfoundry123';
  CS3_FD           = 'DriverID=Mssql;Server=AIWYMSDB             ;Database=DbaClient               ;User_Name=sa          ;Password=Lfoundry123';
  CS4_FD           = 'DriverID=Mssql;Server=AIMSSPROD02          ;Database=client_report_Nameconfig;User_Name=MES_REPORT_1;Password=changeme   ';
  {$ENDREGION}

  {$REGION 'Dba'}
  DBA_COMMAND_TIMEOUT_SEC    = 600; // = 10 min (long oracle query may require more!!!)
  DBA_CONNECTION_TIMEOUT_SEC =  30;
  DBA_DEFAULT_RECORD_COUNT   =  50;
  {$ENDREGION}

  {$REGION 'http'}
  HTTP_PROTOCOL              = 'http://';
  HTTP_PROTOCOL_SECURE       = 'https://';

  HTTP_HEADER_VEC: array of ansistring = [
    'ALL_HTTP'                       // All HTTP headers that were not already parsed into one of the previous variables These variables are of the form HTTP_<header field name> The headers consist of a null-terminated string with the individual headers separated by line feeds
  , 'ALL_RAW'                        //
  , 'APPL_MD_PATH'                   //
  , 'APPL_PHYSICAL_PATH'             //
  , 'AUTH_PASSWORD'                  //
  , 'AUTH_TYPE'                      //
  , 'AUTH_TYPECONTENT_LENGTH'        // The number of bytes which the script can expect to receive from the client
  , 'AUTH_USER'                      //
  , 'CERT_COOKIE'                    //
  , 'CERT_FLAGS'                     //
  , 'CERT_ISSUER'                    //
  , 'CERT_KEYSIZE'                   //
  , 'CERT_SECRETKEYSIZE'             //
  , 'CERT_SERIALNUMBER'              //
  , 'CERT_SERVER_ISSUER'             //
  , 'CERT_SERVER_SUBJECT'            //
  , 'CERT_SUBJECT'                   //
  , 'CONTENT_LENGTH'                 //
  , 'CONTENT_TYPE'                   // The content type of the information supplied in the body of a POST request
  , 'GATEWAY_INTERFACE'              //
  , 'HTTP_ACCEPT'                    // Special-case HTTP header Values of the Accept: fields are concatenated and separated by a comma (",") For example, if the following lines are part of the HTTP header: accept: */*; q=01
  , 'HTTP_ACCEPT_ENCODING'           //
  , 'HTTP_ACCEPT_LANGUAGE'           //
  , 'HTTP_CACHE_CONTROL'             //
  , 'HTTP_CONNECTION'                //
  , 'HTTP_CONTENT_LENGTH'            //
  , 'HTTP_CONTENT_TYPE'              //
  , 'HTTP_COOKIE'                    //
  , 'HTTP_DNT'                       //
  , 'HTTP_HOST'                      //
  , 'HTTP_ORIGIN'                    //
  , 'HTTP_REFERER'                   //
  , 'HTTP_REQUEST_METHOD'            //
  , 'HTTP_SEC_FETCH_DEST'            //
  , 'HTTP_SEC_FETCH_MODE'            //
  , 'HTTP_SEC_FETCH_SITE'            //
  , 'HTTP_SEC_FETCH_USER'            //
  , 'HTTP_SERVER_PROTOCOL'           //
  , 'HTTP_SM_AUTHDIRNAME'            //
  , 'HTTP_SM_AUTHDIRNAMESPACE'       //
  , 'HTTP_SM_AUTHDIROID'             //
  , 'HTTP_SM_AUTHDIRSERVER'          //
  , 'HTTP_SM_AUTHREASON'             //
  , 'HTTP_SM_AUTHTYPE'               //
  , 'HTTP_SM_LOCATION'               //
  , 'HTTP_SM_LOCATION_PARSED'        //
  , 'HTTP_SM_REALM'                  //
  , 'HTTP_SM_REALMOID'               //
  , 'HTTP_SM_SDOMAIN'                //
  , 'HTTP_SM_SERVERIDENTITYSPEC'     //
  , 'HTTP_SM_SERVERSESSIONID'        //
  , 'HTTP_SM_SERVERSESSIONSPEC'      //
  , 'HTTP_SM_TIMETOEXPIRE'           //
  , 'HTTP_SM_TRANSACTIONID'          //
  , 'HTTP_SM_UNIVERSALID'            //
  , 'HTTP_SM_USER'                   //
  , 'HTTP_SM_USERDN'                 //
  , 'HTTP_SMMATRICOLA'               //
  , 'HTTP_SMUSER'                    //
  , 'HTTP_UPGRADE_INSECURE_REQUESTS' //
  , 'HTTP_USER_AGENT'                //
  , 'HTTPS'                          //
  , 'HTTPS_KEYSIZE'                  //
  , 'HTTPS_SECRETKEYSIZE'            //
  , 'HTTPS_SERVER_ISSUER'            //
  , 'HTTPS_SERVER_SUBJECT'           //
  , 'INSTANCE_ID'                    //
  , 'INSTANCE_META_PATH'             //
  , 'LOCAL_ADDR'                     //
  , 'LOGON_USER'                     //
  , 'PATH_INFO'                      // Additional path information, as given by the client This consists of the trailing part of the URL after the script name, but before the query string, if any
  , 'PATH_TRANSLATED'                // This is the value of PATH_INFO, but with any virtual path name expanded into a directory specification
  , 'QUERY_STRING'                   // The information which follows the '"?" in the URL that referenced this script
  , 'REMOTE_ADDR'                    // The IP address of the client or agent of the client (for example, gateway or firewall) that sent the request
  , 'REMOTE_HOST'                    // The hostname of the client or agent of the client (for example, gateway or firewall) that sent the request
  , 'REMOTE_PORT'                    //
  , 'REMOTE_USER'                    // This contains the username supplied by the client and authenticated by the server This comes back as an empty string when the user is anonymous (but authenticated)
  , 'REQUEST_METHOD'                 // The HTTP request method
  , 'SCRIPT_NAME'                    // The name of the script program being executed
  , 'SERVER_NAME'                    // The server's hostname, or IP address, as it should appear in self-referencing URLs
  , 'SERVER_PORT'                    // The TCP/IP port on which the request was received
  , 'SERVER_PORT_SECURE'             // A string of either zero or 1 If the request is being handled on the secure port, then this will be 1 Otherwise, it will be zero
  , 'SERVER_PROTOCOL'                // The name and version of the information retrieval protocol relating to this request This is normally HTTP/10
  , 'SERVER_SOFTWARE'                // The name and version of the Web server under which the ISAPI ApplicationsPI DLL program is running
  , 'UNMAPPED_REMOTE_USER'           // This is the username before any ISAPI ApplicationsPI Filter mapped the user making the request to an NT user account (which appears as REMOTE_USER)
  , 'URL'                            // Gives the base portion of the URL (new for vwesion 20)
  ];
  {$ENDREGION}

  {$REGION 'web'}
  WEB_COOKIE_EXPIRE_IN_DAY   = 1/24;
  {$ENDREGION}

{$ENDREGION}

{$REGION 'Enum'}
type

  TPriorityEnum = (
    pyPrimary
  , pySecondary
  , pyInfo
  , pySuccess
  , pyHighlight
  , pyWarning
  , pyDanger
  , pyError
  );

  TAlignEnum = (
    alTL, alMT, alTR
  , alML, alMC, alMR
  , alBL, alMB, alBR
  );

  TLogEntryEnum = (
    logNone  // untyped
  , logInfo
  , logWarning
  , logException
  , logDebug // outputdebugstring
  , logQuery
  , logVector
  , logStrings // TStrings
  , logDataset
  );
{$ENDREGION}

{$REGION 'Basic'}
type

  TIntegerVector = TIntegerDynArray {array of integer};
  TDoubleVector  = TDoubleDynArray {array of double};
  TDoubleMatrix  = array of array of double;
  TStringVector  = TStringDynArray {array of string};
  TStringMatrix  = array of TStringVector;
  TByteVector    = TByteDynArray {array of byte};       // like TIdBytes
  TVariantVector = array of variant;                    // this is a dynamic array of variants that is resizable (an open array is not resizable!)
  TVarRecVector  = array of TVarRec;                    // TConstArray
  TRgbVector     = array[0..65535] of TRGBTriple;       // color
  PRgbVector     = ^TRgbVector;                         // color

  TCommandRec    = record
    Name       : string;
    Description: string;
  end;

  TCommandRecVec = array of TCommandRec;

  THls = record // color
    H: integer;
    L: integer;
    S: integer;
  end;

  TKva = record // keyvalue
    Key: string;
    Val: string;
  end;

  TKvaVec = array of TKva;

  TNanometer = double;

  TTkv = record // tagkeyvalue
    Tag: string; // group
    Key: string;
    Val: string;
  end;

  TTkvVec = array of TTkv;
{$ENDREGION}

{$REGION 'Types'}
type

  TAskRec = record // yes/no, str, int input dialog
    function  Yes(IvMessage: string = 'Continue ?'): boolean;
    function  YesFmt(IvMessageFormatString: string; IvVarRecVector: array of TVarRec): boolean;
    function  No(IvMessage: string = 'Continue ?'): boolean;
    function  NoFmt(IvMessageFormatString: string; IvVarRecVector: array of TVarRec): boolean;
    function  Str(IvCaption, IvPrompt, IvDefault: string; var IvStr: string): boolean;
    function  Int(IvCaption, IvPrompt: string; IvDefault: integer; var IvInt: integer): boolean;
  end;

  TBynRec = record // binary exe/dll
//type
  //TBinaryKind = (bkConsole, bkLibrary, bkService, bkDesktop);
//private
  //CommandLine: string;
  public
    CommandRecVec: TCommandRecVec;                    // commands with descriptions (PathInfo for isapidll or parameters for exe)
    function  AuthToken: string;                      // Wks.Client, Wks.AGENT.Client, ...   (nickname + role, dotseparated)
    function  Cmds: string;                           //
    function  CmdsHas(IvCmd: string; var IvFbk: string): boolean;
    procedure Dispose;                                // dispose CommandRecVec
    function  FileExt: string;                        // .exe
    function  FileName: string;                       // WksXxx*Project
    function  FileNameDotExt: string;                 // WksXxx*Project.exe
    function  FileSpec: string;                       // c:\...\WksXxx*Project.exe
    function  Info: string;                           // WKS Client 1.0.0.0, Wks AGENT Client 1.0.0.0, ...
    function  IsClient: boolean;                      // Wks*ClientProject.exe
    function  IsDemon : boolean;                      // Wks*[Demon|Service]Project.exe
    function  IsServer: boolean;                      // Wks*[Isapi|Soap|Rest]Project.exe
    function  Name: string;                           // WKS Client, AGENT Client, ...    (nicknameupper + role, withspaces)
    function  NameNice: string;                       // WKS Client, Wks AGENT Client
    function  NameNiceVer: string;                    // WKS Client 1.0.0.0, Wks AGENT Client 1.0.0.0
    function  Nick: string;                           // Wks, Agent    (nickname, sysacro if mainclient else specific client name)
    function  Obj: string;                            // Xxx
    function  Path: string;                           // c:\...
    function  RioVerIsOk(var IvFbk: string): boolean; // check remotely if client version is registered on the server *** MOVE TO TSysRec ***
    function  Role: string;                           // Client, Isapi, Soap, Rest, Dsnap, Service, Deamon
    function  Spec: string;                           // c:\...\WksXxx*Project.exe
    function  SpecInfo: string;                       // + modified datetime
    function  Tag: string;                            // = Nick, WksClient, WksAgentClient  NameNice?
    function  Ver(IvFile: string = ''): string;       // 1.0.0.123
    procedure Version(var IvV1, IvV2, IvV3, IvV4: word);
  end;

  TCnsRec = record // connectionstring
  public
    function  CsADO(IvCsADO{, IvStore, IvDatabase}: string{; var IvFbk: string}): string;
    function  CsFD (IvCsFD {, IvStore, IvDatabase}: string{; var IvFbk: string}): string;
  //function  Cs   (IvCs, IvStore, IvDatabase, IvDriver: string; out IvCsOut: string; var IvFbk: string): boolean;
    function  CsADOTest(IvCs: string; var IvFbk: string): boolean;
    function  CsFDTest (IvCs: string; var IvFbk: string): boolean;
    function  CsMsExcelADO (IvFile: string): string;
    function  CsMsAccessADO(IvFile: string; IvUsername: string = ''; IvPassword: string = ''): string;
    function  CsSqLiteFD   (IvFile: string; IvUsername: string = ''; IvPassword: string = ''): string;
    function  CsMsSqlADO   (IvServer, IvDatabase, IvUsername, IvPassword: string; IvSSPI: boolean = false): string; // SSPI = integrated security
    function  CsMsSqlFD    (IvServer, IvDatabase, IvUsername, IvPassword: string; IvSSPI: boolean = false): string;
    function  CsOracleADO  (IvServer, IvPort, IvSId, IvServiceName, IvDatabase, IvUsername, IvPassword: string; IvDatasource: string = ''): string;
    function  CsOracleFD   (IvServer, IvPort, IvSId, IvServiceName, IvDatabase, IvUsername, IvPassword: string; IvDatasource: string = ''): string;
    function  CsOracleDs   (                  IvServer, IvPort, IvSId, IvServiceName: string): string; // datasource without tnsname.ora
    function  CsMongoFD    (IvServer, IvPort, IvDatabase, IvUsername, IvPassword: string; IvCollection: string = ''): string;
  end;

  TConRec = record // connection
  public
    function  ConnADOInit(var IvADOConnection: TADOConnection; IvCsADO: string; var IvFbk: string): boolean;
    function  ConnADOFree(var IvADOConnection: TADOConnection; var IvFbk: string): boolean;
    function  ConnFDInit (var IvFDConnection : TFDConnection ; IvCsFD : string; var IvFbk: string): boolean;
    function  ConnFDFree (var IvFDConnection : TFDConnection ; var IvFbk: string): boolean;
  end;

  TCryRec = record // crypto

    {$REGION 'Help'}
    (*
      Convention
      ----------
      Plain       original text not encrypted
      Cipher      encripted text
      Key         the method to pass from Chipher to Plain
      Salt        random piece of data combined with your plain text, usally appended
    *)
    {$ENDREGION}

  const
    // borland
    CRYPTO_KEY_MIN_LEN = 5;
    CRYPTO_START_KEY   = 42427; // default StartKey (31316 + 1) DO NOT CHANGE
    CRYPTO_MULT_KEY    = 28917; // default Mult Key
    CRYPTO_ADD_KEY     = 56581; // default Add Key
  public
    function  KeyIsValidAndSecure(const IvKey: string; var IvFbk: string): boolean;
    // borland
    function  Cipher(const IvString: string; IvStartKey: integer = CRYPTO_START_KEY; IvMultKey: integer = CRYPTO_MULT_KEY; IvAddKey: integer = CRYPTO_ADD_KEY): string;
    function  Decipher(const IvString: string; IvStartKey: integer = CRYPTO_START_KEY; IvMultKey: integer = CRYPTO_MULT_KEY; IvAddKey: integer = CRYPTO_ADD_KEY): string;
    // sha2
    function  CipherSha2(IvPlain: string): string;            // HashStrSha2
    function  CipherSha2HMac(IvPlain, IvKey: string): string; // HashHMacSha2
  end;

  TDatRec = record // datetime
  const
    ZERO        = 0.0;
    MSSQLFORMAT = 'yyyymmdd hh:nn:ss.zzz';
  public
    // now
    function  NowStr: string;
    function  NowMs: cardinal;                                                  // return the number of ms from midnight 00:00:00 until now
    // year
    function  YearNow(IvInc: integer = 0): integer;
    function  Year(IvDateTime: TDateTime; IvInc: integer = 0): integer;         // 2020
    // quarter
    function  Quarter(IvDateTime: TDateTime; IvInc: integer = 0): integer;      // 1..4
    // month
    function  Month(IvDateTime: TDateTime; IvInc: integer = 0): integer;        // 1..12
    function  MonthStr(IvDateTime: TDateTime; IvInc: integer = 0; IvLength: integer = -1): string; // January..December
    // weekiso
    function  Week(IvDateTime: TDateTime; IvInc: integer = 0): integer;         // 1..52(53) iso
    function  WeekStr(IvDateTime: TDateTime; IvInc: integer = 0): string;       // 01..52(53) iso
    function  WeekDay(IvDateTime: TDateTime; IvInc: integer = 0): integer;      // 1=monday, 2=tuesday, 3=wednesday, 4=thursday, 5=friday, 6=saturday, 7=sunday (ISO 8601 compliant)
    function  WeekDayStr(IvDateTime: TDateTime; IvInc: integer = 0; IvLength: integer = -1): string;  // Mon,Tue,Wed,Thu,Fri,Sat,Sun | Monday..Sunday ISO 8601
    // workweek
    function  WeekWork(IvDateTime: TDateTime; IvWeekDayStart: string = 'Thusday'; IvTimeStart: string = '19:00:00'; IvInc: integer = 0): integer;   // 1..52(53) // this depends on Organization week start
    function  WeekWorkStr(IvDateTime: TDateTime; IvWeekDayStart: string = 'Thusday'; IvTimeStart: string = '19:00:00'; IvInc: integer = 0): string; // 01..52(53)
    // day
    function  Day(IvDateTime: TDateTime; IvInc: integer = 0): integer;          // 1..31
    function  DayStr(IvDateTime: TDateTime; IvInc: integer = 0): string;        // 01..31
    // hour
    function  Hour(IvDateTime: TDateTime; IvInc: integer = 0): integer;         // 0..23
    function  HourStr(IvDateTime: TDateTime; IvInc: integer = 0): string;       // 00..23
    // minute
    function  Minute(IvDateTime: TDateTime; IvInc: integer = 0): integer;       // 0..59
    function  MinuteStr(IvDateTime: TDateTime; IvInc: integer = 0): string;     // 00..59
    function  MinuteBetween(IvDateTime1, IvDateTime2: TDateTime): int64;
    function  MinuteInc(IvDateTime: TDateTime; IvInc: integer): TDateTime;
    // second
    function  Second(IvDateTime: TDateTime; IvInc: integer = 0): integer;       // 0..59
    function  SecondStr(IvDateTime: TDateTime; IvInc: integer = 0): string;     // 00..59
    // for
    function  ForSql(IvDateTime: TDateTime): string;
    function  FromIso(IvDateTimeIso: string; IvInputIsUTC: boolean): TDateTime;
    // date
    function  DateToCode(IvDateTime: TDateTime): string;
    function  DateFromCode(IvDateTimeCode: string): TDate;
    // time
    function  TimeToCode(IvDateTime: TDateTime): string;
    function  TimeFromCode(IvDateTimeCode: string): TTime;
    // code
    function  ToCode(IvDateTime: TDateTime): string;
    function  FromCode(IvDateTimeCode: string): TDateTime;
  end;

  TDbaCls = class
  private
  //FCsADO  : string;
  //FConnADO: TADOConnection;
    FCsFD   : string;
    FConnFD : TFDConnection;
  public
    constructor Create({IvCsADO: string = ''; }IvCsFD: string = '');
    destructor  Destroy; override;
    // dba
    function  Dba(const IvDatabaseName: string): string;
    function  DbaExists(const IvDba: string; var IvFbk: string): boolean;
    function  DbaCreate(const IvDba: string; var IvFbk: string): boolean;
    function  DbaCreateIfNotExists(const IvDba: string; var IvFbk: string): boolean; // true = created, false = already exists
    // table
    function  Tbl(const IvDatabaseName, IvTableName: string): string;
    function  TblExists(const IvDba, IvTbl: string; var IvFbk: string): boolean;
    function  TblCreate(const IvDba, IvTbl, IvFldDefBlock: string; var IvFbk: string): boolean;
    function  TblCreateIfNotExists(const IvDba, IvTbl, IvFldDefBlock: string; var IvFbk: string): boolean; // true = created, false = already exists
    function  TblIndexCreate(const IvDba, IvTbl, IvIdx, IvIdxDefBlock: string; var IvFbk: string): boolean;
    function  TblIdMax      (const IvTbl: string; IvWhere: string = ''): integer; // consider just the max number in the table
    function  TblIdAvailable(const IvTbl: string; IvWhere: string = ''): integer; // consider also holes in the numeric sequence
    function  TblIdNext     (const IvTbl: string; IvWhere: string = ''): integer; // mix idmax and idavailable
    function  TblIdBounds   (const IvTbl: string; var IvIdMin, IvIdMax: integer; var IvFbk: string): boolean;
    function  TblIdExists   (const IvTbl: string; const IvId: integer; var IvFbk: string): boolean;
    // record
    function  RecExists(const IvTbl, IvWhereFld, IvWhereValue: string; var IvFbk: string; IvCaseSensitive: boolean = false): boolean; overload;
    function  RecExists(const IvTbl, IvWhere: string; var IvFbk: string; IvCaseSensitive: boolean = false): boolean; overload;
    function  RecInsertSimple(const IvTbl: string; const IvValueVe: array of const; var IvFbk: string): boolean;
    function  RecInsert      (const IvTbl, IvInsertSqlWithParams: string; const IvVeParamValue: array of const; var IvIdNew: integer; var IvFbk: string): boolean;
    // field
    function  Fld(const IvFieldName: string): string;
    function  FldExists(const IvTbl, IvFld: string; var IvFbk: string): boolean;
    function  FldCreate(const IvTbl, IvFld: string; var IvFbk: string): boolean;
    function  FldGet(const IvTbl, IvFld, IvWhere: string; var IvValueOut: variant; IvDefault: variant; var IvFbk: string): boolean;
    function  FldSet(const IvTbl, IvFld, IvWhere: string; const IvValueIn: variant; var IvFbk: string): boolean;
    function  FldInc(const IvTbl, IvFld, IvWhere: string; var IvFbk: string): boolean;
    function  FldDec(const IvTbl, IvFld, IvWhere: string; var IvFbk: string): boolean;
    function  FldDefault(IvDs: TFDDataset; IvFld: string; IvDefault: variant): variant;      // \
    function  FldToByteArray(IvDs: TFDDataset; IvFld: string): TByteDynArray;                //  | move to TDstRec
    procedure FldFromByteArray(IvDs: TFDDataset; IvFld: string; IvByteArray: TByteDynArray); // /
    function  FldDoMath(IvTbl, IvFld: string; IvOperator: char; IvOperand: string; IvWhere: string; var IvFbk: string): boolean;
    // exec
  //function  ExecADO(IvSql: string; var IvAffected: integer; var IvFbk: string; IvTimeOutSec: integer = DBA_COMMAND_TIMEOUT_SEC): boolean;
    function  ExecFD (IvSql: string; var IvAffected: integer; var IvFbk: string; IvTimeOutSec: integer = DBA_COMMAND_TIMEOUT_SEC): boolean; // use FDCommand
    // scalar
  //function  ScalarADO(const IvSql: string; const IvDefault: variant; var IvFbk: string; IvTimeOutSec: integer = DBA_COMMAND_TIMEOUT_SEC): variant;
    function  ScalarFD (const IvSql: string; var IvResult: variant; const IvDefault: variant; var IvFbk: string; IvTimeOutSec: integer = DBA_COMMAND_TIMEOUT_SEC): boolean; overload;
    function  ScalarFD (const IvSql: string; IvDefault: variant; var IvFbk: string; IvTimeOutSec: integer = DBA_COMMAND_TIMEOUT_SEC): variant; overload;
    // ds-ado
  //function  DsADO(IvSql: string; var IvDs: TDataSet  ; var IvFbk: string; IvFailIfEmpty: boolean = false; IvTimeOutSec: integer = DBA_COMMAND_TIMEOUT_SEC): boolean; overload;
  //function  RsADO(IvSql: string; var IvRs: _Recordset; var IvFbk: string; IvFailIfEmpty: boolean = false; IvTimeOutSec: integer = DBA_COMMAND_TIMEOUT_SEC): boolean;
    // ds-fd
    function  DsFD (IvSql: string; var IvDs: TFDDataSet; var IvFbk: string; IvFailIfEmpty: boolean = false; IvTimeOutSec: integer = DBA_COMMAND_TIMEOUT_SEC): boolean; overload;
    function  DsFD (IvSql: string; var IvDs: TDataSet  ; var IvFbk: string; IvFailIfEmpty: boolean = false; IvTimeOutSec: integer = DBA_COMMAND_TIMEOUT_SEC): boolean; overload;
    // hierarchy
    function  HIdVecFromName      (const IvTbl, IvNameFld, IvName: string): TIntegerVector; // many id's are possible from one name
    function  HIdFromName         (const IvTbl, IvNameFld, IvName: string): integer; // only the 1st id found
    function  HIdFromPath         (const IvTbl, IvPathFld, IvPath: string; var IvId: integer; var IvFbk: string): boolean; overload;
    function  HIdFromPath         (const IvTbl, IvPathFld, IvPath: string): integer; overload;
    function  HIdFromIdOrPath     (const IvTbl, IvPathFld: string; IvIdOrPath: string; var IvId: integer; var IvFbk: string): boolean; overload;
    function  HIdFromIdOrPath     (const IvTbl, IvPathFld: string; IvIdOrPath: string): integer; overload;
    function  HIdToPath           (const IvTbl, IvPathFld: string; const IvId: integer; var IvPath: string; var IvFbk: string): boolean;
    function  HLevel              (const IvTbl: string; const IvId: integer; var IvLevel: integer; var IvFbk: string): boolean;
    function  HParentsItemChildsDs(const IvTbl, IvFldCsv: string; const IvId: integer; var IvDs: TDataSet; var IvFbk: string): boolean;
    function  HParentsDs          (const IvTbl, IvFldCsv: string; const IvId: integer; var IvDs: TDataSet; var IvFbk: string): boolean;
    function  HChildsDs           (const IvTbl, IvFldCsv: string; const IvId: integer; var IvDs: TDataSet; var IvFbk: string; IvWhere: string = ''; IvOrderBy: string = ''): boolean;
    function  HTreeDs             (const IvTbl, IvFld, IvFldCsv: string; const IvId: integer; var IvDs: TDataSet; var IvFbk: string; IvWhere: string = ''): boolean;
    // image
    function  ImgStreamFromSql(IvImgMemoryStream: TMemoryStream; const IvSql, IvImageField: string; var IvFbk: string): boolean;
    function  ImgPictureFromSql(IvPicture: TPicture; const IvSql  , IvImageField         : string; var IvFbk: string; IvImageNameDefault: string = ''): boolean; overload;
    function  ImgPictureFromDba(IvPicture: TPicture; const IvTable, IvImageField, IvWhere: string; var IvFbk: string; IvImageNameDefault: string = ''): boolean; overload;
    // properties
  //property  CsADO  : string         read FCsADO   write FCsADO;
  //property  ConnADO: TADOConnection read FConnADO {write FConnADO};
    property  CsFD   : string         read FCsFD    write FCsFD;
    property  ConnFD : TFDConnection  read FConnFD  {write FConnFD};
  end;

  TDotRec = record // dot object (like Person.Name involve: DbaPerson, TblPerson, FldName)
  public
    function  IsValid(IvDot: string; var IvFbk: string): boolean;                // Person.Person.Name -> true
    function  Dot  (IvObjOrDba, IvSubOrTbl, IvPropOrFld: string): string;        // Person|DbaPerson, Person|TblPerson, Name|FldName -> Person.Person.Name
    procedure Osp  (IvDotOrDbaTblFld: string; var IvObj, IvSub, IvProp: string); // Person.Person.Name|DbaPerson.TblPerson.FldName -> Person   , Person   , Name
    procedure Dtf  (IvDotOrDbaTblFld: string; var IvDba, IvTbl, IvFld : string); // Person.Person.Name|DbaPerson.TblPerson.FldName -> DbaPerson, TblPerson, FldName
    function  Obj  (IvDotOrDbaTblFld: string): string;                           // object   : Person
    function  Sub  (IvDotOrDbaTblFld: string): string;                           // subject  : Person
    function  Prop (IvDotOrDbaTblFld: string): string;                           // property : Name
    function  Dba  (IvDotOrDbaTblFld: string): string;                           // database : DbaPerson
    function  Tbl  (IvDotOrDbaTblFld: string): string;                           // table    : TblPerson
    function  Fld  (IvDotOrDbaTblFld: string): string;                           // field    : FldName
    function  Table(IvDotOrDbaTblFld: string): string;                           // fulltable: DbaPerson.dbo.TblPerson
    function  Field(IvDotOrDbaTblFld: string): string;                           // field    : FldName
  end;

  TFbkRec = record
    Text: string;
  public
    // builder
    procedure Reset;
    procedure Add(IvString: string);
    procedure AddFmt(IvFormatString: string; IvVarRecVector: array of TVarRec);
    // standardmessages
    function  ExistsStr(IvObj, IvName: string; IvBoolean: boolean): string;
    function  IsActiveStr(IvObj, IvName: string; IvBoolean: boolean): string;
    function  IsAuthenticatedStr(IvObj, IvName: string; IvBoolean: boolean): string;
    function  IsLoggedStr(IvObj, IvName: string; IvBoolean: boolean): string;
    function  IsSecureStr(IvObj, IvName: string; IvBoolean: boolean): string;
    function  IsValidStr(IvObj, IvName: string; IvBoolean: boolean): string;
  end;

  TFsyRec = record // filesystem
  public
    function  FileVer(IvFile: string): string;
    function  FileName(IvFile: string): string;                           // only name part
    function  FileNameDotExt(IvFile: string): string;                     // only name.ext
    function  FileExists(IvFile: string; var IvFbk: string): boolean;
    function  FileCreate(IvFile: string; IvText: string = ''): boolean;
    function  FileDelete(IvFile: string; var IvFbk: string): boolean;
    function  FileTimeToDateTime(const IvFileTime: TFileTime): TDateTime;
    function  FileCreated(IvFile: string): TDateTime;  // when was created
    function  FileModified(IvFile: string): TDateTime; // when was last modify
    function  FileAccessed(IvFile: string): TDateTime; // when was last access
    function  FileMimeType(IvFile: string): string;    // returns the mime type
    function  FileSizeBytes(IvFile: string): int64;    // returns exact file size in bytes, zero if the file is not found, also valid for files bigger than 2Gb, usage: s := FloatToStrF(FsFileSize('c:\autoexec.bat') / 1048576, ffFixed, 7, 2) + ' MB';
    function  FileAttrReadOnlySet(IvFile: string; var IvFbk: string): boolean;
    function  FileAttrArchiveSet(IvFile: string; var IvFbk: string): boolean;
    function  FileToByteArray(IvFile: string): TByteDynArray;
    procedure FileFromByteArray(const IvByteArray: TByteDynArray; const IvFileName: string);
    function  DirExists(IvDir: string; var IvFbk: string): boolean;
    function  DirChose(IvDirToStart, IvDirDefault: string; var IvDirChosen, IvFbk: string): boolean;
    function  DirOpen(IvPath: string; var IvFbk: string): boolean;
    function  DirCreate(IvDir: string; var IvFbk: string): boolean; // deep
    function  DirDelete(IvPath: string; var IvFbk: string): boolean;
  end;

  THttRec = record // http   https://www.loggly.com/blog/http-status-code-diagram
  const
    HTTP_HEADER_EXPIRE                     = 'Mon, 19 Jul 1960 05:00:00 GMT';

    HTTP_STATUS_100_CONTINUE               = 100;    HTTP_STATUS_100_CONTINUE_STR           = '100 - OK to continue with request';
  //HTTP_STATUS_101                        = 101;  //HTTP_STATUS_101_SWITCH_PROTOCOLS_STR   = '101 - server has switched protocols in upgrade header';
  //HTTP_STATUS_102                        = 102;                                                 // Processing';
  //HTTP_STATUS_103                        = 103-199;                                             // Unassigned';

    HTTP_STATUS_200_OK                     = 200;    HTTP_STATUS_200_OK_STR                 = '200 - OK request completed';
  //HTTP_STATUS_201                        = 201;  //HTTP_STATUS_201_CREATED_STR            = '201 - object created, reason = new URI;
  //HTTP_STATUS_202                        = 202;  //HTTP_STATUS_202_ACCEPTED_STR           = '202 - Accepted, async completion (TBS)';
  //HTTP_STATUS_203                        = 203;  //HTTP_STATUS_203_PARTIAL_STR            = '203 - partial completion, Non-Authoritative Information';
  //HTTP_STATUS_204                        = 204;  //HTTP_STATUS_204_NO_CONTENT_STR         = '204 - No Content, no info to return';
  //HTTP_STATUS_205                        = 205;  //HTTP_STATUS_205_RESET_CONTENT_STR      = '205 - reset content, request completed, but clear form';
  //HTTP_STATUS_206                        = 206;  //HTTP_STATUS_206_PARTIAL_CONTENT_STR    = '206 - partial content GET furfilled';
  //HTTP_STATUS_207                        = 207;                                                 // Multi-Status';
  //HTTP_STATUS_208                        = 208;                                                 // Already Reported';
  //HTTP_STATUS_209                        = 209-225;                                             // Unassigned';
  //HTTP_STATUS_226                        = 226;                                                 // IM Used';
  //HTTP_STATUS_227                        = 227-299;                                             // Unassigned';

  //HTTP_STATUS_300                        = 300;  //HTTP_STATUS_300_AMBIGUOUS_STR          = '300 - Multiple Choices, server couldn't decide what to return';
  //HTTP_STATUS_301                        = 301;  //HTTP_STATUS_301_MOVED_STR              = '301 - object permanently moved';
    HTTP_STATUS_302_REDIRECT               = 302;    HTTP_STATUS_302_REDIRECT_STR           = '302 - Object temporarily moved';
  //HTTP_STATUS_303                        = 303;  //HTTP_STATUS_303_REDIRECT_METHOD_STR    = '303 - redirection w/ new access method'; // See Other
  //HTTP_STATUS_304                        = 304;  //HTTP_STATUS_304_NOT_MODIFIED_STR       = '304 - if-modified-since was not modified'; // Not Modified
  //HTTP_STATUS_305                        = 305;  //HTTP_STATUS_305_USE_PROXY_STR          = '305 - redirection to proxy, location header specifies proxy to use'; // Use Proxy
  //HTTP_STATUS_306                        = 306;                                                 // (Unused)';
  //HTTP_STATUS_307_REDIRECT_KEEP_VERB_STR = 307;  //HTTP_STATUS_307_REDIRECT_KEEP_VERB_STR = '307 - HTTP/1.1: keep same verb'; // Temporary Redirect
  //HTTP_STATUS_308                        = 308;                                                 // Permanent Redirect';
  //HTTP_STATUS_309                        = 309-399;                                             // Unassigned';

    HTTP_STATUS_400_BAD_REQUEST            = 400;  //HTTP_STATUS_400_BAD_REQUEST_STR        = '400 - Bad Request, invalid syntax';
    HTTP_STATUS_401_UNAUTHORIZED           = 401;    HTTP_STATUS_401_UNAUTHORIZED_STR       = '401 - Unauthorized, access denied';
  //HTTP_STATUS_402                        = 402;  //HTTP_STATUS_402_PAYMENT_REQ_STR        = '402 - payment required';
    HTTP_STATUS_403_FORBIDDEN              = 403;    HTTP_STATUS_403_FORBIDDEN_STR          = '403 - Request forbidden';
  //HTTP_STATUS_404                        = 404;  //HTTP_STATUS_404_NOT_FOUND_STR          = '404 - object not found';
    HTTP_STATUS_405_BAD_METHOD             = 405;    HTTP_STATUS_405_BAD_METHOD_STR         = '405 - method is not allowed';
  //HTTP_STATUS_406                        = 406;  //HTTP_STATUS_406_NON_ACCEPTABLE_STR     = '406 - Not Acceptable, no response acceptable to client found';
  //HTTP_STATUS_407                        = 407;  //HTTP_STATUS_407_PROXY_AUTH_REQ_STR     = '407 - proxy authentication required';
  //HTTP_STATUS_408                        = 408;  //HTTP_STATUS_408_REQUEST_TIMEOUT_STR    = '408 - Request Timeout, server timed out waiting for request';
  //HTTP_STATUS_409                        = 409;  //HTTP_STATUS_409_CONFLICT_STR           = '409 - Conflict, user should resubmit with more info';
  //HTTP_STATUS_410                        = 410;  //HTTP_STATUS_410_GONE_STR               = '410 - Gone, the resource is no longer available';
  //HTTP_STATUS_411                        = 411;  //HTTP_STATUS_411_LENGTH_REQUIRED_STR    = '411 - Length Required'; ???
  //HTTP_STATUS_411                        = 411;  //HTTP_STATUS_411_AUTH_REFUSED_STR       = '411 - couldn't authorize client'; ???
  //HTTP_STATUS_412                        = 412;  //HTTP_STATUS_412_PRECOND_FAILED_STR     = '412 - Precondition Failed, the server refused to accept request w/o a length';
  //HTTP_STATUS_413                        = 413;  //HTTP_STATUS_413_REQUEST_TOO_LARGE_STR  = '413 - Payload Too Large, precondition given in request failed';
  //HTTP_STATUS_414                        = 414;  //HTTP_STATUS_414_URI_TOO_LONG_STR       = '414 - URI Too Long, request entity was too large';
  //HTTP_STATUS_415                        = 415;  //HTTP_STATUS_415_UNSUPPORTED_MEDIA_STR  = '415 - request URI too long';
  //HTTP_STATUS_416                        = 416;                                                 // unsupported media type'; // Range Not Satisfiable
  //HTTP_STATUS_417                        = 417;                                                 // Expectation Failed';
  //HTTP_STATUS_418                        = 418-420;                                             // Unassigned';
  //HTTP_STATUS_421                        = 421;                                                 // Misdirected Request';
  //HTTP_STATUS_422                        = 422;                                                 // Unprocessable Entity';
  //HTTP_STATUS_423                        = 423;                                                 // Locked';
  //HTTP_STATUS_424                        = 424;                                                 // Failed Dependency';
  //HTTP_STATUS_425                        = 425;                                                 // Unassigned';
  //HTTP_STATUS_426                        = 426;                                                 // Upgrade Required';
  //HTTP_STATUS_427                        = 427;                                                 // Unassigned';
  //HTTP_STATUS_428                        = 428;                                                 // Precondition Required';
  //HTTP_STATUS_429                        = 429;                                                 // Too Many Requests';
  //HTTP_STATUS_430                        = 430;                                                 // Unassigned';
  //HTTP_STATUS_431                        = 431;                                                 // Request Header Fields Too Large ;
  //HTTP_STATUS_432                        = 432-450;                                             // Unassigned';
  //HTTP_STATUS_451                        = 451;                                                 // Unavailable For Legal Reasons';
  //HTTP_STATUS_451                        = 449;  //HTTP_STATUS_451_RETRY_WITH_STR         = '449 - retry after doing the appropriate action';
  //HTTP_STATUS_452                        = 452-499;                                             // Unassigned';

    HTTP_STATUS_500_SERVER_ERROR           = 500;    HTTP_STATUS_500_SERVER_ERROR_STR       = '500 - Internal server error';
    HTTP_STATUS_501_NOT_SUPPORTED          = 501;    HTTP_STATUS_501_NOT_SUPPORTED_STR      = '501 - Not Implemented, required not supported';
  //HTTP_STATUS_502                        = 502;  //HTTP_STATUS_502_BAD_GATEWAY_STR        = '502 - Bad Gateway, error response received from gateway';
  //HTTP_STATUS_503                        = 503;  //HTTP_STATUS_503_SERVICE_UNAVAIL_STR    = '503 - Service Unavailable, temporarily overloaded';
  //HTTP_STATUS_504                        = 504;  //HTTP_STATUS_504_GATEWAY_TIMEOUT_STR    = '504 - Gateway Timeout timed out waiting for gateway';
  //HTTP_STATUS_505                        = 505;  //HTTP_STATUS_505_VERSION_NOT_SUP_STR    = '505 - HTTP version not supported';
  //HTTP_STATUS_506                        = 506;                                                 // Variant Also Negotiates';
  //HTTP_STATUS_507                        = 507;                                                 // Insufficient Storage';
  //HTTP_STATUS_508                        = 508;                                                 // Loop Detected';
  //HTTP_STATUS_509                        = 509;                                                 // Unassigned';
  //HTTP_STATUS_510                        = 510;                                                 // Not Extended';
  //HTTP_STATUS_511                        = 511;                                                 // Network Authentication Required';
  //HTTP_STATUS_512                        = 512-599;                                             // Unassigned';
  public
    function  Get(IvUrl: string; var IvContent, IvFbk: string): boolean; // returninternetcontent
  end;

  TIifRec = record // inlineif
  public
    function  Str(IvTest: boolean; IvValueTrue, IvValueFalse: string): string;
    function  Int(IvTest: boolean; IvValueTrue, IvValueFalse: integer): integer;
    function  Nzp(IvTest: double; IvStrIfNegative, IvStrIfZero, IvStrIfPositive: string): string; // string if value is negative, zero, positive

    function  NxD(IvString: string; IvDefault: string = ''): string;                              // if not exists return default else return string
    function  NxR(IvString: string; IvLength: integer = 4): string;                               // if not exists return random string (of 4 chars by default)

    function  ExR(IvString: string; IvReturn: string = ''): string;                               // is exists return else return empty, if IvReturn is empty return the same IvString
    function  ExA(IvString: string; IvAppend: string): string;                                    // if exists append
    function  ExP(IvString: string; IvPrepend: string): string;                                   // if exists prepend
    function  ExS(IvString: string; IvPrepend, IvAppend: string): string;                         // if exists sourround = append+xxx+prepend
    function  ExF(IvString: string; IvFormat: string; IvVec: array of TVarRec): string; overload; // if exists format
    function  ExF(IvString: string; IvFormat: string): string; overload;                          // if exists format, use ivstring as a single element of ivvec

    function  BTR(IvTest: boolean; IvReturn: string): string;                                     // if true return else empty
    function  BFR(IvTest: boolean; IvReturn: string): string;                                     // if false return else empty
    function  Even(IvInteger: integer; IvValueEven, IvValueOdd: string): string;                  // if even IvValueEven else IvValueOdd  *** TODO: move to num.IfEven() ***
    function  NullDef(IvVariant: variant; IvDefault: variant): variant;                           // if null return default else return variant
  end;

  TIisRec = record // inlineis
    function  Nx(IvString: string): boolean; // is not existent  = empty
    function  Ex(IvString: string): boolean; // is existent      = not empty
    function  Na(IvString: string): boolean; // is not available = empty or NA or ...
  end;

  TImgRec = record // image on dba
    Id          : integer;
    PId         : integer;
    State       : string;
    Organization: string;
    User        : string;
    Image       : string;  // name
    Path        : string;
    Url         : string;
    Binary      : TBitmap;
  //Script      : string;  // Svg
  public
    function  DbaInit(var IvFbk: string): boolean;
    function  DbaSelect(var IvFbk: string): boolean;
    function  DbaInsert(var IvFbk: string): boolean;
    procedure DbaToDisk(IvFile, IvTable, IvField, IvWhere: string);
  end;

  TIniCls = class // ini read/write are by prefix: Root/Organization/W/Wks/User
  private                                                            //domain/oslogin
    FIniFile: TIniFile;
  public
    constructor Create;
    destructor  Destroy; override;
    procedure SectionIdent(const IvPath: string; var IvSection, IvIdent: string); // path --> section/ident
    function  StrGet(const IvPath: string; IvDefault: string = ''; IvForceDefaultIfKeyIsEmpty: boolean = false): string;        // normally if a key EXISTS and is EMPTY (like Key=), the IvDefault is not forced
    procedure StrSet(const IvPath, IvValue: string);                                                                            // with IvForceDefaultIfKeyIsEmpty = true the IvDefault is forced even if the key exists and is empty
    function  IntGet(const IvPath: string; IvDefault: integer = -1{; IvForceDefaultIfKeyIsEmpty: boolean = false}): integer;    // force not needed
    procedure IntSet(const IvPath: string; IvValue: integer);
    function  FloGet(const IvPath: string; IvDefault: double = -1{; IvForceDefaultIfKeyIsEmpty: boolean = false}): double;      // force not needed
    procedure FloSet(const IvPath: string; IvValue: double);
    function  BooGet(const IvPath: string; IvDefault: boolean = false{; IvForceDefaultIfKeyIsEmpty: boolean = false}): boolean; // force not needed
    procedure BooSet(const IvPath: string; IvValue: boolean);
    procedure SliGet(const IvPath: string; IvStrings: TStrings; IvDefaultCsv: string = ''; IvForceDefaultIfKeyIsEmpty: boolean = false);
    procedure SliSet(const IvPath: string; IvStrings: TStrings);
    function  TxtGet(const IvPath: string; IvDefaultBr: string = ''; IvForceDefaultIfKeyIsEmpty: boolean = false): string;
    procedure TxtSet(const IvPath, IvValue: string);
    function  CryGet(const IvPath: string; IvDefault: string = ''; IvForceDefaultIfKeyIsEmpty: boolean = false): string;
    procedure CrySet(const IvPath, IvValue: string);
  end;

  PLgrRec = ^TLgrRec;
  TLgrRec = record // logrequest
    Entry: string;
  end;

  TLgtCls = class(TObject)

    {$REGION 'Help'}
    (*
      if no file is specified then the default folder and filename is used
      if the folder is readonly then the Log file is created in the Windows Temp folder

      https://github.com/martinusso/log4pascal
      http://stackoverflow.com/questions/27202975/delphi-multi-threading-file-write-i-o-error-32   critica session
    *)
    {$ENDREGION}

  private
    FFileSpec: string;
    FIndentCount: integer;
    FThreadPool: TThreadPool;
    procedure LogEntryWrite(IvLogRequest: pointer; IvThread: TThread);
    procedure LogEntryThreadPoolAdd(const IvEntry: string);
  public
    property FileSpec: string read FFileSpec write FFileSpec;
    constructor Create(const IvFileSpec: string = '');
    destructor Destroy; override;
    procedure Tag(IvTag: string; IvValue: string = ''; IvType: TLogEntryEnum = TLogEntryEnum.logNone);
    procedure TagFmt(IvTag, IvValueFormatString: string; IvVarRecVector: array of TVarRec; IvType: TLogEntryEnum = TLogEntryEnum.logNone);
    procedure Iif(IvTest: boolean; IvTrueString, IvFalseString: string; IvTag: string = ''; IvType: TLogEntryEnum = TLogEntryEnum.logNone);
    procedure EmptyRow;
    procedure L(IvString      : string       ; IvTag: string = '');                            // none logsimple
    procedure I(IvString      : string       ; IvTag: string = '');                            // info
    procedure W(IvString      : string       ; IvTag: string = '');                            // warning
    procedure E(IvString      : string       ; IvTag: string = ''); overload;                  // exception
    procedure E(IvException   : Exception    ; IvTag: string = ''); overload;                  // exception
    procedure D(IvString      : string       ; IvTag: string = '');                            // debug (write only if delphi ide is present)
    procedure O(IvObject      : TObject      ; IvTag: string = '');                            // object to json
    procedure Q(IvSql         : string       ; IvTag: string = ''; IvOneLine: boolean = true); // query
    procedure P(IvParams      : TParameters  ; IvTag: string = '');                            // adoparams
    procedure S(IvStrings     : TStrings     ; IvTag: string = '');                            // tstrings
    procedure V(IvStringVector: TStringVector; IvTag: string = '');                            // stringvector
    procedure LFmt(IvFormatString: string; IvVarRecVector: array of TVarRec; IvTag: string = '');
    procedure IFmt(IvFormatString: string; IvVarRecVector: array of TVarRec; IvTag: string = '');
    procedure WFmt(IvFormatString: string; IvVarRecVector: array of TVarRec; IvTag: string = '');
    procedure EFmt(IvFormatString: string; IvVarRecVector: array of TVarRec; IvTag: string = '');
    procedure Ds(IvDs: TDataset; IvTag: string = ''; IvFirstN: integer = 0); // dataset 0 = all
    procedure Event(IvToComputer, IvSource, IvString: string; IvType: word; IvCategory: word; IvId: word);
    procedure EventI(IvString: string; IvToComputer: string = '');
    procedure EventW(IvString: string; IvToComputer: string = '');
    procedure EventE(IvString: string; IvToComputer: string = '');
    procedure Enter(IvString: string; IvTag: string = '');
    procedure Leave(IvString: string; IvTag: string = '');
    procedure EnterFmt(IvFormatStr: string; const IvArgVec: array of TVarRec; IvTag: string = '');
    procedure LeaveFmt(IvFormatStr: string; const IvArgVec: array of TVarRec; IvTag: string = '');
  end;

  TLstRec = record // list/csv
  public
    function  Safe           (IvList: string): string;
    function  Has            (IvList, IvItem: string): boolean;
    procedure DelimReset     (var IvList: string; IvWhiteRemove: boolean = false; IvWhiteAsDelimiter: boolean = false);
    function  ItemPos        (const IvItem, IvCsvLine: string): integer;
    function  WhiteToDelim   (IvList: string): string; // aaa bbb  ccc --> aaa,bbb,ccc // suppose items have no spaces!
    procedure ItemAdd        (var IvList: string; const IvItem: string; IvDelimiterChar: string = DELIMITER_CHAR; IvSorroundChar: string = {SORROUND_CHAR} '');
    function  ItemNext       (var IvPChar: PChar; IvSep: Char = DELIMITER_CHAR): string;
    function  ItemUnsorround (IvList       : string; IvDelimiterChar    : string = DELIMITER_CHAR; IvSorroundChar: string = SORROUND_CHAR; IvSpaceAdd: boolean = false): string;
    function  ItemSorround   (IvList       : string; IvDelimiterChar    : string = DELIMITER_CHAR; IvSorroundChar: string = SORROUND_CHAR; IvSpaceAdd: boolean = false): string; // IvList = [a,b,  c] IvDelimiterChar = ','  IvSorroundChar = '"' -> [a,b,c] , Result = ["a","b","c"]
    function  ItemPrepend    (IvList, IvStr: string; IvDelimiterChar    : string = DELIMITER_CHAR                                        ; IvSpaceAdd: boolean = false): string;
    function  ItemAppend     (IvList, IvStr: string; IvDelimiterChar    : string = DELIMITER_CHAR                                        ; IvSpaceAdd: boolean = false): string;
    function  ToVector       (IvList       : string; IvDelimiterChar    : string = DELIMITER_CHAR                                        ; IvTrim: boolean = true): TStringVector;
    function  ToVectorAnyChar(IvList       : string; IvDelimiterCharList: string = DELIMITER_CHAR                                        ; IvTrim: boolean = true): TStringVector;
    function  ToVectorRe     (const IvText, IvList: string; var IvStringVector: TStringVector; var IvFbk: string; IvTrim: boolean = true): boolean; // process text containing ...[List:ListA, Items:ItemA1, ItemA2]...[List:ListB, Items:ItemB1, ItemB2]... search for ListB and return a vector ['ItemB1', 'ItemB2']
    function  FromStr(IvString: string; IvDelimiterChar: string = DELIMITER_CHAR): string; // 'aaa  bbb; ccc' = 'aaa,bbb,ccc'
    function  FromRangeInt(IvRange: string; IvLeadingZero: boolean = false; IvItemLen: integer = -1; IvSorroundChar: string = ''): string; // IvRange = 8-12 | 8..12 --> 8,9,10,11,12 | 08,09,10,11,12 | '08','09','10','11','12'
    function  FromRangeChar(IvRange: string; IvSorroundChar: string = ''): string; // IvRange = a..d | a-d --> a,b,c,d | 'a','b','c','d'
  end;

  TMatRec = record // math
  public
    function  AbsoluteValue(IvValue: double): double; // Absolute value of a real number
    function  Delta(IvMax, IvMin: double): double; overload;
    function  Delta(IvMax, IvMin: integer): integer; overload;
    function  Max2(a, b: double): double; overload;
    function  Max2(a, b: integer): integer; overload;
    function  Max3(a, b, c: double): double; overload;
    function  Max3(a, b, c: integer): integer; overload;
    function  Min2(a, b: double): double; overload;
    function  Min2(a, b: integer): integer; overload;
    function  Min3(a, b, c: double): double; overload;
    function  Min3(a, b, c: integer): integer; overload;
    function  VecIntMax(IvVector: array of integer): integer;           // *** move to TVecRev ***
    function  VecIntMin(IvVector: array of integer): integer;           // *** move to TVecRev ***
    function  VecSingleMax(const IvSingleVec: array of single): single; // *** move to TVecRev ***
    function  VecSingleMin(const IvSingleVec: array of single): single; // *** move to TVecRev ***
  end;

  TMesRec = record // messages, feedbacks only, for inputs use ask
  const
    PLEASE_ENTER_PROXY_AND_PASSWORD    = 'Please enter the proxy address and your username and password if yoy are bihind a firewall';
    NOT_AVAILABLE                      = 'Not available';
  //NETWORK_IS_NOT_AVAILABLE           = 'Network is not available, please check your connection';
    RECORDS_AFFECTED_FMT               = 'Records affected %d';
    UNABLE_TO_AUTHENTICATE_FMT         = 'Unable to authenticate %s';
    REQUEST_LOGIN_AT_FMT               = 'Request login at website %s for a new session...';      // 'Richiesta di accesso al sito %s...';
    PLEASE_ENTER_USERNAME_AND_PASSWORD = 'Please enter your ORGANIZATION, username and password'; // 'Inserire username e password'
  public
    procedure I(IvMessage: string);
    procedure IFmt(IvMessageFormatString: string; IvVarRecVector: array of TVarRec);
    procedure W(IvMessage: string);
    procedure WFmt(IvMessageFormatString: string; IvVarRecVector: array of TVarRec);
    procedure E(IvMessage: string);
    procedure NA; // show a "Not available" message
    procedure About;
    procedure AutoClose(const IvCaption, IvPrompt: string; IvDurationMs: integer = 2000);
    procedure AutoCloseFmt(const IvCaption, IvPrompt: string; IvVarRecVector: array of TVarRec; IvDurationMs: integer);
  end;

  TMimRec = record // mimetype
  const
    MIMETYPE_TEXT   = 'text/plain'                   ; // plain text default if data is primarily text and no other type detected
    MIMETYPE_HTML   = 'text/html'                    ; // html default if common tags detected and server does not supply image/* type
    MIMETYPE_CSS    = 'text/css'                     ;
    MIMETYPE_CSV    = 'text/csv'                     ;
    MIMETYPE_JSON   = 'application/json'             ; // simulate json text content (use application/javascript for json with callback)
    MIMETYPE_JS     = 'application/javascript'       ;
    MIMETYPE_XML    = 'text/xml'                     ; // xml data default if data specifies <?xml with an unrecognized dtd
    MIMETYPE_RTF    = 'text/richtext'                ; // rich text format (rtf)
    MIMETYPE_WSC    = 'text/scriptlet'               ; // windows script component
    MIMETYPE_AIFF   = 'audio/x-aiff'                 ; // audio interchange file, macintosh
    MIMETYPE_AUNX   = 'audio/basic'                  ; // audio file, unix
    MIMETYPE_WAVE   = 'audio/wav'                    ; // pulse code modulation (pcm) wave audio, windows
    MIMETYPE_GIF    = 'image/gif'                    ; // graphics interchange format (gif)
    MIMETYPE_JPG    = 'image/jpeg'                   ; // jpeg image
    MIMETYPE_PJPG   = 'image/pjpeg'                  ; // default type for jpeg images
    MIMETYPE_PNG    = 'image/png'                    ; // portable network graphics (png)
    MIMETYPE_XPNG   = 'image/x-png'                  ; // default type for png images
    MIMETYPE_TIF    = 'image/tiff'                   ; // tagged image file format (tiff) image
    MIMETYPE_BMP    = 'image/bmp'                    ; // bitmap (bmp) image
    MIMETYPE_EMF    = 'image/x-emf'                  ; // enhanced metafile (emf)
    MIMETYPE_WMF    = 'image/x-wmf'                  ; // windows metafile format (wmf)
    MIMETYPE_AVI    = 'video/avi'                    ; // audio-video interleaved (avi) file
    MIMETYPE_MPEG   = 'video/mpeg'                   ; // mpeg stream file
    MIMETYPE_OCTET  = 'application/octet-stream'     ; // binary file default if data is primarily binary
    MIMETYPE_PS     = 'application/postscript'       ; // postscript (ai, eps, or ps) file
    MIMETYPE_BASE64 = 'application/base64'           ; // base64-encoded bytes
    MIMETYPE_MACBIN = 'application/macbinhex40'      ; // binhex for macintosh
    MIMETYPE_PDF    = 'application/pdf'              ; // portable document format (pdf)
    MIMETYPE_APPXML = 'application/xml'              ; // xml data must be server-supplied see also "text/xml" type
    MIMETYPE_ATOM   = 'application/atom+xml'         ; // atom syndication format feed
    MIMETYPE_RSS    = 'application/rss+xml'          ; // really simple syndication (rss) feed
    MIMETYPE_TAR    = 'application/x-compressed'     ; // unix tar file, gzipped
    MIMETYPE_ZIP    = 'application/x-zip-compressed' ; // compressed archive file
    MIMETYPE_GZIP   = 'application/x-gzip-compressed'; // gzip compressed archive file
    MIMETYPE_JAVA   = 'application/java'             ; // java applet
    MIMETYPE_EXEDLL = 'application/x-msdownload'     ; // executable (exe or dll) file
    MIMETYPE_DOC    = 'application/msword'           ;
    MIMETYPE_PPT    = 'application/vnd.ms-powerpoint';
    MIMETYPE_XLS    = 'application/vnd.ms-excel'     ;
    MIMETYPE_MDB    = 'application/vnd.ms-access'    ;
    MIMETYPE_ACCDB  = 'application/msaccess'         ;
    MIMETYPE_DOCX   = 'application/vnd.openxmlformats-officedocument.wordprocessingml.documen'   ;
    MIMETYPE_PPTX   = 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
    MIMETYPE_XLSX   = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'        ;
  public
    function  FromFile(IvFileName: TFileName): string;
    function  FromRegistry(IvFileExt: string): string;
    function  FromContent(IvContent: pointer; IvLength: integer): string;
  end;

  TNetRec = record // network
  public
    function  Info: string;
    function  Domain : string; // WKS
    function  Host   : string; // PHOBOS
    function  OsLogin: string; // giarussi
    function  IpLan  : string; // 192.168.0.1
    function  IpWan  : string; // 212.237.10.198
    function  IpLanFn(var IvIpLan, IvFbk: string): boolean; // 192.168.0.1
    function  IpWanFn(var IvIpWan, IvFbk: string): boolean; // 212.237.10.198
    function  InternetIsAvailable(var IvFbk: string): boolean;
    function  PingStateFromCode(IvCode: integer): string;
    function  PingRaw(const IvAddress: string; var IvFbk: string): boolean;
    function  PingWmi(const IvAddress: string; IvRetries, IvBufferSize: Word; var IvFbk: string): boolean;
    function  Ping(IvAddress: string; var IvFbk: string; IvRetries: integer = 1): boolean;
  end;

  TObjRec = record // object (System, User, Member, Organization, ...)
  public
    function  IdOrPathParamEnsure(IvObject, IvIdOrPathParam: string): string;
    function  IdOrPathSwitchEnsure(IvObject, IvIdOrPathSwitch: string): string;
    function  DbaExists     (IvObject, IvIdOrPath: string; var IvFbk: string ): boolean;
    function  DbaContentGet (IvObject, IvIdOrPath: string; IvDefault: string ): string;
    function  DbaContentSet (IvObject, IvIdOrPath: string; IvValue  : string ): boolean;
    function  DbaParamGet   (IvObject, IvIdOrPath: string; IvDefault: string ): string;
    function  DbaParamSet   (IvObject, IvIdOrPath: string; IvValue  : string ): boolean;
    function  DbaSwitchGet  (IvObject, IvIdOrPath: string; IvDefault: boolean): boolean;
    function  DbaSwitchSet  (IvObject, IvIdOrPath: string; IvValue  : boolean): boolean;
    function  RioExists     (IvObject, IvIdOrPath: string; var IvFbk: string ): boolean;
    function  RioContentGet (IvObject, IvIdOrPath: string; IvDefault: string ): string;
    function  RioContentSet (IvObject, IvIdOrPath: string; IvValue  : string ): boolean;
    function  RioParamGet   (IvObject, IvIdOrPath: string; IvDefault: string ): string;
    function  RioParamSet   (IvObject, IvIdOrPath: string; IvValue  : string ): boolean;
    function  RioSwitchGet  (IvObject, IvIdOrPath: string; IvDefault: boolean): boolean;
    function  RioSwitchSet  (IvObject, IvIdOrPath: string; IvValue  : boolean): boolean;
  end;

  TOrgRec = record // organization

    {$REGION 'Const'}
  const
  //KindOrganization = 'Organization';
  //KindArea         = 'Area';

    DBA_TBL          = 'DbaOrganization.dbo.TblOrganization';
    DBA_FLD          = 'FldOrganization';

    PAGE_FOOTER_HTML = // highslide may be not present!!!
                   '<footer>'
    + sLineBreak +   '<div class="container">'
    + sLineBreak +     '<span class="copyright text-muted small">'
    + sLineBreak +       '<a href="[RvOrganizationWww()]" class="highslide" onclick="return hs.expand(this)">' // hsfullimagelink
    + sLineBreak +         '<img src="[RvOrganizationIconUrl()]" alt="[RvOrganization()]" title="[RvOrganization()]" style="border: none">' // hsthumbnail class="img-responsive"
    + sLineBreak +       '</a>'
  //+ sLineBreak +       '<div class="highslide-caption">' + sys.NAME + '</div>' // caption must be directly after the anchor above
    + sLineBreak +       '&nbsp; WKS - [RvOrganization()] Web Server Application [RvBinVersion()] - user [RvUsername()] - session [RvReqSession()] - fingerprint [RvReqFingerprint()] - expire on [RvOrganizationExpire()] - building time [RvElapsedSec()] s - [RvDateTimeNow()]'
    + sLineBreak +     '</span>'
    + sLineBreak +   '</div>'
    + sLineBreak + '</footer>'
    ;
    PAGE_LEGAL_HTML =  // move to LegalMessage and content to db
                   '<footer style="background-color: #[RvOrganizationFgColor()]; color: #[RvOrganizationBgColor()]">' // #1a171b; color: #ffffff
    + sLineBreak +   '<div class="container">'
    + sLineBreak +   '  <div class="row">'
    + sLineBreak +   '    <div class="col-md-8">'
    + sLineBreak +   '      <div style="text-align: left" class="widget-area" role="complementary">'
    + sLineBreak +   '        <div class="widget widget_text">'
    + sLineBreak +   '          <div class="textwidget">'
    + sLineBreak +   '            <p>[RvOrganizationCopyright()][RvOrganizationVatNumber(&nbsp;- P.I.&nbsp;)][RvOrganizationSsn(&nbsp;- C.F.&nbsp;)]</p>'
    + sLineBreak +   '          </div>'
    + sLineBreak +   '        </div>'
    + sLineBreak +   '      </div>'
    + sLineBreak +   '    </div>'
    + sLineBreak +   '    <div class="col-md-4">'
    + sLineBreak +   '      <div style="text-align: right" class="widget-area" role="complementary">'
    + sLineBreak +   '        <div class="widget widget_text">'
    + sLineBreak +   '          <div class="textwidget">'
    + sLineBreak +   '            <p><a href="[RvPage(Root/Template/Legal)]" style="color: #[RvOrganizationBgColor()]">Legal</a>'
                 +               ' | <a href="[RvPage(Root/Template/Legal/Privacy)]" style="color: #[RvOrganizationBgColor()]">Privacy</a>'
                 +               ' | <a href="[RvPage(Root/Template/Legal/Cookie)]" style="color: #[RvOrganizationBgColor()]">Cookie</a>'
                 +               '</p>'
    + sLineBreak +   '          </div>'
    + sLineBreak +   '        </div>'
    + sLineBreak +   '      </div>'
    + sLineBreak +   '    </div>'
    + sLineBreak +   '  </div>'
    + sLineBreak +   '</div>'
    + sLineBreak + '</footer>'
    ;
    EMAIL_HTML = '' // expects: $Subject$ and $Content$ + various [Rv()]
  //               '<!DOCTYPE html>'
    + sLineBreak + '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" http://www.w3.org/TR/html4/strict.dtd>'
    + sLineBreak + '<html lang="en">'
    + sLineBreak + '<head>'
    + sLineBreak +   '<meta charset="utf-8">'
  //+ sLineBreak +   '<link  href="/Include/bootstrap/3.4.1/css/bootstrap.min.css" rel="stylesheet" type="text/css" crossorigin="anonymous" />'
  //+ sLineBreak +   '<script src="/Include/bootstrap/3.4.1/js/bootstrap.min.js" crossorigin="anonymous"></script>'
  //+ sLineBreak +   '<link  href="/Include/bootstrap-table/1.11.1/dist/bootstrap-table.min.css" rel="stylesheet" type="text/css" />'
  //+ sLineBreak +   '<script src="/Include/bootstrap-table/1.11.1/dist/bootstrap-table.min.js" ></script>'
    + sLineBreak + '</head>'
    + sLineBreak + '<body style="font-family:Calibri; background-color: #[RvOrganizationBgColor()]">' //  link="blue" vlink="purple"
    + sLineBreak +   '<p align="center" style="text-align:center;">'
    + sLineBreak +     '<a href="[RvOrganizationWww()]">'
    + sLineBreak +       '<img src="cid:OrganizationLogoImageCId" height="48" border="0" />' // title="' + IvOrganization + '"
    + sLineBreak +     '</a>'
    + sLineBreak +     '<br>'
    + sLineBreak +     '<span style="font-size:8.0pt; color:gray;">[RvOrganizationSlogan()]</span>'
    + sLineBreak +   '</p>'
  //+ sLineBreak +   '<p align="center" style="text-align:center;font-size:16.0pt;color:[RvOrganizationFgColor()]">$Title$</p>'
    + sLineBreak +   '<h3 align="center" style="color:[RvOrganizationFgColor()]">$Title$</h3>'
    + sLineBreak +   '<br>'
    + sLineBreak +   '<p align="center" style="text-align:center">'
    + sLineBreak +     '<table border="0" cellspacing="0" cellpadding="0" style="width:400px;border-collapse:collapse;margin-left:auto;margin-right:auto;">'
    + sLineBreak +       '<tr>'
    + sLineBreak +         '<td valign="top" style="font-family:Calibri;">'
    + sLineBreak +           '$Content$' // payload
    + sLineBreak +         '</td>'
    + sLineBreak +       '</tr>'
    + sLineBreak +     '</table>'
    + sLineBreak +     '<br>'
    + sLineBreak +     '<br>'
  //+ sLineBreak +     '<hr style="width:20%;color:silver">'
    + sLineBreak +     '<div style="text-align:center;font-size:8.0pt;color:silver">[RvSystemDescription()]</div>'
    + sLineBreak +   '</p>'
    + sLineBreak + '</body>'
    + sLineBreak + '</html>'
    ;
    {$ENDREGION}

  public
    Id             : integer  ; //
    PId            : integer  ; //
    About          : string   ; //
    Acronym        : string   ; // WKS
    Address        : string   ; // Via Trento, 16
    ApiKey         : string   ; // pass to invoke remote services like WksIotIsapi
    BgColor        : string   ; // background \
    BorderColor    : string   ; // border     /
    City           : string   ; // Cittaducale
    Color          : string   ; // primary    \
    Color2         : string   ; // secondary   |
    Country        : string   ; // Italy
    Css            : string   ; // css specific to the organization, saved to file
    DangerColor    : string   ; // danger     /
    Email          : string   ; // wks@wks.cloud
    EmailTemplate  : string   ; // to send organization level email
    Expire         : TDateTime; // datetime
    Fax            : string   ; //
    FgColor        : string   ; // foreground  |--boxmodel
    InfoColor      : string   ; // info        |__bootstrap
    Json           : string   ; // additional json data
    LegalName      : string   ; // Wks srl
    Logo           : TBitmap  ; // graphics
    LogoGraphic    : TGraphic ; // binaryimage
    LogoInv        : TBitmap  ; // graphics
    Name           : string   ; // Working Knowledge System
    Network        : string   ; // other connected organizations or list of sponsored organizations
    Organization   : string   ; // Wks
    Owner          : string   ; // state
    PageFooter     : string   ; // common html for all pages
    PageSwitch     : string   ; // default webpage switches list
    ContentSwitch  : string   ; // default webpage content switches list
    Phone          : string   ; //
    Province       : string   ; // Rieti
    Slogan         : string   ; // company slogan
    Ssn            : string   ; // SocialSecurityNumber/FiscalCode
    State          : string   ; // state
    SuccessColor   : string   ; // success     |
    Symbol         : string   ; // font-awesome symbol
    VatNumber      : string   ; // PartitaIva
    WarningColor   : string   ; // warning     |
    Www            : string   ; // www.wks.cloud
    ZipCode        : string   ; // 02045 zone improvement plan
  //BrandName      : string   ; //
  //CorporateName  : string   ; //
  //FontColor      : string   ; //
  //FontFace       : string   ; // Verdana, "Currier New"
  //FontSize       : string   ; //
  //FontWeight     : string   ; // 400, 700
  //Market         : string   ; //
  //Since          : integer  ; // 1994
  //Stock          : string   ; //
  //TradeName      : string   ; //
    // local
    function  Info: string;
    function  Copyright: string;
    function  IsExpired(var IvFbk: string): boolean;
    function  IsValid(var IvFbk: string): boolean;
    procedure LogoDraw(IvBmp: TBitmap);
    // basepath
    function  AlphaPath(IvSep: char = '/'): string;  // /W/Wks
    function  RegistryPath: string;                  // \Software\Wks\Wks ???
    function  TreePath: string;                      // Root/Organization/W/Wks
    // diskpath
    function  DiskPath: string;                      // C:\$Org\W\Wks
    function  HomePath: string;                      // same
    function  CssPath: string;                       //              \WksCss.css
    function  IconPath: string;                      //              \WksIcon.ico
    function  LogoPath: string;                      //              \WksLogo.png   image on server disk
    function  LogoInvPath: string;                   //              \WksLogoInv.png
    function  LogoSmallPath: string;                 //              \WksLogoSmall.png
    function  LogoSmallInvPath: string;              //              \WksLogoSmallInv.png
    // urlpath
    function  Url: string;                           // http://www.wks.cloud
    function  HomeUrl: string;                       //                     /Organization/W/Wks
    function  CssUrl: string;                        //                                        /WksCss.css
    function  IconUrl: string;                       //                                        /WksIcon.ico
    function  LogoUrl: string;                       //                                        /WksLogo.png
    function  LogoInvUrl: string;                    //                                        /WksLogoInv.png
    function  LogoSmallUrl: string;                  //                                        /WksLogoSmall.png
    function  LogoSmallInvUrl: string;               //                                        /WksLogoSmallInv.png
    // zzz
    function  EmailD(var IvFbk : string; IvToCsv, IvCcCsv, IvBcCsv, IvSubject, IvTitle, IvContent: string; IvSaveToDba: boolean = false): boolean; // \
    function  EmailI(var IvFbk : string; IvToCsv, IvCcCsv, IvBcCsv, IvSubject, IvTitle, IvContent: string; IvSaveToDba: boolean = false): boolean; //  |_ REMOVE, use eml.
    function  EmailS(var IvFbk : string; IvToCsv, IvCcCsv, IvBcCsv, IvSubject, IvTitle, IvContent: string; IvSaveToDba: boolean = false): boolean; //  |
    function  EmailW(var IvFbk : string; IvToCsv, IvCcCsv, IvBcCsv, IvSubject, IvTitle, IvContent: string; IvSaveToDba: boolean = false): boolean; // /
    // disk
    function  DskInit(var IvFbk: string): boolean;   // initialize the disk stuff
    function  DbaInit(var IvFbk: string): boolean;   // initialize the dba stuff
    function  DbaInsert(var IvFbk: string): boolean;
    function  DbaSelect(const IvOrganization: string; var IvFbk: string): boolean;
    // rio
    function  RioInit(const IvOrganization: string; var IvFbk: string): boolean;
  end;

  TOrgRem = class(TRemotable)
  private
    FOrganization: string       ;
    FAcronym     : string       ;
    FName        : string       ;
    FWww         : string       ;
    FSlogan      : string       ;
    FLogoUrl     : string       ;
    FLogoBytes   : TByteDynArray;
  published
    property Organization: string        read FOrganization write FOrganization;
    property Acronym     : string        read FAcronym      write FAcronym     ;
    property Name        : string        read FName         write FName        ;
    property Www         : string        read FWww          write FWww         ;
    property Slogan      : string        read FSlogan       write FSlogan      ;
    property LogoUrl     : string        read FLogoUrl      write FLogoUrl     ;
    property LogoBytes   : TByteDynArray read FLogoBytes    write FLogoBytes   ;
  end;

  TPalRem = class(TRemotable) // similbootstrap
  private
    FBackground: string;
    FPrimary   : string;
    FSecondary : string;
    FInfo      : string;
    FSuccess   : string;
    FWarning   : string;
    FDanger    : string;
    FError     : string;
  published
    property Background: string read FBackground write FBackground;
    property Primary   : string read FPrimary    write FPrimary   ;
    property Secondary : string read FSecondary  write FSecondary ;
    property Info      : string read FInfo       write FInfo      ;
    property Success   : string read FSuccess    write FSuccess   ;
    property Warning   : string read FWarning    write FWarning   ;
    property Danger    : string read FDanger     write FDanger    ;
    property Error     : string read FError      write FError     ;
  end;

  TPatRec = record // pathfile
    function  Volume(IvFile: string): string;                      // C:\Path\Name.ext --> C:  *** WARNING: will not include the final \ ***
    function  Path(IvFile: string): string;                        // C:\Path\Name.ext --> C:\Path
    function  NameDotExt(IvFile: string): string;                  // C:\Path\Name.ext --> Name.ext
    function  Name(IvFile: string): string;                        // C:\Path\Name.ext --> Name
    function  Ext(IvFile: string): string;                         // C:\Path\Name.ext --> .ext
    function  NameChange(const IvFile, IvNameNew: string): string; // C:\Path\Name.ext --> C:\Path\Newname.ext
    function  DelimiterEnsure(IvPath: string): string;             // C:\Path -> C:\Path\
    function  ExtHas(IvFile: string): boolean;                     // C:\Path\Name.ext -> true
    function  ExtEnsure(IvExt: string): string;                    // txt -> .txt
    function  TreePathNormalize(IvThreePath: string): string;      // change \ or . to /
    function  TreePathIs(IvThreePath: string): boolean;            //
  end;

  TPopRec = record // pop3
    Organization : string;
    Host         : string;
    Port         : string;
    Username     : string;
    Password     : string;
    TrySecureAuth: boolean;
    NewerMsgFirst: boolean;
    CleanOnExit  : boolean; // delete messages afther download
  public
    function  DbaSelect(var IvFbk: string): boolean;
    function  RioInit(IvOrganization: string; var IvFbk: string): boolean;
  end;

  TPxyRec = record // proxyserver
  public
    Use     : boolean;
    Address : string; // ip
    Port    : string;
    Username: string;
    Password: string;
  public
    procedure SoapConnectionProxySet(var IvSoapConnection: TSoapConnection);
    procedure HttpRioProxySet(var IvHttpRio: THTTPRIO);
  end;

  TRexRec = record // regex https://www.debuggex.com

    {$REGION 'Help'}
    (*
    javascript
    ----------
    .        any non newline character
    [abx-z]  one character of: a, b, or the range x-z          ^        beginning of the string
    [^abx-z] one character except: a, b, or the range x-z      $        end of the string
    a|b      a or b                                            \d       a digit (same as [0-9])
    a?       zero or one a's  (greedy)                         \D       a non-digit (same as [^0-9])
    a??      zero or one a's  (lazy)                           \w       a word character (same as [_a-zA-Z0-9])
    a*       zero or more a's (greedy)                         \W       a non-word character (same as [^_a-zA-Z0-9])
    a*?      zero or more a's (lazy)                           \s       a whitespace character
    a+       one or more a's  (greedy)                         \S       a non-whitespace character
    a+?      one or more a's  (lazy)                           \b       a word boundary
    a{4}     exactly 4 a's                                     \B       a non-word boundary
    a{4,8}   between (inclusive) 4 and 8 a's                   \n       a newline
    a{9,}    9 or more a's                                     \t       a tab
    (?=...)  a positive lookahead                              \cY      the control character with the hex code Y
    (?!...)  a negative lookahead                              \xYY     the character with the hex code YY
    (?:...)  a non-capturing group                             \uYYYY   the character with the hex code YYYY
    (...)    a capturing group                                 \Y       the Y'th captured group

    Delphi
    ------
    Delphi use a traslation of pcre.h, see this link for help on pcre: http://mushclient.com/pcre/pcrepattern.html
    Regular expressions are greedy, they take in as much as they can

    ^        BEGINNING OF LINE
             a circumflex at the start of the expression matches the start of a line

    $        END OF LINE
             a dollar sign at the end of the expression matches the end of a line

    .        ANY ONE CHAR (except \n normally = single line mode)
             a period matches a single instance of any character
             for example, b.t matches bot, and bat, but not boat

    ?        ZERO OR ONE OF PREVIOUS CHARACTER
             a question mark after a character/charactergroup matches zero or one occurrences of that character/group
             for example, bo?t matches both bt and bot.
             ?should be greedy?

    *        ZERO OR MORE OF PREVIOUS CHARACTER (as many as possible)
             an asterisk after a character/charactergroup matches any number of occurrences of that character/group, including zero occurrences
             for example, bo*t matches bt, bot, and boot
    *?       non greedy version

    +        ONE OR MORE OF PREVIOUS CHARACTER (as many as possible)
             a plus sign after a character/charactergroup matches any number of occurrences of that character/group, with at least one occurrence
             for example, bo+t matches bot and boot, but not bt
    +?       non greedy version

    |        OR
             a vertical bar matches each expression on each side of the vertical bar
             for example, bar|car will match either bar or car

    [ ]      ANY ONE CHAR IN THIS SET
             characters inside square brackets match any character that appears in the brackets, but no others
             for example, [bot] matches b, o, or t

    [^]      ANY ONE CHARACTER NOT IN THIS SET
             a circumflex at the start of a string inside square brackets means NOT, hence [^bot] matches any characters except b, o, or t
             [^] alone matchs across newline boundary

    [-]      RANGE OF CHARACTERS
             a hyphen inside square brackets signifies a range of characters
             for example [b-o] matches any character from b through o

    { }      GROUPING
             braces group characters or expressions
             groups can be nested, with a maximum number of 10 groups in a single pattern
             for the Replace operation, groups are referred to by a backslash and a number,
             according to the position in the "Text to find" expression, beginning with 0
             for example, find: {[0-9]}{[a-c]*} and replace: NUM\1, the string 3abcabc is changed to NUMabcabc

    ( )      parenthesis are an alternative to braces ({ }), with the same behavior

    \        ESCAPE
             a backslash before a wildcard character tells the Code Editor to treat that character literally, not as a wildcard
             for example, \^ matches ^ and does not look for the start of a line

             RECURSION
    (?#)     a special item that consists of (? followed by a number greater than zero and a closing parenthesis
             is a recursive call of the group of the given number, provided that it occurs inside that subpattern.
             the special item (?R) or (?0) is a recursive call of the entire regular expression
    (R)      tests for recursion, do not confuse it with the (?R) item, which is a recursion to the entire regex


    shortcuts i (see: http://www.regular-expressions.info/refreplacecharacters.html)
    -----------
    \n    match LF              LINE FEED
    \r    match CR              CARRIAGE RETURN
    \r\n  match windows CRLF    LINE BREACK / NEW LINE
    \t    match TAB             ASCII 0x09
    \a    match ALERT/BELL      ASCII 0x07
    \b    match BACKSPACE       ASCII 0x08
    \e    match ESCACE          ASCII 0x1A
    \f    match FORM FEED       ASCII 0x0C
    \v    match VERTICAL TAB    ASCII 0x0B  (vertical whitespace)
    \h    match vertical whitespace
    \0    match NULL CHAR       ASCII 0x00
    \+    match +               ...and other special chars


    shortcuts ii
    ------------
    \d    match a single "digit char"           = [0-9]
    \w    match a single "word char"            = [A-Za-z0-9_]   alphanumeric characters plus underscore
    \s    match a single "whitespace char"      = [ \t\r\n\f]    space, tab, linebreack, formfeed


    negated shortcuts ii
    --------------------
    \D   match a single NOT "digit char"        = [^\d]
    \W   match a single NOT "word char"         = [^\w]
    \S   match a single NOT "whitespace char"   = [^\d]

    notevoli
    --------
    \s\d                  matches a whitespace followed by a digit (2 chars)
    [\s\d]                matches a "single" character that is either whitespace or a digit
    [\da-fA-F]            matches a hexadecimal digit
    [0-9a-fA-F]           idem
    \D\S                  matche a "not digit" followed by a "not whitespace"
    [\D\S]                matches a "not digit" or a "not whitespace"

    gready vs lazy
    --------------
    Greedy means match longest possible string   greedy h.+l  matches 'hell' in 'hello'
    Lazy means match shortest possible string    lazy   h.+?l matches 'hel'  in 'hello'

    +-------------------+-----------------+------------------------------+
    | Greedy quantifier | Lazy quantifier |        Description           |
    +-------------------+-----------------+------------------------------+
    | *                 | *?              | Star Quantifier: 0 or more   |
    | +                 | +?              | Plus Quantifier: 1 or more   |
    | ?                 | ??              | Optional Quantifier: 0 or 1  |
    | {n}               | {n}?            | Quantifier: exactly n        |
    | {n,}              | {n,}?           | Quantifier: n or more        |
    | {n,m}             | {n,m}?          | Quantifier: between n and m  |

    options
    -------

    roNone                Specifies that no options are set

    roIgnoreCase          Specifies case-insensitive matching

    roSingleLine          Specifies single-line mode. Treats the entire text like "a single line" (ignore \n and treats it like any other char)
                          Hence ^ and $ match the beginning and end of the entire text, not the beginning and end of every "virtual" row between \n
                          Changes also the meaning of the dot (.) so it matches every character including \n, making possible to search across "virtual" row between \n
                          Normally the dot (.) matches any character except \n

    roMultiLine           Specifies multi-line mode. Treats the entire text like "many lines" (do NOT ignore \n)
                          Changes the meaning of ^ and $ so they match at the beginning and end
                          of any "virtual" row between \n, and not just the beginning and end of the entire text

    roExplicitCapture     Specifies that the only valid captures are explicitly named or numbered groups of the form (?<name>…)
                          This allows unnamed parentheses to act as noncapturing groups
                          without the syntactic clumsiness of the expression (?:…)

    roCompiled            Specifies that the regular expression is compiled to an assembly
                          This yields faster execution but increases startup time
                          This value should not be assigned to the Options property when calling the CompileToAssembly method

    roIgnorePatternSpace  Eliminates unescaped white space from the pattern and enables comments marked with #
                          However, the IgnorePatternWhitespace value does not affect or eliminate white space in character classes
    *)
    {$ENDREGION}

  const

    {$REGION 'General'}
    REX_EMPTY_LINE_PAT        = '(?m)^[ \t]*\r?\n';                                 //^[ \t]*(\r\n?|\n)$';
    REX_EMPTY_LINE_PAT2       = '(?:\r?\n){2,}';                                    // \r?\n is both Windows and Linux compatible. {2,} means "two or more instances"

    REX_URL_PAT               = '(http(s)*:\/\/[\w-]+\.{0,1}[\w-]*\.(com|org|net|gr|htm|html|cloud))'; // *** VERY LIMITED ***
                                                                                    // http(s)* search for http or https
                                                                                    // followed by ://
                                                                                    // then one or more characters or -
                                                                                    // followed by zero or one . (dot)
                                                                                    // then zero or more characters or -
                                                                                    // followed by a . (dot)
                                                                                    // followed by one of com or org or net or gr or htm or html
    {$ENDREGION}

    {$REGION 'Comment'}
    REX_HTML_COMMENT_PAT      = '<!--.*?-->';                                       // html comment

    REX_SQL_COMMENT_PAT       = '(--(.*|[\r\n]))$';                                 // sql comment at end of line (only --)
  //REX_SQL_COMMENT_PAT2      = '^\s*-{2,2}[^-].*$';                                // sql comment full line (only 2 --, also collide with markdown <h2> titles)

  //REX_PAS_COMMENT_PAT       = '(^\s*//.*?(\r\n?|\n))';                            // c, c++ and pas // comment full line
  //REX_PAS_COMMENT_PAT2      = '//.*?$';                                           // c, c++ and pas // comment full line

    REX_CPP_COMMENT_PAT       = '\/\*[\s\S]*?\*\/|([^:]|^)\/\/.*$';                 // cpp /**/ or //
                                                                                    // this WILL remove:
                                                                                    //   /* multi-line comments */
                                                                                    //   // single-line comments
                                                                                    // will NOT remove:
                                                                                    //   String var1 = "this is /* not a comment. */";
                                                                                    //   char *var2 = "this is // not a comment, either.";
                                                                                    //   url = 'http://not.comment.com';

    REX_RV_COMMENT_PAT        = '\[--Rv.*?\(.*?\)\]';                               // rv comment like [--RvAaa(bbb|ccc)] // \[--Rv[^]]*?\] | \[--Rv.*--\]
    {$ENDREGION}

    {$REGION 'Ranges'}
  //REX_INTEGER_RANGE_PAT     = '^([0-9]*)-([0-9]*)$';                              // ex: 12-34 -> g0=12-34 , g1=12 , g1=34
    REX_INTEGER_RANGE_PAT     = '-?[0-9]+--?[0-9]+|-?[0-9]+\.\.-?[0-9]+';           // ex: 1-12 | -12..-1
    REX_CHAR_RANGE_PAT        = '[a-zA-Z]-[a-zA-Z]|[a-zA-Z]\.\.[a-zA-Z]+';          // ex: a-z | c..j
    {$ENDREGION}

    {$REGION 'List'}
    REX_LIST_PAT              = '\[List=%s, Items=(.*)\]';                          // [List=List1, Items=Item1, Item2] will return: Item1, Item2
    REX_CSV_PAT               = '".+?"|[^"]+?(?=,)|(?=,)[^"]+';                     // match: 123,2.99,AMO024,Title,"Description, more info",,123987564
    REX_CSV_PAT2              = '("([^"]*)"|[^,]*)(,|$)';                           // matches a single column from the CSV line, first portion "([^"]*)" matches a quoted entry, the second part [^,]* matches a non-quoted entry, then either followed by a , or end of line $
    {$ENDREGION}

    {$REGION 'Dollar'}
    REX_DOLLAR_VAR_PAT        = '\$\w*\$';                                          // matches any $Abc$ var-placeholder
    {$ENDREGION}

    {$REGION 'Rv'}
    REX_RV_CHECK_PAT          = '\[Rv.*\(.*\)\]';                                   // used to check existence of [Rv...()] tag
  //REX_RV_PAT                = '\[Rv(\w?)\((.*?)\)\]'                              // simple
    REX_RV_PAT                = '\[(Rv(\w*?)|Rv(\w*?)\((.*?)\)?)\]';                // capture any [RvXxx] or [RvXxx()] or [RvXxx(aaa, bbb, ...)]
    REX_RV_RECURSIVE_PAT      = '\[Rv(\w*?)'                                        // outher beginning search-key + group-1 for the function name
                              +   '('                                               // outher group-2, the start point for recursive (?2) call
                              +     '\('                                            // opening "("
                              +       '('                                           // inner group-3 start
                              +         '(?>[^()]+)'                                // subpattern, everything that is non-parentheses, one or more times
                              +           '|'                                       // or
                              +         '(?2)'                                      // recursive match call of to group-2
                              +       ')*'                                          // inner group-3 end, any number of times
                              +     '\)'                                            // closing ")"
                              +   ')'                                               // outher group-2 end
                              + '\]'                                                // outher end searching
                              ;
  //REX_RV_FUNCTION           = '\[Rv([^]]*)\(([^]]*)\)\]';                         // . = anychar , [^]]anycharexcept]
  //REX_RV_COLOR              = '\[RvColor\((.*)\)\]';
  //REX_RV_COLOR_AGG          = '\[RvColorAgg\((.*)\)\]';
  //REX_RV_COLOR_HTML         = '\[RvColorHtml\((.*)\)\]';
  //REX_RV_NOW                = '\[RvNow\((.*)\)\]';
  //REX_RV_YEAR               = '\[RvYear\((.*)\)\]';
  //REX_RV_MONTH              = '\[RvMonth\((.*)\)\]';
  //REX_RV_DAY                = '\[RvDay\((.*)\)\]';
  //REX_RV_HTML_BADGE         = '\[RvHtmlBadge\((.*)\)\]';
  //REX_RV_HTML_BAR           = '\[RvHtmlBar\((.*)\)\]';
  //REX_RV_HTML_BAR_01        = '\[RvHtmlBar01\((.*)\)\]';
  //REX_RV_HTML_BAR_PERCENT   = '\[RvHtmlBarPercent\((.*)\)\]';
  //REX_RV_HTML_IMAGE         = '\[RvHtmlImage\((.*)\)\]';
  //REX_RV_HTML_CANVAS_GRAPH  = '\[RvHCanvasJsGraph\((.*)\)\]';
  //REX_RV_IF                 = '\[RvIf\((.*)\)\]';
  //REX_RV_IFELSE             = '\[RvIfElse\]';
  //REX_RV_IFEND              = '\[RvIfEnd\]';
  //REX_RV_PAGE               = '\[RvPage\(([\d]*)\)\]';                            // 15
  //REX_RV_FILE               = '\[RvFile\((.*)\)\]';                               // FD61CB1C-B74A-468E-A03F-CB4204D594C3
  //REX_RV_REPORT_URL         = '\[RvReportUrl\((.*)\)\]';                          // PrjMap | 37  --> url to the whole report
  //REX_RV_REPORT_URL_CONTENT = '\[RvReportUrlContent\((.*)\)\]';                   // PrjMap | 37  --> html content only (table part only)
  //REX_RV_HTTPURLGET         = '\[RvHttpUrlGet\((.*)\)\]';                         // http://www.example.com
  //REX_INT_SIGN_UNSIG_PAT    = '\[RvNow\(([+-]?(?<!\.)\b[0-9]+\b(?!\.[0-9]))\)\]'; //
  //REX_KEY_VALUE             = '=[[](.*)[]]';                                      //
  //REX_EDIT_FIELD_PAT        = '\[-\s*Ask=(.*);\s*Select=(.*);\s*Default=(.*)-\]'; //
  //REX_DBA_TAG               = '[%s.%s.%s(%s)]';                                   // [Database.Table.Field(Id)]
  //REX_DBA_TAG2              = '[%s]';                                             // [Xxx]
  //REX_DBA_TAG_PAT           = '\[(\w*)\.(\w*)\.(\w*)\((\d*)\)\]';
  //REX_DBA_TAG_PAT2          = '\[.*\]';
    {$ENDREGION}

  public
    function  Has(IvString, IvPattern: string; IvOpt: TRegExOptions = [roIgnoreCase, roMultiLine]): boolean;
    procedure Search(IvString, IvPattern: string; IvStart: integer; var IvPosition, IvLenght: integer  ; IvOpt: TRegExOptions = [roIgnoreCase, roSingleLine]); overload;
    procedure Search(IvString, IvPattern: string                  ; var IvPosition, IvLenght: integer  ; IvOpt: TRegExOptions = [roIgnoreCase, roSingleLine]); overload;
    procedure Replace(var IvString: string; IvReOut, IvStringIn: string                                ; IvOpt: TRegExOptions = [roIgnoreCase, roSingleLine]; IvCount: integer = -1); // -1=replaceall
    procedure ReplaceEx(var IvString: string; IvReWithOneGroupOut, IvStringWithOnePlaceholderIn: string; IvOpt: TRegExOptions = [roIgnoreCase, roSingleLine]); // IvText=...[RvPage(123)]... , IvReOut=[RvPage((/d))] , IvStringIn=Page.asp?CoId=%s , result=Page.asp?CoId=123
    function  Extract(IvString, IvPattern: string                                                      ; IvOpt: TRegExOptions = [roIgnoreCase, roSingleLine]): string;
    function  ExtractGroup(IvString, IvPattern: string; IvGroup: integer = 0                           ; IvOpt: TRegExOptions = [roIgnoreCase, roSingleLine]): string; overload; // pattern must have one group, the result will be the 1st group (Match[1])
    function  ExtractVeVe(IvString, IvPattern: string                                                  ; IvOpt: TRegExOptions = [roIgnoreCase, roSingleLine]): TStringMatrix; // return a vector of vectors, each containing the submatches
  end;

  TRioRec = record // httprio
  public
    // SOAP RELATED
    function  RioUrl(IvObj: string = 'System'): string;
    function  HttpRio(IvObj: string = 'System'): THTTPRIO;
    function  HttpRioUrlSet(var IvFbk: string; var IvHttpRio: THTTPRIO; IvObj: string): boolean;
  //function  SoapRioCreateByUrl({IvOwner: TComponent;}var IvHttpRio: THTTPRIO; IvName, IvUrl: string; var IvFbk: string): boolean;
  //function  SoapRioCreateByPsw({IvOwner: TComponent;}var IvHttpRio: THTTPRIO; IvName, IvPort, IvService, IvWsdl: string; var IvFbk: string): boolean; // by Port, Service, Wsdl
  //function  SoapRioCreate     ({IvOwner: TComponent;}var IvHttpRio: THTTPRIO; IvObj, IvService: string; var IvFbk: string): boolean;
    // DBA RELATED (ORGANIZATION AND USERNAME IS REQUIRED TO CHECK AUTHENTICATION VIA ACTIVE SESSION PRESENCE ON SERVER SIDE AND AUTORIZATION VIA ...)
    function  IdMax        (const IvTable, IvWhere: string; var IvIdMax: integer; var IvFbk: string): boolean;  // move to TRioRec.IdMax -> TSysRec.RioIdMax etc.
    function  IdNext       (const IvTable, IvWhere: string; var IvIdNext: integer; var IvFbk: string): boolean;
    function  IdExists     (const IvDot: string; IvId: integer; var IvFbk: string): boolean;
    function  OIdIdExists  (const IvDot, IvOFld: string; IvOId, IvId: integer; var IvFbk: string): boolean; // ownerid and id (for nested tree data)
    function  FieldGet     (const IvDot: string; IvId: integer  ; var   IvValue: variant; IvDefault: variant; var IvFbk: string): boolean;
    function  FieldSet     (const IvDot: string; IvId: integer  ; const IvValue: variant                    ; var IvFbk: string): boolean;
    function  FieldGetWhere(const IvDot: string; IvWhere: string; var   IvValue: variant; IvDefault: variant; var IvFbk: string): boolean;
    function  FieldSetWhere(const IvDot: string; IvWhere: string; const IvValue: variant                    ; var IvFbk: string): boolean;
    function  ObjPropGet   (const IvDot: string; IvId: integer  ; var   IvValue: variant; IvDefault: variant; var IvFbk: string): boolean;// dbatblfld like 'TblPerson.dbo.TblPerson.FldName'
    function  ObjPropSet   (const IvDot: string; IvId: integer  ; const IvValue: variant                    ; var IvFbk: string): boolean;
    function  IdOf         (const IvDot, IvKeyFld, IvKeyValue: string; var IvId: integer; var IvFbk: string): boolean;
  //function  RecordInsertSimple(const IvTable: string; const IvStringVe: TStringVector; var IvFbk: string): boolean;
  end;

  TRndRec = record // random
  public
    function  Int(IvBegin: integer = 0; IvEnd: integer = 100): integer;
    function  Str(IvLenght: integer = 4): string;
  end;

  TSesRec = record // session
    Session      : string;
    BeginDateTime: TDateTime;
    HasBeenOpen  : boolean;
  public
    function  Info: string;
    function  DbaNewAndSet(IvOrganization, IvUsername, IvPassword: string; var IvFbk: string): boolean; // login
    function  DbaUnset(IvOrganization, IvUsername, IvPassword: string; var IvFbk: string): boolean; // logout
    function  RioOpen(IvOrganization, IvUsername, IvPassword: string; var IvFbk: string): boolean;
    function  RioExists(IvOrganization, IvUsername, IvSession: string; var IvFbk: string): boolean;
    function  RioClose(IvOrganization, IvUsername: string; var IvFbk: string): boolean;
  end;

  TSqlRec = record
  public
    function  Validate(IvSql: string; var IvFbk: string): boolean;
    function  Val(IvValue: variant{; IvDefault: variant = null}): string; // plain quoted or null
    function  WhereEnsure(IvWhere: string): string;                       // ensure 'where ' in front if necessary
    function  WhereAppend(IvSql, IvWhere: string): string;                // append 'where ...' at the end of the select if any
    function  Filter(IvFilter, IvFieldToSearchCsv: string; IvAdditionalExplicitFilter: string = ''): string;
  end;

  TSmtRec = record // smtp
    Organization: string;
    Host        : string;
    Port        : string;
    Username    : string;
    Password    : string;
  public
    function  DbaSelect(var IvFbk: string): boolean;
    function  RioInit(IvOrganization: string; var IvFbk: string): boolean;
  end;

  TSopRec = record // soap

    {$REGION 'Help'}
    {
    naming
    ------
    WS    Web Service
    SOAP  Simple Object Access Protocol
    AS    Application Server
    SAS   Soap Application Server
    SOA   service Oriented Architecture

    description
    -----------
    Soap serverservice might be invoked from classic winapp via soapconnection and/or soaprio
    Might it be invoked from an isapiserver? yes
    Might it be invoked from a javascript script?

    <service name="IXxxSoapMainDataModuleservice">
      <port name="IXxxSoapMainDataModulePort" binding="tns:IXxxSoapMainDataModulebinding">
        <soap:address location="http://www.abc.eu/Soap/XxxSoapProject.exe/soap/IXxxSoapMainDataModule"/>
      </port>
    </service>

    links
    -----
    url:  http://localhost/WksXxxSoapProject.dll/switch?Param0=0&Param1=1
    wsdl: http://localhost/WksXxxSoapProject.XxxSoapMainService/wsdl/IXxxSoapMainService

    wsdl & soap links
    -----------------
    http://localhost/WksXxxSoapProject.dll/wsdl/IXxxSoapMainService   <-- wsdl ws xml definition
    http://localhost/WksXxxSoapProject.dll/soap/IXxxSoapMainService   <-- soap ws location

    http://localhost/WksXxxSoapProject.dll/wsdl/IAppServer
    http://localhost/WksXxxSoapProject.dll/soap/IAppServer

    http://localhost/WksXxxSoapProject.dll/wsdl/IAppServerSOAP

    http://localhost/WksXxxSoapProject.dll/wsdl/IXxxSoapMainDataModule
    http://localhost/WksXxxSoapProject.dll/soap/IXxxSoapMainDataModule

    debug
    -----
    SoapUI is the way to go, to see how things should work
    Use the RIO.OnBeforeExecute and AfterExecute events to examine the XML that you're sending and receiving
    Compare those to what SoapUI sends and receives
    Ignore differences in namespaces, which shouldn't matter
    Ideally, you should be able to take the XML coming out of the OnBeforeExecute event (save the stream to a text file or log),
    paste into SoapUI, (right-click to clean-up/reformat in SoapUI) and see if the XML makes sense,
    and see what happens when you submit that
    If it turns out that your XML is close to working, but a 'tweak' is needed,
    you can edit the XML in the OnBeforeExecute event with StringReplace, etc., and 'fix' the XML so it works
    }
    {$ENDREGION}

  const
    SOAP_FIX_VALUE         = '<Value xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xsd:string"></Value>';
    SOAP_URL               = 'http://%s';                                                    // %s=website:port (localhost, www.abc.com)
    SOAP_DLL_URL           =          '/Wks%sSoapProject.dll';                               // %1=Xxx
    SOAP_WSDL_PUBLISH_URL  =                               '/soap/IWSDLPublish';             // ?
    SOAP_DM_URL            =                               '/soap/I%sSoap%sDataModule';      // %1=Xxx, %2=Main (IvObj, ivservice=Main as a default)
    SOAP_WSDL_URL          =                               '/wsdl/I%sSoap%sService';         // %1=Xxx, %2=Main (IvObj, ivservice)
    SOAP_RIO_URL           =                               '/soap/I%sSoap%sService';         // %1=Xxx, %2=Main
    SOAP_SERVICE           =                                     'I%sSoap%sServiceservice';  // %1=Xxx, %2=Main
    SOAP_PORT              =                                     'I%sSoap%sServicePort';     // %1=Xxx, %2=Main
    SOAP_SERVER_AVAILABLE_NO          = 'SOAP server %s is not available';                   // 'SOAP server %s non e'' disponibile';
    SOAP_SERVER_AVAILABLE_OK          = 'SOAP server %s is available';                       // 'SOAP server %s e'' disponibile';
    SOAP_SERVER_CONN_URL_FOUND_NO_RS  = 'SOAP server, unable to find connection url at %s';  // 'SOAP server, impossibile trovare url di connessione a %s';
    SOAP_SERVER_CONN_URL_FOUND_OK_RS  = 'SOAP server, found connection url at %s';           // 'SOAP server, trovato url di connessione a %s';
  //SOAP_SERVER_INFO_RS               = 'SOAP server info';                                  // 'SOAP server info';
    SOAP_SERVER_RIO_URL_FOUND_NO_RS   = 'SOAP server, unable to find RIO service url at %s'; // 'SOAP server, impossibile trovare url per servizio RIO di %s';
    SOAP_SERVER_RIO_URL_FOUND_OK_RS   = 'SOAP server, found RIO service url at %s';          // 'SOAP server, trovato url per servizio RIO di %s';
  //SOAP_SERVER_RIO_WSDL_FOUND_NO_RS  = 'SOAP server, unable to find RIO WSDL url at %s';    // 'SOAP server, impossibile trovare WSDL url per servizio RIO di %s';
  //SOAP_SERVER_RIO_WSDL_FOUND_OK_RS  = 'SOAP server, found RIO WSDL url at %s';             // 'SOAP server, trovato WSDL url per servizio RIO di %s';
  public
    function  SoapUrl(IvObj: string = ''): string;
    function  SoapRioUrl(IvObj, IvService: string; var IvUrl, IvFbk: string): boolean;
    function  SoapRioWsdl(IvObj, IvService: string; var IvWsdl, IvFbk: string): boolean;
    function  DmUrl(var IvFbk, IvUrl: string; IvObj: string = ''; IvService: string = 'Main'): boolean; // datamodule, IWSDLPublish or IXxxSoapYyyDataModule (datamodule: Xxx=Object, Yyy=Service=Main)
    function  ConnectionAgentSet(var IvFbk: string; var IvSoapConnection: TSoapConnection): boolean;
    function  ConnectionUrlSet(var IvFbk: string; var IvSoapConnection: TSoapConnection; IvObj: string = ''; IvService: string = 'Main'): boolean;
  end;

  TSrvRec = record // DOUBLENATURE : clientconectto AND webserver (isapi,soap,rest) + webstuff (field & commpn inputs) ********************* ??? DA RIMUOVERE ??? ******************* --> wre / wrs
  public
    WwwDev         : string;  // clientconectto localhost         \
    WwwTest        : string;  // clientconectto www.rumors.cloud   |-- client connects here
    WwwProd        : string;  // clientconectto www.wks.cloud     /
    Environment    : string;  // clientconectto Dev, Test, Prod    |-- drives one of the above, may drive also db env?
    Port           : string;  // server port
    Protocol       : string;  // server protocol
  //WwwAuthenticate: string;  // server wwwauthenticate
    OtpIsActive    : boolean; // server checks otp in incoming call and write fresh otp at the end of the reply
    AuditIsActive  : boolean; // server logs any incoming request
  //Organization   : string;  // server organization
    AdminCsv       : string;  // server admin
    HtmlLibrary    : string;  // W3, B3, B4
  //function  AuthenticateUrl(IvTail: string = ''): string;
    function  Info: string;
    function  Init(const IvAdminCsv, {IvWwwDev, IvWwwTest,} IvWwwProd, IvPort: string; IvOtpIsActive, IvAuditIsActive: boolean; var IvFbk: string): boolean;
    function  Link(IvObj: string; IvId: integer; IvContext: string = ''): string; // http://www.sys.com/WksDocumentIsapiProject.dll/Document?CoId=123#page=4
    function  PageUrl(IvId: string = ''; IvTail: string = ''): string;
    function  Ping(var IvFbk: string): boolean; // IsOnline
    function  QueryStringEncode(IvQueryString: string): string;
    procedure QueryStringFieldAdd(var IvQueryString: string; IvField, IvValue: string);
    function  Url: string;                                                           // http://www.sys.com (noport)
    function  Www: string;                                                           //        www.sys.com (noport, noprotocol)
    function  ObjUrl(IvObj: string = ''; IvTail: string = ''): string;               // http://www.sys.com/User (, Code, Dba, File, Filer, Include, ImageI, Organization, Member, Person, Photo)
    function  ObjIsapiUrl(IvObj: string = ''; IvTail: string = ''): string;          // http://www.sys.com/WksUserIsapiProject.dll
    function  ObjSoapUrl(IvObj: string = ''; IvTail: string = ''): string;           // http://www.sys.com/WksUserSoapProject.dll
    function  ScriptUrl(IvTail: string = ''): string;
  end;

  TStiRec = record // stateitem
    Key    : string;
    BgColor: TColor;
    FgColor: TColor;
  end;

  TStiRecVec = array of TStiRec;

  TStaRec = record // state
  const
    Accepted          : TStiRec = (Key: 'Accepted'         ; BgColor: clGreen     ; FgColor: clWhite    );
    Active            : TStiRec = (Key: 'Active'           ; BgColor: clGreen     ; FgColor: clWhite    );
    Any               : TStiRec = (Key: ''                 ; BgColor: clWhite     ; FgColor: clGray     );
    Archived          : TStiRec = (Key: 'Archived'         ; BgColor: clGray      ; FgColor: clBlack    );
    Assigned          : TStiRec = (Key: 'Assigned'         ; BgColor: clAqua      ; FgColor: clRed      );
    Available         : TStiRec = (Key: 'Available'        ; BgColor: clYellow    ; FgColor: clGreen    );
    Cancelled         : TStiRec = (Key: 'Cancelled'        ; BgColor: clWhite     ; FgColor: clGray     );
    Completed         : TStiRec = (Key: 'Completed'        ; BgColor: clLime      ; FgColor: clBlue     );
    Deleted           : TStiRec = (Key: 'Deleted'          ; BgColor: clGray      ; FgColor: clWhite    );
    Deprecated        : TStiRec = (Key: 'Deprecated'       ; BgColor: clGray      ; FgColor: clWhite    );
    Developed         : TStiRec = (Key: 'Developed'        ; BgColor: clWhite     ; FgColor: clRed      );
    Developing        : TStiRec = (Key: 'Developing'       ; BgColor: clWhite     ; FgColor: clRed      );
    Done              : TStiRec = (Key: 'Done'             ; BgColor: clGreen     ; FgColor: clBlue     );
    Failed            : TStiRec = (Key: 'Failed'           ; BgColor: clRed       ; FgColor: clWhite    );
    Imported          : TStiRec = (Key: 'Imported'         ; BgColor: clAqua      ; FgColor: clRed      );
    Inactive          : TStiRec = (Key: 'Inactive'         ; BgColor: clSilver    ; FgColor: clBlack    );
    Locked            : TStiRec = (Key: 'Locked'           ; BgColor: clRed       ; FgColor: clWhite    );
    New               : TStiRec = (Key: 'New'              ; BgColor: clYellow    ; FgColor: clGreen    );
    Ongoing           : TStiRec = (Key: 'Ongoing'          ; BgColor: clBlue      ; FgColor: clWhite    );
    Onhold            : TStiRec = (Key: 'OnHold'           ; BgColor: clGray      ; FgColor: clBlack    );
    Overdue           : TStiRec = (Key: 'OverDue'          ; BgColor: clRed       ; FgColor: clWhite    );
    Planned           : TStiRec = (Key: 'Planned'          ; BgColor: clWebOrange ; FgColor: clBlue     );
    Planning          : TStiRec = (Key: 'Planning'         ; BgColor: clWebOrange ; FgColor: clBlue     );
    Rejected          : TStiRec = (Key: 'Rejected'         ; BgColor: clRed       ; FgColor: clAqua     );
    Run               : TStiRec = (Key: 'Run'              ; BgColor: clGreen     ; FgColor: clWhite    );
    Running           : TStiRec = (Key: 'Running'          ; BgColor: clGreen     ; FgColor: clWhite    );
    Sent              : TStiRec = (Key: 'Sent'             ; BgColor: clGreen     ; FgColor: clWhite    );
    Success           : TStiRec = (Key: 'Success'          ; BgColor: clGreen     ; FgColor: clWhite    );
    Testing           : TStiRec = (Key: 'Testing'          ; BgColor: clBlue      ; FgColor: clWhite    );
    Underconstruction : TStiRec = (Key: 'Underconstruction'; BgColor: clWebPink   ; FgColor: clGray     );
    Unfeasible        : TStiRec = (Key: 'Unfeasible'       ; BgColor: clBlack     ; FgColor: clWhite    );
    Unknown           : TStiRec = (Key: 'Unknown'          ; BgColor: clGray      ; FgColor: clRed      );
    Updated           : TStiRec = (Key: 'Updated'          ; BgColor: clGreen     ; FgColor: clWhite    );
    Validated         : TStiRec = (Key: 'Validated'        ; BgColor: clWebOrange ; FgColor: clWhite    );
    Validating        : TStiRec = (Key: 'Validating'       ; BgColor: clWebOrange ; FgColor: clWhite    );
    Waiting           : TStiRec = (Key: 'Waiting'          ; BgColor: clWebOrange ; FgColor: clWhite    );
    Working           : TStiRec = (Key: 'Working'          ; BgColor: clWhite     ; FgColor: clWebOrange);
  public
    function  IsActive(IvState: string)  : boolean;
    function  IsInactive(IvState: string): boolean;
    function  CsvStr(IvWhat: string)     : string; // Item, BgColor, FgColor
    function  Vector()                   : TStiRecVec;
  end;

  TStmRec = record // stream
  public
    function  ToByteArray(IvStream: TMemoryStream): TByteDynArray;
    procedure FromByteArray(const IvByteArray: TByteDynArray; IvStream: TStream);
  end;

  TStrRec = record

    {$REGION 'Help'}
    (*
    string in delphi is 0-based for mobile platforms and 1-based for windows
    string in old versions of delphi is ansistring (1-byte per char) and widestring in new versions (2-bytes per char)
    delphi supports set of ansichar, but doesn't support set of widechar
    *)
    {$ENDREGION}

  public
    function  W(IvE: Exception): string;                                              // standardwarning
    function  E(IvE: Exception): string;                                              // standardexception (e.Message)
    function  E2(IvE: Exception): string;                                             // standardexception (e.ClassName and e.Message)
    function  Between(IvTagLeft, IvTagRight, IvString: string): string;               // or Inside s1 = '[', s2 = ']', s3 = 'abc[xxx]def' -> 'xxx'
    function  Bite(IvString, IvDelimiter: string; var IvPos: integer): string;        // return front token based on token delim, each call returns front token and adjusts IvPos to the start of the next token or 0 if this is the last token
    function  Coalesce(IvStringVector: TStringVector): string;                        // return 1st not empty string
    function  Collapse(const IvString: string): string;                               // 'This Is A Test' --> 'ThisIsATest'
    function  CommentRemove(IvString: string): string;                                // remove all types of comments
    function  EmptyLinesRemove(IvString: string): string;                             // remove all emtpy lines
    function  Expande(const IvString: string; IvDelimiterChar: string = ' '): string; // 'ThisIsATest' --> 'This Is A Test' but 'This_IsA_Test' --> 'ThisIs ATest'
    function  Has(IvString, IvSubString: string; IvCaseSensitive: boolean = false): boolean; // contains
    function  HeadAdd(IvString, IvHead: string): string;
    function  HeadRemove(IvString, IvHead: string): string;
    function  Is09(const IvString: string): boolean;
    function  IsInteger(const IvString: string): boolean;
    function  IsFloat(const IvString: string): boolean;
    function  IsNumeric(const IvString: string): boolean;
    function  LeftOf(IvTag, IvString: string; IvTagInclude: boolean = false): string;
    function  OneLine(IvString: string): string;   // replace cr+nl with nothing
    function  OneSpace(IvString: string): string;
    function  Pad(IvString, IvFillChar: string; IvStringLen: integer; IvStrLeftJustify: boolean): string; // pads a string and justifies left if IvStrLeftJustify = true
    function  PartN(IvString: string; IvNZeroBased: integer; IvDelimiter: string = '_'): string; // parser, pick up a id-th substring, 1 based
    function  PosAfter(IvSubString, IvString: string; IvStart: integer = 1): integer;
    function  Replace(IvString, IvOut, IvIn: string): string;
    function  RightOf(IvTag, IvString: string; IvTagInclude: boolean = false; IvLast: boolean = false): string; // normally use the 1st tag in the string
    function  Split(IvString: string; IvDelimiters: string = ','): TStringDynArray;
    function  TailAdd(IvString, IvTail: string): string;
    function  TailRemove(IvString, IvTail: string): string;
    function  ZeroLeadingAdd(IvString: string; IvLen: integer): string;
  end;

  TSysRec = record // ex wks, so Wks may become a normal organization
  const                                                                         // *** move to DbaSsytem.dbo.TblParam all these constants ***
    ACRONYM                 = 'WKS';                                            // username
    NAME                    = 'Working Knowledge System';                       // name
    ADMIN_CSV               = 'giarussi,pfernandez';                            // csv
    ADMIN_EMAIL_CSV         = 'giarussi@wks.cloud,pfernandez@wks.cloud';        // csv
    ARCHITECT               = 'giarussi';                                       // igi
    AUTHOR                  = 'Puppadrillo';                                    // igi
    EMAIL                   = 'wks@wks.cloud';                                  // email
    PHONE                   = '348/5904744';                                    // phone
    QUIT_URL                = 'www.google.com';                                 // quit
    COLOR                   = $BD814F;                                          // color
    DISK                    = 'C:';                                             // C:
    HOME_DIR                = 'C:\$'   ;                                        // C:\$, where all will live
    BAK_DIR                 = 'C:\$Bak';                                        // C:\$Bak
    BIN_DIR                 = 'C:\$\X' ;                                        // win32/win64 bin dir
    DOC_DIR                 = 'C:\$Doc';                                        // C:\$Doc
    FIL_DIR                 = 'C:\$Fil';                                        // C:\$Fil
    IMG_DIR                 = 'C:\$Img';                                        // C:\$Img
    INC_DIR                 = 'C:\$Inc';                                        // C:\$Inc
    MEM_DIR                 = 'C:\$Mem';                                        // C:\$Mem
    ORG_DIR                 = 'C:\$Org';                                        // C:\$Org
    PER_DIR                 = 'C:\$Per';                                        // C:\$Per
    TMP_DIR                 = 'C:\$Tmp';                                        // C:\$Tmp, i.e. for R temporary created files/images
    USR_DIR                 = 'C:\$Usr';                                        // C:\$Usr
    HCONTENT_SWITCH_DEFAULT = '+Cc+Cm+CA4';                                     // default also for any organization
    HPAGE_SWITCH_DEFAULT    = '+N-Nf+Nb+Nls+Nlc+Nsm+Nm+Nu+M-H+T+Th+Tw+C+F+L+B'; // default also for any organization
    LOGIN_ATTEMPT_PAUSE_MS  = 3000;                                             // pause after an unsuccessful login attempt
    LOGIN_PAUSE_MS          = 2000;                                             // pause after a succesful login
    POP3_HOST               = 'pop3s.aruba.it';                                 // email receive protocol
    POP3_PORT               = '110';                                            //
    POP3_USERNAME           = 'wks@wks.cloud';                                  //
    POP3_PASSWORD           = 'Cotto1892Rell@';                                 //
    SMTP_HOST               = 'smtp.wks.cloud';                                 // email send protocol
    SMTP_PASSWORD           = 'Cotto1892Rell@';                                 //
    SMTP_PORT               = '25';                                             //
    SMTP_USERNAME           = 'wks@wks.cloud';                                  //
    URL_EXIST_CHECK         = true;                                             // in soap/isapi check if the url exists before use
    WWW                     = 'www.wks.cloud';                                  //
  //SEND_EMAIL_IF_EXPIRED   = false;                                            // move to organization
  //SEND_EMAIL_IF_INACTIVE  = false;                                            // move to organization
  //NetworkEmail            : string ;
  //NetworkUsername         : string ; // networkuser
  //NetworkPassword         : string ;
  //OtpIsActive             : boolean;
  public
    LogoBmp                : TBitmap;                                           // bmpfromrc
    Smtp                   : TSmtRec;                                           // sys smtp (not organization!)
    Pop3                   : TPopRec;                                           // sys pop3 (not organization!)
    HLib                   : string ;                                           // W3, B3, B4
    // general
    function  Url          : string;
    function  UrlBuild(IvObj: string; IvId: string = ''; IvTail: string = ''): string;
    function  Info         : string;
    function  Slogan       : string;                                            // *** remove, it is for orga ***
    function  Support      : string;
    function  HomePath     : string;
    function  IncPath      : string;
    function  LogoUrl      : string;
    function  IconUrl      : string;
    // dba
    procedure DbaLog(IvHost, IvAgent, IvTag, IvValue: string; IvLifeMs: integer);
    // rio
    function  RioInfo      : string;
    function  RioCopyright : string;
    function  RioOutline   : string;
    function  RioPrivacy   : string;
    function  RioLicense   : string;
    function  RioSessionLog(IvOrganization, IvUsername, IvPassword, IvSession: string): string;
    function  RioRequestLog(IvOrganization, IvUsername, IvPassword, IvSession: string): string;
    procedure RioLog(IvHost, IvAgent, IvTag, IvValue: string; IvLifeMs: integer);
  //function  RioParam(IvParam: string; var IvValue: string; var IvFbk: string): boolean;
//  function  Init(var IvFbk: string): boolean;       // *** if client do an RioInit if isapi/soap/rest do an DbaInit ***
//  function  DskInit(var IvFbk: string): boolean;    // change in DskCreate
//  function  DbaInit(var IvFbk: string): boolean;
//  function  Dba2Init(var IvFbk: string): boolean;
//  function  IsValid(var IvFbk: string): boolean;
//  function  Path: string;             //   \$Wks
////function  AppPath: string;          //   \$App
//  function  BackupPath: string;       //   \$Bak
//  function  FilerPath: string;        //   \$Fil
//  function  ImagePath: string;        //   \$Img
//  function  IncludePath: string;      //   \$Inc
//  function  MemberPath: string;       //   \$Mem
////function  MoviePath: string;        //   \$Mov
//  function  OrganizationPath: string; //   \$Org
//  function  PersonPath: string;       //   \$Per
////function  PicturePath: string;      //   \$Pic
//  function  PhotoPath: string;        //   \$Pho
//  function  ResourcePath: string;     //   \$Res
//  function  TempPath: string;         //   \$Tmp
//  function  UserPath: string;         //   \$Usr
//  function  PersonUserMemberCreate(IvName, IvSurname, IvGender, IvLanguage, IvSsn, IvPhone, IvMobile, IvEmail, IvUsername, IvState, IvSupervisor, IvRole, IvLevel, IvOrganization, IvDepartment, IvArea, IvActivity, IvTeam: string; var IvFbk: string): boolean;
  end;

  TVecRec = record // vetor
    function  Nx(IvStringVec: array of string): boolean; // is not exists  = empty
    function  Ex(IvStringVec: array of string): boolean; // is existent    = not empty
    function  Has(const IvString: string; IvStringVector: TStringVector; IvCaseSensitive: boolean = false): boolean;
    function  ToList(IvStringVector: TStringVector; IvDelimiterChar: string = DELIMITER_CHAR): string;
    function  ToListNotEmpty(IvVector: TStringVector; IvDelimiterChar: string = DELIMITER_CHAR): string;
    function  ToTxt(IvStringVector: TStringVector): string; overload;
    function  ToTxt(IvDoubleVector: TDoubleVector): string; overload;
    function  FromStr(IvString: string; IvDelimChars: string = ','; IvTrim: boolean = true): TStringVector;
    function  FromCsv(IvString: string; IvTrim: boolean = true): TStringVector;
    function  ItemRnd(IvStringVector: array of string): string; // TStringVector non worka con vettori constanti
    function  Collapse(IvStringVector: TStringVector): string;  // ['Aaa', 'Bbb', ...] -> AaaBbb...
  end;

  TVntRec = record // variant - http://docs.embarcadero.com/products/rad_studio/delphiAndcpp2009/HelpUpdate2/EN/html/delphivclwin32/Variants_VarArrayCreate.html
  public
    function  TypeIsStr(const IvVarType: TVarType): boolean;

    function  IsNull(IvVariant: variant; IvDefault : variant): variant;
    function  NullIf(IvVariant: variant; IvIsThis: variant): variant;
    function  ToStr(IvVariant: variant; IvDefault: string = ''): string;
    function  ToInt(IvVariant: variant; IvDefault: integer = 0): integer;

    function  HasData(IvVariant: variant): boolean;
    function  IsEmpty(IvVariant: Variant): boolean;
    function  IsStr(const IvVariant: Variant): boolean;

    function  RecCopy(const IvVarRec: TVarRec): TVarRec; // copies a TVarRec and its contents, if the content is referenced the value will be copied to a new location and the reference updated
    procedure RecFinalize(var IvVarRec: TVarRec);// TVarRecs created by VarRecCopy must be finalized with this function, you should not use it on other TVarRecs, use it only on copied TVarRecs!

    function  RecVectorIsEmpty(IvVarRecVector: array of TVarRec{; var IvFbk: string}): boolean;
    function  RecVectorCreate(const IvElements: array of const): TVarRecVector; // creates a TVarRecVector out of the values given, uses VarRecCopy to make copies of the original elements
    procedure RecVectorFinalize(var IvVarRecVector: TVarRecVector); // TVarRecVector contains TVarRecs that must be finalized, this function does that for all items in the array
    procedure RecVectorClear(var IvVarRecVector: TVarRecVector);

    function  ToVarRec(IvVariant: variant): TVarRec;
    function  RecToVar(IvVarRec: TVarRec): variant;
    procedure ToVarRecVector(IvVariant: variant; var IvVarRecVector: TVarRecVector);
  end;

  TUagRec = record // useragent
    UserAgent       : string; // key
    Client          : string;
    ClientVersion   : string;
    Os              : string;
    OsVersion       : string;
    Engine          : string;
    Vendor          : string;
    Kind            : string;
    Kind2           : string;
    Hardware        : string;
    BitArchitecture : string;
    DateTime        : TDateTime;
    Hit             : integer;
  public
    function  DbaExists(var IvFbk: string): boolean;
    function  DbaSelect(var IvFbk: string): boolean;
    function  DbaInsert(var IvFbk: string): boolean;
  end;

  TUrlRec = record // url
    // http://login:password@somehost.somedomain.com:8080/somepath/somethingelse.dll/Action?param1=val&param2=val#nose
    // \__/   \___/ \______/ \_____________________/ \__/\_________________________/ \____/ \___________________/ \__/
    //  |       |        |             |              |              |                 |             |             |
    // Scheme   Username Password      Host           Port           Path           PathInfo       Query         Fragment
  const
    GOOGLEDOTCOM   = 'http://www.google.com';
  //MYIPDOTNET     = 'https://www.wks.cloud/WksYourIpIsapiProject.dll';
  //MYIPDOTNET     = 'http://requestbin.net/ip';                                // double reading to avoid DoS
  //MYIPDOTNET     = 'http://ipinfo.io/ip';                                     //
    MYIPDOTNET     = 'https://ifconfig.co/ip';                                  //
    UNSPLASHDOTCOM = 'https://source.unsplash.com';                             // images & bg
  public
    Scheme   : string; // http // protocol
    Username : string; // login
    Password : string; // password
    Host     : string; // somehost.somedomain.com
    Port     : string; // 8080
    Path     : string; // /some_path/something_else.html/dll
    PathInfo : string; // /some_path/something_else.html/dll
    QueryInfo: string; // ?param1=val&param2=val
    Fragment : string; // nose
    function  Parse(IvUrl: string; IvPart: string = ''): string;                // also load all above members
    function  PatInfo(IvUrl: string): string;
    function  HttpRemove(IvUrl: string): string;
    function  Ensure(IvLink: string): string;
    function  Encode(IvQueryClearValue: string): string;                        // only query fields part?
    function  Decode(IvQueryObscureValue: string): string;                      // only query fields part?
    function  IsValid(IvUrl: string): boolean;
    function  Exists(IvUrl: string; IvCheck: boolean = false): boolean;
    procedure Go(IvLink: string); // default
    procedure GoEdge(IvLink: string);
    procedure GoChrome(IvLink: string);
    procedure GoFirefox(IvLink: string);
  end;

  TUsrRec = record // user
  const
    USR_CANCELLED_ACTION          = 'User cancelled the action';                // 'Azione cancellata dall''Utente';
    USR_EXISTS_OK                 = 'User %s exists';                           // 'User %s exists';
    USR_EXISTS_NO                 = 'User %s does not exists';                  // 'User %s does not exists';
    USR_ACTIVE_NO                 = 'Utente %s e'' nello stato Inactive';       // 'User %s is in state Inactive';
    USR_ACTIVE_OK                 = 'Utente %s e'' nello stato Active';         // 'User %s is in state Active';
    USR_PLEASE_ENTER_USERNAME     = 'Please enter your username';               // 'Inserire username';
    USR_PLEASE_ENTER_PASSWORD_NEW = 'Please enter your new Password';           // 'Inserire nuova Password';
    USR_PLEASE_ENTER_PASSWORD_OLD = 'Please enter your old Password';           // 'Inserire vecchia Password';
    USR_PASSWORD_MATCH_NO         = 'User %s password doesn''t match';          // 'Utente %s ha password che non corrisponde';
    USR_PASSWORD_MATCH_OK         = 'User %s password match';                   // 'Utente %s ha password che corrisponde';
    USR_PASSWORD_CHANGED_NO       = 'Unable to change password';                // 'Impossibile cambiare la password';
    USR_PASSWORD_CHANGED_OK       = 'Password succesfully changed';             // 'Password cambiata con successo';
  public
    Organization : string; // Wks
    Username     : string; // giarussi
    Password     : string; // secret
    State        : string; // Active
    Session      : string; // loggedin generic ... remove !!!
  //WebSession   : string; // loggedin via browser
  //ClientSession: string; // loggedin via CodeClient !!! NOT FEASIBLE CAN BE MANY CLIENTS AT THE SAME TIME !!!
    Json         : string; // additional properties
    // local
    function  Info: string;
    function  UsernameIsValid(IvUsername: string; var IvFbk: string): boolean;
    function  UsernameWhere(IvOrganization, IvUsername, IvPassword: string; IvConsiderUsernameOnly: boolean): string;
    function  PathAlpha(IvUsername: string = ''): string;
    function  UrlAlpha(IvUsername: string = ''): string;
    function  AvatarPath(IvUsername: string = ''): string;
    function  AvatarUrl(IvUsername: string = ''): string;
    // dba
    function  DbaExists(var IvFbk: string): boolean;
    function  DbaIsActive(var IvFbk: string): boolean;
    function  DbaIsAuthenticated(var IvFbk: string; IvConsiderUsernameOnly: boolean; IvPasswordSkip: boolean = false): boolean; // change to accomodate new login process, so using the session, not the password
    function  DbaIsLoggedIn(var IvFbk: string): boolean;
    function  DbaSelect(const IvUsername: string; var IvFbk: string): boolean;
    // rio
    function  RioExists(IvOrganization, IvUsername: string; var IvFbk: string): boolean;
    function  RioIsActive(IvOrganization, IvUsername: string; var IvFbk: string): boolean;
    function  RioIsAuthenticated(IvOrganization, IvUsername, IvPassword: string; var IvFbk: string): boolean;
  end;

  TWreRec = record // webrequestextended
    // originalreq
    WebRequest          : TWebRequest;   // original web request
  //Ire                 : TISAPIRequest; // original isapi request
    // nowrequestdatetime
    DateTime            : TDateTime;     // 2019-01-31 12:12:14.377
    // client
  //ClientIp            : string;         {10.176.85.121                          }
    ClientAddr          : string;         {10.176.85.121                          }
    ClientHost          : string;         {www.wks.cloud      (THE-ONLY-SURE-INFO)}
  //ClientPort          : string;         {62682                                  }
    ClientAccept        : string;         {text/html,application/xml              }
    ClientAcceptEncoding: string;         {gzip, deflate                          }
    ClientAcceptLanguage: string;         {en-US,en                               }
    ClientApp           : string;         {Mozilla/5.0 Windows NT...              }
    ClientAppVersion    : string;         {5.0 / 1.0.0.1                          }
    // clientfingerprint
    ClientDoNotTrack    : string;         {1                                      }
    ClientTimezoneOffset: string;         {?                                      }
    ClientLanguage      : string;         {?                                      }
    ClientPlatform      : string;         {?                                      }
    ClientOs            : string;         {?                                      }
    ClientCpuCores      : string;         {?                                      }
    ClientScreen        : string;         {?                                      }
    ClientAudio         : string;         {?                                      }
    ClientVideo         : string;         {?                                      }
    ClientLocalStorage  : string;         {?                                      }
    ClientSessionStorage: string;         {?                                      }
    ClientIndexedDb     : string;         {?                                      }
    ClientFingerprint   : string;         {?                                      }
    // user
    UserOrganization    : string;         {Wks (fromurl/dba)                      }
    UserDomain          : string;         {?                                      }
    UserComputer        : string;         {phobos                                 }
    Username            : string;         {giarussi | 353992                      }
  //UserPassword
  //UserLogon           : string;         {?                                      }
  //UserRemote          : string;         {?                                      }
  //UserRemoteUnmapped  : string;         {?                                      }
    // session
    Session             : string;         {?                                      }
    Otp                 : string;         {?                                      }
    // http
    HttpOrigin          : string;         {?                                      }
    HttpProtocol        : string;         {HTTP/1.1                               }
    HttpMethod          : string;         {GET, POST                              }
    // request
    RequestId           : cardinal;       {095EBA6CEcb.ConnId                     }
    Connection          : string;         {keep-alive                             }
    Host                : string;         {aiwymsapp.ai.lfoundry.com              }
    Url                 : string;         {/WksIsapiProject.dll *partial or empty*}
    PathInfo            : string;         {/Info                                  }
  //InternalPathInfo    : string;         {/Info                                  }
  //RawPathInfo         : string;         {/Info                                  }
  //PathTranslated      : string;         {X:\$\X\Win32\Debug\Info                }
    Query               : string;         {?CoId=381&CoXxx=2                      }
  //Referer             : string;         {http://abc.com/WksIsapi.dll/Run?CoId=12}
  //Title               : string;         {*empty*                                }
  //Cookie              : string;         {CoOtp=933073; CoDomain=LOCALHOST;      }
  //TotalBytes          : integer;        {0                                      }
  //Expires             : TDateTime;      {?                                      }
  //MimeType            : string;         {?                                      }
    // content
  //ContentEncoding     : string;         {*empty*                                }
  //ContentType         : string;         {*empty* | application/x-www-form...    }
  //ContentLength       : string;         {0                                      }
  //ContentVersion      : string;         {*empty*                                }
  //ContentRaw          : string/TBytes;  {*arrrayofbytes*                        }
  //Content             : string;         {*keys-values in form*                  }
    // server
    ServerAddr          : string;         {10.176.39.2                            }
    ServerHost          : string;         {localhost | www.abc.com                }
  //ServerName          : string;         {localhost                              }
    ServerPort          : integer;        {80                                     }
    ServerPortSecure    : integer;        {80                                     }
  //ServerProtocol      : string;         {HTTP/1.1                               }
    ServerSoftware      : string;         {Microsoft-IIS/10.0                     }
    // serveriiswebsite
  //WebsiteInstance     : string;         {1                                      }
  //WebsitePath         : string;         {/LM/W3SVC/1                            }
  //WebsitePath         : string;         {/LM/W3SVC/1/ROOT                       }
    // serverscript
  //ScriptGateway       : string;         {CGI/1.1                                }
  //ScriptPath          : string;         {X:\$\X\Win32\Debug                     }
    ScriptName          : string;         {/WksIsapiProject.dll                   }
    ScriptVer           : string;         {1.0.0.123                              }
    // zzz
  //Authorization       : string;         {*empty*                                }
  //CacheControl        : string;         {*empty* or no-cache                    }
  //Date                : TDateTime;      {1899-12-29                             }
  //From                : string;         {*empty* / might conteins User          }
  //IfModifiedSince     : TDateTime;      {1899-12-29                             }
  //DerivedFrom         : string;         {*empty*                                }
    // end
    TimingMs            : integer;        { -1                                    }
  public
    procedure Init (const IvWebRequest: TWebRequest);
    function  DbaInsert(var IvFbk: string): boolean;
    function  TkvVec: TTkvVec;
    function  StrGet(IvField: string; IvDefault: string; IvCookieAlso: boolean = false): string;
    function  IntGet(IvField: string; IvDefault: integer; IvCookieAlso: boolean = false): integer;
    function  BoolGet(IvField: string; IvDefault: boolean; IvCookieAlso: boolean = false): boolean;
    function  CookieGet(IvCookie: string; IvDefault: string = ''): string; overload;
    function  CookieGet(IvWebRequest: TWebRequest; IvCookie: string; IvDefault: integer): integer; overload;
    function  CookieGet(IvWebRequest: TWebRequest; IvCookie: string; IvDefault: string): string; overload; // get a cookie from client browser
    function  FieldExists(IvWebRequest: TWebRequest; IvField: string; var IvFbk: string): boolean;
    function  Field(IvWebRequest: TWebRequest; IvField: string; var IvValue: boolean; IvDefault: boolean; var IvFbk: string; IvFalseIfValueIsEmpty: boolean = true): boolean; overload;
    function  Field(IvWebRequest: TWebRequest; IvField: string; var IvValue: integer; IvDefault: integer; var IvFbk: string; IvFalseIfValueIsEmpty: boolean = true): boolean; overload;
    function  Field(IvWebRequest: TWebRequest; IvField: string; var IvValue: string ; IvDefault: string ; var IvFbk: string; IvFalseIfValueIsEmpty: boolean = true): boolean; overload;
    function  DbaSelectInput(IvWebRequest: TWebRequest; var IvTable, IvField, IvWhere, IvFbk: string): boolean;
    function  DbaUpdateInput(IvWebRequest: TWebRequest; var IvTable, IvField, IvWhere, IvValue, IvFbk: string): boolean;
    function  PathInfoActionIsValid(IvPathInfoAction: string): boolean; // verify if input is one of the defined action pathinfo /Xxx
    function  PathInfoQuery: string;    // /Page?CoId=3
    function  PathInfoQueryUrl: string; // /WksIsapiProject.dll/Page?CoId=3
    function  UrlFull: string;          // http://www.abc.com/WksIsapiProject.dll/Page?CoId=3
  end;

  TWrsRec = record // webresponse (pov=server)
  public
    procedure CookieAdd(IvResponse: TWebResponse; IvCookie: string; IvValue: variant; IvExpireInXDay: double = WEB_COOKIE_EXPIRE_IN_DAY); // set a cookie in client browser
    procedure CookieDelete(IvResponse: TWebResponse; IvCookie: string);
    function  CustomHeaderAdd(IvWebRequest: TWebRequest; IvWebResponse: TWebResponse; var IvFbk: string): boolean;
  end;
{$ENDREGION}

{$REGION 'Var'}
var
  h0 : cardinal;   // handlespare
  ask: TAskRec;    // ask, win-api-only-dialogs
  byn: TBynRec;    // binary
  cns: TCnsRec;    // connectionstring
  con: TConRec;    // connection
  cry: TCryRec;    // cripto
  dat: TDatRec;    // datetime
//db0: TDbaCls;    // sysdb, wksdb                  (mssql)   *** NOT GLOBAL ***
//db1: TDbaCls;    // wksmdb01a,wksmdb01b,wksmdb01c (mongodb) *** NOT GLOBAL ***
  dot: TDotRec;    // dotobject (like Person.Person.Name <-> DbaPerson.dbo.TblPerson+FldName)
  fbk: TFbkRec;    // feedback
  fsy: TFsyRec;    // filesystem
  iif: TIifRec;    // inlineif
  htt: THttRec;    // http
  iis: TIisRec;    // inlineis
  img: TImgRec;    // image
//ini: TIniCls;    // ini *** NOT GLOBAL ***
//log: TLogCls;    // log *** NOT GLOBAL ***
  lgt: TLgtCls;    // log threaded *** GLOBAL ***
  lst: TLstRec;    // list/csv (csv or generic list like aaa/bbb/ccc or aaa|bbb|ccc)
  mat: TMatRec;    // math
  mes: TMesRec;    // message, dialog, taskdialog *** MOVE "dialog, taskdialog" IN "ask" ***
  mim: TMimRec;    // mimetype
  net: TNetRec;    // network
  obj: TObjRec;    // object content, param, switch, ... (System, User, Member, Organization, ...)
  org: TOrgRec;    // organization
  pat: TPatRec;    // pathfile (or more general treepath)
  pop: TPopRec;    // pop3
  pxy: TPxyRec;    // proxy
  rex: TRexRec;    // regex
  rio: TRioRec;    // httprio
  rnd: TRndRec;    // random
  ses: TSesRec;    // session
  smt: TSmtRec;    // smtp
  sop: TSopRec;    // soap
  sql: TSqlRec;    // sql
  srv: TSrvRec;    // server (isapi,soap,rest)
  sta: TStaRec;    // state
  stm: TStmRec;    // stream
  str: TStrRec;    // string
  sys: TSysRec;    // system
  uag: TUagRec;    // useragent
  url: TUrlRec;    // url
  usr: TUsrRec;    // user
  vec: TVecRec;    // vector
  vnt: TVntRec;    // variant
  wa0: TStopwatch; // stopwatch (only global lifetime, do not use!)
  wre: TWreRec;    // webrequestextended
  wrs: TWrsRec;    // webresponse
{$ENDREGION}

implementation

{$REGION 'Use'}
uses
    Winapi.ShellAPI                 // shellexecute
  , Winapi.WinInet                  // hinternet urlcrack canonizeurl
  , Winapi.Winsock                  // ulong twsadata
  , Winapi.ActiveX                  // cominitialize ienumvariant
  , Winapi.Isapi2                   // textension_control_block
  , System.Win.Registry             // registry
  , System.Variants                 // variant
  , System.IOUtils                  // tpath
  , System.Character                // islower
  , System.Math                     // math
  , System.Hash                     // thashsha2
  , System.StrUtils                 // ansicontainstext
  , System.NetEncoding              // tnetencoding
  , System.Win.ComObj               // createoleobject, eoleexception, olevariant
  , System.DateUtils                // datetime
  , Web.Win.IsapiHTTP               // isapihttp tisapirequest
  , Vcl.Dialogs                     // dialogs TFileOpenDialog is specific to platform, use more recent TOpenDialog instead
  , Vcl.Forms                       // application, form
  , Vcl.ExtActns                    // tbrowseurl
  , Vcl.StdCtrls                    // tlabel
//, Vcl.StdActns                    // tbrowseforfolder
  , IdURI                           // tiduri
  , HTTPSend                        // araratsynapse
//, WksSystemSoapMainServiceIntf
  ;
{$ENDREGION}

{$REGION 'TAskRec'}
function TAskRec.Int(IvCaption, IvPrompt: string; IvDefault: integer; var IvInt: integer): boolean;
var
  s, d: string;
begin
  s := IvInt.ToString;
  d := IvDefault.ToString;
  Result := Str(IvCaption, IvPrompt, d, s);
  IvInt := StrToIntDef(s, IvDefault);
end;

function TAskRec.No(IvMessage: string): boolean;
begin
  Result := MessageDlg(IvMessage, mtConfirmation, [mbYes, mbNo], 0) = 7{=mrNo};
end;

function TAskRec.NoFmt(IvMessageFormatString: string; IvVarRecVector: array of TVarRec): boolean;
begin
  Result := No(Format(IvMessageFormatString, IvVarRecVector));
end;

function TAskRec.Str(IvCaption, IvPrompt, IvDefault: string; var IvStr: string): boolean;
begin
  // i
//IvStr  := Inputbox(IvCaption, IvPrompt, IvDefault);
//Result := true;

  // ii
  IvStr := IvDefault;
  Result := Vcl.Dialogs.InputQuery(IvCaption, IvPrompt, IvStr);
end;

function TAskRec.Yes(IvMessage: string): boolean;
begin
  Result := MessageDlg(IvMessage, mtConfirmation, [mbYes, mbNo], 0) = 6{=mrYes}; // mt=messagetype, mb=messagebutton, mr=modalresult in Vcl.Controls unit
end;

function TAskRec.YesFmt(IvMessageFormatString: string; IvVarRecVector: array of TVarRec): boolean;
begin
  Result := Yes(Format(IvMessageFormatString, IvVarRecVector));
end;
{$ENDREGION}

{$REGION 'TBynRec'}
function TBynRec.AuthToken: string;
begin
  Result := str.Expande(byn.Nick, '.');
end;

function TBynRec.Cmds: string;
var
  i: integer;
  n, d, c: string; // name, descr, content
begin
  c := '';
  for i := Low(CommandRecVec) to High(CommandRecVec) do begin
    n := CommandRecVec[i].Name;
    d := CommandRecVec[i].Description;
    c := c + sLineBreak + Format('<br><a href="[RvReqUrl()]%s">%s</a><br>%s<br>', [n, n, d]);
  end;
  Delete(c, 1, 6);
  Result := c;
end;

function TBynRec.CmdsHas(IvCmd: string; var IvFbk: string): boolean;
var
  i: integer;
begin
  Result := false;
  for i := Low(CommandRecVec) to High(CommandRecVec) do begin
    Result := CommandRecVec[i].Name.StartsWith(IvCmd, true);
    if Result then begin
      IvFbk := Format('%s is present', [IvCmd]);
      Exit;
    end;
  end;
  IvFbk := Format('%s is not present', [IvCmd]);
end;

procedure TBynRec.Dispose;
var
  i: integer;
begin
  for i:= Low(CommandRecVec) to High(CommandRecVec) do begin
    CommandRecVec[i].Name        := '';
    CommandRecVec[i].Description := '';
  end;
  SetLength(CommandRecVec, 0);
end;

function TBynRec.FileExt: string;
begin
  Result := ExtractFileExt(Spec);
end;

function TBynRec.FileName: string;
begin
  Result := TPath.GetFileNameWithoutExtension(Spec);
end;

function TBynRec.FileNameDotExt: string;
begin
  Result := ExtractFileName(Spec);
end;

function TBynRec.FileSpec: string;
begin
  Result := Spec;
end;

function TBynRec.Info: string;
begin
  Result := Format('%s %s', [Name, Ver]);

//  Result := NameNice;
////if Role <> '' then
////  Result := Result + ifthen(Result <> '', ' ', '') + Role;
//  if Version <> '' then
//    Result := Result + ifthen(Result <> '', ' ', '') + Version;
end;

function TBynRec.IsClient: boolean;
begin
  Result := SameText(Role, 'Client');
end;

function TBynRec.IsDemon: boolean;
begin
  Result := str.Has('Service,Demon', Role);
end;

function TBynRec.IsServer: boolean;
begin
  Result := str.Has('Isapi,Soap,Rest,Dsnap,RestDs,Server', Role);
end;

function TBynRec.Name: string;
var
  f, n: string;
begin
  // i
//Result := UpperCase(Nick) + ' ' + Role;

  // ii
  f := FileSpec;
  n := ExtractFileName(f);
  if str.Has(n, 'Project.') then begin
    Result := Copy(n, 1, Pos('Project.', n) - 1);
  end else
    Result := n; // simpleapp
end;

function TBynRec.NameNice: string;
var
  s, a, b, c: string;
begin
  s := Str.Expande(Name);
  a := Str.PartN(s, 0, ' ');
  b := Str.PartN(s, 1, ' ');
  c := Str.PartN(s, 2, ' ');
  Result := Format('%s %s %s', [a, b.ToUpper, c]);
end;

function TBynRec.NameNiceVer: string;
begin
  Result := NameNice + ' ' + Ver;
end;

function TBynRec.Nick: string;
begin
  Result := str.LeftOf('Project.', FileNameDotExt); // str.Remove(app.Tag, app.Role); if app.Nick <> sys.Acronym then app.Nick := str.Remove(app.Nick, sys.Acronym);
end;

function TBynRec.Obj: string;
var
  i: integer;
  s: string;
begin
  s := FileName;
  Result := s[4];
  i := 5;
  while char(s[i]).IsLower do begin
    Result := Result + s[i];
    Inc(i);
  end;
end;

function TBynRec.Path: string;
begin
  Result := ExtractFilePath(Spec);
end;

function TBynRec.RioVerIsOk(var IvFbk: string): boolean;
begin
  try
//    Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapClientVersionIsOk(Tag, Ver, IvFbk);
  except
    IvFbk := 'Unable to verify current version';
    Result := false;
  end;
end;

function TBynRec.Role: string;
var
  n: string;
begin
  n := FileName;
       if n.Contains('ClientProject' ) then Result := 'Client'      // Client, Manager, Studio
  else if n.Contains('IsapiProject'  ) then Result := 'Isapi'       // IsapiServer (isapiapp)
  else if n.Contains('SoapProject'   ) then Result := 'Soap'        // SoapServer (webapplicationserver)
  else if n.Contains('DsnapProject'  ) then Result := 'Dsnap'       // DsnapServer
  else if n.Contains('RestProject'   ) then Result := 'Rest'        // RestServer (datasnap)
  else if n.Contains('RestDsProject' ) then Result := 'Rest'        // RestServer (datasnap)
  else if n.Contains('ServerProject' ) then Result := 'Server'      // Server (tcpip generic server)
  else if n.Contains('DemonProject'  ) then Result := 'Demon'       // Demon (windowsservice)
  else if n.Contains('ServiceProject') then Result := 'Demon'       // Demon
//else if n.Contains('AppProject'    ) then Result := 'Application' // standalone
  else if n.Contains('UtilProject'   ) then Result := 'Utility'     // utility standalone app
  else if n.Contains('DemoProject'   ) then Result := 'Demo'        // standalone, to test ctrls or comps
  else if n.Contains('TestProject'   ) then Result := 'Test'        // standalone, to dtest unit
  else begin                                Result := 'Unknown';
    raise Exception.CreateFmt('Unable to determine application [%s] Role, binary file name must be like WksXxxRoleProject.exe/dll where Role = Client, Isapi, Soap, Dsnap, Rest, RestDs, Server, Demon, Service, Util, Demo, Test', [n]);
  end;
end;

function TBynRec.Spec: string;
const
  A = '\\?\';
//var
  //c: array[0..MAX_PATH] of char;
begin
  // i  - no! only gui exe apps
//Result := Application.ExeName;

  // ii - no!, only gui and console exe apps
//Result := ParamStr(0);

  // iii - ok, gui, console exe or dll apps
//FillChar(c, SizeOf(c), #0);
//GetModuleFileName(hInstance, c, MAX_PATH + 1);
//SetLength(Result, Length(PChar(c)));
//Result := c;

  // iiii - wrong, for an isapi dll returns somthing like: "WksAppPool.config" -w "" -m 0 -t 20"
  //Result := CmdLine; //

  // iiiii - ok, gui, console exe or dll apps
  SetLength(Result, MAX_PATH + 1); // prepare buffer, add 1 for the terminating null #0 char
  SetLength(Result, GetModuleFileName(hInstance, PChar(Result), MAX_PATH + 1));

  // fix
  if Pos(A, Result) = 1 then
    Delete(Result, 1, 4);
end;

function TBynRec.SpecInfo: string;
var
  m: TDateTime;
begin
  m := fsy.FileModified(Spec);
  Result := Format('%s, %s, Modified: %s, Now: %s', [Spec, Ver, DateTimeToStr(m), DateTimeToStr(Now)]);
end;

function TBynRec.Tag: string;
begin
  Result := byn.Nick;
end;

function TBynRec.Ver(IvFile: string): string;
begin
//  if str.Nx(IvFile) then
//    Result := fsy.FileVer(Spec)
//  else
//    Result := fsy.FileVer(IvFile);
end;

procedure TBynRec.Version(var IvV1, IvV2, IvV3, IvV4: word);
var
  i: pointer; // verinfo
  z, w, d: DWORD; // verinfosize, vervaluesize, dummy
  v: PVSFixedFileInfo; // vervalue
begin
  z := GetFileVersionInfoSize(PChar(Spec), d);
  if z > 0 then begin
      GetMem(i, z);
      try
        if GetFileVersionInfo(PChar(Spec), 0, z, i) then begin
          VerQueryValue(i, '\', Pointer(v), w);
          with v^ do begin
            IvV1 := dwFileVersionMS shr 16;
            IvV2 := dwFileVersionMS and $FFFF;
            IvV3 := dwFileVersionLS shr 16;
            IvV4 := dwFileVersionLS and $FFFF;
          end;
        end;
      finally
        FreeMem(i, z);
      end;
  end;
end;
{$ENDREGION}

{$REGION 'TCnsRec'}
function TCnsRec.CsADO(IvCsADO: string): string;
var
  s, d, h: string; // store, defaultdb, host
begin
  // proto
  // Provider=SQLOLEDB.1;Data Source=PHOBOS;Initial Catalog=DbaCode;User ID=sa;Password=secret;Persist Security Info=True

  // explicit
  if iis.Ex(IvCsADO) then begin
  //IvFbk := 'ADO connection-string created with explicit connection-string';
    Result := IvCsADO;

  // guessfromhostname
  end else begin
    if      SameText(net.Host, 'KRONOS')     then Result := CS0_ADO
    else if SameText(net.Host, 'PHOBOS')     then Result := CS0_ADO
    else if SameText(net.Host, 'ZBOOK')      then Result := CS0_ADO
    else if SameText(net.Host, 'WKS')        then Result := CS1_ADO
    else if SameText(net.Host, 'GIARUSSI')   then Result := CS2_ADO
    else if SameText(net.Host, 'AIWYMSAPP')  then Result := CS2_ADO
    else if SameText(net.Host, 'AIWYMSDEV')  then Result := CS2_ADO
    else if SameText(net.Host, 'AIWYMSTEST') then Result := CS2_ADO
    else if SameText(net.Host, 'AIWYMSDEM')  then Result := CS2_ADO
    else                                          Result := CS0_ADO;
  //IvFbk := 'ADO connection-string created guessing from the  hostname ' + net.Host.ToUpper;
  end;
end;

function TCnsRec.CsADOTest(IvCs: string; var IvFbk: string): boolean;
var
  c: TADOConnection;
begin
  c := TADOConnection.Create(nil);
  try
    try
      c.LoginPrompt := false;
      c.ConnectionString := IvCs;
      c.Open;
      c.Close;
      IvFbk := 'ADO Connection is OK';
      Result := true;
    except
      on e: Exception do begin
        IvFbk := e.Message;
        Result := false;
      end;
    end;
  finally
    FreeAndNil(c);
  end;
end;

function TCnsRec.CsFD(IvCsFD: string): string;
begin
  // proto
  // DriverID=Mssql;Server=PHOBOS;Database=DbaCode;User_Name=sa;Password=secret

  // explicit
  if iis.Ex(IvCsFD) then begin
  //IvFbk := 'FD connection-string created with explicit connection-string';
    Result := IvCsFD;

  // guessfromhostname
  end else begin
    if      SameText(net.Host, 'KRONOS')     then Result := CS0_FD
    else if SameText(net.Host, 'PHOBOS')     then Result := CS0_FD
    else if SameText(net.Host, 'ZBOOK')      then Result := CS0_FD
    else if SameText(net.Host, 'WKS')        then Result := CS1_FD
    else if SameText(net.Host, 'GIARUSSI')   then Result := CS2_FD
    else if SameText(net.Host, 'AIWYMSAPP')  then Result := CS2_FD
    else if SameText(net.Host, 'AIWYMSDEV')  then Result := CS2_FD
    else if SameText(net.Host, 'AIWYMSTEST') then Result := CS2_FD
    else if SameText(net.Host, 'AIWYMSDEM')  then Result := CS2_FD
    else                                          Result := CS0_FD;
  //IvFbk := 'FD connection-string created considering the hostname ' + net.Host.ToUpper;
  end;
end;

function TCnsRec.CsFDTest(IvCs: string; var IvFbk: string): boolean;
var
  c: TFDConnection;
begin
  c := TFDConnection.Create(nil);
  try
    try
      c.LoginPrompt := false;
      c.ConnectionString := IvCs;
      Result := c.Ping;
      IvFbk := 'FD Connection is OK';
    except
      on e: Exception do begin
        IvFbk := e.Message;
        Result := false;
      end;
    end;
  finally
    FreeAndNil(c);
  end;
end;
{
function TCnsRec.Cs(IvCs, IvStore, IvDatabase, IvDriver: string; out IvCsOut: string; var IvFbk: string): boolean;
begin
  if      SameText(IvDriver, 'ADO') then begin
    IvCsOut := CsADO(IvCs, IvStore, IvDatabase, IvFbk);
    Result := true;

  end else if SameText(IvDriver, 'FD') then begin
    IvCsOut := CsFD(IvCs, IvStore, IvDatabase, IvFbk);
    Result := true;

  end else begin
    IvCsOut := '';
    IvFbk := 'Unable to create connection string, driver is unknowk';
    Result := false;
  end;
end;
}
function TCnsRec.CsMongoFD(IvServer, IvPort, IvDatabase, IvUsername, IvPassword, IvCollection: string): string;
begin
//Result := 'DriverID=Mongo;Database=' + MongoURI(IvServer, IvPort, IvDatabase, IvUsername, IvPassword, IvCollection);
  Result := Format('DriverID=Mongo;Server=%s;Port=%s;Database=%s;Collection=%s', [IvServer, IvPort, IvDatabase, IvCollection]);
end;

function TCnsRec.CsMsAccessADO(IvFile, IvUsername, IvPassword: string): string;
var
  e: string;
begin
  // ext
  e := ExtractFileExt(IvFile);
  if e = '.mdb' then
    Result :=
       'Provider=Microsoft.Jet.OLEDB.4.0'
    + ';Persist Security Info=True'
    + ';Data Source='                 + IvFile
    + ';User ID='                     + iif.NxD(IvUsername, 'Admin')
    + ';Jet OLEDB:Database Password=' + iif.NxD(IvPassword, '""')
  else if e = '.accdb' then
    Result :=
       'Provider=Microsoft.ACE.OLEDB.12.0'
    + ';Persist Security Info=False'
    + ';Data Source='                 + IvFile
    + ';User ID='                     + iif.NxD(IvUsername, 'Admin')
    + ';Jet OLEDB:Database Password=' + iif.NxD(IvPassword, '""')
  //+ ';Mode=Share Deny None'
  //+ ';Jet OLEDB:System database=""'
  //+ ';Jet OLEDB:Registry Path=""'
  //+ ';Jet OLEDB:Database Password=""'
  //+ ';Jet OLEDB:Engine Type=6'
  //+ ';Jet OLEDB:Database Locking Mode=1'
  //+ ';Jet OLEDB:Global Partial Bulk Ops=2'
  //+ ';Jet OLEDB:Global Bulk Transactions=1'
  //+ ';Jet OLEDB:New Database Password=""'
  //+ ';Jet OLEDB:Create System Database=False'
  //+ ';Jet OLEDB:Encrypt Database=False'
  //+ ';Jet OLEDB:Don't Copy Locale on Compact=False'
  //+ ';Jet OLEDB:Compact Without Replica Repair=False'
  //+ ';Jet OLEDB:SFP=False'
  //+ ';Jet OLEDB:Support Complex Data=False'
  else
    raise Exception.Create('Unknow Access file extension')
  ;
end;

function TCnsRec.CsMsExcelADO(IvFile: string): string;
var
  e: string;
begin
  // ext
  e := ExtractFileExt(IvFile);
  if e = '.xls' then
    Result := Format(
      'Provider=Microsoft.Jet.OLEDB.4.0'
    + ';Data Source=%s'
  //+ ';Extended Properties=Excel 5.0' // Excel95
    + ';Extended Properties=Excel 8.0' // Excel 97, Excel 2000, Excel 2002 or ExcelXP
  //+ ';HDR=Yes'                       // HDR=Yes  first row contains columnnames (default)
  //+ ';HDR=No'                        // HDR=No   first row doesnt contains columnnames
    + ';'
    , [IvFile])

  else if e = '.xlsx' then
    Result := Format(
       'Provider=Microsoft.ACE.OLEDB.12.0'
    + ';Data Source=%s'
    + ';Extended Properties="Excel 12.0 Xml'
  //+ ';HDR=Yes'
  //+ ';User ID=Admin'
  //+ ';Mode=Share Deny None'
  //+ ';Persist Security Info=False';
  //+ ';Jet OLEDB:System database=""'
  //+ ';Jet OLEDB:Registry Path=""'
  //+ ';Jet OLEDB:Database Password=""'
  //+ ';Jet OLEDB:Engine Type=37'
  //+ ';Jet OLEDB:Database Locking Mode=0'
  //+ ';Jet OLEDB:Global Partial Bulk Ops=2'
  //+ ';Jet OLEDB:Global Bulk Transactions=1'
  //+ ';Jet OLEDB:New Database Password=""'
  //+ ';Jet OLEDB:Create System Database=False'
  //+ ';Jet OLEDB:Encrypt Database=False'
  //+ ';Jet OLEDB:Don''t Copy Locale on Compact=False'
  //+ ';Jet OLEDB:Compact Without Replica Repair=False'
  //+ ';Jet OLEDB:SFP=False'
  //+ ';Jet OLEDB:Support Complex Data=False'
    + ';'
    , [IvFile])
  else
    raise Exception.Create('Unknow Excel file extension')
  ;
end;

function TCnsRec.CsMsSqlADO(IvServer, IvDatabase, IvUsername, IvPassword: string; IvSSPI: boolean): string;
begin
  Result :=
     'Provider='              + 'SQLOLEDB.1'
  + ';Persist Security Info=' + 'True'       // if True the connection object will remember username/password otherwise it will connect just once and if you close the connection you will not be able to connect again, default is False
  + ';Data Source='           + IvServer     // LOCALHOST | PHOBOS | AIWYMSTEST\SQLEXPRESS
  + ';Initial Catalog='       + IvDatabase   // DbaPage
  ;
  if not IvSSPI then
  Result := Result
  + ';User ID='               + IvUsername  // sa
  + ';Password='              + IvPassword  // secret
  else
  Result := Result
  + ';Integrated Security=SSPI'             // sspi=true, same as Trusted_Connection
  ;
//+ ';Use procedure for Prepare=1'
//+ ';Auto Translate=True'
//+ ';Packet Size=4096'
//+ ';Workstation ID=UNKNOWN'
//+ ';Use Encryption for Data=False'
//+ ';Tag with column collation when possible=False'
end;

function TCnsRec.CsMsSqlFD(IvServer, IvDatabase, IvUsername, IvPassword: string; IvSSPI: boolean): string;
begin
  Result :=
     'DriverID='              + 'MSSQL'                      // IvFDConnection.DriverName             := r;
  + ';SERVER='                + IvServer    // PHOBOS         // IvFDConnection.Params.Append('Server=' + s);
  + ';DATABASE='              + IvDatabase  // DbaAaa         // IvFDConnection.Params.Database        := d;
  + ';User_Name='             + IvUsername  // sa             // IvFDConnection.Params.Username        := u;
  + ';Password='              + IvPassword  // secret         // IvFDConnection.Params.Password        := p;
  + ';ApplicationName='       + sys.Acronym // ?
  + ';Workstation='           + UNKNOWN_STR // ?
  + ';MARS='                  + 'yes'       // ?
  ;
end;

function TCnsRec.CsOracleADO(IvServer, IvPort, IvSId, IvServiceName, IvDatabase, IvUsername, IvPassword, IvDatasource: string): string;
var
  s, t, i, n, d, u, p, o: string; // server, port, sid, servicename, database, username, password, datasource
begin
  // http://docwiki.embarcadero.com/RADStudio/Tokyo/en/Connect_to_Oracle_Server_(FireDAC)
  s := iif.NxD(IvServer     , 'localhost');                                // server                 10.176.154.55, azklarity01.azit.lfoundry.com, azracprod09.azit.micron.com
  t := iif.NxD(IvPort       , ''         );                                // port                   1521
  i := iif.NxD(IvSId        , ''         );                                // sid                    ?
  n := iif.NxD(IvServiceName, ''         );                                // servicename            azracprod09.micron.com/udbfab9
  d := iif.NxD(IvDatabase   , ''         );                                // defaultdba or schemaid ESDA, PARAM, PROBE, REFERENCE, SIGMA, SWRINFO, ...
  u := iif.NxD(IvUsername   , ''         );                                // username               YMS, MIT_SSSECTION_SET_EMPTY_YE
  p := iif.NxD(IvPassword   , ''         );                                // password               changeme, changeyourpassword
  o := iif.Str(IvDatasource  <> '', IvDatasource, CsOracleDs(s, t, i, n)); // odbcdatasource: SIGMA, ...

  // Provider=OraOLEDB.Oracle.1;Password=changeme;Persist Security Info=True;User ID=YMS;Data Source="(DESCRIPTION=(CID=GTU_APP)(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=azracprod09.azit.micron.com)(PORT=1521)))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=azracprod09.micron.com)))"
  Result :=
     'Provider='              + 'OraOLEDB.Oracle.1' // OraOLEDB.Oracle, MSDAORA.1, OraOLEDB.Oracle.1
  + ';Data Source='           + o
  + ';Initial Catalog='       + d
  + ';User ID='               + u
  + ';Password='              + p
  + ';Persist Security Info=' + 'True'
  ;
end;

function TCnsRec.CsOracleFD(IvServer, IvPort, IvSId, IvServiceName, IvDatabase, IvUsername, IvPassword, IvDatasource: string): string;
var
  s, t, i, n, d, u, p, o: string; // server, port, sid, servicename, database, username, password, datasource
begin
  // def
  s := iif.NxD(IvServer     , 'localhost');                                // server                 10.176.154.55, azklarity01.azit.lfoundry.com, azracprod09.azit.micron.com
  t := iif.NxD(IvPort       , ''         );                                // port                   1521
  i := iif.NxD(IvSId        , ''         );                                // sid                    ?
  n := iif.NxD(IvServiceName, ''         );                                // servicename            azracprod09.micron.com/udbfab9
  d := iif.NxD(IvDatabase   , ''         );                                // defaultdba or schemaid ESDA, PARAM, PROBE, REFERENCE, SIGMA, SWRINFO, ...
  u := iif.NxD(IvUsername   , ''         );                                // username               YMS, MIT_SSSECTION_SET_EMPTY_YE
  p := iif.NxD(IvPassword   , ''         );                                // password               changeme, changeyourpassword
  o := iif.Str(IvDatasource  <> '', IvDatasource, CsOracleDs(s, t, i, n)); // odbcdatasource: SIGMA, ...

  // DriverID=Ora;Database=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=<Server>                   )(PORT=<Port>)))(CONNECT_DATA=(SID=<SId>)|(SERVICE_NAME=<ServiceName>         )));User_Name=<Username>;Password=<Password>"
  // DriverID=Ora;Database=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=azracprod09.azit.micron.com)(PORT=1521  )))(CONNECT_DATA=            (SERVICE_NAME=azracprod09.micron.com)));User_Name=YMS       ;Password=changeme'
  Result :=
     'DriverID='              + 'ORA'
  + ';Database='              + o
  + ';User_Name='             + u
  + ';Password='              + p
  ;
end;

function TCnsRec.CsOracleDs(IvServer, IvPort, IvSId, IvServiceName: string): string;
begin
  Result :=
    '(DESCRIPTION='
//+   '(CID=GTU_APP)'
  +   '(ADDRESS_LIST='
  +     '(ADDRESS='
  +     '(PROTOCOL=TCP)'
  +     '(HOST=' + IvServer + ')'
  +     '(PORT=' + IvPort   + ')'
  +     ')'
  +   ')'
  +   '(CONNECT_DATA='
  +     iif.EXr(IvSId        , '(SID='          + IvSId         + ')')
  +     iif.EXr(IvServiceName, '(SERVICE_NAME=' + IvServiceName + ')')
//+    '(SERVER=DEDICATED)'
  +   ')'
  + ')'
  ;
end;

function TCnsRec.CsSqLiteFD(IvFile, IvUsername, IvPassword: string): string;
begin
  Result :=
     'DriverID=' + 'SQLite'
  + ';Database=' + IvFile        // X:\$\I\WksDba.sdb
  + ';Encrypt='  + 'No'
  ;
end;
{$ENDREGION}

{$REGION 'TConRec'}
function TConRec.ConnADOInit(var IvADOConnection: TADOConnection; IvCsADO: string; var IvFbk: string): boolean;
begin
  // nocs
  if iis.Nx(IvCsADO) then begin
    IvFbk := 'IvADO connection string is empty';
    Result := false;
    Exit;
  end;

  // createifneeded
  if not Assigned(IvADOConnection) then begin
  //CoInitialize(nil);
    IvADOConnection := TADOConnection.Create(nil);
  end;

  // setup
  IvADOConnection.Close;
//IvADOConnection.DefaultDatabase   := '';
  IvADOConnection.ConnectionTimeout := DBA_CONNECTION_TIMEOUT_SEC; // IvADOConnection.Properties.Item['ConnectionTimeout'] := '1';
  IvADOConnection.CommandTimeout    := DBA_COMMAND_TIMEOUT_SEC;    // not effective, overridden by ds.CommandTimeout that usually is still 30s, so setup each command tadoquery/tadotable
  IvADOConnection.LoginPrompt       := false;
  IvADOConnection.ConnectionString  := IvCsADO;
//IvADOConnection.BeforeConnect     := nil;
//IvADOConnection.AfterConnect      := nil;
//IvADOConnection.OnWillConnect     := nil;

  // host?
//if not IvHost.Ping then begin
//  IvFbk := 'host ping failed';
//  Result := false;
//  Exit;
//end;

  // db?
  try
    IvADOConnection.Open;
    IvFbk := 'ADO connection ok';
    Result := true;
  except
    on e: Exception do begin
      IvFbk := str.E(e);
      Result := false;
    end;
  end;
end;

function TConRec.ConnADOFree(var IvADOConnection: TADOConnection; var IvFbk: string): boolean;
begin
  // exit
  if not Assigned(IvADOConnection) then begin
    IvFbk := 'IvADOConnection is not assigned, connection release skipped';
    Result := true;
    Exit;
  end;

  try
    // close&free
    IvFbk := Format('ADO connection to %s has been closed and released', [IvADOConnection.ConnectionString]);
    if IvADOConnection.Connected then
      IvADOConnection.Close;
    FreeAndNil(IvADOConnection);
    Result := true;
  except
    on e: Exception do begin
      IvFbk := str.E(e);
      Result := false;
    end;
  end;
end;

function TConRec.ConnFDInit(var IvFDConnection: TFDConnection; IvCsFD: string; var IvFbk: string): boolean;
begin
  // nocs
  if iis.Nx(IvCsFD) then begin
    IvFbk := 'FD connection string is empty';
    Result := false;
    Exit;
  end;

  // createifneeded
  if not Assigned(IvFDConnection) then  begin
  //CoInitialize(nil);
    IvFDConnection := TFDConnection.Create(nil);
  end;

  // setup
  FFDGUIxSilentMode := true;          // suppress whait cursor?
//IvFDConnection.Close;               // IvFDConnection.Connected := false;
  IvFDConnection.LoginPrompt          := false;
  IvFDConnection.ConnectionString     := IvCsFD;
//IvFDConnection.Name                 := 'AZRACPROD09';
//IvFDConnection.DriverName           := 'ORA'; // MySQL
//IvFDConnection.ConnectionDefName    := 'Oracle_Pooled'; // see http://docwiki.embarcadero.com/RADStudio/Tokyo/en/Multithreading_(FireDAC)
//IvFDConnection.ConnectTimeout       := DBA_CONNECTION_TIMEOUT_SEC;
//IvFDConnection.Params.Clear;
//IvFDConnection.Params.Add(    'Server=192.168.1.100'); // or IvFDConnection.Params.Values['Server'] := '192.168.1.100';
//IvFDConnection.Params.Add(  'Database=<YourDatabase>');
//IvFDConnection.Params.Add( 'OSAuthent=Yes');
//IvFDConnection.Params.Database      := 'azracprod09.azit.micron.com';
//IvFDConnection.Params.UserName      := 'YMS';
//IvFDConnection.Params.Password      := 'changeme';
//IvFDConnection.Params.ConnectionDef := 'AZRACPROD09';
//IvFDConnection.BeforeConnect        := nil;
//IvFDConnection.AfterConnect         := nil;
//IvFDConnection.ResourceOptions.CmdExecMode := amNonBlocking;


  // host? note that with sql server express you have to enable tcpip protocol and restart the sql server service
  if not IvFDConnection.Ping then begin
    IvFbk := 'Host ping failed';
    Result := false;
    Exit;
  end;

  // db?
  try
    IvFDConnection.Open;
    IvFbk := 'FD connection ok';
    Result := true;
  except
    on e: Exception do begin
      IvFbk := str.E(e);
      Result := false;
    end;
  end;
end;

function TConRec.ConnFDFree(var IvFDConnection: TFDConnection; var IvFbk: string): boolean;
begin
  // exit
  if not Assigned(IvFDConnection) then begin
    IvFbk := 'IvFDConnection is not assigned, connection release skipped';
    Result := true;
    Exit;
  end;

  try
    // close&free
    IvFbk := Format('FD connection to %s has been closed and released', [IvFDConnection.ConnectionString]);
    if IvFDConnection.Connected then
      IvFDConnection.Close;
    FreeAndNil(IvFDConnection);
    Result := true;
  except
    on e: Exception do begin
      IvFbk := str.E(e);
      Result := false;
    end;
  end;
end;
{$ENDREGION}

{$REGION 'TCryRec'}
function TCryRec.Cipher(const IvString: string; IvStartKey, IvMultKey, IvAddKey: integer): string;
var
  i: word;
  b: byte;
  s: string;
begin
  // reverse
  s := ReverseString(IvString);
  Result := '';
  // standard cipher algorithm - copied from Borland
  for i := 1 to Length(s) do begin
    b := Byte(s[i]) xor (IvStartKey shr 8);
    IvStartKey := (IvStartKey + b) * IvMultKey + IvAddKey;
    Result := Result + IntToHex(b, 2);
  end;
end;

function TCryRec.CipherSha2(IvPlain: string): string;
begin
  Result := THashSHA2.GetHashString(IvPlain);
end;

function TCryRec.CipherSha2HMac(IvPlain, IvKey: string): string;
begin
  Result := THashSHA2.GetHMAC(IvPlain, IvKey);
end;

function TCryRec.Decipher(const IvString: string; IvStartKey, IvMultKey, IvAddKey: integer): string;
var
  i: word;
  a, b: byte;
begin
  a := 0;
  Result := '';
  // standard decipher algorithm - copied from Borland
  for i := 1 to Length(IvString) div 2 do begin
    try
      a := StrToInt('$' + Copy(IvString, 2*i-1, 2));
    except
      on EConvertError do
        a := 0;
    end;
    b := Byte(a) xor (IvStartKey shr 8);
    IvStartKey := (IvStartKey + a) * IvMultKey + IvAddKey;
    Result := Result + Char(b);
  end;
  // reverse
  Result := ReverseString(Result);
end;

function TCryRec.KeyIsValidAndSecure(const IvKey: string; var IvFbk: string): boolean;
begin
  Result := str.Is09(IvKey) and (Length(IvKey) >= CRYPTO_KEY_MIN_LEN);
  if Result then
    IvFbk := Format('CryptoKey %s is valid and secure', [IvKey])
  else
    IvFbk := Format('CryptoKey %s is not valid or secure, it have to be at least %d digits 0..9', [IvKey, CRYPTO_KEY_MIN_LEN]);
end;
{$ENDREGION}

{$REGION 'TDatRec'}
function TDatRec.DateFromCode(IvDateTimeCode: string): TDate;
var
  y, m, d: integer;
begin
  if Length(IvDateTimeCode) <> 14 then
    Result := 0
  else begin
    y := StrToInt(Copy(IvDateTimeCode,  1, 4));
    m := StrToInt(Copy(IvDateTimeCode,  5, 2));
    d := StrToInt(Copy(IvDateTimeCode,  7, 2));
    Result := EncodeTime(y, m, d, 0);
  end;
end;

function TDatRec.DateToCode(IvDateTime: TDateTime): string;
begin
  Result := Format('%.2d%.2d%.2d', [Year(IvDateTime), Month(IvDateTime), Day(IvDateTime)]);
end;

function TDatRec.Day(IvDateTime: TDateTime; IvInc: integer): integer;
begin
  Result := DayOf(IncDay(IvDateTime, IvInc));
end;

function TDatRec.DayStr(IvDateTime: TDateTime; IvInc: integer): string;
begin
  Result := Format('%.*d', [2, Day(IvDateTime, IvInc)]);
end;

function TDatRec.ForSql(IvDateTime: TDateTime): string;
begin
  Result := FormatDateTime(dat.MSSQLFORMAT, IvDateTime);
end;

function TDatRec.FromCode(IvDateTimeCode: string): TDateTime;
var
  y, m, d, h, n, s: integer;
begin
  if Length(IvDateTimeCode) <> 14 then
    Result := 0
  else begin
    y := StrToInt(Copy(IvDateTimeCode,  1, 4));
    m := StrToInt(Copy(IvDateTimeCode,  5, 2));
    d := StrToInt(Copy(IvDateTimeCode,  7, 2));
    h := StrToInt(Copy(IvDateTimeCode,  9, 2));
    n := StrToInt(Copy(IvDateTimeCode, 11, 2));
    s := StrToInt(Copy(IvDateTimeCode, 13, 2));
    Result := EncodeDate(y, m, d) + EncodeTime(h, n, s, 0);
  end;
end;

function TDatRec.ToCode(IvDateTime: TDateTime): string;
begin
  Result := DateToCode(IvDateTime) + TimeToCode(IvDateTime);
end;

function TDatRec.FromIso(IvDateTimeIso: string; IvInputIsUTC: boolean): TDateTime;
begin
  if IvDateTimeIso = '' then
    Result := 0.0
  else
    Result := ISO8601ToDate(IvDateTimeIso, IvInputIsUTC);
// converts an ISO8601 date/time string to TDateTime
// the result is in local time, if IvInputIsUTC is false
// example
// in:  "2013-10-18T20:36:22.966Z", false
// out: 20:36 if your timezone is ZULU (UTC+0 ZeroMeridian)
// out: 22:36 if your timezone is MEST (UTC+2)
end;

function TDatRec.Hour(IvDateTime: TDateTime; IvInc: integer): integer;
begin
  Result := HourOf(IncHour(IvDateTime, IvInc));
end;

function TDatRec.HourStr(IvDateTime: TDateTime; IvInc: integer): string;
begin
  Result := Format('%.*d', [2, Hour(IvDateTime, IvInc)]);
end;

function TDatRec.Minute(IvDateTime: TDateTime; IvInc: integer): integer;
begin
  Result := MinuteOf(IncMinute(IvDateTime, IvInc));
end;

function TDatRec.MinuteStr(IvDateTime: TDateTime; IvInc: integer): string;
begin
  Result := Format('%.*d', [2, Minute(IvDateTime, IvInc)]);
end;

function TDatRec.MinuteBetween(IvDateTime1, IvDateTime2: TDateTime): int64;
begin
  Result := MinutesBetween(IvDateTime1, IvDateTime2);
end;

function TDatRec.MinuteInc(IvDateTime: TDateTime; IvInc: integer): TDateTime;
begin
  Result := IncMinute(IvDateTime, IvInc);
end;

function TDatRec.Month(IvDateTime: TDateTime; IvInc: integer): integer;
begin
  Result := MonthOf(IvDateTime) + IvInc mod 12;
end;

function TDatRec.MonthStr(IvDateTime: TDateTime; IvInc, IvLength: integer): string;
begin
  Result := FormatSettings.LongMonthNames[Month(IvDateTime, IvInc)];
  if (IvLength > 0) and (IvLength <= 3) then
    Result := LeftStr(Result, IvLength);
end;

function TDatRec.NowMs: cardinal;
var
  t: TDateTime;
  h, m, s, ms: word;
begin
  t := Time;
  DecodeTime(t, h, m, s, ms);
  Result := h * 3600000 + m * 60000 + s * 1000 + ms;
end;

function TDatRec.NowStr: string;
begin
  Result := DateTimeToStr(Now);
end;

function TDatRec.Quarter(IvDateTime: TDateTime; IvInc: integer): integer;
var
  m: integer;
begin
  m := MonthOf(IvDateTime);
       if (m >=  4) and (m <=  6) then Result := 1
  else if (m >=  7) and (m <=  9) then Result := 2
  else if (m >= 10) and (m <= 12) then Result := 3
  else                                 Result := 4;
  Result := m + IvInc mod 4;
end;

function TDatRec.Second(IvDateTime: TDateTime; IvInc: integer): integer;
begin
  Result := SecondOf(IncSecond(IvDateTime, IvInc));
end;

function TDatRec.SecondStr(IvDateTime: TDateTime; IvInc: integer): string;
begin
  Result := Format('%.*d', [2, Second(IvDateTime, IvInc)]);
end;

function TDatRec.TimeFromCode(IvDateTimeCode: string): TTime;
var
  h, n, s: integer;
begin
  if Length(IvDateTimeCode) <> 14 then
    Result := 0
  else begin
    h := StrToInt(Copy(IvDateTimeCode,  9, 2));
    n := StrToInt(Copy(IvDateTimeCode, 11, 2));
    s := StrToInt(Copy(IvDateTimeCode, 13, 2));
    Result := EncodeTime(h, n, s, 0);
  end;
end;

function TDatRec.TimeToCode(IvDateTime: TDateTime): string;
begin
  Result := Format('%2d%2d%2d', [Hour(IvDateTime), Minute(IvDateTime), Second(IvDateTime)]);
end;

function TDatRec.Week(IvDateTime: TDateTime; IvInc: integer): integer;
begin
  Result := WeekOf(IvDateTime) + IvInc mod 52{53};
end;

function TDatRec.WeekDay(IvDateTime: TDateTime; IvInc: integer): integer;
begin
  Result := DayOfTheWeek(IvDateTime) + IvInc mod 7;
end;

function TDatRec.WeekDayStr(IvDateTime: TDateTime; IvInc, IvLength: integer): string;
begin
  Result := FormatSettings.LongDayNames[WeekDay(IvDateTime, IvInc)];
  if (IvLength > 0) and (IvLength <= 3) then
    Result := LeftStr(Result, IvLength);
end;

function TDatRec.WeekStr(IvDateTime: TDateTime; IvInc: integer): string;
begin
  Result := Format('%.*d', [2, Week(IvDateTime, IvInc)]);
end;

function TDatRec.WeekWork(IvDateTime: TDateTime; IvWeekDayStart, IvTimeStart: string; IvInc: integer): integer;
begin
  Result := Week(IvDateTime,IvInc); // TODO: should call a rio webservice ... or a FUNCTION = a remote indipendent asyncronous script in any language?
end;

function TDatRec.WeekWorkStr(IvDateTime: TDateTime; IvWeekDayStart, IvTimeStart: string; IvInc: integer): string;
begin
  Result := Format('%.*d', [2, WeekWork(IvDateTime, IvWeekDayStart, IvTimeStart, IvInc)]);
end;

function TDatRec.Year(IvDateTime: TDateTime; IvInc: integer): integer;
begin
  Result := YearOf(IncYear(IvDateTime, IvInc));
end;

function TDatRec.YearNow(IvInc: integer): integer;
begin
  Result := CurrentYear + IvInc;
end;
{$ENDREGION}

{$REGION 'TDbaCls'}
constructor TDbaCls.Create({IvCsADO, }IvCsFD: string);
var
  k: string;
begin

  {$REGION 'ADO'}
  // cs
//  FCsADO := cns.CsADO(IvCsADO);

  // conn
//  con.ConnADOInit(FConnADO, FCsFD, k);
  {$ENDREGION}

  {$REGION 'FD'}
  // cs
  FCsFD := cns.CsFD(IvCsFD);

  // conn
  con.ConnFDInit(FConnFD, FCsFD, k);
  {$ENDREGION}

end;

function TDbaCls.Dba(const IvDatabaseName: string): string;
begin
  Result := 'Dba' + IvDatabaseName;
end;

function TDbaCls.DbaCreate(const IvDba: string; var IvFbk: string): boolean;
var
  q: string;
  z: integer;
begin
  q := Format('create database %s', [IvDba]);
//lg.Q(q);
  Result := ExecFD(q, z, IvFbk);
end;

function TDbaCls.DbaCreateIfNotExists(const IvDba: string; var IvFbk: string): boolean;
begin
  if not DbaExists(IvDba, IvFbk) then begin
    IvFbk := Format('%s does not exists, create it now', [IvDba]);
    Result := DbaCreate(IvDba, IvFbk);
  end else begin
    IvFbk := fbk.ExistsStr('Database', IvDba, true);
    Result := false; // not created, already exists
  end;
end;

function TDbaCls.DbaExists(const IvDba: string; var IvFbk: string): boolean;
var
  q: string;
begin
  q := Format('select case when exists(select * from master.sys.databases where name = ''%s'') then 1 else 0 end as FldResult', [IvDba]); // master.dbo.sysdatabases
//lg.Q(q);
  Result := ScalarFD(q, 0, IvFbk) = 1;
  IvFbk := fbk.ExistsStr('Database', IvDba, Result);
end;

destructor TDbaCls.Destroy;
var
  k: string;
begin

  {$REGION 'ADO'}
//FConnADO.Free;
//con.ConnADOFree(FConnADO, k);
  {$ENDREGION}

  {$REGION 'FD'}
  FConnFD.Free;
//con.ConnFDFree(FConnFD, k); // *** PROBLEM: isapi do not exit when recycling then apppool ***
  {$ENDREGION}

  inherited;
end;
(*
function  TDbaCls.DsADO(IvSql: string; var IvDs: TDataSet; var IvFbk: string; IvFailIfEmpty: boolean; IvTimeOutSec: integer): boolean;
var
  q: TADOQuery;
begin
  q := TADOQuery.Create(nil);
//try
  //q.CursorLocation := clUseServer; // letthecommandtimeoutworkscorrectlybutdoesntworkinaccess
    q.CommandTimeout := IvTimeOutSec;
    q.Connection := FConnADO;
    q.Close;
    q.SQL.Text := IvSql;
    q.Prepared := true;
    try
      q.Open;
      IvDs := q;
      IvFbk := Format('Records affected %d', [IvDs.RecordCount]);
      Result := true;
      if IvFailIfEmpty and IvDs.IsEmpty then
        Result := false;
    except
      on e: EOleException do begin
        if Assigned(q) then
          q.Free;
      //if Assigned(IvDs) then
        //IvDs.Free;
        IvFbk := e.Message;
        lg.E(e);
        lg.Q(IvSql);
        Result := false;
        raise;
      end;
    end;
//finally
  //q.Free; // caller is responsible to free the IvDs := q dataset
//end;
end;

function  TDbaCls.RsADO(IvSql: string; var IvRs: _Recordset; var IvFbk: string; IvFailIfEmpty: boolean; IvTimeOutSec: integer): boolean;
begin
  try
    FConnADO.CommandTimeout := IvTimeOutSec;
    IvRs := FConnADO.Execute(IvSql);
    IvFbk := Format('Records affected %d', [IvRs.RecordCount]);
    Result := true;
    if IvFailIfEmpty and (IvRs.RecordCount = 0) then
      Result := false;
  except
    on e: EOleException do begin
      IvFbk := e.Message;
      lg.E(e);
      lg.Q(IvSql);
      Result := false;
      raise;
    end;
  end;
end;
*)
function TDbaCls.DsFD(IvSql: string; var IvDs: TFDDataSet; var IvFbk: string; IvFailIfEmpty: boolean; IvTimeOutSec: integer): boolean;
var
  q: TFDQuery;
begin
  q := TFDQuery.Create(nil);
  try
  //try
      q.FetchOptions.Mode              := fmAll; // fmOnDemand
    //q.FetchOptions.RowsetSize        := 10000;
    //q.FetchOptions.CursorKind        := ckForwardOnly; // fast forward-only, read-only options
    //q.FetchOptions.Unidirectional    := true;
      q.ResourceOptions.CmdExecTimeout := IvTimeOutSec;

    //q.Close;
      q.Connection := FConnFD;
      q.SQL.Text   := IvSql;
      q.Prepared   := true;
      q.Open;
      q.FetchAll;

      // assign 1st recordset
      IvDs := q;

      // next recordets
      //q.NextRecordSet;
      //q.FetchAll;
      // assign next recordet
      //IvDs2.Data := q.Data;

      IvFbk := Format(mes.RECORDS_AFFECTED_FMT, [q.RecordCount]);
      Result := true;

      if IvFailIfEmpty and (q.RecordCount = 0) then
        Result := false;
  //finally
    //FreeAndNil(q); // WARNING: caller is responsible to free the IvDs
  //end;
  except
    on e: Exception do begin
      FreeAndNil(q);
      IvFbk := Format('EXCEPTION: %s (%s)', [e.Message, str.OneLine(IvSql)]);
      Result := false;
    end;
  end;
end;

function TDbaCls.DsFD(IvSql: string; var IvDs: TDataSet; var IvFbk: string; IvFailIfEmpty: boolean; IvTimeOutSec: integer): boolean;
var
  d: TFDDataSet;
begin
  Result := DsFD(IvSql, d, IvFbk, IvFailIfEmpty, IvTimeOutSec);
  if Result then begin
    if not Assigned(IvDs) then
      IvDs := TDataSet.Create(nil);
    IvDs := d as TDataSet;
    IvDs.Open;
  //d.Free;
  end;
end;
(*
function  TDbaCls.ExecADO(IvSql: string; var IvAffected: integer; var IvFbk: string; IvTimeOutSec: integer): boolean;
begin
  try
    FConnADO.CommandTimeout := IvTimeOutSec;
    {rs :=} FConnADO.Execute(IvSql, IvAffected);
    IvFbk := Format(mes.RECORDS_AFFECTED_FMT, [IvAffected]);
    Result := true;
  except
    on e: Exception do begin
      IvAffected := 0;
      IvFbk := e.Message;
      lg.E(e);
      lg.Q(IvSql);
      Result := false;
      raise;
    end;
  end;
end;
*)
function TDbaCls.ExecFD(IvSql: string; var IvAffected: integer; var IvFbk: string; IvTimeOutSec: integer): boolean;
begin
  try
    FConnFD.ResourceOptions.CmdExecTimeout := IvTimeOutSec;
    IvAffected := FConnFD.ExecSQL(IvSql, []);
    IvFbk := Format(mes.RECORDS_AFFECTED_FMT, [IvAffected]);
    Result := true;
  except
    on e: Exception do begin
      IvFbk := Format('EXCEPTION: %s (%s)', [e.Message, str.OneLine(IvSql)]);
      Result := false;
    end;
  end;
end;

function TDbaCls.Fld(const IvFieldName: string): string;
begin
  Result := 'Fld' + IvFieldName;
end;

function TDbaCls.FldCreate(const IvTbl, IvFld: string; var IvFbk: string): boolean;
begin
  Result := false;
  IvFbk := NOT_IMPLEMENTED;
  //SqlFieldAdd(TableName, FieldName, FieldType, FieldSize);
end;

function TDbaCls.FldDec(const IvTbl, IvFld, IvWhere: string; var IvFbk: string): boolean;
begin
  Result := FldDoMath(IvTbl, IvFld, '-', '1', IvWhere, IvFbk);
end;

function TDbaCls.FldDefault(IvDs: TFDDataset; IvFld: string; IvDefault: variant): variant;
begin
  Result := vnt.IsNull(IvDs.FieldByName(IvFld).Value, IvDefault);
end;

function TDbaCls.FldDoMath(IvTbl, IvFld: string; IvOperator: char; IvOperand, IvWhere: string; var IvFbk: string): boolean;
var
  a, b, r: double;
  v: variant;
begin
  // a
  Result := FldGet(IvTbl, IvFld, IvWhere, v, 0.0, IvFbk);
  if not Result then
    Exit;
  a := v;
  //lg.IFmt('a = %f', [a]);

  // b
  b := StrToFloatDef(IvOperand, 0.0);
  //lg.IFmt('b = %f', [b]);

  // a operator b
  try
    if (IvOperand = '') and (IvOperator = '-') then
      r := -a                            // invert
    else begin
      case IvOperator of
        '+': r := a + b;                 // addition
        '-': r := a - b;                 // subtraction
        '*': r := a * b;                 // multiply
        '/': r := a / b;                 // divide
        '%': r := Round(a) mod Round(b); // module
        '\': r := Round(a) div Round(b); // integer divide
        '~': r := Round(b);              // approximate
      else
        r := -1
      end;
    end;
    //lg.IFmt('a %s b = %f', [IvOperator, r]);

    // setvalue
    Result := FldSet(IvTbl, IvFld, IvWhere, r, IvFbk);
  except
    on e: Exception do begin
      IvFbk := str.E(e);
      Result := false;
    end;
  end;
end;

function TDbaCls.FldExists(const IvTbl, IvFld: string; var IvFbk: string): boolean;
begin
  Result := false;
  IvFbk := NOT_IMPLEMENTED;
{
function  DbaFldExists(IvAdoTable: TADOTable; IvFld: string; var IvFbk: string): boolean;
var
  i: integer;
begin
  IvFbk := Format('Field %s doesn''t exists', [IvFld]);
  Result := false;
  for i := 0 to IvAdoTable.FieldCount - 1 do
    if IvAdoTable.Fields[i].FieldName = IvFld then begin
      IvFbk := Format('Field %s exists', [IvFld]);
      Result := true;
      Exit;
    end;
//lg.I(IvFbk);
end;
}
end;

procedure TDbaCls.FldFromByteArray(IvDs: TFDDataset; IvFld: string; IvByteArray: TByteDynArray);
var
  m: TMemoryStream;
  b: TBlobField;
begin
  // fieldblob
  b := TBlobField(IvDs.FieldByName(IvFld));

  // load
  m := TMemoryStream.Create;
  try
    stm.FromByteArray(IvByteArray, m);
    m.Position := 0;
    b.LoadFromStream(m);
  finally
    FreeAndNil(m);
  end;
end;

function TDbaCls.FldGet(const IvTbl, IvFld, IvWhere: string; var IvValueOut: variant; IvDefault: variant; var IvFbk: string): boolean;
var
  q: string;
begin
  // where
  Result := IvWhere <> '';
  if not Result then begin
    IvFbk := 'IvWhere have to be not empty';
    Exit;
  end;

  // sql
  q := Format('select top(1) %s from %s where %s', [IvFld, IvTbl, IvWhere]);

  // scalar
  IvValueOut := ScalarFD(q, IvDefault, IvFbk);
  Result := true;
end;

function TDbaCls.FldInc(const IvTbl, IvFld, IvWhere: string; var IvFbk: string): boolean;
begin
  Result := FldDoMath(IvTbl, IvFld, '+', '1', IvWhere, IvFbk);
end;

function TDbaCls.FldSet(const IvTbl, IvFld, IvWhere: string; const IvValueIn: variant; var IvFbk: string): boolean;
var
  q: string;
  z: integer;
begin
  // where
  Result := IvWhere <> '';
  if not Result then begin
    IvFbk := 'IvWhere have to be not empty';
    Exit;
  end;

  // sql
  q := Format('update %s set %s = ''%s'' where %s', [IvTbl, IvFld, IvValueIn, IvWhere]);

  // exec
  Result := ExecFD(q, z, IvFbk);
end;

function TDbaCls.FldToByteArray(IvDs: TFDDataset; IvFld: string): TByteDynArray;
var
  b: TBlobField;
  m: TMemoryStream;
begin
  // fieldblob
  b := TBlobField(IvDs.FieldByName(IvFld));

  // result
  if b.BlobSize > 0 then begin
    m := TMemoryStream.Create;
    try
      b.SaveToStream(m);
      m.Position := 0;
      Result := stm.ToByteArray(m);
    finally
      FreeAndNil(m);
    end;

  end else
    Result := nil;
end;

function TDbaCls.HChildsDs(const IvTbl, IvFldCsv: string; const IvId: integer; var IvDs: TDataSet; var IvFbk: string; IvWhere, IvOrderBy: string): boolean;

  {$REGION 'var'}
{
  FldLevel(, FldLevelRel, FldChilds), FldId, FldPId, FldState(, FldPath) are prepended by default so IvFldCsv does not have to contains them
}
var
  q, f, g, w, o: string; // sql, fieldlist, fieldlist2, where, orderby
  {$ENDREGION}

begin
  f := iif.ExP(IvFldCsv, ', ');
  g := str.Replace(f, ', Fld', ', ng.Fld');
  w := iif.ExP(IvWhere, 'where ');
  o := iif.ExP(IvOrderBy, 'order by ');
  q :=           'with'
//+ sLineBreak + '  -- recursive cte'
  + sLineBreak + '  childs (FldLevel, FldId, FldPId, FldState, FldPath' + f + ') as ('
//+ sLineBreak + '  -- fixed part, anchor, 1st generation or level'
  + sLineBreak + '    select 0, FldId, FldPId, FldState, ''\'' + convert(varchar(max), FldId)' + f
  + sLineBreak + '    from ' + IvTbl + ' as fg'        // firstgeneration
  + sLineBreak + '    where FldId = ' + IntToStr(IvId) // root
  + sLineBreak + '  union all'
//+ sLineBreak + '  -- recursive part, next childs or levels'
  + sLineBreak + '    select pa.FldLevel+1, ng.FldId, ng.FldPId, ng.FldState, pa.FldPath + ''\'' + convert(varchar(max), ng.FldId)' + g
  + sLineBreak + '    from ' + IvTbl + ' as ng'        // nextgeneration
  + sLineBreak + '    inner join childs  as pa'        // references the whole cte as parent
  + sLineBreak + '    on (ng.FldPId = pa.FldId)'
  + sLineBreak + ')'
//+ sLineBreak + '-- statement that call the cte'
  + sLineBreak + 'select FldLevel, FldId, FldPId, FldState, FldPath' + f
  + sLineBreak + 'from childs'
  + sLineBreak + w
  + sLineBreak + o
  + sLineBreak + 'option(maxrecursion 32767)' // in calling the cte, by default it is 100
  ;
  Result := DsFD(q, IvDs, IvFbk);
//LogDs(IvDs); // rimane su eof se si usa FD e quindi spacca tutto!
end;

function TDbaCls.HIdFromIdOrPath(const IvTbl, IvPathFld: string; IvIdOrPath: string; var IvId: integer; var IvFbk: string): boolean;
begin
  // default
  IvId := -1;

  // int
  if str.IsInteger(IvIdOrPath) then begin
    IvId := StrToInt(IvIdOrPath);
    Result := true;
    Exit;
  end;

  // path
  Result := HIdFromPath(IvTbl, IvPathFld, IvIdOrPath, IvId, IvFbk);

  // name
//IvId := HIdFromName(IvIdOrPathOrName, IvTbl, IvPathFld);
end;

function TDbaCls.HIdFromIdOrPath(const IvTbl, IvPathFld: string; IvIdOrPath: string): integer;
var
  o: boolean;
  k: string;
begin
  o := HIdFromIdOrPath(IvTbl, IvPathFld, IvIdOrPath, Result, k);
end;

function TDbaCls.HIdFromName(const IvTbl, IvNameFld, IvName: string): integer;
begin
  Result := HIdVecFromName(IvName, IvTbl, IvNameFld)[0];
end;

function TDbaCls.HIdFromPath(const IvTbl, IvPathFld, IvPath: string): integer;
var
  k: string;
begin
  HIdFromPath(IvTbl, IvPathFld, IvPath, Result, k);
end;

function TDbaCls.HIdFromPath(const IvTbl, IvPathFld, IvPath: string; var IvId: integer; var IvFbk: string): boolean;
var
  i: integer;
  p, q, k: string;
  v: {TStringVector}TStringDynArray;
begin
  // zip
  p := pat.TreePathNormalize(IvPath); // just / and remove the 1st /   Root/Organization/W/Wks/Login, Home, Login, ''

  // default
  if Sametext(p, 'Home') then
     p := org.TreePath
  else if not pat.TreePathIs(p) then
     p := org.TreePath + iif.ExP(p, '/');

  // home
//  if p.EndsWith('/Home') then
//    p := str.Remove(p, '/Home');

  // split
  v := vec.FromStr(p, '/\.'); // str.Split(p, '/');

  // find
  IvId := 0;
  for i := Low(v) to High(v) do begin
    q := Format('select FldId from %s where %s = %s and FldPId = %d', [IvTbl, IvPathFld, v[i].QuotedString, IvId]);
    IvId := ScalarFD(q, -1, k);
    Result := IvId > 0;
    if not Result then begin
      IvFbk := Format('Path %s not found', [p]);
      Exit;
    end;
  end;

  IvFbk := Format('Path %s found with id %d', [p, IvId]);
end;

function TDbaCls.HIdToPath(const IvTbl, IvPathFld: string; const IvId: integer; var IvPath, IvFbk: string): boolean;
var
  d: TDataSet;
begin
  Result := HParentsDs(IvTbl, IvPathFld, IvId, d, IvFbk);
  if not Result then
    Exit;

  d.First;
  IvPath := '';
  while not d.Eof do begin
    IvPath := IvPath + '/' + d.FieldByName(IvPathFld).AsString;
    d.Next;
  end;                  // /Root/Aaa/Bbb
  Delete(IvPath, 1, 1); // Root/Aaa/Bbb
end;

function TDbaCls.HIdVecFromName(const IvTbl, IvNameFld, IvName: string): TIntegerVector;
begin
  Result := [-1];
  raise Exception.Create(NOT_IMPLEMENTED);
end;

function TDbaCls.HLevel(const IvTbl: string; const IvId: integer; var IvLevel: integer; var IvFbk: string): boolean;
var
  q: string;
begin
  q :=           'declare @l int'
  + sLineBreak + 'set @l = 0'
  + sLineBreak + 'declare @p int'
  + sLineBreak + 'select @p = FldPId from ' + IvTbl + ' where FldId = ' + IntToStr(IvId)
  + sLineBreak + 'while (not @p = 0) begin'
  + sLineBreak + '    select @p = FldPId from ' + IvTbl + ' where FldId = @p'
  + sLineBreak + '    set @l = @l + 1'
  + sLineBreak + 'end'
  + sLineBreak + 'select @l' // + 0
  ;
  IvLevel := ScalarFD(q, -1, IvFbk);
  Result := true;
end;

function TDbaCls.HParentsDs(const IvTbl, IvFldCsv: string; const IvId: integer; var IvDs: TDataSet; var IvFbk: string): boolean;

  {$REGION 'var'}
{
  FldLevel(, FldLevelRel, FldChilds), FldId, FldPId, FldState(, FldPath) are prepended by default so IvFldCsv does not have to contains them
}
var
  q: string;
  {$ENDREGION}

begin
  q :=           'with parents (FldLevel, FldId, FldPId, FldState, ' + IvFldCsv + ') as ('
//+ sLineBreak + '  -- fixed part, anchor, 1st element'
  + sLineBreak + '    select 0, FldId, FldPId, FldState, ' + IvFldCsv
  + sLineBreak + '    from ' + IvTbl + ' as fe' // firstelement
  + sLineBreak + '    where FldId = ' + IntToStr(IvId)
  + sLineBreak + '  union all'
//+ sLineBreak + '  -- recursive part, next parent'
  + sLineBreak + '    select pa.FldLevel-1, np.FldId, np.FldPId, np.FldState, ' + lst.ItemPrepend(IvFldCsv, 'np.', DELIMITER_CHAR, true)
  + sLineBreak + '    from ' + IvTbl + ' as np' // nextparent
  + sLineBreak + '    inner join parents pa' // parent
  + sLineBreak + '    on (np.FldId = pa.FldPId)'
  + sLineBreak + ')'
  + sLineBreak + ''
  + sLineBreak + 'select *'
  + sLineBreak + 'from parents'
//+ sLineBreak + 'where FldId <> ' + IntToStr(IvForId)
  + sLineBreak + 'order by 1'
  + sLineBreak + 'option(maxrecursion 32767)'
  ;
  Result := DsFD(q, IvDs, IvFbk);
//LogDs(IvDs); // rimane su eof se si usa FD e quindi spacca tutto!
end;

function TDbaCls.HParentsItemChildsDs(const IvTbl, IvFldCsv: string; const IvId: integer; var IvDs: TDataSet; var IvFbk: string): boolean;

  {$REGION 'var'}
{
  FldLevel, FldLevelRel, FldChilds, FldId, FldPId, FldState(, FldPath) are prepended by default so IvFldCsv does not have to contains them
}
var
  a, f, q: string; // 1stfld, fieldslit
  p: PChar;
  {$ENDREGION}

begin
  // ???
  p := Pointer(IvFldCsv);
  a := lst.ItemNext(p);

  f := lst.ItemPrepend(IvFldCsv, 't.', DELIMITER_CHAR, true);
  q :=
//+ sLineBreak + '  -- level
    sLineBreak + 'declare @l int'
  + sLineBreak + 'set @l = 0'
  + sLineBreak + 'declare @p int'
  + sLineBreak + 'select @p = FldPId from ' + IvTbl + ' where FldId = ' + IntToStr(IvId)
  + sLineBreak + 'while (not @p = 0) begin'
  + sLineBreak + '    select @p = FldPId from ' + IvTbl + ' where FldId = @p'
  + sLineBreak + '    set @l = @l + 1'
  + sLineBreak + 'end'
//+ sLineBreak + 'set @l = @l + 0'
  + sLineBreak + ''
//+ sLineBreak + '  -- fixed part, anchor, 1st element, used in the following cte1 and cte2'
  + sLineBreak + ';with cte as ('
  + sLineBreak + '    select 0 as FldLevel, 0 as FldLevelRel, t.FldId, t.FldPId, t.FldState, ' + f + ' '
  + sLineBreak + '    from ' + IvTbl + ' t '
  + sLineBreak + '    where t.FldId = ' + IntToStr(IvId)
  + sLineBreak + '),' // <-- note this!
  + sLineBreak + ''
//+ sLineBreak + '  -- parents'
  + sLineBreak + 'cte1 as ('
  + sLineBreak + '    select 0 as FldLevel, 0 as FldLevelRel, t.FldId, t.FldPId, t.FldState, ' + f + ' ' // anchor
  + sLineBreak + '    from cte t'
  + sLineBreak + ''
  + sLineBreak + '    union all'
  + sLineBreak + ''
//+ sLineBreak + '  -- recursive part, next childs or levels'
  + sLineBreak + '    select 0 as FldLevel, c.FldLevelRel-1 as FldLevelRel, t.FldId, t.FldPId, t.FldState, ' + f + ' '
  + sLineBreak + '    from ' + IvTbl + ' t'
  + sLineBreak + '    inner join cte1 c on (c.FldPId = t.FldId)'
  + sLineBreak + '),' // <-- note this!
  + sLineBreak + ''
//+ sLineBreak + '  -- childs'
  + sLineBreak + 'cte2 as ('
  + sLineBreak + '    select 0 as FldLevel, 0 as FldLevelRel, t.FldId, t.FldPId, t.FldState, ' + f + ' ' // anchor
  + sLineBreak + '    from cte t'
  + sLineBreak + ''
  + sLineBreak + '    union all'
  + sLineBreak + ''
//+ sLineBreak + '  -- recursive part, next childs or levels'
  + sLineBreak + '    select 0 as FldLevel, c.FldLevelRel+1 as FldLevelRel, t.FldId, t.FldPId, t.FldState, ' + f + ' '
  + sLineBreak + '    from ' + IvTbl + ' t'
  + sLineBreak + '    inner join cte2 c on (c.FldId = t.FldPId)'
  + sLineBreak + '    where c.FldLevelRel = 0'
  + sLineBreak + ')'
  + sLineBreak + ''
//+ sLineBreak + '  -- parentsitemchilds'
  + sLineBreak + 'select   FldLevelRel+@l as FldLevel,   FldLevelRel,                                                        null as FldChilds,   FldId,   FldPId,   FldState, ' + IvFldCsv + ' from cte1'
  + sLineBreak + 'union' // <-- note union and not union all, otherwise the "item" will be present two times!
  + sLineBreak + 'select a.FldLevelRel+@l as FldLevel, a.FldLevelRel, (select count(*) from ' + IvTbl + ' where FldPId = a.FldId) as FldChilds, a.FldId, a.FldPId, a.FldState, ' + IvFldCsv + ' from cte2 a where a.FldLevelRel > 0 order by FldLevelRel, ' + a
  ;

  Result := DsFD(q, IvDs, IvFbk);
//LogDs(IvDs); // rimane su eof se si usa FD e quindi spacca tutto!
end;

function TDbaCls.HTreeDs(const IvTbl, IvFld, IvFldCsv: string; const IvId: integer; var IvDs: TDataSet; var IvFbk: string; IvWhere: string): boolean;

  {$REGION 'var'}
{
                              prepended by default so IvFldCsv does not have to contains them                                                          IvFldCsv
<----------------------------------------------------------------------------------------------------------------------------------------------> <-------------------->
FldId  FldPId  FldNumber  FldLevel  FldIndex   FldPath    FldText                         FldIsLeaf  FldState  FldOrder  FldName                | FldCode  FldKind  ...
78     3       12         0         1          \78        WkJs                            0          Active    NULL      WkJs                   |
81     78      1          1         1.1        \78\81         WksStatisticsJs             0          Active    1         WksStatisticsJs        |
82     81      1          2         1.1.1      \78\81\82          WksStatisticsDistribJs  1          Active    NULL      WksStatisticsDistribJs |
80     78      2          1         1.2        \78\80         WksSpcJs                    1          Active    2         WksSpcJs               |
79     78      3          1         1.3        \78\79         WksWaferJs                  1          Active    3         WksWaferJs             |
83     78      4          1         1.4        \78\83         WksHeatMapJs                1          Active    4         WksHeatMapJs           |

table required fields: FldId, FldPId, FldState, FldOrder, FldName

use: http://localhost/WksCodeIsapiProject.dll/Library?CoLibraryId=78
}
var
  q, n, f, g, w: string; // sql, fieldname, fieldlist, fieldlist2, where
  {$ENDREGION}

begin
  n := IvFld;
  f := Format(', %s, %s', [n, IvFldCsv]);
  g := str.Replace(f, ', Fld', ', ng.Fld');
  w := iif.ExP(IvWhere, 'where ');
  q :=
    sLineBreak + 'with'
//+ sLineBreak + '  -- same level siblings numbering'
  + sLineBreak + '  numbered(FldId, FldPId, FldNumber, FldState, FldOrder' + f + ') as ('
  + sLineBreak + '    select FldId, FldPId, row_number() over (partition by FldPId order by FldOrder, ' + n + ') as FldNumber, FldState, FldOrder' + f
  + sLineBreak + '    from ' + IvTbl
  + sLineBreak + '  )'
//+ sLineBreak + '  -- recursive cte'
  + sLineBreak + ', childs (FldId, FldPId, FldNumber, FldLevel, FldIndex, FldPath, FldState, FldOrder' + f + ') as ('
//+ sLineBreak + '  -- fixed part, anchor, 1st generation or level'
  + sLineBreak + '    select FldId, FldPId, FldNumber, 0, cast(FldNumber as varchar(max)), ''\'' + convert(varchar(max), FldId), FldState, FldOrder' + f
  + sLineBreak + '    from numbered as fg'        // firstgeneration
  + sLineBreak + '    where FldId = ' + IntToStr(IvId) // root
  + sLineBreak + '    union all'
//+ sLineBreak + '  -- recursive part, next childs or levels'
  + sLineBreak + '    select ng.FldId, ng.FldPId, ng.FldNumber, pa.FldLevel+1' + ', cast(case when pa.FldIndex = '''' then(cast(ng.FldNumber as varchar(max))) else (pa.FldIndex + ''.'' + cast(ng.FldNumber as varchar(max))) end as varchar(max)), pa.FldPath + ''\'' + convert(varchar(max), ng.FldId), ng.FldState, ng.FldOrder' + g
  + sLineBreak + '    from numbered as ng'        // nextgeneration
  + sLineBreak + '    inner join childs as pa'         // references the whole cte as parent
  + sLineBreak + '    on (ng.FldPId = pa.FldId)'
  + sLineBreak + '  )'
  + sLineBreak + ''
//+ sLineBreak + '-- statement that call the cte'
  + sLineBreak + 'select FldId, FldPId, FldNumber, FldLevel, FldIndex, FldPath, space((FldLevel)*4) + ' + n + ' as FldText, 0 as FldIsLeaf, FldState, FldOrder' + f
  + sLineBreak + 'from childs'
  + sLineBreak + w
  + sLineBreak + 'order by FldIndex'
  + sLineBreak + 'option(maxrecursion 32767)' // in calling the cte, by default it is 100
  ;
  Result := DsFD(q, IvDs, IvFbk);
//lg.Ds(IvDs); // rimane su eof se si usa FD e quindi spacca tutto!
end;

function TDbaCls.ImgPictureFromDba(IvPicture: TPicture; const IvTable, IvImageField, IvWhere: string; var IvFbk: string; IvImageNameDefault: string): boolean;
var
  q: string;
begin

  {$REGION 'Exit'}
  Result := Assigned(IvPicture);
  if not Result then begin
    IvFbk := 'Unable to get picture from db, IvPicture is not assigned';
    Exit;
  end;

  Result := (IvTable <> '') and (IvImageField <> '') and (IvWhere <> '');
  if not Result then begin
    IvFbk := 'Unable to get picture from db, IvTable or IvImageField or IvWhere are empty';
    Exit;
  end;
  {$ENDREGION}

  {$REGION 'Go'}
  q := Format('select %s from %s %s', [IvImageField, IvTable, sql.WhereEnsure(IvWhere)]);
  Result := ImgPictureFromDba(IvPicture, q, IvImageField, IvFbk, IvImageNameDefault);
  {$ENDREGION}

end;

function TDbaCls.ImgPictureFromSql(IvPicture: TPicture; const IvSql, IvImageField: string; var IvFbk: string; IvImageNameDefault: string): boolean;
//var
//  q: string;
//  m: TMemoryStream;
begin
  // TEMPORARYCOMMENT
  (*

  {$REGION 'Exit'}
  Result := Assigned(IvPicture);
  if not Result then begin
    IvFbk := 'Unable to get picture from db, IvPicture is not assigned';
    Exit;
  end;

  Result := (IvSql <> '') and (IvImageField <> '');
  if not Result then begin
    IvFbk := 'Unable to get picture from db, IvSql or IvImageField are empty';
    Exit;
  end;
  {$ENDREGION}

  {$REGION 'Go'}
  try
    m := TMemoryStream.Create;
    try
      Result := ImgStreamFromSql(m, IvSql, IvImageField, IvFbk);
      if not Result then begin // use default picture
        if IvImageNameDefault = '' then
          Result := bmp.DrawSyntetic(IvPicture, 'Random', 200, 200, '', IvFbk) // Blank
        else
          Result := ImgPictureFromDba(IvPicture, 'DbaImage.dbo.TblImage', 'FldBinary', Format('FldImage = ''%s''', [IvImageNameDefault]), IvFbk);
      end else
        Result := pic.FromStream(IvPicture, m, IvFbk);

      if not Result then begin // use default picture
        bmp.Dummy(IvPicture.Bitmap, IvFbk);
        Result := true;
      end;
    finally
      m.Free;
    end;
  except
    on e: Exception do begin
      IvFbk := e.Message;
      Result := false;
    end;
  end;
  {$ENDREGION}

  *)
end;

function TDbaCls.ImgStreamFromSql(IvImgMemoryStream: TMemoryStream; const IvSql, IvImageField: string; var IvFbk: string): boolean;
var
  f: string;
  d: TFDDataSet;
  b: TField; // blobfield
  s: TStream; // TBlobStream blobstream
begin
  // default
  f := iif.NxD(IvImageField, 'FldImage');

  {$REGION 'Exit'}
  Result := Assigned(IvImgMemoryStream);
  if not Result then begin
    IvFbk := 'Unable to load image memory stream from db, it is not assigned';
    Exit;
  end;

  Result := iis.Ex(IvSql);
  if not Result then begin
    IvFbk := 'Unable to load image memory stream from db, sql query is empty';
    Exit;
  end;

  Result := IvSql.Contains(f);
  if not Result then begin
    IvFbk := Format('Unable to load image memory stream from db, sql query doesnt contains %s field', [f]);
    Exit;
  end;
  {$ENDREGION}

  {$REGION 'Go'}
  try

    try
      Result := DsFD(IvSql, d, IvFbk, true);
      if not Result then
        Exit;

      // load
      Result := not d.Eof;
      if not Result then begin
        IvFbk := 'Unable to load memory stream, query result from database is empty';
      end else begin
        b := d.FieldByName(f);
        s := TStream.Create;
        try
          s := d.CreateBlobStream(b, bmRead{Write}); // if s.Size = 0 then ...
          Result := s.Size > 0;
          if not Result then begin
            IvFbk := 'Unable to load image memory stream, blob from database is empty';
            Exit;
          end else begin
            s.Position := 0;
            IvImgMemoryStream.LoadFromStream(s);
            IvFbk := Format('Image memory stream loaded with db blob with size %d', [s.Size]); //+ iif.Str(d.RecordCount = 1, '', Format(' (WARNING: query result has %d records, should be just 1)', [d.RecordCount]));
          end;
        finally
          s.Free;
        end;
      end;

    finally
      d.Close;
      FreeAndNil(d);
    end;

  except
    on e: Exception do begin
      IvFbk := e.Message;
      Result := false;
    end;
  end;
  {$ENDREGION}

end;

function TDbaCls.RecExists(const IvTbl, IvWhereFld, IvWhereValue: string; var IvFbk: string; IvCaseSensitive: boolean): boolean;
var
  w, q: string; // casesensitive
begin
  w := Format('%s = ''%s''', [IvWhereFld, IvWhereValue]);
  if IvCaseSensitive then
    w := w + ' collate sql_latin1_general_cp1_cs_as';
  q := Format('select case when exists(select * from %s where %s) then 1 else 0 end as FldResult', [IvTbl, w]);
  Result := ScalarFD(q, 0, IvFbk) >= 1;
end;

function TDbaCls.RecExists(const IvTbl, IvWhere: string; var IvFbk: string; IvCaseSensitive: boolean): boolean;
var
  w, q: string; // casesensitive
begin
  w := IvWhere;
  if IvCaseSensitive then
    w := w + ' collate sql_latin1_general_cp1_cs_as';
  q := Format('select case when exists(select * from %s where %s) then 1 else 0 end as FldResult', [IvTbl, w]);
  Result := ScalarFD(q, 0, IvFbk) >= 1;
end;

function TDbaCls.RecInsert(const IvTbl, IvInsertSqlWithParams: string; const IvVeParamValue: array of const; var IvIdNew: integer; var IvFbk: string): boolean;
var
  c: TFDCommand;
  i: integer;
begin
  // idnew
  IvIdNew := TblIdNext(IvTbl);

  // command
  c := TFDCommand.Create(nil);
  c.Connection := FConnFD;
  c.CommandText.Text := IvInsertSqlWithParams;
  try
    try
      // params
      c.Params.ParamByName('PId').Value := IvIdNew;                 // :PId must be the 0th param
      for i := {0}1 to c.Params.Count - 1 do                        // *** CHECK AT 1ST USAGE ***
        c.Params[i].Value := vnt.RecToVar(IvVeParamValue[i]);

      // exec
      c.Execute;

      // end
      IvFbk := Format('New record with id %d inserted in %s', [IvIdNew, IvTbl]);
      Result := true;
    except
      on e: Exception do begin
        IvFbk := Format('EXCEPTION: %s (%s)', [e.Message, str.OneLine(c.CommandText.Text)]);
        Result := false;
      end;
    end;
  finally
    FreeAndNil(c);
  end;
end;

function TDbaCls.RecInsertSimple(const IvTbl: string; const IvValueVe: array of const; var IvFbk: string): boolean;
var
  t: TFDTable;
begin
  t := TFDTable.Create(nil);
  t.Connection := FConnFD;
  t.TableName := IvTbl;
  t.Open;
  try
    try
      t.InsertRecord(IvValueVe);
      IvFbk:= 'Record inserted';
      Result := true;
    except
      on e: Exception do begin
        IvFbk := Format('EXCEPTION: %s', [e.Message]);
        Result := false;
      end;
    end;
  finally
    t.Close;
    FreeAndNil(t);
  end;
end;
(*
function  TDbaCls.ScalarADO(const IvSql: string; const IvDefault: variant; var IvFbk: string; IvTimeOutSec: integer): variant;
var
  r: _Recordset;
begin
  try
    FConnADO.timeout := IvTimeOutSec;
    r := FConnADO.Execute(IvSql);
    try
      if r.RecordCount = 0 then
        Result := IvDefault
      else begin
        Result := r.Fields[0].Value;
      //if Result = Unassigned then
        //Result := IvDefault;
        if Result = Null then
          Result := IvDefault;
        IvFbk := Format('Scalar: %s', [VarToStr(Result)]);
      end;
    finally
      r.Close;
      r := nil;
    end;
  except
    on e: Exception do begin
      Result := IvDefault;
      IvFbk := e.Message;
      lg.E(e);
      lg.Q(IvSql);
      raise;
    end;
  end;
end;
*)
function TDbaCls.ScalarFD(const IvSql: string; var IvResult: variant; const IvDefault: variant; var IvFbk: string; IvTimeOutSec: integer): boolean;
var
  v: variant;
  t: word; // type
begin
  try
    FConnFD.ResourceOptions.CmdExecTimeout := IvTimeOutSec;
    v := FConnFD.ExecSQLScalar(IvSql);
    t := VarType(v);
             if t = 3   then begin        // integer
      IvResult := v;
      Result := true;

    end else if t = 271 then begin        // SQLTimeStampVariantType
      IvResult := VarAsType(v, varDate);
      Result := true;

    end else if v = Unassigned then begin // if t = 3 and v = 0 -> v will appear Unassigned !!!
      IvResult := IvDefault;
      Result := true;

    end else if v = null then begin       //
      IvResult := IvDefault;
      Result := true;

    end else begin                        // all oter cases
      IvResult := v;
      Result := true;
    end;
    IvFbk := Format('Scalar: %s', [VarToStr(IvResult)]);
  except
    on e: Exception do begin
      IvResult := IvDefault;
      IvFbk := Format('EXCEPTION: %s (%s)', [e.Message, str.OneLine(IvSql)]);
      Result := false;
    end;
  end;
end;

function TDbaCls.ScalarFD(const IvSql: string; IvDefault: variant; var IvFbk: string; IvTimeOutSec: integer): variant;
begin
  ScalarFD(IvSql, Result, IvDefault, IvFbk, IvTimeOutSec);
end;

function TDbaCls.Tbl(const IvDatabaseName, IvTableName: string): string;
begin
  Result := 'Dba' + IvDatabaseName + '.dbo.' + 'Fld' + IvTableName;
end;

function TDbaCls.TblCreate(const IvDba, IvTbl, IvFldDefBlock: string; var IvFbk: string): boolean;
var
  q: string;
  z: integer;
begin;
  q := Format(   'create table %s.dbo.%s(', [IvDba, IvTbl])
               + IvFldDefBlock
  + sLineBreak + ')'
//+ sLineBreak + Format('alter table %s add constraint [DF_%t_FldUId] default (newid()) for [FldUId]', [t, t])
  ;
//lgQ(q);
  Result := ExecFD(q, z, IvFbk);
end;

function TDbaCls.TblCreateIfNotExists(const IvDba, IvTbl, IvFldDefBlock: string; var IvFbk: string): boolean;
var
  t: string;
begin
  t := Format('%s.dbo.%s', [IvDba, IvTbl]);
  if not TblExists(IvDba, IvTbl, IvFbk) then begin
    IvFbk := Format('%s does not exists, create it now', [t]);
    Result := TblCreate(IvDba, IvTbl, IvFldDefBlock, IvFbk);
  end else begin
    IvFbk := fbk.ExistsStr('Table', t, true);
    Result := false; // not created, already exists
  end;
end;

function TDbaCls.TblExists(const IvDba, IvTbl: string; var IvFbk: string): boolean;
var
  q: string;
  z: integer;
begin
  // igi
  q := Format('select case when exists(select * from %s.sys.tables where name = ''%s'' and type = ''U'') then 1 else 0 end as FldResult', [IvDba, IvTbl]);
//lg.Q(q);
  Result := ScalarFD(q, 0, IvFbk) = 1;
  IvFbk := fbk.ExistsStr('Table', IvTbl, Result);

  // emb
//try
//  q := Format('select * from %s.dbo.%s where 0 = 1', [IvDba, IvTbl]);
//  Result := ExecFD(q, z, IvFbk);
//except
//  on e: EFDDBEngineException do
//    if e.Kind = ekObjNotExists then
//      Result := false
//    else
//      raise;
//end;
end;

function TDbaCls.TblIdAvailable(const IvTbl: string; IvWhere: string): integer;
var
  q, k: string;
begin
  if iis.Nx(IvWhere) then
    q := Format('select l.FldId + 1 as FldIdAvailable from %s as l left outer join %s as r on l.FldId + 1 = r.FldId where r.FldId is null', [IvTbl, IvTbl])
  else
    q := Format('with cte(FldId) as (select FldId from %s %s) select l.FldId + 1 as FldIdAvailable from cte as l left outer join cte as r on (l.FldId + 1 = r.FldId) where r.FldId is null', [IvTbl, IvWhere]);
  Result := ScalarFD(q, 0, k);
end;

function TDbaCls.TblIdBounds(const IvTbl: string; var IvIdMin, IvIdMax: integer; var IvFbk: string): boolean;
var
  q: string;
  d: TFDDataSet;
begin
  try
    // sql
    q := Format('select min(FldId), max(FldId) from %s', [IvTbl]);
  //lg.Q(q);

    // ds
    Result := DsFD(q, d, IvFbk);
    if not Result then
      Exit;

    // bounds
    IvIdMin := d.Fields[0].AsInteger;
    IvIdMax := d.Fields[1].AsInteger;
  //lg.IFmt('%s FldId bounds: %d, %d', [IvTbl, IvIdMin, IvIdMax]);
  finally
    d.Close;
    FreeAndNil(d);
  end;
end;

function TDbaCls.TblIdExists(const IvTbl: string; const IvId: integer; var IvFbk: string): boolean;
var
  q: string;
  i: integer;
begin
  // sql
  q := Format('select FldId from %s', [IvTbl]);
//lg.Q(q);

  // id
  i := ScalarFD(q, null, IvFbk);
  Result := i = IvId;
  IvFbk := fbk.ExistsStr('Id', i.ToString, Result);
end;

function TDbaCls.TblIdMax(const IvTbl: string; IvWhere: string): integer;
var
  q, k: string;
begin
  q := Format('select max(FldId) as FldIdMax from %s', [IvTbl]);
  sql.WhereAppend(q, IvWhere);
  Result := ScalarFD(q, 0, k);
end;

function TDbaCls.TblIdNext(const IvTbl: string; IvWhere: string): integer;
begin
  // using max
//Result := TblIdMax(IvTbl);
//if Result > -1 then
//  Result := Result + 1;

  // using starting number of missed blocks
  Result := TblIdAvailable(IvTbl, IvWhere);
end;

function TDbaCls.TblIndexCreate(const IvDba, IvTbl, IvIdx, IvIdxDefBlock: string; var IvFbk: string): boolean;
var
  q: string;
  z: integer;
begin
  q :=           Format('create nonclustered index %s(', [IvIdx])
  + sLineBreak + Format('on %s.dbo.%s (', [IvDba, IvTbl])
//+ sLineBreak + '    FldId           asc'
//+ sLineBreak + '  , FldState        asc'
//+ sLineBreak + '  , FldOrganization asc'
//+ sLineBreak + '  , FldMember       asc'
//+ sLineBreak + '  , FldSetting      asc'
               + IvIdxDefBlock
  + sLineBreak + ')';
//lg.Q(q);
  Result := ExecFD(q, z, IvFbk);
end;
{$ENDREGION}

{$REGION 'TDotRec'}
function TDotRec.Dba(IvDotOrDbaTblFld: string): string;
begin
  if IvDotOrDbaTblFld.Contains('.dbo.') then
    Result := str.LeftOf('.dbo.', IvDotOrDbaTblFld)
  else
    Result := str.LeftOf('.', IvDotOrDbaTblFld);
  Result := str.HeadAdd(Result, 'Dba');
end;

function TDotRec.Dot(IvObjOrDba, IvSubOrTbl, IvPropOrFld: string): string;
begin
  Result := str.HeadRemove(IvObjOrDba, 'Dba') + '.' + str.HeadRemove(IvSubOrTbl, 'Tbl') + '.' + str.HeadRemove(IvPropOrFld, 'Fld');
end;

procedure TDotRec.Dtf(IvDotOrDbaTblFld: string; var IvDba, IvTbl, IvFld: string);
begin
  IvDba := Dba(IvDotOrDbaTblFld);
  IvTbl := Tbl(IvDotOrDbaTblFld);
  IvFld := Fld(IvDotOrDbaTblFld);
end;

function TDotRec.Field(IvDotOrDbaTblFld: string): string;
begin
  Result := Fld(IvDotOrDbaTblFld);
end;

function TDotRec.Fld(IvDotOrDbaTblFld: string): string;
begin
  if IvDotOrDbaTblFld.Contains('.Fld') then
    Result := str.RightOf('.Fld', IvDotOrDbaTblFld)
  else
    Result := str.RightOf('.', IvDotOrDbaTblFld, true);
  Result := str.HeadAdd(Result, 'Fld');
end;

function TDotRec.IsValid(IvDot: string; var IvFbk: string): boolean;
begin
  Result := IvDot.CountChar('.') = 2;
  if not Result then
    IvFbk := IvDot + 'is invalid, use like: Object.Subject.Property, i.e.: Person.Person.Name'
  else
    IvFbk := IvDot + 'is valid';
end;

function TDotRec.Obj(IvDotOrDbaTblFld: string): string;
begin
  Result := str.HeadRemove(Dba(IvDotOrDbaTblFld), 'Dba');
end;

procedure TDotRec.Osp(IvDotOrDbaTblFld: string; var IvObj, IvSub, IvProp: string);
begin
  IvObj  := Obj (IvDotOrDbaTblFld);
  IvSub  := Sub (IvDotOrDbaTblFld);
  IvProp := Prop(IvDotOrDbaTblFld);
end;

function TDotRec.Prop(IvDotOrDbaTblFld: string): string;
begin
  Result := str.HeadRemove(Fld(IvDotOrDbaTblFld), 'Fld');
end;

function TDotRec.Sub(IvDotOrDbaTblFld: string): string;
begin
  Result := str.HeadRemove(Tbl(IvDotOrDbaTblFld), 'Tbl');
end;

function TDotRec.Table(IvDotOrDbaTblFld: string): string;
begin
  Result := Dba(IvDotOrDbaTblFld) + '.dbo.' + Tbl(IvDotOrDbaTblFld);
end;

function TDotRec.Tbl(IvDotOrDbaTblFld: string): string;
begin
  if IvDotOrDbaTblFld.Contains('.dbo.') then
    Result := str.Between('.dbo.', '.Fld', IvDotOrDbaTblFld)
  else if IvDotOrDbaTblFld.CountChar('.') = 2 then
    Result := str.Between('.', '.', IvDotOrDbaTblFld)
  else
    Result := str.RightOf('.', IvDotOrDbaTblFld);
  Result := str.HeadAdd(Result, 'Tbl');
end;
{$ENDREGION}

{$REGION 'TFbkRec'}
procedure TFbkRec.Add(IvString: string);
begin
  Text := Text + sLineBreak + IvString;
end;

procedure TFbkRec.AddFmt(IvFormatString: string; IvVarRecVector: array of TVarRec);
begin
  Add(Format(IvFormatString, IvVarRecVector));
end;

function TFbkRec.ExistsStr(IvObj, IvName: string; IvBoolean: boolean): string;
begin
  if IvBoolean then
    Result := Format('%s %s exists', [IvObj, IvName])
  else
    Result := Format('%s %s does not exists', [IvObj, IvName]);
end;

function TFbkRec.IsActiveStr(IvObj, IvName: string; IvBoolean: boolean): string;
begin
  if IvBoolean then
    Result := Format('%s %s is active', [IvObj, IvName])
  else
    Result := Format('%s %s is not active', [IvObj, IvName]);
end;

function TFbkRec.IsAuthenticatedStr(IvObj, IvName: string; IvBoolean: boolean): string;
begin
  if IvBoolean then
    Result := Format('%s %s is authenticated', [IvObj, IvName])
  else
    Result := Format('%s %s is not authenticated', [IvObj, IvName]);
end;

function TFbkRec.IsLoggedStr(IvObj, IvName: string; IvBoolean: boolean): string;
begin
  if IvBoolean then
    Result := Format('%s %s is logged', [IvObj, IvName])
  else
    Result := Format('%s %s is not logged', [IvObj, IvName]);
end;

function TFbkRec.IsSecureStr(IvObj, IvName: string; IvBoolean: boolean): string;
begin
  if IvBoolean then
    Result := Format('%s %s is secure', [IvObj, IvName])
  else
    Result := Format('%s %s is not secure', [IvObj, IvName]);
end;

function TFbkRec.IsValidStr(IvObj, IvName: string; IvBoolean: boolean): string;
begin
  if IvBoolean then
    Result := Format('%s %s is valid', [IvObj, IvName])
  else
    Result := Format('%s %s is not valid', [IvObj, IvName]);
end;

procedure TFbkRec.Reset;
begin
  Text :=  '';
end;
{$ENDREGION}

{$REGION 'TFsyRec'}
function TFsyRec.DirChose(IvDirToStart, IvDirDefault: string; var IvDirChosen, IvFbk: string): boolean;
//var
//g: TFileOpenDialog;
begin
  // i
{
//if Win32MajorVersion >= 6 then begin
    g := TFileOpenDialog.Create(nil);
    try
      g.Title := 'Select Directory';
      g.Options := [fdoPickFolders, fdoPathMustExist, fdoForceFileSystem];
      g.OkButtonLabel := 'Select';
      g.DefaultFolder := IvDirToStart;
      g.FileName := IvDirToStart;
      Result := g.Execute;
      if Result then
        IvDirChosen := g.FileName
      else
        IvDirChosen := IvDirDefault;
      IvFbk := 'selected dir is ' + IvDirChosen;
    finally
      FreeAndNil(g);
    end
//end else if SelectDirectory('Select Directory', ExtractFileDrive(d), d, [sdNewUI, sdNewFolder]) then // Vcl.FileCtrl // old
  //Result := d;

  // ii
  with TBrowseForFolder.Create(nil) do try
    RootDir  := IvDirToStart;
    if Execute then
      IvDirChosen := Folder;
  finally
    Free;
  end;
}
  // iii
  with TOpenDialog.Create(nil) do
    try
    //Options := [];
      InitialDir := IvDirToStart;
      Result := Execute;
      if Result then
        IvDirChosen := ExtractFilePath(FileName)
      else
        IvDirChosen := IvDirDefault;
    finally
      Free;
    end;
end;

function TFsyRec.DirCreate(IvDir: string; var IvFbk: string): boolean;
begin
  // exit
  Result := System.SysUtils.DirectoryExists(IvDir);
  if Result then begin
    IvFbk := Format('Directory %s already exists', [IvDir]);
    Exit;
  end;

  // create
  Result := System.SysUtils.ForceDirectories(IvDir);
  if not Result then
    IvFbk := Format('Unable to create directory %s, %s', [IvDir, IntToStr(GetLastError)])
  else
    IvFbk := Format('Directory %s created', [IvDir]);
end;

function TFsyRec.DirDelete(IvPath: string; var IvFbk: string): boolean;
var
  i: TSHFileOpStruct; // shellinfo
begin
  IvFbk := '';

  // i
//Result := RemoveDir(IvPath); //or RmDir(IvPath)

  // ii
  ZeroMemory(@i, SizeOf(i));
  with i do begin
    wFunc  := FO_DELETE;
    fFlags := FOF_SILENT or FOF_NOCONFIRMATION;
    pFrom  := PChar(IvPath + #0);
  end;
  Result := (0 = ShFileOperation(i));
end;

function TFsyRec.DirExists(IvDir: string; var IvFbk: string): boolean;
begin
  Result := System.SysUtils.DirectoryExists(IvDir);
  if Result then
    IvFbk := 'Directory exists'
  else
    IvFbk := 'Directory does not exists';
end;

function TFsyRec.DirOpen(IvPath: string; var IvFbk: string): boolean;
var
  r: uint64;
begin
  // do
  r := ShellExecute(
    Application.Handle // hwnd
  , PChar('explore')   // lpOperation [edit,explore,find,open,print,nil]
  , PChar(IvPath)      // lpFile
  , nil                // lpParameters
  , nil                // lpDirectory
  , SW_SHOWNORMAL      // nShowCmd
  );

  // fbk
  case r of
  0:                      IvFbk := 'The operating system is out of memory or resources.';
//ERROR_FILE_NOT_FOUND:   IvFbk := 'The specified file was not found.';
//ERROR_PATH_NOT_FOUND:   IvFbk := 'The specified path was not found.';
  ERROR_BAD_FORMAT:       IvFbk := 'The .exe file is invalid (non-Win32 .exe or error in .exe image).';
  SE_ERR_ACCESSDENIED:    IvFbk := 'The operating system denied access to the specified file.';
  SE_ERR_ASSOCINCOMPLETE: IvFbk := 'The file name association is incomplete or invalid.';
  SE_ERR_DDEBUSY:         IvFbk := 'The DDE transaction could not be completed because other DDE transactions were being processed.';
  SE_ERR_DDEFAIL:         IvFbk := 'The DDE transaction failed.';
  SE_ERR_DDETIMEOUT:      IvFbk := 'The DDE transaction could not be completed because the request timed out.';
  SE_ERR_DLLNOTFOUND:     IvFbk := 'The specified DLL was not found.';
  SE_ERR_FNF:             IvFbk := 'The specified file was not found.';
  SE_ERR_NOASSOC:         IvFbk := 'There is no application associated with the given file name extension. This error will also be returned if you attempt to print a file that is not printable.';
  SE_ERR_OOM:             IvFbk := 'There was not enough memory to complete the operation.';
  SE_ERR_PNF:             IvFbk := 'The specified path was not found.';
  SE_ERR_SHARE:           IvFbk := 'A sharing violation.';
  end;

  // return
  Result := r > 32; // if the function succeeds, it returns a value greater than 32
end;

function TFsyRec.FileAccessed(IvFile: string): TDateTime;
var
  a: TWin32FileAttributeData;
begin
  if not GetFileAttributesEx(PChar(IvFile), GetFileExInfoStandard, @a) then
    RaiseLastOSError;
  Result := FileTimeToDateTime(a.ftLastAccessTime);
end;

function TFsyRec.FileAttrArchiveSet(IvFile: string; var IvFbk: string): boolean;
begin
  {$WARN SYMBOL_PLATFORM OFF}
  Result := FileSetAttr(IvFile, faArchive) = 0;
  {$WARN SYMBOL_PLATFORM ON}
  if Result then
    IvFbk := Format('File %s set with archive attr', [IvFile])
  else
    IvFbk := Format('Unable to set file %s with archive attr (remove eventual read only attr)', [IvFile]);
end;

function TFsyRec.FileAttrReadOnlySet(IvFile: string; var IvFbk: string): boolean;
begin
  {$WARN SYMBOL_PLATFORM OFF}
  Result := FileSetAttr(IvFile, FileGetAttr(IvFile) or System.SysUtils.faReadOnly) = 0;
  {$WARN SYMBOL_PLATFORM ON}
  if Result then
    IvFbk := Format('File %s set to read only', [IvFile])
  else
    IvFbk := Format('Unable to set file %s to read only', [IvFile]);
end;

function TFsyRec.FileCreate(IvFile, IvText: string): boolean;
var
  l: TStringList;
begin
  l := TStringList.create;
  try
    l.Text := IvText;
    try
      l.SaveToFile(IvFile);
      Result := true;
    except
      on e: Exception do begin
        Result := false;
        raise;
      end;
    end;
  finally
    l.Free
  end;
end;

function TFsyRec.FileCreated(IvFile: string): TDateTime;
var
  a: TWin32FileAttributeData;
begin
  if not GetFileAttributesEx(PChar(IvFile), GetFileExInfoStandard, @a) then
    RaiseLastOSError;
  Result := FileTimeToDateTime(a.ftCreationTime);
end;

function TFsyRec.FileDelete(IvFile: string; var IvFbk: string): boolean;
begin
  Result := DeleteFile(IvFile);
  if Result then
    IvFbk := 'File deleted'
  else
    IvFbk := 'Unable to delete file';
end;

function TFsyRec.FileExists(IvFile: string; var IvFbk: string): boolean;
begin
  Result := System.SysUtils.FileExists(IvFile);
  if Result then
    IvFbk := 'File exists'
  else
    IvFbk := 'File does not exists';
end;

procedure TFsyRec.FileFromByteArray(const IvByteArray: TByteDynArray; const IvFileName: string);
var
  z: integer; // counter
  f: file of byte;
  p: pointer;
begin
  AssignFile(f, IvFileName);
  Rewrite(f);
  try
    z := Length(IvByteArray);
    p := @IvByteArray[0];
    BlockWrite(f, p^, z);
  finally
    CloseFile(f);
  end;
end;

function TFsyRec.FileMimeType(IvFile: string): string;
begin
  Result := mim.FromFile(IvFile); // FromRegistry
end;

function TFsyRec.FileModified(IvFile: string): TDateTime;
var
  a: TWin32FileAttributeData;
begin
  if not GetFileAttributesEx(PChar(IvFile), GetFileExInfoStandard, @a) then
    RaiseLastOSError;
  Result := FileTimeToDateTime(a.ftLastWriteTime);
end;

function TFsyRec.FileName(IvFile: string): string;
begin
  Result := ExtractFileName(IvFile);
end;

function TFsyRec.FileNameDotExt(IvFile: string): string;
begin
  Result := ExtractFileName(IvFile);
end;

function TFsyRec.FileSizeBytes(IvFile: string): int64;
var
//s: TFileStream;
  r: TSearchRec;
begin
  // i
//s := TFileStream.Create(IvFile, fmOpenRead);
//try
//  s.Position := 0;
//  Result := s.Size;
//finally
//  FreeAndNil(s);
//end;

  // ii
  if FindFirst(IvFile, faAnyFile{ $01+$04+$20 }, r ) = 0 then
  {$IFDEF MSWINDOWS}
    // here you can access the FindData member because you are on Windows
    {$WARN SYMBOL_PLATFORM OFF}
  //Result := r.Size // for normal size
    Result := Int64(r.FindData.nFileSizeHigh) shl Int64(32) + Int64(r.FindData.nFileSizeLow) // for file bigger than 2Gb
    {$WARN SYMBOL_PLATFORM ON}
  {$ELSE}
    Result := -1
  // here you can't use FindData member and you would even get the compiler error because
  // the FindData member is Windows specific and you are now on different platform
  {$ENDIF}
  else
    Result := -1;
  FindClose(r);
end;

function TFsyRec.FileTimeToDateTime(const IvFileTime: TFileTime): TDateTime;
var
  s, l: TSystemTime; // systemtime, localtime
begin
  if not FileTimeToSystemTime(IvFileTime, s) then
    RaiseLastOSError;
  if not SystemTimeToTzSpecificLocalTime(nil, s, l) then
    RaiseLastOSError;
  Result := SystemTimeToDateTime(l);
end;

function TFsyRec.FileToByteArray(IvFile: string): TByteDynArray;
const
  BLOCK_SIZE = 1024;
var
  br, bw, z: integer; // bytesread, bytestowrite
  f: file of byte;
  p: pointer;
begin
  AssignFile(f, IvFile);
  Reset(f);
  try
    z := System.FileSize(f);
    SetLength(Result, z);
    p := @Result[0];
    br := BLOCK_SIZE;
    while (br = BLOCK_SIZE) do begin
      bw := mat.Min2(z, BLOCK_SIZE);
      BlockRead(f, p^, bw, br);
      p := Pointer(LongInt(p) + BLOCK_SIZE);
      z := z - br;
    end;
  finally
    CloseFile(f);
  end;
end;

function TFsyRec.FileVer(IvFile: string): string;
var
  f: string; // filespec
  s: dword; // buffersize
  d: dword; // dummy
  b: pointer; // buffer
  i: pointer; // fileinfo
  v: array[1..4] of word;
begin
  // default
  Result := '?.?.?.?';

  // exit
  f := Trim(IvFile);
  if iis.Nx(f) then
    Exit;
  if not System.SysUtils.FileExists(f) then
    Exit;

  // versioninfosize
  s := GetFileVersionInfoSize(PChar(f), d);
  if s = 0 then
    Exit;

  // continue
  GetMem(b, s);
  try
    // get fixed file info (language independent)
    GetFileVersionInfo(PChar(f), 0, s, b);
    VerQueryValue(b, '\', i, d);
    // read version blocks
    v[1] := HiWord(PVSFixedFileInfo(i)^.dwFileVersionMS);
    v[2] := LoWord(PVSFixedFileInfo(i)^.dwFileVersionMS);
    v[3] := HiWord(PVSFixedFileInfo(i)^.dwFileVersionLS);
    v[4] := LoWord(PVSFixedFileInfo(i)^.dwFileVersionLS);
  finally
    FreeMem(b);
  end;

  // return
  Result := Format('%d.%d.%d.%d', [v[1], v[2], v[3], v[4]]);
end;
{$ENDREGION}

{$REGION 'THttRec'}
function THttRec.Get(IvUrl: string; var IvContent, IvFbk: string): boolean;
var
  s: THTTPSend;
  g: TStringList;
begin
  // http
  s := THTTPSend.Create;
  g := TStringList.Create;
  try
    try
      s.HTTPMethod('GET', ansistring(IvUrl));
      g.LoadFromStream(s.Document);
      IvContent := g.Text;
      IvFbk  := OK_STR;
      Result := true;
    except
      on E: Exception do begin
        IvFbk := 'Unable to get Internet http content. ' + E.Message;
        Result := false;
      end;
    end;
  finally
    FreeAndNil(s);
    FreeAndNil(g);
  end;
end;
{$ENDREGION}

{$REGION 'TIifRec'}
function TIifRec.BFR(IvTest: boolean; IvReturn: string): string;
begin
  if not IvTest then
    Result := IvReturn
  else
    Result := '';
end;

function TIifRec.BTR(IvTest: boolean; IvReturn: string): string;
begin
  if IvTest then
    Result := IvReturn
  else
    Result := '';
end;

function TIifRec.Even(IvInteger: integer; IvValueEven, IvValueOdd: string): string;
begin
  if (IvInteger mod 2) = 0 then
    Result := IvValueEven
  else
    Result := IvValueOdd;
end;

function TIifRec.ExA(IvString, IvAppend: string): string;
begin
  if IvString.Trim <> '' then
    Result := IvString + IvAppend
  else
    Result := '';
end;

function TIifRec.ExF(IvString, IvFormat: string; IvVec: array of TVarRec): string;
begin
  if IvString.Trim <> '' then
    Result := Format(IvFormat, IvVec)
  else
    Result := '';
end;

function TIifRec.ExF(IvString, IvFormat: string): string;
begin
  Result := ExF(IvString, IvFormat, [IvString]);
end;

function TIifRec.ExP(IvString, IvPrepend: string): string;
begin
  if IvString.Trim <> '' then
    Result := IvPrepend + IvString
  else
    Result := '';
end;

function TIifRec.ExR(IvString, IvReturn: string): string;
begin
  if IvReturn.Trim = '' then
    IvReturn := IvString;

  if IvString.Trim <> '' then
    Result := IvReturn
  else
    Result := '';
end;

function TIifRec.ExS(IvString, IvPrepend, IvAppend: string): string;
begin
  if IvString.Trim <> '' then
    Result := IvPrepend + IvString + IvAppend
  else
    Result := '';
end;

function TIifRec.Int(IvTest: boolean; IvValueTrue, IvValueFalse: integer): integer;
begin
  if IvTest then
    Result := IvValueTrue
  else
    Result := IvValueFalse;
end;

function TIifRec.NullDef(IvVariant, IvDefault: variant): variant;
begin
  if VarIsNull(IvVariant) then
    Result := IvDefault
  else
    Result := IvVariant;
end;

function TIifRec.NxD(IvString, IvDefault: string): string;
begin
  if iis.Nx(IvString) then
    Result := IvDefault
  else
    Result := IvString;
end;

function TIifRec.NxR(IvString: string; IvLength: integer): string;
begin
  Result := NxD(IvString, rnd.Str(IvLength));
end;

function TIifRec.Nzp(IvTest: double; IvStrIfNegative, IvStrIfZero, IvStrIfPositive: string): string;
begin
  if      IvTest < 0 then
    Result := IvStrIfNegative
  else if IvTest = 0 then
    Result := IvStrIfZero
  else
    Result := IvStrIfPositive;
end;

function TIifRec.Str(IvTest: boolean; IvValueTrue, IvValueFalse: string): string;
begin
  if IvTest then
    Result := IvValueTrue
  else
    Result := IvValueFalse;
end;
{$ENDREGION}

{$REGION 'TIisRec'}
function TIisRec.Ex(IvString: string): boolean;
begin
  Result := IvString.Trim <> '';
end;

function TIisRec.Na(IvString: string): boolean;
begin
  IvString := Trim(IvString);
  IvString := StringReplace(IvString, sLineBreak, '', [rfReplaceAll]);
  if IvString = '' then
    Result := true
  else if SameText(IvString, UNDEFINED_STR) then // js objects
    Result := true
//else if SameText(IvString, UNKNOWN_STR) then
  //Result := true
  else if SameText(IvString, NA_STR) then
    Result := true
  else if IvString = #0 then
    Result := true
//else if VarIsNull(IvTest)  then // assigned but null
//  Result := true
//else if VarIsEmpty(IvTest) then // not assignet at all
//  Result := true
//else if VarIsClear(IvTest) then // undefined
//  Result := true
  else
    Result := false;
end;

function TIisRec.Nx(IvString: string): boolean;
begin
  Result := IvString.Trim = '';
end;
{$ENDREGION}

{$REGION 'TImgRec'}

  {$REGION 'Help'}
  (*
    Resampling  AggPas       Relative
    Filter      Filter       Quality
    -------------------------------------
    none        NoFilter     0
                Bilinear
                Hanning
    Box                      10
    Hermite     Hermite      25
                Quadric
                Bicubic
                Catrom
    Triangle                 35
    Bell                     50
                Spline16
                Spline36
                Blackman144
    B-Spline                 70
    Lanczos3                 90
    Mitchell                 100
  *)
  {$ENDREGION}

function TImgRec.DbaInit(var IvFbk: string): boolean;
begin
  raise Exception.Create(NOT_IMPLEMENTED);
end;

function TImgRec.DbaInsert(var IvFbk: string): boolean;
begin
  raise Exception.Create(NOT_IMPLEMENTED);
end;

function TImgRec.DbaSelect(var IvFbk: string): boolean;
begin
  raise Exception.Create(NOT_IMPLEMENTED);
end;

procedure TImgRec.DbaToDisk(IvFile, IvTable, IvField, IvWhere: string);
var
  d, k: string;
  p: TPicture;
begin
  // TEMPORARYCOMMENT
  {
  p := TPicture.Create;
  try
    if db0.ImgPictureFromDba(p, IvTable, IvField, IvWhere, k) then begin
      d := ExtractFileDir(IvFile);
      if not DirectoryExists(d) then
        if not ForceDirectories(d) then
          raise Exception.CreateFmt('Unable to create directory %s', [d]);
      p.SaveToFile(IvFile); // bmp.ToFile(p.Bitmap, IvFile, true, k);
    end;
  finally
    p.Free;
  end;
  }
end;

  {$REGION 'Zzz Dba'}
(*
  {$REGION 'Ddl'}
  IMAGE_IMAGE_TBL_DDL = ''
  + sLineBreak + 'CREATE TABLE ' + IMAGE_IMAGE_TBL + '('
  + sLineBreak + '    [FldId]                         [int]                   NOT NULL'
  + sLineBreak + '  , [FldPId]                        [int]                   NOT NULL'
  + sLineBreak + '  , [FldState]                      [varchar](16)               NULL'
  + sLineBreak + '  , [FldName]                       [varchar](32)               NULL'
  + sLineBreak + '  , [FldSynonym]                    [varchar](128)              NULL'
  + sLineBreak + '  , [FldIcon]                       [image]                     NULL'
  + sLineBreak + '  , [FldImage]                      [image]                     NULL'
  + sLineBreak + '  , [FldSvg]                        [varchar](max)              NULL'
  + sLineBreak + '  , [FldScript]                     [varchar](max)              NULL'
  + sLineBreak + ')'
  ;
  {$ENDREGION}

  {$REGION 'Sql'}
  IMAGE_IMAGE_SELECT_BY_ID_SQL = ''
  + sLineBreak + ' select'
  + sLineBreak + '     *'
  + sLineBreak + ' from'
  + sLineBreak + '     ' + IMAGE_IMAGE_TBL
  + sLineBreak + ' where'
//+ sLineBreak + '     FldState = ''' + STATE_ACTIVE + ''''
  ;
  IMAGE_IMAGE_INSERT_SQL = ''
  + sLineBreak + ' insert into'
  + sLineBreak + '   ' + IMAGE_IMAGE_TBL + '('
  + sLineBreak + '     FldId'
  + sLineBreak + '   , FldPId'
  + sLineBreak + '   , FldState'
  + sLineBreak + '   , FldName'
  + sLineBreak + '   , FldSynonym'
  + sLineBreak + '   , FldIcon'
  + sLineBreak + '   , FldImage'
  + sLineBreak + '   , FldSvg'
  + sLineBreak + '   , FldScript'
  + sLineBreak + ' ) values('
  + sLineBreak + '     :PId'
  + sLineBreak + '   , :PPId'
  + sLineBreak + '   , :POrder'
  + sLineBreak + '   , :PState'
  + sLineBreak + '   , :PName'
  + sLineBreak + '   , :PSynonym'
  + sLineBreak + '   , :PIcon'
  + sLineBreak + '   , :PImage'
  + sLineBreak + '   , :PSvg'
  + sLineBreak + '   , :PScript'
  + sLineBreak + ' )'
  ;
  IMAGE_IMAGE_UPDATE_SQL = ''
  + sLineBreak + ' update'
  + sLineBreak + '     ' + IMAGE_IMAGE_TBL
  + sLineBreak + ' set'
//+ sLineBreak + '     FldId      = :PId'
  + sLineBreak + '     FldPId     = :PPId'
  + sLineBreak + '   , FldState   = :PState'
  + sLineBreak + '   , FldName    = :PName'
  + sLineBreak + '   , FldSynonym = :PSynonym'
  + sLineBreak + '   , FldIcon    = :PIcon'
  + sLineBreak + '   , FldImage   = :PImage'
  + sLineBreak + '   , FldSvg     = :PSvg'
  + sLineBreak + '   , FldScript  = :PScript'
  + sLineBreak + ' where'
  + sLineBreak + '     FldId = :PId'
  ;
  IMAGE_IMAGE_DELETE_SQL = ''
  + sLineBreak + ' delete'
  + sLineBreak + ' from'
  + sLineBreak + '     ' + IMAGE_IMAGE_TBL
  + sLineBreak + ' where'
  + sLineBreak + '     FldId = :PId'
  ;
  {$ENDREGION}
*)
  {$ENDREGION}

  {$REGION 'Zzz TImageRem'}
(*
  TImageRem = class(TRemotable)
  private
    FId: integer;
    FState: string;
    FName: string;
    FImage: TByteDynArray;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure FromRec(const IvImageRec: TImageRec);
    procedure ToRec(var IvImageRec: TImageRec);
  published
    property Id: integer read FId write FId;
    property State: string read FState write FState;
    property Name: string read FName write FName;
    property Image: TByteDynArray read FImage write FImage;
  end;

  TImageRemVector = array of TImageRem;

constructor TImageRem.Create;
begin
  inherited;

end;

destructor TImageRem.Destroy;
begin

  inherited;
end;

procedure TImageRem.FromRec(const IvImageRec: TImageRec);
begin
  FId :=    IvImageRec.Id;
  FState := IvImageRec.State;
  FName :=  IvImageRec.Name;
  FImage := BitmapToByteArrayF(IvImageRec.Image);
end;

procedure TImageRem.ToRec(var IvImageRec: TImageRec);
begin
  IvImageRec.Id :=                    FId;
  IvImageRec.State :=                 FState;
  IvImageRec.Name :=                  FName;
  ByteArrayToBitmap(IvImageRec.Image, FImage);
end;
*)
  {$ENDREGION}

{$ENDREGION}

{$REGION 'TIniCls'}
function TIniCls.BooGet(const IvPath: string; IvDefault: boolean): boolean;
var
  s, i: string;
begin
  SectionIdent(IvPath, s, i);
  Result := FIniFile.ReadBool(s, i, IvDefault);
end;

procedure TIniCls.BooSet(const IvPath: string; IvValue: boolean);
var
  s, i: string;
begin
  SectionIdent(IvPath, s, i);
  FIniFile.WriteBool(s, i, IvValue);
end;

constructor TIniCls.Create;
var
  e, p, f{, f0, f1, f2}, k: string; // exe, path, file
begin
  try
    // exepath
    e := byn.Spec;

    // exe 0-level
    p := ExtractFilePath(e);
    f := Format('%sWksIni.ini', [p]); //f0 := f;     //--> x:\$\X\Win32\Debug\WksIni.ini
    if not fsy.FileExists(f, k) then begin

      // exe 1-levelup
      p := ExtractFilePath(ExtractFileDir(p));
      f := Format('%sWksIni.ini', [p]); //f1 := f;   //--> x:\$\X\Win32\WksIni.ini
      if not fsy.FileExists(f, k) then begin

        // exe 2-levelup
        p := ExtractFilePath(ExtractFileDir(p));
        f := Format('%sWksIni.ini', [p]); //f2 := f; //--> x:\$\X\WksIni.ini
        if not fsy.FileExists(f, k) then begin
          // createit
          if byn.IsServer then
            fsy.FileCreate(f, INI_SERVER_DEFAULT)
          else if byn.IsDemon then
            fsy.FileCreate(f, INI_DEMON_DEFAULT)
          else
            fsy.FileCreate(f, INI_CLIENT_DEFAULT);
        end;
      end;
    end;

    // create
    FIniFile := TIniFile.Create(f);
  except
    on e: Exception do begin
      raise; // re-raises the current exception for handling at a higher level
    end;
  end;
end;

function TIniCls.CryGet(const IvPath: string; IvDefault: string; IvForceDefaultIfKeyIsEmpty: boolean): string;
var
  x: string;
begin
  x := StrGet(IvPath, IvDefault, IvForceDefaultIfKeyIsEmpty);
  Result := cry.Decipher(x);
end;

procedure TIniCls.CrySet(const IvPath, IvValue: string);
var
  x: string;
begin
  x := cry.Cipher(IvValue);
  StrSet(IvPath, x);
end;

destructor TIniCls.Destroy;
begin
  FreeAndNil(FIniFile);

  inherited;
end;

function TIniCls.FloGet(const IvPath: string; IvDefault: double): double;
var
  s, i: string;
begin
  SectionIdent(IvPath, s, i);
  Result := StrToFloatDef(FIniFile.ReadString(s, i, FloatToStr(IvDefault)), IvDefault);
end;

procedure TIniCls.FloSet(const IvPath: string; IvValue: double);
var
  s, i: string;
begin
  SectionIdent(IvPath, s, i);
  FIniFile.WriteString(s, i, FloatToStr(IvValue));
end;

function TIniCls.IntGet(const IvPath: string; IvDefault: integer): integer;
var
  s, i: string;
begin
  SectionIdent(IvPath, s, i);
  Result := FIniFile.ReadInteger(s, i, IvDefault);
end;

procedure TIniCls.IntSet(const IvPath: string; IvValue: integer);
var
  s, i: string;
begin
  SectionIdent(IvPath, s, i);
  FIniFile.WriteInteger(s, i, IvValue);
end;

procedure TIniCls.SectionIdent(const IvPath: string; var IvSection, IvIdent: string);
var
  v: TStringDynArray;
begin
  v := str.Split(IvPath, '/');
  IvSection := v[0];
  IvIdent   := v[1];
end;

procedure TIniCls.SliGet(const IvPath: string; IvStrings: TStrings; IvDefaultCsv: string; IvForceDefaultIfKeyIsEmpty: boolean);
var
  x, s: string;
  v: TStringDynArray;
begin
  x := StrGet(IvPath, IvDefaultCsv, IvForceDefaultIfKeyIsEmpty);
  v := str.Split(x);
  for s in v do
    IvStrings.Add(s);
end;

procedure TIniCls.SliSet(const IvPath: string; IvStrings: TStrings);
var
  x: string;
begin
  x := IvStrings.CommaText;
  StrSet(IvPath, x);
end;

function TIniCls.StrGet(const IvPath: string; IvDefault: string; IvForceDefaultIfKeyIsEmpty: boolean): string;
var
  s, i: string;
begin
  SectionIdent(IvPath, s, i);
  Result := FIniFile.ReadString(s, i, IvDefault);
  if IvForceDefaultIfKeyIsEmpty and Result.IsEmpty then
    Result := IvDefault;
end;

procedure TIniCls.StrSet(const IvPath, IvValue: string);
var
  s, i: string;
begin
  SectionIdent(IvPath, s, i);
  FIniFile.WriteString(s, i, IvValue);
end;

function TIniCls.TxtGet(const IvPath: string; IvDefaultBr: string; IvForceDefaultIfKeyIsEmpty: boolean): string;
var
  x: string;
begin
  x := StrGet(IvPath, IvDefaultBr, IvForceDefaultIfKeyIsEmpty);
  Result := StringReplace(x, '<br>', sLineBreak, [rfReplaceAll]);
end;

procedure TIniCls.TxtSet(const IvPath, IvValue: string);
var
  x: string;
begin
  x := StringReplace(IvValue, sLineBreak, '<br>', [rfReplaceAll]);
  StrSet(IvPath, x);
end;
{$ENDREGION}

{$REGION 'TLgtCls'}
constructor TLgtCls.Create(const IvFileSpec: string);
var
  s, d: string; // bynspec, datetime
begin
  // file
  FFileSpec := IvFileSpec;
  if FFileSpec = '' then begin
    s := byn.FileSpec; {Application.ExeName}
    d := FormatDateTime('yyyy-mm', Now);
    FFileSpec := ChangeFileExt(s, '_' + d + '.log');
  end;

  // pool of "one" thread to handle queue of log request writes
  FThreadPool := TThreadPool.Create(LogEntryWrite, 1);
end;

destructor TLgtCls.Destroy;
begin
  FThreadPool.Free;

  inherited;
end;

procedure TLgtCls.LogEntryWrite(IvLogRequest: pointer; IvThread: TThread);
var
  f: TextFile;
  r: PLgrRec; // logrequest
begin
  // data
  r := IvLogRequest;

  // ondebugview ***************************************************************
  OutputDebugString(PWideChar(r.Entry));

  // onfile ********************************************************************
  try
    {$I-} // no i/o exception, it is the responsiblity of the program to check the i/o operation by using the IOResult routine
    AssignFile(f, FFileSpec);
    if not System.SysUtils.FileExists(FFileSpec) then
      System.Rewrite(f)
    else
      System.Append(f);

    // if no error accessong the file then write & close
    if IOResult = 0 then begin
      try
        System.Writeln(f, r^.Entry);
        System.Flush(f);
      finally
        System.CloseFile(f);
      end;
    end else
      raise Exception.Create('Error while logging ' + r^.Entry);
    {$I-}
  finally
    Dispose(r);
  end;
end;

procedure TLgtCls.LogEntryThreadPoolAdd(const IvEntry: string);
var
  r: PLgrRec; // logrequest
begin
  New(r);
  r^.Entry := IvEntry;
  FThreadPool.Add(r);
end;

procedure TLgtCls.Tag(IvTag, IvValue: string; IvType: TLogEntryEnum);
var
  t, s: string;
begin
  case IvType of
    logDebug    : t := 'DEBUG  '; // WKS|MODULE|... ?
    logInfo     : t := 'INFO   ';
    logWarning  : t := 'WARNING';
    logException: t := 'ERROR  ';
    logQuery    : t := 'QUERY  ';
    logVector   : t := 'VECTOR ';
    logStrings  : t := 'STRINGS';
    logDataset  : t := 'DATASET';
    else          t := '       ';
  end;

  s := Format('%s|%5d:%5d|WKS|%7s|%-50s|%s', [FormatDateTime('dd hh:nn:ss zzz', Now), GetCurrentProcessID, GetCurrentThreadID, t, IvTag, IvValue]);
  LogEntryThreadPoolAdd(s);
end;

procedure TLgtCls.TagFmt(IvTag, IvValueFormatString: string; IvVarRecVector: array of TVarRec; IvType: TLogEntryEnum);
var
  s: string;
begin
  s := Format(IvValueFormatString, IvVarRecVector);
  Tag(IvTag, s, IvType);
end;

procedure TLgtCls.Iif(IvTest: boolean; IvTrueString, IvFalseString, IvTag: string; IvType: TLogEntryEnum);
begin
  if IvTest then
    Tag(IvTag, IvTrueString, IvType)
  else
    Tag(IvTag, IvFalseString, IvType);
end;

procedure TLgtCls.EmptyRow;
begin
  Tag('', '');
end;

procedure TLgtCls.L(IvString, IvTag: string);
begin
  Tag(IvTag, IvString, TLogEntryEnum.logNone);
end;

procedure TLgtCls.LFmt(IvFormatString: string; IvVarRecVector: array of TVarRec; IvTag: string);
begin
  L(Format(IvFormatString, IvVarRecVector), IvTag);
end;

procedure TLgtCls.I(IvString, IvTag: string);
begin
  Tag(IvTag, IvString, TLogEntryEnum.logInfo);
end;

procedure TLgtCls.IFmt(IvFormatString: string; IvVarRecVector: array of TVarRec; IvTag: string);
begin
  I(Format(IvFormatString, IvVarRecVector), IvTag);
end;

procedure TLgtCls.W(IvString, IvTag: string);
begin
  Tag(IvTag, IvString, TLogEntryEnum.logWarning);
end;

procedure TLgtCls.WFmt(IvFormatString: string; IvVarRecVector: array of TVarRec; IvTag: string);
begin
  W(Format(IvFormatString, IvVarRecVector), IvTag);
end;

procedure TLgtCls.E(IvString, IvTag: string);
begin
  Tag(IvTag, IvString, TLogEntryEnum.logException);
end;

procedure TLgtCls.E(IvException: Exception; IvTag: string);
begin
  Tag(IvTag, IvException.Message, TLogEntryEnum.logException);
end;

procedure TLgtCls.EFmt(IvFormatString: string; IvVarRecVector: array of TVarRec; IvTag: string);
begin
  E(Format(IvFormatString, IvVarRecVector), IvTag);
end;

procedure TLgtCls.D(IvString, IvTag: string);
begin
  {$WARN SYMBOL_PLATFORM OFF}
  if DebugHook = 0 then
    Exit;
  {$WARN SYMBOL_PLATFORM ON}
  Tag(IvTag, IvString, TLogEntryEnum.logDebug);
end;

procedure TLgtCls.O(IvObject: TObject; IvTag: string);
begin
  Tag('LOGOBJECT', NOT_IMPLEMENTED);
end;

procedure TLgtCls.Q(IvSql, IvTag: string; IvOneLine: boolean);
var
  s: string;
begin
  if IvOneLine then begin
    s := StringReplace(IvSql, sLineBreak, ' ', [rfReplaceAll]);
    s := StringReplace(s, '  ', ' ', [rfReplaceAll]);
  end else
    s := IvSql;
  Tag(IvTag, s, TLogEntryEnum.logQuery);
end;

procedure TLgtCls.P(IvParams: TParameters; IvTag: string);
var
  i: integer;
begin
  for i := 0 to IvParams.Count-1 do begin
    TagFmt(IvTag, 'Param %2d Name : %s', [i, IvParams[i].Name]);
    TagFmt(IvTag, 'Param %2d Value: %s', [i, VarToStr(IvParams[i].Value)]);
    TagFmt(IvTag, 'Param %2d Size : %d', [i, IvParams[i].Size]);
  //TagFmt(IvTag, 'Param %2d Type : %s', [i, IvParams[i].DataType]);
  end;
end;

procedure TLgtCls.S(IvStrings: TStrings; IvTag: string);
var
  i: integer;
  s: string;
begin
  for i := 0 to IvStrings.Count-1 do
    s := s + ',' + IvStrings[i];
  Tag(IvTag, s, TLogEntryEnum.logStrings);
end;

procedure TLgtCls.V(IvStringVector: TStringVector; IvTag: string);
var
  i: integer;
  s: string;
begin
  for i := Low(IvStringVector) to High(IvStringVector) do
    s := s + ',' + IvStringVector[i];
  Tag(IvTag, s, TLogEntryEnum.logVector);
end;

procedure TLgtCls.Ds(IvDs: TDataset; IvTag: string; IvFirstN: integer);
var
  i: integer;
  s, t: string; // buffer, temp
  l: TStrings;
begin
  // exit
  if IvDs.IsEmpty then begin
    Tag(IvTag, 'Dataset is empty', TLogEntryEnum.logDataset);
    Exit;
  end;

  // go
  l := TStringList.Create;
  try
    IvDs.First;

    // header
    s := IvDs.Fields[0].FieldName;
    for i := 1 to IvDs.FieldCount-1 do
      s := s + ',' + IvDs.Fields[i].FieldName;
    l.Add(s);

    // body
    while not IvDs.Eof do begin
      if IvDs.Fields[0].IsNull then
        s := NULL_STR
      else if IvDs.Fields[0].IsBlob then
        s := BLOB_STR
      else
        s := IvDs.Fields[0].AsString;
      for i := 1 to IvDs.FieldCount-1 do begin
        if IvDs.Fields[i].IsNull then
          t := NULL_STR
        else if IvDs.Fields[i].IsBlob then
          t := BLOB_STR
        else
          t := IvDs.Fields[i].AsString;
        s := s + ',' + t;
      end;
      l.Add(s);
      IvDs.Next;
    end;
    Tag(IvTag, l.Text, TLogEntryEnum.logDataset);
  finally
    IvDs.First;
    l.Free;
  end;
end;

procedure TLgtCls.Enter(IvString, IvTag: string);
begin
  Tag(IvTag, LOG_INDENT_ENTER + IvString);
  Inc(FIndentCount)
end;

procedure TLgtCls.EnterFmt(IvFormatStr: string; const IvArgVec: array of TVarRec; IvTag: string);
begin
  Enter(Format(IvFormatStr, IvArgVec), IvTag);
end;

procedure TLgtCls.Leave(IvString, IvTag: string);
begin
  Dec(FIndentCount);
  Tag(IvTag, LOG_INDENT_LEAVE + IvString);
end;

procedure TLgtCls.LeaveFmt(IvFormatStr: string; const IvArgVec: array of TVarRec; IvTag: string);
begin
  Leave(Format(IvFormatStr, IvArgVec), IvTag);
end;

procedure TLgtCls.Event(IvToComputer, IvSource, IvString: string; IvType, IvCategory, IvId: word);
var
  p: pointer;
  h: THandle;
begin
  p := PChar(IvString);
  if Length(IvToComputer) = 0 then
    h := RegisterEventSource(nil, PChar(IvSource))                  // connect to local machine
  else
    h := RegisterEventSource(PChar(IvToComputer), PChar(IvSource)); // connect to remote machine
  if h <> 0 then
    try
      ReportEvent(
        h          // event log handle
      , IvType     // event type (EVENTLOG_INFORMATION_TYPE, EVENTLOG_ERROR_TYPE)
      , IvCategory // category identifier --> e.g. 1 aka 'Database Connection Error'
      , IvId       // event identifier    --> e.g. 3 aka 'Failed to connect to database Server %1'
      , nil        // user security identifier (optional)
      , 1          // number of strings, one substitution string
      , 0          // size of binary data, 0 = no data
      , @p         // pointer to string array, string to be merged with Text in Ressource DLL --> e.g. 'DBSERVER'
      , nil        // pointer to data, address of binary data
      );
    finally
      DeregisterEventSource(h);
    end;
end;

procedure TLgtCls.EventI(IvString, IvToComputer: string);
begin
  Event(IvToComputer, ExtractFileName(ParamStr(0)), IvString, EVENTLOG_INFORMATION_TYPE, 0, 0);
end;

procedure TLgtCls.EventW(IvString, IvToComputer: string);
begin
  Event(IvToComputer, ExtractFileName(ParamStr(0)), IvString, EVENTLOG_WARNING_TYPE, 0, 0);
end;

procedure TLgtCls.EventE(IvString, IvToComputer: string);
begin
  Event(IvToComputer, ExtractFileName(ParamStr(0)), IvString, EVENTLOG_ERROR_TYPE, 0, 0);
end;
{$ENDREGION}

{$REGION 'TLstRec'}
procedure TLstRec.DelimReset(var IvList: string; IvWhiteRemove, IvWhiteAsDelimiter: boolean);
begin
  // nowhite
  if IvWhiteRemove then
    IvList := str.Replace(IvList, ' ', '');

  // before should escape DELIMITER_CHAR
  IvList := str.Replace(IvList, ',', DELIMITER_CHAR);
  IvList := str.Replace(IvList, ';', DELIMITER_CHAR);
  IvList := str.Replace(IvList, '|', DELIMITER_CHAR);
//IvList := str.Replace(IvList, ':', DELIMITER_CHAR); // NO! broke X:\
  if IvWhiteAsDelimiter then
    IvList := str.Replace(IvList, ' ', DELIMITER_CHAR); // NO! broke X:\$\Txt - Copia
//if IvConsiderColon then
end;

function TLstRec.FromRangeChar(IvRange, IvSorroundChar: string): string;
var
  r, x: string;
  a, z, i: integer;
begin
  // preprocess
  r := IvRange;
  r := str.Replace(r, '..', '-');

  // bounds
  a := StrToInt(str.LeftOf('-', r));      // a
  z := StrToInt(str.RightOf('-', r));     // d

  // do
  for i := Ord(a) to Ord(z) do begin
    x := Char(i);
    Result := Result + ',' + IvSorroundChar + x + IvSorroundChar;
  end;
  Delete(Result, 1, 1);
end;

function TLstRec.FromRangeInt(IvRange: string; IvLeadingZero: boolean; IvItemLen: integer; IvSorroundChar: string): string;
var
  r, x: string;
  a, z, i: integer;
begin
  // exit
  if (IvLeadingZero) and (IvItemLen < 0) then
    Exit;

  // preprocess
  r := IvRange;
  r := str.Replace(r, '..', '-');

  // bounds
  a := StrToInt(str.LeftOf('-', r));
  z := StrToInt(str.RightOf('-', r));

  // do
  for i := a to z do begin
    x := IntToStr(i);
    if IvLeadingZero then
      x := str.ZeroLeadingAdd(x, IvItemLen);
    Result := Result + ',' + IvSorroundChar + x + IvSorroundChar;
  end;
  Delete(Result, 1, 1);
end;

function TLstRec.FromStr(IvString, IvDelimiterChar: string): string;
begin
  Result := str.OneSpace(IvString);
  Result := str.Replace(Result, ' '       , IvDelimiterChar);
  if ',' <> IvDelimiterChar then
  Result := str.Replace(Result, ','       , IvDelimiterChar);
  Result := str.Replace(Result, ';'       , IvDelimiterChar);
//Result := str.Replace(Result, sLineBreak, IvDelimiterChar);
end;

function TLstRec.Has(IvList, IvItem: string): boolean;
var
  i: integer;
  s: string;
  v: TStringVector;
//l: TStringList;
begin
  Result := false;

  // i
//l := TStringList.Create;
//try
//  l.CommaText := IvStringList;
//  for i := 0 to l.Count - 1 do begin
//    Result := IvString = Trim(l.Strings[i]);
//    if Result then
//      Exit;
//  end;
//finally
//  FreeAndNil(l);
//end;

  // ii
  v := ToVector(IvList);
  for i := Low(v) to High(v) do begin
    s := v[i];
    if s = IvItem then begin
      Result := true;
      Exit;
    end;
  end;
end;

procedure TLstRec.ItemAdd(var IvList: string; const IvItem: string; IvDelimiterChar, IvSorroundChar: string);
begin
  if IvList = '' then
    IvList := IvItem
  else if iis.Ex(IvSorroundChar) then
    IvList := IvList + IvDelimiterChar + IvSorroundChar + IvItem + IvSorroundChar
  else
    IvList := IvList + IvDelimiterChar + IvItem;
end;

function TLstRec.ItemAppend(IvList, IvStr, IvDelimiterChar: string; IvSpaceAdd: boolean): string;
var
  i: integer;
  v: TStringVector;
  d: string;
begin
  Result := IvList;

  // empty
  if iis.Nx(IvList) then
    Exit;

  // unsorround
  Result := ItemUnsorround(Result);

  // vector
  v := TStringVector(ToVector(Result));

  // spacedelim
  if IvSpaceAdd then d := ' ' else d := '';

  // sorround
  Result := Trim(v[0]) + IvStr;
  for i := 1 to High(v) do
    Result := Result + IvDelimiterChar + d + Trim(v[i] + IvStr);
end;

function TLstRec.ItemNext(var IvPChar: PChar; IvSep: Char): string;
var
  s: PChar;
begin
  if IvPChar = nil then
    Result := ''
  else begin
    s := IvPChar;
    while (s^ <> #0) and (s^ <> IvSep) do
      inc(s);
    SetString(Result, IvPChar, s - IvPChar);
    if s^ <> #0 then
      IvPChar := s + 1
    else
      IvPChar := nil;
  end;
end;

function TLstRec.ItemPos(const IvItem, IvCsvLine: string): integer;
var
  i: string; // item
  p: PChar;
begin
  Result := -1;
  p := Pointer(IvCsvLine);
  i := IvItem;
  if (p = nil) or (i = '') then
    Exit;
//Delete(i, 1, 1);
  repeat
    Inc(Result);
    if SameText(ItemNext(p), i) then
      Exit;
  until p = nil;
  Result := -1;
end;

function TLstRec.ItemPrepend(IvList, IvStr, IvDelimiterChar: string; IvSpaceAdd: boolean): string;
var
  i: integer;
  v: TStringVector;
  d: string;
begin
  Result := IvList;

  // empty
  if iis.Nx(IvList) then
    Exit;

  // unsorround
  Result := ItemUnsorround(Result);

  // vector
  v := TStringVector(ToVector(Result));

  // spacedelim
  if IvSpaceAdd then d := ' ' else d := '';

  // sorround
  Result := IvStr + Trim(v[0]);
  for i := 1 to High(v) do
    Result := Result + IvDelimiterChar + d + IvStr + Trim(v[i]);
end;

function TLstRec.ItemSorround(IvList, IvDelimiterChar, IvSorroundChar: string; IvSpaceAdd: boolean): string;
var
  i: integer;
  v: TStringVector;
  s: string;
begin
  Result := IvList;

  // exit
  if iis.Nx(Result) then
    Exit;

  // unsorround
  Result := ItemUnsorround(Result);

  // vector
  v := TStringVector(ToVector(Result, IvDelimiterChar));

  // spacedelim
  if IvSpaceAdd then s := ' ' else s := '';

  // sorround
  Result := IvSorroundChar + Trim(v[0]) + IvSorroundChar;
  for i := 1 to High(v) do
    Result := Result + IvDelimiterChar + s + IvSorroundChar + Trim(v[i]) + IvSorroundChar;
end;

function TLstRec.ItemUnsorround(IvList, IvDelimiterChar, IvSorroundChar: string; IvSpaceAdd: boolean): string;
var
  i: integer;
  v: TStringVector;
  s: string;
begin
  Result := IvList;

  // exit
  if iis.Nx(Result) then
    Exit;

  // vector
  v := TStringVector(ToVector(Result, IvDelimiterChar));

  // spacedelim
  if IvSpaceAdd then s := ' ' else s := '';

  // sorround
  Result := str.Replace(Trim(v[0]), IvSorroundChar, '');
  for i := 1 to High(v) do
    Result := Result + IvDelimiterChar + s + str.Replace(Trim(v[i]), IvSorroundChar, '');
end;

function TLstRec.Safe(IvList: string): string;
begin
  Result := str.Replace(Result, '"' , '');
  Result := str.Replace(Result, '''', '');
end;

function TLstRec.ToVector(IvList, IvDelimiterChar: string; IvTrim: boolean): TStringVector;
var
  i, c, p: integer; // count, capacity, pos
begin
  // exit
  if iis.Nx(IvList) then begin
    SetLength(Result, 0);
    Exit;
  end;

  // init
  i := 0;
  p := 1;
  c := 16;
  SetLength(Result, c);

  // go
  repeat
    if i >= c then begin
      c := c + 16;
      SetLength(Result, c);
    end;
    Result[i] := str.Bite(IvList, IvDelimiterChar, p);
    Inc(i);
  until p = 0;
  SetLength(Result, i);

  // trim
  if not IvTrim then
    Exit;
  for i := Low(Result) to High(Result) do
    Result[i] := Trim(Result[i]);
end;

function TLstRec.ToVectorAnyChar(IvList, IvDelimiterCharList: string; IvTrim: boolean): TStringVector;
var
  i{, c, p}: integer; // count, capacity, pos
begin
  if iis.Nx(IvList) then begin
    SetLength(Result, 0);
    Exit;
  end;

  // ii
  Result := TStringVector(
    SplitString(
      IvList              // string to be split
    , IvDelimiterCharList // one or more characters defined as possible delimiters
    )
  );

  // trim
  if not IvTrim then
    Exit;
  for i := Low(Result) to High(Result) do
    Result[i] := Trim(Result[i]);
end;

function TLstRec.ToVectorRe(const IvText, IvList: string; var IvStringVector: TStringVector; var IvFbk: string; IvTrim: boolean): boolean;
var
  x: string;
  r: TRegEx;
  m: TMatch;
  i, j: integer;
begin
  // init
  x := Format(rex.REX_LIST_PAT, [IvList]);

  // go
  r := TRegEx.Create(x, [roIgnoreCase, roSingleLine]);
  m := r.Match(IvText);
  i := -1;
  while m.Success do begin
    //LogD('Match : [' + m.Value + ']');
    if m.Groups.Count = 2 then  begin // only 2 groups are expected, the group[0]=wholematch and the group[1]=(.* )
      //LogD('Group[1] : [' + m.Groups[1].Value + ']')
      SetLength(IvStringVector, Length(IvStringVector)+1);
      Inc(i);
      IvStringVector[i] := m.Groups[1].Value;
    end;
    m := m.NextMatch;
  end;

  // trim
  if IvTrim then
    for j := Low(IvStringVector) to High(IvStringVector) do
      IvStringVector[j] := Trim(IvStringVector[i]);

  // fbk
  Result := i > -1;
  if not Result then
    IvFbk := Format('Text does not contains %s rex', [x])
  else
    IvFbk := Format('Returning a list vector with %d elements', [Length(IvStringVector)]);
end;

function TLstRec.WhiteToDelim(IvList: string): string;
begin
  Result := str.OneSpace(IvList);
  Result := str.Replace(Result, ' ', DELIMITER_CHAR);
end;
{$ENDREGION}

{$REGION 'TMatRec'}
function TMatRec.AbsoluteValue(IvValue: double): double;
begin
  if IvValue < 0 then
    Result := -(IvValue)
  else
    Result := IvValue;
end;

function TMatRec.Delta(IvMax, IvMin: integer): integer;
begin
  Result := IvMax - IvMin;
end;

function TMatRec.Delta(IvMax, IvMin: double): double;
begin
  Result := IvMax - IvMin;
end;

function TMatRec.Max2(a, b: integer): integer;
begin
  Result := System.Math.Max(a, b);
end;

function TMatRec.Max2(a, b: double): double;
begin
  Result := System.Math.Max(a, b);
end;

function TMatRec.Max3(a, b, c: double): double;
begin
  if (a > b) then begin
    if (a > c) then begin
      Result := a;
    end else begin
      Result := c;
    end;
  end else if b > c then begin
    Result := b;
  end else
    Result := c;
end;

function TMatRec.Max3(a, b, c: integer): integer;
asm { params: eax, edx, ecx }
 cmp   edx, eax
 cmovg eax, edx
 cmp   ecx, eax
 cmovg eax, ecx
end;

function TMatRec.Min2(a, b: integer): integer;
begin
  Result := System.Math.Min(a, b);
end;

function TMatRec.Min2(a, b: double): double;
begin
  Result := System.Math.Min(a, b);
end;

function TMatRec.Min3(a, b, c: double): double;
begin
  if (a < b) then begin
    if (a < c) then begin
      Result := a;
    end else begin
      Result := c;
    end;
  end else if b < c then begin
    Result := b;
  end else
    Result := c;
end;

function TMatRec.Min3(a, b, c: integer): integer;
asm { params: eax, edx, ecx }
 cmp   edx, eax
 cmovl eax, edx
 cmp   ecx, eax
 cmovl eax, ecx
end;

function TMatRec.VecIntMax(IvVector: array of integer): integer;
var
  i: integer;
begin
  Result := IvVector[0];
  for i := 1 to High(IvVector) do
    if Result < IvVector[i] then
      Result := IvVector[i];
end;

function TMatRec.VecIntMin(IvVector: array of integer): integer;
var
  i: integer;
begin
  Result := IvVector[0];
  for i := 1 to High(IvVector) do
    if Result > IvVector[i] then
      Result := IvVector[i];
end;

function TMatRec.VecSingleMax(const IvSingleVec: array of single): single;
begin
  Result := System.Math.MaxValue(IvSingleVec);
end;

function TMatRec.VecSingleMin(const IvSingleVec: array of single): single;
begin
  Result := System.Math.MinValue(IvSingleVec);
end;
{$ENDREGION}

{$REGION 'TMesRec'}
procedure TMesRec.About;
var
  t: TTaskDialog;
begin
//if (Win32MajorVersion >= 6) and ThemeServices.ThemesEnabled then
  t := TTaskDialog.Create(nil);
  try
    t.Caption        := 'About'; // IvCaption
    t.Title          := sys.Acronym + ' ' + byn.Info;
    t.Text           := Format('Version: %s', [byn.Ver])
    + sLineBreak      + sys.RioCopyright
    + sLineBreak      + sys.Www;
    t.CommonButtons  := [tcbClose];
    t.Flags          := [tfUseHiconMain{, tfAllowDialogCancellation}];
    t.CustomMainIcon := Application.Icon;
    t.Execute;
  finally
    FreeAndNil(t);
  end;
end;

procedure TMesRec.AutoClose(const IvCaption, IvPrompt: string; IvDurationMs: integer);
var
  f: TForm;
  p: TLabel; // prompt
  o: TPoint; // dialogunits
  i, j: integer; // chars, lines

  function CharSizeAvg(Canvas: TCanvas): TPoint;
  var
    i: integer;
    b: array[0..51] of Char; // buffer
  begin
    for i := 0 to 25 do b[i]      := Chr(i + Ord('A'));
    for i := 0 to 25 do b[i + 26] := Chr(i + Ord('a'));
    GetTextExtentPoint(Canvas.Handle, b, 52, TSize(Result));
    Result.X := Result.X div 52;
  end;

begin
  j := 0;
  for i := 1 to Length(IvPrompt) do
    if IvPrompt[i] = sLineBreak then Inc(j);

  f := TForm.Create(Application);
  try
    o := CharSizeAvg(f.Canvas);
  //f.Font.Name    := 'Arial';
  //f.Font.Size    := 10;
  //f.Font.Style   := [fsBold];
  //f.Canvas.Font  := Font;
    f.BorderStyle  := bsToolWindow; // bsDialog
    f.FormStyle    := fsStayOnTop;
    f.BorderIcons  := [];
    f.Caption      := IvCaption;
    f.ClientWidth  := MulDiv(Screen.Width div 4, o.X, 4);
    f.ClientHeight := MulDiv(23 + (j * 10), o.Y, 8);
    f.Position     := poScreenCenter;
    p              := TLabel.Create(f);
    p.Parent       := f;
    p.AutoSize     := true;
    p.Left         := MulDiv(8, o.X, 4);
    p.Top          := MulDiv(8, o.Y, 8);
    p.Caption      := IvPrompt;
    f.Width := p.Width + p.Left + 50;
    f.Show;
    Application.ProcessMessages;
  finally
    Sleep(IvDurationMs);
    FreeAndNil(f);
  end;
end;

procedure TMesRec.AutoCloseFmt(const IvCaption, IvPrompt: string; IvVarRecVector: array of TVarRec; IvDurationMs: integer);
begin
  AutoClose(IvCaption, Format(IvPrompt, IvVarRecVector), IvDurationMs);
end;

procedure TMesRec.E(IvMessage: string);
begin
  MessageDlg(IvMessage, mtError, [mbOK], 0);
end;

procedure TMesRec.I(IvMessage: string);
//var
//  t: TTaskDialog;
begin
  // i
  if byn.IsClient then
    ShowMessage(IvMessage)
  else
    MessageDlg(IvMessage, mtInformation, [mbOK], 0);

  // ii
//t := TTaskDialog.Create(nil);
//try
//  t.Caption        := IvCaption;
//  t.Title          := IvCaption;
//  t.Text           := IvMessage;
//  t.CommonButtons  := [tcbClose];
//  t.Flags          := [tfUseHiconMain];
//  t.Execute;
//finally
//  FreeAndNil(t);
//end;
end;

procedure TMesRec.IFmt(IvMessageFormatString: string; IvVarRecVector: array of TVarRec);
begin
  I(Format(IvMessageFormatString, IvVarRecVector));
end;

procedure TMesRec.NA;
begin
  I(NOT_AVAILABLE)
end;

procedure TMesRec.W(IvMessage: string);
begin
  MessageDlg(IvMessage, mtWarning, [mbOK], 0);
end;

procedure TMesRec.WFmt(IvMessageFormatString: string; IvVarRecVector: array of TVarRec);
begin
  W(Format(IvMessageFormatString, IvVarRecVector));
end;
{$ENDREGION}

{$REGION 'TMimRec'}
function TMimRec.FromContent(IvContent: pointer; IvLength: integer): string;
begin
  if (IvContent <> nil) and (IvLength > 4) then
    case PCardinal(IvContent)^ of
    $04034B50: Result := 'application/zip';                  // 50 4B 03 04
    $46445025: Result := 'application/pdf';                  // 25 50 44 46 2D 31 2E
    $21726152: Result := 'application/x-rar-compressed';     // 52 61 72 21 1A 07 00
    $AFBC7A37: Result := 'application/x-7z-compressed';      // 37 7A BC AF 27 1C
    $75B22630: Result := 'audio/x-ms-wma';                   // 30 26 B2 75 8E 66
    $9AC6CDD7: Result := 'video/x-ms-wmv';                   // D7 CD C6 9A 00 00
    $474E5089: Result := 'image/png';                        // 89 50 4E 47 0D 0A 1A 0A
    $38464947: Result := 'image/gif';                        // 47 49 46 38
    $002A4949, $2A004D4D, $2B004D4D: Result := 'image/tiff'; // 49 49 2A 00 or 4D 4D 00 2A or 4D 4D 00 2B
    $E011CFD0:                                               // Microsoft Office applications D0 CF 11 E0 = DOCFILE
      if IvLength > 600 then
      case System.SysUtils.PWordArray(IvContent)^[256] of                    // at offset 512
        $A5EC: Result := 'application/msword';               // EC A5 C1 00
        $FFFD: // FD FF FF
          case System.SysUtils.PByteArray(IvContent)^[516] of
            $0E, $1C, $43:                     Result := 'application/vnd.ms-powerpoint';
            $10, $1F, $20, $22, $23, $28, $29: Result := 'application/vnd.ms-excel';
          end;
      end;
    else
      case PCardinal(IvContent)^ and $00ffffff of
        $685A42: Result := 'application/bzip2';              // 42 5A 68
        $088B1F: Result := 'application/gzip';               // 1F 8B 08
        $492049: Result := 'image/tiff';                     // 49 20 49
        $FFD8FF: Result := 'image/jpeg';                     // FF D8 FF DB/E0/E1/E2/E3/E8
        else
          case PWord(IvContent)^ of
            $4D42: Result := 'image/bmp';                    // 42 4D
          end;
      end;
    end;

  // default
  if Result = '' then
    Result := MIMETYPE_OCTET;
end;

function TMimRec.FromFile(IvFileName: TFileName): string;
begin
  if IvFileName = '' then
    Exit;

  case lst.ItemPos(ExtractFileExt(IvFileName), '.txt,.htm,.html,.css,.csv,.json,.js,.png,.gif,.tiff,.tif,.jpg,.jpeg,.bmp,.doc,.docx,.ppt,.pptx,.xls,.xlsx,.mdb,.accdb') of
     0   : Result := MIMETYPE_TEXT;
     1, 2: Result := MIMETYPE_HTML;
     3   : Result := MIMETYPE_CSS ;
     4   : Result := MIMETYPE_CSV ;
     5   : Result := MIMETYPE_JSON;
     6   : Result := MIMETYPE_JS  ;
     7   : Result := MIMETYPE_PNG ;
     8   : Result := MIMETYPE_GIF ;
     9,10: Result := MIMETYPE_TIF ;
    11,12: Result := MIMETYPE_JPG ;
    13   : Result := MIMETYPE_BMP ;
    14,15: Result := MIMETYPE_DOC ;
    16,17: Result := MIMETYPE_PPT ;
    18,19: Result := MIMETYPE_XLS ;
    20,21: Result := MIMETYPE_MDB ;
    else begin
      Result := ExtractFileExt(IvFileName);
      Delete(Result, 1, 1);
      if Result <> '' then
        Result := 'application/' + LowerCase(Result)
      else
        Result := MIMETYPE_OCTET;
    end;
  end;

  if Result = '' then
    Result := 'application/octet-stream';
end;

function TMimRec.FromRegistry(IvFileExt: string): string;
var
  r: TRegistry;
begin
  // default
  Result := MIMETYPE_OCTET;

  // lookregistry
  r := TRegistry.Create;
  with r do try
    RootKey := HKEY_CLASSES_ROOT;
    if OpenKey(IvFileExt, false) then begin
      if ValueExists('Content Type') then
        Result := ReadString('Content Type');
      CloseKey;
    end;
  finally
    FreeAndNil(r);
  end;
end;
{$ENDREGION}

{$REGION 'TNetRec'}
function TNetRec.Domain: string;
begin
  Result := LowerCase(GetEnvironmentVariable('USERDNSDOMAIN'));
  if Result = '' then
    Result := 'nodomain';
end;

function TNetRec.Host: string;
var
  s: DWord; // size
  b: array[0..255] of {ansi}char; // buffer
begin
  s := 256;
  if winapi.Windows.GetComputerName(b, s) then
    Result := LowerCase(b)
  else
    Result := 'nohost';
end;

function TNetRec.Info: string;
begin
  Result := Format('OsUser: %s@%s.%s   Lan: %s   Wan: %s', [net.OsLogin, net.Host, net.Domain, net.IpLan, net.IpWan]);
end;

function TNetRec.InternetIsAvailable(var IvFbk: string): boolean;
var
  o: cardinal; // origin
begin
  // connected?
  Result := InternetGetConnectedState(@o, 0);

  // kind
  if      o =  0                             then IvFbk := 'Internet connection not available, please check your internet connection'
  else if o = INTERNET_CONNECTION_MODEM      then IvFbk := 'Internet connection available via modem'
  else if o = INTERNET_CONNECTION_LAN        then IvFbk := 'Internet connection available via local area network'
  else if o = INTERNET_CONNECTION_PROXY      then IvFbk := 'Internet connection available via proxy server'
  else if o = INTERNET_CONNECTION_MODEM_BUSY then IvFbk := 'Internet connection modem busy, no longer used'
  else if o = INTERNET_RAS_INSTALLED         then IvFbk := 'Internet connection not available, local system has RAS installed'
  else if o = INTERNET_CONNECTION_OFFLINE    then IvFbk := 'Internet connection not available, local is in offline mode'
  else if o = INTERNET_CONNECTION_CONFIGURED then IvFbk := 'Internet connection configured but it might or might not be currently connected'
  else                                            IvFbk := UNKNOWN_STR;
end;

function TNetRec.IpLan: string;
var
  k: string;
begin
  IpLanFn(Result, k);
end;

function TNetRec.IpLanFn(var IvIpLan, IvFbk: string): boolean;
type
  l = ^u_long;
var
  w: TWSAData;
  h: PHostEnt;
  a: TInAddr;
  b: array[0..255] of ansichar; // buffer
begin
  Result := WSAStartup($101, w) = 0;
  if not Result then begin
    IvIpLan := 'nolanip';
    IvFbk := IntToStr(GetLastError); // GetLastOSError;
  end else begin
    GetHostName(b, sizeof(b));
    h := gethostbyname(b);
    a.S_addr := u_long(l(h^.h_addr_list^)^);
    IvIpLan := string(inet_ntoa(a));
    IvFbk := OK_STR;
  end;
  WSACleanup;
end;

function TNetRec.IpWan: string;
var
  k: string;
begin
  IpWanFn(Result, k);
end;

function TNetRec.IpWanFn(var IvIpWan, IvFbk: string): boolean;
var
  {h, i,} hc: string; // html, ip, httpcontent
//  l, l2: Word; // htmllen, flaglen
//  b, b2, c: PChar; // htmlbuff, flagbuff
//  p: integer; // pos
begin
  Result := htt.Get(url.MYIPDOTNET, hc, IvFbk);
  if not Result then
    IvIpWan := 'nowanip'
  else
    IvIpWan := Trim(hc);
end;

function TNetRec.OsLogin: string;
var
  s: DWord; // size
  b: array[0..255] of char; // buffer
begin
  s := SizeOf(b);
  if GetUsername(b, s) then // GetUsernameEx get the user's domain (if there even is one), not the machine's joined domain
    Result := LowerCase(b)
  else
    Result := 'nooslogin'
end;

function TNetRec.Ping(IvAddress: string; var IvFbk: string; IvRetries: integer): boolean;
var
  j: integer;
  f: string;
begin
  Result := false;
  for j := 0 to IvRetries-1 do begin
  //if false then
    //Result := PingRaw(IvAddress, f)
  //else
      Result := PingWmi(IvAddress, 1, 32, f);
    if Result then
      Exit;
  end;
end;

function TNetRec.PingRaw(const IvAddress: string; var IvFbk: string): boolean;
//var
//  h: THandle;
//  a: TIPAddr;
//  d: DWORD;
//  r: array[1..128] of byte; // reply
begin
//  Result := false;
//  h := NetIcmpCreateFile;
//  if h = INVALID_HANDLE_VALUE then
//    Exit;
//  NetTranslateStringToAddr(IvAddress, a);
//  d := NetIcmpSendEcho(h, a, nil, 0, nil, @r, 128, 0);
//  Result := (d <> 0);
//  NetIcmpCloseHandle(h);
end;

function TNetRec.PingStateFromCode(IvCode: integer): string;
begin
  case IvCode of
        0: Result := 'Success';
    11001: Result := 'Buffer Too Small';
    11002: Result := 'Destination Net Unreachable';
    11003: Result := 'Destination Host Unreachable';
    11004: Result := 'Destination Protocol Unreachable';
    11005: Result := 'Destination Port Unreachable';
    11006: Result := 'No Resources';
    11007: Result := 'Bad Option';
    11008: Result := 'Hardware Error';
    11009: Result := 'Packet Too Big';
    11010: Result := 'Request Timed Out';
    11011: Result := 'Bad Request';
    11012: Result := 'Bad Route';
    11013: Result := 'TimeToLive Expired Transit';
    11014: Result := 'TimeToLive Expired Reassembly';
    11015: Result := 'Parameter Problem';
    11016: Result := 'Source Quench';
    11017: Result := 'Option Too Big';
    11018: Result := 'Bad Destination';
    11032: Result := 'Negotiating IPSEC';
    11050: Result := 'General Failure'
  else     Result := 'Unknow';
  end;
end;

function TNetRec.PingWmi(const IvAddress: string; IvRetries, IvBufferSize: Word; var IvFbk: string): boolean;
var
  FSWbemLocator: OLEVariant;
  FWMIService: OLEVariant;
  FWbemObjectSet: OLEVariant;
  FWbemObject: OLEVariant;
  q: string; // query
  e: IEnumVariant;
  l: LongWord;
  i: integer;
  r: integer; // packetsreceived
  min: integer;
  max: integer;
  avg: integer;
begin;
  // init
  IvFbk := Format('Pinging %s with %d bytes of data', [IvAddress, IvBufferSize]);
  r := 0;
  min := 0;
  max := 0;
  avg := 0;
  q := Format('select * from Win32_PingStatus where Address=%s and BufferSize=%d and Timeout=100',[QuotedStr(IvAddress), IvBufferSize]);

  // wmi
  FSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
  FWMIService   := FSWbemLocator.ConnectServer('localhost', 'root\CIMV2', '', '');
//FWMIService   := FSWbemLocator.ConnectServer('192.168.52.130', 'root\CIMV2', 'Username', 'password');
  // loop
  for i := 0 to IvRetries-1 do begin
    FWbemObjectSet := FWMIService.ExecQuery(q, 'WQL', 0);
    e := IUnknown(FWbemObjectSet._NewEnum) as IEnumVariant;
    if e.Next(1, FWbemObject, l) = 0 then begin
      if FWbemObject.StatusCode = 0 then begin
        Inc(r);
        if FWbemObject.ResponseTime > 0 then
          IvFbk := IvFbk + sLineBreak + Format('Reply from %s: bytes=%s time=%sms TTL=%s',[FWbemObject.ProtocolAddress, FWbemObject.ReplySize, FWbemObject.ResponseTime, FWbemObject.TimeToLive])
        else
          IvFbk := IvFbk + sLineBreak + Format('Reply from %s: bytes=%s time=<1ms TTL=%s',[FWbemObject.ProtocolAddress, FWbemObject.ReplySize, FWbemObject.TimeToLive]);
        if FWbemObject.ResponseTime > max then
          max := FWbemObject.ResponseTime;
        if min = 0 then
          min := max;
        if FWbemObject.ResponseTime < min then
          min := FWbemObject.ResponseTime;
        avg := avg + FWbemObject.ResponseTime;
      end else if not VarIsNull(FWbemObject.StatusCode) then
        IvFbk := IvFbk + sLineBreak + Format('Reply from %s: %s', [FWbemObject.ProtocolAddress, PingStateFromCode(FWbemObject.StatusCode)])
      else
        IvFbk := IvFbk + sLineBreak + Format('Reply from %s: %s', [IvAddress, 'Error processing request']);
    end;
    FWbemObject := Unassigned;
    FWbemObjectSet := Unassigned;
    //Sleep(500);
  end;

  IvFbk := IvFbk + sLineBreak + Format('Ping statistics for %s:', [IvAddress]);
  IvFbk := IvFbk + sLineBreak + Format('Packets: Sent=%d, Received=%d, Lost=%d (%d%% loss),', [IvRetries, r, IvRetries - r, Round((IvRetries - r) * 100 / IvRetries)]);
  if r > 0 then begin
    IvFbk := IvFbk + sLineBreak + 'Approximate round trip times in milli-seconds:';
    IvFbk := IvFbk + sLineBreak + Format('Minimum=%dms, Maximum=%dms, Average=%dms',[min, max, Round(avg / r)]);
  end;

  // return
  Result := IvRetries = r;
end;
{$ENDREGION}

{$REGION 'TObjRec'}
function TObjRec.IdOrPathParamEnsure(IvObject, IvIdOrPathParam: string): string;
var
  s: string; // pathstart
begin
  s := Format('Root/%s/Param/', [IvObject]);
  if str.IsInteger(IvIdOrPathParam) then
    Result := IvIdOrPathParam
  else if IvIdOrPathParam.StartsWith(s, true) then
    Result := IvIdOrPathParam
  else
    Result := s + IvIdOrPathParam;
end;

function TObjRec.IdOrPathSwitchEnsure(IvObject, IvIdOrPathSwitch: string): string;
var
  s: string; // pathstart
begin
  s := Format('Root/%s/Switch/', [IvObject]);
  if str.IsInteger(IvIdOrPathSwitch) then
    Result := IvIdOrPathSwitch
  else if IvIdOrPathSwitch.StartsWith(s, true) then
    Result := IvIdOrPathSwitch
  else
    Result := s + IvIdOrPathSwitch;
end;

function TObjRec.DbaExists(IvObject, IvIdOrPath: string; var IvFbk: string): boolean;
var
  i: integer;
  t, f, w, k: string; // tbl, fld, where
begin
  // TEMPORARYCOMMENT
  {
  t := db0.Tbl(IvObject, IvObject);
  f := db0.Fld(IvObject);
  db0.HIdFromIdOrPath(t, f, IvIdOrPath, i, k);
  w := Format('FldId = %d', [i]);
  Result := db0.RecExists(t, w, k);
  }
end;

function TObjRec.DbaContentGet(IvObject, IvIdOrPath, IvDefault: string): string; // *** use FldGet ***
var
  t, f, q, c, k: string; // tbl, fld, sql, content
  i: integer;
begin
  // TEMPORARYCOMMENT
  {
  t := db0.Tbl(IvObject, IvObject);
  f := db0.Fld(IvObject);
  i := db0.HIdFromIdOrPath(t, f, IvIdOrPath);
  q := Format('select FldContent from %s where FldId = %d', [t, i]);
  c := db0.ScalarFD(q, IvDefault, k);
  c := str.CommentRemove(c);
  c := str.EmptyLinesRemove(c);
// TEMPORARYCOMMENT
//  c := rva.Rv(c, true);
  Result := iif.NxD(c, IvDefault);
  }
end;

function TObjRec.DbaContentSet(IvObject, IvIdOrPath, IvValue: string): boolean;
var
  t, f, v, q, k: string; // tbl, fld, value, sql
  i, z: integer;
begin
  (* TEMPORARYCOMMENT
  t := db0.Tbl(IvObject, IvObject);
  f := db0.Fld(IvObject);
  i := db0.HIdFromIdOrPath(t, f, IvIdOrPath);
  v := sql.Val(IvValue);
  q := Format('update %s set FldContent = %s where FldId = %d', [t, v, i]);
  Result := db0.ExecFD(q, z, k); // *** WARNING might delete comments ***
  *)
end;

function TObjRec.DbaParamGet(IvObject, IvIdOrPath: string; IvDefault: string): string;
var
  x: string; // idorpath
begin
  x := IdOrPathParamEnsure(IvObject, IvIdOrPath);
  Result := DbaContentGet(IvObject, x, IvDefault);
end;

function TObjRec.DbaParamSet(IvObject, IvIdOrPath: string; IvValue: string): boolean;
var
  x: string; // idorpath
begin
  x := IdOrPathParamEnsure(IvObject, IvIdOrPath);
  Result := DbaContentSet(IvObject, x, IvValue);
end;

function TObjRec.DbaSwitchGet(IvObject, IvIdOrPath: string; IvDefault: boolean): boolean;
var
  x, c: string; // idorpath, content
begin
  x := IdOrPathSwitchEnsure(IvObject, IvIdOrPath);
  c := DbaContentGet(IvObject, x, BoolToStr(IvDefault));
  Result := StrToBoolDef(c, IvDefault);
end;

function TObjRec.DbaSwitchSet(IvObject, IvIdOrPath: string; IvValue: boolean): boolean;
var
  x: string; // idorpath
begin
  x := IdOrPathSwitchEnsure(IvObject, IvIdOrPath);
  Result := DbaContentSet(IvObject, x, BoolToStr(IvValue));
end;

function TObjRec.RioExists(IvObject, IvIdOrPath: string; var IvFbk: string): boolean;
begin
  // TEMPORARYCOMMENT
//  Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapParamExists(IvIdOrPath, IvFbk);
end;

function TObjRec.RioContentGet(IvObject, IvIdOrPath, IvDefault: string): string;
begin
  Result := '';
  raise Exception.Create(NOT_IMPLEMENTED);
end;

function TObjRec.RioContentSet(IvObject, IvIdOrPath, IvValue: string): boolean;
begin
  Result := false;
  raise Exception.Create(NOT_IMPLEMENTED);
end;

function TObjRec.RioParamGet(IvObject, IvIdOrPath: string; IvDefault: string): string;
var
  k: string;
begin
  // TEMPORARYCOMMENT
//  {o :=} (rio.HttpRio as ISystemSoapMainService).SystemSoapParamGet(IvIdOrPath, Result, IvDefault, k);
end;

function TObjRec.RioParamSet(IvObject, IvIdOrPath: string; IvValue: string): boolean;
var
  k: string;
begin
  // TEMPORARYCOMMENT
//  {o :=} (rio.HttpRio as ISystemSoapMainService).SystemSoapParamSet(IvIdOrPath, IvValue, k);
end;

function TObjRec.RioSwitchGet(IvObject, IvIdOrPath: string; IvDefault: boolean): boolean;
begin
  Result := false;
  raise Exception.Create(NOT_IMPLEMENTED);
end;

function TObjRec.RioSwitchSet(IvObject, IvIdOrPath: string; IvValue: boolean): boolean;
begin
  Result := false;
  raise Exception.Create(NOT_IMPLEMENTED);
end;
{$ENDREGION}

{$REGION 'TOrgRec'}
function TOrgRec.AlphaPath(IvSep: char): string;
begin
  Result := Format('%s%s%s%s', [IvSep, LeftStr(Organization, 1), IvSep, Organization]); // /L/Localhost
end;

function TOrgRec.Copyright: string;
begin
  Result := Format('Copyright © %s, %s, all rights reserved', [FormatDateTime('yyyy', Now), iif.NxD(LegalName, Organization)]);
end;

function TOrgRec.CssPath: string;
begin
  Result := Format('%s\%sCss.css', [DiskPath, Organization]);
end;

function TOrgRec.CssUrl: string;
begin
  Result := Format('%s/%sCss.css', [HomeUrl, Organization]);
end;

function TOrgRec.DbaInit(var IvFbk: string): boolean;
var
  q: string;
begin
  (* TEMPORARYCOMMENT

  {$REGION 'DbaOrganization'}
  db0.DbaCreateIfNotExists('DbaOrganization', IvFbk);
  {$ENDREGION}

  {$REGION 'TblOrganization'}
  q := ''
    + sLineBreak + '   FldId                 integer      NOT NULL' // Id
    + sLineBreak + ' , FldPId                integer      NOT NULL' // PId
    + sLineBreak + ' , FldOrganization       varchar(32)  NOT NULL' // Organization
    + sLineBreak + ' , FldState              varchar(16)      NULL' // State
    + sLineBreak + ' , FldWww                varchar(128)     NULL' // Www
    + sLineBreak + ' , FldExpire             datetime         NULL' // Expire
    + sLineBreak + ' , FldOwner              varchar(32)      NULL' // Owner
    + sLineBreak + ' , FldSlogan             varchar(32)      NULL' // Slogan
    + sLineBreak + ' , FldAbout              varchar(max)     NULL' // About
    + sLineBreak + ' , FldPhone              varchar(32)      NULL' // Phone
    + sLineBreak + ' , FldFax                varchar(32)      NULL' // Fax
    + sLineBreak + ' , FldEmail              varchar(32)      NULL' // Email
    + sLineBreak + ' , FldAddress            varchar(64)      NULL' // Address
    + sLineBreak + ' , FldZipCode            varchar(8)       NULL' // ZipCode
    + sLineBreak + ' , FldCity               varchar(64)      NULL' // City
    + sLineBreak + ' , FldProvince           varchar(16)      NULL' // Province
    + sLineBreak + ' , FldCountry            varchar(16)      NULL' // Country
    + sLineBreak + ' , FldSsn                varchar(32)      NULL' // Ssn
    + sLineBreak + ' , FldVatNumber          varchar(16)      NULL' // VatNumber
    + sLineBreak + ' , FldLegalName          varchar(64)      NULL' // LegalName
    + sLineBreak + ' , FldSymbol             varchar(32)      NULL' // Symbol
    + sLineBreak + ' , FldApiKey             varchar(128)     NULL' // ApiKey
    + sLineBreak + ' , FldNetwork            varchar(max)     NULL' // Network
    + sLineBreak + ' , FldPageFooter         varchar(max)     NULL' // PageFooter
    + sLineBreak + ' , FldEmailTemplate      varchar(max)     NULL' // EmailTemplate
    + sLineBreak + ' , FldCss                varchar(max)     NULL' // Css
    + sLineBreak + ' , FldLogo               image            NULL' // Logo
    + sLineBreak + ' , FldLogoInv            image            NULL' // LogoInv
    + sLineBreak + ' , FldBgColor            varchar(16)      NULL' // BgColor
    + sLineBreak + ' , FldFgColor            varchar(16)      NULL' // FgColor
    + sLineBreak + ' , FldBorderColor        varchar(16)      NULL' // BorderColor
    + sLineBreak + ' , FldColor              varchar(16)      NULL' // Color
    + sLineBreak + ' , FldColor2             varchar(16)      NULL' // Color2
    + sLineBreak + ' , FldInfoColor          varchar(16)      NULL' // InfoColor
    + sLineBreak + ' , FldSuccessColor       varchar(16)      NULL' // SuccessColor
    + sLineBreak + ' , FldWarningColor       varchar(16)      NULL' // WarningColor
    + sLineBreak + ' , FldDangerColor        varchar(16)      NULL' // DangerColor
    + sLineBreak + ' , FldJson               varchar(max)     NULL' // Json
    + sLineBreak + ' , FldPageSwitch         varchar(512)     NULL' // PageSwitch
    + sLineBreak + ' , FldContentSwitch      varchar(512)     NULL' // ContentSwitch
  ;
  if db0.TblCreateIfNotExists('DbaOrganization', 'TblOrganization', q, IvFbk) then begin
  //db0.RecDefaultInsert('DbaOrganization.dbo.TblOrganization', IvFbk);
  //db0.RecTestInsert('DbaOrganization.dbo.TblOrganization', ['FldOrganization'], ['Wks'], IvFbk);
  end;
  {$ENDREGION}

  {$REGION 'End'}
  IvFbk := 'Organization database initialized';
  Result := true;
  {$ENDREGION}
  *)
end;

function TOrgRec.DbaInsert(var IvFbk: string): boolean;
var
  q, k: string;
  z: integer;
begin
  (* TEMPORARYCOMMENT

  {$REGION 'Insert'}
  Id := db0.TblIdNext('DbaOrganization.dbo.TblOrganization');
  PId := ROOT_NEW_ID;
  q :=           'insert into DbaOrganization.dbo.TblOrganization'
  + sLineBreak + 'select'
  + sLineBreak + '    ' + sql.Val(Id)                         // Id
  + sLineBreak + '  , ' + sql.Val(PId)                        // PId
  + sLineBreak + '  , ' + sql.Val(Organization)               // Organization
  + sLineBreak + '  , ' + sql.Val(sta.Active.Key)             // State
  + sLineBreak + '  , ' + sql.Val(Www)                        // Www
  + sLineBreak + '  , ' + sql.Val(EndOfTheYear(Now))          // Expire
  + sLineBreak + '  , ' + sql.Val('')                         // Owner
  + sLineBreak + '  , ' + sql.Val('')                         // Slogan
  + sLineBreak + '  , ' + sql.Val('[RvOrganization()] is...') // About
  + sLineBreak + '  , ' + sql.Val('')                         // Phone
  + sLineBreak + '  , ' + sql.Val('')                         // Fax
  + sLineBreak + '  , ' + sql.Val('')                         // Email
  + sLineBreak + '  , ' + sql.Val('')                         // Address
  + sLineBreak + '  , ' + sql.Val('')                         // ZipCode
  + sLineBreak + '  , ' + sql.Val('')                         // City
  + sLineBreak + '  , ' + sql.Val('')                         // Province
  + sLineBreak + '  , ' + sql.Val('')                         // Country
  + sLineBreak + '  , ' + sql.Val('')                         // Ssn
  + sLineBreak + '  , ' + sql.Val('')                         // VatNumber
  + sLineBreak + '  , ' + sql.Val('')                         // LegalName
  + sLineBreak + '  , ' + sql.Val('')                         // Symbol
  + sLineBreak + '  , ' + sql.Val('')                         // ApiKey
  + sLineBreak + '  , ' + sql.Val('')                         // Network
  + sLineBreak + '  , ' + sql.Val('')                         // PageFooter
  + sLineBreak + '  , ' + sql.Val('')                         // EmailTemplate
  + sLineBreak + '  , ' + sql.Val('')                         // Css
  + sLineBreak + '  , ' + sql.Val('')                         // Logo
  + sLineBreak + '  , ' + sql.Val('')                         // LogoInv
  + sLineBreak + '  , ' + sql.Val('')                         // BgColor
  + sLineBreak + '  , ' + sql.Val('')                         // FgColor
  + sLineBreak + '  , ' + sql.Val('')                         // BorderColor
  + sLineBreak + '  , ' + sql.Val('')                         // Color
  + sLineBreak + '  , ' + sql.Val('')                         // Color2
  + sLineBreak + '  , ' + sql.Val('')                         // InfoColor
  + sLineBreak + '  , ' + sql.Val('')                         // SuccessColor
  + sLineBreak + '  , ' + sql.Val('')                         // WarningColor
  + sLineBreak + '  , ' + sql.Val('')                         // DangerColor
  + sLineBreak + '  , ' + sql.Val('')                         // Json
  + sLineBreak + '  , ' + sql.Val('')                         // PageSwitch
  + sLineBreak + '  , ' + sql.Val('')                         // ContentSwitch
  ;
  Result := db0.ExecFD(q, z, k);
  if not Result then begin
    IvFbk := k;
    lg.I(IvFbk, 'ORGANIZATION INSERT');
  end else
    IvFbk := Format('Organization %s record inserted', [Organization]);
  {$ENDREGION}
  *)
end;

function TOrgRec.DbaSelect(const IvOrganization: string; var IvFbk: string): boolean;
var
  d: TFDDataSet;
  q, k: string;
begin
  (* TEMPORARYCOMMENT

  // key
  Organization := IvOrganization;

  {$REGION 'Insert'}
  if not db0.RecExists('DbaOrganization.dbo.TblOrganization', 'FldOrganization', Organization, k) then begin
    lg.I('Organization record does not exists, create it now');
    PId := ROOT_NEW_ID;
    DbaInsert(k);
  end;
  {$ENDREGION}

  {$REGION 'Select'}
  try
    q := Format('select * from DbaOrganization.dbo.TblOrganization where FldOrganization = ''%s''', [Organization]);
    Result := db0.DsFD(q, d, k);
    Id             := d.FieldByName('FldId'           ).AsInteger ;              // Id
    PId            := d.FieldByName('FldPId'          ).AsInteger ;              // PId
    Organization   := d.FieldByName('FldOrganization' ).AsString  ;              // Organization
    State          := d.FieldByName('FldState'        ).AsString  ;              // State
    Www            := d.FieldByName('FldWww'          ).AsString  ;              // Www
    Expire         := d.FieldByName('FldExpire'       ).AsDateTime;              // Expire
    Owner          := d.FieldByName('FldOwner'        ).AsString  ;              // Owner
    Slogan         := d.FieldByName('FldSlogan'       ).AsString  ;              // Slogan
    About          := d.FieldByName('FldAbout'        ).AsString  ;              // About
    Phone          := d.FieldByName('FldPhone'        ).AsString  ;              // Phone
    Fax            := d.FieldByName('FldFax'          ).AsString  ;              // Fax
    Email          := d.FieldByName('FldEmail'        ).AsString  ;              // Email
    Address        := d.FieldByName('FldAddress'      ).AsString  ;              // Address
    ZipCode        := d.FieldByName('FldZipCode'      ).AsString  ;              // ZipCode
    City           := d.FieldByName('FldCity'         ).AsString  ;              // City
    Province       := d.FieldByName('FldProvince'     ).AsString  ;              // Province
    Country        := d.FieldByName('FldCountry'      ).AsString  ;              // Country
    Ssn            := d.FieldByName('FldSsn'          ).AsString  ;              // Ssn
    VatNumber      := d.FieldByName('FldVatNumber'    ).AsString  ;              // VatNumber
    LegalName      := d.FieldByName('FldLegalName'    ).AsString  ;              // LegalName
    Symbol         := d.FieldByName('FldSymbol'       ).AsString  ;              // Symbol
    ApiKey         := d.FieldByName('FldApiKey'       ).AsString  ;              // ApiKey
    Network        := d.FieldByName('FldNetwork'      ).AsString  ;              // Network
    PageFooter     := d.FieldByName('FldPageFooter'   ).AsString  ;              // PageFooter
    EmailTemplate  := d.FieldByName('FldEmailTemplate').AsString  ;              // EmailTemplate
    Css            := d.FieldByName('FldCss'          ).AsString  ;              // Css
  //BlobFieldToBitmap(d.FieldByName('FldLogo'         ) as TBlobField, Logo   ); // Logo
  //BlobFieldToBitmap(d.FieldByName('FldLogoInv'      ) as TBlobField, LogoInv); // LogoInv
    BgColor        := d.FieldByName('FldBgColor'      ).AsString  ;              // BgColor
    FgColor        := d.FieldByName('FldFgColor'      ).AsString  ;              // FgColor
    BorderColor    := d.FieldByName('FldBorderColor'  ).AsString  ;              // BorderColor
    Color          := d.FieldByName('FldColor'        ).AsString  ;              // Color
    Color2         := d.FieldByName('FldColor2'       ).AsString  ;              // Color2
    InfoColor      := d.FieldByName('FldInfoColor'    ).AsString  ;              // InfoColor
    SuccessColor   := d.FieldByName('FldSuccessColor' ).AsString  ;              // SuccessColor
    WarningColor   := d.FieldByName('FldWarningColor' ).AsString  ;              // WarningColor
    DangerColor    := d.FieldByName('FldDangerColor'  ).AsString  ;              // DangerColor
    Json           := d.FieldByName('FldJson'         ).AsString  ;              // Json
    PageSwitch     := d.FieldByName('FldPageSwitch'   ).AsString  ;              // HPageSwitch
    ContentSwitch  := d.FieldByName('FldContentSwitch').AsString  ;              // HContentSwitch
  //if iis.Nx(PageSwitch)    then PageSwitch    := sys.PAGE_SWITCH_DEFAULT;
  //if iis.Nx(ContentSwitch) then ContentSwitch := sys.CONTENT_SWITCH_DEFAULT;
  finally
    d.Free;
  end;
  {$ENDREGION}

  {$REGION 'End'}
  IvFbk := Format('Organization %s record selected', [Organization]);
  Result := true;
  {$ENDREGION}
  *)
end;

function TOrgRec.DiskPath: string;
begin
  Result := sys.ORG_DIR + AlphaPath('\');
end;

function TOrgRec.DskInit(var IvFbk: string): boolean;
begin
  raise Exception.Create(NOT_IMPLEMENTED);
end;

function TOrgRec.EmailD(var IvFbk: string; IvToCsv, IvCcCsv, IvBcCsv, IvSubject, IvTitle, IvContent: string; IvSaveToDba: boolean): boolean;
begin
// TEMPORARYCOMMENT
//  Result := eml.Send(IvFbk, org.Email, 'Danger' , IvToCsv, IvCcCsv, IvBcCsv, IvSubject, IvTitle, IvContent, IvSaveToDba); // orgtemplate? EMAIL_HTML
end;

function TOrgRec.EmailI(var IvFbk: string; IvToCsv, IvCcCsv, IvBcCsv, IvSubject, IvTitle, IvContent: string; IvSaveToDba: boolean): boolean;
begin
// TEMPORARYCOMMENT
//  Result := eml.Send(IvFbk, org.Email, 'Info'   , IvToCsv, IvCcCsv, IvBcCsv, IvSubject, IvTitle, IvContent, IvSaveToDba);
end;

function TOrgRec.EmailS(var IvFbk: string; IvToCsv, IvCcCsv, IvBcCsv, IvSubject, IvTitle, IvContent: string; IvSaveToDba: boolean): boolean;
begin
// TEMPORARYCOMMENT
//  Result := eml.Send(IvFbk, org.Email, 'Success', IvToCsv, IvCcCsv, IvBcCsv, IvSubject, IvTitle, IvContent, IvSaveToDba);
end;

function TOrgRec.EmailW(var IvFbk: string; IvToCsv, IvCcCsv, IvBcCsv, IvSubject, IvTitle, IvContent: string; IvSaveToDba: boolean): boolean;
begin
// TEMPORARYCOMMENT
//  Result := eml.Send(IvFbk, org.Email, 'Warning', IvToCsv, IvCcCsv, IvBcCsv, IvSubject, IvTitle, IvContent, IvSaveToDba);
end;

function TOrgRec.HomePath: string;
begin
  Result := DiskPath;
end;

function TOrgRec.HomeUrl: string;
begin
  Result := '/Organization' + AlphaPath;
end;

function TOrgRec.IconPath: string;
begin
  Result := Format('%s\%sIcon.ico', [DiskPath, Organization]);
end;

function TOrgRec.IconUrl: string;
begin
  Result := Format('%s/%sIcon.ico', [HomeUrl, Organization]);
end;

function TOrgRec.Info: string;
begin
  Result := Format('%s - %s', [Organization, LegalName]);
end;

function TOrgRec.IsExpired(var IvFbk: string): boolean;
begin
  Result := Expire < Now;
  if Result then
    IvFbk := Format('Organization %s is expired on %s', [Organization, DateTimeToStr(Expire)])
  else
    IvFbk := Format('Organization %s is not expired, will expire on %s', [Organization, DateTimeToStr(Expire)]);
end;

function TOrgRec.IsValid(var IvFbk: string): boolean;
begin
  Result :=
      (Id > 100)
  and (Organization <> '')
  and (Www <> '')
//and (IconPath <> '')
  ;
  if Result then
    IvFbk := 'Organization is valid'
  else
    IvFbk := 'Organization is invalid, id must be a positive integer or organization must be not empty or www must be not empty';
end;

procedure TOrgRec.LogoDraw(IvBmp: TBitmap);
var
  k: string;
begin
  // TEMPORARYCOMMENT
//  bmp.DrawLogo(IvBmp, 'WK', 'Circle', '4F81BDFF', k);
end;

function TOrgRec.LogoInvPath: string;
begin
  Result := Format('%s\%sLogoInv.png', [DiskPath, Organization]);
end;

function TOrgRec.LogoInvUrl: string;
begin
  Result := Format('%s/%sLogoInv.png', [HomeUrl, Organization]);
end;

function TOrgRec.LogoPath: string;
begin
  Result := Format('%s\%sLogo.png', [DiskPath, Organization]);
end;

function TOrgRec.LogoSmallInvPath: string;
begin
  Result := Format('%s\%sLogoSmallInv.png', [DiskPath, Organization]);
end;

function TOrgRec.LogoSmallInvUrl: string;
begin
  Result := Format('%s/%sLogoSmallInv.png', [HomeUrl, Organization]);
end;

function TOrgRec.LogoSmallPath: string;
begin
  Result := Format('%s\%sLogoSmall.png', [DiskPath, Organization]);
end;

function TOrgRec.LogoSmallUrl: string;
begin
  Result := Format('%s/%sLogoSmall.png', [HomeUrl, Organization]);
end;

function TOrgRec.LogoUrl: string;
begin
  Result := Format('%s/%sLogo.png', [HomeUrl, Organization]);
end;

function TOrgRec.RegistryPath: string;
begin
  Result := Format('\Software\%s\Wks', [Organization]);
end;

function TOrgRec.RioInit(const IvOrganization: string; var IvFbk: string): boolean;
var
  r: TOrgRem;
begin
  r := TOrgRem.Create;
  try
    // TEMPORARYCOMMENT
//  Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapOrganizationGet(IvOrganization, r, IvFbk);
    if Result then begin
      Organization := r.Organization;
      Acronym      := r.Acronym     ;
      Name         := r.Name        ;
      Www          := r.Www         ;
      Slogan       := r.Slogan      ;
    //LogoUrl      := r.LogoUrl     ;
// TEMPORARYCOMMENT
//      gra.FromByteArray(LogoGraphic, r.LogoBytes);
    end;
  finally
    FreeAndNil(r);
  end;
end;

function TOrgRec.TreePath: string;
begin
  Result := 'Root/Organization' + AlphaPath;
end;

function TOrgRec.Url: string;
begin
  Result := WksAllUnit.url.Ensure(Www);
end;
{$ENDREGION}

{$REGION 'TPatRec'}
function TPatRec.DelimiterEnsure(IvPath: string): string;
begin
  Result := IncludeTrailingPathDelimiter(IvPath);
end;

function TPatRec.Ext(IvFile: string): string;
begin
  Result := LowerCase(ExtractFileExt(IvFile)); // .txt
end;

function TPatRec.ExtEnsure(IvExt: string): string;
begin
  if IvExt = '' then
    Exit;
  Result := LowerCase(IvExt);
  if Result[1] <> '.' then
    Result := '.' + Result;
end;

function TPatRec.ExtHas(IvFile: string): boolean;
begin
  Result := IvFile.Contains('.');
end;

function TPatRec.Name(IvFile: string): string;
begin
  // removepath
  Result := ExtractFileName(IvFile);
  // removeext
  Result := Copy(Result, 1, Pos('.', Result)-1);
end;

function TPatRec.NameChange(const IvFile, IvNameNew: string): string;
var                                // C:\Path\Name.ext
  p, n, e: string;
begin
  p := ExtractFilePath(IvFile); // C:\Path\
  n := Name(IvFile);            // Name
  e := Ext(IvFile);             // .ext
  Result := p + IvNameNew + e;  // FsFileMove(IvFile, IvNameNew + e);
end;

function TPatRec.NameDotExt(IvFile: string): string;
begin
  Result := ExtractFileName(IvFile); // Aaa.txt
end;

function TPatRec.Path(IvFile: string): string;
begin
//Result := ExtractFilePath(IvFile); // will include the final \
  Result := ExtractFileDir(IvFile);  // will NOT include the final \
end;

function TPatRec.TreePathIs(IvThreePath: string): boolean;
begin
  Result := IvThreePath.StartsWith('/Root') or IvThreePath.StartsWith('Root');
end;

function TPatRec.TreePathNormalize(IvThreePath: string): string;
begin
  Result := str.Replace(IvThreePath, '\', '/');
  Result := str.Replace(Result     , '.', '/');
  if not Result.IsEmpty then
    if Result[1] = '/' then
      Delete(Result, 1, 1);
end;

function TPatRec.Volume(IvFile: string): string;
begin
  Result := ExtractFileDrive(IvFile);
end;
{$ENDREGION}

{$REGION 'TPopRec'}
function TPopRec.DbaSelect(var IvFbk: string): boolean;
begin
  IvFbk  := NOT_IMPLEMENTED;
  Result := false;

  Host          := '';
  Port          := '';
  Username      := '';
  Password      := '';
  TrySecureAuth := true;
  NewerMsgFirst := true;
  CleanOnExit   := true;
end;

function TPopRec.RioInit(IvOrganization: string; var IvFbk: string): boolean;
var
  h, p, u, w: string;
begin
 // TEMPORARYCOMMENT
//   Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapPop3Get(IvOrganization, h, p, u, w, IvFbk);
  if Result then begin
    Organization  := IvOrganization;
    Host          := h;
    Port          := p;
    Username      := u;
    Password      := w;
    TrySecureAuth := true;
    NewerMsgFirst := true;
    CleanOnExit   := false;
    Result        := true;
  end;
end;
{$ENDREGION}

{$REGION 'TPxyRec'}
procedure TPxyRec.HttpRioProxySet(var IvHttpRio: THTTPRIO);
begin
  if not Use then
    Exit;
  IvHttpRio.HTTPWebNode.Proxy    := Format('%s:%s', [Address, Port]);
  IvHttpRio.HTTPWebNode.UserName := Username;
  IvHttpRio.HTTPWebNode.Password := Password;
end;

procedure TPxyRec.SoapConnectionProxySet(var IvSoapConnection: TSoapConnection);
begin
  if not Use then
    Exit;
  IvSoapConnection.Proxy    := Format('%s:%s', [Address, Port]);
  IvSoapConnection.Username := Username;
  IvSoapConnection.Password := Password;
end;
{$ENDREGION}

{$REGION 'TRexRec'}
function TRexRec.Extract(IvString, IvPattern: string; IvOpt: TRegExOptions): string;
var
  r: TRegEx;
  m: TMatch;
begin
  r := TRegEx.Create(IvPattern, IvOpt);
  m := r.Match(IvString);
  if m.Success then begin
    if (m.Groups.Count > 0) then begin
      if m.Groups.Count = 1 then // no group(s)
        Result := m.Groups[0].Value
      else
        Result := m.Groups[1].Value // group(s) present, but group[0] is the whole match
      ;
    end else
      Result := '';
  end else
    Result := '';
end;

function TRexRec.ExtractGroup(IvString, IvPattern: string; IvGroup: integer; IvOpt: TRegExOptions): string;
begin
  Result := TRegEx.Match(IvString, IvPattern).Groups[IvGroup].Value;
end;

function TRexRec.ExtractVeVe(IvString, IvPattern: string; IvOpt: TRegExOptions): TStringMatrix;
var
  i, j: integer;
  r: TRegEx;
  m: TMatch;
begin
  // init
  r := TRegEx.Create(IvPattern, IvOpt);

  // matches
  m := r.Match(IvString);

  // scan
  i := -1;
  SetLength(Result, 0);
  while m.Success do begin
    // one
    Inc(i);
    SetLength(Result, Length(Result)+1);
    SetLength(Result[i], 0);
  //LogFmt('Match %d: %s', [i, m.Value]);

    // group 0 is the entire match, so count will always be at least 1 for a group-match
    for j := 0 to m.Groups.Count-1 do begin
    //LogFmt('Group  %d%d: %s', [i, j, m.Groups[j].Value]);
      SetLength(Result[i], Length(Result[i])+1);
      Result[i, j] := m.Groups[j].Value;
    end;

    // next
    m := m.NextMatch;
  end;
end;

function TRexRec.Has(IvString, IvPattern: string; IvOpt: TRegExOptions): boolean;
var
  r: TRegEx;
  m: TMatch;
begin
  try
    r := TRegEx.Create(IvPattern, IvOpt);
  //Result := r.IsMatch(IvString);
    m := r.Match(IvString);
    Result := m.Success;
  except
    on e: ERegularExpressionError do begin
    //Result := false;
      raise e;
    end;
  end;
end;

procedure TRexRec.Replace(var IvString: string; IvReOut, IvStringIn: string; IvOpt: TRegExOptions; IvCount: integer);
var
  r: TRegEx;
  m: TMatch;

  procedure MatchProcess(var IvMatch: TMatch; var IvZ: integer);
  begin
    // replace-SINGLE
    IvString := StringReplace(IvString, IvMatch.Value, IvStringIn, []); // rfReplaceAll

    // nextrecursive-ALL
    if IvZ = -1 then begin
      IvMatch := IvMatch.NextMatch;
      if IvMatch.Success then
        MatchProcess(IvMatch, IvZ);

    // nextrecursive-COUNTING
    end else begin
      Dec(IvZ);
      if IvZ > 0 then begin
        IvMatch := IvMatch.NextMatch;
        if IvMatch.Success then
          MatchProcess(IvMatch, IvZ);
      end;
    end;
  end;

begin
  // 0 = donothing
  if IvCount = 0 then
    Exit;

  // -1= replaceall; >1 = replacecounting
  try
    r := TRegEx.Create(IvReOut, IvOpt);
    m := r.Match(IvString);
    if m.Success then
      MatchProcess(m, IvCount);
  except
    raise Exception.Create('Error in ReReplace()');
  end;

{ not-working
  r := TRegEx.Create(IvReOut, IvOpt);
  if IvCount < 0 then
    IvText := r.Replace(IvString, IvStringIn) // replace all
  else
    IvText := r.Replace(IvString, IvStringIn, IvCount);
}
end;

procedure TRexRec.ReplaceEx(var IvString: string; IvReWithOneGroupOut, IvStringWithOnePlaceholderIn: string; IvOpt: TRegExOptions);
var
  r: TRegEx;
  m: TMatch;
  {j,} k: integer;
  g, o, i: string; // thegroup, thestringout, thestringin
begin
  // re
  r := TRegEx.Create(IvReWithOneGroupOut, IvOpt);

  // matches
  m := r.Match(IvString);

  // walkmatches
//j := 0;
  while m.Success do begin
  //Inc(j);
  //lg.I(Format('%d) Match = %s', [j, m.Value]));

    // walkgroups
    for k := 1 to m.Groups.Count - 1 do begin // group 0 is the entire match, so count will always be at least 1 for a match
      g := m.Groups[k].Value;
    //lg.I(Format('%d.%d) Group = %s', [j, k, m.Groups[k].Value]));

      // out
      o := m.Value; // m.Groups[0].Value
    //lg.I(Format('%d.%d) Out = %s', [j, k, o]));

      // in
    //i := Format(IvStringWithOnePlaceholderIn, [g]);
      i := StringReplace(IvStringWithOnePlaceholderIn, '%s', g, [rfReplaceAll]);
    //lg.I(Format('%d.%d) In = %s', [j, k, i]));

      // replace
      IvString := StringReplace(IvString, o, i, [rfReplaceAll]);
    //lg.I(Format('IvText = %s', [IvText]));
    end;

    // next
    m := m.NextMatch;
  end;
end;

procedure TRexRec.Search(IvString, IvPattern: string; IvStart: integer; var IvPosition, IvLenght: integer; IvOpt: TRegExOptions);
var
  r: TRegEx;
  m: TMatch;
  i: integer; // instance
begin
  r := TRegEx.Create(IvPattern, IvOpt);
  m := r.Match(IvString);
  i := 0;
  IvPosition := -1;
  IvLenght := 0;
  while m.Success do begin
    if i = IvStart then begin
      IvPosition := m.Index;
      IvLenght := m.Length;
      Exit;
    end;
    Inc(i);
    m := m.NextMatch;
  end;
end;

procedure TRexRec.Search(IvString, IvPattern: string; var IvPosition, IvLenght: integer; IvOpt: TRegExOptions);
begin
  Search(IvString, IvPattern, 0, IvPosition, IvLenght, IvOpt);
end;
{$ENDREGION}

{$REGION 'TRioRec'}
function TRioRec.FieldGet(const IvDot: string; IvId: integer; var IvValue: variant; IvDefault: variant; var IvFbk: string): boolean;
begin
  // TEMPORARYCOMMENT
//  Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapFieldGet(usr.Organization, usr.Username, ses.Session, IvDot, IvId, IvValue, IvDefault, IvFbk);
end;

function TRioRec.FieldGetWhere(const IvDot: string; IvWhere: string; var IvValue: variant; IvDefault: variant; var IvFbk: string): boolean;
begin
  // TEMPORARYCOMMENT
//  Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapFieldGetWhere(usr.Organization, usr.Username, ses.Session, IvDot, IvWhere, IvValue, IvDefault, IvFbk);
end;

function TRioRec.FieldSet(const IvDot: string; IvId: integer; const IvValue: variant; var IvFbk: string): boolean;
begin
  // TEMPORARYCOMMENT
//  Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapFieldSet(usr.Organization, usr.Username, ses.Session, IvDot, IvId, IvValue, IvFbk);
end;

function TRioRec.FieldSetWhere(const IvDot: string; IvWhere: string; const IvValue: variant; var IvFbk: string): boolean;
begin
  // TEMPORARYCOMMENT
//  Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapFieldSetWhere(usr.Organization, usr.Username, ses.Session, IvDot, IvWhere, IvValue, IvFbk);
end;

function TRioRec.HttpRio(IvObj: string): THTTPRIO;
var
  u: string;
begin
  // url
  u := RioUrl(IvObj);

  // exit
  if iis.Nx(u) then begin
    raise Exception.CreateFmt('Unable to return HttpRio for %s object, Rio url is empty: "%s"', [IvObj, LowerCase(u)]);
    Result := nil;
    Exit;
  end;

  // httprio
  Result := THTTPRIO.Create(nil);
  // it uses interface reference counting to manage its lifetime
  // if no owner is specified it free itself when interface is released!
  // typecasting it to IXxx creates a temporary interface reference that gets released at the end of the function

  // proxy
  if pxy.Use then
    pxy.HttpRioProxySet(Result);

  // viaurl
  Result.URL := u;

  // viawsdlserviceport
//Result.WSDLLocation := '?';
//Result.Service := '?';
//Result.Port := '?';
end;

function TRioRec.HttpRioUrlSet(var IvFbk: string; var IvHttpRio: THTTPRIO; IvObj: string): boolean;
var
  u: string;
begin
  Result := sop.SoapRioUrl(IvObj, 'Main', u, IvFbk);
  if not Result then
    Exit;
  IvHttpRio.URL := u; // http://localhost/WksXxxSoapProject.dll/soap/IXxxSoapMainService
end;

function TRioRec.IdExists(const IvDot: string; IvId: integer; var IvFbk: string): boolean;
begin
  // TEMPORARYCOMMENT
//  Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapIdExists(IvDot, IvId, IvFbk);
end;

function TRioRec.IdMax(const IvTable, IvWhere: string; var IvIdMax: integer; var IvFbk: string): boolean;
begin
  // TEMPORARYCOMMENT
//  Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapIdMax(IvTable, IvWhere, IvIdMax, IvFbk);
end;

function TRioRec.IdNext(const IvTable, IvWhere: string; var IvIdNext: integer; var IvFbk: string): boolean;
begin
  // TEMPORARYCOMMENT
//  Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapIdNext(IvTable, IvWhere, IvIdNext, IvFbk);
end;

function TRioRec.IdOf(const IvDot, IvKeyFld, IvKeyValue: string; var IvId: integer; var IvFbk: string): boolean;
var
  v: variant;
begin
  Result := FieldGetWhere(IvDot, IvKeyFld + ' = ' + sql.Val(IvKeyValue), v, -1, IvFbk);
  IvId := v;
end;

function TRioRec.ObjPropGet(const IvDot: string; IvId: integer; var IvValue: variant; IvDefault: variant; var IvFbk: string): boolean;
var
  x: string; // dot
begin
  // zip
  x := Trim(IvDot);

  // check
  Result := dot.IsValid(x, IvFbk);
  if not Result then begin
    IvValue := IvDefault;
    Exit;
  end;

  // go
  Result := FieldGet(x, IvId, IvValue, IvDefault, IvFbk);
  if Result then
    IvFbk := Format('%s(%d): %s', [x, IvId, IvValue])
  else
    IvFbk := Format('Unable to read %s(%d), using default %s', [x, IvId, IvValue]);
end;

function TRioRec.ObjPropSet(const IvDot: string; IvId: integer; const IvValue: variant; var IvFbk: string): boolean;
var
  x: string; // dot
begin
  // zip
  x := Trim(IvDot);

  // check
  Result := dot.IsValid(x, IvFbk);
  if not Result then
    Exit;

  // go
  Result := FieldSet(x, IvId, IvValue, IvFbk);
  if Result then
    IvFbk := Format('%s(%d) changed to %s', [x, IvId, IvValue])
  else
    IvFbk := Format('Unable to changed %s(%d) to %s', [x, IvId, IvValue]);
end;

function TRioRec.OIdIdExists(const IvDot, IvOFld: string; IvOId, IvId: integer; var IvFbk: string): boolean;
begin
  // TEMPORARYCOMMENT
//  Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapOIdIdExists(IvDot, IvOFld, IvOId, IvId, IvFbk);
end;

function TRioRec.RioUrl(IvObj: string): string;
//var
//  u: string;
//begin
//  u := SoapUrl(IvObj) + Format(SOAP_RIO_URL, [IvObj, IvService]);
//  Result := UrlExists(u, sys.URL_EXIST_CHECK_SKIP);
//  if not Result then begin
//    IvUrl := '';
//    IvFbk := Format(SOAP_SERVER_RIO_URL_FOUND_NO_RS, [Www]);
//  end else begin
//    IvUrl := u;
//    IvFbk := Format(SOAP_SERVER_RIO_URL_FOUND_OK_RS, [Www]);
//  end;
begin
  Result := Format('%s/Wks%sSoapProject.dll/soap/I%sSoapMainService', [srv.Url, IvObj, IvObj]);
end;
{$ENDREGION}

{$REGION 'TRndRec'}
function TRndRec.Int(IvBegin, IvEnd: integer): integer;
begin
  Result := IvBegin + Random(IvEnd);
end;

function TRndRec.Str(IvLenght: integer): string;
const
  c = 'abcdefghijklmnopqrstuvwxyz';
var
  s: string;
  i, n: integer;
begin
  Randomize;
  s := '';
  for i := 1 to IvLenght do begin
    n := Random(Length(c)) + 1;
    s := s + c[n];
  end;
  Result := s;
end;
{$ENDREGION}

{$REGION 'TSesRec'}
function TSesRec.DbaNewAndSet(IvOrganization, IvUsername, IvPassword: string; var IvFbk: string): boolean;
var
  q, w: string;
  z: integer;
begin
  (* TEMPORARYCOMMENT

  // exit
  Result := iis.Ex(IvOrganization) and iis.Ex(IvUsername) and iis.Ex(IvPassword);
  if not Result then begin
    IvFbk := 'Unable to create new session, organization or username or password are empty';
    Exit
  end;

  // NEW
  Randomize(); // allows for use of the random() function
  Session := IntToStr(Random(999999));

  // db0
  w := usr.UsernameWhere(IvOrganization, IvUsername, IvPassword, false);
  q := Format('update DbaUser.dbo.TblUser set FldSession = ''%s'' where %s', [Session, w]);
  db0.ExecFD(q, z, IvFbk);
  *)
end;

function TSesRec.DbaUnset(IvOrganization, IvUsername, IvPassword: string; var IvFbk: string): boolean;
var
  q, w: string;
  z: integer;
begin
  (* TEMPORARYCOMMENT

  w := usr.UsernameWhere(IvOrganization, IvUsername, IvPassword, false);
  q := Format('update DbaUser.dbo.TblUser set FldSession = ''%s'' where %s', [Session, w]);
  Result := db0.ExecFD(q, z, IvFbk);
  *)
end;

function TSesRec.Info: string;
begin
  Result := Format('Session: %s', [Session]);
end;

function TSesRec.RioClose(IvOrganization, IvUsername: string; var IvFbk: string): boolean;
begin
  // flag
  if not HasBeenOpen then begin
    IvFbk := 'Session is not open, needless to close it';
    Exit;
  end;

  // rio
  // TEMPORARYCOMMENT
//  Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapSessionClose(IvOrganization, IvUsername, Session, IvFbk);
end;

function TSesRec.RioExists(IvOrganization, IvUsername, IvSession: string; var IvFbk: string): boolean;
begin
  // TEMPORARYCOMMENT
//  Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapSessionExists(usr.Organization, usr.Username, Session, IvFbk);
end;

function TSesRec.RioOpen(IvOrganization, IvUsername, IvPassword: string; var IvFbk: string): boolean;
begin
  // TEMPORARYCOMMENT
//  Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapSessionOpen(IvOrganization, IvUsername, IvPassword, net.Domain, net.Host, net.OsLogin, net.IpLan, net.IpWan, byn.Tag, byn.Ver, ses.Session, ses.BeginDateTime, IvFbk);

  // flag
  HasBeenOpen := Result;
end;
{$ENDREGION}

{$REGION 'TSmtRec'}
function TSmtRec.DbaSelect(var IvFbk: string): boolean;
begin
  IvFbk  := NOT_IMPLEMENTED;
  Result := false;

  Host          := '';
  Port          := '';
  Username      := '';
  Password      := '';
end;

function TSmtRec.RioInit(IvOrganization: string; var IvFbk: string): boolean;
var
  h, p, u, w: string;
begin
  // TEMPORARYCOMMENT
//  Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapSmtpGet(IvOrganization, h, p, u, w, IvFbk);
  if Result then begin
    Organization := IvOrganization; // Wks          , Lfoundry
    Host         := h;              // www.wks.cloud, aivmcas01.ai.sys.com
    Port         := p;              // 25           , 25
    Username     := u;
    Password     := w;
  end;
end;
{$ENDREGION}

{$REGION 'TSqlRec'}
function TSqlRec.Filter(IvFilter, IvFieldToSearchCsv, IvAdditionalExplicitFilter: string): string;
var
  v: TStringDynArray; // fieldvec
  f: string;
  i: integer;
begin
  // vector
  v := str.Split(IvFieldToSearchCsv);

  // filter
  f := '(RvFld like ' + QuotedStr('*' + IvFilter + '*') + ')';

  // decore
  for i := Low(v) to High(v) do
    v[i] := StringReplace(f, 'RvFld', v[i], []); // integers could not be 'like', try CAST([FldId] as varchar(10))

  // build
  f := v[0];
  for i := Low(v)+1 to High(v) do
    if (f <> '') and (v[i] <> '') then
      f := f + ' OR ' + v[i];

  // additionalexplicitfilter
  if IvAdditionalExplicitFilter <> '' then
    f := '(' + f + ') and (' + IvAdditionalExplicitFilter + ')';

  // **replace
  repeat
    f := StringReplace(f, '**', '*', [rfReplaceAll]);
  until Pos('**', f) = 0;

  // *replace
  Result := StringReplace(f, '*', '%', [rfReplaceAll]);

  // zzz
  // IvFieldVector, IvOperatoVector, IvValueVector: array of string
  //for i := Low(IvFieldVector) to High(IvFieldVector) do begin
  //  if IvValueVector[i] = '' then
  //    Continue;
  //  f := f + Format(' and (%s %s ''%s'')', [IvFieldVector[i], IvOperatoVector[i], IvValueVector[i]]);
  //end;
  //if f.StartsWith(' and ') then
  //  Delete(f, 1, 5);
end;

function TSqlRec.Val(IvValue: variant): string;
begin
  if      VarIsEmpty(IvValue) or VarIsNull(IvValue) or (Trim(IvValue) = '') or (Trim(IvValue) = {'NULL'}'') then
    Result := 'null'
  else if VarIsType(IvValue, varBoolean) then
    Result := iif.Str(IvValue, '1', '0')
  else if VarIsNumeric(IvValue) then
    Result := Trim(IvValue)
  else if VarIsFloat(IvValue) then
    Result := Trim(IvValue)
  else if VarIsType(IvValue, varDate) or (VarType(IvValue) = 271) then // 271 = SQLTimeStampVariantType
    Result := dat.ForSql(IvValue).QuotedString
//else if VarIsType(IvValue, TBytes) then
  //Result := IvValue
  else
    Result := Trim(IvValue).QuotedString;
end;

function TSqlRec.Validate(IvSql: string; var IvFbk: string): boolean;
begin
//IvFbk := 'Sql script is not valid';
  IvFbk := 'Sql script is valid (' + NOT_IMPLEMENTED + ')';
  Result := true;
end;

function TSqlRec.WhereAppend(IvSql, IvWhere: string): string;
var
  w: string;
begin
  w := WhereEnsure(IvWhere);
  if w = '' then
    Exit;
  Result :=  IvSql + ' ' + w;
end;

function TSqlRec.WhereEnsure(IvWhere: string): string;
var
  w, s: string;
begin
  w := IvWhere.Trim;
  if w = '' then
    Exit;
  s := Copy(w, 1, 6);
  if SameText(s, 'where ') then
    Exit;
  Result := 'where ' + w;
end;
{$ENDREGION}

{$REGION 'TStaRec'}
function TStaRec.CsvStr(IvWhat: string): string;
var
  v: TStiRecVec;
  i: integer;
begin
  v := Vector;
  for i := Low(v) to High(v) do begin
    if      SameText(IvWhat, 'Item') then
      Result := ',' + v[i].Key
    else if SameText(IvWhat, 'BgColor') then
// TEMPORARYCOMMENT
//      Result := ',' + col.ToHexStr(v[i].BgColor)
    else if SameText(IvWhat, 'FgColor') then
// TEMPORARYCOMMENT
//      Result := ',' + col.ToHexStr(v[i].FgColor)
    ;
  end;
  Delete(Result, 1, 1);
end;

function TStaRec.IsActive(IvState: string): boolean;
begin
  Result := SameText(IvState, Active.Key);
end;

function TStaRec.IsInactive(IvState: string): boolean;
begin
  Result := SameText(IvState, Inactive.Key);
end;

function TStaRec.Vector: TStiRecVec;
begin
  Result := [
    sta.Any
  , sta.Accepted
  , sta.Active
  , sta.Assigned
  , sta.Archived
  , sta.Available
  , sta.Cancelled
  , sta.Completed
  , sta.Deleted
  , sta.Deprecated
  , sta.Developing
  , sta.Developed
  , sta.Done
  , sta.Failed
  , sta.Imported
  , sta.Inactive
  , sta.Locked
  , sta.New
  , sta.Ongoing
  , sta.Onhold
  , sta.Overdue
  , sta.Planning
  , sta.Planned
  , sta.Rejected
  , sta.Run
  , sta.Running
  , sta.Sent
  , sta.Success
  , sta.Testing
  , sta.Underconstruction
  , sta.Unfeasible
  , sta.Unknown
  , sta.Updated
  , sta.Validating
  , sta.Validated
  , sta.Waiting
  , sta.Working
  ];
end;
{$ENDREGION}

{$REGION 'TStmRec'}
procedure TStmRec.FromByteArray(const IvByteArray: TByteDynArray; IvStream: TStream);
var
  p: Pointer;
begin
  p := @IvByteArray[0];
  IvStream.Write(p^, Length(IvByteArray));
  IvStream.Position := 0; // IvStream.Seek(0, soFromBeginning);
end;

function TStmRec.ToByteArray(IvStream: TMemoryStream): TByteDynArray;
var
  p: pointer;
begin
  SetLength(Result, IvStream.Size);
  p := @Result[0];
  IvStream.Position := 0;
//IvStream.Seek(0, soFromBeginning);
  IvStream.Read(p^, IvStream.Size);
end;
{$ENDREGION}

{$REGION 'TSopRec'}
function TSopRec.ConnectionAgentSet(var IvFbk: string; var IvSoapConnection: TSoapConnection): boolean;
begin
  IvSoapConnection.Agent := byn.Info;
  IvFbk := 'Soap connection agent set to: ' + IvSoapConnection.Agent;
  Result := true;
end;

function TSopRec.ConnectionUrlSet(var IvFbk: string; var IvSoapConnection: TSoapConnection; IvObj, IvService: string): boolean;
var
  u: string;
begin
  Result := DmUrl(IvFbk, u, IvObj, IvService);
  if not Result then
    Exit;
  IvSoapConnection.URL := u; // http://localhost/WksXxxSoapProject.dll/soap/IXxxSoapMainDataModule or /IWSDLPublish
end;

function TSopRec.DmUrl(var IvFbk, IvUrl: string; IvObj, IvService: string): boolean;
var
  u: string;
begin
  if IvObj = '' then
    u := SoapUrl(IvObj) + SOAP_WSDL_PUBLISH_URL
  else
    u := SoapUrl(IvObj) + Format(sop.SOAP_DM_URL, [IvObj, IvService]);
  Result := url.Exists(u, sys.URL_EXIST_CHECK);
  if not Result then begin
    IvUrl := '';
    IvFbk := Format(sop.SOAP_SERVER_CONN_URL_FOUND_NO_RS, [sys.Www]);
  end else begin
    IvUrl := u;
    IvFbk := Format(sop.SOAP_SERVER_CONN_URL_FOUND_OK_RS, [sys.Www]);
  end;
end;

function TSopRec.SoapUrl(IvObj: string): string;
var
  o, u: string;
begin
  // url
  u := srv.Url;

  // object
  o := IvObj;
  if IvObj = '' then
    o := byn.Obj;

  // url
  Result := u + Format(sop.SOAP_DLL_URL, [o])
end;

function TSopRec.SoapRioUrl(IvObj, IvService: string; var IvUrl, IvFbk: string): boolean;
var
  u: string;
begin
  u := sop.SoapUrl(IvObj) + Format(sop.SOAP_RIO_URL, [IvObj, IvService]);
  Result := url.Exists(u, sys.URL_EXIST_CHECK);
  if not Result then begin
    IvUrl := '';
    IvFbk := Format(sop.SOAP_SERVER_RIO_URL_FOUND_NO_RS, [sys.Www]);
  end else begin
    IvUrl := u;
    IvFbk := Format(sop.SOAP_SERVER_RIO_URL_FOUND_OK_RS, [sys.Www]);
  end;
end;

function TSopRec.SoapRioWsdl(IvObj, IvService: string; var IvWsdl, IvFbk: string): boolean;
var
  u: string;
begin
  u := sop.SoapUrl(IvObj) + Format(sop.SOAP_WSDL_URL, [IvObj, IvService]);
  Result := url.Exists(u, sys.URL_EXIST_CHECK);
  if not Result then begin
    IvWsdl := '';
    IvFbk := Format(sop.SOAP_SERVER_RIO_URL_FOUND_NO_RS, [u]);
  end else begin
    IvWsdl := u;
    IvFbk := Format(sop.SOAP_SERVER_RIO_URL_FOUND_OK_RS, [u]);
  end;
end;
{$ENDREGION}

{$REGION 'TSrvRec'}
function TSrvRec.Info: string;
begin
  Result := Format('Server: %s', [Url]);
  Result := str.Replace(Result, HTTP_PROTOCOL_SECURE, '');
  Result := str.Replace(Result, HTTP_PROTOCOL       , '');
end;

function TSrvRec.Init(const IvAdminCsv, IvWwwProd, IvPort: string; IvOtpIsActive, IvAuditIsActive: boolean; var IvFbk: string): boolean;
begin
//Organization    := '';
  AdminCsv        := IvAdminCsv;
//WwwDev          := IvWwwDev;
//WwwTest         := IvWwwTest;
  WwwProd         := IvWwwProd;
  Port            := IvPort;
  Protocol        := iif.Str(IvPort = '443', 'https', 'http'); // HTML_PROTOCOL_SECURE
//WwwAuthenticate := sys.WwwAuthenticate;
  OtpIsActive     := IvOtpIsActive;
  AuditIsActive   := IvAuditIsActive;

  IvFbk := 'WebServer initialized';
  Result := true;
end;

function TSrvRec.Link(IvObj: string; IvId: integer; IvContext: string): string;
var
  o, i, c: string; // object, id, context
begin
  // object
  if iis.Nx(IvObj)                then o := 'System'  // WksSystemIsapiProject.dll
//else if str.Same(IvObj, 'Page') then o := ''        // WksIsapiProject.dll/Page?CoId=%d .. WksPageIsapiProject
  else                                 o := IvObj;

  // id
  if IvId > 0 then
    i := Format('/%s?CoId=%d', [o, IvId])
  else
    i := '';

  // context
  if iis.Ex(IvContext) then
    c := IvContext
  else
    c := '';

  // link
  Result := Format('%s/Wks%sIsapiProject.dll%s%s', [Url, o, i, c]);
end;

function TSrvRec.ObjIsapiUrl(IvObj, IvTail: string): string;
var
  o: string;
begin
  o := iif.NxD(IvObj, 'System');
  Result := Format('%s/%s%s', [Url, o, IvTail]);
end;

function TSrvRec.ObjSoapUrl(IvObj, IvTail: string): string;
var
  o: string;
begin
  o := iif.NxD(IvObj, 'System');
  Result := Format('%s/%s%s', [Url, o, IvTail]);
end;

function TSrvRec.ObjUrl(IvObj, IvTail: string): string;
var
  o: string;
begin
  o := iif.NxD(IvObj, 'System');
  Result := Format('%s/%s%s', [Url, o, IvTail]);
end;

function TSrvRec.PageUrl(IvId, IvTail: string): string;
begin
  Result := Url + '/WksPageIsapiProject.dll/Page' + iif.EXr(IvId, '?CoId=' + IvId) + IvTail;
end;

function TSrvRec.Ping(var IvFbk: string): boolean;
begin
  Result := net.Ping(Www, IvFbk);
end;

function TSrvRec.QueryStringEncode(IvQueryString: string): string;
var
  i: integer;
  s: string; // PAnsiChar;
begin
  Result := '';
  s := IvQueryString; // PAnsiChar()
  for i := 1 to Length(s) do
    if not (s[i]     in ['A'..'Z', 'a'..'z', '0'..'9', '-', '_', '~', '.', ':', '/', '#']) then
      Result := Result + '%' + IntToHex(Ord(s[i]), 2)
    else
      Result := Result + s[i];
end;

procedure TSrvRec.QueryStringFieldAdd(var IvQueryString: string; IvField, IvValue: string);
var
  f, v: string;
begin
  // field
  f := IvField;
  if f = '' then
    Exit;
//f := nam.Co(f);

  // value
  if iis.Nx(IvValue) then
    Exit;
  v := QueryStringEncode(IvValue);

  // qs
  if IvQueryString = '' then
    IvQueryString := Format('?%s=%s', [f, v])
  else
    IvQueryString := IvQueryString + Format('&%s=%s', [f, v]);
end;

function TSrvRec.ScriptUrl(IvTail: string): string;
begin
  Result := Url + wre.ScriptName + IvTail;
end;

function TSrvRec.Url: string;
//var
//  p, r: string; // port, protocol
//begin
//  if (Port <> '80') and (Port <> '443') then
//    p := ':' + Port
//  else
//    p := '';
//  if Port = '443' then
//    r := 'https'
//  else
//    r := 'http';
//  Result := Format('%s://%s%s', [r, Www, p])
begin
  Result := WksAllUnit.url.Ensure(Www);
end;

function TSrvRec.Www: string;
begin
  if      SameText(Environment, 'Prod') then
    Result := WwwProd
  else if SameText(Environment, 'Test') then
    Result := WwwTest
  else
    Result := WwwDev;
end;
{$ENDREGION}

{$REGION 'TStrRec'}
function TStrRec.Between(IvTagLeft, IvTagRight, IvString: string): string;
//var
//  i: integer;
//  b: boolean;
begin
  // i
  Result := LeftOf(IvTagRight, RightOf(IvTagLeft, IvString, false));

  // ii
//b := false;
//Result := '';
//for i := 1 to Length(s) do begin
//  if (s[i] = s1) or b then begin
//     b := (s[i] <> s2);
//    if (s[i] <> s1) then
//      if (s[i] <> s2) then
//        Result := Result + s[i];
//  end;
//end;
end;

function TStrRec.Bite(IvString, IvDelimiter: string; var IvPos: integer): string;
var
  p: integer; // newpos
begin
  // check
  if (IvPos < 1) or (IvPos > Length(IvString)) then begin
    Result := '';
    IvPos := 0;
    Exit;
  end;

  // chomp
  p := PosAfter(IvDelimiter, IvString, IvPos);
  if p = 0 then begin
    Result := Copy(IvString, IvPos, Length(IvString) - IvPos + 1);
    IvPos := 0;
  end else begin
    Result := Copy(IvString, IvPos, p - IvPos);
    IvPos := p + Length(IvDelimiter);
  end;
end;

function TStrRec.Coalesce(IvStringVector: TStringVector): string;
var
  i: Integer;
begin
  for i := Low(IvStringVector) to High(IvStringVector) do
    if IvStringVector[i] <> '' then begin
      Result := IvStringVector[i];
      Exit;
    end;
end;

function TStrRec.Collapse(const IvString: string): string;
var
  i: integer;
  v: TArray<string>; // TStringDynArray
begin
  // ii
  v := IvString.Split([' ', #9]);
  for i := Low(v) to High(v) do
    Result := Result + v[i];

  // i
//Result := Replace(IvString, ' ', '');
//Result := Replace(Result  , #9 , '');
end;

function TStrRec.CommentRemove(IvString: string): string;
var
  s: string;
begin
  // zip
  s := IvString;
  // remove html <!-- -->
  if rex.Has(s, rex.REX_HTML_COMMENT_PAT, [roIgnoreCase, roSingleLine]) then rex.Replace(s, rex.REX_HTML_COMMENT_PAT, '', [roIgnoreCase, roSingleLine]);
  // remove sql --
  if rex.Has(s, rex.REX_SQL_COMMENT_PAT, [roIgnoreCase, roMultiLine])   then rex.Replace(s, rex.REX_SQL_COMMENT_PAT , '', [roIgnoreCase, roMultiLine]);
  // remove several cases
  if rex.Has(s, rex.REX_CPP_COMMENT_PAT, [roIgnoreCase,roSingleLine])   then rex.Replace(s, rex.REX_CPP_COMMENT_PAT , '', [roIgnoreCase, roSingleLine]);
  // remove [--Rv...()]
  if rex.Has(s, rex.REX_RV_COMMENT_PAT, [roIgnoreCase, roMultiLine])    then rex.Replace(s, rex.REX_RV_COMMENT_PAT  , '', [roIgnoreCase, roMultiLine]); // was roSingleLine
  // remove c c++ pas // full line ( NOT {} or (* *) )
//if rex.Has(s, rex.REX_PAS_COMMENT_PAT, [roIgnoreCase, roMultiLine])   then rex.Replace(s, rex.REX_PAS_COMMENT_PAT , '', [roIgnoreCase, roMultiLine]);
  // remove c c++ pas // at end of line
//if rex.Has(s, rex.REX_PAS_COMMENT_PAT2, [roIgnoreCase, roMultiLine])  then rex.Replace(s, rex.REX_PAS_COMMENT_PAT2, '', [roIgnoreCase, roMultiLine]);
  Result := s;
end;

function TStrRec.EmptyLinesRemove(IvString: string): string;
var
//s: string;
  i: integer;
  l: TStrings;
begin
  // zip
//s := IvString;

  // empylines i
//if rex.Has(s, rex.RE_EMPTY_LINE_PAT, [roIgnoreCase, roMultiLine])     then rex.Replace(s, rex.RE_EMPTY_LINE_PAT   , '', [roIgnoreCase, roMultiLine]);

  // empylines ii
  //while Pos(Char(13)+Char(10)+Char(13)+Char(10), s) > 0 do
    //s := StringReplace(s, Char(13)+Char(10)+Char(13)+Char(10), Char(13)+Char(10), [rfReplaceAll]);

  // empylines iii
  l := TStringList.Create;
  l.Text := IvString;
  try
    for i := l.count - 1 downto 0 do
      if Trim(l[i]) = '' then
        l.Delete(i);
    Result := Trim(l.Text); // trim to remove the extra crlf at the end added by stringlist
  finally
    FreeAndNil(l);
  end;
end;

function TStrRec.E(IvE: Exception): string;
begin
  Result := Format(EXCEPTION_FORMAT, [IvE.Message]);
end;

function TStrRec.E2(IvE: Exception): string;
begin
  Result := Format(EXCEPTION2_FORMAT, [IvE.Message, IvE.ClassName]);
end;

function TStrRec.Expande(const IvString: string; IvDelimiterChar: string): string;
var
  i, j, k: integer; // count, ordprevchar, ordcurrchar
  p, c: char; // prevchar, currchar
begin
  p := #0;
  Result := '';
  for i := 1 to Length(IvString) do begin
    c := IvString[i]; // Copy(IvString, i, 1);
    j := Ord(p);
    k := Ord(c);
    if c = '_' then // nocollapse
      Result := Result + c
    else if (((j > 96) and (j < 123)) or ((j > 47) and (j <58)))  and  ((k > 64) and (k < 91)) then // (minnuscole or numbers) and (maiuscole)
      Result := Result + IvDelimiterChar + c
    else
      Result := Result + c;
    p := c;
  end;
  if IvDelimiterChar <> '_' then
  //Result := StringReplace(Result, '_', ' ', [rfReplaceAll]);
    Result := StringReplace(Result, '_', '', [rfReplaceAll]);
end;

function TStrRec.Has(IvString, IvSubString: string; IvCaseSensitive: boolean): boolean;
begin
  if IvCaseSensitive then
    Result := Pos(IvSubString, IvString) > 0                        // casesensitive
  else
    Result := Pos(UpperCase(IvSubString), UpperCase(IvString)) > 0; // caseINsensitive
end;

function TStrRec.HeadAdd(IvString, IvHead: string): string;
begin
  Result := IvString;
  if not IvString.StartsWith(IvHead) then
    Result := IvHead + IvString;
end;

function TStrRec.HeadRemove(IvString, IvHead: string): string;
begin
  Result := IvString;
  if IvString.StartsWith(IvHead) then
    Result := IvString.Substring(Length(IvHead));
end;

function TStrRec.Is09(const IvString: string): boolean;
var
  p: PChar;
begin
  Result := false;
  p := PChar(IvString);
  while p^ <> #0 do begin
  //if not (p^ in ['0'..'9']) then
    if not CharInSet(p^, ['0'..'9']) then
      Exit;
    Inc(p);
  end;
  Result := true;
end;

function TStrRec.IsFloat(const IvString: string): boolean;
var
  e: extended;
begin
  Result := TryStrToFloat(IvString, e);
end;

function TStrRec.IsInteger(const IvString: string): boolean;
var
  i: integer;
begin
  Result := TryStrToInt(IvString, i);
end;

function TStrRec.IsNumeric(const IvString: string): boolean;
begin
  if IvString = '' then
    Result := false
  else
    Result := IsInteger(IvString) or IsFloat(IvString);
end;

function TStrRec.LeftOf(IvTag, IvString: string; IvTagInclude: boolean): string;
begin
  // i
//Result := Copy(IvString, 1, Pos(IvTag, IvString)-1);

  // ii
  Result := Copy(IvString, 1, Pos(IvTag, IvString)-1);
  if IvTagInclude then
    Result := Result + IvTag;
end;

function TStrRec.OneLine(IvString: string): string;
begin
  Result := Replace(IvString.Trim, sLineBreak, '');
end;

function TStrRec.OneSpace(IvString: string): string;
var
  s: string;
begin
  s := IvString;
  while Pos('  ', s) > 0 do
  //s := Replace(s, '  ', ' ');
    s := Copy(s, 1, Pos('  ', s) - 1) + Copy(s, Pos('  ', s) + 1, Length(s) - Pos('  ', s));
  Result := s;
end;

function TStrRec.Pad(IvString, IvFillChar: string; IvStringLen: integer; IvStrLeftJustify: boolean): string;
var
  f: string; // tempfill
  i, l: integer; // counter, length
begin
  l := Length(IvString);

  if l <> IvStringLen then begin
    if l > IvStringLen then begin
      IvString := Copy(IvString, 1, IvStringLen);
    end else begin
      f := '';
      for i := 1 to IvStringLen-l do
        f := f + IvFillChar;
      if IvStrLeftJustify then
        IvString := IvString + f  // 1230000000  left justified
      else
        IvString := f + IvString; // 0000000123  right justified
    end;
  end;
  Result := IvString;
end;

function TStrRec.PartN(IvString: string; IvNZeroBased: integer; IvDelimiter: string): string;
var
  i, o, n: integer; // id, offset, curnum
  p: string; // curpart
begin
  i := IvNZeroBased + 1;
  n := 1;
  o := 1;
  while (n <= i) and (o <> 0) do begin
    o := Pos(IvDelimiter, IvString);
    if o <> 0 then begin
      p := Copy(IvString, 1, o-1);
      Delete(IvString, 1, (o-1) + Length(IvDelimiter));
      Inc(n)
    end else
      p := IvString;
  end;
  if n >= i then
    Result := p
  else
    Result := '';
end;

function TStrRec.PosAfter(IvSubString, IvString: string; IvStart: integer): integer;
begin
  if IvStart < 1 then
    IvStart := 1;

  if IvStart > Length(IvString) then begin
    Result := 0;
    Exit;
  end;

  Delete(IvString, 1, IvStart - 1);
  Result := Pos(IvSubString, IvString);
  if Result <> 0 then
    Result := IvStart - 1 + Result;
end;

function TStrRec.Replace(IvString, IvOut, IvIn: string): string;
begin
  Result := StringReplace(IvString, IvOut, IvIn, [rfReplaceAll, rfIgnoreCase]);
end;

function TStrRec.RightOf(IvTag, IvString: string; IvTagInclude, IvLast: boolean): string;
var
  z, w, p: integer;
begin
  z := Length(IvString);
  w := Length(IvTag);
  if IvLast then
    p := IvString.LastIndexOf(IvTag)+1 // 0-based
  else
    p := Pos(IvTag, IvString);
  Result := Copy(IvString, p+w, z-p+w-1);
  if IvTagInclude then
    Result := IvTag + Result;
end;

function TStrRec.Split(IvString, IvDelimiters: string): TStringDynArray;
begin
  Result := SplitString(IvString, IvDelimiters);
end;

function TStrRec.TailAdd(IvString, IvTail: string): string;
begin
  Result := IvString;
  if not IvString.EndsWith(IvTail) then
    Result := IvString + IvTail;
end;

function TStrRec.TailRemove(IvString, IvTail: string): string;
begin
  Result := IvString;
  if IvString.EndsWith(IvTail) then
    Result := IvString.Remove(Length(IvString) - Length(IvTail));
end;

function TStrRec.W(IvE: Exception): string;
begin
  Result := Format('WARNING  : %s', [IvE.Message]);
end;

function TStrRec.ZeroLeadingAdd(IvString: string; IvLen: integer): string;
begin
  Result := Str.Pad(IvString, '0', IvLen, false);
end;
{$ENDREGION}

{$REGION 'TSysRec'}
procedure TSysRec.DbaLog(IvHost, IvAgent, IvTag, IvValue: string; IvLifeMs: integer);
var
  s, k: string;
  z: integer;
begin
  (* TEMPORARYCOMMENT

  s :=           'insert into DbaSystem.dbo.TblLog'
  + sLineBreak + 'select'
  + sLineBreak + '     ''' + DateTimeToStr(Now) + '''' // FldDateTime
  + sLineBreak + '   , ''' + IvHost  + ''''            // FldHost
  + sLineBreak + '   , ''' + IvAgent + ''''            // FldAgent
  + sLineBreak + '   , ''' + IvTag   + ''''            // FldTag
  + sLineBreak + '   , ''' + IvValue + '''';           // FldValue
  if not db0.ExecFD(s, z, k) then
    lg.W(k);
  *)
end;

function TSysRec.HomePath: string;
begin
  Result := obj.DbaParamGet('System', 'HomePath', 'X:\$\X\Win32\Debug');
end;

function TSysRec.IconUrl: string;
begin
  Result := obj.DbaParamGet('System', 'IconUrl', '/Organization/W/Wks/WksIcon.ico');
end;

function TSysRec.IncPath: string;
begin
  Result := obj.DbaParamGet('System', '$IncPath', 'X:\$Inc');
end;

function TSysRec.Info: string;
begin
  Result := Format('%s %s %s', [Acronym, Name, Www]);
end;

function TSysRec.LogoUrl: string;
begin
  Result := obj.DbaParamGet('System', 'LogoUrl', '/Organization/W/Wks/WksLogo.png');
end;

function TSysRec.RioCopyright: string;
var
  o: boolean;
  k: string;
begin
  // TEMPORARYCOMMENT
//  o := (rio.HttpRio as ISystemSoapMainService).SystemSoapCopyright(Result, k);
end;

function TSysRec.RioInfo: string;
var
  o: boolean;
  k: string;
begin
  // TEMPORARYCOMMENT
//  o := (rio.HttpRio as ISystemSoapMainService).SystemSoapInfo(k);
end;

function TSysRec.RioLicense: string;
var
  o: boolean;
  k: string;
begin
  // TEMPORARYCOMMENT
//  o := (rio.HttpRio as ISystemSoapMainService).SystemSoapLicense(Result, k);
end;

procedure TSysRec.RioLog(IvHost, IvAgent, IvTag, IvValue: string; IvLifeMs: integer);
begin
  raise Exception.Create(NOT_IMPLEMENTED);
end;

function TSysRec.RioOutline: string;
var
  o: boolean;
  k: string;
begin
  // TEMPORARYCOMMENT
//  o := (rio.HttpRio as ISystemSoapMainService).SystemSoapOutline(Result, k);
end;

function TSysRec.RioPrivacy: string;
var
  o: boolean;
  k: string;
begin
  // TEMPORARYCOMMENT
//  o := (rio.HttpRio as ISystemSoapMainService).SystemSoapPrivacy(Result, k);
end;

function TSysRec.RioRequestLog(IvOrganization, IvUsername, IvPassword, IvSession: string): string;
var
  o: boolean;
  k: string;
begin
  // TEMPORARYCOMMENT
//  o := (rio.HttpRio as ISystemSoapMainService).SystemSoapRequestLog(IvOrganization, IvUsername, IvPassword, IvSession, Result, k);
end;

function TSysRec.RioSessionLog(IvOrganization, IvUsername, IvPassword, IvSession: string): string;
var
  o: boolean;
  k: string;
begin
  // TEMPORARYCOMMENT
//  o := (rio.HttpRio as ISystemSoapMainService).SystemSoapSessionLog(IvOrganization, IvUsername, IvPassword, byn.Nick, Result, k);
end;

function TSysRec.Slogan: string;
begin
  Result := obj.DbaParamGet('System', 'Slogan', 'Programmed for progress');
end;

function TSysRec.Support: string;
begin
  Result := obj.DbaParamGet('System', 'Support', Format('Please contact a system administator via email: %s', [ADMIN_CSV]));
end;

function TSysRec.Url: string;
begin
  Result := WksAllUnit.url.Ensure(Www);
end;

function TSysRec.UrlBuild(IvObj, IvId, IvTail: string): string;
begin
  Result := Format('/Wks%sIsapiProject.dll/Page', [IvObj]);
  if iis.Ex(IvId)   then Result := Result + '?CoId=' + IvId;
  if iis.Ex(IvTail) then Result := Result + IvTail;
end;
{$ENDREGION}

{$REGION 'TUagRec'}
function TUagRec.DbaExists(var IvFbk: string): boolean;
begin
  Result := false;
  raise Exception.Create(NOT_IMPLEMENTED);
end;

function TUagRec.DbaInsert(var IvFbk: string): boolean;
var
  q, k: string;
  z: integer;
begin
  (* TEMPORARYCOMMENT

  {$REGION 'Insert'}
  q :=           'insert into DbaClient.dbo.TblUserAgent'
  + sLineBreak + 'select'
  + sLineBreak + '    ' + sql.Val(UserAgent      ) // FldUserAgent
  + sLineBreak + '  , ' + sql.Val(Client         ) // FldClient
  + sLineBreak + '  , ' + sql.Val(ClientVersion  ) // FldClientVersion
  + sLineBreak + '  , ' + sql.Val(Os             ) // FldOs
  + sLineBreak + '  , ' + sql.Val(OsVersion      ) // FldOsVersion
  + sLineBreak + '  , ' + sql.Val(Engine         ) // FldEngine
  + sLineBreak + '  , ' + sql.Val(Vendor         ) // FldVendor
  + sLineBreak + '  , ' + sql.Val(Kind           ) // FldKind
  + sLineBreak + '  , ' + sql.Val(Kind2          ) // FldKind2
  + sLineBreak + '  , ' + sql.Val(Hardware       ) // FldHardware
  + sLineBreak + '  , ' + sql.Val(BitArchitecture) // FldBitArchitecture
  + sLineBreak + '  , ' + sql.Val(DateTime       ) // FldDateTime
  + sLineBreak + '  , ' + sql.Val(Hit            ) // FldHit
  ;
  Result := db0.ExecFD(q, z, k);
  if not Result then begin
    lg.W(k);
    lg.Q(q);
  end; //else
    //eml.SendA(k, 'Info', 'Wks New UserAgent', UserAgent, 'A new user agent has been added in DbaClient.dbo.TblUserAgent, please check');
  {$ENDREGION}
  *)
end;

function TUagRec.DbaSelect(var IvFbk: string): boolean;
var
  d: TFDDataset;
  w, q, k: string;
begin
  (* TEMPORARYCOMMENT

  {$REGION 'Insert'}
  if not db0.RecExists('DbaClient.dbo.TblUserAgent', 'FldUserAgent', UserAgent, k) then begin
    lg.I('Useragent record does not exists, create it now', 'USERAGENT');
    DbaInsert(k);
  end else begin
    // update the datetime in register
    w := 'FldUserAgent = ' + sql.Val(UserAgent);
    db0.FldSet('DbaClient.dbo.TblUserAgent', 'FldDateTime', w, Now, k);
    db0.FldInc('DbaClient.dbo.TblUserAgent', 'FldHit', w, k);
  end;
  {$ENDREGION}

  {$REGION 'Select'}
  q := Format('select * from DbaClient.dbo.TblUserAgent where FldUserAgent = ''%s''', [UserAgent]);
  Result := db0.DsFD(q, d, k, true);
  if not Result then begin
   {Result :=} DbaInsert(k);
    Result := db0.DsFD(q, d, k, true);
  end;
  UserAgent       := d.FieldByName('FldUserAgent'      ).AsString;
  Client          := d.FieldByName('FldClient'         ).AsString;
  ClientVersion   := d.FieldByName('FldClientVersion'  ).AsString;
  Os              := d.FieldByName('FldOs'             ).AsString;
  OsVersion       := d.FieldByName('FldOsVersion'      ).AsString;
  Engine          := d.FieldByName('FldEngine'         ).AsString;
  Vendor          := d.FieldByName('FldVendor'         ).AsString;
  Kind            := d.FieldByName('FldKind'           ).AsString;
  Kind2           := d.FieldByName('FldKind2'          ).AsString;
  Hardware        := d.FieldByName('FldHardware'       ).AsString;
  BitArchitecture := d.FieldByName('FldBitArchitecture').AsString;
  DateTime        := d.FieldByName('FldDateTime'       ).AsDateTime;
  Hit             := d.FieldByName('FldHit'            ).AsInteger;
  {$ENDREGION}
  *)
end;
{$ENDREGION}

{$REGION 'TUrlRec'}
function TUrlRec.Decode(IvQueryObscureValue: string): string;
begin
  Result := TNetEncoding.URL.Decode(IvQueryObscureValue);
end;

function TUrlRec.Encode(IvQueryClearValue: string): string;
// you can not encode the whole URL with this function
// you need to encode the parts that you want to have no special meaning (typically the values of the variables aka queryfields)
//const
//  CHAR_OK = ['A'..'Z','a'..'z','0','1'..'9','-','_','~','.','*','@','=','&',':','?','/']; // noconversion
//var
//  i: integer;
begin
  // i
//Result := '';
//for i := 1 to Length(IvQueryClearValue) do
//  if IvQueryClearValue[i] in CHAR_OK then
//    Result := Result + IvQueryClearValue[i]
//  else
//    Result := Result + '%' + IntToHex(Ord(IvQueryClearValue[i]), 2)
//;

  // ii
  Result := TNetEncoding.URL.Encode(IvQueryClearValue);
end;

function TUrlRec.Ensure(IvLink: string): string;
begin
  if IvLink.StartsWith(HTTP_PROTOCOL, true) or IvLink.StartsWith(HTTP_PROTOCOL_SECURE, true) then
    Result := IvLink
  else
    Result := HTTP_PROTOCOL + IvLink; // or HTTP_PROTOCOL_SECURE ?
end;

function TUrlRec.Exists(IvUrl: string; IvCheck: boolean): boolean;
var
  u: string;
  s, e: hInternet; // session, request
  i, l: dword; // index, codelen
  c: array[1..20] of char; // code
  r: pchar; // result
  z: integer; // httpstatuscode
begin
  // skip
  if not IvCheck then begin
    Result := true;
    Exit;
  end;

  // ensure
  u := WksAllUnit.url.Ensure(IvUrl);

  // exit
//Result := url.IsValid(u);
//if not Result then
//  Exit;

  // getinternetsession
  s := InternetOpen('InetURL:/1.0', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  Result := Assigned(s);
  if not Result then
    Exit;

  // request
  e := InternetOpenUrl(s, pchar(u), nil, 0, INTERNET_FLAG_RELOAD, 0);
  i := 0;
  l := 10;
  Result := HttpQueryInfo(e, HTTP_QUERY_STATUS_CODE, @c, l, i);
  if Assigned(e) then InternetCloseHandle(e);
  if Assigned(s) then InternetCloseHandle(s);
  if not Result then
    Exit;

  // result
  r := PChar(@c);
  z := StrToInt(r);
  Result := (z = htt.HTTP_STATUS_200_OK) or (z = htt.HTTP_STATUS_302_REDIRECT);
end;

procedure TUrlRec.Go(IvLink: string);
var
  l: string;
  b: TBrowseURL;
begin
//ShellExecute(Application.Handle, nil, PChar(IvLink), nil, nil, SW_SHOWMAXIMIZED);
//win.ShellExec(Application.Handle, IvLink);
  if IvLink = '' then
    Exit;
  l := Ensure(IvLink);
  b := TBrowseURL.Create(nil);
  try
    b.URL := l;
    try
      b.ExecuteTarget(nil);
    except
      ;
    end;
  finally
    FreeAndNil(b);
  end;
end;

procedure TUrlRec.GoChrome(IvLink: string);
var
  c, p: string;
begin
  c := 'chrome.exe';
  p := '--app=' + IvLink;
  ShellExecute(Application.Handle, nil, PChar(c), PChar(p), nil, SW_SHOWMAXIMIZED);
  //win.ShellExec(Application.Handle, c);
end;

procedure TUrlRec.GoEdge(IvLink: string);
var
  c: string;
begin
  c := 'cmd /C start microsoft-edge:' + IvLink;
  ShellExecute(Application.Handle, nil, PChar(c), nil, nil, SW_SHOWMAXIMIZED);
  //win.ShellExec(Application.Handle, c);
end;

procedure TUrlRec.GoFirefox(IvLink: string);
var
  c: string;
begin
  c := 'firefox.exe' + IvLink;
  ShellExecute(Application.Handle, nil, PChar(c), nil, nil, SW_SHOWMAXIMIZED);
  //win.ShellExec(Application.Handle, c);
end;

function TUrlRec.HttpRemove(IvUrl: string): string;
begin
  // init
  Result := IvUrl;

  if      Pos('https://', Lowercase(Result)) > 0 then
    Delete(Result, 1, 8)
  else if Pos('http://', Lowercase(Result)) > 0 then
    Delete(Result, 1, 7);
end;

function TUrlRec.IsValid(IvUrl: string): boolean;
begin
  Result := TRegEx.IsMatch(IvUrl, rex.REX_URL_PAT)
end;

function TUrlRec.Parse(IvUrl, IvPart: string): string;
var
  u: TIdURI;
begin
  u := TIdURI.Create(IvUrl);
  try
    Scheme    := u.Protocol;
    Username  := u.Username;
    Password  := u.Password;
    Host      := u.Host;
    Port      := u.Port;
    Path      := u.Path;
    QueryInfo := u.Params;
    Fragment  := str.RightOf('#', IvUrl, true);
  finally
    u.Free;
  end;
  PathInfo  := str.LeftOf('?', IvUrl); if PathInfo = '' then PathInfo := IvUrl;
  PathInfo  := str.RightOf('/', PathInfo, true, true);
end;

function TUrlRec.PatInfo(IvUrl: string): string;
begin
  Parse(IvUrl);
  Result := PathInfo;
end;
{$ENDREGION}

{$REGION 'TUsrRec'}
function TUsrRec.AvatarPath(IvUsername: string): string;
var
  u: string;
begin
  u := iif.NxD(IvUsername, Username);
  Result := Format('%s\%s.png', [PathAlpha(u), u]);
  if not FileExists(Result) then
    img.DbaToDisk(Result, 'DbaUser.dbo.TblUser', 'FldAvatar', Format('FldUsername = ''%s''', [u]));
//Result := '/WksImageIsapiProject.dll/Image?CoFrom=User&CoName=' + IvUser;
end;

function TUsrRec.AvatarUrl(IvUsername: string): string;
var
  u: string;
begin
  u := iif.NxD(IvUsername, Username);
  Result := Format('%s/%s.png', [UrlAlpha(u), u]);
end;

function TUsrRec.DbaExists(var IvFbk: string): boolean;
var
  w, k: string;
begin
  (* TEMPORARYCOMMENT

  w := Format('FldUsername = ''%s''', [Username]);
  Result := db0.RecExists('DbaUser.dbo.TblUser', w, k);
  IvFbk := fbk.ExistsStr('User', Username, Result);
  *)
end;

function TUsrRec.DbaIsActive(var IvFbk: string): boolean;
var
  w, k: string;
begin
  (* TEMPORARYCOMMENT
  w := Format('FldState = ''%s''', [sta.Active.Key]);
  Result := db0.RecExists('DbaUser.dbo.TblUser', w, k);
  IvFbk := fbk.IsActiveStr('User', Username, Result);
  *)
end;

function TUsrRec.DbaIsAuthenticated(var IvFbk: string; IvConsiderUsernameOnly, IvPasswordSkip: boolean): boolean;
var
  w, s: string;
  r: variant; // returnval
begin
  (* TEMPORARYCOMMENT

  // nosqlinjection
  Organization := str.PartN(Organization, 0, ' ');
  Username     := str.PartN(Username    , 0, ' ');
  Password     := str.PartN(Password    , 0, ' ');

  // dba
  if IvConsiderUsernameOnly then begin
    w := UsernameWhere(Organization, Username, Password, true);
    Result := db0.FldGet('DbaUser.dbo.TblUser', 'FldUsername', w, r, '', IvFbk);
    s := Username;
  end else begin
    w := UsernameWhere(Organization, Username, Password, false);
    Result := db0.FldGet('DbaUser.dbo.TblUser', 'FldUsername', w, r, '', IvFbk);
    s := Format('%s@%s', [Username, Organization]);
  end;
  if not Result then
    Exit;

  // authenticated?
  Result := (r = Username) and (r <> '');
  IvFbk := fbk.IsAuthenticatedStr('User', Username, Result);
  *)
end;

function TUsrRec.DbaIsLoggedIn(var IvFbk: string): boolean;
var
  w, k: string;
begin
  (* TEMPORARYCOMMENT

  w := UsernameWhere(Organization, Username, Password, false) + Format(' and FldSession = ''%s''', [Session]);
  Result := db0.RecExists('DbaUser.dbo.TblUser', w, k);
  IvFbk := fbk.IsLoggedStr('User', Username, Result);
  *)
end;

function TUsrRec.DbaSelect(const IvUsername: string; var IvFbk: string): boolean;
begin
  raise Exception.Create(NOT_IMPLEMENTED);
end;

function TUsrRec.Info: string;
begin
  Result := Format('%s@%s', [Username, Organization]);
end;

function TUsrRec.PathAlpha(IvUsername: string): string;
var
  u: string;
begin
  u := iif.NxD(IvUsername, Username);
  Result := Format('%s\%s', [sys.USR_DIR, UpperCase(u[1])]);
end;

function TUsrRec.RioExists(IvOrganization, IvUsername: string; var IvFbk: string): boolean;
begin
  // TEMPORARYCOMMENT
//  Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapUserExists(IvOrganization, IvUsername, IvFbk);
end;

function TUsrRec.RioIsActive(IvOrganization, IvUsername: string; var IvFbk: string): boolean;
begin
  // TEMPORARYCOMMENT
//  Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapUserIsActive(IvOrganization, IvUsername, IvFbk);
end;

function TUsrRec.RioIsAuthenticated(IvOrganization, IvUsername, IvPassword: string; var IvFbk: string): boolean;
begin
  // TEMPORARYCOMMENT
//  Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapUserIsAuthenticated(IvOrganization, IvUsername, IvPassword, IvFbk);
end;

function TUsrRec.UrlAlpha(IvUsername: string): string;
var
  u: string;
begin
  u := iif.NxD(IvUsername, Username);
  Result := srv.ObjUrl('User', UpperCase(u[1]));
end;

function TUsrRec.UsernameIsValid(IvUsername: string; var IvFbk: string): boolean;
begin
  // length
  Result := Length(IvUsername) >= 4;
  if not Result then begin
    IvFbk := 'Username must be 4 or more characters long';
    Exit;
  end;

  // haslower
  Result := SameStr(IvUsername, LowerCase(IvUsername));
  if not Result then begin
    IvFbk := 'Username must be all in lowercase characters';
    Exit;
  end;
end;

function TUsrRec.UsernameWhere(IvOrganization, IvUsername, IvPassword: string; IvConsiderUsernameOnly: boolean): string;
begin
  Result := Format('FldUsername = ''%s'' and FldPassword = ''%s'' collate sql_latin1_general_cp1_cs_as', [IvUsername, IvPassword]);
  if not IvConsiderUsernameOnly then
    if IvUsername <> sys.ARCHITECT then
      Result := Format('FldOrganization = ''%s'' and %s', [IvOrganization, Result]);
end;
{$ENDREGION}

{$REGION 'TVecRec'}
function TVecRec.Collapse(IvStringVector: TStringVector): string;
begin
  Result := ToList(IvStringVector, '');
end;

function TVecRec.Ex(IvStringVec: array of string): boolean;
begin
  Result := Length(IvStringVec) > 0;
end;

function TVecRec.FromCsv(IvString: string; IvTrim: boolean): TStringVector;
begin
  Result := FromStr(IvString, ',');
end;

function TVecRec.FromStr(IvString, IvDelimChars: string; IvTrim: boolean): TStringVector;
var
  i: integer;
begin
  Result := SplitString(IvString, IvDelimChars);
  for i := Low(Result) to High(Result) do
    Result[i] := Result[i].Trim;
end;

function TVecRec.Has(const IvString: string; IvStringVector: TStringVector; IvCaseSensitive: boolean): boolean;
var
  i: integer;
begin
  Result := true;
  for i := Low(IvStringVector) to High(IvStringVector) do
    if IvStringVector[i] = IvString then
      Exit;
  Result := false;
end;

function TVecRec.ItemRnd(IvStringVector: array of string): string;
begin
  Result := IvStringVector[Random(Length(IvStringVector))];
end;

function TVecRec.Nx(IvStringVec: array of string): boolean;
begin
  Result := Length(IvStringVec) <= 0;
end;

function TVecRec.ToList(IvStringVector: TStringVector; IvDelimiterChar: string): string;
var
  i: integer;
begin
  Result := '';
  if Length(IvStringVector) = 0 then
    Exit;
  Result := IvStringVector[0];
  for i := 1 to High(IvStringVector) do
    Result := Result + IvDelimiterChar + IvStringVector[i];
end;

function TVecRec.ToListNotEmpty(IvVector: TStringVector; IvDelimiterChar: string): string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to High(IvVector) do begin
    if IvVector[i] <> '' then
      Result := Result + IvDelimiterChar + IvVector[i];
  end;
  Delete(Result, 1, Length(IvDelimiterChar));
end;

function TVecRec.ToTxt(IvStringVector: TStringVector): string;
var
  i: integer;
begin
  for i := Low(IvStringVector) to High(IvStringVector) do
    Result := Result + sLineBreak + Format('"%d": "%s"', [i, IvStringVector[i]]);
end;

function TVecRec.ToTxt(IvDoubleVector: TDoubleVector): string;
var
  i: integer;
begin
  for i := Low(IvDoubleVector) to High(IvDoubleVector) do
    Result := Result + sLineBreak + Format('"%d": "%f"', [i, IvDoubleVector[i]]);
end;
{$ENDREGION}

{$REGION 'TVntRec'}
function TVntRec.HasData(IvVariant: variant): boolean;
begin
  Result := VarToStr(IvVariant) <> ''; // VarIsClear() or VarIsEmpty() or VarIsNull()
end;

function TVntRec.IsEmpty(IvVariant: Variant): boolean;
var
  d: PVarData; // data
begin
  d := FindVarData(IvVariant);
  case d^.VType of
    varOleStr:
      Result := (d^.VOleStr^ = #0);
    varString:
      Result := (d^.VString = nil);
    varUString:
      Result := (d^.VUString = nil);
    else
      Result := false;
  end;
end;

function TVntRec.IsNull(IvVariant, IvDefault: variant): variant;
begin
  if VarIsNull(IvVariant) then
    Result := IvDefault
  else
    Result := IvVariant;
end;

function TVntRec.IsStr(const IvVariant: Variant): boolean;
begin
  Result := TypeIsStr(FindVarData(IvVariant)^.VType);
end;

function TVntRec.NullIf(IvVariant, IvIsThis: variant): variant;
begin
  if IvVariant = IvIsThis then
    Result := null
  else
    Result := IvVariant;
end;

function TVntRec.RecCopy(const IvVarRec: TVarRec): TVarRec;
var
  w: WideString;
begin
  // copy entire TVarRec first
  Result := IvVarRec;

  // now handle special cases
  case IvVarRec.VType of
    vtExtended: begin
      New(Result.VExtended);
      Result.VExtended^ := IvVarRec.VExtended^;
    end;

    vtString: begin
    //New(Result.VString);
      GetMem(Result.VString, Length(IvVarRec.VString^) + 1); // improvement suggestion by Hallvard Vassbotn: only copy real length
      Result.VString^ := IvVarRec.VString^;
    end;

    vtPChar:
      Result.VPChar := StrNew(IvVarRec.VPChar);

    vtPWideChar: begin // there is no StrNew for PWideChar
      w := IvVarRec.VPWideChar;
      GetMem(Result.VPWideChar, (Length(w) + 1) * SizeOf(WideChar));
      Move(PWideChar(w)^, Result.VPWideChar^, (Length(w) + 1) * SizeOf(WideChar));
    end;

    vtAnsiString: begin // a little trickier: casting to AnsiString will ensure reference counting is done properly
      Result.VAnsiString := nil; // nil out first, so no attempt to decrement reference count
      AnsiString(Result.VAnsiString) := AnsiString(IvVarRec.VAnsiString);
    end;

    vtCurrency: begin
      New(Result.VCurrency);
      Result.VCurrency^ := IvVarRec.VCurrency^;
    end;

    vtVariant: begin
      New(Result.VVariant);
      Result.VVariant^ := IvVarRec.VVariant^;
    end;

    vtInterface: begin // casting ensures proper reference counting
      Result.VInterface := nil;
      IInterface(Result.VInterface) := IInterface(IvVarRec.VInterface);
    end;

    vtWideString: begin // casting ensures a proper copy is created
      Result.VWideString := nil;
      WideString(Result.VWideString) := WideString(IvVarRec.VWideString);
    end;

    vtInt64: begin
      New(Result.VInt64);
      Result.VInt64^ := IvVarRec.VInt64^;
    end;

    // VPointer and VObject don't have proper copy semantics so it is impossible to write generic code that copies the contents
  end;
end;

procedure TVntRec.RecFinalize(var IvVarRec: TVarRec);
begin
  case IvVarRec.VType of
    vtExtended  : Dispose(IvVarRec.VExtended);
    vtString    : Dispose(IvVarRec.VString);
    vtPChar     : StrDispose(IvVarRec.VPChar);
    vtPWideChar : FreeMem(IvVarRec.VPWideChar);
    vtAnsiString: AnsiString(IvVarRec.VAnsiString) := '';
    vtCurrency  : Dispose(IvVarRec.VCurrency);
    vtVariant   : Dispose(IvVarRec.VVariant);
    vtInterface : IInterface(IvVarRec.VInterface) := nil;
    vtWideString: WideString(IvVarRec.VWideString) := '';
    vtInt64     : Dispose(IvVarRec.VInt64);
  end;
  IvVarRec.VInteger := 0;
end;

function TVntRec.RecToVar(IvVarRec: TVarRec): variant;
begin
  case IvVarRec.VType of
    vtInteger:  Result := IvVarRec.VInteger;
    vtBoolean:  Result := IvVarRec.VBoolean;
    vtChar:     Result := IvVarRec.VChar;
    vtExtended: Result := IvVarRec.VExtended^;
    vtString:   Result := IvVarRec.VString^;
  end;
end;

procedure TVntRec.RecVectorClear(var IvVarRecVector: TVarRecVector);
var
 i: integer;
begin
  for i := 0 to Length(IvVarRecVector) - 1 do
    if IvVarRecVector[i].VType in [vtExtended, vtString, vtVariant] then
      Dispose(IvVarRecVector[i].VExtended);
  Finalize(IvVarRecVector);
end;

function TVntRec.RecVectorCreate( const IvElements: array of const): TVarRecVector;
var
  i: integer;
begin
  SetLength(Result, Length(IvElements));
  for i := Low(IvElements) to High(IvElements) do
    Result[i] := RecCopy(IvElements[i]);
end;

procedure TVntRec.RecVectorFinalize(var IvVarRecVector: TVarRecVector);
var
  i: integer;
begin
  for i := Low(IvVarRecVector) to High(IvVarRecVector) do
    RecFinalize(IvVarRecVector[i]);
  Finalize(IvVarRecVector);
  IvVarRecVector := nil;
end;

function TVntRec.RecVectorIsEmpty(IvVarRecVector: array of TVarRec): boolean;
var
  i: integer;
  t: byte;
  v: string;
begin
  for i := Low(IvVarRecVector) to High(IvVarRecVector) do begin
    // type
    t := IvVarRecVector[i].VType;

    // value
    case t of
{ 0}  vtInteger       : v := IntToStr(IvVarRecVector[i].VInteger);
{ 1}  vtBoolean       : v := BoolToStr(IvVarRecVector[i].VBoolean, true);
{ 2}  vtChar          : v := string(IvVarRecVector[i].VChar);
{ 3}  vtExtended      : v := FloatToStr(IvVarRecVector[i].VExtended^);
{ 4}  vtString        : v := string(IvVarRecVector[i].VString);
{ 5}  vtPointer       : v := string(IvVarRecVector[i].VPointer^);
{ 6}  vtPChar         : v := string(IvVarRecVector[i].VPChar);
{ 7}  vtObject        : v := TObject(IvVarRecVector[i].VObject).ClassName;
{ 8}  vtClass         : v := IvVarRecVector[i].VClass.ClassName;
{ 9}  vtWideChar      : v := string(IvVarRecVector[i].VWideChar);
{10}  vtPWideChar     : v := string(IvVarRecVector[i].VPWideChar);
{11}  vtAnsiString    : v := string(IvVarRecVector[i].VAnsiString);
{12}  vtCurrency      : v := CurrToStr(IvVarRecVector[i].VCurrency^);
{13}  vtVariant       : v := string(IvVarRecVector[i].VVariant^);
{14}  vtInterface     : v := string(IvVarRecVector[i].VInterface^);
{15}  vtWideString    : v := string(IvVarRecVector[i].VWideString^);
{16}  vtInt64         : v := IntToStr(IvVarRecVector[i].VInt64^);
{17}  vtUnicodeString : v := string(IvVarRecVector[i].VUnicodeString);
    else
                        v := ''; // sendamessageinabottle!
    end;

    // exir
    Result := v = '';
    if Result then begin
    //IvFbk := Format('Element #%d is empty', [i]);
      Exit;
    end;
  end;

  Result := false;
  //IvFbk := 'No one element is empty';
end;

function TVntRec.ToInt(IvVariant: variant; IvDefault: integer): integer;
begin
  Result := StrToIntDef(Trim(VarToStr(IvVariant)), IvDefault);
end;

function TVntRec.ToStr(IvVariant: variant; IvDefault: string): string;
begin
  Result := System.Variants.VarToStr(IvVariant);
end;

function TVntRec.ToVarRec(IvVariant: variant): TVarRec;
var
  t: integer; // type
  e: TVarRec; // Extended
  c: TVarRec; // Currency
  b: TVarRec; // boolean
  s: TVarRec; // string
begin
  t := VarType(IvVariant);
  case t of
    varSmallint, varInteger, varByte: begin
      Result.VType := vtInteger;
      Result.VInteger := IvVariant;
    end;
    varSingle, varDouble, varCurrency, varDate: begin
      Result.VType := vtExtended;
    //SetLength(e, length(e)+1);
    //e[length(e)-1] := IvVariant;
    //Result.VExtended := @e[length(e)-1];
      New(Result.VExtended);
      Result.VExtended^ := IvVariant;
    end;
    varBoolean: begin
      Result.VType := vtBoolean;
    //SetLength(b, length(b)+1);
    //b[length(b)-1] := IvVariant;
    //Result.VExtended := @b[length(b)-1];
      Result.VType := vtBoolean;
      Result.VBoolean := IvVariant;
    end;
    varString, varOleStr: begin
      Result.VType := vtString;
    //SetLength(s, length(s)+1);
    //s[length(s)-1] := IvVariant;
    //Result.VExtended := @s[length(s)-1];
      New(Result.VString);
      Result.VString^ := IvVariant;
    end;
    varVariant: begin
      Result.VType := vtVariant;
      New(Result.VVariant);
      Result.VVariant^ := IvVariant;
    end;
  end;
end;

procedure TVntRec.ToVarRecVector(IvVariant: variant; var IvVarRecVector: TVarRecVector);
var
  i: integer;
begin
  SetLength(IvVarRecVector, VarArrayHighBound(IvVariant, 1) + 1);
  for i := 0 to VarArrayHighBound(IvVariant, 1) do
    case TVarData(IvVariant[i]).VType of
      varSmallint, varInteger, varByte:
        begin
          IvVarRecVector[i].VType := vtInteger;
          IvVarRecVector[i].VInteger := IvVariant[i];
        end;
      varSingle, varDouble, varCurrency, varDate:
        begin
          IvVarRecVector[i].VType := vtExtended;
          New(IvVarRecVector[i].VExtended);
          IvVarRecVector[i].VExtended^ := IvVariant[i];
        end;
      varBoolean:
        begin
          IvVarRecVector[i].VType := vtBoolean;
          IvVarRecVector[i].VBoolean := IvVariant[i];
        end;
      varOleStr, varString:
        begin
          IvVarRecVector[i].VType := vtString;
          New(IvVarRecVector[i].VString);
          IvVarRecVector[i].VString^ := IvVariant[i];
        end;
      varVariant:
        begin
          IvVarRecVector[i].VType := vtVariant;
          New(IvVarRecVector[i].VVariant);
          IvVarRecVector[i].VVariant^ := IvVariant[i];
        end;
    end;
end;

function TVntRec.TypeIsStr(const IvVarType: TVarType): boolean;
begin
  Result := (IvVarType = varOleStr) or (IvVarType = varString) or (IvVarType = varUString);
end;
{$ENDREGION}

{$REGION 'TWreRec'}
function TWreRec.StrGet(IvField, IvDefault: string; IvCookieAlso: boolean): string;
begin
  Result := WebRequest.QueryFields.Values[IvField];
  if iis.Ex(Result) then Exit;

  Result := WebRequest.ContentFields.Values[IvField];
  if iis.Ex(Result) then Exit;

if IvCookieAlso then begin
  Result := WebRequest.CookieFields.Values[IvField];
  if iis.Ex(Result) then Exit;
end;

  Result := IvDefault;
end;

function TWreRec.IntGet(IvField: string; IvDefault: integer; IvCookieAlso: boolean): integer;
var
  r: string;
begin
  r := WebRequest.QueryFields.Values[IvField];
  if iis.Ex(r) then begin
    Result := r.ToInteger;
    Exit;
  end;

  r := WebRequest.ContentFields.Values[IvField];
  if iis.Ex(r) then begin
    Result := r.ToInteger;
    Exit;
  end;

if IvCookieAlso then begin
  r := WebRequest.CookieFields.Values[IvField];
  if iis.Ex(r) then begin
    Result := r.ToInteger;
    Exit;
  end;
end;

  Result := IvDefault;
end;

function TWreRec.BoolGet(IvField: string; IvDefault, IvCookieAlso: boolean): boolean;
var
  s: string;
begin
  s := StrGet(IvField, BoolToStr(IvDefault), IvCookieAlso);
  Result := StrToBool(s);
end;

function TWreRec.CookieGet(IvCookie, IvDefault: string): string;
begin
  Result := '1234';
  Exit;

  if Length(WebRequest.CookieFields.Values[IvCookie]) > 0 then
    Result := WebRequest.CookieFields.Values[IvCookie]
  else
    Result := IvDefault;
end;

function TWreRec.CookieGet(IvWebRequest: TWebRequest; IvCookie, IvDefault: string): string;
begin
  if Length(IvWebRequest.CookieFields.Values[IvCookie]) > 0 then
    Result := IvWebRequest.CookieFields.Values[IvCookie]
  else
    Result := IvDefault;
end;

function TWreRec.CookieGet(IvWebRequest: TWebRequest; IvCookie: string; IvDefault: integer): integer;
var
  s, d: string; // default
begin
  d := IntToStr(IvDefault);
  s := CookieGet(IvWebRequest, IvCookie, d);
  Result := StrToInt(s);
end;

function TWreRec.FieldExists(IvWebRequest: TWebRequest; IvField: string; var IvFbk: string): boolean;
begin
  Result := (IvWebRequest.QueryFields.IndexOfName(IvField) >= 0) or (IvWebRequest.ContentFields.IndexOfName(IvField) >= 0);
  IvFbk := fbk.ExistsStr('WebField', IvField, Result);
end;

function TWreRec.Field(IvWebRequest: TWebRequest; IvField: string; var IvValue: string; IvDefault: string; var IvFbk: string; IvFalseIfValueIsEmpty: boolean): boolean;
begin
  // exists
  if IvFalseIfValueIsEmpty then begin
    if not FieldExists(IvWebRequest, IvField, IvFbk) then begin
      Result := false;
      Exit;
    end;
  end;

  // queryfield 1sttry
  IvValue := IvWebRequest.QueryFields.Values[IvField];
  Result := IvValue <> '';
  if Result then begin
    IvFbk := Format('%s = %s selected from query fields', [IvField, IvValue]);
    Exit;
  end;

  // contentfield 2ndtry
  IvValue := IvWebRequest.ContentFields.Values[IvField];
  Result := IvValue <> '';
  if Result then begin
    IvFbk := Format('%s = %s selected from content fields', [IvField, IvValue]);
    Exit;
  end;

  // default lasttry
  IvValue := IvDefault;
  Result := IvValue <> '';
  if Result then
    IvFbk := Format('%s = %s selected from default', [IvField, IvValue])
  else
    IvFbk := Format('%s = empty, even from default, returning false', [IvField]);
end;

function TWreRec.Field(IvWebRequest: TWebRequest; IvField: string; var IvValue: integer; IvDefault: integer; var IvFbk: string; IvFalseIfValueIsEmpty: boolean): boolean;
var
  v, d: string; // value, default
begin
  d := IntToStr(IvDefault);
  Result := Field(IvWebRequest, IvField, v, d, IvFbk, IvFalseIfValueIsEmpty);
  IvValue := StrToIntDef(v, IvDefault);
end;

function TWreRec.Field(IvWebRequest: TWebRequest; IvField: string; var IvValue: boolean; IvDefault: boolean; var IvFbk: string; IvFalseIfValueIsEmpty: boolean): boolean;
var
  v, d: string; // value, default
begin
  d := BoolToStr(IvDefault);
  Result := Field(IvWebRequest, IvField, v, d, IvFbk, IvFalseIfValueIsEmpty);
  IvValue := StrToBoolDef(v, IvDefault);
end;

function TWreRec.DbaSelectInput(IvWebRequest: TWebRequest; var IvTable, IvField, IvWhere, IvFbk: string): boolean;
begin
  // database
//Result := Field(IvWebRequest, 'CoDba', IvDba, '', true, IvFbk);
//if not Result then
//  Exit;

  // table
  Result := Field(IvWebRequest, 'CoTable', IvTable, '', IvFbk);
  if not Result then
    Exit;

  // field
  Result := Field(IvWebRequest, 'CoField', IvField, '', IvFbk);
  if not Result then
    Exit;

  // where
  Result := Field(IvWebRequest, 'CoWhere', IvWhere, '', IvFbk);
end;

function TWreRec.DbaUpdateInput(IvWebRequest: TWebRequest; var IvTable, IvField, IvWhere, IvValue, IvFbk: string): boolean;
begin
  // forselect
  Result := DbaSelectInput(IvWebRequest, IvTable, IvField, IvWhere, IvFbk);
  if not Result then
    Exit;

  // value
  Result := Field(IvWebRequest, 'CoValue', IvValue, '', IvFbk, false); // value can be empty
end;

procedure TWreRec.Init(const IvWebRequest: TWebRequest);
var
  c, o, k: string; // cookie, organization
  t: TDateTime;
  u: TUagRec;
begin
  (* TEMPORARYCOMMENT

  {$REGION 'UserAgent'}
  u.UserAgent := IvWebRequest.UserAgent;
  u.DbaSelect(k);
  {$ENDREGION}

  {$REGION 'RequestOriginal'}
  WebRequest           := IvWebRequest;
//Ire                  := TISAPIRequest(IvWre);
  {$ENDREGION}

  {$REGION 'Now'}
  c := IvWebRequest.CookieFields.Values['CoDateTime']; // CoDateTime is a cookie written by js and is UTC (absolute zero meridian time!)
  if c = '' then
    DateTime           := Now     // server time / DtToIso(DateTime)
  else begin
    t := dat.FromIso(c, false);   // false will transform utc in your local time zone
    DateTime           := StrToDateTime(DateTimeToStr(t)); // client time
  end;
  {$ENDREGION}

  {$REGION 'RequestExtended'}
  // client (server is the reference point so remote_addr is the client_addr)
//ClientIp             :=   {10.176.85.121                          }  WebRequest.RemoteIp;                                  //
  ClientAddr           :=   {10.176.85.121                          }  WebRequest.RemoteAddr;                                // REMOTE_ADDR
  ClientHost           :=   {localhost                              }  WebRequest.RemoteHost;                                // REMOTE_HOST
//ClientPort                {62682                                  }                                                        // REMOTE_PORT
  ClientAccept         :=   {text/html,application/xml              }  WebRequest.Accept;                                    // HTTP_ACCEPT
  ClientAcceptEncoding :=   {gzip, deflate                          }  WebRequest.GetFieldByName('HTTP_ACCEPT_ENCODING');    //
  ClientAcceptLanguage :=   {en-US,en                               }  WebRequest.GetFieldByName('HTTP_ACCEPT_LANGUAGE');    //
  ClientApp            :=   {Mozilla/5.0 Windows NT...              }  WebRequest.UserAgent;                                 // HTTP_USER_AGENT   / WksClient 1.0.0.1
  ClientAppVersion     :=   {5.0 / 1.0.0.1                          }  '';                                                   // UseragentVer / ClientVersion
  // clientfingerprint
  ClientDoNotTrack     :=   {1                                      }  WebRequest.CookieFields.Values['CoDoNotTrack'];       // HTTP_DNT
  ClientTimezoneOffset :=   {?                                      }  WebRequest.CookieFields.Values['CoTimezoneOffset'];   //
  ClientLanguage       :=   {?                                      }  WebRequest.CookieFields.Values['CoLanguage'];         //
  ClientPlatform       :=   {?                                      }  WebRequest.CookieFields.Values['CoPlatform'];         //
  ClientOs             :=   {?                                      }  WebRequest.CookieFields.Values['CoOs'];               //
  ClientCpuCores       :=   {?                                      }  WebRequest.CookieFields.Values['CoCpuCores'];         //
  ClientScreen         :=   {?                                      }  WebRequest.CookieFields.Values['CoScreen'];           //
  ClientAudio          :=   {?                                      }  WebRequest.CookieFields.Values['CoAudio'];            //
  ClientVideo          :=   {?                                      }  WebRequest.CookieFields.Values['CoVideo'];            //
  ClientLocalStorage   :=   {?                                      }  WebRequest.CookieFields.Values['CoLocalStorage'];     //
  ClientSessionStorage :=   {?                                      }  WebRequest.CookieFields.Values['CoSessionStorage'];   //
  ClientIndexedDb      :=   {?                                      }  WebRequest.CookieFields.Values['CoIndexedDb'];        //
  ClientFingerprint    :=   {?                                      }  WebRequest.CookieFields.Values['CoFingerprint'];      //
  // user
  UserOrganization     :=   {Wks (fromurl/dba)                      }  db0.ScalarFD('select top(1) FldOrganization from DbaOrganization.dbo.TblOrganization where FldState= ''Active'' and FldWww = ''' + WebRequest.Host + '''', 'Unknown', k); lg.I('ORGANIZATION ' + UserOrganization); // IvWebRequest.CookieFields.Values['CoOrganization'];
  UserDomain           :=   {?                                      }  WebRequest.CookieFields.Values['CoDomain'];           //
  UserComputer         :=   {phobos                                 }  WebRequest.CookieFields.Values['CoComputer'];         //
  Username             :=   {giarussi | 353992                      }  str.Coalesce([WebRequest.CookieFields.Values['CoUsername'], WebRequest.GetFieldByName('HTTP_SMUSER'), WebRequest.GetFieldByName('HTTP_SMMATRICOLA')]);
//UserPassword         :=                                              WebRequest.CookieFields.Values['CoPassword'];         //
//UserLogon            :=   {?                                      }  WebRequest.GetFieldByName('LOGON_USER');              //
//UserRemote           :=   {?                                      }  WebRequest.GetFieldByName('REMOTE_USER');             //
//UserRemoteUnmapped   :=   {/                                      }  WebRequest.GetFieldByName('UNMAPPED_REMOTE_USER');    //
  // session
  Session              :=   {?                                      }  WebRequest.CookieFields.Values['CoSession'];          // was initiated in WebModuleAfterDispatch AT THE END of previous request   *** WILL REPLACE USERNAME+PASSSWORD or FINGERPRINT***
  Otp                  :=   {?                                      }  WebRequest.CookieFields.Values['CoOtp'];              //
  // http
  HttpOrigin           :=   {                                       }  WebRequest.GetFieldByName('HTTP_ORIGIN');             //
  HttpProtocol         :=   {HTTP/1.1                               }  WebRequest.ProtocolVersion;                           // SERVER_PROTOCOL
  HttpMethod           :=   {GET, POST                              }  WebRequest.Method;                                    // REQUEST_METHOD / WebRequest.MethodType / Ecb.Method
  // request
  RequestId            :=   {095EBA6CEcb.ConnId                     }  (WebRequest as TISAPIRequest).Ecb^.ConnId;            //
  Connection           :=   {keep-alive                             }  WebRequest.Connection;                                // HTTP_CONNECTION
  Host                 :=   {aiwymsapp.ai.lfoundry.com              }  WebRequest.Host;                                      // SERVER_NAME
  Url                  :=   {/WksIsapiProject.dll *partial or empty*}  WebRequest.Url ;                                      //
  PathInfo             :=   {/Info                                  }  WebRequest.PathInfo;                                  // PATH_INFO / Ecb.PathInfo
//InternalPathInfo     :=   {/Info                                  }  WebRequest.InternalPathInfo;                          //
//RawPathInfo          :=   {/Info                                  }  WebRequest.RawPathInfo;                               //
//PathTranslated       :=   {X:\$\X\Win32\Debug\Info                }  WebRequest.PathTranslated;                            // PATH_TRANSLATED / Ecb.PathTranslated
  Query                :=   {?CoId=381&CoXxx=2                      }  WebRequest.Query;                                     // QUERY_STRING / Ecb.Query / WebRequest.QueryFields.CommaText
//Referer              :=   {http://abc.com/WksIsapi.dll/Run?CoId=12}  WebRequest.Referer;                                   // HTTP_REFERER / full url or generally *empty*
//Title                :=   {*empty*                                }  WebRequest.Title;                                     //
//Cookie               :=   {CoOtp=933073; CoDomain=LOCALHOST;      }  WebRequest.Cookie;                                    // HTTP_COOKIE
//TotalBytes           :=   {0                                      }  WebRequest.ContentLength;                             // Ecb.TotalBytes
//Expires              :=   {?                                      }  TDateTime(IvWebRequest.Expires);                      //
//MimeType             :=   {?                                      }  '';                                                   //
  // content
//ContentEncoding      :=   {*empty*                                }  WebRequest.ContentEncoding;                           //
//ContentType          :=   {*empty* | application/x-www-form...    }  WebRequest.ContentType;                               // CONTENT_TYPE / Ecb.ContentType / *empty*
//ContentLength        :=   {0                                      }  WebRequest.ContentLength;                             // CONTENT_LENGTH / Ecb.TotalBytes
//ContentVersion       :=   {*empty*                                }  WebRequest.ContentVersion;                            //
//ContentRaw           :=   {*arrrayofbytes*                        }  WebRequest.RawContent;                                //
//Content              :=   {*keys-values in form*                  }  WebRequest.Content;                                   //
  // server
  ServerAddr           :=   {10.176.39.2                            }  WebRequest.GetFieldByName('LOCAL_ADDR');              //
  ServerHost           :=   {localhost | www.abc.com                }  WebRequest.GetFieldByName('HTTP_HOST');               // WebRequest.Host
//ServerName           :=   {localhost                              }  WebRequest.GetFieldByName('SERVER_NAME');             //
  ServerPort           :=   {80                                     }  WebRequest.GetFieldByName('SERVER_PORT').ToInteger;   // WebRequest.ServerPort
  ServerPortSecure     :=   {80                                     }  WebRequest.GetFieldByName('SERVER_PORT_SECURE').ToInteger;
//ServerProtocol       :=   {HTTP/1.1                               }  WebRequest.GetFieldByName('SERVER_PROTOCOL');         //
  ServerSoftware       :=   {Microsoft-IIS/10.0                     }  WebRequest.GetFieldByName('SERVER_SOFTWARE');         //
  // serveriiswebsite
//WebsiteInstance      :=   {1                                      }  WebRequest.GetFieldByName('INSTANCE_ID');             //
//WebsitePath          :=   {/LM/W3SVC/1                            }  WebRequest.GetFieldByName('INSTANCE_META_PATH');      //
//WebsitePath          :=   {/LM/W3SVC/1/ROOT                       }  WebRequest.GetFieldByName('APPL_MD_PATH');            //
  // serverscript
//ScriptGateway        :=   {CGI/1.1                                }  WebRequest.GetFieldByName('GATEWAY_INTERFACE');       // GATEWAY_INTERFACE
//ScriptPath           :=   {X:\$\X\Win32\Debug                     }  WebRequest.GetFieldByName('APPL_PHYSICAL_PATH');      //
  ScriptName           :=   {/WksIsapiProject.dll                   }  WebRequest.ScriptName;                                // SCRIPT_NAME / WebRequest.InternalScriptName
  ScriptVer            :=   {1.0.0.123                              }  byn.Ver;                                              //
  // zzz
//Authorization        :=   {*empty*                                }  WebRequest.Authorization;                             //
//CacheControl         :=   {*empty* or no-cache                    }  WebRequest.CacheControl;                              // HTTP_CACHE_CONTROL
//Date                 :=   {1899-12-29                             }  DateTime(IvWebRequest.Date);                          //
//From                 :=   {*empty* / might conteins User          }  WebRequest.From;                                      //
//IfModifiedSince      :=   {1899-12-29                             }  DateTime(IvWebRequest.IfModifiedSince);               //
//DerivedFrom          :=   {*empty*                                }  WebRequest.DerivedFrom;                               //
  // end
  TimingMs             :=   {-1                                     }  -1;                                                   //
  {$ENDREGION}

  // note
  // UserOrganization IS-THE-ONLY-SURE-INFO, Username IS-AVAILABLE-AFTER-SUCCESSFUL-LOGIN
  *)
end;

function TWreRec.DbaInsert(var IvFbk: string): boolean;
var
  q: string;
  z: integer;
begin
  (* TEMPORARYCOMMENT

  // sql
  q :=           'insert into DbaClient.dbo.TblRequest'
  + sLineBreak + 'select'
  + sLineBreak + '    ' + sql.Val(DateTime            )
  // client
//+ sLineBreak + '  , ' + sql.Val(ClientIp            ) {10.176.85.121                          }
  + sLineBreak + '  , ' + sql.Val(ClientAddr          ) {10.176.85.121                          }
  + sLineBreak + '  , ' + sql.Val(ClientHost          ) {www.wks.cloud      (THE-ONLY-SURE-INFO)}
//+ sLineBreak + '  , ' + sql.Val(ClientPort          ) {62682                                  }
  + sLineBreak + '  , ' + sql.Val(ClientAccept        ) {text/html,application/xml              }
  + sLineBreak + '  , ' + sql.Val(ClientAcceptEncoding) {gzip, deflate                          }
  + sLineBreak + '  , ' + sql.Val(ClientAcceptLanguage) {en-US,en                               }
  + sLineBreak + '  , ' + sql.Val(ClientApp           ) {Mozilla/5.0 Windows NT...              }
  + sLineBreak + '  , ' + sql.Val(ClientAppVersion    ) {5.0 / 1.0.0.1                          }
  // clientfingerprint				      )
  + sLineBreak + '  , ' + sql.Val(ClientDoNotTrack    ) {1                                      }
  + sLineBreak + '  , ' + sql.Val(ClientTimezoneOffset) {?                                      }
  + sLineBreak + '  , ' + sql.Val(ClientLanguage      ) {?                                      }
  + sLineBreak + '  , ' + sql.Val(ClientPlatform      ) {?                                      }
  + sLineBreak + '  , ' + sql.Val(ClientOs            ) {?                                      }
  + sLineBreak + '  , ' + sql.Val(ClientCpuCores      ) {?                                      }
  + sLineBreak + '  , ' + sql.Val(ClientScreen        ) {?                                      }
  + sLineBreak + '  , ' + sql.Val(ClientAudio         ) {?                                      }
  + sLineBreak + '  , ' + sql.Val(ClientVideo         ) {?                                      }
  + sLineBreak + '  , ' + sql.Val(ClientLocalStorage  ) {?                                      }
  + sLineBreak + '  , ' + sql.Val(ClientSessionStorage) {?                                      }
  + sLineBreak + '  , ' + sql.Val(ClientIndexedDb     ) {?                                      }
  + sLineBreak + '  , ' + sql.Val(ClientFingerprint   ) {?                                      }
  // user					      )
  + sLineBreak + '  , ' + sql.Val(UserOrganization    ) {Wks (fromurl/dba)                      }
  + sLineBreak + '  , ' + sql.Val(UserDomain          ) {?                                      }
  + sLineBreak + '  , ' + sql.Val(UserComputer        ) {phobos                                 }
  + sLineBreak + '  , ' + sql.Val(Username            ) {giarussi | 353992                      }
//+ sLineBreak + '  , ' + sql.Val(UserPassword        )
//+ sLineBreak + '  , ' + sql.Val(UserLogon           ) {?                                      }
//+ sLineBreak + '  , ' + sql.Val(UserRemote          ) {?                                      }
//+ sLineBreak + '  , ' + sql.Val(UserRemoteUnmapped  ) {/                                      }
  // session					      )
  + sLineBreak + '  , ' + sql.Val(Session             ) {?                                      }
  + sLineBreak + '  , ' + sql.Val(Otp                 ) {?                                      }
  // http					      )
  + sLineBreak + '  , ' + sql.Val(HttpOrigin          ) {                                       }
  + sLineBreak + '  , ' + sql.Val(HttpProtocol        ) {HTTP/1.1                               }
  + sLineBreak + '  , ' + sql.Val(HttpMethod          ) {GET, POST                              }
  // request					      )
  + sLineBreak + '  , ' + sql.Val(RequestId           ) {095EBA6CEcb.ConnId                     }
  + sLineBreak + '  , ' + sql.Val(Connection          ) {keep-alive                             }
  + sLineBreak + '  , ' + sql.Val(Host                ) {aiwymsapp.ai.lfoundry.com              }
  + sLineBreak + '  , ' + sql.Val(Url                 ) {/WksIsapiProject.dll *partial or empty*}
  + sLineBreak + '  , ' + sql.Val(PathInfo            ) {/Info                                  }
//+ sLineBreak + '  , ' + sql.Val(InternalPathInfo    ) {/Info                                  }
//+ sLineBreak + '  , ' + sql.Val(RawPathInfo         ) {/Info                                  }
//+ sLineBreak + '  , ' + sql.Val(PathTranslated      ) {X:\$\X\Win32\Debug\Info                }
  + sLineBreak + '  , ' + sql.Val(Query               ) {?CoId=381&CoXxx=2                      }
//+ sLineBreak + '  , ' + sql.Val(Referer             ) {http://abc.com/WksIsapi.dll/Run?CoId=12}
//+ sLineBreak + '  , ' + sql.Val(Title               ) {*empty*                                }
//+ sLineBreak + '  , ' + sql.Val(Cookie              ) {CoOtp=933073; CoDomain=LOCALHOST;      }
//+ sLineBreak + '  , ' + sql.Val(TotalBytes          ) {0                                      }
//+ sLineBreak + '  , ' + sql.Val(Expires             ) {?                                      }
//+ sLineBreak + '  , ' + sql.Val(MimeType            ) {?                                      }
  // content					      )
//+ sLineBreak + '  , ' + sql.Val(ContentEncoding     ) {*empty*                                }
//+ sLineBreak + '  , ' + sql.Val(ContentType         ) {*empty* | application/x-www-form...    }
//+ sLineBreak + '  , ' + sql.Val(ContentLength       ) {0                                      }
//+ sLineBreak + '  , ' + sql.Val(ContentVersion      ) {*empty*                                }
//+ sLineBreak + '  , ' + sql.Val(ContentRaw          ) {*arrrayofbytes*                        }
//+ sLineBreak + '  , ' + sql.Val(Content             ) {*keys-values in form*                  }
  // server					      )
  + sLineBreak + '  , ' + sql.Val(ServerAddr          ) {10.176.39.2                            }
  + sLineBreak + '  , ' + sql.Val(ServerHost          ) {localhost | www.abc.com                }
//+ sLineBreak + '  , ' + sql.Val(ServerName          ) {localhost                              }
  + sLineBreak + '  , ' + sql.Val(ServerPort          ) {80                                     }
  + sLineBreak + '  , ' + sql.Val(ServerPortSecure    ) {80                                     }
//+ sLineBreak + '  , ' + sql.Val(ServerProtocol      ) {HTTP/1.1                               }
  + sLineBreak + '  , ' + sql.Val(ServerSoftware      ) {Microsoft-IIS/10.0                     }
  // serveriiswebsite				      )
//+ sLineBreak + '  , ' + sql.Val(WebsiteInstance     ) {1                                      }
//+ sLineBreak + '  , ' + sql.Val(WebsitePath         ) {/LM/W3SVC/1                            }
//+ sLineBreak + '  , ' + sql.Val(WebsitePath         ) {/LM/W3SVC/1/ROOT                       }
  // serverscript				      )
//+ sLineBreak + '  , ' + sql.Val(ScriptGateway       ) {CGI/1.1                                }
//+ sLineBreak + '  , ' + sql.Val(ScriptPath          ) {X:\$\X\Win32\Debug                     }
  + sLineBreak + '  , ' + sql.Val(ScriptName          ) {/WksIsapiProject.dll                   }
  + sLineBreak + '  , ' + sql.Val(ScriptVer           ) {1.0.0.123                              }
  // zzz					      )
//+ sLineBreak + '  , ' + sql.Val(Authorization       ) {*empty*                                }
//+ sLineBreak + '  , ' + sql.Val(CacheControl        ) {*empty* or no-cache                    }
//+ sLineBreak + '  , ' + sql.Val(Date                ) {1899-12-29                             }
//+ sLineBreak + '  , ' + sql.Val(From                ) {*empty* / might conteins User          }
//+ sLineBreak + '  , ' + sql.Val(IfModifiedSince     ) {1899-12-29                             }
//+ sLineBreak + '  , ' + sql.Val(DerivedFrom         ) {*empty*                                }
  // end					      )
  + sLineBreak + '  , ' + sql.Val(TimingMs            ) {-1                                     }
  ;
  // insert
  Result := db0.ExecFD(q, z, IvFbk);
  if not Result then
    lg.W(IvFbk);

  // fbk
  IvFbk := Format('Web request %d saved into database', [RequestId]);
  *)
end;

function TWreRec.TkvVec: TTkvVec;
var
  i, w: cardinal;
  r: TISAPIRequest;
  e: TEXTENSION_CONTROL_BLOCK;
//b: array [0..2048] of ansichar;
//l: TStringList;
  x: TTkvVec;
//a: TBytes; // StringOf converts TBytes to a UnicodeString, BytesOf converts a UnicodeString to TBytes
begin
  // isapirequest
  r := TISAPIRequest(WebRequest);
//r.ReadTotalContent;

  // requestfields
//l := TStringList.Create;
//try
//  r.ExtractFields([#0, #10, #13], [' '], r.Content, l);
//  Result := l.Text;
//finally
//  l.Free;
//end;

  // ecb
  e := r.ECB^;

  // ecbinfo
  SetLength(x, 10);
  x[0].Tag := 'Ecb'; x[0].Key := 'Size'          ; x[0].Val := Format('%d'  , [e.cbSize            ]);
  x[1].Tag := 'Ecb'; x[1].Key := 'Version'       ; x[1].Val := Format('%.8x', [e.dwVersion         ]);
  x[2].Tag := 'Ecb'; x[2].Key := 'ConnId'        ; x[2].Val := Format('%.8x', [e.ConnID            ]);
  x[3].Tag := 'Ecb'; x[3].Key := 'Method'        ; x[3].Val := Format('%s'  , [e.lpszMethod        ]);
  x[4].Tag := 'Ecb'; x[4].Key := 'Query'         ; x[4].Val := Format('%s'  , [e.lpszQueryString   ]);
  x[5].Tag := 'Ecb'; x[5].Key := 'PathInfo'      ; x[5].Val := Format('%s'  , [e.lpszPathInfo      ]);
  x[6].Tag := 'Ecb'; x[6].Key := 'PathTranslated'; x[6].Val := Format('%s'  , [e.lpszPathTranslated]);
  x[7].Tag := 'Ecb'; x[7].Key := 'TotalBytes'    ; x[7].Val := Format('%d'  , [e.cbTotalBytes      ]);
  x[8].Tag := 'Ecb'; x[8].Key := 'AvailableBytes'; x[8].Val := Format('%d'  , [e.cbAvailable       ]);
  x[9].Tag := 'Ecb'; x[9].Key := 'ContentType'   ; x[9].Val := Format('%s'  , [e.lpszContentType   ]);

  // headers
  //z := sizeof(b);
  w := Length(x);
  for i := Low(HTTP_HEADER_VEC) to High(HTTP_HEADER_VEC) do begin
    SetLength(x, w+i+1);

    // servar
    //b := '';
    //e.GetServerVariable(e.ConnID, @HTTP_HEADER_VEC[i], @b, z);
    //Result := Result + Format('<br>%s :: %s', [HTTP_HEADER_VEC[i], b]);

    // wrevar
    x[w+i].Tag := 'Header'; x[w+i].Key := HTTP_HEADER_VEC[i]; x[w+i].Val := r.GetFieldByName(HTTP_HEADER_VEC[i]);
  end;

  // cookiefields
  if WebRequest.CookieFields.Count > 0 then begin
    w := Length(x);
    for i := 0 to WebRequest.CookieFields.Count-1 do begin
      SetLength(x, Length(x)+1);
      x[w+i].Tag := 'Cookie'; x[w+i].Key := WebRequest.CookieFields.Names[i];  x[w+i].Val := WebRequest.CookieFields.ValueFromIndex[i];
    end;
  end;

  // queryfields
  if WebRequest.QueryFields.Count > 0 then begin
    w := Length(x);
    for i := 0 to WebRequest.QueryFields.Count-1 do begin
      SetLength(x, Length(x)+1);
      x[w+i].Tag := 'Query'; x[w+i].Key := WebRequest.QueryFields.KeyNames[i] {+ ' - ' + WebRequest.QueryFields.Names[i]}; x[w+i].Val := WebRequest.QueryFields.ValueFromIndex[i];
    end;
  end;

  // contentfields
  if WebRequest.ContentFields.Count > 0 then begin
    w := Length(x);
    for i := 0 to WebRequest.ContentFields.Count-1 do begin
      SetLength(x, Length(x)+1);
      x[w+i].Tag := 'Content'; x[w+i].Key := WebRequest.ContentFields.Names[i];  x[w+i].Val := WebRequest.ContentFields.ValueFromIndex[i];
    end;
  end;

  // end
  Result := x;
end;

function TWreRec.PathInfoActionIsValid(IvPathInfoAction: string): boolean;
//var
//  i: integer;
begin
//  for i := 0 to self.Actions.Count - 1 do begin // non ho trovato a cosa corrisponda self
//    Result := Actions[i].PathInfo = IvPathInfoAction;
//    if Result then
//      Exit;
//  end;
  raise Exception.Create(NOT_IMPLEMENTED);
end;

function TWreRec.PathInfoQuery: string;
begin
  Result := iif.ExP(PathInfo, '/') + iif.ExP(Query, '?');
end;

function TWreRec.PathInfoQueryUrl: string;
begin
  Result := iif.ExP(Url, '/') + PathInfoQuery;
end;

function TWreRec.UrlFull: string;
begin
  Result := 'http://' + Host + iif.ExP(ServerPort.ToString, ':') + PathInfoQueryUrl;
end;
{$ENDREGION}

{$REGION 'TWrsRec'}
procedure TWrsRec.CookieAdd(IvResponse: TWebResponse; IvCookie: string; IvValue: variant; IvExpireInXDay: double);
begin
  with IvResponse.Cookies.Add do begin
    Name    := IvCookie;
    Value   := IvValue;
  //Domain  := wre.Domain;
    Path    := '/';
  //Secure  := false;
    Expires := Now + IvExpireInXDay;
  end;

  {$REGION 'Zzz'}
(*
  IvCookieCol.Add;
  IvCookieCol.Items[IvCookieCol.Count-1].Name    := IvCookie;
  IvCookieCol.Items[IvCookieCol.Count-1].Value   := IvValue;
//IvCookieCol.Items[IvCookieCol.Count-1].Domain  := ?;
  IvCookieCol.Items[IvCookieCol.Count-1].Path    := '/';
//IvCookieCol.Items[IvCookieCol.Count-1].Secure  := false;
  IvCookieCol.Items[IvCookieCol.Count-1].Expires := Now + IvExpireInXDay;
*)
  {$ENDREGION}

end;

procedure TWrsRec.CookieDelete(IvResponse: TWebResponse; IvCookie: string);
begin
  raise Exception.Create(NOT_IMPLEMENTED);
end;

function TWrsRec.CustomHeaderAdd(IvWebRequest: TWebRequest; IvWebResponse: TWebResponse; var IvFbk: string): boolean;
begin
  // samples
//IvWebResponse.ContentType := 'text/html';                                          // simulate text/hatml content
//IvWebResponse.ContentType := 'application/javascript';                             // simulate text/javascript content
//IvWebResponse.ContentType := MimeTypeFromContent(@m, m.Size);                      // setmime, MimeTypeFromRegistry(fe) <- not working!!!
//IvWebResponse.SetCustomHeader(HTTP_HEADER_CONTENT_TYPE, MIME_TYPE_TEXT_XML_UTF8);  //
//IvWebResponse.SetCustomHeader('Content-Disposition', 'filename=' + n);             // set "suggested file name" in case a user try a download and save file as

  // no page cache in the client
  IvWebResponse.SetCustomHeader('Expires', htt.HTTP_HEADER_EXPIRE);

  // cors
  IvWebResponse.SetCustomHeader('Access-Control-Allow-Origin', '*');
  if Trim(IvWebRequest.GetFieldByName('Access-Control-Request-Headers')) <> '' then
    IvWebResponse.SetCustomHeader('Access-Control-Allow-Headers', IvWebRequest.GetFieldByName('Access-Control-Request-Headers'));

  // logallcustomheaders
  Result := true;
  IvFbk := 'OK';
end;
{$ENDREGION}

initialization

{$REGION 'Init'}
OutputDebugString('WKSALLUNIT INIT --== I N I T I A L I Z A T I O N ==--');

{$REGION 'Help'}
{
  W A R N I N G
  =============
  THIS INITIALIZATION SECTION HAPPENS ONLY ONE TIME

  IF THE APP IS A CLIENT IT MAY BE OK TO DEFINE/INITIALIZE HERE OBJECTS LIKE TLogRec, TIniRec, TDbaCls,
  THIS IS BECAUSE IN A CLIENT APP ALL THINGS HAPPEND IN THE MAIN SINGLE THREAD

  IF THE APP IS A SERVER (ISAPI,SOAP,ETC.) IT IS LOADED UNDER IIS ONCE SO THIS INITIALIZATION HAPPENS ONCE
  BUT UNDER HEAVY LOAD, IIS MIGHT INSTANZIATE SEVARAL INSTANCES OF A WEBMODULE IN DIFFERENT THREADS
  THIS CAUSE THE SAME TLogRec, TIniRec / TDbaCls TO BE CALLED IN PARALLEL CAUSING PROBLEMS, AT LEAST IN FIREDAC
  SO THESE OBJECTS MUST BE INSTAZIATED IN THE ONBEFOREDISPATCH AND DESTROIED IN ONAFTERDISPATCH SO EACH THREAD HAS ITS OWN DB CONNECTION OR LOG
}
{$ENDREGION}

{$REGION 'FormatSettings'}
FormatSettings.DecimalSeparator  := '.';              // or numbers will be 12,123 with a comma instead of a period
FormatSettings.ShortDateFormat   := 'MM/dd/yyyy';     // or mssql will fails
FormatSettings.ShortTimeFormat   := 'HH:mm:ss AM/PM'; // or mssql will fails
Application.UpdateFormatSettings := false;            // avoid windows to change back the format setting, to much size increase
OutputDebugString('WKSALLUNIT INIT FormatSettings applied');
{$ENDREGION}

{$REGION 'Leaks'}
{$WARN SYMBOL_PLATFORM OFF}
ReportMemoryLeaksOnShutDown := IsDebuggerPresent();
OutputDebugString('WKSALLUNIT INIT ReportMemoryLeaksOnShutDown');
{$WARN SYMBOL_PLATFORM ON}
{$ENDREGION}

{$REGION 'reg'}
//RegisterClasses([TIcon, TMetafile, TBitmap, TJPEGImage, TPngImage]); // you might register others if wished (foR blobtopicture)
{$ENDREGION}

{$REGION 'xml'}
//Xml.Win.msxmldom.MSXMLDOMDocumentFactory.AddDOMProperty('ProhibitDTD', false);
{$ENDREGION}

{$REGION 'wa0'}
wa0 := TStopwatch.StartNew;
OutputDebugString('WKSALLUNIT INIT TStopwatch wa0 started');
{$ENDREGION}

{$REGION 'sys'}                                                                 (*
// main
bmp.GetFromRc(sys.LogoBmp, 'WKS_LOGO_BMP_RC');
lg.I('Assigned', 'WKSALLUNIT INIT COMMON SYSTEM LOGO');

// dirs
if not DirectoryExists(sys.TEMPDIR) then CreateDir(sys.TEMPDIR);

// smtp-out
sys.Smtp.Host     := ini.StrGet('Smtp/Host'    , sys.SMTP_HOST    );
sys.Smtp.Port     := ini.StrGet('Smtp/Port'    , sys.SMTP_PORT    );
sys.Smtp.Username := ini.StrGet('Smtp/Username', sys.SMTP_USERNAME);
sys.Smtp.Password := ini.StrGet('Smtp/Password', sys.SMTP_PASSWORD);
lg.I('Assigned', 'WKSALLUNIT INIT COMMON SYSTEM SMTP');

// pop3-in
sys.Pop3.Host     := ini.StrGet('Pop3/Host'    , sys.POP3_HOST    );
sys.Pop3.Port     := ini.StrGet('Pop3/Port'    , sys.POP3_PORT    );
sys.Pop3.Username := ini.StrGet('Pop3/Username', sys.POP3_USERNAME);
sys.Pop3.Password := ini.StrGet('Pop3/Password', sys.POP3_PASSWORD);
lg.I('Assigned', 'WKSALLUNIT INIT COMMON SYSTEM POP3');

OutputDebugString('WKSALLUNIT INIT TSysRec sys initialized');                   *)
{$ENDREGION}

{$REGION 'lic'}
//OutputDebugString('WKSALLUNIT INIT TLicRec lic not implemented');
{$ENDREGION}

{$REGION 'log'}
lgt := TLgtCls.Create(); // globalobject
OutputDebugString('WEBMODULE TThreadFileLog created');
{$ENDREGION}

{$REGION 'SERVER'}
if byn.IsServer or byn.IsDemon then begin

  {$REGION 'com'}
//CoInitializeEx(nil, COINIT_MULTITHREADED); // use COINIT_APARTMENTTHREADED for opaR
//OutputDebugString('WKSALLUNIT INIT SERVER COM initialized');
  {$ENDREGION}

  {$REGION 'dba'}
//db0 := TDbaCls.Create(ini.StrGet('Database/Db0FDCs', ''));
//OutputDebugString('WKSALLUNIT INIT SERVER TDbaCls db0 created (mssql)'); // db0.FCsFD , db0.FCsADO

//db1 := TDbaCls.Create(ini.StrGet('Database/Db1Cs', ''));
//OutputDebugString('WKSALLUNIT INIT SERVER TMonCls db1 created (mongo)');

//db2 := TDbaCls.Create(ini.StrGet('Database/Db2Cs', ''), 'Redis', '???Client');
//OutputDebugString('WKSALLUNIT INIT SERVER TRedCls db2 created (redis)');

//db3 := TDbaCls.Create(ini.StrGet('Database/Db3Cs', ''), 'Kafka', 'LogClient');
//OutputDebugString('WKSALLUNIT INIT SERVER TKafCls db2 created (kafka)');
  {$ENDREGION}

  {$REGION 'usr,mbr,org,smt,pop : nologin'}
//OutputDebugString('WKSALLUNIT INIT SERVER User, member and organization data acquired after a user webrequest (domanin -> organization, login --> user/menber)');
  {$ENDREGION}

end;
{$ENDREGION}

{$REGION 'CLIENT'}
if byn.IsClient then begin

  {$REGION 'ico'}
  h0 := LoadIcon(HInstance, 'AAA_APPLICATION_BIN_ICON_RC');
  if h0 > 0 then begin
    Application.Icon.Handle := h0; // assign main icon at runtime
    OutputDebugString('WKSALLUNIT INIT CLIENT icon assigned');
  end else
    OutputDebugString('WKSALLUNIT INIT CLIENT Unable to assign icon');
  {$ENDREGION}

  {$REGION 'hlp'}
//Application.HelpFile := ChangeFileExt(Application.ExeName, 'Help.chm');
//OutputDebugString('WKSALLUNIT INIT CLIENT Help file not implemented');
  {$ENDREGION}

  {$REGION 'com'}
//OutputDebugString('WKSALLUNIT INIT CLIENT Com not implemented');
  {$ENDREGION}

  {$REGION 'dba'}
//OutputDebugString('WKSALLUNIT INIT CLIENT Dba not implemented');
  {$ENDREGION}

  {$REGION 'net'}
//if not net.InternetIsAvailable(fk) then begin
//  OutputDebugString('WKSALLUNIT INI Internet is not available, exit');
//  raise Exception.Create('Internet is not available, exit');
  //Application.Terminate; // shut down in an orderly fashion
  //System.Halt;           // initiates the abnormal termination of the program
  //ExitProcess;           // exit as quickly as possible, executing the minimum amount of code along the way, it is the final step of Halt
  //TerminateProcess;      // even more brutal
  //Exit;
//end;
  {$ENDREGION}

  {$REGION 'usr,mbr,org,smt,pop : login'}
//if not TLoginForm.Execute(fk) then begin // fk := 'Unable to login'; // loginandsessionopen
//  raise Exception.Create(fk);
  //Application.Terminate;
//end;
//OutputDebugString('WKSALLUNIT INIT CLIENT User, member and organization data acquired after a succesful login');
  {$ENDREGION}

  {$REGION 'gui'}
//syn.SynEditSearch      := TSynEditSearch.Create(nil);
//syn.SynEditRegexSearch := TSynEditRegexSearch.Create(nil);
//syg.SearchFromCaret    := true;
//OutputDebugString('WKSALLUNIT INIT Client gui stuff created (syneditsearch)');
  {$ENDREGION}

end;
{$ENDREGION}

{$ENDREGION}

finalization

{$REGION 'Fine'}
OutputDebugString('WKSALLUNIT FINE --== F I N A L I Z A T I O N ==--');

{$REGION 'CLIENT'}
if byn.IsClient then begin

  {$REGION 'gui'}
//FreeAndNil(syn.SynEditSearch);
//FreeAndNil(syn.SynEditRegexSearch);
//OutputDebugString('WKSALLUNIT FINE Client gui stuff free (syneditsearch)');
  {$ENDREGION}

  {$REGION 'usr,mbr,org,smt,pop : logout'}
//FreeAndNil(org.LogoGraphic);
//OutputDebugString('WKSALLUNIT FINE CLIENT User, member and organization stuff free');

  // sessionclose
//ses.RioClose(usr.Organization, usr.Username, fk);
//OutputDebugString('WKSALLUNIT FINE CLIENT User logout');
  {$ENDREGION}

end;
{$ENDREGION}

{$REGION 'SERVER'}
if byn.IsServer or byn.IsDemon then begin

  {$REGION 'usr,mbr,org,smt,pop : nologout'}
//usr.Avatar.Free;
//mbr.Badge.Free;
//org.LogoGraphic.Free;
//OutputDebugString('WKSALLUNIT FINE SERVER User, member and organization stuff free');
  {$ENDREGION}

  {$REGION 'dba'}
//db0.Free; // *** problems freeing the FConnFD ***
//OutputDebugString('WKSALLUNIT FINE SERVER TDbaCls db0 free (mssql)');
  {$ENDREGION}

  {$REGION 'com'}
//CoUninitialize; // non so se e' questo a causare il disaster !!!
//OutputDebugString('WKSALLUNIT FINE SERVER COM uninitialize');
  {$ENDREGION}

end;
{$ENDREGION}

{$REGION 'log'}
//lgt.Free; // cause the iis applicationpool to not recycle properly
OutputDebugString('WEBMODULE TThreadFileLog NOT free');
{$ENDREGION}

{$REGION 'sys'}
//FreeAndNil(sys.LogoBmp);
//OutputDebugString('WKSALLUNIT FINE TSysCls logo bitmap free');
{$ENDREGION}

{$REGION 'wa0'}
OutputDebugString(PWideChar('WKSALLUNIT FINE TStopwatch total lifetime ' + wa0.ElapsedMilliseconds.ToString + ' ms'));
{$ENDREGION}

OutputDebugString('WKSALLUNIT FINE --== E N D ==--');
{$ENDREGION}

{$REGION 'Zzz'}

  {$REGION 'Html'}
(*
  + sLineBreak + ''
  + sLineBreak + ''
  + sLineBreak + '<!-- Page Container -->'
  + sLineBreak + '<div class="w3-container w3-content" style="max-width:1400px;margin-top:80px">'
  + sLineBreak + '  <!-- The Grid -->'
  + sLineBreak + '  <div class="w3-row">'
  + sLineBreak + '    <!-- Left Column -->'
  + sLineBreak + '    <div class="w3-col m3">'
  + sLineBreak + ''
  + sLineBreak + ''
  + sLineBreak + '    <!-- End Left Column -->'
  + sLineBreak + '    </div>'
  + sLineBreak + ''
  + sLineBreak + '    <!-- Middle Column -->'
  + sLineBreak + '    <div class="w3-col m7">'
  + sLineBreak + ''
  + sLineBreak + '    <!-- End Middle Column -->'
  + sLineBreak + '    </div>'
  + sLineBreak + ''
  + sLineBreak + '    <!-- Right Column -->'
  + sLineBreak + '    <div class="w3-col m2">'
  + sLineBreak + '      <div class="w3-card w3-round w3-white w3-center">'
  + sLineBreak + '        <div class="w3-container">'
  + sLineBreak + '          <p>Upcoming Events:</p>'
  + sLineBreak + '          <img src="/w3images/forest.jpg" alt="Forest" style="width:100%;">'
  + sLineBreak + '          <p><strong>Holiday</strong></p>'
  + sLineBreak + '          <p>Friday 15:00</p>'
  + sLineBreak + '          <p><button class="w3-button w3-block w3-theme-l4">Info</button></p>'
  + sLineBreak + '        </div>'
  + sLineBreak + '      </div>'
  + sLineBreak + '      <br>'
  + sLineBreak + ''
  + sLineBreak + '      <div class="w3-card w3-round w3-white w3-center">'
  + sLineBreak + '        <div class="w3-container">'
  + sLineBreak + '          <p>Friend Request</p>'
  + sLineBreak + '          <img src="/w3images/avatar6.png" alt="Avatar" style="width:50%"><br>'
  + sLineBreak + '          <span>Jane Doe</span>'
  + sLineBreak + '          <div class="w3-row w3-opacity">'
  + sLineBreak + '            <div class="w3-half">'
  + sLineBreak + '              <button class="w3-button w3-block w3-green w3-section" title="Accept"><i class="fa fa-check"></i></button>'
  + sLineBreak + '            </div>'
  + sLineBreak + '            <div class="w3-half">'
  + sLineBreak + '              <button class="w3-button w3-block w3-red w3-section" title="Decline"><i class="fa fa-remove"></i></button>'
  + sLineBreak + '            </div>'
  + sLineBreak + '          </div>'
  + sLineBreak + '        </div>'
  + sLineBreak + '      </div>'
  + sLineBreak + '      <br>'
  + sLineBreak + ''
  + sLineBreak + '      <div class="w3-card w3-round w3-white w3-padding-16 w3-center">'
  + sLineBreak + '        <p>ADS</p>'
  + sLineBreak + '      </div>'
  + sLineBreak + '      <br>'
  + sLineBreak + ''
  + sLineBreak + '      <div class="w3-card w3-round w3-white w3-padding-32 w3-center">'
  + sLineBreak + '        <p><i class="fa fa-bug w3-xxlarge"></i></p>'
  + sLineBreak + '      </div>'
  + sLineBreak + ''
  + sLineBreak + '    <!-- End Right Column -->'
  + sLineBreak + '    </div>'
  + sLineBreak + ''
  + sLineBreak + '  <!-- End Grid -->'
  + sLineBreak + '  </div>'
  + sLineBreak + ''
  + sLineBreak + '<!-- End Page Container -->'
  + sLineBreak + '</div>'
*)
  {$ENDREGION}

  {$REGION 'Rio'}
(*
// see: http://docwiki.embarcadero.com/RADStudio/XE/en/Using_Web_Services_Index
procedure TRioRec.EnvironmentSet(IvEnvironment: string);
begin
  Environment := IvEnvironment;
end;

// THTTPRIO OnBeforeExecute and OnAfterExecute events will allow access to outcoming and incoming xml envelopes,
// so use these events to inspect the xml for example to inspect the coming back xml use:
procedure TForm1.HTTPRIO1AfterExecute(const MethodName: String; SOAPResponse: TStream);
var
  s: TStringStream;
  r: string // responsexml
begin
  s := TStringStream.Create('');
  try
    s.CopyFrom(SOAPResponse, 0);
    r := Utf8Decode(s.DataString);
  finally
    FreeAndNil(s);
  end;
end;

function TRioRec.RecordInsertSimple(const IvTable: string; const IvStringVe: TStringVector; var IvFbk: string): boolean;
begin
  Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapRecordInsertSimple(IvTable, IvStringVe, IvFbk);
  if not Result then
    lg.W(IvFbk);
end;

function  TSopRec.SoapRioCreateByUrl(var IvHttpRio: THTTPRIO; IvName, IvUrl: string; var IvFbk: string): boolean;
begin
  // exit
  Result := IvUrl <> '';
  if not Result then begin
    IvHttpRio := nil;
    IvFbk := Format('Unable to create HttpRio %s, url is empty', [IvName]);
    Exit;
  end;

  // do
//if IvOwner.FindComponent(IvName) is THTTPRIO then begin
//  IvHttpRio := IvOwner.FindComponent(IvName) as THTTPRIO;
//  IvHttpRio.URL := IvUrl;
//  IvFbk := Format('HttpRio %s already exists, updated it with url %s', [IvName, IvUrl]);
//  Result := true;
//end else begin
    IvHttpRio := THTTPRIO.Create({IvOwner}nil); // if THTTPRIO is created without an owner, it uses interface reference counting to manage its lifetime
    IvHttpRio.Name := IvName;                   // typecasting it to IXxx creates a temporary interface reference that gets released at the end of the function
    IvHttpRio.URL  := IvUrl;
    if pxy.Use then begin
      IvHttpRio.HTTPWebNode.URL      := pxy.AddressAndPort;
      IvHttpRio.HTTPWebNode.Username := pxy.Username;
      IvHttpRio.HTTPWebNode.Password := pxy.Password;
    end;
    IvFbk := Format('Created HttpRio %s with url %s', [IvName, IvUrl]);
    Result := true;
//end;
end;

function  TSopRec.SoapRioCreateByPsw(var IvHttpRio: THTTPRIO; IvName, IvPort, IvService, IvWsdl: string; var IvFbk: string): boolean;
begin
  // exit
  Result := (IvName <> '') and (IvPort <> '') and (IvService <> '') and (IvWsdl <> '');
  if not Result then begin
    IvFbk := Format('Unable to create HttpRio %s, port, name, service and wsdl must be not empty', [IvName]);
    Exit;
  end;

  // do
  IvHttpRio := THTTPRIO.Create(nil);
  IvHttpRio.Name    := IvName;
  IvHttpRio.Port    := IvPort;
  IvHttpRio.Service := IvService;
  IvHttpRio.WSDLLocation := IvWsdl;
  if pxy.Use then begin
    IvHttpRio.HTTPWebNode.URL      := pxy.AddressAndPort;
    IvHttpRio.HTTPWebNode.Username := pxy.Username;
    IvHttpRio.HTTPWebNode.Password := pxy.Password;
  end;
  IvFbk := Format('Created HttpRio %s with port %s, service %s and wsdl %s', [IvName, IvPort, IvService, IvWsdl]);
  Result := true;
end;

function  TSopRec.SoapRioCreate(var IvHttpRio: THTTPRIO; IvObj, IvService: string; var IvFbk: string): boolean;
var
  n, u{, s, p, w}: string; // name, url, service, port, wsdl
begin
  // name
  n := nam.RndPostfix('HttpRio');

  // useurl
//if true then begin
   {Result :=} SoapRioUrl(IvObj, IvService, u, IvFbk);
    Result := SoapRioCreateByUrl({IvOwner: TComponent;}IvHttpRio, n, u, IvFbk);

  // usewsdl
//end else begin
//  Result := SoapRioWsdl(IvObj, IvService, w, IvFbk);
//  s := '';
//  p := '';
//  Result := SoapRioCreateByPsw({IvOwner: TComponent;}IvHttpRio, n, p, s, w, IvFbk);
//end;

  // beforepost
//IvHttpRio.HTTPWebNode.OnBeforePost := ...; // you should use TRio
end;
*)
  {$ENDREGION}

  {$REGION 'Soap'}
(*
function  SoapConnectionCreate(IvOwner: TComponent; var IvSoapConnection: TSoapConnection; IvName, IvUrl: string; var IvFbk: string): boolean;
begin
  if IvUrl = '' then begin
    IvSoapConnection := nil;
    IvFbk := Format('Unable to create SoapConnection %s, url is empty', [IvName]);
    Result := false;
  end else begin
    if IvOwner.FindComponent(IvName) is TSoapConnection then begin
      IvSoapConnection := IvOwner.FindComponent(IvName) as TSoapConnection;
      IvSoapConnection.Close;
      IvSoapConnection.URL := IvUrl;
      IvFbk := Format('SoapConnection %s already exists, updated it with url %s', [IvName, IvUrl]);
      Result := true;
    end else begin
      IvSoapConnection := TSoapConnection.Create(IvOwner);
      IvSoapConnection.Name := IvName;
      IvSoapConnection.URL := IvUrl;
      IvFbk := Format('Created SoapConnection %s with url %s', [IvName, IvUrl]);
      Result := true;
    end;
  end;
end;

function  SoapConnectionCreate2(IvOwner: TComponent; var IvSoapConnection: TSoapConnection; IvWebSiteRec: TWebSiteRec; IvObj: string; var IvFbk: string): boolean;
var
  u: string;
begin
  Result := SoapDmUrl(IvWebSiteRec, IvObj, u, IvFbk);
  if not Result then begin
    IvSoapConnection := nil;
  end else begin
    Result := SoapConnectionCreate(IvOwner, IvSoapConnection, NameRndPostfix('SoapConn'), u, IvFbk);
  end;
end;

function  SoapRioPort(IvObj, IvService: string; var IvPort, IvFbk: string): boolean;
begin
  IvPort := Format(SOAP_PORT, [IvObj, IvService]);
  IvFbk := Format('return rio port url %s', [IvPort]);
  Result := true;
end;

function  SoapRioService(IvObj, IvService: string; var IvServiceStr, IvFbk: string): boolean;
begin
  IvServiceStr := Format(SOAP_SERVICE, [IvObj, IvService]);
  IvFbk := Format('return rio service %s', [IvService]);
  Result := true;
end;
*)
  {$ENDREGION}

{$ENDREGION}

end.
