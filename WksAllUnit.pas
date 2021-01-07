unit WksAllUnit;

// - remove : TEMPORARYCOMMENT
// - remove : ACCOUNTS (mesrport1)
// - remove : PASSWORDS (lf123,igi0ade)
// - remove : REFERENCES
// - remove : iarussigiovannigiarussiwkslfmicroengitech
// - remove : rva.Rv( intermedi

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
  , System.SyncObjs                 // tcriticalsection
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
  , superobject                     // json
  , VirtualTrees                    // virtualstringtree
  , DTDBTreeView                    // pnodeitem
//, DTClientTree
//, XSuperobject                    // json
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
  NO_DATA_STR                = 'No Data';
//NOT_FOUND_STR              = 'Not found';
  NOT_ASSIGNED_STR           = 'Not assigned';
//NOT_AVAILABLE_STR          = 'Not available';
//NOT_AUTHORIZED_STR         = 'Not authorized';
  NOT_IMPLEMENTED_STR        = 'Not implemented';
//NOT_AN_OPTION_STR          = 'Not an option';
//FIRST_STR                  = 'First';
//LAST_STR                   = 'Last';
//STATE_ACTIVE_STR           = 'Active';
  KIND_CSV                   = ',Bat,Css,Csv,Dws,Etl,Folder,Html,Js,Json,Link,Member,Organization,Param,Pas,Person,Py,R,Root,Sql,Txt'; // *** WARNING, DUPLICATE, INCOMPLETE, REMOVE ***
  clWks                      = $BD814F; // wkscolor
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
  INI_CLIENT_DEFAULT =
                 '[Server]'
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
  INI_SERVER_DEFAULT =
                 '[Database]'
//+ sLineBreak + 'Db0CsADO=Provider=SQLNCLI11.1;Data Source=LOCALHOST;Initial Catalog=DbaClient;User ID=sa;Password=secret;Persist Security Info=True'
  + sLineBreak + 'Db0CsFD=DriverID=Mssql;Server=LOCALHOST;Database=DbaClient;User_Name=sa;Password=secret'
  + sLineBreak
  + sLineBreak + '[WebRequest]'
  + sLineBreak + 'OtpIsActive=0'
  + sLineBreak + 'AuditIsActive=0'
  ;
  INI_DEMON_DEFAULT =  '[Database]'
//+ sLineBreak + 'Db0CsADO=Provider=SQLNCLI11.1;Data Source=LOCALHOST;Initial Catalog=DbaClient;User ID=sa;Password=secret;Persist Security Info=True'
  + sLineBreak + 'Db0CsFD=DriverID=Mssql;Server=LOCALHOST;Database=DbaClient;User_Name=sa;Password=secret'
  ;
  {$ENDREGION}

  {$REGION 'Connection'}
  CONN_DEF_NAME_FD = 'WKSFDCONNECTIONPOOLED';
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

  {$REGION 'Http'}
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

  {$REGION 'Web'}
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
  TDbaCls = class;

  TAllRec = record // ALL - THIS DO THINGS ALL IN ONE SHOT
  public
    function  RecordDbaInit(IvOrganization, IvUsername: string; var IvFbk: string): boolean;
    function  RecordRioInit(IvOrganization, IvUsername: string; var IvFbk: string): boolean;
    function  BeforeDispatch(IvWebRequest: TWebRequest; IvWebResponse: TWebResponse; IvOtpIsActive, IvAuditIsActive: boolean; var IvFbk: string): boolean;
    function  AfterDispatch (IvStopwatch: TStopwatch; IvWebRequest: TWebRequest; IvWebResponse: TWebResponse; IvOtpIsActive, IvAuditIsActive: boolean; var IvFbk: string): boolean;
  end;

  TAskRec = record // yes/no, str, int input dialog
    function  Yes(IvMessage: string = 'Continue ?'): boolean;
    function  YesFmt(IvMessageFormatString: string; IvVarRecVector: array of TVarRec): boolean;
    function  No(IvMessage: string = 'Continue ?'): boolean;
    function  NoFmt(IvMessageFormatString: string; IvVarRecVector: array of TVarRec): boolean;
    function  Str(IvCaption, IvPrompt, IvDefault: string; var IvStr: string): boolean;
    function  Int(IvCaption, IvPrompt: string; IvDefault: integer; var IvInt: integer): boolean;
  end;

  TBolRec = record // boolean
  public
    function  ToStr(IvBoolean: boolean; IvLowerCase: boolean = false): string; // WARNING: also in SysyUtils
    function  FromStr(IvString: string; IvDefault: boolean = false): boolean;  // see StrAsBool
    function  VectorToBinaryStr(IvBooleanVec: array of boolean): string;       // in = [false, true, false]  out = '010'
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

  TCodRec = record // code *** MOVE TO WksCodeUnit ***
  const
    BAT_KIND        = 'Bat'     ;
    CSS_KIND        = 'Css'     ;
    CSV_KIND        = 'Csv'     ;
    DWS_KIND        = 'Dws'     ;
    ETL_KIND        = 'Etl'     ;
    ETL_SQL_KIND    = 'EtlSql'  ;
    ETL_MONGO_KIND  = 'EtlMdb'  ;
    HTML_KIND       = 'Html'    ;
    INI_KIND        = 'Ini'     ;
    ISS_KIND        = 'Iss'     ;
    JAVA_KIND       = 'Java'    ;
    JS_KIND         = 'Js'      ;
    JSON_KIND       = 'Json'    ;
    PAS_KIND        = 'Pas'     ;
    PY_KIND         = 'Py'      ;
    R_KIND          = 'R'       ;
    SQL_KIND        = 'Sql'     ;
    TXT_KIND        = 'Txt'     ;
    XML_KIND        = 'Xml'     ;
    RETURN_ASSCRIPT = 'AsScript';
    RETURN_ASCSV    = 'AsCsv'   ;
    RETURN_ASJSON   = 'AsJson'  ;
  public
    function  CsvStr() : string; // Item, BgColor, FgColor
  //function  JsonStr(): string;
    function  Vector() : TStringVector;
    function  DbaCode(IvId: integer; var IvBlocs: integer; var IvType, IvCode, IvFbk: string): boolean;
    function  RioCode(IvId: integer; var IvBlocs: integer; var IvType, IvCode, IvFbk: string): boolean;
  end;

  TCoiRec = record // coloritem - for table mapping between html color name and rgb, argb colors
    Name   : string;
    RGB    : TColor;
    ARGB   : TColor;
  end;

  TColRec = record // color         delphi   html   // integrate this: X:\Application\_\S\ScreenSaver\Demo2\ColorRGB.pas
  const                         //  B G R    R G B
    WHITE     = clWhite;        //
    ORANGE    = clWebOrange;    // $0080FF  #FF8000
    ORANGERED = clWebOrangeRed; //
    BLUE      = clBlue;         //
    GREEN     = clGreen;        //
    RED       = clRed;          //
    GRAY      = clGray;         //
    BLACK     = clBlack;        //
    CANVASJS  = $AD9E36;        //          #AD9E36
    PINK      = $4040FF;        //          #FF4040
    WKS       = clWks;          // $BD814F  #4F81BD
    HLS_MAX   = 240;
    TABLE: array[0..151] of TCoiRec = (
      //     htmlnames                     rrggbb         aarrggbb  ( warning TColor is bbggrr )
     (Name: 'aliceblue'            ; RGB: $F0F8FF; ARGB: $FFF0F8FF)
   , (Name: 'antiquewhite'         ; RGB: $FAEBD7; ARGB: $FFFAEBD7)
   , (Name: 'aqua'                 ; RGB: $00FFFF; ARGB: $FF00FFFF)
   , (Name: 'aquamarine'           ; RGB: $7FFFD4; ARGB: $FF7FFFD4)
   , (Name: 'azure'                ; RGB: $F0FFFF; ARGB: $FFF0FFFF)
   , (Name: 'beige'                ; RGB: $F5F5DC; ARGB: $FFF5F5DC)
   , (Name: 'bisque'               ; RGB: $FFE4C4; ARGB: $FFFFE4C4)
   , (Name: 'black'                ; RGB: $000000; ARGB: $FF000000)
   , (Name: 'blanchedalmond'       ; RGB: $FFFFCD; ARGB: $FFFFEBCD)
   , (Name: 'blue'                 ; RGB: $0000FF; ARGB: $FF0000FF)
   , (Name: 'blueviolet'           ; RGB: $8A2BE2; ARGB: $FF8A2BE2)
   , (Name: 'brown'                ; RGB: $A52A2A; ARGB: $FFA52A2A)
   , (Name: 'burlywood'            ; RGB: $DEB887; ARGB: $FFDEB887)
   , (Name: 'cadetblue'            ; RGB: $5F9EA0; ARGB: $FF5F9EA0)
   , (Name: 'chartreuse'           ; RGB: $7FFF00; ARGB: $FF7FFF00)
   , (Name: 'chocolate'            ; RGB: $D2691E; ARGB: $FFD2691E)
   , (Name: 'coral'                ; RGB: $FF7F50; ARGB: $FFFF7F50)
   , (Name: 'cornflowerblue'       ; RGB: $6495ED; ARGB: $FF6495ED)
   , (Name: 'cornsilk'             ; RGB: $FFF8DC; ARGB: $FFFFF8DC)
   , (Name: 'crimson'              ; RGB: $DC143C; ARGB: $FFDC143C)
   , (Name: 'cyan'                 ; RGB: $00FFFF; ARGB: $FF00FFFF)
   , (Name: 'darkblue'             ; RGB: $00008B; ARGB: $FF00008B)
   , (Name: 'darkcyan'             ; RGB: $008B8B; ARGB: $FF008B8B)
   , (Name: 'darkgoldenrod'        ; RGB: $B8860B; ARGB: $FFB8860B)
   , (Name: 'darkgray'             ; RGB: $A9A9A9; ARGB: $FFA9A9A9)
   , (Name: 'darkgreen'            ; RGB: $006400; ARGB: $FF006400)
   , (Name: 'darkgrey'             ; RGB: $BDB76B; ARGB: $FFA9A9A9)
   , (Name: 'darkkhaki'            ; RGB: $BDB76B; ARGB: $FFBDB76B)
   , (Name: 'darkmagenta'          ; RGB: $8B008B; ARGB: $FF8B008B)
   , (Name: 'darkolivegreen'       ; RGB: $556B2F; ARGB: $FF556B2F)
   , (Name: 'darkorange'           ; RGB: $FF8C00; ARGB: $FFFF8C00)
   , (Name: 'darkorchid'           ; RGB: $9932CC; ARGB: $FF9932CC)
   , (Name: 'darkred'              ; RGB: $8B0000; ARGB: $FF8B0000)
   , (Name: 'darksalmon'           ; RGB: $E9967A; ARGB: $FFE9967A)
   , (Name: 'darkseagreen'         ; RGB: $8FBC8F; ARGB: $FF8FBC8F)
   , (Name: 'darkslateblue'        ; RGB: $483D8B; ARGB: $FF483D8B)
   , (Name: 'darkslategray'        ; RGB: $2F4F4F; ARGB: $FF2F4F4F)
   , (Name: 'darkslategrey'        ; RGB: $2F4F4F; ARGB: $FF2F4F4F)
   , (Name: 'darkturquoise'        ; RGB: $00CED1; ARGB: $FF00CED1)
   , (Name: 'darkviolet'           ; RGB: $9400D3; ARGB: $FF9400D3)
   , (Name: 'deeppink'             ; RGB: $FF1493; ARGB: $FFFF1493)
   , (Name: 'deepskyblue'          ; RGB: $00BFFF; ARGB: $FF00BFFF)
   , (Name: 'dimgray'              ; RGB: $696969; ARGB: $FF696969)
   , (Name: 'dimgrey'              ; RGB: $696969; ARGB: $FF696969)
   , (Name: 'dodgerblue'           ; RGB: $1E90FF; ARGB: $FF1E90FF)
   , (Name: 'firebrick'            ; RGB: $B22222; ARGB: $FFB22222)
   , (Name: 'floralwhite'          ; RGB: $FFFAF0; ARGB: $FFFFFAF0)
   , (Name: 'forestgreen'          ; RGB: $228B22; ARGB: $FF228B22)
   , (Name: 'fuchsia'              ; RGB: $FF00FF; ARGB: $FFFF00FF)
   , (Name: 'gainsboro'            ; RGB: $DCDCDC; ARGB: $FFDCDCDC)
   , (Name: 'ghostwhite'           ; RGB: $F8F8FF; ARGB: $FFF8F8FF)
   , (Name: 'gold'                 ; RGB: $FFD700; ARGB: $FFFFD700)
   , (Name: 'goldenrod'            ; RGB: $DAA520; ARGB: $FFDAA520)
   , (Name: 'gray'                 ; RGB: $808080; ARGB: $FF808080)
   , (Name: 'grey'                 ; RGB: $808080; ARGB: $FF808080)
   , (Name: 'green'                ; RGB: $008000; ARGB: $FF008000)
   , (Name: 'greenyellow'          ; RGB: $ADFF2F; ARGB: $FFADFF2F)
   , (Name: 'honeydew'             ; RGB: $F0FFF0; ARGB: $FFF0FFF0)
   , (Name: 'hotpink'              ; RGB: $FF69B4; ARGB: $FFFF69B4)
   , (Name: 'indianred'            ; RGB: $CD5C5C; ARGB: $FFCD5C5C)
   , (Name: 'indigo'               ; RGB: $4B0082; ARGB: $FF4B0082)
   , (Name: 'ivory'                ; RGB: $FFF0F0; ARGB: $FFFFFFF0)
   , (Name: 'khaki'                ; RGB: $F0E68C; ARGB: $FFF0E68C)
   , (Name: 'lavender'             ; RGB: $E6E6FA; ARGB: $FFE6E6FA)
   , (Name: 'lavenderblush'        ; RGB: $FFF0F5; ARGB: $FFFFF0F5)
   , (Name: 'lawngreen'            ; RGB: $7CFC00; ARGB: $FF7CFC00)
   , (Name: 'lemonchiffon'         ; RGB: $FFFACD; ARGB: $FFFFFACD)
   , (Name: 'lightblue'            ; RGB: $ADD8E6; ARGB: $FFADD8E6)
   , (Name: 'lightcoral'           ; RGB: $F08080; ARGB: $FFF08080)
   , (Name: 'lightcyan'            ; RGB: $E0FFFF; ARGB: $FFE0FFFF)
   , (Name: 'lightgoldenrodyellow' ; RGB: $FAFAD2; ARGB: $FFFAFAD2)
   , (Name: 'lightgreen'           ; RGB: $90EE90; ARGB: $FF90EE90)
   , (Name: 'lightgray'            ; RGB: $D3D3D3; ARGB: $FFD3D3D3)
   , (Name: 'lightgrey'            ; RGB: $D3D3D3; ARGB: $FFD3D3D3)
   , (Name: 'lightpink'            ; RGB: $FFB6C1; ARGB: $FFFFB6C1)
   , (Name: 'lightsalmon'          ; RGB: $FFA07A; ARGB: $FFFFA07A)
   , (Name: 'lightseagreen'        ; RGB: $20B2AA; ARGB: $FF20B2AA)
   , (Name: 'lightskyblue'         ; RGB: $87CEFA; ARGB: $FF87CEFA)
   , (Name: 'lightslategray'       ; RGB: $778899; ARGB: $FF778899)
   , (Name: 'lightslategrey'       ; RGB: $778899; ARGB: $FF778899)
   , (Name: 'lightsteelblue'       ; RGB: $B0C4DE; ARGB: $FFB0C4DE)
   , (Name: 'lightyellow'          ; RGB: $FFFFE0; ARGB: $FFFFFFE0)
   , (Name: 'lime'                 ; RGB: $00FF00; ARGB: $FF00FF00)
   , (Name: 'limegreen'            ; RGB: $32CD32; ARGB: $FF32CD32)
   , (Name: 'linen'                ; RGB: $FAF0E6; ARGB: $FFFAF0E6)
   , (Name: 'magenta'              ; RGB: $FF00FF; ARGB: $FFFF00FF)
   , (Name: 'maroon'               ; RGB: $800000; ARGB: $FF800000)
   , (Name: 'mediumaquamarine'     ; RGB: $66CDAA; ARGB: $FF66CDAA)
   , (Name: 'mediumblue'           ; RGB: $0000CD; ARGB: $FF0000CD)
   , (Name: 'mediumorchid'         ; RGB: $BA55D3; ARGB: $FFBA55D3)
   , (Name: 'mediumpurple'         ; RGB: $9370DB; ARGB: $FF9370DB)
   , (Name: 'mediumseagreen'       ; RGB: $3CB371; ARGB: $FF3CB371)
   , (Name: 'mediumslateblue'      ; RGB: $7B68EE; ARGB: $FF7B68EE)
   , (Name: 'mediumspringgreen'    ; RGB: $00FA9A; ARGB: $FF00FA9A)
   , (Name: 'mediumturquoise'      ; RGB: $48D1CC; ARGB: $FF48D1CC)
   , (Name: 'mediumvioletred'      ; RGB: $C71585; ARGB: $FFC71585)
   , (Name: 'midnightblue'         ; RGB: $191970; ARGB: $FF191970)
   , (Name: 'mintcream'            ; RGB: $F5FFFA; ARGB: $FFF5FFFA)
   , (Name: 'mistyrose'            ; RGB: $FFE4E1; ARGB: $FFFFE4E1)
   , (Name: 'moccasin'             ; RGB: $FFE4B5; ARGB: $FFFFE4B5)
   , (Name: 'navajowhite'          ; RGB: $FFDEAD; ARGB: $FFFFDEAD)
   , (Name: 'navy'                 ; RGB: $000080; ARGB: $FF000080)
   , (Name: 'null'                 ; RGB: $000000; ARGB: $00000000)
   , (Name: 'oldlace'              ; RGB: $FDF5E6; ARGB: $FFFDF5E6)
   , (Name: 'olive'                ; RGB: $808000; ARGB: $FF808000)
   , (Name: 'olivedrab'            ; RGB: $6B8E23; ARGB: $FF6B8E23)
   , (Name: 'orange'               ; RGB: $FFA500; ARGB: $FFFFA500)
   , (Name: 'orangered'            ; RGB: $FF4500; ARGB: $FFFF4500)
   , (Name: 'orchid'               ; RGB: $DA70D6; ARGB: $FFDA70D6)
   , (Name: 'palegoldenrod'        ; RGB: $EEE8AA; ARGB: $FFEEE8AA)
   , (Name: 'palegreen'            ; RGB: $98FB98; ARGB: $FF98FB98)
   , (Name: 'paleturquoise'        ; RGB: $AFEEEE; ARGB: $FFAFEEEE)
   , (Name: 'palevioletred'        ; RGB: $DB7093; ARGB: $FFDB7093)
   , (Name: 'papayawhip'           ; RGB: $FFEFD5; ARGB: $FFFFEFD5)
   , (Name: 'peachpuff'            ; RGB: $FFDBBD; ARGB: $FFFFDAB9)
   , (Name: 'peru'                 ; RGB: $CD853F; ARGB: $FFCD853F)
   , (Name: 'pink'                 ; RGB: $FFC0CB; ARGB: $FFFFC0CB)
   , (Name: 'plum'                 ; RGB: $DDA0DD; ARGB: $FFDDA0DD)
   , (Name: 'powderblue'           ; RGB: $B0E0E6; ARGB: $FFB0E0E6)
   , (Name: 'purple'               ; RGB: $800080; ARGB: $FF800080)
   , (Name: 'red'                  ; RGB: $FF0000; ARGB: $FFFF0000)
   , (Name: 'rosybrown'            ; RGB: $BC8F8F; ARGB: $FFBC8F8F)
   , (Name: 'royalblue'            ; RGB: $4169E1; ARGB: $FF4169E1)
   , (Name: 'saddlebrown'          ; RGB: $8B4513; ARGB: $FF8B4513)
   , (Name: 'salmon'               ; RGB: $FA8072; ARGB: $FFFA8072)
   , (Name: 'sandybrown'           ; RGB: $F4A460; ARGB: $FFF4A460)
   , (Name: 'seagreen'             ; RGB: $2E8B57; ARGB: $FF2E8B57)
   , (Name: 'seashell'             ; RGB: $FFF5EE; ARGB: $FFFFF5EE)
   , (Name: 'sienna'               ; RGB: $A0522D; ARGB: $FFA0522D)
   , (Name: 'silver'               ; RGB: $C0C0C0; ARGB: $FFC0C0C0)
   , (Name: 'skyblue'              ; RGB: $87CEEB; ARGB: $FF87CEEB)
   , (Name: 'slateblue'            ; RGB: $6A5ACD; ARGB: $FF6A5ACD)
   , (Name: 'slategray'            ; RGB: $708090; ARGB: $FF708090)
   , (Name: 'slategrey'            ; RGB: $708090; ARGB: $FF708090)
   , (Name: 'snow'                 ; RGB: $FFFAFA; ARGB: $FFFFFAFA)
   , (Name: 'springgreen'          ; RGB: $00FF7F; ARGB: $FF00FF7F)
   , (Name: 'steelblue'            ; RGB: $4682B4; ARGB: $FF4682B4)
   , (Name: 'tan'                  ; RGB: $D2B48C; ARGB: $FFD2B48C)
   , (Name: 'teal'                 ; RGB: $008080; ARGB: $FF008080)
   , (Name: 'thistle'              ; RGB: $D8BFD8; ARGB: $FFD8BFD8)
   , (Name: 'tomato'               ; RGB: $FD6347; ARGB: $FFFF6347)
   , (Name: 'transparent'          ; RGB: $000000; ARGB: $00000000)
   , (Name: 'turquoise'            ; RGB: $40E0D0; ARGB: $FF40E0D0)
   , (Name: 'violet'               ; RGB: $EE82EE; ARGB: $FFEE82EE)
   , (Name: 'wheat'                ; RGB: $F5DEB3; ARGB: $FFF5DEB3)
   , (Name: 'white'                ; RGB: $FFFFFF; ARGB: $FFFFFFFF)
   , (Name: 'whitesmoke'           ; RGB: $F5F5F5; ARGB: $FFF5F5F5)
   , (Name: 'yellow'               ; RGB: $FFFF00; ARGB: $FFFFFF00)
   , (Name: 'yellowgreen'          ; RGB: $9ACD32; ARGB: $FF9ACD32)
   , (Name: 'yellowmedium'         ; RGB: $FCD901; ARGB: $00FCD901)
   , (Name: 'yellowneon'           ; RGB: $F5FF12; ARGB: $00F5FF12)
   , (Name: 'yellowprimrose'       ; RGB: $F5FF12; ARGB: $00F5FF12)
  );
  public
    function  R(IvColor: TColor): byte; overload;
    function  G(IvColor: TColor): byte; overload;
    function  B(IvColor: TColor): byte; overload;
    function  R(IvHColor: string): byte; overload;
    function  G(IvHColor: string): byte; overload;
    function  B(IvHColor: string): byte; overload;
    function  H(IvColor: TColor): double; // hue
    function  S(IvColor: TColor): double; // saturation
    function  L(IvColor: TColor): double; // luminosity = luminance = brightness = 0.25*red + 0.625*green + 0.125*blue (simplified formula)
    function  ToColorRef(IvColor: TColor): TColorRef;
    procedure ToRGB(const IvColor: TColor; out R, G, B: byte);
    function  FromRGB(const R, G, B: byte): TColor;
    procedure ToHSL(const IvColor: TColor; out H, S, L: word);
    function  FromHSL(const H, S, L: word): TColor;
    function  ToHtml(IvColor: TColor): string;
    function  FromHtml(IvHColor: string; IvDefault: TColor = clNone): TColor;
    function  Invert(IvColor: TColor): TColor;
    function  Darken(IvColor: TColor; IvPercentage: integer): TColor;
    function  Lighten(IvColor: TColor; IvPercentage: integer): TColor;
    function  RGB2BGR(IvRGBColor: TColor): TColor;                                                // RGB -> BGR                   (swap R with B)
    function  BGR2RGB(IvBGRColor: TColor): TColor;                                                // BGR -> RGB                   (swap B with R)
    function  RgbToHls(IvRgb: TRGBTriple): THls;
    function  HlsToRgb(IvHls: THls): TRGBTriple;
    function  ToStr(IvColor: TColor): string;                                                     // to    clRed                  (turns a TColor to delphi colorname string)
    function  ToHexStr(IvColor: TColor): string;                                                  // to   '0000FF'                (turns a TColor to hex color string)
    function  ToHtmlHexStr(IvColor: TColor; IvPrefix: boolean = true): string;                    // to   '#FF0000'               (turns a TColor to HTML hex color string)
    function  ToHtmlNameStr(IvColor: TColor): string;                                             // to    orangered / '#CF07B9)' (turns a TColor to HTML name/hex color string)
    function  FromStr(IvString: string): TColor;                                                  // from  cl+delphicolorname     (turns a delphi color string to a delphi TColor)
    function  FromHexStr(IvHexString: string; IvDefault: string = '808080'): TColor;              // from '0000FF'                (turns an hex string to a delphi TColor)
    function  FromHtmlHexStr(IvHtmlHexString: string; IvDefault: string = '#808080'): TColor;     // from '#RRGGBB' or 'FF0000'   (turns an HTML hex string to a delphi TColor)
    function  FromHtmlHexOrNameStr(IvHtmlNameString: string; IvDefault: string = 'gray'): TColor; // from  red      or orangered  (turns an HTML hex/name string to a delphi TColor)
    function  Blend(IvColor1, IvColor2: TColor; IvBlendingLevel: Byte): TColor;                   // usage  NewColor:= Blend(Color1, Color2, blending level 0 to 100);
    function  GradeGray (IvGrade: byte): string;
    function  GradeRed  (IvGrade: byte): string;
    function  GradeGreen(IvGrade: byte): string;
    function  GradeBlue (IvGrade: byte): string;
    procedure WavelengthToRgb(const Wavelength: TNanometer; var R, G, B: byte); // Spectra - Copyright (C) 1998, Earl F. Glynn, Overland Park, KS. -  www.efg2.com/Lab // adapted from www.isc.tamu.edu/~astro/color.html
    procedure RainbowToRgb(const fraction: double; var R,G,B: byte); // return spectrum colors for range of 0.0 to 1.0
    function  Rainbow(IvMin, IvMax, IvIdx: double): string; overload;
    function  Rainbow(MinHue, MaxHue, Hue: integer): TColor; overload;
    function  Rainbow(Hue: double): TColor; overload;
    function  ColorRnd: TColor;
    function  ColorFineRnd(IvStart: byte = 127): TColor; // for red, green and blue byte, select $00, $33, $66, $99, $cc or $ff or rather: random(6) * $33 so the resulting 216 possible combinations will not look dark
    function  ColorNameRnd: string;
    function  ColorHtmlRnd: string;
    function  ColorAggRnd(IvStart: byte = 127; IvAlpha: string = '40'): string; // return rrggbbaa suitable for aggpas
    function  ColorHexRnd: string;
    function  ColorHexaRnd: string;
  end;

  TConRec = record // connection
  public
    function  ConnADOInit(var IvADOConnection: TADOConnection; IvCsADO: string; var IvFbk: string): boolean;
    function  ConnADOFree(var IvADOConnection: TADOConnection; var IvFbk: string): boolean;
    function  ConnFDInit (var IvFDConnection : TFDConnection ; IvCsFD : string; var IvFbk: string): boolean;
    function  ConnFDFree (var IvFDConnection : TFDConnection ; var IvFbk: string): boolean;
    procedure ConnPrivatePooledCreateInFDManagerInCode;
    procedure ConnPrivatePooledCreateInFDManagerFromIni;
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

  TCssRec = record // css
  public
    function  W3ThemeInit(IvHColor, IvName: string): string;
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
    constructor Create({IvCsADO: string = ''; }IvCsFD: string = ''); overload;
    constructor Create(IvFDManager: TFDCustomManager); overload;
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
  //function  DsFD (IvSql: string; var IvDs: TDataSet  ; var IvFbk: string; IvFailIfEmpty: boolean = false; IvTimeOutSec: integer = DBA_COMMAND_TIMEOUT_SEC): boolean; overload;
    // hierarchy
    function  HIdVecFromName      (const IvTbl, IvNameFld, IvName: string): TIntegerVector; // many id's are possible from one name
    function  HIdFromName         (const IvTbl, IvNameFld, IvName: string): integer; // only the 1st id found
    function  HIdFromPath         (const IvTbl, IvPathFld, IvPath: string; var IvId: integer; var IvFbk: string): boolean; overload;
    function  HIdFromPath         (const IvTbl, IvPathFld, IvPath: string): integer; overload;
    function  HIdFromIdOrPath     (const IvTbl, IvPathFld: string; IvIdOrPath: string; var IvId: integer; var IvFbk: string): boolean; overload;
    function  HIdFromIdOrPath     (const IvTbl, IvPathFld: string; IvIdOrPath: string): integer; overload;
    function  HIdToPath           (const IvTbl, IvPathFld: string; const IvId: integer; var IvPath: string; var IvFbk: string): boolean;
    function  HLevel              (const IvTbl: string; const IvId: integer; var IvLevel: integer; var IvFbk: string): boolean;
    function  HParentsItemChildsDs(const IvTbl, IvFldCsv: string; const IvId: integer; var IvDs: TFDDataSet; var IvFbk: string): boolean;
    function  HParentsDs          (const IvTbl, IvFldCsv: string; const IvId: integer; var IvDs: TFDDataSet; var IvFbk: string): boolean;
    function  HChildsDs           (const IvTbl, IvFldCsv: string; const IvId: integer; var IvDs: TFDDataSet; var IvFbk: string; IvWhere: string = ''; IvOrderBy: string = ''): boolean;
    function  HTreeDs             (const IvTbl, IvFld, IvFldCsv: string; const IvId: integer; var IvDs: TFDDataSet; var IvFbk: string; IvWhere: string = ''): boolean;
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

  TDstRec = record // dataset
  public
    procedure Filter(IvDs: TDataSet; IvFilter: string; IvFieldToSearchCsv: string; IvActive: boolean = true; IvAdditionalExplicitFilter: string = '');
    procedure FilterList(IvDs: TDataSet; IvFilter: string; IvFieldToSearchCsv, IvFieldToShowInList: string; IvStringList: TStrings);

    function  FieldCreate(IvDs: TDataSet; IvFieldType: TFieldType; const IvFld: string = ''; IvSize: integer = 0; IvDisplayWidth: integer = 255): TField; overload;
    function  DataSetFieldCreate(IvDs: TDataSet; const IvFld: string): TDataSetField; overload;

    function  FieldValueToJsonValue(IvField: TField): string; // Field.Value --> "Xxx", 123, null, {}
    function  FieldToJson(IvField: TField; IvNoFld: boolean = false): string; // Field.Value --> "FldXxx": "Xxx"
    procedure FieldFromJson(IvField: TField; IvValue: superobject.ISuperObject);
    procedure FieldsFromJsonFields(IvDs: TDataSet; IvSuperObject: superobject.ISuperObject);

    procedure RecordDeleteSoft(IvDs: TDataSet; IvFieldToRenameAvailable: string);
    procedure RecordToJson(IvDs: TDataSet; var IvSuperObject: superobject.ISuperObject; IvNoFld: boolean = false; IvRowNoAdd: boolean = false); overload;
    function  RecordToJson(IvDs: TDataSet; IvNoFld: boolean = false; IvRowNoAdd: boolean = false): string; overload;

    procedure ToTxt (IvDs: TDataSet; var IvTxt : string; IvNoFld: boolean = false; IvRowNoAdd: boolean = false; IvHeaderAdd: boolean = false);
    procedure ToCsv (IvDs: TDataSet; var IvCsv : string; IvNoFld: boolean = false; IvRowNoAdd: boolean = false; IvHeaderAdd: boolean = false);
    procedure ToHtml(IvDs: TDataSet; var IvHtml: string; IvNoFld: boolean = false; IvRowNoAdd: boolean = false; IvHeaderAdd: boolean = true );

    function  ToJson(IvDs: TDataSet; var IvJson: string; IvNoFld: boolean; IvRowNoAdd: boolean): integer;                    //  {"Fld1":"aa1","Fld2":"bb1",...},{"Fld1":"aa2","Fld2":"bb2",...}, ...
    procedure ToJsonVector(IvDs: TDataSet; var IvJson: string; IvNoFld: boolean = false; IvRowNoAdd: boolean = false);       // [{"Fld1":"aa1","Fld2":"bb1",...},{"Fld1":"aa2","Fld2":"bb2",...}, ...]
    procedure ToJsonTotalAndRows(IvDs: TDataSet; var IvJson: string; IvNoFld: boolean = false; IvRowNoAdd: boolean = false); // {"total":2,"rows":[{"Fld1":"aaa","Fld2":"bbb",...},{"Fld1":"aa2","Fld2":"bb2",...}, ...]}
    procedure ToJsonKeyValue(IvDs: TDataSet; var IvJson: string; IvNoFld: boolean = false);         // used in <select><option> {"key1":"aaa","key2":"bbb",...} only field[0] and field[1] are considered

    procedure FromJson(IvDs: TDataSet; IvSuperObject: superobject.ISuperObject); overload; // ds need to be available and active (open)
    procedure FromJson(IvDs: TDataSet; IvJson: string); overload;

    procedure AppendJson(IvDs: TDataSet; IvSuperObject: superobject.ISuperObject);
    procedure RecordToFldAndValueVectors(IvDs: TDataSet; var IvFldVec: TStringVector; var IvValueVec: TVariantVector; IvNoFld: boolean = true);
  end;

  TEdiRec = record // editinfo (table)
    Editable : boolean;
    Select   : string ;
    Insert   : string ;
    Update   : string ;
    Delete   : string ;
  //EditIni  : string ; // legacy edit info
    Json     : string ;
    // remove
  //ReportId         : integer; // report id ref
  //DatasetName      : string ; // the specific dataset(s?) in the report
  //InsertIfNotExists: boolean; // insert the record if it does not exists for update
  //Table            : string ; // table to change
  //KeyFieldList     : string ; // fields key, not changeable
  //OwnerField       : string ; // the person that can change
  //OneWayField      : string ; // not reversible toggle
  //OneWayRange      : string ; // toggle values
  //FieldList        : string ; // fields to change
  //ValueRange       : string ; // admitted values (actually for all fields!, should be separated lists one for each field to change)
  //UpdatedField     : string ; // updated field
  //EnabledStateList : string ; // will update records only in these states (Active, OnHold, ...
  public
    procedure LoadFrom(IvEditable: boolean; IvSelect, IvInsert, IvUpdate, IvDelete{, IvEditIni}, IvJson: string);
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

  THtmRec = record // htmlstuff *** TRANSFORM IN CLASS SO ADDING

    {$REGION 'Const'}
    {
  const
    HNBSP   = '&nbsp;';   // [ ]
    HMIDDOT = '&middot;'; // .
    HLT     = '&lt;';     // <
    HGT     = '&gt;';     // >
    HAMP    = '&amp;';    // &
    HQUOTE  = '&quot;';   // "
    }
    {$ENDREGION}

  public
    // attr
    function  AttrIdName(IvCo: string = ''): string;                                                                   // id="" name=""
    function  AttrClasse(IvClassVec: array of string): string;                                                         // class=""
    function  AttrStyle(IvValue: string): string;                                                                      // style=""
    function  AttrPlaceholder(IvValue: string): string;                                                                // placeholder=""
    // elements
    function  A(IvHref, IvText: string): string; overload;                                                             // <a href=""></a>
    function  A(IvHref, IvFormat: string; IvVec: array of TVarRec): string; overload;                                  //
    function  B(IvN: integer = 1): string;                                                                             // <br>
    function  C(IvComment: string): string;                                                                            // <!-- -->
    function  D(IvContent: string; IvClass: string = ''; IvComment: string = ''): string; overload;                    // <div></div>
    function  D(IvFormat: string; IvVec: array of TVarRec; IvClass: string = ''; IvComment: string = ''): string; overload; //
    function  H(IvLevel: integer; IvContent: string; IvClass: string = ''): string; overload;                               // <h1></h1>
    function  H(IvLevel: integer; IvFormat: string; IvVec: array of TVarRec; IvClass: string = ''): string; overload;       //
    function  P(IvContent: string; IvClass: string = ''): string; overload;                                            // <p></p>
    function  P(IvFormat: string; IvVec: array of TVarRec; IvClass: string = ''): string; overload;                    //
    function  Container(IvContent: string; IvClass: string = ''): string;                                              // <div class="container"></div>
    function  Panel    (IvContent: string; IvClass: string = ''): string;                                              // <div class="panel"></div>
    function  Accordion(IvContent: string; IvClass: string = ''): string;                                              //
    function  Table    (IvContent: string; IvClass: string = ''; IvStyle: string = ''; IvCo: string = ''; IvCaption: string = ''): string;   // <table></table>
    function  TableResp(IvContent: string; IvClass: string = ''; IvStyle: string = ''; IvCo: string = ''; IvCaption: string = ''): string;   // <div class="responsive"><table></table></div>
    function  Th       (IvContent: string; IvClass: string = ''): string;                                              // <th></th>
    function  Td       (IvContent: string; IvClass: string = ''): string;                                              // <td></td>
    function  Tr       (IvContent: string; IvClass: string = ''): string;                                              // <tr></tr>
    function  Tc       (IvContent: string; IvClass: string = ''): string; // tablecaption                              // <caption></caption>
    function  Fa(IvIcon: string; IvStyle: string = ''): string;                                                        // <i class="fa fa-sign-in"></i>
    // pageparts
    function  Head(IvTitle: string; IvHead: string = ''; IvCss: string = ''; IvJs: string = ''): string;               // <head></head>
    function  Navbar(IvContent: string): string;                                                       // <nav></nav>
    function  SidebarLeft(IvContent: string): string;                                                  // <div class="w3-sidebar w3-animate-left"></div>
    function  SidebarRight(IvContent: string): string;                                                 // <div class="w3-sidebar w3-animate-right"></div>
    function  Content( IvContent: string; IvContainerOn: boolean = true): string;                                       // <div class="container content"></div>
    function  Header(IvContent: string; IvDebug: string = ''): string;                                                 // <header></header>
    function  Footer(IvContent: string; IvDebug: string = ''): string;                                 // <footer></footer>
    function  BottomFixed(): string;                                                                                   // go top arrow
    function  BootScript(): string;                                                                                      // <script></script>
    // pages
    function  Page(IvTitle, IvContent: string; IvHead: string = ''; IvCss: string = ''; IvJs: string = ''; IvHeader: string = ''; IvFooter: string = ''; IvContainerOn: boolean = true; IvBuilder: integer = 0): string; // <html></html>
    function  PageBlank(IvTitle, IvContent: string): string;                                               // <html></html>
    function  PageI(IvTitle: string; IvText: string = ''; IvBuilder: integer = 0): string;             // <html>info</html>
    function  PageW(IvTitle: string; IvText: string = ''; IvBuilder: integer = 0): string;             // <html>warning</html>
    function  PageE(IvTitle: string; IvText: string = ''; IvBuilder: integer = 0): string;             // <html>exception</html>
    function  PageNotFound(IvBuilder: integer = 0): string;                                        // <html>not found</html>
    // gui
    // alerts
    function  Alert    (IvTitle: string; IvText: string = ''; IvClass: string = ''): string;                           //
    function  AlertI   (IvTitle: string; IvText: string = ''): string;                                                 //
    function  AlertS   (IvTitle: string; IvText: string = ''): string;                                                 //
    function  AlertW   (IvTitle: string; IvText: string = ''): string;                                                 //
    function  AlertD   (IvTitle: string; IvText: string = ''): string;                                                 //
    function  AlertE   (IvTitle: string; IvText: string = ''): string;                                                 //
    // buttons
    function  BtnHome(IvCaption: string = ''; IvClass: string = ''; IvStyle: string = ''): string;                     //
    function  BtnBack(IvCaption: string = ''; IvClass: string = ''; IvStyle: string = ''): string;                     //
    function  BtnXHome(IvClass: string = ''; IvStyle: string = ''): string;                                            // close panel and go home
    function  BtnXHide(IvCo: string; IvClass: string = ''; IvStyle: string = ''): string;                              // close panel only
    // gui
    function  {Gui}SpaceV(IvPx: integer = 32): string;                                                                      // <div style="height:32px"></div>
    function  {Gui}SpaceH(IvSpaces: integer = 3): string;                                                                   // ' &nbsp; '
    function  {Gui}Row(IvCellVec, IvClassVec, IvStyleVec: TStringVector): string;
    // table
    function  TableArr(IvArr: TStringMatrix; IvClass: string = ''; IvStyle: string = ''; IvCo: string = ''; IvCaption: string = ''; Iv1stRowIsHeader: boolean = true): string;             //
    function  TableDs (IvDs : TFDDataset   ; IvClass: string = ''; IvStyle: string = ''; IvCo: string = ''; IvCaption: string = ''): string;                                               //
    function  TableSql(IvSql: string       ; IvClass: string = ''; IvStyle: string = ''; IvCo: string = ''; IvCaption: string = ''; IvTimeOut: integer = DBA_COMMAND_TIMEOUT_SEC): string; // IvSkip, IvLimit: integer
    function  TableWre: string;                                                                                         // <table>wre</table>
    // form
    function  Form(IvCoVec, IvKindVec, IvValueVec: array of string; IvClass, IvAction, IvMethod: string): string;       // <form></form>
    function  Labl(IvContent: string; IvClass: string = ''): string;                                                    // <label></label>
    function  Input(IvCo, IvKind, IvLabel, IvValue: string; IvPlaceholder: string = ''; IvClass: string = ''; IvStyle: string = ''; IvUseLayout: boolean = true): string; // <input></input>
    // modals
    function  ModMessage(IvTitle: string; IvText: string = ''; IvClass: string = ''): string;                           // generic
    function  ModUserAccountCreate: string;                                                                             //
    function  ModUserAccountCreateDone: string;                                                                         // reply to the above
    function  ModUserAccountRecover: string;                                                                            //
    function  ModUserAccountRecoverDone: string;                                                                        // reply to the above
    function  ModUserLogin: string;                                                                                     //
    // spans-widgets
    function  SpanCode(IvCode: string): string;                                                                         //
    // divs-widgets
    function  DivTiming(IvMs: integer): string;                                                                         // <p>rendering time</p>
    function  DivPathInfoActions(IvWm: TWebModule; IvWre: TWebRequest): string;                                         // all webapp available actions
    function  DivNews(IvLastHour: integer = 24): string;                                                                //
    function  DivUserProfile(IvUser, IvUserId: string): string;                                                         //
    function  DivUserInterest(IvUser, IvUserId: string): string;                                                        //
    function  DivUserNotification(IvNotification: string): string;                                                      //
    function  DivUserBlog(IvLastHour: integer = 24): string;                                                            //
    function  DivUserUpcomingEvent(IvUser: string): string;                                                             //
    function  DivUserFrienRequest(IvUser: string): string;                                                              //
    function  DivUserAds(IvUser: string): string;                                                                       //
    function  DivUserBug(IvUser: string): string;                                                                       //
    function  DivUserMore(IvUser: string): string;                                                                      //
    // chart
    function  Chart   (IvCo, IvW, IvH, IvTitle, IvData: string): string;                                                                                              //
    function  ChartDs (IvCo, IvW, IvH, IvTitle: string; IvDs : TFDDataset; IvXFld, IvYFld, IvTooltipFld: string): string;                                               //
    function  ChartSql(IvCo, IvW, IvH, IvTitle: string; IvSql: string    ; IvXFld, IvYFld, IvTooltipFld: string; IvTimeOut: integer = DBA_COMMAND_TIMEOUT_SEC): string; //
    // report
    function  Report(IvId: integer): string;                                                                            // fullreport
    // test
    function  TestTheme: string;                                                                                        //
    function  TestTable(IvRow, IvCol: cardinal): string;                                                                // big nxm html table string for loading test
    function  TestForm: string;                                                                                         // a sample form with all kind of inputs
    function  TestChart(IvN: cardinal = 100): string;                                                                   //
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
  public
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

  TIsaRec = record // isapi, companion with TSoaRec
  const
    ISAPI_URL       = 'http://%s';                                                            // %s=website:port (localhost, www.wks.cloud)
    ISAPI_DLL_URL   =          '/Wks%sIsapiProject.dll';                                      // %1=Xxx
  public
    function  IsapiUrl(IvObj: string = 'System'): string;
  end;

  TLgoRec = record // logo
  public
    function  InvSpec(IvOrganization: string = ''): string;
    function  InvUrl(IvOrganization: string = ''): string;
    function  Spec(IvOrganization: string = ''): string;
    function  Url(IvOrganization: string = ''): string;
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

  TMbrRec = record // member
  public
    State        : string; // Active
    Member       : string; // giarussi
    Organization : string; // Wks
    Role         : string; // Administrator, Member, Guest
    Level        : string; // Low, Normal, High
    Email        : string; // giarussi@engitech.it
    Phone        : string; // 348/5904744
    Authorization: string; // jsonblock
    function  Info: string;
    function  DbaSelect(var IvFbk: string): boolean;
    function  RioInit(IvMember, IvOrganization: string; var IvFbk: string): boolean;
    function  IsGuest: boolean;
    function  IsMember: boolean;
    function  IsSupervisor: boolean;
    function  IsManager: boolean;
    function  IsAdmin: boolean;
    function  IsAdminHigh: boolean;
    function  IsWksAdmin: boolean;
    function  IsOwner: boolean; // organization-site owner
    function  IsAuthorized(IvResource: string; var IvFbk: string): boolean;
    function  CanInsert(IvResource: string): boolean;
    function  CanDelete(IvResource: string): boolean;
    function  CanEdit(IvResource: string): boolean;
    function  CanView(IvResource: string): boolean;
    function  Grade: integer; // 00..42 depending on role/level values
    function  MemberAtOrganization: string;
    function  PathAlpha(IvMember: string = ''): string;
    function  UrlAlpha(IvMember: string = ''): string;
    function  BadgePath(IvMember: string = ''): string;
    function  BadgeUrl(IvMember: string = ''): string;
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

  TNamRec = record // name

    {$REGION 'Help'}
    {
      naming conventions
      --------------------------
      pascal:   GiovanniIarussi
      camel:    giovanniIarussi
      snake:    giovanni_iarussi
      const:    GIOVANNI_IARUSSI
    }
    {$ENDREGION}

  public
    function  Rnd(IvLenght: integer = 4): string;
    function  RndCsv(IvListLenght: integer; IvNameLenght: integer = 4): string;
    function  RndPrefix(IvPrefix: string = ''; IvLenght: integer = 4): string;
    function  RndPostfix(IvPostfix: string = ''; IvLenght: integer = 4): string;
    function  Std(IvName: string = ''; IvPostfix: string = ''): string;
    function  Co(IvName: string = ''): string;
    function  CoRemove(IvName: string): string;
    function  CoRnd(IvPrefix: string = ''; IvLenght: integer = 4): string;
    function  HasNum(IvName: string): boolean;           // Dog7 --> true, Dog --> false
    function  IsNumOf(IvName, IvBase: string): boolean;  // Dog7; Dog --> true , Dog7;
    function  NumBasePart(IvName: string): string;       // Dog7 --> Dog
    function  NumCodePart(IvName: string): string;       // Dog7 --> 7
    function  NumPrev(IvName: string): string;           // Dog7 --> Dog6, Dog2 --> Dog , Dog1 --> Dog , Dog --> Dog
    function  NumNext(IvName: string): string;           // Dog7 --> Dog8, Dog1 --> Dog2, Dog  --> Dog2, ...
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

  TOpsRec = record // operatingsystem
    function ProcessIdGet: cardinal; register;
    function ThreadIdGet: cardinal; register;
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

  TPerRec = record // person
  public
    Id     : integer; // id
    PId    : integer; // pid
    Person : string ; // giarussi
    Name   : string ; // Giovanni
    Surname: string ; // Iarussi
    Email  : string ; // giarussi@yahoo.com
    function  SoapServerInfo(var IvFbk: string): boolean;
    function  HasKey(var IvFbk: string): boolean;
    function  DbaSelect(var IvFbk: string; IvInsertIfNotExist: boolean = false): boolean;
    function  FullName: string;
    function  PathAlpha(IvPerson: string = ''): string;
    function  UrlAlpha(IvPerson: string = ''): string;
    function  PicturePath(IvPerson: string = ''): string;
    function  PictureUrl(IvPerson: string = ''): string;
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

  TPwdRec = record // password
  const
    PWD_MIN_LEN = 6;
  public
    function  Generate(IvLength: integer = 8; IvUseLower: boolean = true; IvUseUpper: boolean = false; IvUseNumber: boolean = false; IvUseWierd: boolean = false): string;
    function  GenerateWord(IvLanguage: string; var IvPassword: string; var IvFbk: string): boolean; // generate a language work for better remeber !!!
    function  IsSecure(IvPassword: string; var IvFbk: string): boolean;
    function  StrongScore(IvPassword: string; var IvFbk: string): integer;
    function  Encode(IvPassword: string): string;
    function  Decode(IvPassword: string): string;
    // dba
    function  DbaMatch(IvOrganization, IvUsername, IvPassword: string; var IvFbk: string): boolean;
    function  DbaChange(IvOrganization, IvUsername, IvPasswordOld, IvPasswordNew: string; var IvFbk: string): boolean;
    // rio
    function  RioChange(IvOrganization, IvUsername, IvPasswordOld, IvPasswordNew: string; var IvFbk: string): boolean;
    function  RioRecover(IvOrganization, IvUsername: string; var IvFbk: string): boolean;
    function  RioReset(IvOrganization, IvUsername: string; var IvFbk: string): boolean;
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

  TRolRec = record // role/level

    {$REGION 'Help'}
    (*
      15 grades = role/levels
      ------------------------------------------------------
                           |    0     |    1     |    2     |
                            --------------------------------
                           |    Low   |  Normal  |   High   | \
                            --------------------------------   | levels
            role           |  Junior  |  Normal  |  Senior  | /
       --- -------------------------------------------------
      | 6 | System         |               90               | \
       --- -------------------------------------------------   |
      | 5 | Architech      |               50               |  |
       --- -------------------------------------------------   |
      | 4 | Administrator  |    40    |    41    |    42    |  |
       --- -------------------------------------------------   |
      | 3 | Manager        |    30    |    31    |    32    |  | grades
       --- -------------------------------------------------   |
      | 2 | Supervisor     |    20    |    21    |    22    |  |
       --- -------------------------------------------------   |
      | 1 | Member/User    |    11    |    11    |    12    |  |
       --- -------------------------------------------------   |
      | 0 | Guest          |               00               | /
       --- -------------------------------------------------
    *)
    {$ENDREGION}

  const

    {$REGION 'Const'}
    // roles
    ROLE_SYSTEM                = 'System'       ; { 9}
    ROLE_ARCHITECT             = 'Architect    '; { 5}
    ROLE_ADMINISTRATOR         = 'Administrator'; { 4}
    ROLE_MANAGER               = 'Manager'      ; { 3}
    ROLE_SUPERVISOR            = 'Supervisor'   ; { 2}
    ROLE_MEMBER                = 'Member'       ; { 1}
    ROLE_GUEST                 = 'Guest'        ; { 0}

    // level
    LEVEL_SYSTEM               = 'System'       ; { 9}
    LEVEL_HIGH                 = 'High'         ; { 2} // senior
    LEVEL_NORMAL               = 'Normal'       ; { 1} //
    LEVEL_LOW                  = 'Low'          ; { 0} // junior

    // grades
    GRADE_GUEST                = 00;
    GRADE_MEMBER_LOW           = 10;
    GRADE_MEMBER_NORMAL        = 11;
    GRADE_MEMBER_HIGH          = 12;
    GRADE_SUPERVISOR_LOW       = 20;
    GRADE_SUPERVISOR_NORMAL    = 21;
    GRADE_SUPERVISOR_HIGH      = 22;
    GRADE_MANAGER_LOW          = 30;
    GRADE_MANAGER_NORMAL       = 31;
    GRADE_MANAGER_HIGH         = 32;
    GRADE_ADMINISTRATOR_LOW    = 40;
    GRADE_ADMINISTRATOR_NORMAL = 41;
    GRADE_ADMINISTRATOR_HIGH   = 42;
    GRADE_ARCHITECT            = 50;
    GRADE_SYSTEM               = 90;
    GRADE_VECTOR: array[0..14] of string = (
      '00 Guest'               // guest
    , '11 MemberLow'           // member
    , '12 MemberNormal'
    , '13 MemberHigh'
    , '20 SupervisorLow'       // supervisor
    , '21 SupervisorNormal'
    , '22 SupervisorHigh'
    , '30 ManagerLow'          // manager
    , '31 ManagerNormal'
    , '32 ManagerHigh'
    , '40 AdministratorLow'    // administrator
    , '41 AdministratorNormal'
    , '42 AdministratorHigh'
    , '50 Architect'           // architect
    , '90 System'              // system
    );
    {$ENDREGION}

  end;

  TRvaRec = record

    {$REGION 'Help'}
    {
         __ Rv
        /
    [RvXxx(Arg0| Arg1| Arg2)]
           ¯¯¯¯¯¯¯\¯¯¯¯¯¯¯¯
                   \__ Args list

    Variable/Placeholder/TagsReplacement

    NOTE: if args list is empty parentesis are still necessary, like this: RvXxx()
    NOTE: consider changing [RvFoo()] to [=Foo()]
    }
    {$ENDREGION}

    {$REGION 'Const'}
    {
  const
    RV_RECURSION_MAX = 99;
    }
    {$ENDREGION}

  private
  //Rv: string; // RvXxx(Arg0| Arg1| Arg2)
  //function  ArgVector: TStringVector; // will return ['Arg0', 'Arg1', 'Arg2']
    function  RvFunction (IvFunction, IvArgsList: string): string;
    function  RvFunction2(f, a: TStringVector): string;
  public
    function  Rv2(IvString: string; IvCommentRemove: boolean = false; IvEmptyLinesRemove: boolean = true; IvTrim: boolean = true): string; // [RvAaa(Arg0| Arg1| Arg2)]
    function  Rv (IvString: string; IvCommentRemove: boolean = false): string; //
    function  RvJ(IvString, IvJsonStr: string; IvReplaceFlag: TReplaceFlags = []): string;    // recursively replace all [Rv<json.path>()] with SO(IvJsonStr)['json.path'].Value // $Aaa.Bbb$ -> 123      where IvJsonStr = {"Aaa": {"Bbb": 123}, ...}
    function  RvDs(IvString: string; IvDs: TDataset): string;                                 // $FldAaa$  -> 123      where IvDs      = FldAaa=123, ...
  end;

  TSbuRec = record // stringbuilder
    Text: string;
  public
    procedure Clear;                                                                                             // clear all
    procedure Emp(IvNl: integer = 1);                                                                            // add empty line

    procedure Ann(IvString: string);                                                                             // add without prepend new line
    procedure Add(IvString: string; IvNlPrefix: integer = 1);                                                    // add with a newline after with optional one before
    procedure Aif(IvString: string; IvTest: boolean; IvNlPrefix: integer = 1);                                   // add if test is true
    procedure AiX(IvString: string; IvNlPrefix: integer = 1);                                                    // add if string exists
    procedure AiE(IvString: string; IvDefault: string; IvNlPrefix: integer = 1);                                 // add default if string is empty
    procedure AXr(IvString: string; IvReturn: string; IvNlPrefix: integer = 1);                                  // add return if string exists
  //procedure AdS(IvString: string; IvNlPrefix: integer = 1);                                                    // add success
  //procedure AdW(IvString: string; IvNlPrefix: integer = 1);                                                    // add warning
  //procedure AdE(IvE: Exception;   IvNlPrefix: integer = 1);                                                    // add exception
    procedure ATg(IvString: string; IvTag: string);                                                              // add inside html <tag></tag> if string exists

    procedure Fmt(IvFormat: string; IvVarRecVector: array of TVarRec; IvNlPrefix: integer = 1);                  // add format
    procedure Fif(IvFormat: string; IvVarRecVector: array of TVarRec; IvTest: boolean; IvNlPrefix: integer = 1); // add format if test is true
    procedure Fie(IvFormat: string; IvVarRecVector: array of TVarRec; IvTest: string ; IvNlPrefix: integer = 1); // add format if test exists
    procedure FiX(IvFormat,            IvIfExist: string; IvNlPrefix: integer = 1);                              // add format if exists
    procedure FiY(IvFormat, IvFormat2, IvIfExist: string; IvNlPrefix: integer = 1);                              // add format if exists

    procedure Rep(IvString, IvOut, IvIn: string; IvNlPrefix: integer = 1);                                       // add replacing
    procedure Iif(IvTest: boolean; IvTrueVal, IvFalseVal: string; IvNlPrefix: integer = 1);                      // add s1 or s2
    procedure Swi(IvSwitchList, IvSwitch, IvString: string; IvNlPrefix: integer = 1);                            // add if switch
  //procedure IXr();
  //procedure IfT();
  //procedure IfF();
  end;

  TSesRec = record // session
  public
    Session      : string;
    BeginDateTime: TDateTime;
    HasBeenOpen  : boolean;
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

  TSobRec = record // superobject
  public
    function  ObjectInfo(const IvAsObject: superobject.TSuperTableString; var IvFbk: TFbkRec; const IvPrefix: string = ''): string;
    function  SuperTypeToFieldType(IvSuperType: superobject.TSuperType): TFieldType;
    function  SuperTypeToFieldSize(IvSuperType: superobject.TSuperType): integer;
    function  Pretty(IvString: WideString): string;
    function  FromFileUTF8(const IvFileName: string): superobject.ISuperObject; // delphi speaks UTF16!
    procedure ToFileUTF8(const aFileName: string; o: superobject.ISuperObject); // idem
    function  StrEscape(const IvString: string): string;
    function  StrUnescape(const IvString: AnsiString): string;
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
    function  SoapUrl(IvObj: string = 'System'): string;
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
    function  W(IvE: Exception): string;                                                                        // standardwarning
    function  E(IvE: Exception): string;                                                                        // standardexception (e.Message)
    function  E2(IvE: Exception): string;                                                                       // standardexception (e.ClassName and e.Message)
    function  Between(IvTagLeft, IvTagRight, IvString: string): string;                                         // or Inside s1 = '[', s2 = ']', s3 = 'abc[xxx]def' -> 'xxx'
    function  Bite(IvString, IvDelimiter: string; var IvPos: integer): string;                                  // return front token based on token delim, each call returns front token and adjusts IvPos to the start of the next token or 0 if this is the last token
    function  CamelToVec(IvString: string): TStringVector;                                                      // ThisIsATest    --> ['This', 'Is', 'A', 'Test']
    function  CharShift(const IvString: string; IvShift: integer = 1): string;                                  // shift each char -/+
    function  Coalesce(IvStringVector: TStringVector): string;                                                  // return 1st not empty string
    function  Collapse(const IvString: string): string;                                                         // 'This Is A Test' --> 'ThisIsATest'
    function  CommentRemove(IvString: string): string;                                                          // remove all types of comments
    function  EmptyLinesRemove(IvString: string): string;                                                       // remove all emtpy lines
    function  Expande(const IvString: string; IvDelimiterChar: string = ' '): string;                           // 'ThisIsATest' --> 'This Is A Test' but 'This_IsA_Test' --> 'ThisIs ATest'
    function  Has(IvString, IvSubString: string; IvCaseSensitive: boolean = false): boolean;                    // contains
    function  HasRex(IvString, IvRex: string; IvOpt: TRegExOptions = [roIgnoreCase, roMultiLine]): boolean;     // containsrex
    function  HasWildcard(IvString, IvStrWithWildcard: string): boolean;                                        // abc*def
    function  HeadAdd(IvString, IvHead: string): string;                                                        //
    function  HeadRemove(IvString, IvHead: string): string;                                                     //
    function  Is09(const IvString: string): boolean;                                                            //
    function  IsInteger(const IvString: string): boolean;                                                       //
    function  IsFloat(const IvString: string): boolean;                                                         //
    function  IsNumeric(const IvString: string): boolean;                                                       //
    function  IsPath(const IvString: string): boolean;                                                          // /Root/Organization or Root/Organization with / \ .
    function  Left(IvString: string; IvCount: integer): string;                                                 //
    function  LeftOf(IvTag, IvString: string; IvTagInclude: boolean = false): string;                           //
    function  LeftCut(s: string; i: integer): string;                                                           // return the string without first i chars
    function  Right(IvString: string; IvCount: integer): string;                                                //
    function  RightOf(IvTag, IvString: string; IvTagInclude: boolean = false; IvLast: boolean = false): string; // normally use the 1st tag in the string
    function  RightCut(s: string; i: integer): string;                                                          // return the string without last i chars
    function  Match(IvSubString, IvString: string; IvCharMinToMatch: integer = -1): boolean;                    // abc Abcdef, -1 = match all ivsubstring, case insensitive
    function  OneLine(IvString: string): string;                                                                // replace cr+nl with nothing
    function  OneSpace(IvString: string): string;                                                               //
    function  Pad(IvString, IvFillChar: string; IvStringLen: integer; IvStrLeftJustify: boolean): string;       // pads a string and justifies left if IvStrLeftJustify = true
    function  Quote(const IvString: string): string;                                                            // 'abc'
    function  QuoteDbl(const IvString: string): string;                                                         // "abc"
    function  PartN(IvString: string; IvNZeroBased: integer; IvDelimiter: string = '_'): string;                // parser, pick up a id-th substring, 1 based
    function  PosAfter(IvSubString, IvString: string; IvStart: integer = 1): integer;                           //
    function  PosOfNth{Occurrence}(IvSubString, IvString: string; IvNth: integer): integer;                     // 0|1 based ?
    function  PosLast{Occurrence}(IvSubString, IvString: string): integer;                                      // 0 based !
    function  Proper(IvString: string): string;                                                                 //
    function  Remove(IvString, IvOut: string): string;                                                          //
    function  Replace(IvString, IvOut, IvIn: string): string;                                                   //
    function  Reverse(IvString: string): string;                                                                //
    function  Split(IvString: string; IvDelimiters: string = ','): TStringDynArray;                             //
    function  TailAdd(IvString, IvTail: string): string;                                                        //
    function  TailRemove(IvString, IvTail: string): string;                                                     //
    function  ToBool(IvString: string; IvDefault: boolean = false): boolean;                                    //
    function  ZeroLeadingAdd(IvString: string; IvLen: integer): string;                                         //
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
    function  Slogan()     : string;                                            // *** remove, it is for orga ***
    function  Support()    : string;
    function  HomePath()   : string;
    function  IncPath()    : string;
    function  LogoUrl()    : string;
    function  IconUrl()    : string;
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

  TUagRec = record // useragent
  public
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

  TVstRec = record // virtualstringtree
  const
    ROOT_ID         =   1;
    ZZZ_ID          =   2;
    SYSTEM_ID       =   3;
    TEST_ID         =   4;
    TEMPLATE_ID     =   5;
    ORGANIZATION_ID =   6;
    PEOPLE_ID       =   7;
    PUBLIC_ID       =   8;
    HELP_ID         =   9;
    NEW_ID          =  10;
    ERROR_ID        =  11; // !!! exception
    RESERVED_ID     =  99;
    SYS_LAST_ID     = 100; // last system id
    FREE_1ST_ID     = 101;
  public
    procedure OnPaintText(   IvVst: TBaseVirtualTree  ; const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
    procedure OnCompareNodes(IvVst: TBaseVirtualTree  ; Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: integer);
//    procedure GetImageIndex( IvVst: TBaseVirtualTree  ; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: TImageIndex);
    procedure GetNodeInfo(   IvVst: TBaseVirtualTree  ; Node: PVirtualNode; var IvPath, IvCaption: string; var IvKey, IvLevel, IvChildCount: integer);
    function  GetNodePath(   IvVst: TBaseVirtualTree  ; IvNode: PVirtualNode; IvDelimiter: char = '/'; IvUseLevels: boolean = false): string;
    procedure NodeParamSet(  IvVst: TVirtualStringTree; IvNode: PVirtualNode; IvDs: TDataSet);
  end;

  TWreRec = record // webrequestextended
  public
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
    procedure Init(IvWebRequest: TWebRequest);
    function  DbaInsert(var IvFbk: string): boolean;
    function  DbaSelectInput(var IvTable, IvField, IvWhere, IvFbk: string): boolean;
    function  DbaUpdateInput(var IvTable, IvField, IvWhere, IvValue, IvFbk: string): boolean;
    function  TkvVec: TTkvVec;
    function  StrGet(IvField: string; IvDefault: string; IvCookieAlso: boolean = false): string;
    function  IntGet(IvField: string; IvDefault: integer; IvCookieAlso: boolean = false): integer;
    function  BoolGet(IvField: string; IvDefault: boolean; IvCookieAlso: boolean = false): boolean;
    function  CookieGet(IvCookie: string; IvDefault: string ): string; overload;
    function  CookieGet(IvCookie: string; IvDefault: integer): integer; overload;
    function  CookieGet(IvCookie: string; IvDefault: boolean): boolean; overload; // get a cookie from client browser
    function  FieldExists(IvField: string; var IvFbk: string): boolean;
    function  Field(IvField: string; var IvValue: boolean; IvDefault: boolean; var IvFbk: string; IvFalseIfValueIsEmpty: boolean = true): boolean; overload;
    function  Field(IvField: string; var IvValue: integer; IvDefault: integer; var IvFbk: string; IvFalseIfValueIsEmpty: boolean = true): boolean; overload;
    function  Field(IvField: string; var IvValue: string ; IvDefault: string ; var IvFbk: string; IvFalseIfValueIsEmpty: boolean = true): boolean; overload;
    function  PathInfoActionIsValid(IvPathInfoAction: string): boolean; // verify if input is one of the defined action pathinfo /Xxx
    function  PathInfoQuery: string;    // /Page?CoId=3
    function  PathInfoQueryUrl: string; // /WksIsapiProject.dll/Page?CoId=3
    function  UrlFull: string;          // http://www.abc.com/WksIsapiProject.dll/Page?CoId=3
  end;

  TWapRec = record // webapp
    WebModule: TWebModule;
  public
    procedure Reply(var IvWebResponse: TWebResponse; IvStateCode: integer; IvStateMessage: string; IvDebug: string = '');
    function PathInfoActionIsValid(IvPathInfo: string): boolean;
  end;

  TWrsRec = record // webresponse (pov=server)
    WebResponse: TWebResponse; // original web response
  public
    procedure CookieSet(IvCookie: string; IvValue: variant; IvExpireInXDay: double = WEB_COOKIE_EXPIRE_IN_DAY; IvDomain: string = ''; IvPath: string = '/'); // set a cookie in client browser
    procedure CookieDelete(IvCookie: string; IvDomain: string = ''; IvPath: string = '/');
  end;
{$ENDREGION}

{$REGION 'Globals'}
// *** WARNING ***
// in multithread application these variable are safe
// to read but must be accessed in safe mode in write
// ***************
var
  h00: cardinal;   // handlespare
  all: TAllRec;    // all
  ask: TAskRec;    // ask, win-api-only-dialogs
  bol: TBolRec;    // boolean
  byn: TBynRec;    // binary
  cns: TCnsRec;    // connectionstring
  cod: TCodRec;    // code
  col: TColRec;    // color
  con: TConRec;    // connectiondb
  cry: TCryRec;    // cripto
  css: TCssRec;    // css
  dat: TDatRec;    // datetime
//db0: TDbaCls;    // sysdb, wksdb (mssql) *** NOT GLOBAL ***
  dot: TDotRec;    // dotobject (like Person.Person.Name <-> DbaPerson.dbo.TblPerson+FldName)
  dst: TDstRec;    // dataset
  edi: TEdiRec;    // editinfo (table)
  fbk: TFbkRec;    // feedback
  fsy: TFsyRec;    // filesystem
  iif: TIifRec;    // inlineif
//ini: TIniCls;    // ini *** NOT GLOBAL ***
  htm: THtmRec;    // html
  htt: THttRec;    // http
  iis: TIisRec;    // inlineis
  img: TImgRec;    // image
  isa: TIsaRec;    // isapi
  lmx: TCriticalSection; // log mutex (critical setcion to protect single log file writing) (TRTLCriticalSection)
//log: TLogCls;    // log *** NOT GLOBAL ***
//lgt: TLgtCls;    // log threaded *** NOT GLOBAL ***
  lgo: TLgoRec;    // logo
  lst: TLstRec;    // list/csv (csv or generic list like aaa/bbb/ccc or aaa|bbb|ccc)
  mat: TMatRec;    // math
  mbr: TMbrRec;    // member
  mes: TMesRec;    // message, dialog, taskdialog *** MOVE "dialog, taskdialog" IN "ask" ***
  mim: TMimRec;    // mimetype
  nam: TNamRec;    // name
  net: TNetRec;    // network
  obj: TObjRec;    // object content, param, switch, ... (System, User, Member, Organization, ...)
  org: TOrgRec;    // organization
  pat: TPatRec;    // pathfile (or more general treepath)
  per: TPerRec;    // person
  pop: TPopRec;    // pop3
  pxy: TPxyRec;    // proxy
  pwd: TPwdRec;    // password
  rex: TRexRec;    // regex
  rio: TRioRec;    // httprio
  rnd: TRndRec;    // random
  rol: TRolRec;    // role/level
  rva: TRvaRec;    // replacevariable
  sbu: TSbuRec;    // stringbuilder
  ses: TSesRec;    // session
  smt: TSmtRec;    // smtp
  sob: TSobRec;    // jsonsuperobject
  sop: TSopRec;    // soap
  sql: TSqlRec;    // sql
  srv: TSrvRec;    // server (isapi,soap,rest)
  sta: TStaRec;    // state
  stm: TStmRec;    // stream
  str: TStrRec;    // string
  sys: TSysRec;    // system (wks)
  uag: TUagRec;    // useragent
  url: TUrlRec;    // url
  usr: TUsrRec;    // user
  vec: TVecRec;    // vector
  vnt: TVntRec;    // variant
  vst: TVstRec;    // virtualstringtree
  wa0: TStopwatch; // stopwatch (only global lifetime, do not use locally in multithread applications!)
  wap: TWapRec;    // webapp (webmodule, webbroker)
  wre: TWreRec;    // webrequest (extended)
  wrs: TWrsRec;    // webresponse
{$ENDREGION}

{$REGION 'Routines'}
procedure ods(IvTag: string; IvText: string = '');
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
  , Vcl.Controls                    // crhourglass
  , Vcl.GraphUtil                   // ColorHLSToRGB, ColorRGBToHS
//, Vcl.StdActns                    // tbrowseforfolder
  , IdURI                           // tiduri
  , HTTPSend                        // araratsynapse
//, WksSystemSoapMainServiceIntf
  ;
{$ENDREGION}

{$REGION 'Routines'}
procedure ods(IvTag, IvText: string);
//var
//  f, e: string; // filename, entry
//  w: TStreamWriter;
begin
//  if IsDebuggerPresent {or not Assigned(lmx)} then begin
//    e := byn.Name + ' : ' + IvTag + ' : ' + IvText;
//    OutputDebugString(PWideChar(e));

    // globalLog.Add(s);
//    if Assigned(lmx) then begin
//      f := ChangeFileExt(byn.FileSpec, '_' + FormatDateTime('yyyy-mm', Now) + '.log');
//      e:= Format('%s|%5d:%5d|%-32s|%s', [FormatDateTime('dd hh:nn:ss zzz', Now), GetCurrentProcessID, GetCurrentThreadID, IvTag, IvText]);
//      lmx.Enter;
//      w := TStreamWriter.Create(f, true, TEncoding.UTF8);
//      try
//        w.WriteLine(e);
//      finally
//        w.Free;
//        lmx.Leave;
//      end;
//    end;
//  end;
end;
{$ENDREGION}

{$REGION 'TAllRec'}
function TAllRec.RecordDbaInit(IvOrganization, IvUsername: string; var IvFbk: string): boolean;
begin
  // sys (refresh some info since the record is initialized once at beginning using sys.DbaInit(), not for each request)
  //sys.HLib := obj.DbaParamGet('System', '113', 'W3');

  // what to do?
//Result := iis.Ex(usr.Username) and iis.Ex(usr.Password);
  // user
  usr.Organization := IvOrganization; // at 1st request user is not know, only the organization is know
  usr.Username     := IvUsername;     // also these info are empty until user has been
//usr.Password     := wre.Password;   // successfully logged-in with authentication
//Result := usr.DbaSelect(wre.Username, IvFbk);

  // session       WARNING: a session should be created when the user supply username+password, so during a successful login
//Result := ses.DbaNewAndSet(usr.Organization, usr.Username, usr.Password, IvFbk);

  // organization
  Result := org.DbaSelect(IvOrganization, IvFbk);

  // smtp
  smt.Organization  := IvOrganization; // smtp is ok since 1st request because it is tied to organization
  Result := smt.DbaSelect(IvFbk);

  // pop3
  pop.Organization  := IvOrganization; // pop3 is ok since 1st request because it is tied to organization
  Result := pop.DbaSelect(IvFbk);

  // member
  mbr.Organization  := IvOrganization; // also member is not know at 1st request
  mbr.Member        := IvUsername;
  //Result := mbr.DbaSelect(IvFbk);

  // fbklog
  IvFbk := 'All records sys, usr, ses, org, smt, pop, mbr initialized from database';
end;

function TAllRec.RecordRioInit(IvOrganization, IvUsername: string; var IvFbk: string): boolean;
begin
  // move here all stuff that is actually in wksloginform
  IvFbk  := NOT_IMPLEMENTED_STR;
  Result := false;
  raise Exception.Create(NOT_IMPLEMENTED_STR);
end;

function TAllRec.BeforeDispatch(IvWebRequest: TWebRequest; IvWebResponse: TWebResponse; IvOtpIsActive, IvAuditIsActive: boolean; var IvFbk: string): boolean;
var
  k: string;
  v: variant;
begin
  {
    HERE THE APPLICATION SHOULD KNOW ALL ABOUT THE REQUEST SO IT CAN LOAD ALL THESE BUSINESS RECORDS:
    - system, params, switches
    - user, authentication, session
    - organization, palette, smtp, pop3
    - member, email, role, level, structure, authorization
  }

  {$REGION 'WebRequestExtended'}
  {Result :=} wre.Init(IvWebRequest);
//ods('BEFOREDISPATCH WEBREQUESTEXTENDED', 'Initialized'); // TRecHlp<TWreRec>.FieldsToJson(wre)
  {$ENDREGION}

  {$REGION 'WebResponseExtended'}
  {Result :=} wrs.WebResponse := IvWebResponse;
//ods('BEFOREDISPATCH WEBREQUESTEXTENDED', 'Initialized'); // TRecHlp<TWreRec>.FieldsToJson(wre)
  {$ENDREGION}

  {$REGION 'Server'}
  Result := srv.Init(sys.ADMIN_CSV, wre.Host, IntToStr(wre.ServerPort), IvOtpIsActive, IvAuditIsActive, IvFbk);
  if not Result then begin
    ods('ISAPIWEBMODULE BEFOREDISPATCH WEBSERVER WARNING', IvFbk);
    Exit;
  end;
//ods('ISAPIWEBMODULE BEFOREDISPATCH WEBSERVER', TRecHlp<TSrvRec>.FieldsToJson(srv));
  {$ENDREGION}

  {$REGION 'BusinessRecord'}
  Result := all.RecordDbaInit(wre.UserOrganization, wre.Username, IvFbk);
//  ods('BEFOREDISPATCH ALL-REC-INIT-FROM-DBA', IvFbk);
  {$ENDREGION}

  {$REGION 'Otp'}
  (*
  if not IvOtpIsActive then
//    ods('BEFOREDISPATCH OTP', 'Disabled')
  else begin
    if wre.Otp.IsEmpty then begin
//      ods('BEFOREDISPATCH OTP', 'Enabled but empty (this should be the 1st request, so a new one has been generated and saved back to the client browser, ready for the next requests)');
      wre.Otp := otq.New;
      v := wre.Otp;
      cok.Write(IvWebResponse, 'CoOtp', v, k); // writes to client browser a cookie with a fresh otp, 1st request
    end else begin
//      ods('BEFOREDISPATCH OTP', 'Enabled and not empty (this should be a request after the 1st one, carring the otp written during the 1st request');
      Result := otq.Validate(StrToInt(wre.Otp), IvFbk); // 4+4 seconds tolerance
      if not Result then begin
        IvWebResponse.SendRedirect('/');
//        ods('BEFOREDISPATCH OTP', 'Not valid, ' + IvFbk);
      end else
//        ods('BEFOREDISPATCH OTP', 'Ok, ' + IvFbk);
    end;
  end;
  *)
  {$ENDREGION}

  {$REGION 'CustomHeaderCors'}
  IvWebResponse.SetCustomHeader('Access-Control-Allow-Origin', '*');
  if Trim(IvWebRequest.GetFieldByName('Access-Control-Request-Headers')) <> '' then begin
    IvWebResponse.SetCustomHeader('Access-Control-Allow-Headers', IvWebRequest.GetFieldByName('Access-Control-Request-Headers'));
  //Handled := true; see: https://stackoverflow.com/questions/38786004/cors-issue-on-a-delphis-datasnap-isapi-module
  end;
  {$ENDREGION}

  {$REGION 'CustomHeaderZzz'}
  (*
  IvWebResponse.ContentType := 'text/html';                                          // simulate text/hatml content
  IvWebResponse.ContentType := 'application/javascript';                             // simulate text/javascript content
  IvWebResponse.ContentType := MimeTypeFromContent(@m, m.Size);                      // setmime, MimeTypeFromRegistry(fe) <- not working!!!
  IvWebResponse.SetCustomHeader(HTTP_HEADER_CONTENT_TYPE, MIME_TYPE_TEXT_XML_UTF8);  //
  IvWebResponse.SetCustomHeader('Content-Disposition', 'filename=' + n);             // set "suggested file name" in case a user try a download and save file as
  // no page cache in the client
  IvWebResponse.SetCustomHeader('Expires', htt.HTTP_HEADER_EXPIRE);
  *)
  {$ENDREGION}

  Result := true;
end;

function TAllRec.AfterDispatch(IvStopwatch: TStopwatch; IvWebRequest: TWebRequest; IvWebResponse: TWebResponse; IvOtpIsActive, IvAuditIsActive: boolean; var IvFbk: string): boolean;
begin

  {$REGION 'TimersStop'}
  wre.TimingMs := IvStopwatch.ElapsedMilliseconds; // final total time, for partial timing use wa0.ElapsedMilliseconds no, use local
//ods('AFTERDISPATCH TIMING', wre.TimingMs.ToString + ' ms');
  {$ENDREGION}

  {$REGION 'FinalContent'}
  if obj.DbaSwitchGet('System', 'ShowRenderingTime', true) then
    IvWebResponse.Content := str.Replace(IvWebResponse.Content, '$RenderingTime$', htm.DivTiming(wre.TimingMs))
  else
    IvWebResponse.Content := str.Remove(IvWebResponse.Content, '$RenderingTime$');
  {$ENDREGION}

  {$REGION 'RequestLog'}
  if IvAuditIsActive then
    wre.DbaInsert(IvFbk); // can save a request even if the user is not logged in? may be using a sessionid created anyway? so all request in the same session might be clustered
  {$ENDREGION}

  Result := true;
end;
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

{$REGION 'TBolRec'}
function TBolRec.FromStr(IvString: string; IvDefault: boolean): boolean;
var
  s: string;
begin
//Result := StrToBoolDef(IvString, IvDefault);

  s := UpperCase(IvString);
       if (s ='-1') or (s = '1') or (s = 'TRUE' ) or (s = 'ON' ) or (s = 'YES') or (s = 'OK') or (s = 'OPEN')  or (s = 'ENABLED' ) or (s = 'SUCCESSFUL'  ) then Result := true
  else if (s = '0')              or (s = 'FALSE') or (s = 'OFF') or (s = 'NO' ) or (s = 'NO') or (s = 'CLOSE') or (s = 'DISABLED') or (s = 'UNSUCCESSFUL') then Result := false
  else                                                                                                                                                          Result := IvDefault;
end;

function TBolRec.ToStr(IvBoolean, IvLowerCase: boolean): string;
begin
//Result := BoolToStr(IvBoolean, true);

  if IvBoolean then
    Result := 'True'
  else
    Result := 'False';

  if IvLowerCase then
    Result := LowerCase(Result);
end;

function TBolRec.VectorToBinaryStr(IvBooleanVec: array of boolean): string;
var
  i: integer;
begin
  Result := '';
  for i := Low(IvBooleanVec) to High(IvBooleanVec) do
    if IvBooleanVec[i] then
      Result := Result + '1'
    else
      Result := Result + '0';
end;
{$ENDREGION}

{$REGION 'TBynRec'}
function TBynRec.AuthToken: string;
begin
  Result := str.Expande(Nick, '.');
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
  Screen.Cursor := crHourGlass;
  try
//    Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapClientVersionIsOk(Tag, Ver, IvFbk);
  finally
    Screen.Cursor := crDefault;
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
  else if n.Contains('UtilsProject'  ) then Result := 'Utility'     // utility standalone app
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
  Result := Nick;
end;

function TBynRec.Ver(IvFile: string): string;
begin
  if iis.Nx(IvFile) then
    Result := fsy.FileVer(Spec)
  else
    Result := fsy.FileVer(IvFile);
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

{$REGION 'TCodRec'}
function TCodRec.CsvStr: string;
var
  v: TStringVector;
  i: integer;
begin
  v := Vector;
  for i := Low(v) to High(v) do
    Result := Result + ',' + v[i];
  Delete(Result, 1, 1);
end;

function TCodRec.DbaCode(IvId: integer; var IvBlocs: integer; var IvType, IvCode, IvFbk: string): boolean;
var
  ds: TFDDataSet;
  x: TDbaCls;
  sb: TSbuRec;
  id, pi, zo: integer;
  ki, cn, co{, cm, mi, jo}, ra, mt{, od, on}, a, b, c, d: string;
begin
  x := TDbaCls.Create(FDManager);
  try

    {$REGION 'Query'}
    Result := x.HTreeDs('DbaCode.dbo.TblCode', 'FldCode', 'FldKind, FldContent, FldReturnAs, FldMimeType', IvId, ds, IvFbk, 'FldState=''Active''');
    if not Result then
      Exit;
    IvBlocs := ds.RecordCount;
    {$ENDREGION}

    {$REGION 'Validate'}
    Result := IvBlocs >= 1;
    if not Result then begin
      IvFbk := Format('Unable to get library for CoLibraryId = %d, dataset is empty', [id]);
      Exit;
    end;
    {$ENDREGION}

    {$REGION 'Root'}
    id := ds.FieldByName('FldId'            ).AsInteger;
    pi := ds.FieldByName('FldPId'           ).AsInteger;
    zo := ds.FieldByName('FldOrder'         ).AsInteger;
    ki := ds.FieldByName('FldKind'          ).AsString ;
  //st := ds.FieldByName('FldState'         ).AsString ;
  //cr := ds.FieldByName('FldCreated'       ).AsString ;
  //up := ds.FieldByName('FldUpdated'       ).AsString ;
  //oo := ds.FieldByName('FldOrganization'  ).AsInteger;
  //ow := ds.FieldByName('FldOwner'         ).AsString ;
    cn := ds.FieldByName('FldCode'          ).AsString ;
    co := ds.FieldByName('FldContent'       ).AsString ;
  //jo := ds.FieldByName('FldJson'          ).AsString ;
  //cm := ds.FieldByName('FldCompiled'      ).AsString ;
  //mi := ds.FieldByName('FldMinimized'     ).AsString ;
    ra := ds.FieldByName('FldReturnAs'      ).AsString ;
    mt := ds.FieldByName('FldMimeType'      ).AsString ;
  //od := ds.FieldByName('FldOutputDir'     ).AsString ;
  //on := ds.FieldByName('FldOutputFileName').AsString ;
  //rc := ds.FieldByName('FldRunCommand'    ).AsString;
    {$ENDREGION}

    {$REGION 'Other'}
    // type
    IvType := iif.Str(IvBlocs = 1, 'CODE', 'LIBRARY');

    // comment
         if ki = cod.BAT_KIND       then c := '::' // *** WARNING, POTENTIALLY INCOMPLETE ***
    else if ki = cod.CSS_KIND       then c := ''
    else if ki = cod.CSV_KIND       then c := ''
    else if ki = cod.DWS_KIND       then c := '//'
    else if ki = cod.ETL_KIND       then c := '--'
    else if ki = cod.ETL_SQL_KIND   then c := '--'
    else if ki = cod.ETL_MONGO_KIND then c := ''
    else if ki = cod.HTML_KIND      then c := ''
    else if ki = cod.ISS_KIND       then c := ';;'
    else if ki = cod.JAVA_KIND      then c := '//'
    else if ki = cod.JS_KIND        then c := '//'
    else if ki = cod.JSON_KIND      then c := ''
    else if ki = cod.PAS_KIND       then c := '//'
    else if ki = cod.PY_KIND        then c := '##'
    else if ki = cod.R_KIND         then c := '##'
    else if ki = cod.SQL_KIND       then c := '--'
    else if ki = cod.XML_KIND       then c := ''
    else if ki = cod.TXT_KIND       then c := ''
    else if ki = cod.INI_KIND       then c := ';;' // ???
    ;
    {$ENDREGION}

    {$REGION 'Build'}
    // head
  if c <> '' then begin
    a := Format('%s   %s', [IvType, cn]);
    b := Format('(id:%d, pid:%d, ord:%d)', [id, pi, zo]);
    d := StringOfChar(c.Chars[0], 80);
    sb.Add(d, 0);
    sb.Fmt('%s %-40s%37s', [c, a, b]);
    sb.Add(d);
    sb.Emp;
  end;

    // rootadd
    sb.Add(Trim(co));
    // next
    ds.Next;

    // childsaddifany
    while not ds.Eof do begin
      // item
      id := ds.FieldByName('FldId'     ).AsInteger;
      pi := ds.FieldByName('FldPId'    ).AsInteger;
      zo := ds.FieldByName('FldOrder'  ).AsInteger;
      cn := ds.FieldByName('FldCode'   ).AsString;
      co := ds.FieldByName('FldContent').AsString;

      // append
    if c <> '' then begin
      a := Format('B L O K   %s', [cn]);
      b := Format('(id:%d, pid:%d, ord:%d)', [id, pi, zo]);
      sb.Emp;
      sb.Emp;
      sb.Fmt('%s %-35s%42s', [c, a, b]);
      sb.Add(d);
    end;
      sb.Add(Trim(co));

      ds.Next;
    end;

    // tail
  if c <> '' then begin
    sb.Emp;
    a := Format('END', [cn]);
    b := Format('(generated by wks @ %s in %d ms)', [DateTimeToStr(Now), {FWat.Elapsed.Milliseconds}-1]); // *** no, use local ***
    sb.Add(d);
    sb.Fmt('%s %-20s%57s', [c, a, b]);
    sb.Add(d);
  end;

    // library
  //  IvCode := rva.Rv(sb.Text);
    {$ENDREGION}

  finally
    FreeAndNil(x);
  end;
end;

function TCodRec.RioCode(IvId: integer; var IvBlocs: integer; var IvType, IvCode, IvFbk: string): boolean;
begin
  Screen.Cursor := crHourGlass;
  try
  // TEMPORARYCOMMENT
//  Result := (rio.HttpRio('Code') as ICodeSoapMainService).CodeRioCode(IvId, IvBlocs, IvType, IvCode, IvFbk);
  finally
    Screen.Cursor := crDefault;
  end;
end;

function TCodRec.Vector: TStringVector;
begin
  Result := [
    BAT_KIND
  , CSS_KIND
  , CSV_KIND
  , DWS_KIND
  , ETL_KIND
  , ETL_SQL_KIND
  , ETL_MONGO_KIND
  , HTML_KIND
  , ISS_KIND
  , JAVA_KIND
  , JS_KIND
  , JSON_KIND
  , PAS_KIND
  , PY_KIND
  , R_KIND
  , SQL_KIND
  , XML_KIND
  , TXT_KIND
  , INI_KIND
  ];
end;
{$ENDREGION}

{$REGION 'TColRec'}

  {$REGION 'Help'}
{
  DEFINITIONS
  ===========
  - hue is a color like red, blue, orange, ...

  SHADE and TINT
  ==============
  - shade is produced by "darkening" a hue or "adding black"
  - tint is produced by "ligthening" a hue or "adding white"

  in RGB
  ------
    To shade:
    newR = currentR * (1 - shade_factor)
    newG = currentG * (1 - shade_factor)
    newB = currentB * (1 - shade_factor)

    To tint:
    newR = currentR + (255 - currentR) * tint_factor
    newG = currentG + (255 - currentG) * tint_factor
    newB = currentB + (255 - currentB) * tint_factor

    More generally, the color resulting in layering a color RGB(currentR,currentG,currentB) with a color RGBA(aR,aG,aB,alpha) is:
    newR = currentR + (aR - currentR) * alpha
    newG = currentG + (aG - currentG) * alpha
    newB = currentB + (aB - currentB) * alpha

    where (aR,aG,aB) = black = (0,0,0) for shading
      and (aR,aG,aB) = white = (255,255,255) for tinting

   in HSV or HSB
   -------------
     To shade: lower the Value / Brightness or increase the Saturation
     To tint: lower the Saturation or increase the Value / Brightness

   in HSL
   ------
     To shade: lower the Lightness
     To tint: increase the Lightness


  delphi color format
  -------------------
  TColor type is an integer whose bits contain the actual RGB values like this ssBBGGRR

  TColor internal format can have five formats:
  1. $00bbggrr -- Create using the RGB function
  2. $010000nn -- Create using the PaletteIndex function
  3. $02bbggrr -- Create using the PaletteRGB function
  4. $800000nn -- Defined in Graphics.pas using Windows constants like COLOR_SCOLLBAR, etc
                  these negative values must be passed to the ColorToRGB function  to have R, G and B
  5. $FFFFFFFF -- if you create a TBitmap and do not define its height and width,
                  the pixels value will be -1 ($FFFFFFFF) and may cause range-check errors

  Warning about system colors
  ---------------------------
  There are special colors which are derived from the system colors (like button and window colors)
  Those colors don't actually have valid RGB values
  You can detect them by checking the first eight bits
  If they are non-zero you have a special system color
  You can also cast the color to an integer
  If it is negative, it's a system color
  In that case the R part contains the system color index

  Color components extraction
  ---------------------------
  You can filter out the parts by doing a bit-wise and with 0xFF, while shifting the bits to the right:
  R := Color and $FF;  G := (Color shr 8) and $FF;  B := (Color shr 16) and $FF;
}
  {$ENDREGION}

  {$REGION 'Component'}
function  TColRec.R(IvColor: TColor): byte;
begin
  Result := GetRValue(IvColor); // IvColor and $FF;
end;

function  TColRec.G(IvColor: TColor): byte;
begin
  Result := GetGValue(IvColor); // (IvColor shr 8) and $FF;
end;

function  TColRec.B(IvColor: TColor): byte;
begin
  Result := GetBValue(IvColor); // (IvColor shr 16) and $FF;
end;

function  TColRec.R(IvHColor: string): byte;
begin
  Result := GetRValue(FromHtml(IvHColor));
end;

function  TColRec.G(IvHColor: string): byte;
begin
  Result := GetGValue(FromHtml(IvHColor));
end;

function  TColRec.B(IvHColor: string): byte;
begin
  Result := GetBValue(FromHtml(IvHColor));
end;

function  TColRec.H(IvColor: TColor): double;
var
  h, s, l: word;
begin
  ToHSL(IvColor, h, s, l);
  Result := h;
end;

function  TColRec.S(IvColor: TColor): double;
var
  h, s, l: word;
begin
  ToHSL(IvColor, h, s, l);
  Result := s;
end;

function  TColRec.L(IvColor: TColor): double;
var
  h, s, l: word;
begin
  ToHSL(IvColor, h, s, l);
  Result := l;
end;
  {$ENDREGION}

  {$REGION 'Ops'}
function  TColRec.Invert(IvColor: TColor): TColor;
begin
  raise Exception.Create('Error, function not implemented');
//Result := clRed;
end;

function  TColRec.Lighten(IvColor: TColor; IvPercentage: integer): TColor;
var
  r: TColorRef;
  h, s, l: word;
begin
  r := ToColorRef(IvColor);
  ColorRGBToHLS(r, h, l, s);
  l := (Cardinal(l) * (100 + IvPercentage)) div 100;
  r := ColorHLSToRGB(h, l, s);
  Result := r;
end;

function  TColRec.Darken(IvColor: TColor; IvPercentage: integer): TColor;
var
  r: TColorRef;
  h, s, l: word;
begin
  r := ToColorRef(IvColor);
  ColorRGBToHLS(r, h, l, s);
  l := (Cardinal(l) * (100 - IvPercentage)) div 100;
  r := ColorHLSToRGB(h, l, s);
  Result := r;
end;
  {$ENDREGION}

  {$REGION 'Grade'}
function  TColRec.GradeBlue(IvGrade: byte): string;
var
  l, r, g, b, a: byte;
begin
  l := Round(-1 / 2 * IvGrade + $ff);
  b := $ff;
  g := 2 * l - $ff;
  r := g;
  a := $ff;

  Result :=
    IntToHex(r, 2) // red
  + IntToHex(g, 2) // green
  + IntToHex(b, 2) // blue
  + IntToHex(a, 2) // alpha
  ;
end;

function  TColRec.GradeGray(IvGrade: byte): string;
var
  l, r, g, b, a: byte;
begin
  l := $ff - IvGrade;
  r := l;
  g := r;
  b := r;
  a := $ff;

  Result :=
    IntToHex(r, 2) // red
  + IntToHex(g, 2) // green
  + IntToHex(b, 2) // blue
  + IntToHex(a, 2) // alpha
  ;
end;

function  TColRec.GradeGreen(IvGrade: byte): string;
var
  l, r, g, b, a: byte;
begin
  l := Round(-3 / 4 * IvGrade + $ff);
  if l < $80 then begin
    r := 0;
    g := 2 * l;
    b := 0;
  end else begin
    r := 2 * l - $ff;
    g := $ff;
    b := r;
  end;
  a := $ff;

  Result :=
    IntToHex(r, 2) // red
  + IntToHex(g, 2) // green
  + IntToHex(b, 2) // blue
  + IntToHex(a, 2) // alpha
  ;
end;

function  TColRec.GradeRed(IvGrade: byte): string;
var
  l, r, g, b, a: byte;
begin
  l := Round(-1 / 2 * IvGrade + $ff);
  r := $ff;
  g := 2 * l - $ff;
  b := g;
  a := $ff;

  Result :=
    IntToHex(r, 2) // red
  + IntToHex(g, 2) // green
  + IntToHex(b, 2) // blue
  + IntToHex(a, 2) // alpha
  ;
end;
  {$ENDREGION}

  {$REGION 'Spectra'}
function  TColRec.Rainbow(IvMin, IvMax, IvIdx: double): string;
var
  m: Double;
  r, g, b, a, mt: byte;
begin
  m := (IvIdx - IvMin) / (IvMax - IvMin + 1) * 6;
  mt := (Round(Frac(m) * $FF));
  case Trunc(m) of
  0: begin
      r := $ff;
      g := mt;
      b := 0;
      a := $ff;
    end;
  1: begin
      r := $ff - mt;
      g := $ff;
      b := 0;
      a := $ff;
    end;
  2: begin
      r := 0;
      g := $ff;
      b := mt;
      a := $ff;
    end;
  3: begin
      r := 0;
      g := $ff - mt;
      b := $ff;
      a := $ff;
    end;
  4: begin
      r := mt;
      g := 0;
      b := $ff;
      a := $ff;
    end;
  5: begin
      r := $ff;
      g := 0;
      b := $ff - mt;
      a := $ff;
    end;
  else begin
      r := 0;
      g := 0;
      b := 0;
      a := $ff;
    end;
  end;

  Result :=
    IntToHex(r, 2) // red
  + IntToHex(g, 2) // green
  + IntToHex(b, 2) // blue
  + IntToHex(a, 2) // alpha
  ;
end;

function  TColRec.Rainbow(MinHue, MaxHue, Hue: integer): TColor;
begin
  Result := Rainbow((Hue - MinHue) / (MaxHue - MinHue + 1));
end;

function  TColRec.Rainbow(Hue: double): TColor;
var
  h: THls;
  c: TRGBTriple;
begin
//Hue := EnsureRange(Hue, 0, 1) * 6;
//case Trunc(Hue) of
//  0: Result := RGB(255                         , Round(Frac(Hue) * 255)      , 0                           );
//  1: Result := RGB(255 - Round(Frac(Hue) * 255), 255                         , 0                           );
//  2: Result := RGB(0                           , 255                         , Round(Frac(Hue) * 255)      );
//  3: Result := RGB(0                           , 255 - Round(Frac(Hue) * 255), 255                         );
//  4: Result := RGB(Round(Frac(Hue) * 255)      , 0                           , 255                         );
//else
//     Result := RGB(255                         , 0                           , 255 - Round(Frac(Hue) * 255));
//end;

  // or
  h.H := Round(Hue * HLS_MAX);
  h.L := HLS_MAX div 2;
  h.S := HLS_MAX;
  c := HLStoRGB(h);
  Result := RGB(c.rgbtRed, c.rgbtGreen, c.rgbtBlue);
end;

procedure TColRec.RainbowToRgb(const fraction: double; var R, G, B: byte);
const
  WAVELENGTH_MINIMUM = 380;  // nanometers
  WAVELENGTH_MAXIMUM = 780;
var
  w: TNanometer; // wavelength
begin
  w := WAVELENGTH_MINIMUM + fraction*(WAVELENGTH_MAXIMUM - WAVELENGTH_MINIMUM);
  if   w < WAVELENGTH_MINIMUM
  then w := WAVELENGTH_MINIMUM;

  if   w > WAVELENGTH_MAXIMUM
  then w := WAVELENGTH_MAXIMUM;

  WavelengthToRgb(w, R, G, B)
end;

procedure TColRec.WavelengthToRgb(const Wavelength: TNanometer; var R, G, B: byte);
const
  Gamma        = 0.80;
  IntensityMax = 255;
var
  Blue  : double;
  Green : double;
  Red   : double;
  Factor: double;

  function  Adjust(const Color, Factor: double): integer;
  begin
    if   Color = 0.0
    then Result := 0     // Don't want 0^x = 1 for x <> 0
    else Result := Round(IntensityMax * Power(Color * Factor, Gamma))
  end;

begin
  case trunc(Wavelength) of
    380..439: begin
      Red   := -(Wavelength - 440) / (440 - 380);
      Green := 0.0;
      Blue  := 1.0
    end;
    440..489: begin
      Red   := 0.0;
      Green := (Wavelength - 440) / (490 - 440);
      Blue  := 1.0
    end;
    490..509: begin
      Red   := 0.0;
      Green := 1.0;
      Blue  := -(Wavelength - 510) / (510 - 490)
    end;
    510..579: begin
      Red   := (Wavelength - 510) / (580 - 510);
      Green := 1.0;
      Blue  := 0.0
    end;
    580..644: begin
      Red   := 1.0;
      Green := -(Wavelength - 645) / (645 - 580);
      Blue  := 0.0
    end;
    645..780: begin
      Red   := 1.0;
      Green := 0.0;
      Blue  := 0.0
    end;
    else begin
      Red   := 0.0;
      Green := 0.0;
      Blue  := 0.0;
    end;
  end;

  // let the intensity fall off near the vision limits
  case trunc(Wavelength) of
    380..419: factor := 0.3 + 0.7*(Wavelength - 380) / (420 - 380);
    420..700: factor := 1.0;
    701..780: factor := 0.3 + 0.7*(780 - Wavelength) / (780 - 700)
    else      factor := 0.0
  end;

  R := Adjust(Red,   Factor);
  G := Adjust(Green, Factor);
  B := Adjust(Blue,  Factor);
end;
  {$ENDREGION}

  {$REGION 'FromTo'}
function  TColRec.ToColorRef(IvColor: TColor): TColorRef;
begin
  if IvColor < 0 then
    Result := GetSysColor(IvColor and $000000FF)
  else
    Result := IvColor; // ColorToRGB()
end;

procedure TColRec.ToRGB(const IvColor: TColor; out R, G, B: byte);
begin
  R :=  IvColor         and $FF;
  G := (IvColor shr  8) and $FF;
  B := (IvColor shr 16) and $FF;
end;

function  TColRec.FromRGB(const R, G, B: byte): TColor;
begin
  Result := R or (G shl 8) or (B shl 16);
end;

procedure TColRec.ToHSL(const IvColor: TColor; out H, S, L: word);
var
  r: TColorRef;
begin
  r := ToColorRef(IvColor);
  ColorRGBToHLS(r, H, L, S);
end;

function  TColRec.FromHSL(const H, S, L: word): TColor;
var
  r: TColorRef;
begin
  r := ColorHLSToRGB(H, L, S);
  Result := r;
end;

function  TColRec.ToHtml(IvColor: TColor): string;
var
  c: TColorRef;
begin
  c := ColorToRGB(IvColor);
  Result := Format('#%.2x%.2x%.2x', [GetRValue(c), GetGValue(c), GetBValue(c)]).ToLower;
end;

function  TColRec.FromHtml(IvHColor: string; IvDefault: TColor): TColor;
begin
  if copy(IvHColor, 1, 1) <> '#' then
    IvHColor := '#' + IvHColor;
  IvHColor := '$' + copy(IvHColor, 6, 2) + copy(IvHColor, 4, 2) + copy(IvHColor, 2, 2); // $bbggrr
  try
    Result := StringToColor(IvHColor);
  except
    Result := IvDefault;
  end;
end;


function  TColRec.RGB2BGR(IvRGBColor: TColor): TColor;
var
  r, g, b: integer;
begin
//Result := (Integer(B) shl 16) + (Integer(G) shl 8) + R;
  r :=   IvRGBColor div $10000                  ;
  g := ((IvRGBColor mod $10000) div $100) shl  8;
  b :=  (IvRGBColor mod $100  )           shl 16;
  Result := b + g + r;
end;

function  TColRec.BGR2RGB(IvBGRColor: TColor): TColor;
var
  r, g, b: integer;
begin
  r := IvBGRColor and $FF0000 shr 16;
  g := IvBGRColor and $00FF00       ;
  b := IvBGRColor and $0000FF shl 16;
  Result := r + g + b;
end;

function  TColRec.RgbToHls(IvRgb: TRGBTriple): THls;
var
  lr, lg, lb, lh, ll, ls, lmin, lmax: double;
begin
  lr   := IvRgb.RgbtRed   / 256;
  lg   := IvRgb.RgbtGreen / 256;
  lb   := IvRgb.RgbtBlue  / 256;
  lmin := Mat.Min3(lr, lg, lb);
  lmax := Mat.Max3(lr, lg, lb);
  LL := (LMax + LMin) / 2;
  if LMin = LMax then begin
    LH := 0;
    LS := 0;
    Result.H := round(LH * 256);
    Result.L := round(LL * 256);
    Result.S := round(LS * 256);
    exit;
  end;
  if LL < 0.5 then
    LS := (LMax - LMin) / (LMax + LMin)
  else
    LS := (LMax-LMin) / (2.0 - LMax - LMin);
  if LR = LMax then
    LH := (LG - LB)/(LMax - LMin)
  else if LG = LMax then
    LH := 2.0 + (LB - LR) / (LMax - LMin)
  else
    LH := 4.0 + (LR - LG) / (LMax - LMin);
  Result.H := round(LH * 42.6);
  Result.L := round(LL * 256);
  Result.S := round(LS * 256);
end;

function  TColRec.HlsToRgb(IvHls: THls): TRGBTriple;
var
  LR, LG, LB, LH, LL, LS: double;
  L1, L2: Double;
begin
  LH := IvHls.H / 255;
  LL := IvHls.L / 255;
  LS := IvHls.S / 255;
  if LS = 0 then begin
    Result.RgbtRed := IvHls.L;
    Result.RgbtGreen := IvHls.L;
    Result.RgbtBlue := IvHls.L;
    Exit;
  end;
  if LL < 0.5 then
    L2 := LL * (1.0 + LS)
  else
    L2 := LL + LS - LL * LS;
  L1 := 2.0 * LL - L2;
  LR := LH + 1.0/3.0;
  if LR < 0 then
    LR := LR + 1.0;
  if LR > 1 then
    LR := LR - 1.0;
  if 6.0 * LR < 1 then
    LR := L1+(L2 - L1) * 6.0 * LR
  else if 2.0 * LR < 1 then
    LR := L2
  else if 3.0*LR < 2 then
    LR := L1 + (L2 - L1) * ((2.0 / 3.0) - LR) * 6.0
  else
    LR := L1;
  LG := LH;
  if LG < 0 then
    LG := LG + 1.0;
  if LG > 1 then
    LG := LG - 1.0;
  if 6.0 * LG < 1 then
    LG := L1+(L2 - L1) * 6.0 * LG
  else if 2.0*LG < 1 then
    LG := L2
  else if 3.0*LG < 2 then
    LG := L1 + (L2 - L1) * ((2.0 / 3.0) - LG) * 6.0
  else
    LG := L1;
  LB := LH - 1.0/3.0;
  if LB < 0 then
    LB := LB + 1.0;
  if LB > 1 then
    LB := LB - 1.0;
  if 6.0 * LB < 1 then
    LB := L1+(L2 - L1) * 6.0 * LB
  else if 2.0*LB < 1 then
    LB := L2
  else if 3.0*LB < 2 then
    LB := L1 + (L2 - L1) * ((2.0 / 3.0) - LB) * 6.0
  else
    LB := L1;
  Result.RgbtRed := round(LR * 255);
  Result.RgbtGreen := round(LG * 255);
  Result.RgbtBlue := round(LB * 255);
end;

function  TColRec.ToStr(IvColor: TColor): string;                               // to    'clRed'
begin
  Result := ColorToString(IvColor);
end;

function  TColRec.ToHexStr(IvColor: TColor): string;                            // to   '0000FF'
begin
  Result := ColorToString(IvColor);
end;

function  TColRec.ToHtmlHexStr(IvColor: TColor; IvPrefix: boolean): string;     // to   'FF0000'  or '#FF0000'
begin
  Result := Format('%.2x%.2x%.2x', [GetRValue(IvColor), GetGValue(IvColor), GetBValue(IvColor)]);
  if IvPrefix then
    Result := '#' + Result;
end;

function  TColRec.ToHtmlNameStr(IvColor: TColor): string;                       // to    red      or orangered
var
  i: integer;
begin
  Result := '';
  try
    // 1) try to find match in table to get html color name
    for i := Low(TABLE) to High(TABLE) do
      if TABLE[i].RGB = BGR2RGB(IvColor) then begin
        Result := TABLE[i].Name;
        Break;
      end;

    // 2) if no match convert rgb color to html hex color string
    if Result = '' then
      Result := '#' +
        IntToHex(Byte(IvColor       ), 2)
      + IntToHex(Byte(IvColor shr  8), 2)
      + IntToHex(Byte(IvColor shr 16), 2);
  except
    Result := '#000000';
  end;
end;

function  TColRec.FromStr(IvString: string): TColor;                            // from  cl+delphicolorname
begin
  Result := StringToColor('cl' + IvString);
end;

function  TColRec.FromHexStr(IvHexString, IvDefault: string): TColor;           // from '0000FF'
var
  s: string;
begin
  s := IvHexString;
  if s = '' then
    s := IvDefault;
  if Length(s) < 6 then
    s := s + StringOfChar('0', 6 - Length(s));
  if Length(s) > 6 then
    s := LeftStr(s, 6);
//if Length(s) = 6 then
  //s := s + '00';

  try
    Result := RGB(
      StrToInt('$' + Copy(s, 1, 2)) // red value
    , StrToInt('$' + Copy(s, 3, 2)) // green value
    , StrToInt('$' + Copy(s, 5, 2)) // blue value
    );
  except
    Result := FromHexStr(IvDefault); // if colorname is mispelled, like skyblu (should be skyblue), than 1) will not trigger and 2) will fail
  end;
end;

function  TColRec.FromHtmlHexStr(IvHtmlHexString, IvDefault: string): TColor;   // from '#RRGGBB' or 'FF0000'
var
  x: string;
begin
  x := str.Right(IvHtmlHexString, 6);
  Result := FromHexStr(x, IvDefault);
end;

function  TColRec.FromHtmlHexOrNameStr(IvHtmlNameString, IvDefault: string): TColor; // from  red      or orangered
var
  i, o: integer; // offset
begin
  Result := -1;
  try
    // 1) try to find match in table to get delphi tcolor
    for i := Low(TABLE) to High(TABLE) do
      if SameText(TABLE[i].Name, IvHtmlNameString) then begin
        Result := RGB2BGR(TABLE[i].RGB);
        Break;
      end;

    // 2) if no match convert html hex rgb color to delphi tcolor
    if Result = -1 then begin       // check for leading '#'
      if Copy(IvHtmlNameString, 1, 1) = '#' then
        o := 1
      else
        o := 0;
      Result :=
        Integer(StrToInt('$' + Copy(IvHtmlNameString, o + 1, 2)))
      + Integer(StrToInt('$' + Copy(IvHtmlNameString, o + 3, 2))) shl 8
      + Integer(StrToInt('$' + Copy(IvHtmlNameString, o + 5, 2))) shl 16;
    end;
  except
    Result := FromHtmlHexOrNameStr(IvDefault); // if colorname is mispelled, like skyblu (should be skyblue), than 1) will not trigger and 2) will fail
  end;
end;
  {$ENDREGION}

  {$REGION 'Utils'}
function  TColRec.Blend(IvColor1, IvColor2: TColor; IvBlendingLevel: Byte): TColor;
var
  c1, c2: longint;
  r, g, b, v1, v2: byte;
begin
  IvBlendingLevel := Round(2.55 * IvBlendingLevel);
  c1 := ColorToRGB(IvColor1);
  c2 := ColorToRGB(IvColor2);
  v1 := Byte(c1);
  v2 := Byte(c2);
  r  := IvBlendingLevel * (v1 - v2) shr 8 + v2;
  v1 := Byte(c1 shr 8);
  v2 := Byte(c2 shr 8);
  g  := IvBlendingLevel * (v1 - v2) shr 8 + v2;
  v1 := Byte(c1 shr 16);
  v2 := Byte(c2 shr 16);
  b  := IvBlendingLevel * (v1 - v2) shr 8 + v2;
  Result := (b shl 16) + (g shl 8) + r;
end;
  {$ENDREGION}

  {$REGION 'Rnd'}
function  TColRec.ColorAggRnd(IvStart: byte; IvAlpha: string): string;
begin
  Result := ToHexStr(ColorFineRnd(IvStart)) + IvAlpha;
end;

function  TColRec.ColorFineRnd(IvStart: byte): TColor;
var
  r: byte; // remaining
begin
  r := 255 - IvStart;
  Result := Rgb(IvStart + Random(r), IvStart + Random(r), IvStart + Random(r));
end;

function  TColRec.ColorHexaRnd: string;
begin
  Result := ColorHexRnd + IntToHex(Random($ff), 2) // alpha
end;

function  TColRec.ColorHexRnd: string;
begin
  Result :=
    IntToHex(Random($ff), 2) // red
  + IntToHex(Random($ff), 2) // green
  + IntToHex(Random($ff), 2) // blue
end;

function  TColRec.ColorHtmlRnd: string;
begin
  Result := '#808080';
end;

function  TColRec.ColorNameRnd: string;
var
  z, r: integer;
begin
  z := Length(TABLE);
  r := Random(z);
  Result := TABLE[r].Name;
end;

function  TColRec.ColorRnd: TColor;
var
  z, r: integer;
begin
  z := Length(TABLE);
  r := Random(z);
  Result := TABLE[r].RGB;
end;
  {$ENDREGION}

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

procedure TConRec.ConnPrivatePooledCreateInFDManagerInCode;
var
  p: TStrings; // params
begin
  p := TStringList.Create;
  try
    p.Add('Server=LOCALHOST');
    p.Add('Database=DbaClient');
    p.Add('User_Name=sa');
    p.Add('Password=Igi0Ade');
    p.Add('POOL_CleanupTimeout=60000'); // default 30000 ms
    p.Add('POOL_ExpireTimeout=600000'); // default 90000 ms
    p.Add('POOL_MaximumItems=60');      // maximum number of connections, default 50
    p.Add('Pooled=True');
    FDManager.Close;
    FDManager.AddConnectionDef(CONN_DEF_NAME_FD, 'Mssql', p);
    FDManager.Active := true;
  finally
    p.Free;
  end;
end;

procedure TConRec.ConnPrivatePooledCreateInFDManagerFromIni;
begin
  FDManager.ConnectionDefFileName := Format('..\..\WksFDConnection_%s.ini', [net.Host]);
  ods('TCONREC', FDManager.ConnectionDefFileName);
  FDManager.LoadConnectionDefFile;
  FDManager.Active := true;
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

{$REGION 'TCssRec'}
function TCssRec.W3ThemeInit(IvHColor, IvName: string): string;
var
  l: TStrings;
  tc: TColor;
  l5, l4, l3, l2, l1, co, d1, d2, d3, d4, d5: string;
begin
  // tcolor
  tc := col.FromHtml(IvHColor);

  // levels
  l5 := col.ToHtml(col.Lighten(tc, 50)); // light  #f9f9f9
  l4 := col.ToHtml(col.Lighten(tc, 40)); //        #ececec
  l3 := col.ToHtml(col.Lighten(tc, 30)); //        #d8d8d8
  l2 := col.ToHtml(col.Lighten(tc, 20)); //        #c5c5c5
  l1 := col.ToHtml(col.Lighten(tc, 10)); //        #b1b1b1
  co := IvHColor;                        // normal #9e9e9e
  d1 := col.ToHtml(col.Darken (tc, 10)); //        #8e8e8e
  d2 := col.ToHtml(col.Darken (tc, 20)); //        #7e7e7e
  d3 := col.ToHtml(col.Darken (tc, 30)); //        #6f6f6f
  d4 := col.ToHtml(col.Darken (tc, 40)); //        #5f5f5f
  d5 := col.ToHtml(col.Darken (tc, 50)); // dark   #4f4f4f

  // css
  l := TStringList.Create;
  try
    l.Add('/***');
    l.Add(' * W3CSS');
    l.Add(' */');
    l.Add('.w3-theme-light              {color:#000 !important; background-color:' + l5 + ' !important}');
    l.Add('.w3-theme-l5                 {color:#000 !important; background-color:' + l5 + ' !important}');
    l.Add('.w3-theme-l4                 {color:#000 !important; background-color:' + l4 + ' !important}');
    l.Add('.w3-theme-l3                 {color:#000 !important; background-color:' + l3 + ' !important}');
    l.Add('.w3-theme-l2                 {color:#000 !important; background-color:' + l2 + ' !important}');
    l.Add('.w3-theme-l1                 {color:#000 !important; background-color:' + l1 + ' !important}');
    l.Add('.w3-theme                    {color:#000 !important; background-color:' + co + ' !important}');
    l.Add('.w3-theme-d1                 {color:#000 !important; background-color:' + d1 + ' !important}'); // should vary: light -> 000, dark -> fff
    l.Add('.w3-theme-d2                 {color:#fff !important; background-color:' + d2 + ' !important}');
    l.Add('.w3-theme-d3                 {color:#fff !important; background-color:' + d3 + ' !important}');
    l.Add('.w3-theme-d4                 {color:#fff !important; background-color:' + d4 + ' !important}');
    l.Add('.w3-theme-d5                 {color:#fff !important; background-color:' + d5 + ' !important}');
    l.Add('.w3-theme-dark               {color:#fff !important; background-color:' + d5 + ' !important}');
    l.Add('');
    l.Add('.w3-theme-action             {color:#fff !important; background-color:' + d5 + ' !important}');
    l.Add('.w3-text-theme               {color:'                                   + co + ' !important}');
    l.Add('.w3-border-theme             {border-color:'                            + co + ' !important}');
    l.Add('');
    l.Add('.w3-hover-theme:hover        {color:#000 !important; background-color:' + co + ' !important}');
    l.Add('.w3-hover-text-theme:hover   {color:'                                   + co + ' !important}');
    l.Add('.w3-hover-border-theme:hover {border-color:'                            + co + ' !important}');
    l.Add('');
    l.Add('/***');
    l.Add(' * SCROLLBARS');
    l.Add(' */');
    l.Add('.w3-scrollbar::-webkit-scrollbar {width:12px;height:12px;}'                        );
    l.Add('.w3-scrollbar::-webkit-scrollbar-track       {background:'              + d1 + ';}');
    l.Add('.w3-scrollbar::-webkit-scrollbar-thumb       {background:'              + d2 + ';}');
    l.Add('.w3-scrollbar::-webkit-scrollbar-thumb:hover {background:'              + d3 + ';}');
    l.Add('.w3-scrollbar::-webkit-scrollbar-corner {background: transparent;}'                );
    l.Add('}');
    l.Add('');
    l.Add('/***');
    l.Add(' * WAITLOADER (not present in the original w3css)');
    l.Add(' */');
    l.Add('@-webkit-keyframes spin { /* safari */');
    l.Add('  0% { -webkit-transform: rotate(0deg); }');
    l.Add('  100% { -webkit-transform: rotate(360deg); }');
    l.Add('}');
    l.Add('@keyframes spin {');
    l.Add('  0% { transform: rotate(0deg); }');
    l.Add('  100% { transform: rotate(360deg); }');
    l.Add('}');
    l.Add('.w3-waitloader {');
    l.Add('  width: 150px;                      /* width */');
    l.Add('  height: 150px;                     /* height */');
    l.Add('  border: 15px solid ' + l4 + ';     /* thickness and bgcolor */');
    l.Add('  border-top: 15px solid ' + d2 + '; /* thickness and fgcolor */');
    l.Add('  margin: -90px 0 0 -90px;           /* 90 = 150/2 + 15 */');
    l.Add('  border-radius: 50%;');
    l.Add('  position: absolute;');
    l.Add('  top: 50%;');
    l.Add('  left: 50%;');
    l.Add('  z-index: 1;');
    l.Add('  -webkit-animation: spin 2s linear infinite; /* safari */');
    l.Add('  animation: spin 2s linear infinite;');
    l.Add('}');
    l.Add('');
    l.Add('/***');
    l.Add(' * MODAL (override)');
    l.Add(' */');
    l.Add('.w3-modal{');
    l.Add('  background-color:rgb('  + Format('%d,%d,%d', [col.R(co), col.G(co), col.B(co)]) + ');');
    l.Add('  background-color:rgba(' + Format('%d,%d,%d', [col.R(co), col.G(co), col.B(co)]) + ',0.6)');
    l.Add('}');
    l.SaveToFile(sys.IncPath + '\w3\w3-theme-' + IvName + '.css');
  finally
    l.Free;
  end;
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

constructor TDbaCls.Create(IvFDManager: TFDCustomManager);
begin
  FFDGUIxSilentMode := true; // suppress whait cursor?
  FConnFD := TFDConnection.Create(nil);
  FConnFD.LoginPrompt := false;
  FConnFD.ConnectionDefName := CONN_DEF_NAME_FD;
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
//FConnFD.Free;
  con.ConnFDFree(FConnFD, k); // *** PROBLEM: isapi do not exit when recycling then apppool ***
  {$ENDREGION}

  inherited;
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
  Result := ScalarFD(q, 0, IvFbk) = 1;
  IvFbk := fbk.ExistsStr('Database', IvDba, Result);
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
        ods('TDBACLS.DSADO', IvFbk);
        ods('TDBACLS.DSADO', IvSql);
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
      ods('TDBACLS.DSADO', IvFbk);
      ods('TDBACLS.DSADO', IvSql);
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
(*
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
      ods('TDBACLS.DSADO', IvFbk);
      ods('TDBACLS.DSADO', IvSql);
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
  IvFbk := NOT_IMPLEMENTED_STR;
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

  // b
  b := StrToFloatDef(IvOperand, 0.0);

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
  IvFbk := NOT_IMPLEMENTED_STR;
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

function TDbaCls.HChildsDs(const IvTbl, IvFldCsv: string; const IvId: integer; var IvDs: TFDDataSet; var IvFbk: string; IvWhere, IvOrderBy: string): boolean;

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
  d: TFDDataSet;
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
  raise Exception.Create(NOT_IMPLEMENTED_STR);
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

function TDbaCls.HParentsDs(const IvTbl, IvFldCsv: string; const IvId: integer; var IvDs: TFDDataSet; var IvFbk: string): boolean;

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
end;

function TDbaCls.HParentsItemChildsDs(const IvTbl, IvFldCsv: string; const IvId: integer; var IvDs: TFDDataSet; var IvFbk: string): boolean;

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
end;

function TDbaCls.HTreeDs(const IvTbl, IvFld, IvFldCsv: string; const IvId: integer; var IvDs: TFDDataSet; var IvFbk: string; IvWhere: string): boolean;

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
      ods('TDBACLS.SCALARADO', IvFbk);
      ods('TDBACLS.SCALARADO', IvSql);
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
  Result := 'Dba' + IvDatabaseName + '.dbo.' + 'Tbl' + IvTableName;
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

    // ds
    Result := DsFD(q, d, IvFbk);
    if not Result then
      Exit;

    // bounds
    IvIdMin := d.Fields[0].AsInteger;
    IvIdMax := d.Fields[1].AsInteger;
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

{$REGION 'TDstRec'}
procedure TDstRec.Filter(IvDs: TDataSet; IvFilter, IvFieldToSearchCsv: string; IvActive: boolean; IvAdditionalExplicitFilter: string);
var
  a: boolean; // active
  f: string; // filter
  v: TStringVector;
begin
  // exit
  if IvDs = nil then
    Exit;
  if not IvDs.Active then
    Exit;
  if IvFilter = '' then
    Exit;

  // safe
  if (IvDs.State = dsEdit) or (IvDs.State = dsInsert) then
    IvDs.Post;

  // active filter
  a := IvActive;
  f := sql.Filter(IvFilter, IvFieldToSearchCsv, IvAdditionalExplicitFilter);
  if iis.Nx(f) then
    a := false;

  // apply
  IvDs.DisableControls;
  try
    if a then begin
      IvDs.Filtered      := false;
      IvDs.FilterOptions := [foCaseInsensitive]; // apparently option is not supported, probably it depend on the dbengine
      IvDs.Filter        := f;
      IvDs.Filtered      := true;
    end else begin
      IvDs.Filtered      := false;
      IvDs.FilterOptions := [];
      IvDs.Filter        := '';
    end;
  finally
    IvDs.EnableControls;
  end;

  //IvDs.FilterOptions := [];
  //IvDs.Filter := 'Product LIKE ''%' + txtFilter.Text + '%'''
  //IvDs.Filter := 'UPPER(Product) LIKE ''%' + UPPERCASE(txtFilter.Text) + '%''';
end;

procedure TDstRec.FilterList(IvDs: TDataSet; IvFilter, IvFieldToSearchCsv, IvFieldToShowInList: string; IvStringList: TStrings);
var
  i: integer;
  v: string;
begin
  // exit
  if IvFilter = '' then
    Exit;

  // listload
  IvDs.DisableControls;
  try
    IvDs.FilterOptions := [foCaseInsensitive];
    IvDs.Filter := sql.Filter(IvFilter, IvFieldToSearchCsv);
    IvDs.Filtered := true;
    if IvDs.RecordCount > 0 then
      IvStringList.Clear;
    while not IvDs.Eof do begin
      i := IvDs.FieldByName('FldId').AsInteger;
      v := Format('%4d - %s', [i, IvDs.FieldByName(IvFieldToShowInList).AsString]);
    //IvStringList.Add(v);                   // addthestring
      IvStringList.AddObject(v, TObject(i)); // addthestringandtheid
      IvDs.Next;
    end;
    IvDs.Filtered := false;
    IvDs.Filter := '';
  finally
    IvDs.EnableControls;
  end;
end;

procedure TDstRec.AppendJson(IvDs: TDataSet; IvSuperObject: superobject.ISuperObject);
var
  f: TField;
  i: superobject.TSuperObjectIter;
begin
  IvDs.Append;
  if superobject.ObjectFindFirst(IvSuperObject, i) then begin
    try
      repeat
        f := IvDs.FindField(i.key);
        if Assigned(f) then
          FieldFromJson(f, i.val);
      until not superobject.ObjectFindNext(i);
    finally
      superobject.ObjectFindClose(i);
    end;
  end;
  IvDs.Post;
end;

function TDstRec.FieldCreate(IvDs: TDataSet; IvFieldType: TFieldType; const IvFld: string; IvSize, IvDisplayWidth: integer): TField;
begin
  Result := DefaultFieldClasses[IvFieldType].Create(IvDs);
  Result.FieldName := IvFld;
  if Result.FieldName = '' then
    Result.FieldName:= 'Fld' + IntToStr(IvDs.FieldCount + 1);
  Result.FieldKind := fkData;
  Result.DataSet := IvDs;
  Result.Name := IvDs.Name + Result.FieldName;
  Result.Size := IvSize;
  if (IvFieldType = ftString) then
    Result.DisplayWidth := IvDisplayWidth;
  if (IvFieldType = ftString) and (IvSize <= 0) then
    raise Exception.CreateFmt('Size not defined for "%s"', [IvFld]);
end;

function TDstRec.DataSetFieldCreate(IvDs: TDataSet; const IvFld: string): TDataSetField;
begin
  Result := TDataSetField(FieldCreate(IvDs, ftDataSet, IvFld));
end;

procedure TDstRec.FieldFromJson(IvField: TField; IvValue: superobject.ISuperObject);
var
  n: string; // fieldname
  d: TDataSet; // nesteddataset
begin
  n := IvField.FieldName;
  case IvField.DataType of
    ftSmallint
  , ftinteger
  , ftWord
  , ftLargeint:          IvField.AsInteger  := IvValue.AsInteger;
    ftFloat
  , ftCurrency
  , ftBCD
  , ftFMTBcd:            IvField.AsFloat    := IvValue.AsDouble;
    ftBoolean:           IvField.AsBoolean  := IvValue.AsBoolean;
    ftDate
  , ftTime
  , ftDateTime
  , ftTimeStamp:         IvField.AsDateTime := IvValue.AsDouble;
    ftDataSet: begin
      d := TDataSetField(IvField).NestedDataSet;
      FromJson(d, IvValue); // nested
    end;
  //ftBytes, ftVarBytes: IvField.Value      := IvValue.AsArray;
  //ftBlob:              IvField.Value      := IvValue.AsArray;
  //ftMemo:              IvField.Value      := IvValue.AsString;
  //ftGraphic:           IvField.Value      := IvValue.AsArray;
    ftUnknown:           IvField.Value      := IvValue.AsString;
  else
                         IvField.AsString   := IvValue.AsString;
  end;
end;

procedure TDstRec.FieldsFromJsonFields(IvDs: TDataSet; IvSuperObject: superobject.ISuperObject);
var
  i: superobject.TSuperObjectIter;
  n: TDataSetField; // nestedfield
  v: superobject.TSuperArray;
begin
  if SuperObject.ObjectFindFirst(IvSuperObject, i) then begin
    try
      repeat
        if (i.val.IsType(stArray)) then begin
          n := DataSetFieldCreate(IvDs, i.key);
          v := i.val.AsArray;
          if (v.Length > 0) then
            FieldsFromJsonFields(n.NestedDataSet, v[0]); // get just the 1st vector item to keep fields names ?
        end else
          FieldCreate(IvDs, sob.SuperTypeToFieldType(i.val.DataType), i.key, sob.SuperTypeToFieldSize(i.val.DataType));
      until not superobject.ObjectFindNext(i);
    finally
      superobject.ObjectFindClose(i);
    end;
  end;
end;

function TDstRec.FieldToJson(IvField: TField; IvNoFld: boolean): string;
var
  v, n, q: string; // jsonvalue, fieldname
begin
  // fieldname
  n := IvField.FieldName;
  if IvNoFld then
    Delete(n, 1, 3);

  // jsonvalue
  v := FieldValueToJsonValue(IvField);

  // end
  Result := '"' + n + '":' + v;
end;

function TDstRec.FieldValueToJsonValue(IvField: TField): string;
var
  n, v, e, q: string; // fieldname, fieldvalue, escaped, escapedandquoted
begin
  if IvField.IsNull then
    Result := 'null'

  else begin
    v := IvField.AsString;
    e := sob.StrEscape(v); //e := StringReplace(e, '\""', '\"', [rfReplaceAll]); // fix \"" --> \"
    q := '"' + e + '"';

    case IvField.DataType of
      // bool
      data.DB.ftBoolean         : Result := v;

      // oid
    //data.DB.ft???             : Result := '{"$oid":"5C0C5A6DA86A3024580003F1"} // --> "_id":{"$oid":"5C0C5A6DA86A3024580003F1"}

      // guid
      data.DB.ftGuid            : Result := AnsiQuotedStr(v, '"');

      // integer
      data.DB.ftByte
    , data.DB.ftWord
    , data.DB.ftLongWord
    , data.DB.ftBCD
    , data.DB.ftFMTBcd
    , data.DB.ftInteger
    , data.DB.ftAutoInc
    , data.DB.ftSmallint
    , data.DB.ftShortint
    , data.DB.ftLargeint        : Result := IvField.Value;

    // float
      data.DB.ftFloat
    , data.DB.ftSingle
    , data.DB.ftCurrency
    , data.DB.ftExtended        : Result := IvField.Value;

      // ansistring
      data.DB.ftFixedChar
    , data.DB.ftString
    , data.DB.ftMemo            : Result := q;

      // string
      data.DB.ftFixedWideChar
    , data.DB.ftWideString
    , data.DB.ftWideMemo        : Result := q;

      // datetime
      data.DB.ftDate
    , data.DB.ftTime
    , data.DB.ftDateTime
    , data.DB.ftTimeStamp
    , data.DB.ftTimeStampOffset : Result := '{"$date":'           + AnsiQuotedStr(DateToISO8601(IvField.AsDateTime, false), '"') + '}';

      // bytes
      data.DB.ftStream          : Result := AnsiQuotedStr('FTSTREAM'      + IvField.Value, '"');
      data.DB.ftBlob            : Result := AnsiQuotedStr('FTBLOB'        + IvField.Value, '"');
      data.DB.ftBytes           : Result := AnsiQuotedStr('FTBYTES'       + IvField.Value, '"');
      data.DB.ftVarBytes        : SetString(Result, PChar(@IvField.AsBytes[0]), Length(IvField.AsBytes)); // try: ByteArrToStr or ByteArrToAscii
      data.DB.ftGraphic         : Result := AnsiQuotedStr('FTGRAPHIC'     + IvField.Value, '"');
      data.DB.ftTypedBinary     : Result := AnsiQuotedStr('FTTYPEDBINARY' + IvField.Value, '"');

      // variant
      data.DB.ftVariant         : Result := AnsiQuotedStr('FTVARIANT'     + IvField.Value, '"');

      // unknown
      data.DB.ftUnknown
    , data.DB.ftADT
    , data.DB.ftArray
    , data.DB.ftConnection
    , data.DB.ftCursor
    , data.DB.ftDataSet
    , data.DB.ftDBaseOle
    , data.DB.ftFmtMemo
    , data.DB.ftIDispatch
    , data.DB.ftInterface
    , data.DB.ftObject
    , data.DB.ftOraBlob
    , data.DB.ftOraClob
    , data.DB.ftOraInterval
    , data.DB.ftOraTimeStamp
    , data.DB.ftParadoxOle
    , data.DB.ftParams
    , data.DB.ftReference       : Result := AnsiQuotedStr('FTUNKNOWN'     + IvField.Value, '"');
    else
                                  Result := q
    end;
  end;
end;

procedure TDstRec.FromJson(IvDs: TDataSet; IvJson: string);
var
  o: superobject.ISuperObject;
begin
  o := superobject.SO(IvJson);
  FromJson(IvDs, o);
end;

procedure TDstRec.FromJson(IvDs: TDataSet; IvSuperObject: superobject.ISuperObject);
var
  i: integer;
  v: superobject.TSuperArray;
begin
  //IvDs.DisableControls;
  //try
    if IvSuperObject.IsType(stArray) then begin
      v := IvSuperObject.AsArray;
      for i := 0 to v.Length-1 do
        AppendJson(IvDs, v.O[i]);
    end else
      AppendJson(IvDs, IvSuperObject);
  //finally
    //IvDs.EnableControls;
  //end;
  //IvDs.First;
end;

procedure TDstRec.RecordDeleteSoft(IvDs: TDataSet; IvFieldToRenameAvailable: string);
var
  i: integer;
begin
  IvDs.Edit;
  for i := 0 to IvDs.FieldCount - 1 do begin
    if      SameText(IvDs.FieldDefs[i].Name, 'FldId') then
      continue
    else if SameText(IvDs.FieldDefs[i].Name, 'FldPId') then
      IvDs.Fields[i].Value := vst.ZZZ_ID
    else if SameText(IvDs.FieldDefs[i].Name, IvFieldToRenameAvailable) then
      IvDs.Fields[i].Value := 'Available'
    else
      IvDs.Fields[i].Value := null;
  end;
  IvDs.Post;
end;

procedure TDstRec.RecordToFldAndValueVectors(IvDs: TDataSet; var IvFldVec: TStringVector; var IvValueVec: TVariantVector; IvNoFld: boolean);
var
  z, i: integer;
begin
  z := IvDs.FieldCount;
  SetLength(IvFldVec, z);
  SetLength(IvValueVec, z);
  for i := 0 to z - 1 do begin
    IvFldVec[i]   := IvDs.Fields[i].FieldName;
    IvValueVec[i] := IvDs.Fields[i].Value;
    if IvNoFld then
      Delete(IvFldVec[i], 1, 3);
  end;
end;

function TDstRec.RecordToJson(IvDs: TDataSet; IvNoFld, IvRowNoAdd: boolean): string; var
  i: integer;
  n: string;
begin
  // record
  Result := '';
  for i := 0 to IvDs.FieldCount-1 do
    Result := Result + ',' + FieldToJson(IvDs.Fields[i], IvNoFld);
  Delete(Result, 1, 1);

  // rowno
  if IvRowNoAdd then
    n := iif.Str(IvNoFld, '"No":', '"FldNo":') + IntToStr(IvDs.RecNo) + ','
  else
    n := '';

  // finalrow
  Result := '{' + n + Result + '}';
end;

procedure TDstRec.RecordToJson(IvDs: TDataSet; var IvSuperObject: superobject.ISuperObject; IvNoFld, IvRowNoAdd: boolean);
var
  s: string;
//j, j2: superobject.ISuperObject;
begin
  s := RecordToJson(IvDs, IvNoFld, IvRowNoAdd);

  IvSuperObject := superobject.SO(s);

  // or build like this
//j := SO;
//j.S['name'] := 'Henri Gourvest';            // string
//j.B['vip'] := TRUE;                         // boolean
//j.O['telephones'] := SA([]);                // object/array
//j.A['telephones'].S[0] := '000000000';      // object/array
//j.A['telephones'].S[1] := '111111111111';   // object/array
//j.I['age'] := 33;                           // integer
//j.D['size'] := 1.83;                        // float
//j.O['addresses'] := SA([]);                 // object/array
//  j2 := SO;
//  j2.S['address'] := 'blabla';
//  j2.S['city'] := 'Metz';
//  j2.I['pc'] := 57000;
//j.A['addresses'].Add(j2);
//  j2.S['address'] := 'blabla';
//  j2.S['city'] := 'Nantes';
//  j2.I['pc'] := 44000;
//j.A['addresses'].Add(j2);
//j := nil;
//j2 := nil;
end;

procedure TDstRec.ToCsv(IvDs: TDataSet; var IvCsv: string; IvNoFld, IvRowNoAdd, IvHeaderAdd: boolean);
var
  r, c: integer;
  l: string;
begin
  // init
  IvCsv := '';
  if IvDs.IsEmpty or (not Assigned(IvDs.Fields)) then
    Exit;

  // header
  if IvHeaderAdd then begin
    l := '';
    for c := 0 to IvDs.FieldCount - 1 do
      l := l + ',' + IvDs.Fields[c].FieldName; // str.QuoteDbl(IvDs.Fields[c].FieldName)

    if IvRowNoAdd then
      l := 'FldNo' + l
    else
      Delete(l, 1, 1);

    if IvNoFld then
      IvCsv := StringReplace(l, 'Fld', '', [rfReplaceAll])
    else
      IvCsv := l;
  end;

  // body
  r := 0;
  IvDs.First;
  while not IvDs.Eof do begin
    Inc(r);
    l := '';
    for c := 0 to IvDs.FieldCount - 1 do
      l := l + ',' + IvDs.Fields[c].AsString; // str.QuoteDbl(IvDs.Fields[c].FieldName)

    if IvRowNoAdd then
      l := IntToStr(r) + l
    else
      Delete(l, 1, 1);

    IvCsv := IvCsv + sLineBreak + l;

    IvDs.Next;
  end;

  // remove 1st nl
  if not IvHeaderAdd then
    Delete(IvCsv, 1, 2);

  // end
  IvDs.First;
end;

procedure TDstRec.ToTxt(IvDs: TDataSet; var IvTxt: string; IvNoFld, IvRowNoAdd, IvHeaderAdd: boolean);
begin
  ToCsv(IvDs, IvTxt, IvNoFld, IvRowNoAdd, IvHeaderAdd);
end;

procedure TDstRec.ToHtml(IvDs: TDataSet; var IvHtml: string; IvNoFld, IvRowNoAdd, IvHeaderAdd: boolean);
var
  r, c: integer;
  l: string;
begin
  // exit
  if not Assigned(IvDs.Fields) then begin
    IvHtml := 'No Data (dataset not assigned)';
    Exit;
  end;
  if IvDs.IsEmpty or (not Assigned(IvDs.Fields)) then begin
    IvHtml := 'No Data (dataset is empty)';
    Exit;
  end;

  // header
  if IvHeaderAdd then begin
    l := '';
    for c := 0 to IvDs.FieldCount - 1 do
      l := l + '<th>' + IvDs.Fields[c].FieldName + '</th>';

    if IvRowNoAdd then
      l := '<th>FldNo</th>' + l;

    if IvNoFld then
      IvHtml := StringReplace(l, 'Fld', '', [rfReplaceAll]);

    IvHtml := '<tr>' + l + '</tr>';
  end;

  // body
  r := 0;
  IvDs.First;
  while not IvDs.Eof do begin
    Inc(r);
    l := '';
    for c := 0 to IvDs.FieldCount - 1 do
      l := l + '<td>' + IvDs.Fields[c].AsString + '</td>';

    if IvRowNoAdd then
      l := '<td>' + IntToStr(r) + '</td>' + l;

    IvHtml := IvHtml + sLineBreak + '<tr>' + l + '</tr>';

    IvDs.Next;
  end;

  // finish
  IvHtml := '<table>' + sLineBreak + IvHtml + sLineBreak + '</table>';

  // end
  IvDs.First;
end;

function TDstRec.ToJson(IvDs: TDataSet; var IvJson: string; IvNoFld, IvRowNoAdd: boolean): integer;
begin
  // init
  Result := 0;
  IvJson := '';

  // first
  if not IvDs.Bof then
    IvDs.First;

  // rows
  while not IvDs.Eof do begin
    IvJson := IvJson + ',' + RecordToJson(IvDs, IvNoFld, IvRowNoAdd);
    IvDs.Next;
    Inc(Result);
  end;
  IvDs.First;
  if Length(IvJson) = 0 then
    Exit;

  //strip1stcomma
  Delete(IvJson, 1, 1);
end;

procedure TDstRec.ToJsonKeyValue(IvDs: TDataSet; var IvJson: string; IvNoFld: boolean);
var
  o: boolean; // onefieldonly
  k, v: string; // key, value
begin
  // init
  IvJson := '';
  o := IvDs.FieldCount < 2;

  // exit
//if o then
  //Exit;

  // first
  if not IvDs.Bof then
    IvDs.First;

  // rows
  while not IvDs.Eof do begin
    k := IvDs.Fields[0].AsString;
    if o then
      v := k
    else
      v := IvDs.Fields[1].AsString;
    IvJson := IvJson + ',' + Format('"%s": "%s"', [k, v]);
    IvDs.Next;
  end;
  IvDs.First;

  //strip1stcomma
  if Length(IvJson) > 0 then
    Delete(IvJson, 1, 1);

  // keyvalue
  IvJson := '{' + IvJson + '}'; // may returns {}
end;

procedure TDstRec.ToJsonTotalAndRows(IvDs: TDataSet; var IvJson: string; IvNoFld, IvRowNoAdd: boolean);
var
  z: integer;
begin
  // raw
  z := ToJson(IvDs, IvJson, IvNoFld, IvRowNoAdd);

  // total&rows
  IvJson :=
    '{'
  +  '"total":' + IntToStr(z)
  + ',"rows":[' + IvJson + ']'
  + '}'
  ;
end;

procedure TDstRec.ToJsonVector(IvDs: TDataSet; var IvJson: string; IvNoFld, IvRowNoAdd: boolean);
begin
  // raw
  ToJson(IvDs, IvJson, IvNoFld, IvRowNoAdd);

  // vector
  IvJson := '[' + IvJson + ']';
end;
{$ENDREGION}

{$REGION 'TEdiRec'}
procedure TEdiRec.LoadFrom(IvEditable: boolean; IvSelect, IvInsert, IvUpdate, IvDelete, IvJson: string);
var
  l: TStringList;
begin
  // new
  Editable := IvEditable;
  Select   := IvSelect  ;
  Insert   := IvInsert  ;
  Update   := IvUpdate  ;
  Delete   := IvDelete  ;
//EditIni  := IvEditIni ; // old to remove
  Json     := IvJson    ; // new substitute

  // exit
//  if Trim(IvEditIni) = '' then
//    Exit;

  // legacy
  {
  l := TStringList.Create;
  try
    l.Text := EditIni;
    ReportId          := l.Values['EditReportId'].ToInteger;      // ReportId=49
    DatasetName       := l.Values['EditDatasetName'];             // DatasetName=Main
    InsertIfNotExists := l.Values['InsertIfNotExists'].ToBoolean; // InsertIfNotExists=true
    Table             := l.Values['EditTable'];                   // EditTable=DbaPerson.dbo.TblPerson
    KeyFieldList      := l.Values['EditKeyFieldList'];            // EditKeyFieldList=["FldId","FldOwner"]
    OwnerField        := l.Values['EditOwnerField'];              // EditOwnerField=
    OneWayField       := l.Values['EditOneWayField'];             // EditOneWayField=FldState
    OneWayRange       := l.Values['EditOneWayRange'];             // EditOneWayRange=["Active","Inactive"]
    FieldList         := l.Values['EditFieldList'];               // EditFieldList=["FldSurname","FldName","FldGender","FldNationality","FldLanguage","FldSsn","FldPhone","FldMobile","FldEmail"]
    ValueRange        := l.Values['EditValueRange'];              // EditValueRange=[]
    UpdatedField      := l.Values['EditUpdatedField'];            // EditUpdatedField=
    EnabledStateList  := l.Values['EditEnabledStateList'];        // EditEnabledStateList=["Active","OnHold"]
  finally
    l.Free;
  end;
  }
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

{$REGION 'THtmRec'}

  {$REGION 'attr'}
function THtmRec.AttrIdName(IvCo: string): string;
begin
  Result := iif.ExF(IvCo, ' id="%s" name="%s"', [IvCo, IvCo]);
end;

function THtmRec.AttrClasse(IvClassVec: array of string): string;
var
  i: integer;
begin
  if vec.Nx(IvClassVec) then
    Result := ''
  else begin
    for i := Low(IvClassVec) to High(IvClassVec) do begin
      if iis.Nx(IvClassVec[i]) then
        continue;
      Result := Result + ' ' + IvClassVec[i];
    end;
    if iis.Ex(Result) then
      Result := Format(' class="%s"', [Result.Trim]);
  end;
end;

function THtmRec.AttrStyle(IvValue: string): string;
begin
  Result := iif.ExF(IvValue, ' style="%s"', [IvValue]);
end;

function THtmRec.AttrPlaceholder(IvValue: string): string;
begin
  Result := iif.ExF(IvValue, ' placeholder="%s"', [IvValue]);
end;
  {$ENDREGION}

  {$REGION 'elements'}
function THtmRec.A(IvHref, IvText: string): string;
begin
  Result :=           sLineBreak + Format('<a href="%s">', [IvHref])
                    + sLineBreak +   IvText
                    + sLineBreak + '</a>';
end;

function THtmRec.A(IvHref, IvFormat: string; IvVec: array of TVarRec): string;
begin
  Result := A(IvHref, Format(IvFormat, IvVec));
end;

function THtmRec.B(IvN: integer): string;
var
  i: integer;
begin
  Result :='';
  for i := 1 to IvN do
    Result := Result + '<br>';
end;

function THtmRec.C(IvComment: string): string;
begin
  Result :=           sLineBreak + Format('<!-- %s -->', [IvComment])
end;

function THtmRec.H(IvLevel: integer; IvContent, IvClass: string): string;
begin
  Result :=           sLineBreak + Format('<h%d%s>', [IvLevel, AttrClasse([iif.NxD(IvClass, '')])]) // w3-text-theme
                    + sLineBreak +   IvContent
                    + sLineBreak + Format('</h%d>', [IvLevel]);
end;

function THtmRec.H(IvLevel: integer; IvFormat: string; IvVec: array of TVarRec; IvClass: string): string;
begin
  Result := H(IvLevel, Format(IvFormat, IvVec));
end;

function THtmRec.P(IvContent, IvClass: string): string;
begin
  Result :=           sLineBreak + Format('<p%s>', [AttrClasse([iif.NxD(IvClass, '')])]) // w3-text-theme
                    + sLineBreak +   IvContent
                    + sLineBreak + '</p>';
end;

function THtmRec.P(IvFormat: string; IvVec: array of TVarRec; IvClass: string): string;
begin
  Result := P(Format(IvFormat, IvVec), IvClass);
end;

function THtmRec.D(IvContent, IvClass, IvComment: string): string;
begin
  Result :=           sLineBreak + Format('<div%s>', [AttrClasse([IvClass])]) + iif.ExR(IvComment, C(IvComment))
                    + sLineBreak +   IvContent
                    + sLineBreak + '</div>' + iif.ExR(IvComment, C(IvComment + ' End'));
end;

function THtmRec.D(IvFormat: string; IvVec: array of TVarRec; IvClass, IvComment: string): string;
begin
  Result := D(Format(IvFormat, IvVec), IvClass, IvComment);
end;

function THtmRec.Container(IvContent, IvClass: string): string;
begin
  Result :=           sLineBreak + Format('<div class="w3-container"%s>', [AttrClasse([IvClass])])
                    + sLineBreak +   IvContent
                    + sLineBreak + '</div>';
end;

function THtmRec.Panel(IvContent, IvClass: string): string;
begin
  Result :=           sLineBreak + Format('<div class="w3-panel"%s>', [AttrClasse([IvClass])])
                    + sLineBreak +   IvContent
                    + sLineBreak + '</div>';
end;

function THtmRec.Accordion(IvContent, IvClass: string): string;
begin
  Result :=
    sLineBreak + '<!-- Accordion -->'
  + sLineBreak + '<div class="w3-card w3-round">'
  + sLineBreak + '  <div class="w3-white">'

  + sLineBreak + '    <button onclick="w3AccordionToggle(''CoAccordion1'')" class="w3-button w3-block w3-theme-l1 w3-left-align"><i class="fa fa-circle-o-notch fa-fw w3-margin-right"></i> My Groups</button>'
  + sLineBreak + '    <div id="CoAccordion1" class="w3-hide w3-container">'
  + sLineBreak + '      <p>Some text..</p>'
  + sLineBreak + '    </div>'

  + sLineBreak + '    <button onclick="w3AccordionToggle(''CoAccordion2'')" class="w3-button w3-block w3-theme-l1 w3-left-align"><i class="fa fa-calendar-check-o fa-fw w3-margin-right"></i> My Events</button>'
  + sLineBreak + '    <div id="CoAccordion2" class="w3-hide w3-container">'
  + sLineBreak + '      <p>Some other text..</p>'
  + sLineBreak + '    </div>'

  + sLineBreak + '    <button onclick="w3AccordionToggle(''CoAccordion3'')" class="w3-button w3-block w3-theme-l1 w3-left-align"><i class="fa fa-users fa-fw w3-margin-right"></i> My Photos</button>'
  + sLineBreak + '    <div id="CoAccordion3" class="w3-hide w3-container">'
  + sLineBreak + '      <div class="w3-row-padding">'
  + sLineBreak + '        <br>'
  + sLineBreak + '        <div class="w3-half">'
  + sLineBreak + '          <img src="http://prodimg.ai.lfoundry.com/emppics/353473.jpg" alt="" class="w3-margin-bottom" style="width:100%">'
  + sLineBreak + '        </div>'
  + sLineBreak + '        <div class="w3-half">'
  + sLineBreak + '          <img src="http://prodimg.ai.lfoundry.com/emppics/353992.jpg" alt="" class="w3-margin-bottom" style="width:100%">'
  + sLineBreak + '        </div>'
  + sLineBreak + '        <div class="w3-half">'
  + sLineBreak + '          <img src="http://prodimg.ai.lfoundry.com/emppics/353234.jpg" alt="" class="w3-margin-bottom" style="width:100%">'
  + sLineBreak + '        </div>'
  + sLineBreak + '        <div class="w3-half">'
  + sLineBreak + '          <img src="http://prodimg.ai.lfoundry.com/emppics/784629.jpg" alt="" class="w3-margin-bottom" style="width:100%">'
  + sLineBreak + '        </div>'
  + sLineBreak + '        <div class="w3-half">'
  + sLineBreak + '          <img src="http://prodimg.ai.lfoundry.com/emppics/810643.jpg" alt="" class="w3-margin-bottom" style="width:100%">'
  + sLineBreak + '        </div>'
  + sLineBreak + '        <div class="w3-half">'
  + sLineBreak + '          <img src="http://prodimg.ai.lfoundry.com/emppics/784479.jpg" alt="" class="w3-margin-bottom" style="width:100%">'
  + sLineBreak + '        </div>'
  + sLineBreak + '      </div>'
  + sLineBreak + '    </div>'

  + sLineBreak + '  </div>'
  + sLineBreak + '</div>'
end;

function THtmRec.Td(IvContent, IvClass: string): string;
begin
  Result :=                        Format('<td%s>', [AttrClasse([IvClass])])
                                 +   IvContent
                                 + '</td>';
end;

function THtmRec.Th(IvContent, IvClass: string): string;
begin
  Result :=                        Format('<th%s>', [AttrClasse([IvClass])])
                                 +   IvContent
                                 + '</th>';
end;

function THtmRec.Tc(IvContent, IvClass: string): string;
begin
  Result :=           sLineBreak + Format('<caption%s>', [AttrClasse([IvClass])])
                                 +   IvContent
                                 + '</caption>';
end;

function THtmRec.Tr(IvContent, IvClass: string): string;
begin
  Result :=           sLineBreak + Format('<tr%s>', [AttrClasse([IvClass])])
                    + sLineBreak +   IvContent
                    + sLineBreak + '</tr>';
end;

function THtmRec.Table(IvContent, IvClass, IvStyle, IvCo, IvCaption: string): string;
var
  c: string;
begin
  c := iif.NxD(IvClass, 'w3-table w3-bordered w3-small');
  Result :=           sLineBreak + Format('<table%s%s%s>', [AttrClasse([c]), AttrStyle(IvStyle), AttrIdName(IvCo)])
                                 +   IvCaption // iif.Str(IvCaption.Contains('/caption'), IvCaption, Tc(IvCaption))
                                 +   IvContent
                    + sLineBreak + '</table>';
end;

function THtmRec.TableResp(IvContent, IvClass, IvStyle, IvCo, IvCaption: string): string;
begin
  Result :=           sLineBreak + '<div class="w3-responsive">'
                                 + Table(IvContent, IvClass, IvStyle, IvCo, IvCaption)
                    + sLineBreak + '</div>';
end;

function THtmRec.Fa(IvIcon, IvStyle: string): string;
begin
  Result := Format('<i class="fa fa-%s"%s></i>', [IvIcon, AttrStyle(IvStyle)]);
end;
  {$ENDREGION}

  {$REGION 'pageparts'}
function THtmRec.Head(IvTitle, IvHead, IvCss, IvJs: string): string;
begin
  Result :=           sLineBreak + '<!-- Head -->'
                    + sLineBreak + '<head>'
                    + sLineBreak + '<title>' + ifthen(false, sys.ACRONYM, org.Organization) + ' ' + IvTitle + '</title>'
                    + sLineBreak + '<meta charset="UTF-8">'
                    + sLineBreak + '<meta name="viewport" content="width=device-width, initial-scale=1">'
                    + sLineBreak + '<meta name="description" content="Yield Management System - integrated framework for product yield enhancement with unified data collection, storage, analysis, classification, knowledge, sharing & decision support" />'
                    + sLineBreak + '<meta name="author" content="puppadrillo" />'
                    + sLineBreak + '<link rel="icon" href="' + org.IconUrl + '" type="image/png">'
                    + sLineBreak + '<link rel="stylesheet" href="/Include/w3/w3.css">'
                    + sLineBreak + '<link rel="stylesheet" href="/Include/w3/w3-theme-[RvSysParam(Theme, white)].css">' // white grey dark-grey blue-grey
                  //+ sLineBreak + '<link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Open+Sans">'
                  //+ sLineBreak + '<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Inconsolata:wght@500&display=swap">'
                  //+ sLineBreak + '<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Roboto+Mono&display=swap">'
                    + sLineBreak + '<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Play&display=swap">'
                    + sLineBreak + '<link rel="stylesheet" href="/Include/font-awesome/4.7.0/css/font-awesome.min.css">'
                    + sLineBreak + '<link rel="stylesheet" href="/Include/wks/wks.css">'
                    + sLineBreak + IvHead
                    + sLineBreak + '<style>'
                  //+ sLineBreak + 'html, body, h1, h2, h3, h4, h5 {font-family: "Open Sans", sans-serif}'
                  //+ sLineBreak + 'html, body, h1, h2, h3, h4, h5 {font-family: "Inconsolata", monospace;}'
                  //+ sLineBreak + 'html, body, h1, h2, h3, h4, h5 {font-family: "Roboto Mono", monospace;}'
                    + sLineBreak + 'html, body, h1, h2, h3, h4, h5 {font-family: "Play", sans-serif;}'
                    + sLineBreak + '</style>'
                    + sLineBreak + IvCss
                  //+ sLineBreak + '<script src="/Include/jquery/3.5.1/jquery.min.js"></script>'
                    + sLineBreak + '<script src="/Include/canvasjs/2.3.1/canvasjs.min.js"></script>'
                    + sLineBreak + '<script src="/Include/w3/w3.js"></script>'
                    + sLineBreak + '<script src="/Include/wks/wks.js"></script>'
                    + sLineBreak + '<script>'
                    + sLineBreak + IvJs
                    + sLineBreak + '</script>'
                    + sLineBreak + '</head>';
end;

function THtmRec.Navbar(IvContent: string): string;
var
  a, b: string;
begin
//a := 'domBlockToggle(''CoSidebarLeft'')';
  a := 'w3SidebarLeftToggle(''CoMiddleBlock'', ''CoSidebarLeft'', ''200px'')';
  b := wre.ScriptName; // /WksIsapiProject.dll
  Result :=           sLineBreak + '<!-- Navbar -->'
                    + sLineBreak + '<div>' // class="w3-top"                            // w3-border-bottom w3-border-theme
                    + sLineBreak + ' <div class="w3-bar w3-theme-d1 w3-left-align w3-large">'
                    + sLineBreak + '  <a class="w3-bar-item w3-button w3-hide-medium w3-hide-large w3-right w3-padding-large w3-hover-white w3-large w3-theme-d2" href="javascript:void(0);" onclick="w3NavbarOpen()"><i class="fa fa-bars"></i></a>'
                    + sLineBreak + '  <div class="w3-bar-item w3-button w3-hover-white w3-theme-d1">' // w3-padding-large  style="padding:4px 16px"
                    + sLineBreak + '    <a href="javascript:void(0);" onclick="' + a + '"><img src="' + org.LogoUrl + '" alt="" class="w3-image" style="height:35px;"></a>'
                  //+ sLineBreak + '    <a href="javascript:void(0);" onclick="pageReload()"><img src="' + sys.LOGO_URL + '" alt="" class="w3-image" style="height:18px"></a>'
                    + sLineBreak + '  </div>'
                    ;
                  if obj.DbaSwitchGet('System', 'ShowNavIcons', false) then
  Result := Result  + sLineBreak + '  <a href="' + b + '/Home" class="w3-bar-item w3-button w3-hide-small w3-padding-large w3-hover-white" title="Home"><i class="fa fa-home"></i></a>'
                    + sLineBreak + '  <a href="' + b + '/Social" class="w3-bar-item w3-button w3-hide-small w3-padding-large w3-hover-white" title="Social"><i class="fa fa-paw"></i></a>'
                    + sLineBreak + '  <a href="' + b + '/Account" class="w3-bar-item w3-button w3-hide-small w3-padding-large w3-hover-white" title="Account Settings"><i class="fa fa-user"></i></a>'
                    + sLineBreak + '  <a href="' + b + '/News" class="w3-bar-item w3-button w3-hide-small w3-padding-large w3-hover-white" title="News"><i class="fa fa-globe"></i></a>'
                    + sLineBreak + '  <a href="' + b + '/Message" class="w3-bar-item w3-button w3-hide-small w3-padding-large w3-hover-white" title="Messages"><i class="fa fa-envelope"></i></a>'
                    + sLineBreak + '  <a href="' + b + '/Notification" class="w3-bar-item w3-button w3-hide-small w3-padding-large w3-hover-white" title="Notifications"><i class="fa fa-bell"></i><span class="w3-badge w3-right w3-small w3-green">3</span></a>'
                  //+ sLineBreak + '  <div class="w3-dropdown-hover w3-hide-small">'
                  //+ sLineBreak + '    <a href="' + b + '/Notification" class="w3-button w3-padding-large" title="Notifications"><i class="fa fa-bell"></i><span class="w3-badge w3-right w3-small w3-green">3</span></a>'
                  //+ sLineBreak + '    <div class="w3-dropdown-content w3-card-4 w3-bar-block" style="width:300px">'
                  //+ sLineBreak + '      <a href="#" class="w3-bar-item w3-button">One new friend request</a>'
                  //+ sLineBreak + '      <a href="#" class="w3-bar-item w3-button">John Doe posted on your wall</a>'
                  //+ sLineBreak + '      <a href="#" class="w3-bar-item w3-button">Jane likes your post</a>'
                  //+ sLineBreak + '    </div>'
                  //+ sLineBreak + '  </div>'
                    ;
                  if obj.DbaSwitchGet('System', 'ShowUserAvatar', false) then
  Result := Result  + sLineBreak + '  <a href="javascript:void(0);" onclick="domBlockToggle(''CoSidebarRight'')" class="w3-bar-item w3-button w3-hide-small w3-right w3-hover-white" style="padding:4px 16px" title="' + wre.Username + '">'
                    + sLineBreak + '    <img src="/User/G/giarussi/giarussi.png" alt="" class="w3-circle" style="height:43px;width:43px" alt="' + wre.Username + '">'
                    + sLineBreak + '  </a>'
                    ;
  Result := Result  + sLineBreak + ' </div>'
                    + sLineBreak + '</div>'
                    + sLineBreak + '<!-- Navbar on small screens -->'
                    + sLineBreak + '<div id="CoNavbar" class="w3-bar-block w3-theme-d2 w3-hide w3-hide-large w3-hide-medium w3-large">'
                    + sLineBreak + '  <a href="#" class="w3-bar-item w3-button w3-padding-large">Link 1</a>'
                    + sLineBreak + '  <a href="#" class="w3-bar-item w3-button w3-padding-large">Link 2</a>'
                    + sLineBreak + '  <a href="#" class="w3-bar-item w3-button w3-padding-large">Link 3</a>'
                    + sLineBreak + '  <a href="#" class="w3-bar-item w3-button w3-padding-large">My Profile</a>'
                    + sLineBreak + '</div>'
                    ;
end;

function THtmRec.SidebarLeft(IvContent: string): string;
var
  i, j, l, m: integer; // pageorgid, menuid, counter, menulev
  a, c, k: string; // caption
  d: TFDDataset;
  x: TDbaCls;
begin
  x := TDbaCls.Create(FDManager);
  try
    // ids
    i := x.HIdFromPath('DbaPage.dbo.TblPage', 'FldPage', org.TreePath);
    j := wre.IntGet('CoMenuId', -1);
    if j = -1 then
      j := i;

    // ds
    x.HParentsItemChildsDs('DbaPage.dbo.TblPage', 'FldPage, FldMenu', j, d, k);

    // skip
    d.Next; // Root
    d.Next; //   Organization
    d.Next; //     A

    // loop
    m := 0;
    for l := 3 to d.RecordCount - 1 do begin
      c := iif.NxD(d.FieldByName('FldMenu').AsString, d.FieldByName('FldPage').AsString);

      if d.FieldByName('FldState').AsString = sta.Active.Key then begin
        if          m = 0 then begin
          a := a + sLineBreak + Format('<a href="%s/Page?CoId=%d&CoMenuId=%d" class="w3-bar-item w3-button w3-theme-d2" style="padding:14px 8px 15px 8px">%s</a>', [
            wre.ScriptName
          , d.FieldByName('FldId').AsInteger
          , d.FieldByName('FldId').AsInteger
          , c
          ]);
          m := 1; // justonetime

        end else if d.FieldByName('FldLevelRel').AsInteger <= 0 then begin
          a := a + sLineBreak + Format('<a href="%s/Page?CoId=%d&CoMenuId=%d" class="w3-bar-item w3-button w3-theme-' + ifthen(d.FieldByName('FldLevelRel').AsInteger = 0, 'd2', 'd2') + '">%s</a>', [
            wre.ScriptName
          , d.FieldByName('FldId').AsInteger
          , d.FieldByName('FldId').AsInteger
          , c
          ]);

        end else begin
          a := a + sLineBreak + Format('<a href="%s/Page?CoId=%d&CoMenuId=%d" class="w3-bar-item w3-button w3-theme-d1 w3-small" style="padding: 4px 16px">%s%s</a>', [
            wre.ScriptName
          , d.FieldByName('FldId').AsInteger
          , iif.Int(d.FieldByName('FldChilds').AsInteger > 0, d.FieldByName('FldId').AsInteger, j)
          , c
          , ifthen(d.FieldByName('FldChilds').AsInteger > 0, '<i class="fa fa-caret-right w3-right"></i>', '')
          ]);
        end;
      end;

      d.Next;
    end;

    // html
    Result :=           sLineBreak + '<!-- Sidebar Left -->' // w3-animate-left w3-card w3-border-right w3-border-theme
                      + sLineBreak + '<div class="w3-sidebar w3-bar-block w3-theme-d1 w3-scrollbar wks-rtl" style="' + ifthen(wre.BoolGet('CoSidebarLeftShow', false, true), 'width:200px', 'display:none') + ';" id="CoSidebarLeft">'
                                   + a
                      + sLineBreak + '</div>';
  finally
    FreeAndNil(d);
    FreeAndNil(x);
  end;
end;

function THtmRec.SidebarRight(IvContent: string): string;
const
  S = 'width:16px;text-align:center;margin-right:16px';
begin
  Result :=            sLineBreak + '<!-- Sidebar Right -->'
                     + sLineBreak + '<div class="w3-sidebar w3-bar-block w3-card w3-animate-right w3-theme-d1" style="display:none;right:0" id="CoSidebarRight">'
                     + sLineBreak + '  <div style="margin: 0;padding: 14px 8px 15px 8px;float: left;">Shortcuts</div><button onclick="domBlockClose(''CoSidebarRight'')" class="w3-button w3-large w3-right">&times;</button>';
  if wre.CookieGet('CoSession', '') = '1234' then
    Result := Result + sLineBreak + '  <a href="' + wre.ScriptName + '/Logout" class="w3-bar-item w3-button">'       + Fa('sign-out', S) + 'Logout</a>'
  else
    Result := Result + sLineBreak + '  <a href="' + wre.ScriptName + '/Login" class="w3-bar-item w3-button">'        + Fa('sign-in' , S) + 'Login</a>';
  Result := Result   + sLineBreak + '  <a href="' + wre.ScriptName + '/Home" class="w3-bar-item w3-button">'         + Fa('home'    , S) + 'Home</a>'
                     + sLineBreak + '  <a href="' + wre.ScriptName + '/Social" class="w3-bar-item w3-button">'       + Fa('paw'     , S) + 'Social</a>'
                     + sLineBreak + '  <a href="' + wre.ScriptName + '/Account" class="w3-bar-item w3-button">'      + Fa('user'    , S) + 'Account</a>'
                     + sLineBreak + '  <a href="' + wre.ScriptName + '/News" class="w3-bar-item w3-button">'         + Fa('globe'   , S) + 'News</a>'
                     + sLineBreak + '  <a href="' + wre.ScriptName + '/Message" class="w3-bar-item w3-button">'      + Fa('envelope', S) + 'Messages</a>'
                     + sLineBreak + '  <a href="' + wre.ScriptName + '/Notification" class="w3-bar-item w3-button">' + Fa('bell'    , S) + 'Notifications</a>'
                     + sLineBreak + '  <a href="' + wre.ScriptName + '/Info" class="w3-bar-item w3-button">'         + Fa('info'    , S) + 'Info</a>'
                     + sLineBreak + '  <a href="' + wre.ScriptName + '/Test" class="w3-bar-item w3-button">'         + Fa('bug'     , S) + 'Test</a>'
                     + sLineBreak + '</div>';
end;

function THtmRec.Content(IvContent: string; IvContainerOn: boolean): string;
begin
  Result :=           sLineBreak + '<!-- Content -->'
                    + ifthen(IvContainerOn, sLineBreak + '<div class="w3-container w3-content" style="max-width:1900px">') // style="max-width:1400px;margin-top:50px" notice the margin-top !
                    + sLineBreak + IvContent // Container()
                    + ifthen(IvContainerOn, sLineBreak + '</div>');
end;

function THtmRec.Header(IvContent, IvDebug: string): string;
begin
  Result := IvContent;
end;

function THtmRec.Footer(IvContent, IvDebug: string): string;
var
  c: string;
begin
  c := rva.Rv(IvContent); // because might be empty
  Result := '';
  if c <> ''       then Result :=
                      sLineBreak + '<!-- Footer -->'
                    + sLineBreak + '<footer class="w3-container w3-theme-d4 w3-padding-16">'
                    + sLineBreak + '  <h5>' + IvContent + '</h5>'
                    + sLineBreak + '</footer>';

  if IvDebug <> '' then Result := Result
                    + sLineBreak + '<footer class="w3-container w3-theme-d2">'
                    + sLineBreak + '  <p>' + IvDebug + '</p>'
                    + sLineBreak + '</footer>';

  if obj.DbaSwitchGet('System', 'ShowPoweredBy', false) then Result := Result
                    + sLineBreak + '<footer class="w3-container w3-theme-d1">'
                    + sLineBreak + '  <p class="w3-center">Powered by <a href="' + sys.Url + '" target="_blank"> <img src="' + sys.IconUrl() + '" alt="" class="w3-image" style="height:24px" title="' + sys.NAME + '"></a></p>'
                    + sLineBreak + '</footer>';

  Result := Result
                    + sLineBreak + '<footer class="w3-container w3-theme-d1">'
                    + sLineBreak + '  <p>$RenderingTime$</p>' // this will be replace at the very end in all.AfterDispatch
                    + sLineBreak + '</footer>';
end;

function THtmRec.BottomFixed(): string;
begin
  Result :=                        '<!-- BottomFixed -->'                                                                                                                     //#[RvOrganizationFgColor()]
                  //+ sLineBreak + '<div id="CoGoToTopButton" onclick="GoToTopFunction()" style="display:none;position:fixed;width:40px;height:40px;border-radius:3px;background:orange;bottom:12px;right:20px;cursor:pointer;z-index:99;">'
                  //+ sLineBreak + '  <div id="CoGoToTopArrow" style="transform:rotate(45deg);border-top:5px solid #[RvOrganizationBgColor()];border-left:5px solid #[RvOrganizationBgColor()];border-bottom:none;border-right:none;width:10px;height:10px;margin:15px auto"></div>'
                  //+ sLineBreak + '</div>'
                    + sLineBreak + '<button class="w3-button w3-circle w3-theme-d1 w3-card-4" id="CoGoToTopButton" onclick="GoToTopFunction();" style="display:none;padding:0px;position:fixed;width:40px;height:40px;bottom:20px;right:20px;"><i class="fa fa-chevron-up"></i></button>'
                    + sLineBreak + '<script>'
                    + sLineBreak + 'window.onscroll = function() {ScrollFunction()};' // when the user scrolls down 20px from the top of the document, show the button
                    + sLineBreak + 'function ScrollFunction() {'
                    + sLineBreak + '  if (document.body.scrollTop > 200 || document.documentElement.scrollTop > 200) {'
                    + sLineBreak + '    document.getElementById("CoGoToTopButton").style.display = "block";'
                    + sLineBreak + '  } else {'
                    + sLineBreak + '    document.getElementById("CoGoToTopButton").style.display = "none";'
                    + sLineBreak + '  }'
                    + sLineBreak + '}'
                    + sLineBreak + 'function GoToTopFunction() {' // when the user clicks on the button, scroll to the top of the document
                    + sLineBreak + '  document.body.scrollTop = 0;'
                    + sLineBreak + '  document.documentElement.scrollTop = 0;'
                    + sLineBreak + '}'
                    + sLineBreak + '</script>'
end;
  {$ENDREGION}

  {$REGION 'pages'}
function THtmRec.Page(IvTitle, IvContent, IvHead, IvCss, IvJs, IvHeader, IvFooter: string; IvContainerOn: boolean; IvBuilder: integer): string;
var
  b: TStringBuilder;
  t: TTextWriter;
  d: string; // debug
begin
  // trivialconcat
  if IvBuilder = 0 then begin
    d := ''; // 'Page assembled with trivial string concatenation'
    Result :=                      '<!DOCTYPE html>'
                    + sLineBreak + '<html lang="en-US">'
                    + sLineBreak +    Head(IvTitle, IvHead, IvCss, IvJs)
                    + sLineBreak + '<body>' // class="w3-theme"
                    + sLineBreak +    SidebarLeft('')
                    + sLineBreak +    SidebarRight('')
                    + sLineBreak +   '<!-- MiddleBlock -->'
                    + sLineBreak +   '<div id="CoMiddleBlock"' + ifthen(wre.BoolGet('CoSidebarLeftShow', false, true), ' style="margin-left:200px"') + '>'
                    + sLineBreak +      Navbar('')
                    + sLineBreak +      Header(IvHeader, d)
                    + sLineBreak +      Content(IvContent, IvContainerOn)
                    + sLineBreak +      Footer(IvFooter, d)
                    + sLineBreak +   '</div>'
                    + sLineBreak +    BottomFixed()
                    + sLineBreak +    BootScript()
                    + sLineBreak + '</body>'
                    + sLineBreak + '</html>';

    // stringbuilder
  end else if IvBuilder = 1 then begin
    d := ''; // 'Page assembled with stringbuilder'
    b := TStringBuilder.Create;
    try
      b.Append('<!DOCTYPE html>');
      b.Append('<html lang="en-US">');
      b.Append(Head(IvTitle));
      b.Append('<body class="w3-theme">');
      b.Append(Navbar(''));
      b.Append(Content(IvContent));
      b.Append(Footer(IvFooter, d));
      b.Append(BootScript());
      b.Append('</body>');
      b.Append('</html>');
      Result := b.ToString;
    finally
      b.Free;
    end;

  // textwriter
//end else if IvBuilder = 2 then begin
//  d := ''; // 'Page assembled with textwriter'
//  t := TTextWriter.CreateOwnedStream;
//  try
//    t.AddString(StringToUTF8('<!DOCTYPE html>'));
//    t.AddString(StringToUTF8('<html lang="en-US">'));
//    t.AddString(StringToUTF8(Head(IvTitle)));
//    t.AddString(StringToUTF8('<body class="w3-theme">'));
//    t.AddString(StringToUTF8(Navbar));
//    t.AddString(StringToUTF8(Content(IvContent)));
//    t.AddString(StringToUTF8(Footer(IvFooter, d)));
//    t.AddString(BootScript);
//    t.AddString(StringToUTF8('</body>'));
//    t.AddString(StringToUTF8('</html>'));
//    Result := UTF8ToString(t.Text);
//  finally
//    t.Free;
//  end;
  end;

  // rv
  Result := rva.Rv(Result);
end;

function THtmRec.PageBlank(IvTitle, IvContent: string): string;
begin
  Result :=                        '<!DOCTYPE html>'
                    + sLineBreak + '<html lang="en-US">'
                    + sLineBreak +    Head(IvTitle)
                    + sLineBreak + '<body class="w3-theme">'
                    + sLineBreak +    Content(IvContent)
                    + sLineBreak + '</body>'
                    + sLineBreak + '</html>';

  // rv
  Result := rva.Rv(Result);
end;

function THtmRec.PageI(IvTitle, IvText: string; IvBuilder: integer): string;
begin
  Result := Page(
    'Info'
  , SpaceV()
  + H(2, IvTitle)
  + P(IvText)
  + SpaceV()
  );
end;

function THtmRec.PageW(IvTitle, IvText: string; IvBuilder: integer): string;
begin
  Result := Page(
    'Warning'
  , SpaceV()
  + AlertW(IvTitle, IvText)
  + SpaceV()
  );
end;

function THtmRec.PageE(IvTitle, IvText: string; IvBuilder: integer): string;
begin
  Result := Page(
    'Exception'
  , SpaceV()
  + AlertE(IvTitle, IvText)
  + SpaceV()
  );
end;

function THtmRec.PageNotFound(IvBuilder: integer): string;
begin
  Result := Page(
    'PageNotFound'
  , SpaceV()
  + AlertW('Page Not Found', Format('The requested page %s%s%s?%s is inactive or it does not exists', [wre.ServerHost, wre.Url, wre.PathInfo, wre.Query]))
  + SpaceV()
  );
end;
  {$ENDREGION}

  {$REGION 'buttons'}
function THtmRec.BtnBack(IvCaption, IvClass, IvStyle: string): string;
begin
  Result := '<button onclick="window.history.go(-1)" type="button" class="w3-button w3-theme-d3">' + iif.NxD(IvCaption, 'Back') + '</button>';
end;

function THtmRec.BtnHome(IvCaption, IvClass, IvStyle: string): string;
begin
  Result := '<button onclick="window.location.href=''/''" type="button" class="w3-button w3-theme-d3">' + iif.NxD(IvCaption, 'Home') + '</button>';
end;

function THtmRec.BtnXHome(IvClass, IvStyle: string): string;
begin
  Result := '<span onclick="window.location.href=''/''" class="w3-button w3-xlarge w3-transparent w3-display-topright" title="Close Modal">×</span>'
end;

function THtmRec.BtnXHide(IvCo, IvClass, IvStyle: string): string;
begin
  Result := '<span onclick="document.getElementById(''' + IvCo + ''').style.display=''none''" class="w3-button w3-xlarge w3-transparent w3-display-topright" title="Close Modal">×</span>'
end;
  {$ENDREGION}

  {$REGION 'alerts'}
function THtmRec.Alert(IvTitle, IvText, IvClass: string): string;
begin
  Result :=           sLineBreak + Format('<div%s>', [AttrClasse(['w3-panel', 'w3-display-container', IvClass])])
                    + sLineBreak + '<span onclick="this.parentElement.style.display=''none''" class="w3-button w3-large w3-display-topright">&times;</span>'
                    + sLineBreak + iif.ExF(IvTitle, '<h3>%s</h3>')
                    + sLineBreak + iif.ExF(IvText, '<p>%s</p>')
                    + sLineBreak + '</div>';
end;

function THtmRec.AlertI(IvTitle, IvText: string): string;
begin
  Result := Alert(IvTitle, IvText, 'w3-indigo');
end;

function THtmRec.AlertS(IvTitle, IvText: string): string;
begin
  Result := Alert(IvTitle, IvText, 'w3-green');
end;

function THtmRec.AlertW(IvTitle, IvText: string): string;
begin
  Result := Alert(IvTitle, IvText, 'w3-orange');
end;

function THtmRec.AlertD(IvTitle, IvText: string): string;
begin
  Result := Alert(IvTitle, IvText, 'w3-deep-orange');
end;

function THtmRec.AlertE(IvTitle, IvText: string): string;
begin
  Result := Alert(IvTitle, IvText, 'w3-dark-gray');
end;
  {$ENDREGION}

  {$REGION 'gui'}
function THtmRec.SpaceH(IvSpaces: integer): string;
begin
  Result :=                        ' &nbsp; ';
end;

function THtmRec.SpaceV(IvPx: integer): string;
begin
  Result :=           sLineBreak + Format('<div style="height:%dpx">', [IvPx])
                    + sLineBreak + '</div>';
end;

function THtmRec.Row(IvCellVec, IvClassVec, IvStyleVec: TStringVector): string;
var
  i: integer;
begin
  Result :=          sLineBreak + '<div class="w3-row">';
  for i := Low(IvCellVec) to High(IvCellVec) do
  Result := Result + sLineBreak + Format('<div%s%s>%s</div>', [AttrClasse([IvClassVec[i]]), AttrStyle(IvStyleVec[i]), IvCellVec[i]]);
  Result := Result + sLineBreak + '</div>';
end;
  {$ENDREGION}

  {$REGION 'tables'}
function THtmRec.TableArr(IvArr: TStringMatrix; IvClass, IvStyle, IvCo, IvCaption: string; Iv1stRowIsHeader: boolean): string;
var
  i, j: integer;
  r: string;
begin
  Result := '';

  // header
  if Iv1stRowIsHeader then begin
    for j := Low(IvArr[0]) to High(IvArr[0]) do
      r := r + Th(IvArr[0][j]);
    Result := Result + Tr(r);
  end;

  // rows
  for i := Low(IvArr) + iif.Int(Iv1stRowIsHeader, 1, 0) to High(IvArr) do begin
    r := '';
    for j := Low(IvArr[i]) to High(IvArr[i]) do
      r := r + Td(IvArr[i][j]);
    Result := Result + Tr(r);
  end;
  Result := Table(Result, IvClass, IvStyle, IvCo, IvCaption);
end;

function THtmRec.TableDs(IvDs: TFDDataset; IvClass, IvStyle, IvCo, IvCaption: string): string;
var

  {$REGION 'var'}
  c, r, rr, f, n, s, h, v: string; // caption, row, rows, fldname, name, showname, header, value
  i, j: integer; // counter

  function FieldIsGost(IvField: string): boolean;
  begin
    Result := IvField.EndsWith('Tooltip') or IvField.EndsWith('Symbol') or IvField.EndsWith('Ghost'); // canvasjsservicefields
  end;
  {$ENDREGION}

begin

  {$REGION 'exit'}
  if not Assigned(IvDs) then begin
    Result := Panel(NOT_ASSIGNED_STR);
    Exit
  end;
  if IvDs.IsEmpty then begin
    Result := Panel(NO_DATA_STR);
    Exit
  end;
  {$ENDREGION}

  {$REGION 'caption'}
  if IvClass.Contains('no-caption') then
    c := ''
  else begin
  //c := Format('<caption class="wks-cursor-pointer w3-left-align" onclick="w3.toggleShow(''#%s'')">%d Record(s)', [IvCo, IvDs.RecordCount]); // scompare insieme alla tabella
  //c := Format('<button class="w3-button w3-small" onclick="w3.toggleShow(''#%s'')">%s%d Record(s)</button>', [IvCo, iif.ExA(IvCaption, ' - '), IvDs.RecordCount]);
    c := Format('<span class="w3-text-gray w3-small" onclick="w3.toggleShow(''#%s'')" style="cursor:pointer;">%s%d Record(s)</span>', [IvCo, iif.ExA(IvCaption, ' - '), IvDs.RecordCount]);
  end;
  {$ENDREGION}

  {$REGION 'header'}
  if IvClass.Contains('no-header') then
    h := ''
  else begin
    r := Th('#');
    for i := 0 to IvDs.FieldCount - 1 do begin
      // fieldname
      f := IvDs.Fields[i].FieldName; // DisplayName

      // skip
      if FieldIsGost(f) then
        Continue;

      // fix/coname/showname
      n := f;
      if n.StartsWith('Fld') then
        Delete(n, 1, 3);
    //x := ''; // IvCo + n + 'Header'; // +i.ToString
      s := str.Expande(n);

      // header
      r := r + Th(s);
    end;
    h := Tr(r, 'w3-theme-d1');
  end;
  {$ENDREGION}

  {$REGION 'rows'}
  j := 0;
  rr := '';
  IvDs.First;
  while not IvDs.Eof do begin
    // inc
    Inc(j);

    // row
    r := Td(j.ToString);
    for i := 0 to IvDs.FieldCount-1 do begin
      // fieldname
      f := IvDs.Fields[i].FieldName;

      // skip
      if FieldIsGost(f) then
        Continue;

      // value
      v := IvDs.Fields.Fields[i].AsString;

      // fix
//    if str.Has(v, sLineBreak) then
//      v := str.Replace(v, sLineBreak, HBR);

      // strip
//    v := Strip(v, false);

      // charescape
//    v := Encode(v);

      // id
//    x := ''; // Format('CoI%dJ%d', [i, j]);

      // row
      r := r + Td(v);
    end;
    rr := rr + Tr(r);

    // next
    IvDs.Next;
  end;
  {$ENDREGION}

  {$REGION 'table'}
  Result := Table(h + rr, IvClass, IvStyle, IvCo, c);
  {$ENDREGION}

end;

function THtmRec.TableSql(IvSql, IvClass, IvStyle, IvCo, IvCaption: string; IvTimeOut: integer): string;
var
  k: string;
  d: TFDDataset;
  x: TDbaCls;
begin

  {$REGION 'exit'}
  if iis.Nx(IvSql) then begin
    Result := AlertW(IvCaption, 'Your sql query is probably empty, please check');
    Exit
  end;
  {$ENDREGION}

  x := TDbaCls.Create(FDManager);
  try

    {$REGION 'ds'}
    if not x.DsFD(IvSql, d, k, true, IvTimeOut) then begin
      Result := Panel(k);
      Exit
    end;
    Result := TableDs(d, IvClass, IvStyle, IvCo, IvCaption);
    {$ENDREGION}

  finally
    FreeAndNil(x);
  end;
end;

function THtmRec.TableWre: string;
var
  i: integer;
  x: TTkvVec;
begin
  // kv
  x := wre.TkvVec;

  // rows
  Result := '<tr class="w3-theme-d1"><th>#</th><th>Tag</th><th>Field</th><th>Value</th></tr>';
  for i := Low(x) to High(x) do
    Result := Result + Format('<tr><td>%d</td><td>%s</td><td>%s</td><td>%s</td></tr>', [i+1, x[i].Tag, x[i].Key, x[i].Val]);

  // tbl
  Result := Table(Result);
end;
  {$ENDREGION}

  {$REGION 'forms'}
function THtmRec.Form(IvCoVec, IvKindVec, IvValueVec: array of string; IvClass, IvAction, IvMethod: string): string;

  {$REGION 'help'}
  (*
  method
  ------
  get       form-data is sent as URL variables (?CoAbc=123)  default
  post      form-data is sent as HTTP post transaction

  target
  ------
  _blank    the response is displayed in a new window or tab
  _self     the response is displayed in the same frame               default, which means that the response will open i the current window
  _parent   the response is displayed in the parent frame
  _top      the response is displayed in the full body of the window
  framename the response is displayed in a named iframe
  *)
  {$ENDREGION}

var
  i: integer;
  c, k, v, l: string;
begin
  for i := Low(IvCoVec) to High(IvCoVec) do begin
    c := IvCoVec[i];
    k := IvKindVec[i];
    v := IvValueVec[i];
    l := nam.CoRemove(c);
    Result := Result + Input(c, k, l, v);
  end;
  Result :=           sLineBreak + Format('<form%s action="%s" method="%s">', [AttrClasse([IvClass]), IvAction, IvMethod])
                    + sLineBreak +   Result
                    + sLineBreak + '</form>';
end;

function THtmRec.Labl(IvContent, IvClass: string): string;
begin
  Result :=           sLineBreak + Format('<label%s>', [AttrClasse([iif.NxD(IvClass.Empty, '')])]) // w3-text-theme
                                 +   IvContent
                                 + '</label>';
end;

function THtmRec.Input(IvCo, IvKind, IvLabel, IvValue, IvPlaceholder, IvClass, IvStyle: string; IvUseLayout: boolean): string;
var
  l, i: string; // label, input
begin
  if          IvKind = 'Radio' then begin                                       // radio button (for selecting one of many choices)
    i := '<div class="w3-input">'
       +   '<input type="radio" class="w3-radio" name="gender" value="male" checked> <label style="margin-right:24px">Male</label>'
       +   '<input type="radio" class="w3-radio" name="gender" value="female"> <label style="margin-right:24px">Female</label>'
       +   '<input type="radio" class="w3-radio" name="gender" value="" disabled> <label>Don''t know (Disabled)</label>'
       + '</div>';
  end else if IvKind = 'Check' then begin                                       // checkbox (for selecting zero or more of many choices)
    i := '<div class="w3-input">'
       +   '<input type="checkbox" class=" class="w3-check" value="male" checked="checked"> <label style="margin-right:24px">Male</label>'
       +   '<input type="checkbox" class=" class="w3-check" value="female"> <label style="margin-right:24px">Female</label>'
       +   '<input type="checkbox" class=" class="w3-check" value="" disabled>'
       + '</div>';
  end else if IvKind = 'Textarea' then begin                                    // textarea
    i := '<textarea name="message" rows="10" cols="30" class="w3-input w3-border">' + IvValue + '</textarea>';
  end else if IvKind = 'Select' then begin                                      // select
    i := '<select id="cars" name="cars" class="w3-select w3-border">'           // size="1" multiple
       +   '<option value="" selected disabled>Choose your option</option>'
       +   '<option value="volvo">Volvo</option>'
       +   '<option value="saab">Saab</option>'
       +   '<option value="fiat">Fiat</option>'
       +   '<option value="audi">Audi</option>'
       +   '<option value="yamaha">Yamaha</option>'
       +   '<option value="opel">Opel</option>'
       + '</select>';
  end else if IvKind = 'Date' then begin                                        // date
    i := Format('<input%s type="date" value="%s"%s%s%s>', [AttrIdName(IvCo), IvValue, AttrClasse(['w3-input', 'w3-validate', IvClass]), AttrStyle(IvStyle), AttrPlaceholder(IvPlaceholder)]);
  end else if IvKind = 'DateTime' then begin                                    // datetime
    i := Format('<input%s type="datetime" value="%s"%s%s%s>', [AttrIdName(IvCo), IvValue, AttrClasse(['w3-input', 'w3-validate', IvClass]), AttrStyle(IvStyle), AttrPlaceholder(IvPlaceholder)]);
  end else if IvKind = 'DateTimeLocal' then begin                               // datetimelocal
    i := Format('<input%s type="datetime-local" value="%s"%s%s%s>', [AttrIdName(IvCo), IvValue, AttrClasse(['w3-input', 'w3-validate', IvClass]), AttrStyle(IvStyle), AttrPlaceholder(IvPlaceholder)]);
  end else if IvKind = 'Button' then begin                                      // clickable button
    i := Format('<button type="button"%s%s%s onclick="alert(''Hello World!'')">', [AttrIdName(IvCo), IvClass, IvStyle]) + IvValue + '</button>';
  end else if IvKind = 'Submit' then begin                                      // submit button (for submitting the form)
    i := Format('<input type="submit" value="%s"%s%s%s>', [IvValue, AttrIdName(IvCo), AttrClasse([IvClass]), AttrStyle(IvStyle)]);
  end else begin                                                                // single-line text input field
    i := Format('<input%s type="text" value="%s"%s%s%s>', [AttrIdName(IvCo), IvValue, AttrClasse(['w3-input', 'w3-validate', IvClass]), AttrStyle(IvStyle), AttrPlaceholder(IvPlaceholder)]);
  end;

  // assy
  l := iif.ExF(IvLabel, '<label for="cars">%s</label>'); // class="w3-text-theme"
  if IvUseLayout then
    Result := Row([l, i], ['w3-col', 'w3-rest'], ['width:150px;margin-top:8px', ''])
  else
    Result := l + sLineBreak + i;
end;
  {$ENDREGION}

  {$REGION 'charts'}
function THtmRec.Chart(IvCo, IvW, IvH, IvTitle, IvData: string): string;
begin
  Result :=      '<div id="' + IvCo + '" style="width:' + IvW + ';height:' + IvH + ';display: inline-block;"></div>'
  + sLineBreak + '<script>'
//+ sLineBreak + 'window.onload = function () {'
  + sLineBreak + 'var chart = new CanvasJS.Chart("' + IvCo + '", {'
  + sLineBreak + '  title:{'
  + sLineBreak + '    text: "' + IvTitle + '"'
  + sLineBreak + '  , fontSize: 18'
  + sLineBreak + '  }'
  + sLineBreak + ', data: [{'
	+ sLineBreak + '    type: "scatter"'
	+ sLineBreak + '  , dataPoints: ['
  + sLineBreak +        IvData
  + sLineBreak + '    ]'
  + sLineBreak + '  }]'
  + sLineBreak + '});'
  + sLineBreak + 'chart.render();'
//+ sLineBreak + '}'
  + sLineBreak + '</script>';
end;

function THtmRec.ChartDs(IvCo, IvW, IvH, IvTitle: string; IvDs: TFDDataset; IvXFld, IvYFld, IvTooltipFld: string): string;
var
  dt: TDateTime;
  da, ys, lb: string; // data
  //yy, mm, dd, hh, mi, ss, ms: word;
begin
  // data
  IvDs.First;
  while not IvDs.Eof do begin
    dt := IvDs.FieldByName(IvXFld).AsDateTime;
//    DecodeDate(dt, yy, mm, dd);
//    DecodeTime(dt, hh, mi, ss, ms);
//    xs := Format('new Date(Date.UTC(%d,%d,%d,%d,%d,%d,%d))', [yy, mm, dd, hh, mi, ss, ms]);
    lb := DateTimeToStr(dt);
    ys := IvDs.FieldByName(IvYFld).AsString;
//    xs := rnd.Int().ToString;
//    ys := rnd.Int().ToString;
//    da := da + Format(', {y:%s}', [ys]);
    da := da + Format(', {label:"%s", y:%s}', [lb, ys]);
//    da := da + Format(', {x:%s, y:%s}', [xs, ys]);
    IvDs.Next;
  end;
  Delete(da, 1, 2);
  //da := '{' + da + '}';

  // chart
  Result := Chart(IvCo, IvW, IvH, IvTitle, da);
end;

function THtmRec.ChartSql(IvCo, IvW, IvH, IvTitle: string; IvSql, IvXFld, IvYFld, IvTooltipFld: string; IvTimeOut: integer): string;
var
  k: string;
  d: TFDDataset;
  x: TDbaCls;
begin

  {$REGION 'exit'}
  if iis.Nx(IvSql) then begin
    Result := AlertW('Chart ' + IvTitle, 'Your sql query is probably empty, please check');
    Exit
  end;
  {$ENDREGION}

  x := TDbaCls.Create(FDManager);
  try

    {$REGION 'ds'}
    if not x.DsFD(IvSql, d, k, true, IvTimeOut) then begin
      Result := Panel(k);
      Exit
    end;
    Result := ChartDs(IvCo, IvW, IvH, IvTitle, d, IvXFld, IvYFld, IvTooltipFld);
    {$ENDREGION}

  finally

  end;
end;
  {$ENDREGION}

  {$REGION 'modals'}
function THtmRec.ModMessage(IvTitle, IvText, IvClass: string): string;
begin
  Result :=
    sLineBreak + '<!-- Modal Message -->'
  + sLineBreak + '<div id="CoModalMessage" class="w3-modal" style="display:block">'
  + sLineBreak + '  <div class="w3-modal-content w3-card-4 w3-animate-zoom" style="max-width:600px">'
  + sLineBreak + '    <div class="w3-center"><br>'
  + sLineBreak + '      ' + BtnXHome
  + sLineBreak + '      <i class="fa fa-check w3-jumbo w3-text-green w3-margin-top" alt="' + IvTitle + '"></i>'
  + sLineBreak + '      ' + H(1, IvTitle)
  + sLineBreak + '    </div>'
  + sLineBreak + '    <div class="w3-container">'
  + sLineBreak + '      ' + IvText
  + sLineBreak + '    </div>'
  + sLineBreak + '    <div class="w3-container w3-border-top w3-padding-16 w3-theme-l2 w3-yellow">'
  + sLineBreak + '      ' + BtnHome('Cancel') + SpaceH + BtnBack
  + sLineBreak + '    </div>'
  + sLineBreak + '  </div>'
  + sLineBreak + '</div>'
end;

function THtmRec.ModUserLogin: string;
begin
  Result :=
    sLineBreak + '<!-- User Login -->'
  + sLineBreak + '<div id="CoUserLogin" class="w3-modal" style="display:block">'
  + sLineBreak + '  <div class="w3-modal-content w3-card-4 w3-animate-zoom" style="max-width:600px">'
  + sLineBreak + '    <div class="w3-center"><br>'
  + sLineBreak + '      ' + BtnXHome
  + sLineBreak + '      <img src="' + org.LogoUrl + '" class="w3-margin-top" style="width:30%" alt="Avatar">' // w3-circle
  + sLineBreak + '    </div>'
  + sLineBreak + '    <form class="w3-container" action="' + wre.ScriptName + '/LoginTry">'
  + sLineBreak + '      <div class="w3-section">'
  + sLineBreak + '        ' + Labl('<b>Username</b>')
  + sLineBreak + '        <input name="CoUsername" class="w3-input w3-border w3-margin-bottom" type="text" placeholder="Enter Username" required>'
  + sLineBreak + '        ' + Labl('<b>Password</b>')
  + sLineBreak + '        <input name="CoPassword" class="w3-input w3-border" type="text" placeholder="Enter Password" required>'
  + sLineBreak + '        <button class="w3-button w3-block w3-green w3-section w3-padding" type="submit">Login</button>'
  + sLineBreak + '        <input class="w3-check w3-margin-top" type="checkbox" checked="checked"> Remember me'
  + sLineBreak + '      </div>'
  + sLineBreak + '    </form>'
  + sLineBreak + '    <div class="w3-container w3-border-top w3-padding-16 w3-theme-l2">'
//+ sLineBreak + '      <button onclick="document.getElementById(''CoUserLogin'').style.display=''none''" type="button" class="w3-button w3-red">Cancel</button>'
  + sLineBreak + '      ' + BtnHome('Cancel') + SpaceH + BtnBack
  + sLineBreak + '      <span class="w3-right w3-padding w3-hide-small"><a href="' + wre.ScriptName + '/AccountRecover">Recover account (username or password) ?</a></span>'
  + sLineBreak + '      <span class="w3-right w3-padding w3-hide-small"><a href="' + wre.ScriptName + '/AccountCreate">Create new account</a></span>'
  + sLineBreak + '    </div>'
  + sLineBreak + '  </div>'
  + sLineBreak + '</div>'
end;

function THtmRec.ModUserAccountCreate: string;
begin
  Result :=
    sLineBreak + '<!-- Account Create -->'
  + sLineBreak + '<div id="CoAccountCreate" class="w3-modal" style="display:block">'
  + sLineBreak + '  <div class="w3-modal-content w3-card-4 w3-animate-zoom" style="max-width:600px">'
  + sLineBreak + '    <div class="w3-center"><br>'
  + sLineBreak + '      ' + BtnXHome
  + sLineBreak + '      <i class="fa fa-user-circle-o w3-jumbo w3-margin-top" alt="Account Create"></i>'
  + sLineBreak + '      ' + H(1, 'Create New Account')
  + sLineBreak + '    </div>'
  + sLineBreak + '    <form class="w3-container" action="' + wre.ScriptName + '/AccountCreateTry">'
  + sLineBreak + '      <div class="w3-section">'
  + sLineBreak + '        ' + Labl('<b>Organization</b>')
  + sLineBreak + '        <input name="CoOrganization" class="w3-input w3-border w3-margin-bottom" type="text" placeholder="Enter Company, School, Institution, etc. (one single capitalized word)" required>'
  + sLineBreak + '        ' + Labl('<b>Username</b>')
  + sLineBreak + '        <input name="CoUsername" class="w3-input w3-border w3-margin-bottom" type="text" placeholder="Enter Username" required>'
  + sLineBreak + '        ' + Labl('<b>Password</b>')
  + sLineBreak + '        <input name="CoPassword" class="w3-input w3-border" type="text" placeholder="Enter Password" required>'
  + sLineBreak + '        <input name="CoSocial" class="w3-check w3-margin-top" type="checkbox" checked="checked"> Social'
  + sLineBreak + '        <button class="w3-button w3-block w3-green w3-section w3-padding" type="submit">Create New Account</button>'
  + sLineBreak + '      </div>'
  + sLineBreak + '    </form>'
  + sLineBreak + '    <div class="w3-container w3-border-top w3-padding-16 w3-theme-l2">'
  + sLineBreak + '      ' + BtnHome('Cancel') + SpaceH + BtnBack
  + sLineBreak + '    </div>'
  + sLineBreak + '  </div>'
  + sLineBreak + '</div>'
end;

function THtmRec.ModUserAccountCreateDone: string;
begin
  Result :=
    sLineBreak + '<!-- Account Create Done -->'
  + sLineBreak + '<div id="CoAccountCreateDone" class="w3-modal" style="display:block">'
  + sLineBreak + '  <div class="w3-modal-content w3-card-4 w3-animate-zoom" style="max-width:600px">'
  + sLineBreak + '    <div class="w3-center"><br>'
  + sLineBreak + '      ' + BtnXHome
  + sLineBreak + '      <i class="fa fa-check w3-jumbo w3-text-green w3-margin-top" alt="Account Created"></i>'
  + sLineBreak + '      ' + H(1, 'New Account Created')
  + sLineBreak + '    </div>'
  + sLineBreak + '    <div class="w3-container">'
  + sLineBreak + '      ' + P('Your new account has been created.')
  + sLineBreak + '      ' + P('Please check your email and follows the instructions to validate your email')
  + sLineBreak + '    </div>'
  + sLineBreak + '    <div class="w3-container w3-border-top w3-padding-16 w3-theme-l2">'
  + sLineBreak + '      ' + BtnHome('Continue')
  + sLineBreak + '    </div>'
  + sLineBreak + '  </div>'
  + sLineBreak + '</div>'
end;

function THtmRec.ModUserAccountRecover: string;
begin
  Result :=
    sLineBreak + '<!-- Account Recover -->'
  + sLineBreak + '<div id="CoAccountCreate" class="w3-modal" style="display:block">'
  + sLineBreak + '  <div class="w3-modal-content w3-card-4 w3-animate-zoom" style="max-width:600px">'
  + sLineBreak + '    <div class="w3-center"><br>'
  + sLineBreak + '      ' + BtnXHome
  + sLineBreak + '      <i class="fa fa-key w3-jumbo w3-margin-right w3-margin-top" alt="Send Password"></i>'
  + sLineBreak + '      ' + H(1, 'Recover Username or Password')
  + sLineBreak + '    </div>'
  + sLineBreak + '    <form class="w3-container" action="' + wre.ScriptName + '/AccountRecoverTry">'
  + sLineBreak + '      <div class="w3-section">'
  + sLineBreak + '        ' + Labl('<b>Email</b>')
  + sLineBreak + '        <input name="CoEmail" class="w3-input w3-border w3-margin-bottom" type="text" placeholder="Enter the original email assocated with your account" required>'
  + sLineBreak + '        <button class="w3-button w3-block w3-green w3-section w3-padding" type="submit">Send Account Info</button>'
  + sLineBreak + '      </div>'
  + sLineBreak + '    </form>'
  + sLineBreak + '    <div class="w3-container w3-border-top w3-padding-16 w3-theme-l2">'
  + sLineBreak + '      ' + BtnHome('Cancel') + SpaceH + BtnBack
  + sLineBreak + '    </div>'
  + sLineBreak + '  </div>'
  + sLineBreak + '</div>'
end;

function THtmRec.ModUserAccountRecoverDone: string;
begin
  Result :=
    sLineBreak + '<!-- Account Recover Done -->'
  + sLineBreak + '<div id="CoAccountRecoverDone" class="w3-modal" style="display:block">'
  + sLineBreak + '  <div class="w3-modal-content w3-card-4 w3-animate-zoom" style="max-width:600px">'
  + sLineBreak + '    <div class="w3-center"><br>'
  + sLineBreak + '      ' + BtnXHome
  + sLineBreak + '      <i class="fa fa-check w3-jumbo w3-text-green w3-margin-top" alt="Recovered account info sent"></i>'
  + sLineBreak + '      ' + H(1, 'Recovered Account Info Sent')
  + sLineBreak + '    </div>'
  + sLineBreak + '    <div class="w3-container">'
  + sLineBreak + '      ' + P('Your account relevant information has been sent via email')
  + sLineBreak + '      ' + P('Please check your email')
  + sLineBreak + '    </div>'
  + sLineBreak + '    <div class="w3-container w3-border-top w3-padding-16 w3-theme-l2">'
  + sLineBreak + '      ' + BtnHome('Continue')
  + sLineBreak + '    </div>'
  + sLineBreak + '  </div>'
  + sLineBreak + '</div>'
end;
  {$ENDREGION}

  {$REGION 'scripts'}
function THtmRec.BootScript(): string;
begin
    Result :=
                      sLineBreak + '<!-- BootScript -->'
                    + sLineBreak + '<script>'
                    + sLineBreak + '// used to toggle accordion blocks'
                    + sLineBreak + 'function w3AccordionToggle(id) {'
                    + sLineBreak + '  var x = document.getElementById(id);'
                    + sLineBreak + '  if (x.className.indexOf("w3-show") == -1) {'
                    + sLineBreak + '    x.className += " w3-show";'
                    + sLineBreak + '    x.previousElementSibling.className += " w3-theme-d1";'
                    + sLineBreak + '  } else {'
                    + sLineBreak + '    x.className = x.className.replace("w3-show", "");'
                    + sLineBreak + '    x.previousElementSibling.className ='
                    + sLineBreak + '    x.previousElementSibling.className.replace(" w3-theme-d1", "");'
                    + sLineBreak + '  }'
                    + sLineBreak + '}'
                    + sLineBreak + '// used to toggle the menu on smaller screens when clicking on the menu button'
                    + sLineBreak + 'function w3NavbarOpen() {'
                    + sLineBreak + '  var x = document.getElementById("CoNavbar");'
                    + sLineBreak + '  if (x.className.indexOf("w3-show") == -1) {'
                    + sLineBreak + '    x.className += " w3-show";'
                    + sLineBreak + '  } else {'
                    + sLineBreak + '    x.className = x.className.replace(" w3-show", "");'
                    + sLineBreak + '  }'
                    + sLineBreak + '}'
                    + sLineBreak + 'function w3SidebarLeftOpen(mainDivId, sidebarLeftId, width) {'
                    + sLineBreak + '  document.getElementById(mainDivId).style.marginLeft = width;'
                    + sLineBreak + '  document.getElementById(sidebarLeftId).style.width = width;'
                    + sLineBreak + '  document.getElementById(sidebarLeftId).style.display = "block";'
                  //+ sLineBreak + '  document.getElementById("openNav").style.display = "none";'
                    + sLineBreak + '  CookieSet("CoSidebarLeftShow", "true", 7);'
                    + sLineBreak + '}'
                    + sLineBreak + 'function w3SidebarLeftClose(mainDivId, sidebarLeftId) {'
                    + sLineBreak + '  document.getElementById(mainDivId).style.marginLeft = "0%";'
                    + sLineBreak + '  document.getElementById(sidebarLeftId).style.display = "none";'
                  //+ sLineBreak + '  document.getElementById("openNav").style.display = "inline-block";'
                    + sLineBreak + '  CookieSet("CoSidebarLeftShow", "false", 7);'
                    + sLineBreak + '}'
                    + sLineBreak + 'function w3SidebarLeftToggle(mainDivId, sidebarLeftId, width) {'
                    + sLineBreak + '  if (document.getElementById(sidebarLeftId).style.display == "none")'
                    + sLineBreak + '    w3SidebarLeftOpen(mainDivId, sidebarLeftId, width)'
                    + sLineBreak + '  else'
                    + sLineBreak + '    w3SidebarLeftClose(mainDivId, sidebarLeftId);'
                    + sLineBreak + '}'
                    + sLineBreak + '</script>'
end;
  {$ENDREGION}

  {$REGION 'spans'}
function THtmRec.SpanCode(IvCode: string): string;
begin
  Result := '<code class="w3-codespan">' + IvCode + '</code>';
end;
  {$ENDREGION}

  {$REGION 'divs'}
function THtmRec.DivTiming(IvMs: integer): string;
var
  s: string;
begin
  if IvMs < 1000 then
    s := Format('%d ms', [IvMs])
  else
    s := Format('%f s', [IvMs / 1000]);
  Result := Format('<p class="w3-small w3-padding w3-opacity" style="text-align:center;">rendering time %s</p>', [s]);
end;

function THtmRec.DivPathInfoActions(IvWm: TWebModule; IvWre: TWebRequest): string;
var
  i: integer;
begin
  Result :=
    sLineBreak + '<!-- PathInfos -->'
  + sLineBreak + '<h3>PathInfo</h3>';
  Result := Result + sLineBreak + '<ul>';
  for i := 0 to IvWm.Actions.Count - 1 do
    Result := Result + sLineBreak + '<li><a href="' + IvWre.ScriptName + IvWm.Action[I].PathInfo + '"> ' + IvWm.Action[I].Name + '</a></li>';
  Result := Result +  sLineBreak + '</ul>';
end;

function THtmRec.DivNews(IvLastHour: integer): string;
begin
  Result :=
    sLineBreak + '      <!-- News -->'
  + sLineBreak + '      <div class="w3-card w3-round w3-white">'
  + sLineBreak + '      news...'
  + sLineBreak + '      </div>'
end;

function THtmRec.DivUserAds(IvUser: string): string;
begin
  Result :=
    sLineBreak + '      <!-- User Ads -->'
  + sLineBreak + '      <div class="w3-card w3-round w3-white w3-padding-16 w3-center">'
  + sLineBreak + '        <p>ADS</p>'
  + sLineBreak + '      </div>'
end;

function THtmRec.DivUserBlog(IvLastHour: integer): string;
begin
  Result :=
    sLineBreak + '      <!-- User Blog -->'
  + sLineBreak + '      <div class="w3-row-padding">'
  + sLineBreak + '        <div class="w3-col m12">'
  + sLineBreak + '          <div class="w3-card w3-round w3-white">'
  + sLineBreak + '            <div class="w3-container w3-padding">'
  + sLineBreak + '              <h6 class="w3-opacity">Social Media template by w3.css</h6>'
  + sLineBreak + '              <p contenteditable="true" class="w3-border w3-padding">Status: Feeling Blue</p>'
  + sLineBreak + '              <button type="button" class="w3-button w3-theme"><i class="fa fa-pencil"></i>  Post</button>'
  + sLineBreak + '            </div>'
  + sLineBreak + '          </div>'
  + sLineBreak + '        </div>'
  + sLineBreak + '      </div>'
  + sLineBreak + ''
  + sLineBreak + '      <div class="w3-container w3-card w3-white w3-round w3-margin"><br>'
  + sLineBreak + '        <img src="/w3images/avatar2.png" alt="Avatar" class="w3-left w3-circle w3-margin-right" style="width:60px">'
  + sLineBreak + '        <span class="w3-right w3-opacity">1 min</span>'
  + sLineBreak + '        <h4>John Doe</h4><br>'
  + sLineBreak + '        <hr class="w3-clear">'
  + sLineBreak + '        <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.</p>'
  + sLineBreak + '          <div class="w3-row-padding" style="margin:0 -16px">'
  + sLineBreak + '            <div class="w3-half">'
  + sLineBreak + '              <img src="/w3images/lights.jpg" alt="Northern Lights" style="width:100%" class="w3-margin-bottom">'
  + sLineBreak + '            </div>'
  + sLineBreak + '            <div class="w3-half">'
  + sLineBreak + '              <img src="/w3images/nature.jpg" alt="Nature" style="width:100%" class="w3-margin-bottom">'
  + sLineBreak + '          </div>'
  + sLineBreak + '        </div>'
  + sLineBreak + '        <button type="button" class="w3-button w3-theme-d1 w3-margin-bottom"><i class="fa fa-thumbs-up"></i>  Like</button>'
  + sLineBreak + '        <button type="button" class="w3-button w3-theme-d2 w3-margin-bottom"><i class="fa fa-comment"></i>  Comment</button>'
  + sLineBreak + '      </div>'
  + sLineBreak + ''
  + sLineBreak + '      <div class="w3-container w3-card w3-white w3-round w3-margin"><br>'
  + sLineBreak + '        <img src="/w3images/avatar5.png" alt="Avatar" class="w3-left w3-circle w3-margin-right" style="width:60px">'
  + sLineBreak + '        <span class="w3-right w3-opacity">16 min</span>'
  + sLineBreak + '        <h4>Jane Doe</h4><br>'
  + sLineBreak + '        <hr class="w3-clear">'
  + sLineBreak + '        <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.</p>'
  + sLineBreak + '        <button type="button" class="w3-button w3-theme-d1 w3-margin-bottom"><i class="fa fa-thumbs-up"></i>  Like</button>'
  + sLineBreak + '        <button type="button" class="w3-button w3-theme-d2 w3-margin-bottom"><i class="fa fa-comment"></i>  Comment</button>'
  + sLineBreak + '      </div>'
  + sLineBreak + ''
  + sLineBreak + '      <div class="w3-container w3-card w3-white w3-round w3-margin"><br>'
  + sLineBreak + '        <img src="/w3images/avatar6.png" alt="Avatar" class="w3-left w3-circle w3-margin-right" style="width:60px">'
  + sLineBreak + '        <span class="w3-right w3-opacity">32 min</span>'
  + sLineBreak + '        <h4>Angie Jane</h4><br>'
  + sLineBreak + '        <hr class="w3-clear">'
  + sLineBreak + '        <p>Have you seen this?</p>'
  + sLineBreak + '        <img src="/w3images/nature.jpg" alt="" style="width:100%" class="w3-margin-bottom">'
  + sLineBreak + '        <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.</p>'
  + sLineBreak + '        <button type="button" class="w3-button w3-theme-d1 w3-margin-bottom"><i class="fa fa-thumbs-up"></i>  Like</button>'
  + sLineBreak + '        <button type="button" class="w3-button w3-theme-d2 w3-margin-bottom"><i class="fa fa-comment"></i>  Comment</button>'
  + sLineBreak + '      </div>'
end;

function THtmRec.DivUserBug(IvUser: string): string;
begin
  Result :=
    sLineBreak + '      <!-- User Bug -->'
  + sLineBreak + '      <div class="w3-card w3-round w3-white w3-padding-16 w3-center">'
  + sLineBreak + '        <p><i class="fa fa-bug w3-xxlarge"></i></p>'
  + sLineBreak + '      </div>'
end;

function THtmRec.DivUserFrienRequest(IvUser: string): string;
begin
  Result :=
    sLineBreak + '      <!-- User FrienRequest -->'
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
end;

function THtmRec.DivUserInterest(IvUser, IvUserId: string): string;
begin
  Result :=
    sLineBreak + '      <!-- User Interests -->'
  + sLineBreak + '      <div class="w3-card w3-round w3-white w3-hide-small">'
  + sLineBreak + '        <div class="w3-container">'
  + sLineBreak + '          <p>Interests</p>'
  + sLineBreak + '          <p>'
  + sLineBreak + '            <span class="w3-tag w3-small w3-theme-d5">News</span>'
  + sLineBreak + '            <span class="w3-tag w3-small w3-theme-d4">W3Schools</span>'
  + sLineBreak + '            <span class="w3-tag w3-small w3-theme-d3">Labels</span>'
  + sLineBreak + '            <span class="w3-tag w3-small w3-theme-d2">Games</span>'
  + sLineBreak + '            <span class="w3-tag w3-small w3-theme-d1">Friends</span>'
  + sLineBreak + '            <span class="w3-tag w3-small w3-theme">Games</span>'
  + sLineBreak + '            <span class="w3-tag w3-small w3-theme-l1">Friends</span>'
  + sLineBreak + '            <span class="w3-tag w3-small w3-theme-l2">Food</span>'
  + sLineBreak + '            <span class="w3-tag w3-small w3-theme-l3">Design</span>'
  + sLineBreak + '            <span class="w3-tag w3-small w3-theme-l4">Art</span>'
  + sLineBreak + '            <span class="w3-tag w3-small w3-theme-l5">Photos</span>'
  + sLineBreak + '          </p>'
  + sLineBreak + '        </div>'
  + sLineBreak + '      </div>'
end;

function THtmRec.DivUserMore(IvUser: string): string;
begin
  Result :=
    sLineBreak + '<!-- Accordion -->'
  + sLineBreak + '<div class="w3-card w3-round">'
  + sLineBreak + '  <div class="w3-white">'

  + sLineBreak + '    <button onclick="w3AccordionToggle(''CoAccordion1'')" class="w3-button w3-block w3-theme-l1 w3-left-align"><i class="fa fa-circle-o-notch fa-fw w3-margin-right"></i> My Groups</button>'
  + sLineBreak + '    <div id="CoAccordion1" class="w3-hide w3-container">'
  + sLineBreak + '      <p>Some text..</p>'
  + sLineBreak + '    </div>'

  + sLineBreak + '    <button onclick="w3AccordionToggle(''CoAccordion2'')" class="w3-button w3-block w3-theme-l1 w3-left-align"><i class="fa fa-calendar-check-o fa-fw w3-margin-right"></i> My Events</button>'
  + sLineBreak + '    <div id="CoAccordion2" class="w3-hide w3-container">'
  + sLineBreak + '      <p>Some other text..</p>'
  + sLineBreak + '    </div>'

  + sLineBreak + '    <button onclick="w3AccordionToggle(''CoAccordion3'')" class="w3-button w3-block w3-theme-l1 w3-left-align"><i class="fa fa-users fa-fw w3-margin-right"></i> My Photos</button>'
  + sLineBreak + '    <div id="CoAccordion3" class="w3-hide w3-container">'
  + sLineBreak + '      <div class="w3-row-padding">'
  + sLineBreak + '        <br>'
  + sLineBreak + '        <div class="w3-half">'
  + sLineBreak + '          <img src="http://prodimg.ai.lfoundry.com/emppics/353473.jpg" alt="" class="w3-margin-bottom" style="width:100%">'
  + sLineBreak + '        </div>'
  + sLineBreak + '        <div class="w3-half">'
  + sLineBreak + '          <img src="http://prodimg.ai.lfoundry.com/emppics/353992.jpg" alt="" class="w3-margin-bottom" style="width:100%">'
  + sLineBreak + '        </div>'
  + sLineBreak + '        <div class="w3-half">'
  + sLineBreak + '          <img src="http://prodimg.ai.lfoundry.com/emppics/353234.jpg" alt="" class="w3-margin-bottom" style="width:100%">'
  + sLineBreak + '        </div>'
  + sLineBreak + '        <div class="w3-half">'
  + sLineBreak + '          <img src="http://prodimg.ai.lfoundry.com/emppics/784629.jpg" alt="" class="w3-margin-bottom" style="width:100%">'
  + sLineBreak + '        </div>'
  + sLineBreak + '        <div class="w3-half">'
  + sLineBreak + '          <img src="http://prodimg.ai.lfoundry.com/emppics/810643.jpg" alt="" class="w3-margin-bottom" style="width:100%">'
  + sLineBreak + '        </div>'
  + sLineBreak + '        <div class="w3-half">'
  + sLineBreak + '          <img src="http://prodimg.ai.lfoundry.com/emppics/784479.jpg" alt="" class="w3-margin-bottom" style="width:100%">'
  + sLineBreak + '        </div>'
  + sLineBreak + '      </div>'
  + sLineBreak + '    </div>'

  + sLineBreak + '  </div>'
  + sLineBreak + '</div>'
end;

function THtmRec.DivUserNotification(IvNotification: string): string;
begin
  Result :=
    sLineBreak + '      <!-- User Notification -->'
  + sLineBreak + '      <div class="w3-container w3-display-container w3-round w3-theme-l4 w3-border w3-theme-border w3-margin-bottom w3-hide-small">'
  + sLineBreak + '        <span onclick="this.parentElement.style.display=''none''" class="w3-button w3-theme-l3 w3-display-topright">'
  + sLineBreak + '          <i class="fa fa-remove"></i>'
  + sLineBreak + '        </span>'
  + sLineBreak + '        <p><strong>Hey!</strong></p>'
  + sLineBreak + '        <p>People are looking at your profile. Find out who.</p>'
  + sLineBreak + '      </div>'
end;

function THtmRec.DivUserProfile(IvUser, IvUserId: string): string;
begin
  Result :=
    sLineBreak + '      <!-- User Profile -->'
  + sLineBreak + '      <div class="w3-card w3-round w3-white">'
  + sLineBreak + '        <div class="w3-container">'
  + sLineBreak + '         <h4 class="w3-center">' + IvUser + '</h4>'
//+ sLineBreak + '         <p class="w3-center"><img src="http://prodimg.ai.lfoundry.com/emppics/' + IvUserId + '.jpg" alt="Avatar" class="w3-circle" style="height:106px;width:106px"></p>'
  + sLineBreak + '         <p class="w3-center"><img src="/User/G/giarussi/giarussi.png" alt="Avatar" class="w3-circle" style="height:106px;width:106px"></p>'
  + sLineBreak + '         <hr>'
  + sLineBreak + '         <p><i class="fa fa-pencil fa-fw w3-margin-right w3-text-theme"></i> Designer, UI</p>'
  + sLineBreak + '         <p><i class="fa fa-home fa-fw w3-margin-right w3-text-theme"></i> London, UK</p>'
  + sLineBreak + '         <p><i class="fa fa-birthday-cake fa-fw w3-margin-right w3-text-theme"></i> April 1, 1988</p>'
  + sLineBreak + '        </div>'
  + sLineBreak + '      </div>'
end;

function THtmRec.DivUserUpcomingEvent(IvUser: string): string;
begin
  Result :=
    sLineBreak + '      <!-- User UpcomingEvent -->'
  + sLineBreak + '      <div class="w3-card w3-round w3-white w3-center">'
  + sLineBreak + '        <div class="w3-container">'
  + sLineBreak + '          <p>Upcoming Events:</p>'
  + sLineBreak + '          <img src="/w3images/forest.jpg" alt="Forest" style="width:100%;">'
  + sLineBreak + '          <p><strong>Holiday</strong></p>'
  + sLineBreak + '          <p>Friday 15:00</p>'
  + sLineBreak + '          <p><button class="w3-button w3-block w3-theme-l4">Info</button></p>'
  + sLineBreak + '        </div>'
  + sLineBreak + '      </div>'
end;
  {$ENDREGION}

  {$REGION 'report'}
function THtmRec.Report(IvId: integer): string;

  {$REGION 'var'}
var
  xp, xd, xc: integer; // idx param, dataset, chart
  sq, co, c2, cl, sy, va, na, n2, ww, hh, ti, t2, se, k: string; // sql, coname, class, style, value, name, w, h, title, select
  dr, dp, dd, dc: TFDDataset; // ds report, params, datasets, dataset-charts
  rr, rp, rd, ra, rb: string; // result report, params, datasets, dstable, dscharts
  fx, fy, ft: string; // fldx, fldy, fldtooltip
  nn, vv, cc: string; // spare name, value, coname
  x: TDbaCls;
  {$ENDREGION}

begin
  x := TDbaCls.Create(FDManager);
  try

    {$REGION 'dr rr report'}
    sq := Format('select * from DbaReport.dbo.TblReport where FldState = ''Active'' and FldId = %d', [IvId]);
    if not x.DsFD(sq, dr, k, true) then begin
      Result := AlertW('Report', k);
      Exit;
    end;
    {$ENDREGION}

    {$REGION 'dp rp params'}
    rp := '';
    sq := Format('select * from DbaReport.dbo.TblParam where FldState = ''Active'' and FldReportId = %d order by FldOrder', [IvId]);
    if not x.DsFD(sq, dp, k) then begin
      rp := rp + AlertW('Params', k);
    end else begin
      rp := rp +         '<h4 style="cursor:pointer;" onclick="w3.toggleShow(''#CoFilter'')">Filters</h4>' // class="w3-button"
          + sLineBreak + '<form id="CoFilter" class="w3-card w3-padding"' + iif.Str(dr.FieldByName('FldParamsClosed').AsBoolean, ' style="display:none;"', '') + ' action="' + '' + '" method="post">'; //  w3-container
      xp := 0;
      while not dp.Eof do begin
        Inc(xp);
        co := nam.Co(dp.FieldByName('FldParam').AsString);
        va := wre.StrGet(co, dp.FieldByName('FldDefault').AsString);
        rp := rp + sLineBreak + Input(
          co                                                                                  // Co
        , dp.FieldByName('FldKind').AsString                                                  // Kind
        , iif.NxD(dp.FieldByName('FldCaption').AsString, dp.FieldByName('FldParam').AsString) // Label
        , va                                                                                  // Value
        , dp.FieldByName('FldPlaceholder').AsString                                           // Placeholder
        , dp.FieldByName('FldClass').AsString                                                 // Class
        , dp.FieldByName('FldStyle').AsString                                                 // Style
        );
        dp.Next;
      end;
    end;
    rp := rp + sLineBreak + '<br>' + Input('CoRefresh', 'Submit', '', 'Refresh', '', 'w3-btn w3-indigo');
    rp := rp + sLineBreak + '<br></form>';
    rp := rva.Rv(rp);
    {$ENDREGION}

    {$REGION 'dd rd=ra+rb dataset(s)+chart(s)'}
    rd := '';
    sq := Format('select * from DbaReport.dbo.TblDataset where FldState = ''Active'' and FldReportId = %d order by FldOrder', [IvId]);
    if not x.DsFD(sq, dd, k) then begin
      rd := rd + AlertW('Datasets', k);
    end else begin
      xd := 0; // ds
      while not dd.Eof do begin

        {$REGION 'ra dataset'}
        ra := '';
        Inc(xd);
        na := dd.FieldByName('FldDataset').AsString;
        ti := dd.FieldByName('FldTitle').AsString;
        se := dd.FieldByName('FldSelect').AsString;
        cl := dd.FieldByName('FldClass').AsString;
        sy := dd.FieldByName('FldStyle').AsString;
        co := nam.Co('Table' + xd.ToString);

        // se compile
        dp.First;
        while not dp.Eof do begin
          nn := dp.FieldByName('FldParam').AsString;
          cc := nam.Co(nn);
          vv := wre.StrGet(cc, dp.FieldByName('FldDefault').AsString);
          se := stringreplace(se, '$'+nn+'$', vv, [rfReplaceAll]);
          dp.Next;
        end;
        ra := ra {+ '<br>'} + TableSql(se, cl, sy, co, {ti}''); // title will be used as title of ds+charts card
        {$ENDREGION}

        {$REGION 'rb charts'}
        rb := '';
        sq := Format('select * from DbaReport.dbo.TblChart where FldState = ''Active'' and FldReportId = %d and FldDataset = ''%s'' order by FldOrder', [IvId, na]);
        if not x.DsFD(sq, dc, k) then begin
          rb := rb + AlertW('Charts', k);
        end else begin
          xc := 0; // chart
          while not dc.Eof do begin
            Inc(xc);
            n2 := dc.FieldByName('FldChart').AsString;
            t2 := dc.FieldByName('FldTitle').AsString;
            ww := dc.FieldByName('FldWidth').AsString;
            hh := dc.FieldByName('FldHeight').AsString;
            fx := dc.FieldByName('FldXLabelAngleDeg').AsString;
            fy := dc.FieldByName('FldYLabelAngleDeg').AsString;
            ft := dc.FieldByName('FldDescription').AsString;
          //cl := dc.FieldByName('FldClass').AsString;
          //sy := dc.FieldByName('FldStyle').AsString;
            c2 := nam.Co(Format('Dataset%dChart%d', [xd, xc]));
            rb := rb {+ '<br>'} + '<div class="w3-center">' + ChartSql(c2, ww, hh, t2, se, fx, fy, ft) + '</div>';
            dc.Next;
          end;
        end;
        {$ENDREGION}

        // chart(s) + table
        co := nam.Co('Dataset' + xd.ToString);
        rd := rd
        + '<h4 style="cursor:pointer;" onclick="w3.toggleShow(''#' + co + ''')">' + ti + '</h4>' // class="w3-button"
        + '<div' + iif.Str(dd.FieldByName('FldPanelOn').AsBoolean, ' class="w3-card w3-padding"', '') + ' id="' + co + '"' + iif.Str(dd.FieldByName('FldPanelClosed').AsBoolean, ' style="display:none;"', '') + '>'
        + iif.ExA(rb, '<br>') + ra
        + '</div>';

        // next
        dd.Next;
      end;
    end;
    {$ENDREGION}

    {$REGION 'report-assy'}
    Result := '';

    // add header
    if not dr.FieldByName('FldContent').AsString.Contains('no-header') then
      Result := Result + dr.FieldByName('FldHeader').AsString;

    // add params rp
    if not dr.FieldByName('FldContent').AsString.Contains('no-filter') then
      Result := Result + rp;

    // add datasets+charts rd
    if not dr.FieldByName('FldContent').AsString.Contains('no-dataset') then // imply no-charts
      Result := Result + rd;

    // add footer
    if not dr.FieldByName('FldContent').AsString.Contains('no-footer') then
      Result := Result + dr.FieldByName('FldFooter').AsString;
    {$ENDREGION}

    {$REGION 'clean'}
    dc.Free;
    dd.Free;
    dp.Free;
    dr.Free;
    {$ENDREGION}

  finally
    FreeAndNil(x);
  end;
end;
  {$ENDREGION}

  {$REGION 'tests'}
function THtmRec.TestChart(IvN: cardinal): string;
var
  i: integer;
begin
  Result :=      '<!-- Test Chart -->'
  + sLineBreak + '<div id="CoTestChart" style="height:400px;width:100%;"></div>'
  + sLineBreak + '<script>'
  + sLineBreak + 'window.onload = function () {'
  + sLineBreak + '  var chart = new CanvasJS.Chart("CoTestChart", {'
  + sLineBreak + '    title:{'
  + sLineBreak + '      text: "Loading %d Points"'
  + sLineBreak + '    , fontSize: 16'
  + sLineBreak + '    }'
  + sLineBreak + '  , data: [{'
  + sLineBreak + '      type: "scatter"'
  + sLineBreak + '    , dataPoints: ['
  + sLineBreak + '      {x:0.0, y: 0.0}';
  for i := 1 to IvN do
    Result := Result + Format(', {x:%d, y:%d}', [rnd.Int(0, 1000), rnd.Int(0, 500)]);
  Result := Result + sLineBreak + '    ]'
  + sLineBreak + '  }]'
  + sLineBreak + ' });'
  + sLineBreak + 'chart.render();'
  + sLineBreak + '}'
  + sLineBreak + '</script>';
end;

function THtmRec.TestForm: string;
begin
  Result := '<!-- Test Form -->'
  + sLineBreak + Form(
    ['CoFirstName', 'CoLastName', 'CoText', 'CoRadio', 'CoCheck', 'CoTextarea', 'CoSelect', 'CoButton', 'CoSubmit']
  , ['Text'       , 'Text'      , 'Text'  , 'Radio'  , 'Check'  , 'Textarea'  , 'Select'  , 'Button'  , 'Submit'  ]
  , ['Gio'        , 'Vanni'     , 'abc'   , ''       , ''       , 'abcdef'    , ''        , ''        , ''        ]
  , 'w3-container', wre.ScriptName + '/Test', 'get');
end;

function THtmRec.TestTable(IvRow, IvCol: cardinal): string;
var
  r, c: integer;
  a: TStringMatrix;
begin
  // rows
  SetLength(a, IvRow);

  // cols
  for r := 0 to IvRow - 1 do begin
    SetLength(a[r], IvCol);
    for c := 0 to IvCol - 1 do
      a[r, c] := ifthen(true, Format('r:%d , c:%d', [r, c]), rnd.Str(8));
  end;

  Result := '<!-- Test Table -->'
  + sLineBreak + TableArr(a);
end;

function THtmRec.TestTheme: string;
begin
  Result :=      '<!-- Test Theme -->'
  + sLineBreak + '<div class="w3-card-4">'
  + sLineBreak + '  <div class="w3-container w3-theme w3-card">'
  + sLineBreak + '    <h1>Test Theme</h1>'
  + sLineBreak + '  </div>'
  + sLineBreak + '  <div class="w3-container w3-text-theme">'
  + sLineBreak + '    <h2>w3-text-theme</h2>'
  + sLineBreak + '  </div>'
  + sLineBreak + '  <ul class="w3-ul w3-border-top">'
  + sLineBreak + '    <li class="w3-theme-l5"><p>w3-theme-l5 (w3-theme-light)</p></li>'
  + sLineBreak + '    <li class="w3-theme-l4"><p>w3-theme-l4</p></li>'
  + sLineBreak + '    <li class="w3-theme-l3"><p>w3-theme-l3</p></li>'
  + sLineBreak + '    <li class="w3-theme-l2"><p>w3-theme-l2</p></li>'
  + sLineBreak + '    <li class="w3-theme-l1"><p>w3-theme-l1</p></li>'
  + sLineBreak + '    <li class="w3-theme"><p>w3-theme</p></li>'
  + sLineBreak + '    <li class="w3-theme-d1"><p>w3-theme-d1</p></li>'
  + sLineBreak + '    <li class="w3-theme-d2"><p>w3-theme-d2</p></li>'
  + sLineBreak + '    <li class="w3-theme-d3"><p>w3-theme-d3</p></li>'
  + sLineBreak + '    <li class="w3-theme-d4"><p>w3-theme-d4</p></li>'
  + sLineBreak + '    <li class="w3-theme-d5"><p>w3-theme-d5 (w3-theme-dark)</p></li>'
  + sLineBreak + '  </ul>'
  + sLineBreak + '</div>';
end;
  {$ENDREGION}

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
  raise Exception.Create(NOT_IMPLEMENTED_STR);
end;

function TImgRec.DbaInsert(var IvFbk: string): boolean;
begin
  raise Exception.Create(NOT_IMPLEMENTED_STR);
end;

function TImgRec.DbaSelect(var IvFbk: string): boolean;
begin
  raise Exception.Create(NOT_IMPLEMENTED_STR);
end;

procedure TImgRec.DbaToDisk(IvFile, IvTable, IvField, IvWhere: string);
var
  d, k: string;
  p: TPicture;
  x: TDbaCls;
begin
  p := TPicture.Create;
  x := TDbaCls.Create(FDManager);
  try
    if x.ImgPictureFromDba(p, IvTable, IvField, IvWhere, k) then begin
      d := ExtractFileDir(IvFile);
      if not DirectoryExists(d) then
        if not ForceDirectories(d) then
          raise Exception.CreateFmt('Unable to create directory %s', [d]);
      p.SaveToFile(IvFile); // bmp.ToFile(p.Bitmap, IvFile, true, k);
    end;
  finally
    FreeAndNil(x);
    FreeAndNil(p);
  end;
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

{$REGION 'TIsaRec'}
function TIsaRec.IsapiUrl(IvObj: string): string;
var
  u: string;
begin
  // url
  u := srv.Url;

  // url
  if IvObj <> '' then
    Result := u + Format(ISAPI_DLL_URL, [IvObj])
  else
    Result := u + byn.Spec; // XxxIsapiProject.dll/exe
end;
{$ENDREGION}

{$REGION 'TLgoRec'}
function TLgoRec.Spec(IvOrganization: string): string;
var
  o: string;
begin
  o := iif.NxD(IvOrganization, 'Wks');
  Result := Format('%s\%1s\%s\%sLogo.png', [sys.ORG_DIR, o, o, o]);
end;

function TLgoRec.Url(IvOrganization: string): string;
var
  o: string;
begin
  o := iif.NxD(IvOrganization, 'Wks');
  Result := Format('%s/Organization/%1s/%s/%sLogo.png', [srv.Url, o, o, o]);
end;

function TLgoRec.InvSpec(IvOrganization: string): string;
var
  o: string;
begin
  o := iif.NxD(IvOrganization, 'Wks');
  Result := Format('%s\%1s\%s\%sLogoInv.png', [sys.ORG_DIR, o, o, o]);
end;

function TLgoRec.InvUrl(IvOrganization: string): string;
var
  o: string;
begin
  o := iif.NxD(IvOrganization, 'Wks');
  Result := Format('%s/Organization/%1s/%s/%sLogoInv.png', [srv.Url, o, o, o]);
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
  //ods('LOG', r.Entry);

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
  {$IFDEF DEBUG}
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
  {$ENDIF}
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
  Tag('LOGOBJECT', NOT_IMPLEMENTED_STR);
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

{$REGION 'TMbrRec'}
function TMbrRec.BadgePath(IvMember: string): string;
var
  m: string;
begin
  m := iif.NxD(IvMember, Member);
  Result := Format('%s\%s.png', [PathAlpha(m), m]);
  if not FileExists(Result) then
    img.DbaToDisk(Result, 'DbaMember.dbo.TblMember', 'FldBadge', Format('FldMember = ''%s''', [m]));
//Result := '/WksImageIsapiProject.dll/Image?CoFrom=Member&CoName=' + IvMember;
end;

function TMbrRec.BadgeUrl(IvMember: string): string;
var
  m: string;
begin
  m := iif.NxD(IvMember, Member);
  Result := Format('%s/%s.png', [UrlAlpha(m), m]);
end;

function TMbrRec.CanDelete(IvResource: string): boolean;
begin
  Result := true;
end;

function TMbrRec.CanEdit(IvResource: string): boolean;
begin
  Result := true;
end;

function TMbrRec.CanInsert(IvResource: string): boolean;
begin
  Result := true;
end;

function TMbrRec.CanView(IvResource: string): boolean;
begin
  Result := true;
end;

function TMbrRec.DbaSelect(var IvFbk: string): boolean;
begin
  IvFbk  := NOT_IMPLEMENTED_STR;
  Result := false;
//raise Exception.Create(NOT_IMPLEMENTED_STR);

//Member        := ;
//Role          := ;
//Level         := ;
//Email         := ;
//Phone         := ;
//Authorization := ;
end;

function TMbrRec.Grade: integer;
begin
  // system
       if (Role = rol.ROLE_SYSTEM)                                                  then Result := rol.GRADE_SYSTEM

  // architect
  else if (Role = rol.ROLE_ARCHITECT)                                               then Result := rol.GRADE_ARCHITECT

  // administrator, match just the 1st 5 chars to allow role = admin(istator)
  else if str.Match(Role, rol.ROLE_ADMINISTRATOR, 5) and (Level = rol.LEVEL_LOW)    then Result := rol.GRADE_ADMINISTRATOR_LOW
  else if str.Match(Role, rol.ROLE_ADMINISTRATOR, 5) and (Level = rol.LEVEL_NORMAL) then Result := rol.GRADE_ADMINISTRATOR_NORMAL
  else if str.Match(Role, rol.ROLE_ADMINISTRATOR, 5) and (Level = rol.LEVEL_HIGH)   then Result := rol.GRADE_ADMINISTRATOR_HIGH

  // manager
  else if (Role = rol.ROLE_MANAGER)                  and (Level = rol.LEVEL_LOW)    then Result := rol.GRADE_MANAGER_LOW
  else if (Role = rol.ROLE_MANAGER)                  and (Level = rol.LEVEL_NORMAL) then Result := rol.GRADE_MANAGER_NORMAL
  else if (Role = rol.ROLE_MANAGER)                  and (Level = rol.LEVEL_HIGH)   then Result := rol.GRADE_MANAGER_HIGH

  // supervisor
  else if (Role = rol.ROLE_SUPERVISOR)               and (Level = rol.LEVEL_LOW)    then Result := rol.GRADE_SUPERVISOR_LOW
  else if (Role = rol.ROLE_SUPERVISOR)               and (Level = rol.LEVEL_NORMAL) then Result := rol.GRADE_SUPERVISOR_NORMAL
  else if (Role = rol.ROLE_SUPERVISOR)               and (Level = rol.LEVEL_HIGH)   then Result := rol.GRADE_SUPERVISOR_HIGH

  // member
  else if (Role = rol.ROLE_MEMBER)                   and (Level = rol.LEVEL_LOW)    then Result := rol.GRADE_MEMBER_LOW
  else if (Role = rol.ROLE_MEMBER)                   and (Level = rol.LEVEL_NORMAL) then Result := rol.GRADE_MEMBER_NORMAL
  else if (Role = rol.ROLE_MEMBER)                   and (Level = rol.LEVEL_HIGH)   then Result := rol.GRADE_MEMBER_HIGH

  // guest
  else                                                                                   Result := rol.GRADE_GUEST;
end;

function TMbrRec.Info: string;
begin
  Result := Format('%s@%s', [Member, Organization]);
end;

function TMbrRec.IsAdmin: boolean;
begin
  Result := Grade >= rol.GRADE_ADMINISTRATOR_LOW; // Role = ROLE_ADMINISTRATOR
end;

function TMbrRec.IsAdminHigh: boolean;
begin
  Result := Grade = rol.GRADE_ADMINISTRATOR_HIGH; // Result := (Role = rol.ROLE_ADMINISTRATOR) and (Level = rol.LEVEL_HIGH);
end;

function TMbrRec.IsAuthorized(IvResource: string; var IvFbk: string): boolean;
begin
  Result := Authorization.Contains(IvResource)
         or Authorization.StartsWith('All')
         or sys.ADMIN_CSV.Contains(Member);
  if Result then
    IvFbk := Format('%s is authorized for %s', [Member, IvResource])
  else
    IvFbk := Format('%s is not authorized for %s', [Member, IvResource]);
end;

function TMbrRec.IsGuest: boolean;
begin
  Result := Grade >= rol.GRADE_GUEST;
end;

function TMbrRec.IsManager: boolean;
begin
  Result := Grade >= rol.GRADE_MANAGER_LOW;
end;

function TMbrRec.IsMember: boolean;
begin
  Result := Grade >= rol.GRADE_MEMBER_LOW;
end;

function TMbrRec.IsOwner: boolean;
begin
  Result := Member = org.Owner;
end;

function TMbrRec.IsSupervisor: boolean;
begin
  Result := Grade >= rol.GRADE_SUPERVISOR_LOW;
end;

function TMbrRec.IsWksAdmin: boolean;
begin
  Result := sys.ADMIN_CSV.Contains(Member);
end;

function TMbrRec.MemberAtOrganization: string;
begin
  Result := Format('%s@%s', [Member, LowerCase(Organization)]);
end;

function TMbrRec.PathAlpha(IvMember: string): string;
var
  m: string;
begin
  m := iif.NxD(IvMember, Member);
  Result := Format('%s\%s', [sys.MEM_DIR, UpperCase(m[1])]);
end;

function TMbrRec.RioInit(IvMember, IvOrganization: string; var IvFbk: string): boolean;
begin
  IvFbk  := NOT_IMPLEMENTED_STR;
  Result := false;
  raise Exception.Create(NOT_IMPLEMENTED_STR);
end;

function TMbrRec.UrlAlpha(IvMember: string): string;
var
  m: string;
begin
  m := iif.NxD(IvMember, Member);
  Result := srv.ObjUrl('Member', UpperCase(m[1]));
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

{$REGION 'TNamRec'}
function TNamRec.Co(IvName: string): string;
var
  a: string;
begin
  a := CoRemove(IvName);
  Result := 'Co' + Std(a);
end;

function TNamRec.CoRemove(IvName: string): string;
var
  a: string;
begin
  // zip
  a := IvName;

  // exit
  if a.StartsWith('Code')
  or a.StartsWith('Computer') then
    Exit;

  // go
  while a.StartsWith('Co') do
    Delete(a, 1, 2);
  Result := a;
end;

function TNamRec.CoRnd(IvPrefix: string; IvLenght: integer): string;
begin
  Result := 'Co' + Rnd(IvLenght);
end;

function TNamRec.HasNum(IvName: string): boolean;
var
  l: integer;
begin
  l := Length(IvName);
  Result := l > 0;
  if not Result then
    Exit;
  Result := CharInSet(IvName[Length(IvName)], ['0'..'9']);
end;

function TNamRec.IsNumOf(IvName, IvBase: string): boolean;
begin
  Result := IvName.StartsWith(IvBase, true);
end;

function TNamRec.NumBasePart(IvName: string): string;
var
  i: integer;
  c: char;
begin
  Result := '';
  for i := 1 to Length(IvName) do begin
    c := IvName[i];
    if CharInSet(c, ['A'..'z']) then
      Result := Result + c
    else
      Exit;
  end;
end;

function TNamRec.NumCodePart(IvName: string): string;
var
  i: integer;
  c: char;
begin
  Result := '';
  for i := Length(IvName) downto 1 do begin
    c := IvName[i];
    if CharInSet(c, ['0'..'9']) then
      Result := c + Result
    else
      Exit;
  end;
end;

function TNamRec.NumNext(IvName: string): string;
var
  i: integer;
  b, c: string;
begin
  b := nam.NumBasePart(IvName);
  c := nam.NumCodePart(IvName);
  i := StrToInt(c) + 1;
  Result := b + IntToStr(i);
end;

function TNamRec.NumPrev(IvName: string): string;
var
  i: integer;
  b, c: string;
begin
  b := nam.NumBasePart(IvName);
  c := nam.NumCodePart(IvName);
  i := StrToInt(c) - 1;
  Result := b + IntToStr(i);
end;

function TNamRec.Rnd(IvLenght: integer): string;
var
  r: TRndRec;
begin
  Result := str.Proper(r.Str(IvLenght));
end;

function TNamRec.RndCsv(IvListLenght, IvNameLenght: integer): string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to IvListLenght-1 do
    Result := Result + ', ' + Rnd(IvNameLenght);
  Delete(Result, 1, 2);
end;

function TNamRec.RndPostfix(IvPostfix: string; IvLenght: integer): string;
begin
  Result := Rnd(IvLenght) + IvPostfix;
end;

function TNamRec.RndPrefix(IvPrefix: string; IvLenght: integer): string;
begin
  Result := IvPrefix + Rnd(IvLenght);
end;

function TNamRec.Std(IvName, IvPostfix: string): string;
begin
  if IvName = '' then
    Result := Rnd
  else
    Result := IvName;
  if IvPostfix <> '' then
    Result := Result + IvPostfix;
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
  x: TDbaCls;
begin
  x := TDbaCls.Create(FDManager);
  try
    t := x.Tbl(IvObject, IvObject);
    f := x.Fld(IvObject);
    x.HIdFromIdOrPath(t, f, IvIdOrPath, i, k);
    w := Format('FldId = %d', [i]);
    Result := x.RecExists(t, w, k);
  finally
    FreeAndNil(x);
  end;
end;

function TObjRec.DbaContentGet(IvObject, IvIdOrPath, IvDefault: string): string; // *** use FldGet ***
var
  t, f, q, c, k: string; // tbl, fld, sql, content
  i: integer;
  x: TDbaCls;
begin
  x := TDbaCls.Create(FDManager);
  try
    t := x.Tbl(IvObject, IvObject);
    f := x.Fld(IvObject);
    i := x.HIdFromIdOrPath(t, f, IvIdOrPath);
    q := Format('select FldContent from %s where FldId = %d', [t, i]);
    c := x.ScalarFD(q, IvDefault, k);
    c := str.CommentRemove(c);
    c := str.EmptyLinesRemove(c);
    c := rva.Rv(c, true); // encapsulate Rv, CommentRemuve, etc. in a sys.Compile o similar
    Result := iif.NxD(c, IvDefault);
  finally
    FreeAndNil(x);
  end;
end;

function TObjRec.DbaContentSet(IvObject, IvIdOrPath, IvValue: string): boolean;
var
  t, f, v, q, k: string; // tbl, fld, value, sql
  i, z: integer;
  x: TDbaCls;
begin
  x := TDbaCls.Create(FDManager);
  try
    t := x.Tbl(IvObject, IvObject);
    f := x.Fld(IvObject);
    i := x.HIdFromIdOrPath(t, f, IvIdOrPath);
    v := sql.Val(IvValue);
    q := Format('update %s set FldContent = %s where FldId = %d', [t, v, i]);
    Result := x.ExecFD(q, z, k); // *** WARNING might delete comments ***
  finally
    FreeAndNil(x);
  end;
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
  Screen.Cursor := crHourGlass;
  try
  // TEMPORARYCOMMENT
//  Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapParamExists(IvIdOrPath, IvFbk);
  finally
    Screen.Cursor := crDefault;
  end;
end;

function TObjRec.RioContentGet(IvObject, IvIdOrPath, IvDefault: string): string;
begin
  Result := '';
  raise Exception.Create(NOT_IMPLEMENTED_STR);
end;

function TObjRec.RioContentSet(IvObject, IvIdOrPath, IvValue: string): boolean;
begin
  Result := false;
  raise Exception.Create(NOT_IMPLEMENTED_STR);
end;

function TObjRec.RioParamGet(IvObject, IvIdOrPath: string; IvDefault: string): string;
var
  k: string;
begin
  Screen.Cursor := crHourGlass;
  try
  // TEMPORARYCOMMENT
//  {o :=} (rio.HttpRio as ISystemSoapMainService).SystemSoapParamGet(IvIdOrPath, Result, IvDefault, k);
  finally
    Screen.Cursor := crDefault;
  end;
end;

function TObjRec.RioParamSet(IvObject, IvIdOrPath: string; IvValue: string): boolean;
var
  k: string;
begin
  Screen.Cursor := crHourGlass;
  try
  // TEMPORARYCOMMENT
//  {o :=} (rio.HttpRio as ISystemSoapMainService).SystemSoapParamSet(IvIdOrPath, IvValue, k);
  finally
    Screen.Cursor := crDefault;
  end;
end;

function TObjRec.RioSwitchGet(IvObject, IvIdOrPath: string; IvDefault: boolean): boolean;
begin
  Result := false;
  raise Exception.Create(NOT_IMPLEMENTED_STR);
end;

function TObjRec.RioSwitchSet(IvObject, IvIdOrPath: string; IvValue: boolean): boolean;
begin
  Result := false;
  raise Exception.Create(NOT_IMPLEMENTED_STR);
end;
{$ENDREGION}

{$REGION 'TOpsRec'}
function TOpsRec.ProcessIdGet: cardinal; register; assembler;
{$IFDEF 32BIT}
asm
  mov eax, FS:[$20]
end;
{$ELSE}
begin
  Result := Winapi.Windows.GetCurrentProcessId;
end;
{$ENDIF}

function TOpsRec.ThreadIdGet: cardinal; register; assembler;
{$IFDEF 32BIT}
asm
  mov eax, FS:[$24]
end;
{$ELSE}
begin
  Result := Winapi.Windows.GetCurrentThreadID;
end;
{$ENDIF}
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
  x: TDbaCls;
begin
  x := TDbaCls.Create(FDManager);
  try

    {$REGION 'DbaOrganization'}
    x.DbaCreateIfNotExists('DbaOrganization', IvFbk);
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
    if x.TblCreateIfNotExists('DbaOrganization', 'TblOrganization', q, IvFbk) then begin
    //DbaCls.RecDefaultInsert('DbaOrganization.dbo.TblOrganization', IvFbk);
    //DbaCls.RecTestInsert('DbaOrganization.dbo.TblOrganization', ['FldOrganization'], ['Wks'], IvFbk);
    end;
    {$ENDREGION}

    {$REGION 'End'}
    IvFbk := 'Organization database initialized';
    Result := true;
    {$ENDREGION}

  finally
    FreeAndNil(x);
  end;
end;

function TOrgRec.DbaInsert(var IvFbk: string): boolean;
var
  q, k: string;
  z: integer;
  x: TDbaCls;
begin
  x := TDbaCls.Create(FDManager);
  try

    {$REGION 'Insert'}
    Id := x.TblIdNext('DbaOrganization.dbo.TblOrganization');
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
    Result := x.ExecFD(q, z, k);
    if not Result then begin
      IvFbk := k;
    end else
      IvFbk := Format('Organization %s record inserted', [Organization]);
    {$ENDREGION}

  finally
    FreeAndNil(x);
  end;
end;

function TOrgRec.DbaSelect(const IvOrganization: string; var IvFbk: string): boolean;
var
  d: TFDDataSet;
  q: string;
  x: TDbaCls;
begin
  x := TDbaCls.Create(FDManager);
  try

    // key
    Organization := IvOrganization;

    {$REGION 'Insert'}
    if not x.RecExists('DbaOrganization.dbo.TblOrganization', 'FldOrganization', Organization, IvFbk) then begin
    //ods('Organization record does not exists, create it now');
      PId := ROOT_NEW_ID;
      DbaInsert(IvFbk);
    end;
    {$ENDREGION}

    {$REGION 'Select'}
    try
      q := Format('select * from DbaOrganization.dbo.TblOrganization where FldOrganization = ''%s''', [Organization]);
      Result := x.DsFD(q, d, IvFbk);
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

  finally
    FreeAndNil(x);
  end;
end;

function TOrgRec.DiskPath: string;
begin
  Result := sys.ORG_DIR + AlphaPath('\');
end;

function TOrgRec.DskInit(var IvFbk: string): boolean;
begin
  raise Exception.Create(NOT_IMPLEMENTED_STR);
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
    Screen.Cursor := crHourGlass;
    try
    // TEMPORARYCOMMENT
//  Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapOrganizationGet(IvOrganization, r, IvFbk);
    finally
      Screen.Cursor := crDefault;
    end;

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

{$REGION 'TPerRec'}
function TPerRec.DbaSelect(var IvFbk: string; IvInsertIfNotExist: boolean): boolean;
var
  q: string;
  d: TFDDataSet;
  x: TDbaCls;
begin
  x := TDbaCls.Create(FDManager);
  try
    try

      {$REGION 'Dba'}
    //q := 'select * from DbaPerson.dbo.TblPerson where FldPerson = ''' + Person + '''';
      q :=           'select p.FldId, -1 as FldPId, u.FldUsername as FldPerson, FldName, FldSurname, FldEmail'
      + sLineBreak + 'from DbaPerson.dbo.TblPerson p inner join'
      + sLineBreak + '     DbaUser.dbo.TblUser u on (u.FldId = p.FldId)'
      + sLineBreak + 'where u.FldUsername = ''' + Person + '''';
      Result := x.DsFD(q, d, IvFbk);
      try
        Id           := d.FieldByName('FldId'         ).AsInteger;
        PId          := d.FieldByName('FldPId'        ).AsInteger;
        Person       := d.FieldByName('FldPerson'     ).AsString;
        Name         := d.FieldByName('FldName'       ).AsString;
        Surname      := d.FieldByName('FldSurname'    ).AsString;
        Email        := d.FieldByName('FldEmail'      ).AsString;
      finally
        FreeAndNil(d);
      end;
      {$ENDREGION}

      IvFbk  := 'Person selected';
      Result := true;

    except
      on e: Exception do begin
        IvFbk  := str.E(e);
        Result := false;
      end;
    end;
  finally
    FreeAndNil(x);
  end;

  {$REGION 'InsertIfNotExist'}
//  if IvInsertIfNotExist then
//    if not DbaExists(IvFbk) then begin
//      Init(Surname, Name);
//      DbaInsert(IvFbk);
//    end;
  {$ENDREGION}

  {$REGION 'Check'}
  Result := HasKey(IvFbk);
  if not Result then
    Exit;
  {$ENDREGION}

end;

function TPerRec.FullName: string;
begin
  Result := Format('%s %s', [Name, Surname]);
end;

function TPerRec.HasKey(var IvFbk: string): boolean;
begin
  Result := Person <> '';
  if Result then
    IvFbk := Format('Person has key %s', [Person])
  else
    IvFbk := 'Person has no valid key';
end;

function TPerRec.PathAlpha(IvPerson: string): string;
var
  p: string;
begin
  p := iif.NxD(IvPerson, Person);
  Result := Format('%s\%s', [sys.PER_DIR, UpperCase(p[1])]);
end;

function TPerRec.PicturePath(IvPerson: string): string;
var
  p: string;
begin
  p := iif.NxD(IvPerson, Person);
  Result := Format('%s\%s.png', [PathAlpha(p), p]);
  if not FileExists(Result) then
    img.DbaToDisk(Result, 'DbaPerson.dbo.TblPerson', 'FldPicture', Format('FldPerson = ''%s''', [p]));
//Result := '/WksImageIsapiProject.dll/Image?CoFrom=Person&CoName=' + IvPerson;
end;

function TPerRec.PictureUrl(IvPerson: string): string;
var
  p: string;
begin
  p := iif.NxD(IvPerson, Person);
  Result := Format('%s/%s.png', [UrlAlpha(p), p]);
end;

function TPerRec.SoapServerInfo(var IvFbk: string): boolean;
begin
  Screen.Cursor := crHourGlass;
  try
    // TEMPORARYCOMMENT
//    Result := (rio.HttpRio as IPersonSoapMainService).PersonSoapInfo(IvFbk);
  finally
    Screen.Cursor := crDefault;
  end;
end;

function TPerRec.UrlAlpha(IvPerson: string): string;
var
  p: string;
begin
  p := iif.NxD(IvPerson, Person);
  Result := srv.ObjUrl('Person',  '/' + UpperCase(p[1]));
end;
{$ENDREGION}

{$REGION 'TPopRec'}
function TPopRec.DbaSelect(var IvFbk: string): boolean;
begin
  IvFbk  := NOT_IMPLEMENTED_STR;
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
  Screen.Cursor := crHourGlass;
  try
 // TEMPORARYCOMMENT
//   Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapPop3Get(IvOrganization, h, p, u, w, IvFbk);
  finally
    Screen.Cursor := crDefault;
  end;

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

{$REGION 'TPwdRec'}
function TPwdRec.DbaChange(IvOrganization, IvUsername, IvPasswordOld, IvPasswordNew: string; var IvFbk: string): boolean;
begin
  IvFbk  := NOT_IMPLEMENTED_STR;
  Result := false;
  raise Exception.Create(NOT_IMPLEMENTED_STR);
end;

function TPwdRec.DbaMatch(IvOrganization, IvUsername, IvPassword: string; var IvFbk: string): boolean;
begin
  IvFbk  := NOT_IMPLEMENTED_STR;
  Result := false;
  raise Exception.Create(NOT_IMPLEMENTED_STR);
end;

function TPwdRec.Decode(IvPassword: string): string;
var
  s, t: string;
begin
  s := IvPassword;
  t := str.Reverse(s);
  Result := str.CharShift(t, +1);
end;

function TPwdRec.Encode(IvPassword: string): string;
var
  s, t: string;
begin
  s := IvPassword;
  t := str.CharShift(s, -1);
  Result := str.Reverse(t);
end;

function TPwdRec.Generate(IvLength: integer; IvUseLower, IvUseUpper, IvUseNumber, IvUseWierd: boolean): string;
var
  i: byte;
  s: string;
begin
  // init
  Randomize;
  Result := '';
  s := '';

  // chars
  if IvUseUpper  then s :=     'ABCDEFGHIJKLMNOPQRSTUVWXYZ'; // if you want to use the 'A..Z' characters
  if IvUseLower  then s := s + 'abcdefghijklmnopqrstuvwxyz'; // if you want to use the 'a..z' characters (also)
  if IvUseNumber then s := s + '0123456789';                 // if you want to use the '0..9' characters (also)
  if IvUseWierd  then s := s + '_@#$%^&+-*{[()]};:<>\|/?';   // if you want to use the '@..?' characters (also)
  if s = '' then
    Exit;

  // return
  for i := 0 to IvLength-1 do
    Result := Result + s[Random(Length(s){-1})+1];
end;

function TPwdRec.GenerateWord(IvLanguage: string; var IvPassword, IvFbk: string): boolean;
//var
//  r: TWordRem;
begin
  // get with spaces
//r := TWordRem.Create;
//Result := WordDbaSelectRnd(r, IvFbk);
//if Result then begin
//  if      IvLanguage = 'Spanish' then
//    IvPassword := r.Spanish
//  else if IvLanguage = 'Italian' then
//    IvPassword := r.Italian
//  else if IvLanguage = 'German' then
//    IvPassword := r.German
//  else if IvLanguage = 'French' then
//    IvPassword := r.French
//  else
//    IvPassword := r.English;
//end else
//  IvPassword := RndPassword;
//r.Free;

  // get no spaces
  IvPassword := 'Word'; // WordDbaSelectRnd2(IvLanguage, IvPassword, IvFbk);

  // clean
  IvPassword := IvPassword.Replace(' ', '');
  IvPassword := IvPassword.Replace('-', '');
  IvPassword := IvPassword.Replace('''', '');
  IvPassword := IvPassword.Replace('`', '');
  IvPassword := IvPassword.Replace('à', 'a');
  IvPassword := IvPassword.Replace('á', 'a');
  IvPassword := IvPassword.Replace('â', 'a');
  IvPassword := IvPassword.Replace('ã', 'a');
  IvPassword := IvPassword.Replace('ä', 'a');
  IvPassword := IvPassword.Replace('å', 'a');
  IvPassword := IvPassword.Replace('æ', 'a');
  IvPassword := IvPassword.Replace('ç', 'c');
  IvPassword := IvPassword.Replace('è', 'e');
  IvPassword := IvPassword.Replace('é', 'e');
  IvPassword := IvPassword.Replace('ê', 'e');
  IvPassword := IvPassword.Replace('ë', 'e');
  IvPassword := IvPassword.Replace('ì', 'i');
  IvPassword := IvPassword.Replace('í', 'i');
  IvPassword := IvPassword.Replace('î', 'i');
  IvPassword := IvPassword.Replace('ï', 'i');
  IvPassword := IvPassword.Replace('ð', 'o');
  IvPassword := IvPassword.Replace('ñ', 'n');
  IvPassword := IvPassword.Replace('ò', 'o');
  IvPassword := IvPassword.Replace('ó', 'o');
  IvPassword := IvPassword.Replace('ô', 'o');
  IvPassword := IvPassword.Replace('õ', 'o');
  IvPassword := IvPassword.Replace('ö', 'o');
  IvPassword := IvPassword.Replace('ø', '');
  IvPassword := IvPassword.Replace('ù', 'u');
  IvPassword := IvPassword.Replace('ú', 'u');
  IvPassword := IvPassword.Replace('û', 'u');
  IvPassword := IvPassword.Replace('ü', 'u');
  IvPassword := IvPassword.Replace('ý', 'y');
  IvPassword := IvPassword.Replace('þ', 'b');
  IvPassword := IvPassword.Replace('ÿ', 'y');

  // end
  IvFbk := Format('Password %s lite generated', [IvPassword]);
  Result := true;
end;

function TPwdRec.IsSecure(IvPassword: string; var IvFbk: string): boolean;
begin
  Result := Length(IvPassword) >= PWD_MIN_LEN;
  IvFbk := fbk.IsSecureStr('Password', IvPassword, Result);
  if not Result then
    IvFbk := IvFbk + Format(', it have to be at least %d digits', [IvPassword, PWD_MIN_LEN]);
end;

function TPwdRec.RioChange(IvOrganization, IvUsername, IvPasswordOld, IvPasswordNew: string; var IvFbk: string): boolean;
begin
  Screen.Cursor := crHourGlass;
  try
  // TEMPORARYCOMMENT
//  Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapPasswordChange(IvOrganization, IvUsername, IvPasswordOld, IvPasswordNew, IvFbk);
  finally
    Screen.Cursor := crDefault;
  end;
end;

function TPwdRec.RioRecover(IvOrganization, IvUsername: string; var IvFbk: string): boolean;
begin
  Screen.Cursor := crHourGlass;
  try
  // TEMPORARYCOMMENT
//  Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapPasswordRecover(IvOrganization, IvUsername, IvFbk);
  finally
    Screen.Cursor := crDefault;
  end;
end;

function TPwdRec.RioReset(IvOrganization, IvUsername: string; var IvFbk: string): boolean;
begin
  Screen.Cursor := crHourGlass;
  try
  // TEMPORARYCOMMENT
//  Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapPasswordReset(IvOrganization, IvUsername, IvFbk);
  finally
    Screen.Cursor := crDefault;
  end;
end;

function TPwdRec.StrongScore(IvPassword: string; var IvFbk: string): integer;
begin
  // length
  if Length(IvPassword) > 8 then
    Result := 5
  else begin
    IvFbk := 'Password must be 8 or more characters long';
    Result := 0;
    Exit;
  end;

  // haslower
  if TRegEx.IsMatch(IvPassword, '[a-z]') then
    Result := Result + 1
  else begin
    IvFbk := 'Password need to have at least 1 lowercase character';
    Result := 0;
    Exit;
  end;

  // hasupper
  if TRegEx.IsMatch(IvPassword, '[A-Z]') then
    Result := Result + 3
  else begin
    IvFbk := 'Password need to have at least 1 uppercase character';
    Result := 0;
    Exit;
  end;

  // hasdigit
  if not TRegEx.IsMatch(IvPassword, '\d') then
    Result := Result + 1
  else begin
    IvFbk := 'Password need to have at least 1 digit character';
    Result := 0;
    Exit;
  end;

  // haswierd
  if not TRegEx.IsMatch(IvPassword, '[_@#$%^&+-*{[()]};:<>\|/?]') then
    Result := Result + 1
  else begin
    IvFbk := 'Password need to have at least one of the following character: _@#$%^&+-*{[()]};:<>\|/?';
    Result := 0;
  end;

  // end
  IvFbk := Format('Password is strong enough with score %d', [Result]);
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
  //ods('TREXREC.REPLACEEX', Format('%d) Match = %s', [j, m.Value]));

    // walkgroups
    for k := 1 to m.Groups.Count - 1 do begin // group 0 is the entire match, so count will always be at least 1 for a match
      g := m.Groups[k].Value;
    //ods('TREXREC.REPLACEEX', Format('%d.%d) Group = %s', [j, k, m.Groups[k].Value]));

      // out
      o := m.Value; // m.Groups[0].Value
    //ods('TREXREC.REPLACEEX', Format('%d.%d) Out = %s', [j, k, o]));

      // in
    //i := Format(IvStringWithOnePlaceholderIn, [g]);
      i := StringReplace(IvStringWithOnePlaceholderIn, '%s', g, [rfReplaceAll]);
    //ods('TREXREC.REPLACEEX', Format('%d.%d) In = %s', [j, k, i]));

      // replace
      IvString := StringReplace(IvString, o, i, [rfReplaceAll]);
    //ods('TREXREC.REPLACEEX', Format('IvText = %s', [IvText]));
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
  Screen.Cursor := crHourGlass;
  try
  // TEMPORARYCOMMENT
//  Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapFieldGet(usr.Organization, usr.Username, ses.Session, IvDot, IvId, IvValue, IvDefault, IvFbk);
  finally
    Screen.Cursor := crDefault;
  end;
end;

function TRioRec.FieldGetWhere(const IvDot: string; IvWhere: string; var IvValue: variant; IvDefault: variant; var IvFbk: string): boolean;
begin
  Screen.Cursor := crHourGlass;
  try
  // TEMPORARYCOMMENT
//  Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapFieldGetWhere(usr.Organization, usr.Username, ses.Session, IvDot, IvWhere, IvValue, IvDefault, IvFbk);
  finally
    Screen.Cursor := crDefault;
  end;
end;

function TRioRec.FieldSet(const IvDot: string; IvId: integer; const IvValue: variant; var IvFbk: string): boolean;
begin
  Screen.Cursor := crHourGlass;
  try
  // TEMPORARYCOMMENT
//  Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapFieldSet(usr.Organization, usr.Username, ses.Session, IvDot, IvId, IvValue, IvFbk);
  finally
    Screen.Cursor := crDefault;
  end;
end;

function TRioRec.FieldSetWhere(const IvDot: string; IvWhere: string; const IvValue: variant; var IvFbk: string): boolean;
begin
  Screen.Cursor := crHourGlass;
  try
  // TEMPORARYCOMMENT
//  Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapFieldSetWhere(usr.Organization, usr.Username, ses.Session, IvDot, IvWhere, IvValue, IvFbk);
  finally
    Screen.Cursor := crDefault;
  end;
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
  Screen.Cursor := crHourGlass;
  try
  // TEMPORARYCOMMENT
//  Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapIdExists(IvDot, IvId, IvFbk);
  finally
    Screen.Cursor := crDefault;
  end;
end;

function TRioRec.IdMax(const IvTable, IvWhere: string; var IvIdMax: integer; var IvFbk: string): boolean;
begin
  Screen.Cursor := crHourGlass;
  try
  // TEMPORARYCOMMENT
//  Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapIdMax(IvTable, IvWhere, IvIdMax, IvFbk);
  finally
    Screen.Cursor := crDefault;
  end;
end;

function TRioRec.IdNext(const IvTable, IvWhere: string; var IvIdNext: integer; var IvFbk: string): boolean;
begin
  Screen.Cursor := crHourGlass;
  try
  // TEMPORARYCOMMENT
//  Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapIdNext(IvTable, IvWhere, IvIdNext, IvFbk);
  finally
    Screen.Cursor := crDefault;
  end;
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
  Screen.Cursor := crHourGlass;
  try
  // TEMPORARYCOMMENT
//  Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapOIdIdExists(IvDot, IvOFld, IvOId, IvId, IvFbk);
  finally
    Screen.Cursor := crDefault;
  end;
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
  Result := IvBegin + Random(Abs(IvEnd - IvBegin));
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

{$REGION 'TRvaRec'}
function TRvaRec.RvFunction2(f, a: TStringVector): string;
var
  i, id: integer; // counter, id
  wv: TTkvVec; // webrequest
  a0, fc, q, k: string; // a[0], f[0]+f[1]+...
begin

  {$REGION 'init'}
  Result := '';

  if length(f) = 0 then
    Exit;

  if length(a) = 0 then
    SetLength(a, 1);

  fc := vec.Collapse(f);
  {$ENDREGION}

  {$REGION 'Contact'}
  if SameText(f[0], 'Contact') then begin

    {$REGION 'Default'}
    if iis.Nx(a[0]) then
      a[0] := org.Organization;
    {$ENDREGION}

    {$REGION 'FromDba'}
//    q := Format('select Fld%s from DbaContact.dbo.TblContact where FldOwner = ''%s'' and FldOrder = 0', [f[1], a[0]]);
//    Result := IvDbaCls.ScalarFD(q, '', k);
    {$ENDREGION}

//else if  f.StartsWith('Contact') then begin
//       if  f = 'ContactId'                          then r := AvCtcRec.Id.ToString
//  else if  f = 'ContactPId'                         then r := AvCtcRec.PId.ToString
//  else if  f = 'ContactOwner'                       then r := AvCtcRec.Owner
//  else if  f = 'ContactContact'                     then r := AvCtcRec.Contact
//  else if  f = 'ContactState'                       then r := AvCtcRec.State
//  else if  f = 'ContactAddress'                     then r := AvCtcRec.Address
//  else if  f = 'ContactPhone'                       then r := AvCtcRec.Phone
//  else if  f = 'ContactFax'                         then r := AvCtcRec.Fax
//  else if  f = 'ContactMobile'                      then r := AvCtcRec.Mobile
//  else if  f = 'ContactEmail'                       then r := AvCtcRec.Email
//  else if  f = 'ContactMap'                         then r := AvCtcRec.Map
//  else if  f = 'ContactOrder'                       then r := AvCtcRec.Order.ToString
//  ;
//end
  {$ENDREGION}

  {$REGION 'dat'}
  end else if SameText(f[0], 'Dat') then begin

    {$REGION 'Default'}
    {$ENDREGION}

    {$REGION 'dat'}
//       if  fc = 'DatTimeRnd'                                                  then Result := TimeToStr(dat.TimeRnd) // [RvDtNow(+/-float)] ex: [RvDtNow(7)] -> Now+7 , [RvDtNow(-14.54)] -> Now-14.54
//  else if  fc = 'DatDateRnd'                                                  then Result := DateToStr(dat.DateRnd)
//  else if  fc = 'DatDateTimeRnd'                                              then Result := DateTimeToStr(dat.DateTimeRnd)
    // now
//  else if  fc = 'DatTimeNow'                                                  then Result := TimeToStr(dat.TimeNow(StrToFloatDef(a[0], 0.0)))
//  else if  fc = 'DatDateNow'                                                  then Result := DateToStr(dat.DateNow(StrToFloatDef(a[0], 0.0)))
//  else if (fc = 'DatDateTimeNow') or (f = 'Now')                              then Result := DateTimeToStr(dat.DateTimeNow(StrToFloatDef(a[0], 0.0)))
//  else if  fc = 'DatNowCode'                                                  then Result := dat.DateTimeToCode(Now)
    // year
         if  fc = 'DatYearNow'                                                  then Result := dat.YearNow(StrToIntDef(a[0], 0)).ToString
    else if  fc = 'DatYearStart'                                                then Result := NOT_IMPLEMENTED_STR
    else if  fc = 'DatYearEnd'                                                  then Result := NOT_IMPLEMENTED_STR
    // quarter
    else if  fc = 'DatQuarterNow'                                               then Result := NOT_IMPLEMENTED_STR
    else if  fc = 'DatQuarterStart'                                             then Result := NOT_IMPLEMENTED_STR
    else if  fc = 'DatQuarterEnd'                                               then Result := NOT_IMPLEMENTED_STR
    // month
//  else if  fc = 'DatMonthNow'                                                 then Result := dat.MonthNow(StrToIntDef(a[0], 0)).ToString
    else if  fc = 'DatMonthStart'                                               then Result := NOT_IMPLEMENTED_STR
    else if  fc = 'DatMonhtEnd'                                                 then Result := NOT_IMPLEMENTED_STR
    // week
//  else if  fc = 'DatWeekNow'                                                  then Result := dat.WeekNow(StrToIntDef(a[0], 0)).ToString
    else if  fc = 'DatWeekDay'                                                  then Result := NOT_IMPLEMENTED_STR
    else if  fc = 'DatWeekStart'                                                then Result := NOT_IMPLEMENTED_STR
    else if  fc = 'DatWeekEnd'                                                  then Result := NOT_IMPLEMENTED_STR
    // day
    else if  fc = 'DatDayNow'                                                   then Result := NOT_IMPLEMENTED_STR // RvDay() -> actualday, RvDay(-3) -> actualday-3, RvDay('09/16/2016 11:00:00') -> 16
    else if  fc = 'DatDayStart'                                                 then Result := NOT_IMPLEMENTED_STR
    else if  fc = 'DatDayEnd'                                                   then Result := NOT_IMPLEMENTED_STR
    // timing
  //else if  fc = 'DatElapsedSec'                                               then Result := FloatToStr(--FWat.ElapsedMilliseconds / 1000) *** no, use local ***
    ;
    {$ENDREGION}

  {$ENDREGION}

  {$REGION 'htm'}
  end else if SameText(f[0], 'Htm') then begin

    {$REGION 'Report'}
    if          SameText(f[1], 'Report') then begin
      Result := htm.Report(a[0].ToInteger);
    {$ENDREGION}

    {$REGION 'Select'}
    end else if SameText(f[1], 'Select') then begin
      Result := NOT_IMPLEMENTED_STR;
    end;
    {$ENDREGION}

  {$ENDREGION}

  {$REGION 'org'}
  end else if SameText(f[0], 'Organization') or SameText(f[0], 'Org') then begin

    {$REGION 'Default'}
    if length(f) = 1 then begin // transform [RvOrganization()] into [RvOrganizationOrganization()]
      SetLength(f, 2);
      f[1] := f[0];
    end;
    {$ENDREGION}

    {$REGION 'FromDba'}
//    id := IvDbaCls.HIdFromIdOrPath('DbaOrganization.dbo.TblOrganization', 'FldOrganization', a[0]);         // [RvOrganizationSlogan()]
//    id := org.Id;                                                                                      // [RvOrganizationField(Root/W/Wks, Slogan)]
//    q := Format('select Fld%s from DbaOrganization.dbo.TblOrganization where FldId = %d', [f[1], id]);
//    Result := IvDbaCls.ScalarFD(q, '', k);
    {$ENDREGION}

  {$ENDREGION}

  {$REGION 'Page'}
  end else if SameText(f[0], 'Page') then begin

    {$REGION 'Default'}
    {
    if length(f) = 1 then begin // transform [RvPage()] into [RvPageContent()]
      SetLength(f, 2);
      f[1] := 'Url';
    //f[1] := 'Content';
    end;
    }
    {$ENDREGION}

    {$REGION 'Url'}
    if          SameText(f[1], 'Url') then begin
      if str.IsInteger(a[0]) then
        Result := Format('%s/Page?CoId=%s', [wre.ScriptName, a[0]])  // [RvPageUrl(123)]
      else if str.IsPath(a[0]) then
        Result := Format('%s/Page?CoId=%s', [wre.ScriptName, a[0]])  // [RvPageUrl(Root/Organization/W/Wks/Home)] / [RvPageUrl(/Home)]
      else
        Result := Format('%s/%s'          , [wre.ScriptName, a[0]]); // handle explicit webactions like localhost/WksIsapiProject.dll/Info or /Login
    {$ENDREGION}

    {$REGION 'FromDba'}
    end else begin
//      id := IvDbaCls.HIdFromIdOrPath('DbaPage.dbo.TblPage', 'FldPage', a[0]);
//      q := Format('select Fld%s from DbaPage.dbo.TblPage where FldId = %d', [f[1], id]);
//      Result := IvDbaCls.ScalarFD(q, '', k);
    end;
    {$ENDREGION}

    {$REGION 'Zzz'}
    {
         if  f = 'Page'             then r := '?CoId=' + a[0]                                          // 123 | Root/Organization/W/Wks
  //else if  f = 'PageSystem'       then r := '?CoId=' + a[0]                                          //
    else if  f = 'PageTemplate'     then r := '?CoId=Root/Template/' + a[0]                            // + Default/About
    else if  f = 'PageOrganization' then r := Format('?CoId=Root/Organization/%s/%s', [a[0][1], a[0]]) // + Wks/About
    end;
    }
    {$ENDREGION}

  {$ENDREGION}

  {$REGION 'sys'}
  end else if SameText(f[0], 'Sys') then begin

    {$REGION 'Param'}
    if          SameText(f[1], 'Param') then begin
      if not a[0].StartsWith('Root/System/Param/', true) then
        a0 := 'Root/System/Param/' + a[0];
      Result := obj.DbaParamGet('System', a0, a[1]);
    {$ENDREGION}

    {$REGION 'Switch'}
    end else if SameText(f[1], 'Switch') then begin
      Result := BoolToStr(obj.DbaSwitchGet('System', a0, StrToBool(a[1])));
    end;
    {$ENDREGION}

  {$ENDREGION}

  {$REGION 'wre'}
  end else if SameText(f[0], 'Wre') then begin

    {$REGION 'Client'}
    if         SameText(f[1], 'Client') then begin
      if SameText(f[2], 'Addr') then
        Result := wre.ClientAddr
      ;
    {$ENDREGION}

    {$REGION 'Field'}
    end else if SameText(f[1], 'Field') then begin
      wv := wre.TkvVec;
      for i := Low(wv) to High(wv) do begin
        if SameText(a[0], wv[i].Key) then begin
          Result := wv[i].Val;
          Break
        end;
      end;
    {$ENDREGION}

    {$REGION 'Script'}
    end else if SameText(f[1], 'Script') then begin
      if      SameText(f[2], 'Name') then
        Result := wre.ScriptName
      ;
    {$ENDREGION}

    {$REGION 'User'}
    end else if SameText(f[1], 'User') then begin
      if      SameText(f[2], 'Name') then
        Result := wre.Username
      else if SameText(f[2], 'Organization') then
        Result := wre.UserOrganization
      ;
    end;
    {$ENDREGION}

  end;
  {$ENDREGION}

end;

function TRvaRec.RvFunction(IvFunction, IvArgsList: string): string;

  {$REGION 'var'}
var
  i0, i1, i2, i3: integer; // spare
  b0, b1, b2, b3, ok: boolean; // spare
  f, r, s, n, t, l, w, h, m, x, v, u, o, k: string; // func, return, switch, id, name, title, level, width, height, method, action, validator, defaults, optionjson
  q, qs, qi, qd, df: string; // sql, server, instance, databasedef, default
  tbl, id, pid, fc: string; // table, id, pid, fieldcsv
  a: TStringVector; // argsvect
  d: TFDDataSet; //dei: TEdiRec; // dataset, editinfo
//p: TPageRec;
  xx: TDbaCls;
  {$ENDREGION}

begin

  {$REGION 'zip'}
  r := '?';
  f := IvFunction;
  {$ENDREGION}

  {$REGION 'args'}
  a := lst.ToVector(IvArgsList, '|'); // max 12
  if Length(a) < 12 then
    SetLength(a, 12);
  {$ENDREGION}

  {$REGION 'byn'}
  if       f.StartsWith('App') or f.StartsWith('Byn') or (f = 'Version') then begin
         if  f = 'BynInfo'                                                      then r := byn.Info
    else if  f = 'BynCmds'                                                      then r := byn.Cmds
    else if (f = 'BynVersion') or (f = 'AppVersion') or (f = 'Version')         then r := byn.Ver
    else if  f = 'BynFileSpec'                                                  then r := byn.FileSpec
    else if  f = 'BynName'                                                      then r := byn.Name
    else if  f = 'BynNameNice'                                                  then r := byn.NameNice
    else if  f = 'BynRole'                                                      then r := byn.Role
    else if  f = 'BynInfo'                                                      then r := byn.Info
    ;
  end
  {$ENDREGION}

  {$REGION 'cod'}
  else if  f.StartsWith('Code') then begin
         if  f = 'CodeUrl'                                                      then r := '/WksCodeIsapiProject.dll/Code?CoCodeId=' + a[0]
    ;
  end
  {$ENDREGION}

  {$REGION 'col'}
 {else if  f.StartsWith('Color') then begin
         if  f = 'Color'                                                        then r := ColorFromName(a[0]).ToHexString // [RvColor(red)]
    else if  f = 'ColorAgg'                                                     then r := ColorAggFromName(a[0])          // [RvColorAgg(red)]
    else if  f = 'ColorHtml'                                                    then r := ColorHtmlFromName(a[0])         // [RvColorHtml(red)]
  end}
  {$ENDREGION}

  {$REGION 'cry'}
  else if  f.StartsWith('Crypto') then begin
         if  f = 'CryptoCipher'                                                 then r := cry.Cipher(a[0])
    else if  f = 'CryptoDecipher'                                               then r := cry.Decipher(a[0])
    ;
  end
  {$ENDREGION}

  {$REGION 'css'}
  else if  f.StartsWith('Css') then begin
         if  f = 'CssLogoSize'                                                  then r := '48' // AvCssRec.LogoSize // + a[0]
    ;
  end
  {$ENDREGION}

  {$REGION 'dba'}
  else if  f.StartsWith('Dba') then begin
    if f = 'DbaScalar' then begin
      q  := a[0]; // sql
      df := a[1]; // default
      qs := a[2]; // sqlserver
      qi := a[3]; // sqlinstance
      qd := a[4]; // sqldefaultdb
      xx := TDbaCls.Create(FDManager);
      try
        r := xx.ScalarFD(q, df, k);
      finally
        FreeAndNil(xx);
      end;
    end
  //else if f = 'DbaSaUsername'                                                 then r := sys.DBA_SA
  //else if f = 'DbaSaPassword'                                                then r := sys.DBA_SA_PASSWORD
  //else if str.Like(f, 'Dba*.Tbl*.Fld*') and IsNumeric(a[0])                   then r := 'value of FieldZ in record Id in table DbaX.TableY' // [RvDbaX.TblY.FldZ(Id)]
    ;
  end
  {$ENDREGION}

  {$REGION 'fsy'}
//  else if  f.StartsWith('fsy') then begin
//         if  f = 'FsyPathWinToC'                                                 then r := fsy.PathWinToC(a[0])  // X:\$Tmp --> X:\\$Tmp
//    else if  f = 'FsyPathCToWin'                                                 then r := fsy.PathCToWin(a[0]); // X:\\$Tmp --> X:\$Tmp
//    ;
//  end
  {$ENDREGION}

  {$REGION 'htm'}
  else if  f.StartsWith('H') then begin
         if  f = 'HBlog'                                                        then //r := HBlog(a[0], a[1], a[2], a[3])     // [HBlog(giarussi|Title|Text|switches)]
    {
      [RvHForm(
        13                                       // IvId: string
      |                                          // IvDefaultsJson: string = ''
      | Test Form                                // IvTitle: string = ''
      |                                          // IvSwitch: string = ''
      | /SysIsapiProject.dll/FormProcess?CoId=2  // IvAction: string = ''
      |                                          // IvMethod: string = 'post'
      |                                          // IvEnctype: string = ''
      |                                          // IvValidator: string = 'data-toggle="validator"
      )]
    }
//  else if  f = 'HForm'                                                        then r := HForm(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7])
//  else if  f = 'HGallery'                                                     then r := HGallery(a[0]) // [HGallery(dummy)]
    else if  f = 'HGraph'                                                       then begin // [RvHGraph(sqlorid| title| level| width| height| idname| switches| sqlserver| sqlinstance| sqldefaultdb)]
      // params                                                  // [RvHGraph(SqlRepo:Test|Test Graph|1|240|120|CoGraph)]
      q := a[0];   // sqlorid
//      if str.Has(q, 'SqlRepo:') then
//        q := SqlRepo(q);
      t   := a[1]; // title
      l   := a[2]; // level 0=h1,1=h2...
      w   := a[3]; // width
      h   := a[4]; // height
      n   := a[5]; // idname
      s   := a[6]; // switch
      qs  := a[7]; // sqlserver
      qi  := a[8]; // sqlinstance
      qd  := a[9]; // sqldefaultdb
      // dba
      xx := TDbaCls.Create(FDManager);
      try
        ok := xx.DsFD(q, d, k);
        if not ok then
          r := k // HAlertW(k)
        else begin
        //LogDs(d, 'Info');
//          r := HGraph(d, t, StrToIntDef(l, 1), w, h, n, s);
        end;
      finally
        d.Free;
        FreeAndNil(xx);
      end;
    end
//  else if  f = 'HImg'                                                         then r := HImg(a[0], a[1], a[2], a[3]) // [RvHImg(source| alt| link| switches)]
//  else if  f = 'HPanel'                                                       then r := HPanel(a[0], a[1], a[2], a[3], a[4])       // [RvHPanel(body| header| header2| footer| switches)]
//  else if  f = 'HCollaps'                                                     then r := HCollaps(a[0], a[1], a[2].ToInteger, a[3]) // [RvHCollaps(header| body| level| switches:[+b=button, def=h1])]
//  else if  f = 'HProgress'                                                    then r := HProgress(a[0].ToInteger, a[1], a[2], a[3], a[4])
    else if  f = 'HRepeat'                                                      then begin // [HRepeat(html-template-with-$FldAaa$| Sql)]
      t := a[0]; // template
      q := a[1];
//      if str.Has(q, 'SqlRepo:') then
//        q := SqlRepo(q);
      q := Rv(q); // *** recursive ***
      xx := TDbaCls.Create(FDManager);
      try
        ok := xx.DsFD(q, d, k);
        if (not ok) or (d.IsEmpty) then
          r := k // HAlertW(k)
        else begin
        //LogDs(d, 'Info');
//          r := htm.HRepeat(t, d);
        end;
      finally
        d.Free;
        FreeAndNil(xx);
      end;
    end
//  else if  f = 'HReport'                                                      then r := HReport(a[0], a[1]) // [HReport(id| switches)]
    else if  f = 'HTable'                                                       then begin // [RvHTable(sqloridords | editinfo| title    | idname    | level| switches| sqlserver| sqlinstance| sqldefaultdb)]
      // params                                      // [RvHTable(SqlRepo:Test|         |Test Table|CoTestTable|2     |-#)]
      q := a[0];                                     // sqloridords
//      if str.Has(q, 'SqlRepo:') then
//        q := SqlRepo(q);
      edi.LoadFrom(false, '', '', '', '', a[1]); // editinfo | dataseteditinfo, incomplete, for now just the legacy editini
      t   := a[2];                                   // title
      n   := a[3];                                   // idname
      l   := a[4];                                   // level 0=h1,1=h2...
      s   := a[5];                                   // switch
      qs  := a[6];                                   // sqlserver
      qi  := a[7];                                   // sqlinstance
      qd  := a[8];                                   // sqldefaultdb
      // dba
      xx := TDbaCls.Create(FDManager);
      try
        ok := xx.DsFD(q, d, k);
        if not ok then
          r := k // HAlertW(k)
        else begin
        //LogDs(d, 'Info');
//          r := htm.HTable(d, dei, t, n, '', '', StrToIntDef(l, 1), s);
        end;
      finally
        d.Free;
        FreeAndNil(xx);
      end;
    end
    else if  f = 'HTreeView'                                                    then begin // [RvHTreeView(0.table                  |1.fieldscsv           |2.rootid|3.optionjson                                  |4.editinfo|5.title |6.coname  |7.level|8.switches|9.sqlserver|10.sqlinstance|11.sqldefaultdb)]
      // params                                                  // [RvHTreeView(DbaMember.dbo.TblActivity|FldActivity as FldText|100     |{backColor: "#FFFFFF", borderColor: "#FF0000"}|          |TreeView|CoTreeView|2      )]
      tbl := a[0];                                   // table
      fc  := ',' + iif.NxD(a[1], 'FldText');          // fieldcsv
      while Pos(', ', fc) > 0 do
        fc  := str.Replace(fc, ', ', ',');
      fc  := str.Replace(fc, ',', ', a.');
      id  := a[2];                                   // rootid
      q   :=         'with cte as ('                 // sql
      + sLineBreak + '    select a.FldId, a.FldPId, FldState,            0 as FldLevel, cast(a.FldId as varchar(255))                                         as FldPath' + fc + ' from ' + tbl + ' a where FldId = ' + id
      + sLineBreak + '    union all'
      + sLineBreak + '    select a.FldId, a.FldPId, a.FldState, FldLevel+1 as FldLevel, cast(FldPath + ''.'' + cast(a.FldId as varchar(255)) as varchar(255)) as FldPath' + fc + ' from ' + tbl + ' a inner join cte b on (a.FldPId = b.FldId)'
      + sLineBreak + ')'
      + sLineBreak + 'select * from cte order by  FldLevel, FldText'; // FldPath - , replicate('-', FldLevel * 4) + FldActivity
      o   := a[3];                                   // optionjson
      edi.LoadFrom(false, '', '', '', '', a[4]); // editinfo | dataseteditinfo, incomplete, for now just the legacy editini
      t   := a[5];                                   // title
      n   := a[6];                                   // coname
      l   := a[7];                                   // level 0=h1,1=h2...
      s   := a[8];                                   // switch
      qs  := a[9];                                   // sqlserver
      qi  := a[10];                                  // sqlinstance
      qd  := a[11];                                  // sqldefaultdb
      // dba
      xx := TDbaCls.Create(FDManager);
      try
        ok := xx.DsFD(q, d, k);
        if not ok then
          r := k // HAlertW(k)
        else begin
        //LogDs(d, 'Info');
        //if iis.Nx(t) then
          //t := d.FieldByName('FldText').AsString;
//          r := HTreeView(d, StrToIntDef(id, -1), o, dei, t, n, '', '', StrToIntDef(l, 1), s, '');
        end;
      finally
        d.Free;
        FreeAndNil(xx);
      end;
    end
//    else if  f = 'HH'                                                           then r := HH(a[0], a[1], a[2])                   // [HH(title| subtitle| switches)]
//    else if  f = 'HTextLevel'                                                   then r := HTextLevel(a[0], StrToIntDef(a[1], 0)) // [HTextLevel(text| level)]
//    else if  f = 'HP'                                                           then r := HP(a[0], a[1])                         // [HP(text| switches)]
//    else if  f = 'HTypo'                                                        then r := HTypo(a[0], a[1])                      // [HTypo(text| switches)]
//    else if (f = 'HUnderconstruction') or (f = 'ComingSoon') then r := HComingSoon(a[0], a[1])         // [RvHComingSoon(Jan 5, 2019 15:37:25, this page is underconstruction)]
//    else if  f = 'HWordify'                                                     then r := HWordify(StrToIntDef(a[0], -1), StrToIntDef(a[1], -1), StrToIntDef(a[2], -1), a[3], a[4], a[5])
    ;
  end
  {$ENDREGION}

  {$REGION 'ico'}
//else if f.StartsWith('Icon') then begin
//  else if  f = 'IconSpec'                        then r := app.IconSpec
//  else if  f = 'IconUrl'                         then r := app.IconUrl
//  ;
//end
  {$ENDREGION}

  {$REGION 'iif'}
  else if  f = 'Iif'                                  then begin
                                                           r := iif.Str(str.ToBool(a[0]), a[1], a[2])
    ;
  end
  {$ENDREGION}

  {$REGION 'img'}
 {else if  f.StartsWith('Image') then begin
         if  f = 'ImageId'                            then r := AvImgRec.Id
    else if  f = 'ImagePId'                           then r := AvImgRec.PId
    else if  f = 'ImageState'                         then r := AvImgRec.Image
    else if  f = 'ImageOrganization'                  then r := AvImgRec.Organization
    else if  f = 'ImageUsername'                      then r := AvImgRec.Username
    else if  f = 'Image'                              then r := AvImgRec.Image
    else if  f = 'ImagePath'                          then r := AvImgRec.Path
    else if  f = 'ImageUrl'                           then r := AvImgRec.Url
    else if  f = 'ImageBinary'                        then r := AvImgRec.Binary
    ;
  end}
  {$ENDREGION}

  {$REGION 'lic'}
 {else if  f.StartsWith('License') then begin
         if  f = 'LicenseKey'                         then r := AvLicRec.Key
    else if  f = 'LicenseIniKeyBase'                  then r := AvLicRec.KeyBase
    else if  f = 'LicenseIniDateMax'                  then r := DateToStr(AvLicRec.DateMax)
    else if  f = 'LicenseIniItemMax'                  then r := AvLicRec.ItemMax.ToString
    else if  f = 'LicenseIniUsagemax'                 then r := AvLicRec.UsageMax.ToString
    else if  f = 'LicenseIgnore'                      then r := AvLicRec.Ignore.ToString
    else if  f = 'LicenseIsValid'                     then r := AvLicRec.IsValid(k).ToString
  end}
  {$ENDREGION}

  {$REGION 'logo'}
  else if f.StartsWith('Logo') then begin
         if  f = 'LogoSpec'                                                     then r := lgo.Spec
    else if  f = 'LogoUrl'                                                      then r := lgo.Url
    else if  f = 'LogoInvSpec'                                                  then r := lgo.InvSpec
    else if  f = 'LogoInvUrl'                                                   then r := lgo.InvUrl
    ;
  end
  {$ENDREGION}

  {$REGION 'lorem'}
  {else if  f.StartsWith('Lorem') then begin
         if  f = 'LoremTitle'                         then begin // [RvLoremTitle(3| 6| 1| false)]
      i0 := StrToIntDef(a[0], 4);
      i1 := StrToIntDef(a[1], 8);
      i2 := StrToIntDef(a[2], 1);
      b1 := StrToBoolDef(a[3], false);
      r  := TLoremRec.Title(i0, i1, i2, b1);

    end else if  f = 'LoremParagraphs'                then begin // [RvLoremParagraphs(1| 3| 12| 24)]
      i0 := StrToIntDef(a[0], 1);
      i1 := StrToIntDef(a[1], 4);
      i2 := StrToIntDef(a[2], 16);
      i3 := StrToIntDef(a[3], 32);
      r  := TLoremRec.Paragraphs(i0, i1, i2, i3);

    end else if  f = 'LoremHTitle'                    then begin // [RvLoremTitle(3| 6| 1| false)]
      i0 := StrToIntDef(a[0], 4);
      i1 := StrToIntDef(a[1], 8);
      i2 := StrToIntDef(a[2], 0);
      i3 := StrToIntDef(a[2], 1);
      b1 := StrToBoolDef(a[3], false);
      r  := TLoremRec.HTitle(i0, i1, i2, i3, b1);

    end else if  f = 'LoremHParagraphs'               then begin // [RvLoremParagraphs(1| 3| 12| 24)]
      i0 := StrToIntDef(a[0], 1);
      i1 := StrToIntDef(a[1], 4);
      i2 := StrToIntDef(a[2], 16);
      i3 := StrToIntDef(a[3], 32);
      r  := TLoremRec.HParagraphs(i0, i1, i2, i3);
    end;
  end}
  {$ENDREGION}

  {$REGION 'lst'}
  else if  f.StartsWith('List') then begin
         if  f = 'ListFormRange'                      then r := lst.FromRangeInt(a[0], StrToBool(a[1]), StrToInt(a[2]), a[3]) // range, leadzero, itemlen, sourrandingchar, useful in where Fldxxx not in (^)
    ;
  end
  {$ENDREGION}

  {$REGION 'mbr'}
  else if  f.StartsWith('Member') then begin
  //else if  f = 'MemberId'                                                     then r := mbr.Id.ToString
  //else if  f = 'MemberPId'                                                    then r := mbr.PId.ToString
         if  f = 'MemberOrganization'                                           then r := mbr.Organization
    else if  f = 'Member'                                                       then r := mbr.Member
    else if  f = 'MemberRole'                                                   then r := mbr.Role
    else if  f = 'MemberLevel'                                                  then r := mbr.Level
    else if  f = 'MemberEmail'                                                  then r := mbr.Email
    else if  f = 'MemberPhone'                                                  then r := mbr.Phone
  //else if  f = 'MemberBadge'                                                  then r := mbr.Badge
    else if  f = 'MemberGrade'                                                  then r := mbr.Grade.ToString
  //else if  f = 'MemberNumber'                                                 then r := mbr.Number.ToString
    ;
  end
  {$ENDREGION}

  {$REGION 'mrk'}
//  else if (f = 'Markdown') or (f = 'HtmlFromText') or (f = 'TextToHtml') then begin
//                                                           r := Markdown(a[0], StrAsBool(a[1])) // r := HtmlFromText(a[0], StrAsBool(a[1]))
//    ;
//  end
  {$ENDREGION}

  {$REGION 'nam'}
  else if  f.StartsWith('Name') then begin
         if  f = 'NameRnd'                                                      then r := nam.Rnd(StrToIntDef(a[0], 4))
    else if  f = 'nam.Co'                                                       then r := nam.Co(a[0])
    ;
  end
  {$ENDREGION}

  {$REGION 'net'}
  else if  f.StartsWith('Net') or (f = 'IpLan') or (f = 'IpWan') then begin
         if  f = 'NetHost'                                                      then r := net.Host
    else if (f = 'NetIpLan') or (f = 'IpLan')                                   then r := net.IpLan
    else if (f = 'NetIpWan') or (f = 'IpWan')                                   then r := net.IpWan
    else if  f = 'NetDomain'                                                    then r := net.Domain
    else if  f = 'NetComputer'                                                  then r := net.Host
    else if  f = 'NetOsLogin'                                                   then r := net.OsLogin
  //else if  f = 'NetLocation'                                                  then r := net.Location
    ;
  end
  {$ENDREGION}

  {$REGION 'org'}
  else if  f.StartsWith('Organization') then begin
         if  f = 'Organization'                                                 then r := iif.NxD(a[0], org.Organization)
  //else if  f = 'OrganizationId'                                               then r := org.Id.ToString
  //else if  f = 'OrganizationPId'                                              then r := org.PId.ToString
    else if  f = 'OrganizationState'                                            then r := org.State
    else if  f = 'OrganizationWww'                                              then r := org.Www
    else if  f = 'OrganizationExpire'                                           then r := DateTimeToStr(org.Expire)
    else if  f = 'OrganizationOwner'                                            then r := iif.NxD(a[0], org.Owner)
    else if  f = 'OrganizationSlogan'                                           then r := iif.NxD(a[0], org.Slogan)
    else if  f = 'OrganizationAbout'                                            then r := iif.NxD(a[0], org.About)
    else if  f = 'OrganizationPhone'                                            then r := org.Phone
    else if  f = 'OrganizationFax'                                              then r := org.Fax
    else if  f = 'OrganizationEmail'                                            then r := org.Email
    else if  f = 'OrganizationAddress'                                          then r := org.Address
    else if  f = 'OrganizationZipCode'                                          then r := org.ZipCode
    else if  f = 'OrganizationCity'                                             then r := org.City
    else if  f = 'OrganizationProvince'                                         then r := org.Province
    else if  f = 'OrganizationCountry'                                          then r := org.Country
    else if  f = 'OrganizationSsn'                                              then r := iif.ExP(org.Ssn, a[0])
    else if  f = 'OrganizationVatNumber'                                        then r := iif.ExP(org.VatNumber, a[0])
    else if  f = 'OrganizationLegalName'                                        then r := org.LegalName
    else if  f = 'OrganizationSymbol'                                           then r := iif.NxD(a[0], org.Symbol)
    else if  f = 'OrganizationApiKey'                                           then r := org.Symbol
    else if  f = 'OrganizationNetwork'                                          then r := iif.NxD(a[0], org.Network)
    else if  f = 'OrganizationPageFooter'                                       then r := org.PageFooter
    else if  f = 'OrganizationEmailTemplate'                                    then r := org.EmailTemplate
  //else if  f = 'OrganizationCss'                                              then r := org.Css
  //else if  f = 'OrganizationLogo'                                             then r := org.Logo
  //else if  f = 'OrganizationLogoInv'                                          then r := org.LogoInv
    else if  f = 'OrganizationBgColor'                                          then r := org.BgColor
    else if  f = 'OrganizationFgColor'                                          then r := org.FgColor
    else if  f = 'OrganizationBorderColor'                                      then r := org.BorderColor
    else if  f = 'OrganizationColor'                                            then r := org.Color
    else if  f = 'OrganizationColor2'                                           then r := org.Color2
    else if  f = 'OrganizationInfoColor'                                        then r := org.InfoColor
    else if  f = 'OrganizationSuccessColor'                                     then r := org.SuccessColor
    else if  f = 'OrganizationWarningColor'                                     then r := org.WarningColor
    else if  f = 'OrganizationDangerColor'                                      then r := org.DangerColor
    else if  f = 'OrganizationJson'                                             then r := org.Json
    else if  f = 'OrganizationPageSwitch'                                       then r := org.PageSwitch
    else if  f = 'OrganizationInfo'                                             then r := org.Info
  //else if  f = 'OrganizationToJson'                                           then r := org.ToJson
    else if  f = 'OrganizationCopyright'                                        then r := org.Copyright
    else if  f = 'OrganizationRegistryPath'                                     then r := org.RegistryPath
    else if  f = 'OrganizationTreePath'                                         then r := org.TreePath
    else if  f = 'OrganizationDiskPath'                                         then r := org.DiskPath
    else if  f = 'OrganizationUrl'                                              then r := org.Url
    else if  f = 'OrganizationHomeUrl'                                          then r := org.HomeUrl
    else if  f = 'OrganizationIconPath'                                         then r := org.IconPath
    else if  f = 'OrganizationIconUrl'                                          then r := org.IconUrl
    else if  f = 'OrganizationLogoPath'                                         then r := org.LogoPath
    else if  f = 'OrganizationLogoUrl'                                          then r := org.LogoUrl
    else if  f = 'OrganizationLogoInvPath'                                      then r := org.LogoInvPath
    else if  f = 'OrganizationLogoInvUrl'                                       then r := org.LogoInvUrl
    else if  f = 'OrganizationLogoSmallPath'                                    then r := org.LogoSmallPath
    else if  f = 'OrganizationLogoSmallUrl'                                     then r := org.LogoSmallUrl
    else if  f = 'OrganizationLogoSmallInvPath'                                 then r := org.LogoSmallInvPath
    else if  f = 'OrganizationLogoSmallInvUrl'                                  then r := org.LogoSmallInvUrl
    ;
  end
  {$ENDREGION}

  {$REGION 'os'}
  {else if f.StartsWith('Os') then begin
         if  f = 'Os'                                                           then r := ops.Os
    else if  f = 'OsVersion'                                                    then r := ops.Version
    ;
  end}
  {$ENDREGION}

  {$REGION 'pwd'}
  else if  f.StartsWith('Password') then begin
         if  f = 'PasswordGenerate'                   then r := pwd.Generate(StrToInt(a[0]), str.ToBool(a[1]), str.ToBool(a[2]), str.ToBool(a[3])) // lenght, uselower, useupper, usenumber
    else if  f = 'PasswordEncode'                     then r := pwd.Encode(a[0])
    else if  f = 'PasswordDecode'                     then r := pwd.Decode(a[0])
    ;
  end
  {$ENDREGION}

  {$REGION 'per'}
  else if  f.StartsWith('Person') then begin
         if  f = 'PersonId'                                                     then r := per.Id.ToString
    else if  f = 'PersonPId'                                                    then r := per.PId.ToString
    else if  f = 'Person'                                                       then r := per.Person
    else if  f = 'PersonName'                                                   then r := per.Name
    else if  f = 'PersonSurname'                                                then r := per.Surname
//  else if  f = 'PersonGender'                                                 then r := per.Gender
//  else if  f = 'PersonNationality'                                            then r := per.Nationality
//  else if  f = 'PersonLanguage'                                               then r := per.Language
//  else if  f = 'PersonSsn'                                                    then r := per.Ssn
//  else if  f = 'PersonVatNumber'                                              then r := per.VatNumber
//  else if  f = 'PersonPhone'                                                  then r := per.Phone
//  else if  f = 'PersonMobile'                                                 then r := per.Mobile
    else if  f = 'PersonEmail'                                                  then r := per.Email
//  else if  f = 'PersonWww'                                                    then r := per.Www
//  else if  f = 'PersonAddress'                                                then r := per.Address
//  else if  f = 'PersonZipCode'                                                then r := per.ZipCode
//  else if  f = 'PersonCity'                                                   then r := per.City
//  else if  f = 'PersonProvince'                                               then r := per.Province
//  else if  f = 'PersonCountry'                                                then r := per.Country
//  else if  f = 'PersonBirthDate'                                              then r := DateTimeToStr(per.BirthDate)
//  else if  f = 'PersonBirthPlace'                                             then r := per.BirthPlace
//  else if  f = 'PersonOfficePhone'                                            then r := per.OfficePhone
//  else if  f = 'PersonOfficeMobile'                                           then r := per.OfficeMobile
//  else if  f = 'PersonOfficeEmail'                                            then r := per.OfficeEmail
//  else if  f = 'PersonOfficeWww'                                              then r := per.OfficeWww
//  else if  f = 'PersonOfficeFax'                                              then r := per.OfficeFax
  //else if  f = 'PersonPicture'                                                then r := per.Picture
//  else if  f = 'PersonNote'                                                   then r := per.Note
    ;
  end
  {$ENDREGION}

  {$REGION 'rnd'}
  else if  f.StartsWith('Rnd') then begin
         if  f = 'RndStr'                             then r := rnd.Str(StrToInt(a[0]))
//    else if  f = 'RndWord'                            then r := rnd.Word(StrToInt(a[0]), StrAsBool(a[1]))
//    else if  f = 'RndPassword'                        then r := rnd.Password(StrToInt(a[0])) // plain
    ;
  end
  {$ENDREGION}

  {$REGION 'scripting'}
  {else if  f.StartsWith('Py') or f.StartsWith('Dws') or f.StartsWith('R') then begin
             if  f = 'PyEval' then begin
      if not PyEval(a[0], r, k)  then r := k; // [RvPyEval(2+2)]
    end else if  f = 'PyExec' then begin
      if not PyExec(a[0], r, k)  then r := k; // [RvPyExec(print 2+2)]
    end else if (f = 'DwsExec') or (f = 'PasExec') then begin
      if not DwsExec(a[0], r, k) then r := k; // [RvDwsExec(var i: integer; for i := 0 to 9 do Print('text ');)]
    end else if  f = 'RExec' then begin
      if not RExec(a[0], r, k) then           // [RvRExec(iris)]
        r := k;
      if BoolFromStr(a[1]) then
      //r := HPre(r);
        r := HCollaps('Console', HCode(r), 4, '+CCtm-CCo');
    end;
  end}
  {$ENDREGION}

  {$REGION 'smt'}
  else if  f.StartsWith('Smtp') then begin
         if  f = 'SmtpOrganization'                                             then r := smt.Organization
    else if  f = 'SmtpHost'                                                     then r := smt.Host
    else if  f = 'SmtpPort'                                                     then r := smt.Port
    else if  f = 'SmtpUsername'                                                 then r := smt.Username
    else if  f = 'SmtpPassword'                                                 then r := smt.Password
    ;
  end
  {$ENDREGION}

  {$REGION 'sql'}
  {else if  f.StartsWith('Sql') then begin
         if (f = 'SqlElin') or (f = 'SqlEqualLikeInNot') then r := sql.Elin(a[0], a[1])   // [RvSqlElin(  FldAbc| $AValue$)]
    else if  f = 'SqlFilter'                             then r := sql.Filter(a[0], a[1]) // [RvSqlFilter(FldAbc| $AValue$)] $AValue$ = [ Aaa | Aaa* | Aaa,Bbb,... | Aaa*,Bbb*,... | ^ xxx | xxx # | ^ xxx # ] xxx = one of the previous
  end}
  {$ENDREGION}

  {$REGION 'srv <- website'}
  else if  f.StartsWith('WebSite') then begin
  //     if  f = 'WebSiteOrganization'                                          then r := srv.Organization
         if  f = 'WebSiteAdminCsv'                                              then r := srv.AdminCsv
    else if  f = 'WebSiteWww'                                                   then r := srv.Www
    else if  f = 'WebSitePort'                                                  then r := srv.Port
    else if  f = 'WebSiteProtocol'                                              then r := srv.Protocol
//  else if  f = 'WebSiteWwwAuthenticate'                                       then r := srv.WwwAuthenticate
    else if  f = 'WebSiteUrl'                                                   then r := srv.Url
    else if  f = 'WebSiteIsapiUrl'                                              then r := isa.IsapiUrl(a[0])
//  else if  f = 'WebSiteCodeIsapiUrl'                                          then r := srv.CodeIsapiUrl(a[0])
//  else if  f = 'WebSiteDbaIsapiUrl'                                           then r := srv.DbaIsapiUrl(a[0])
//  else if  f = 'WebSiteImageIsapiUrl'                                         then r := srv.ImageIsapiUrl(a[0])
    else if  f = 'WebSitePageUrl'                                               then r := srv.PageUrl(a[0], a[1]) // id, tail
//  else if  f = 'WebSiteFilerUrl'                                              then r := srv.FilerUrl(a[0])
//  else if  f = 'WebSiteImageUrl'                                              then r := srv.ImageUrl(a[0])
//  else if  f = 'WebSiteIncludeUrl'                                            then r := srv.IncludeUrl(a[0])
    else if  f = 'WebSiteOrganizationUrl'                                       then r := srv.ObjUrl('Organization', a[0])
//  else if  f = 'WebSitePersonUrl'                                             then r := srv.PersonUrl(a[0])
//  else if  f = 'WebSitePhotoUrl'                                              then r := srv.PhotoUrl(a[0])
//  else if  f = 'WebSiteUserUrl'                                               then r := srv.UserUrl(a[0])
//  else if  f = 'WebSiteLoginUrl'                                              then r := srv.LoginUrl(a[0])
//  else if  f = 'WebSiteLogoutUrl'                                             then r := srv.LogoutUrl(a[0])
//  else if  f = 'WebSiteAuthenticateUrl'                                       then r := srv.AuthenticateUrl(a[0])
//  else if  f = 'WebSiteUploadUrl'                                             then r := srv.UploadUrl(a[0])
    ;
  end
  {$ENDREGION}

  {$REGION 'sys'}
  else if  f.StartsWith('Sys') or f.StartsWith('System') then begin
         if  (f = 'SysAcronym'         ) or (f = 'SystemAcronym'         )      then r := sys.Acronym
//  else if  (f = 'SysDescription'     ) or (f = 'SystemDescription'     )      then r := sys.Description
    else if  (f = 'SysCopyright'       ) or (f = 'SystemCopyright'       )      then r := sys.RioCopyright
    else if  (f = 'SysAuthor'          ) or (f = 'SystemAuthor'          )      then r := sys.Author
    else if  (f = 'SysEmail'           ) or (f = 'SystemEmail'           )      then r := sys.Email
    else if  (f = 'SysWww'             ) or (f = 'SystemWww'             )      then r := sys.Www
//  else if  (f = 'SysAdmin'           ) or (f = 'SystemAdmin'           )      then r := sys.Admin
//  else if  (f = 'SysAdminEmail'      ) or (f = 'SystemAdminEmail'      )      then r := sys.AdminEmail
//  else if  (f = 'SysAdminPhone'      ) or (f = 'SystemAdminPhone'      )      then r := sys.AdminPhone
//  else if  (f = 'SysNetworkUsername' ) or (f = 'SystemNetworkUsername' )      then r := sys.NetworkUsername
//  else if  (f = 'SysNetworkPassword' ) or (f = 'SystemNetworkPassword' )      then r := sys.NetworkPassword
//  else if  (f = 'SysNetworkEmail'    ) or (f = 'SystemNetworkEmail'    )      then r := sys.NetworkEmail
//  else if  (f = 'SysOtpIsActive'     ) or (f = 'SystemOtpIsActive'     )      then r := sys.OtpIsActive.ToString
    else if  (f = 'SysQuitUrl'         ) or (f = 'SystemQuitUrl'         )      then r := sys.QUIT_URL
    else if  (f = 'SysUrl'             ) or (f = 'SystemUrl'             )      then r := sys.Url
    else if  (f = 'SysInfo'            ) or (f = 'SystemInfo'            )      then r := sys.Info
  //else if  (f = 'SysDisk'            ) or (f = 'SystemDisk'            )      then r := sys.Disk
//  else if  (f = 'SysPath'            ) or (f = 'SystemPath'            )      then r := sys.Path
  //else if  (f = 'SysAppPath'         ) or (f = 'SystemAppPath'         )      then r := sys.AppPath
//  else if  (f = 'SysBackupPath'      ) or (f = 'SystemBackupPath'      )      then r := sys.BackupPath
//  else if  (f = 'SysFilerPath'       ) or (f = 'SystemFilerPath'       )      then r := sys.FilerPath
//  else if  (f = 'SysImagePath'       ) or (f = 'SystemImagePath'       )      then r := sys.ImagePath
//  else if  (f = 'SysIncludePath'     ) or (f = 'SystemIncludePath'     )      then r := sys.IncludePath
  //else if  (f = 'SysMoviePath'       ) or (f = 'SystemMoviePath'       )      then r := sys.MoviePath
    else if  (f = 'SysOrganizationDir' ) or (f = 'SystemOrganizationDir' )      then r := sys.ORG_DIR
//  else if  (f = 'SysPersonPath'      ) or (f = 'SystemPersonPath'      )      then r := sys.PerPath
  //else if  (f = 'SysPicturePath'     ) or (f = 'SystemPicturePath'     )      then r := sys.PicturePath
//  else if  (f = 'SysPhotoPath'       ) or (f = 'SystemPhotoPath'       )      then r := sys.PhotoPath
//  else if  (f = 'SysResourcePath'    ) or (f = 'SystemResourcePath'    )      then r := sys.ResourcePath
//  else if  (f = 'SysTempPath'        ) or (f = 'SystemTempPath'        )      then r := sys.TempPath
//  else if  (f = 'SysUserPath'        ) or (f = 'SystemUserPath'        )      then r := sys.UserPath
    ;
  end
  {$ENDREGION}

  {$REGION 'usr'}
  else if  f.StartsWith('User') or (f = 'Password') or (f = 'Avatar') or (f = 'Session') then begin
         if (f = 'UserOrganization')                                            then r := usr.Organization
    else if (f = 'UserUsername') or (f = 'Username')                            then r := usr.Username
    else if (f = 'UserPassword') or (f = 'Password')                            then r := usr.Password
    else if (f = 'UserState')                                                   then r := usr.State
    else if (f = 'UserAvatar')   or (f = 'Avatar')                              then r := 'usr.Avatar'
    else if (f = 'UserSession')  or (f = 'Session')                             then r := usr.Session
    else if (f = 'UserJson')                                                    then r := usr.Json
    ;
  end
  {$ENDREGION}

  {$REGION 'wre'}
  else if  f.StartsWith('Req') or f.StartsWith('Wre') then begin
         if  f = 'WreDateTime'                                                  then r := DateTimeToStr(wre.DateTime)
    else if  f = 'WreClientAddr'                                                then r := wre.ClientAddr
    else if  f = 'WreClientHost'                                                then r := wre.ClientHost
    else if  f = 'WreClientAccept'                                              then r := wre.ClientAccept
    else if  f = 'WreClientAcceptEncoding'                                      then r := wre.ClientAcceptEncoding
    else if  f = 'WreClientAcceptLanguage'                                      then r := wre.ClientAcceptLanguage
    else if  f = 'WreClientApp'                                                 then r := wre.ClientApp
    else if  f = 'WreClientAppVersion'                                          then r := wre.ClientAppVersion
    else if  f = 'WreClientDoNotTrack'                                          then r := wre.ClientDoNotTrack
    else if  f = 'WreClientTimezoneOffset'                                      then r := wre.ClientTimezoneOffset
    else if  f = 'WreClientLanguage'                                            then r := wre.ClientLanguage
    else if  f = 'WreClientPlatform'                                            then r := wre.ClientPlatform
    else if  f = 'WreClientOs'                                                  then r := wre.ClientOs
    else if  f = 'WreClientCpuCores'                                            then r := wre.ClientCpuCores
    else if  f = 'WreClientScreen'                                              then r := wre.ClientScreen
    else if  f = 'WreClientAudio'                                               then r := wre.ClientAudio
    else if  f = 'WreClientVideo'                                               then r := wre.ClientVideo
    else if  f = 'WreClientLocalStorage'                                        then r := wre.ClientLocalStorage
    else if  f = 'WreClientSessionStorage'                                      then r := wre.ClientSessionStorage
    else if  f = 'WreClientIndexedDb'                                           then r := wre.ClientIndexedDb
    else if  f = 'WreClientFingerprint'                                         then r := wre.ClientFingerprint
    else if  f = 'WreUserOrganization'                                          then r := wre.UserOrganization
    else if  f = 'WreUserDomain'                                                then r := wre.UserDomain
    else if  f = 'WreUserComputer'                                              then r := wre.UserComputer
    else if  f = 'WreUsername'                                                  then r := wre.Username
    else if  f = 'WreUserName'                                                  then r := wre.Username
    else if  f = 'WreSession'                                                   then r := wre.Session
    else if  f = 'WreOtp'                                                       then r := wre.Otp
    else if  f = 'WreHttpOrigin'                                                then r := wre.HttpOrigin
    else if  f = 'WreHttpProtocol'                                              then r := wre.HttpProtocol
    else if  f = 'WreHttpMethod'                                                then r := wre.HttpMethod
    else if  f = 'WreRequestId'                                                 then r := wre.RequestId.ToString
    else if  f = 'WreConnection'                                                then r := wre.Connection
    else if  f = 'WreHost'                                                      then r := wre.Host
    else if  f = 'WreUrl'                                                       then r := wre.Url
    else if  f = 'WrePathInfo'                                                  then r := wre.PathInfo
    else if  f = 'WreQuery'                                                     then r := wre.Query
    else if  f = 'WreServerAddr'                                                then r := wre.ServerAddr
    else if  f = 'WreServerHost'                                                then r := wre.ServerHost
    else if  f = 'WreServerPort'                                                then r := wre.ServerPort.ToString
    else if  f = 'WreServerPortSecure'                                          then r := wre.ServerPortSecure.ToString
    else if  f = 'WreServerSoftware'                                            then r := wre.ServerSoftware
    else if  f = 'WreScriptName'                                                then r := wre.ScriptName
    else if  f = 'WreScriptVer'                                                 then r := wre.ScriptVer
    else if  f = 'WreTimingMs'                                                  then r := wre.TimingMs.ToString
    ;
  end
  {$ENDREGION}

  {$REGION 'web'}
  {else if  f.StartsWith('Web') then begin
         if  f = 'WebField'                           then WebField(AvWrqRec, a[0], r, a[1], k, false); // [RvWebField(CoAaa|Default)]
    ;
  end}
  {$ENDREGION}

  {$REGION 'NOTHINGFOUND'}
  else {if r = '' then} begin
    r := '?';
  //r := '&#91;Rv' + f + '&#40;' + IvArgsList + '&#41;&#93; ' + NOT_FOUND;
  end;
  {$ENDREGION}

  {$REGION 'End'}
  Result := r;
  {$ENDREGION}

end;

function TRvaRec.Rv2(IvString: string; IvCommentRemove, IvEmptyLinesRemove, IvTrim: boolean): string;

  {$REGION 'Var'}
var
  z: integer; // matchesreplaced
  s, g, f, a, c: string; // str, group0, function, args, contentforreplacing
  r: TRegEx;
  m: TMatch;
//g: TGroup;
  {$ENDREGION}

begin

  {$REGION 'Init'}
  z := 0;
  s := IvString;
  if IvTrim then s := Trim(s);
  {$ENDREGION}

  {$REGION 'CommentRemovePre'}
  if IvCommentRemove then
    str.CommentRemove(s);
  {$ENDREGION}

  {$REGION 'Exit'}
  if not str.HasRex(s, rex.REX_RV_CHECK_PAT, [roIgnoreCase, roSingleLine]) then begin
    Result := s;
    Exit;
  end;
  {$ENDREGION}

  {$REGION 'Go'}
  try
    r := TRegEx.Create(rex.REX_RV_RECURSIVE_PAT, [roIgnoreCase, roSingleLine, roIgnorePatternSpace]);

    // allmatches
    m := r.Match(s);
    z := m.Length;

    // processmatches
    z := 0;
    while m.Success do begin

      Inc(z);

      {$REGION 'Zzz'}
      // process the match
      //LogFmt('grpcount: %d, idx: %d, len: %d, ok: %s, val: %s', [m.Groups.Count, m.Index, m.Length, BoolToStr(m.Success), m.Value]);
      //LogFmt('grps: %d, val: %s', [m.Groups.Count, m.Value]);

      // log
      //for i := 0 to m.Groups.Count -1 do begin
      //  g := m.Groups.Item[i];
      //  LogFmt('grpid: %d, idx: %d, len: %d, val: %s', [i, g.Index, g.Length, g.Value]);
      //end;
      {$ENDREGION}

      {$REGION 'groups->func+args OLD-NON-RECURSIVE'}
      {
      // simple [RvXxx()]
      if m.Groups.Count = 3 then begin           // g0, g1, g2
        f := m.Groups.Item[2].Value;
        a := '';

      // empty [RvXxx()] or full [RvXxx(aaa, bbb, ...)]
      end else begin                             // g0, g1, g2, g3, g4
        f := m.Groups.Item[3].Value;
        a := m.Groups.Item[4].Value;

      end;
      }
      {$ENDREGION}

      {$REGION 'groups->func+args RECURSIVE'}
      g := m.Groups.Item[0].Value;
      f := m.Groups.Item[1].Value;
      a := m.Groups.Item[2].Value;
      //x := Format('[Rv%s%s]', [f, a]); // reconstruct tag, args not compiled
      //if x = x2 then begin           // cache
      //  m := m.NextMatch;
      //  Continue
      //end;
      //x2 := x;
      Delete(a, 1, 1); // remove 1st (
      Delete(a, Length(a), 1); // remove last )
      //LogFmt('func: %s', [f]);
      //LogFmt('args: %s', [a]);
      //LogFmt('tag : %s', [x]);
      {$ENDREGION}

      // recursively apply Rv() to eventual params
      while rex.Has(a, rex.REX_RV_CHECK_PAT, [roIgnoreCase, roSingleLine]) do // str.Has(a, '[Rv')
        a := Rv(a);

      // content
      c := RvFunction(f, a);

      // replace
      s := str.Replace(s, g, c); // IvString

      // next
      m := m.NextMatch;
    end;

    // recursively apply Rv() to eventual tags just inserted above
    if rex.Has(s, rex.REX_RV_CHECK_PAT, [roIgnoreCase, roSingleLine]) then
      s := Rv(s);

  except
    on e: ERegularExpressionError do
      Result := e.Message;
  end;
  {$ENDREGION}

  {$REGION 'CommentRemovePost'}
  if IvCommentRemove then
    str.CommentRemove(s);
  {$ENDREGION}

  {$REGION 'EmptyLinesRemove'}
  if IvEmptyLinesRemove then
    str.EmptyLinesRemove(s);
  {$ENDREGION}

  {$REGION 'End'}
  Result := s;
  {$ENDREGION}

end;

function TRvaRec.Rv(IvString: string; IvCommentRemove: boolean): string;
type
  TTag = record
    Orig: string;
    Func: string;
    Args: string;
  end;
const
  RV_PAT = '\[Rv(\w*?)(\((.*?)\))?\]';
var
  t: array of TTag; // tagvec
  o, x: string; // origrv, funcresult
  f, a: TStringVector; // funcvec, argsvec
  r: TRegEx;
  m: TMatch;
  i: integer;
begin
  // tags
  r := TRegEx.Create(RV_PAT);
  m := r.Match(IvString);
  i := -1;
  while m.Success and (m.Groups.Count >= 1) do begin
    SetLength(t, length(t)+1);
    Inc(i);
    if      m.Groups.Count = 2 then begin
      t[i].Orig := m.Groups[0].Value;
      t[i].Func := m.Groups[1].Value;
      t[i].Args := '';
    end else if m.Groups.Count = 4 then begin
      t[i].Orig := m.Groups[0].Value;
      t[i].Func := m.Groups[1].Value;
      t[i].Args := m.Groups[3].Value;
    end;
    m := m.NextMatch;
  end;

  // init
  Result := IvString;

  // comments
  if IvCommentRemove then
    str.CommentRemove(Result);

  // loop
  for i := Low(t) to High(t) do begin
    // init
    o := t[i].Orig;
    f := str.CamelToVec(t[i].Func);
    a := vec.FromStr(t[i].Args, '|,;');

    // funcresult
    x := RvFunction2(f, a);

    // replace
    if not iis.Ex(x) then begin
      if obj.DbaSwitchGet('System', 'ShowUnknownRvTags', true) then begin
        Result := str.Replace(Result, o, str.Replace(str.Replace(o, '[', '('), ']', ')'))
      end else
        Result := str.Replace(Result, o, '');
    end else
      Result := str.Replace(Result, o, x);
  end;

  // recursive
  if Result.Contains('[Rv') then
    Result := Rv(Result, IvCommentRemove);
end;

function TRvaRec.RvDs(IvString: string; IvDs: TDataset): string;
var
  f: TStringVector;
  v: TVariantVector;
  i: integer;
begin
  dst.RecordToFldAndValueVectors(IvDs, f, v);
  Result := IvString;
  for i := Low(f) to High(f) do
    Result := StringReplace(Result, '$'+f[i]+'$', vartostr(v[i]), [rfReplaceAll, rfIgnoreCase]);
end;

function TRvaRec.RvJ(IvString, IvJsonStr: string; IvReplaceFlag: TReplaceFlags): string;
var
  o{, o2}: superobject.ISuperObject; // givenobj, objinarray
//  i: superobject.TSuperObjectIter; // item
//i2: superobject.TSuperAvlEntry; // item
//  a: superobject.TSuperArray; // aray
//  n, v: string; // name, value
//  j: integer;
  IvResultRecursive: string;

  procedure JsonObjectProcess(const IvAsObject: superobject.TSuperTableString; const IvPrefix: string = ''); // RECURSIVE
  var
    i: integer; // idx
    n, v: string; // name, value
    nv, vv: superobject.ISuperObject; // namevector, valuevector
    i1, i2: superobject.ISuperObject; // itemvalue, vectoritem
  begin
    if Assigned(IvAsObject) then begin
      nv := IvAsObject.GetNames;
      vv := IvAsObject.GetValues;

      for i := 0 to vv.AsArray.Length - 1 do begin
        n := nv.AsArray[i].AsString;
        i1 := vv.AsArray[i];
        if i1.DataType = stObject then begin
        //v := '<Object>';
          JsonObjectProcess(i1.AsObject, IvPrefix + n + '.');
        end else if i1.DataType = stArray then begin
        //v := '<Array>';
          for i2 in i1 do
            JsonObjectProcess(i2.AsObject, IvPrefix + n + '.');
        end else begin
          v := i1.AsString;
          if True then
            v := str.Replace(v, '*', '%');
        //IvResultRecursive := str.Replace  (IvResultRecursive, '$' + IvPrefix + n + '$', v); // '[RvAgent'+n+'()]'
          IvResultRecursive := StringReplace(IvResultRecursive, '$' + IvPrefix + n + '$', v, IvReplaceFlag);
        end;
//        if i1.DataType = stArray then
//        if i1.DataType = stObject then
      end;
    end;
  end;

begin
  // before
  IvResultRecursive := StringReplace(IvString, '$Json$', '***NOTALLOWED***', [rfReplaceAll, rfIgnoreCase]);

  // jsonobject
  o := superobject.SO(IvJsonStr);
  JsonObjectProcess(o.AsObject);

  // after
  Result := IvResultRecursive;

  {
  if superobject.ObjectFindFirst(o, i) then begin
    try
      repeat
        if (i.val.IsType(stArray)) then begin
          a := i.val.AsArray;
          for j := 0 to a.Length-1 do begin  //for j in a do begin
            o2 := a.O[j];
            // recursive ...
          //RvJ(Result, ???);
          end;
        end else begin
          n := i.key;
          v := i.val.AsString;
          Result := StrReplace(Result, '[RvAgent'+n+'()]', v);
        end;
      until not superobject.ObjectFindNext(i);
    finally
      superobject.ObjectFindClose(i);
    end;
  end;

  for j := 0 to o.AsArray.Length-1 do begin
    // the object in the array
    a := o.AsArray[j].AsObject;

    // 1 asobject
//  for i1 in a.AsObject do begin
//    n := i1.Name;
//    v := i1.Value.AsString;
//    IvString := StrReplace(IvString, '[Rv'+n+'()]', v);
//  end;

    // 2 browsing
    if ObjectFindFirst(a, i2) then
    repeat
      n := i2.key;
      v := i2.val.AsString;
      IvString := StrReplace(IvString, '[Rv'+n+'()]', v);
    until not ObjectFindNext(i2);
    ObjectFindClose(i2);
  end;
  }
end;
{$ENDREGION}

{$REGION 'TSbuRec'}
procedure TSbuRec.Add(IvString: string; IvNlPrefix: integer);
var
  i: integer;
begin
  for i := 1 to IvNlPrefix do
    Text := Text + sLineBreak;
  Text := Text + IvString;
end;

procedure TSbuRec.AiE(IvString, IvDefault: string; IvNlPrefix: integer);
var
  s: string;
begin
  s := IvString;
  if iis.Nx(s) then
    s := IvDefault;
  Add(s, IvNlPrefix);
end;

procedure TSbuRec.Aif(IvString: string; IvTest: boolean; IvNlPrefix: integer);
begin
  if IvTest then
    Add(IvString, IvNlPrefix);
end;

procedure TSbuRec.AiX(IvString: string; IvNlPrefix: integer);
begin
  if iis.Ex(IvString) then
    Add(IvString, IvNlPrefix);
end;

procedure TSbuRec.Ann(IvString: string);
begin
  Text := Text + IvString;
end;

procedure TSbuRec.ATg(IvString, IvTag: string);
begin
  Fmt('<%s>%s</%s>', [IvTag, IvString, IvTag]);
end;

procedure TSbuRec.AXr(IvString, IvReturn: string; IvNlPrefix: integer);
begin
  if iis.Ex(IvString) then
    Add(IvReturn, IvNlPrefix);
end;

procedure TSbuRec.Clear;
begin
  Text := '';
end;

procedure TSbuRec.Emp(IvNl: integer);
var
  i: integer;
begin
  for i := 1 to IvNl do
    Text := Text + sLineBreak;
end;

procedure TSbuRec.Fie(IvFormat: string; IvVarRecVector: array of TVarRec; IvTest: string; IvNlPrefix: integer);
begin
  if iis.Ex(IvTest) then
    Fmt(IvFormat, IvVarRecVector, IvNlPrefix);
end;

procedure TSbuRec.Fif(IvFormat: string; IvVarRecVector: array of TVarRec; IvTest: boolean; IvNlPrefix: integer);
begin
  if IvTest then
    Fmt(IvFormat, IvVarRecVector, IvNlPrefix);
end;

procedure TSbuRec.FiX(IvFormat, IvIfExist: string; IvNlPrefix: integer);
begin
  if IvIfExist <> '' then
    Add(Format(IvFormat, [IvIfExist]), IvNlPrefix);
end;

procedure TSbuRec.FiY(IvFormat, IvFormat2, IvIfExist: string; IvNlPrefix: integer);
begin
  if IvIfExist = '' then
    Add(Format(IvFormat, ['']), IvNlPrefix)
  else
    Add(Format(IvFormat, [Format(IvFormat2, [IvIfExist])]), IvNlPrefix);
end;

procedure TSbuRec.Fmt(IvFormat: string; IvVarRecVector: array of TVarRec; IvNlPrefix: integer);
begin
  Add(Format(IvFormat, IvVarRecVector), IvNlPrefix);
end;

procedure TSbuRec.Iif(IvTest: boolean; IvTrueVal, IvFalseVal: string; IvNlPrefix: integer);
begin
  if IvTest then
    Add(IvTrueVal, IvNlPrefix)
  else
    Add(IvFalseVal, IvNlPrefix);
end;

procedure TSbuRec.Rep(IvString, IvOut, IvIn: string; IvNlPrefix: integer);
begin
  Add(StringReplace(IvString, IvOut, IvIn, [rfReplaceAll, rfIgnoreCase]), IvNlPrefix);
end;

procedure TSbuRec.Swi(IvSwitchList, IvSwitch, IvString: string; IvNlPrefix: integer);
begin
  if IvSwitchList.Contains(IvSwitch) then
    Add(IvString, IvNlPrefix);
end;
{
procedure TSbuRec.AdS(IvString: string; NlPrefix: boolean);
begin
  Fmt(SUCCESS_STR_FMT, [IvString], NlPrefix);
end;

procedure TSbuRec.AdW(IvString: string; NlPrefix: boolean);
begin
  Fmt(WARNING_STR_FMT, [IvString], NlPrefix);
end;

procedure TSbuRec.AdE(IvE: Exception; NlPrefix: boolean);
begin
  Fmt(EXCEPTION_FORMAT, [IvE.Message], NlPrefix);
end;
}
{$ENDREGION}

{$REGION 'TSesRec'}
function TSesRec.DbaNewAndSet(IvOrganization, IvUsername, IvPassword: string; var IvFbk: string): boolean;
var
  q, w: string;
  z: integer;
  x: TDbaCls;
begin
  x := TDbaCls.Create(FDManager);
  try
    // exit
    Result := iis.Ex(IvOrganization) and iis.Ex(IvUsername) and iis.Ex(IvPassword);
    if not Result then begin
      IvFbk := 'Unable to create new session, organization or username or password are empty';
      Exit
    end;

    // NEW
    Randomize(); // allows for use of the random() function
    Session := IntToStr(Random(999999));

    // dba
    w := usr.UsernameWhere(IvOrganization, IvUsername, IvPassword, false);
    q := Format('update DbaUser.dbo.TblUser set FldSession = ''%s'' where %s', [Session, w]);
    x.ExecFD(q, z, IvFbk);
  finally
    FreeAndNil(x);
  end;
end;

function TSesRec.DbaUnset(IvOrganization, IvUsername, IvPassword: string; var IvFbk: string): boolean;
var
  q, w: string;
  z: integer;
  x: TDbaCls;
begin
  x := TDbaCls.Create(FDManager);
  try
    w := usr.UsernameWhere(IvOrganization, IvUsername, IvPassword, false);
    q := Format('update DbaUser.dbo.TblUser set FldSession = ''%s'' where %s', [Session, w]);
    Result := x.ExecFD(q, z, IvFbk);
  finally
    FreeAndNil(x);
  end;
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
  Screen.Cursor := crHourGlass;
  try
  // TEMPORARYCOMMENT
//  Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapSessionClose(IvOrganization, IvUsername, Session, IvFbk);
  finally
    Screen.Cursor := crDefault;
  end;
end;

function TSesRec.RioExists(IvOrganization, IvUsername, IvSession: string; var IvFbk: string): boolean;
begin
  Screen.Cursor := crHourGlass;
  try
  // TEMPORARYCOMMENT
//  Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapSessionExists(usr.Organization, usr.Username, Session, IvFbk);
  finally
    Screen.Cursor := crDefault;
  end;
end;

function TSesRec.RioOpen(IvOrganization, IvUsername, IvPassword: string; var IvFbk: string): boolean;
begin
  Screen.Cursor := crHourGlass;
  try
  // TEMPORARYCOMMENT
//  Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapSessionOpen(IvOrganization, IvUsername, IvPassword, net.Domain, net.Host, net.OsLogin, net.IpLan, net.IpWan, byn.Tag, byn.Ver, ses.Session, ses.BeginDateTime, IvFbk);
  finally
    Screen.Cursor := crDefault;
  end;

  // flag
  HasBeenOpen := Result;
end;
{$ENDREGION}

{$REGION 'TSmtRec'}
function TSmtRec.DbaSelect(var IvFbk: string): boolean;
begin
  IvFbk  := NOT_IMPLEMENTED_STR;
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
  Screen.Cursor := crHourGlass;
  try
  // TEMPORARYCOMMENT
//  Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapSmtpGet(IvOrganization, h, p, u, w, IvFbk);
  finally
    Screen.Cursor := crDefault;
  end;

  if Result then begin
    Organization := IvOrganization; // Wks          , Lfoundry
    Host         := h;              // www.wks.cloud, aivmcas01.ai.sys.com
    Port         := p;              // 25           , 25
    Username     := u;
    Password     := w;
  end;
end;
{$ENDREGION}

{$REGION 'TSobRec'}
function TSobRec.FromFileUTF8( const IvFileName: string): superobject.ISuperObject;
var
  input: TFileStream;
  output: TStringStream;
begin
  input := TFileStream.Create(IvFileName, fmOpenRead, fmShareDenyWrite);
  try
     output := TStringStream.Create('');
     try
       output.CopyFrom(input, input.Size);
//       Result := superobject.TSuperObject.ParseString(PWideChar(UTF8ToUTF16(output.DataString)), true, true);
     finally
       FreeAndNil(output);
     end;
  finally
    FreeAndNil(input);
  end;
end;

function TSobRec.ObjectInfo(const IvAsObject: superobject.TSuperTableString; var IvFbk: TFbkRec; const IvPrefix: string): string;
var
  ns, vs: superobject.ISuperObject;         // names, items
  na: string; ij: superobject.ISuperObject; // name, item
  v: string;                                // value
  j: superobject.ISuperObject;              // arrayitem
  i: integer;
begin
  // exit
  if not Assigned(IvAsObject) then begin
    Exit;
  end;

  // names-values
  ns := IvAsObject.GetNames;
  vs := IvAsObject.GetValues;

  // loop
  for i := 0 to vs.AsArray.Length - 1 do begin
    // name-value
    na := ns.AsArray[i].AsString;
    ij := vs.AsArray[i];

    if ij.DataType = stObject then
      v := '<Object>'
    else if ij.DataType = stArray then
      v := '<Array>'
    else
      v := ij.AsString;

    //if SameText(na, 'id') then
      IvFbk.AddFmt('%s: %s', [IvPrefix + na, v]);

    if ij.DataType = stArray then
      for j in ij do
        ObjectInfo(j.AsObject, IvFbk, IvPrefix + na + '.');

    if ij.DataType = stObject then
      ObjectInfo(ij.AsObject, IvFbk, IvPrefix + na + '.');
  end;
end;

function TSobRec.Pretty(IvString: WideString): string;
var
  o: superobject.ISuperObject;
begin
  o := superobject.TSuperObject.ParseString(PWideChar(IvString), true);
  if not Assigned(o) then
    Result := ''
  else
    Result := o.AsJson(true, false); // here comes your result: pretty-print JSON
end;

function TSobRec.StrEscape(const IvString: string): string;
//const
//  ESCAPE          = '\';
////QUOTATION_MARK  = '"'; //  double quote is replaced with \"
//  SOLIDUS         = '/';
//  REVERSE_SOLIDUS = '\'; //  backslash is replaced with \\
//  BACKSPACE       = #8 ; //  backspace is replaced with \b
//  FORM_FEED       = #12; //  form feed is replaced with \f
//  NEW_LINE        = #10; //  newline is replaced with \n
//  CARRIAGE_RETURN = #13; //  carriage return is replaced with \r
//  HORIZONTAL_TAB  = #9 ; //  tab is replaced with \t
var
  i, ix: integer;
  c: Char;

  procedure AddChars(const AChars: string; var Dest: string; var AIndex: integer); inline;
  begin
    System.Insert(AChars, Dest, AIndex);
    System.Delete(Dest, AIndex + 2, 1);
    Inc(AIndex, 2);
  end;

  procedure AddUnicodeChars(const AChars: string; var Dest: string; var AIndex: integer); inline;
  begin
    System.Insert(AChars, Dest, AIndex);
    System.Delete(Dest, AIndex + 6, 1);
    Inc(AIndex, 6);
  end;

begin
  // i
//  Result := '';
//  for c in IvString do begin
//    case c of
//      // !! double quote (") is handled by TJSONString
//    //QUOTATION_MARK : Result := Result + ESCAPE + QUOTATION_MARK;
//      REVERSE_SOLIDUS: Result := Result + ESCAPE + REVERSE_SOLIDUS;
//      SOLIDUS        : Result := Result + ESCAPE + SOLIDUS;
//      BACKSPACE      : Result := Result + ESCAPE + 'b';
//      FORM_FEED      : Result := Result + ESCAPE + 'f';
//      NEW_LINE       : Result := Result + ESCAPE + 'n';
//      CARRIAGE_RETURN: Result := Result + ESCAPE + 'r';
//      HORIZONTAL_TAB : Result := Result + ESCAPE + 't';
//      else begin
//        if (integer(c) < 32) or (integer(c) > 126) then
//          Result := Result + ESCAPE + 'u' + IntToHex(integer(c), 4)
//        else
//          Result := Result + c;
//      end;
//    end;
//  end;

  // ii
  Result := IvString;
  ix := 1;
  for i := 1 to System.Length(IvString) do begin
    c :=  IvString[i];
    case c of
      '/', '\', '"':
      begin
        System.Insert('\', Result, ix);
        Inc(ix, 2);
      end;
      #8:  // backspace
      begin
        AddChars('\b', Result, ix);
      end;
      #9: // tab
      begin
        AddChars('\t', Result, ix);
      end;
      #10: // newline
      begin
        AddChars('\n', Result, ix);
      end;
      #12: // formfeed
      begin
        AddChars('\f', Result, ix);
      end;
      #13: // carriagereturn
      begin
        AddChars('\r', Result, ix);
      end;
      #0 .. #7, #11, #14 .. #31:
      begin
        AddUnicodeChars('\u' + IntToHex(Word(c), 4), Result, ix);
      end else begin
        if Word(c) > 127 then begin
          AddUnicodeChars('\u' + IntToHex(Word(c), 4), Result, ix);
        end else begin
          Inc(ix);
        end;
      end;
    end;
  end;
end;

function TSobRec.StrUnescape(const IvString: AnsiString): string;
//var
//  j: TJSONValue;
begin
//  j := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(IvString), 0);
//  Result := j.ToString;
end;

function TSobRec.SuperTypeToFieldSize( IvSuperType: superobject.TSuperType): integer;
begin
  Result := 0;
  if (IvSuperType = stString) then
    Result := 255;
end;

function TSobRec.SuperTypeToFieldType( IvSuperType: superobject.TSuperType): TFieldType;
begin
  case IvSuperType of
    stBoolean:  Result := ftBoolean;
    stDouble:   Result := ftFloat;
    stCurrency: Result := ftCurrency;
    stInt:      Result := ftinteger;
    stObject:   Result := ftDataSet;
    stArray:    Result := ftDataSet;
    stString:   Result := ftString;
  else          Result := ftUnknown;
  end;
end;

procedure TSobRec.ToFileUTF8(const aFileName: string; o: superobject.ISuperObject);
var
  output: TFileStream;
  input: TStringStream;
begin
//  input := TStringStream.Create(UTF16ToUTF8(o.AsJSon(true)));
  try
     output := TFileStream.Create(aFileName, fmOpenWrite or fmCreate, fmShareDenyWrite);
     try
       output.CopyFrom(input, input.Size);
     finally
       FreeAndNil(output);
     end;
  finally
    FreeAndNil(input);
  end;
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
  IvFbk := 'Sql script is valid (' + NOT_IMPLEMENTED_STR + ')';
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

function TStrRec.CamelToVec(IvString: string): TStringVector;
var
  s: string;
begin
  s := Expande(IvString);
  Result := System.StrUtils.SplitString(s, ' ');
end;

function TStrRec.CharShift(const IvString: string; IvShift: integer): string;
var
  s: string;
  i: integer;
begin
  s := IvString;
  for i := 1 to Length(s) do
    s[i] := Chr(Ord(s[i]) + IvShift);
  Result := s;
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

function TStrRec.HasRex(IvString, IvRex: string; IvOpt: TRegExOptions): boolean;
begin
  Result := rex.Has(IvString, IvRex, IvOpt);
end;

function TStrRec.HasWildcard(IvString, IvStrWithWildcard: string): boolean;
var
  i, j, l, p: word;
begin
  i := 1; j := 1;
  while (i <= length(IvStrWithWildcard)) do begin
    if IvStrWithWildcard[i] = '*' then begin
      if i = Length(IvStrWithWildcard) then begin
        Result := true;
        Exit
      end else begin //we need to synchronize
        l := i + 1;
        while (l < Length(IvStrWithWildcard)) and (IvStrWithWildcard[l+1] <> '*') do
          inc (l);
          p := pos(copy(IvStrWithWildcard, i+1, l-i), IvString);
        if p > 0 then begin
          j := p-1;
        end else begin
          Result := false;
          Exit;
        end;
      end;
    end else if (IvStrWithWildcard[i] <> '?') and ((Length(IvString) < i) or (IvStrWithWildcard[i] <> IvString[j])) then begin
      Result := false;
      Exit
    end;
    inc (i);
    inc (j);
  end;
  Result := (j > Length(IvString));
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

function TStrRec.IsPath(const IvString: string): boolean;
begin
  Result := IvString.Contains('/') or IvString.Contains('\') or IvString.Contains('.');
end;

function TStrRec.Left(IvString: string; IvCount: integer): string;
begin
  Result := Copy(IvString, 1, IvCount);
end;

function TStrRec.LeftCut(s: string; i: integer): string;
begin
  Result := copy(s, i + 1, Length(s) - i);
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

function TStrRec.Match(IvSubString, IvString: string; IvCharMinToMatch: integer): boolean;
var
  l, i: integer;
begin
  // check
  Result := IvSubString <> '';
  if not Result then
    Exit;
  Result := Length(IvSubString) <= Length(IvString);
  if not Result then
    Exit;

  // mincharstomatch
  if IvCharMinToMatch < 1 then
    l := Length(IvSubString)
  else
    l := IvCharMinToMatch;

  // check l chars
  for i := 1 to l do begin
    Result := UpperCase(IvString[i]) = UpperCase(IvSubString[i]);
    if not Result then
      Exit; // no match
  end;
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

function TStrRec.PosLast(IvSubString, IvString: string): integer;
begin
  Result := IvString.LastIndexOf(IvSubString);
end;

function TStrRec.PosOfNth(IvSubString, IvString: string; IvNth: integer): integer;
var
  s: string; // str
  i, p, r: integer; // iteration, pos, result
begin
  // def
  Result := 0;

  // validate
  if ((IvNth < 1) or (IvSubString = '') or (IvString = '')) then
    Exit;

  // evaluate
  i := 0;
  r := 0;
  s := IvString;
  while (i < IvNth) do begin
    p := Pos(IvSubString, s);
    if (p = 0) then exit;
    r := r + p;
    s := Copy(IvString, r + 1, Length(IvString) - r);
    inc(i);
  end;
  Result := r;
end;

function TStrRec.Proper(IvString: string): string;
begin
  Result := UpperCase(Copy(IvString, 1, 1)) + LowerCase(Copy(IvString, 2, Length(IvString)-1));
end;

function TStrRec.Quote(const IvString: string): string;
begin
  Result := QuotedStr(IvString);
end;

function TStrRec.QuoteDbl(const IvString: string): string;
begin
  Result := AnsiQuotedStr(IvString, '"');
end;

function TStrRec.Remove(IvString, IvOut: string): string;
begin
  Result := Replace(IvString, IvOut, '');
end;

function TStrRec.Replace(IvString, IvOut, IvIn: string): string;
begin
  Result := StringReplace(IvString, IvOut, IvIn, [rfReplaceAll, rfIgnoreCase]);
end;

function TStrRec.Reverse(IvString: string): string;
var
  i: integer;
begin
  Result := '';
  for i := 1 to Length(IvString) do
    Result := IvString[i] + Result;
end;

function TStrRec.Right(IvString: string; IvCount: integer): string;
begin
  if IvCount > Length(IvString) then
    IvCount := Length(IvString);
  Result := copy(IvString, Length(IvString) - IvCount + 1, IvCount);
end;

function TStrRec.RightCut(s: string; i: integer): string;
begin
  Result := copy(s, i, Length(s) - i);
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

function TStrRec.ToBool(IvString: string; IvDefault: boolean): boolean;
var
  s: string;
begin
  s := UpperCase(Trim(IvString));

  if s = '' then begin
    Result := IvDefault;
    Exit;
  end;

       if s = 'KO'    then Result := false
  else if s = 'OFF'   then Result := false
  else if s = 'NO'    then Result := false
  else if s = 'FALSE' then Result := false

  else if s ='-1'     then Result := false
  else if s = '0'     then Result := false
  else if s = '1'     then Result := true

  else if s = 'TRUE'  then Result := true
  else if s = 'YES'   then Result := true
  else if s = 'ON'    then Result := true
  else if s = 'OK'    then Result := true
  else                     Result := false
  ;
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
  x: TDbaCls;
begin
  x := TDbaCls.Create(FDManager);
  try
    s :=           'insert into DbaSystem.dbo.TblLog'
    + sLineBreak + 'select'
    + sLineBreak + '     ''' + DateTimeToStr(Now) + '''' // FldDateTime
    + sLineBreak + '   , ''' + IvHost  + ''''            // FldHost
    + sLineBreak + '   , ''' + IvAgent + ''''            // FldAgent
    + sLineBreak + '   , ''' + IvTag   + ''''            // FldTag
    + sLineBreak + '   , ''' + IvValue + '''';           // FldValue
    if not x.ExecFD(s, z, k) then
      ods('TSYSREC.DBALOG', k);
  finally
    FreeAndNil(x);
  end;
end;

function TSysRec.HomePath(): string;
begin
  Result := obj.DbaParamGet('System', 'HomePath', 'X:\$\X\Win32\Debug');
end;

function TSysRec.IconUrl(): string;
begin
  Result := obj.DbaParamGet('System', 'IconUrl', '/Organization/W/Wks/WksIcon.ico');
end;

function TSysRec.IncPath(): string;
begin
  Result := obj.DbaParamGet('System', '$IncPath', 'X:\$Inc');
end;

function TSysRec.Info: string;
begin
  Result := Format('%s %s %s', [Acronym, Name, Www]);
end;

function TSysRec.LogoUrl(): string;
begin
  Result := obj.DbaParamGet('System', 'LogoUrl', '/Organization/W/Wks/WksLogo.png');
end;

function TSysRec.RioCopyright: string;
var
  o: boolean;
  k: string;
begin
  Screen.Cursor := crHourGlass;
  try
  // TEMPORARYCOMMENT
//  o := (rio.HttpRio as ISystemSoapMainService).SystemSoapCopyright(Result, k);
  finally
    Screen.Cursor := crDefault;
  end;
end;

function TSysRec.RioInfo: string;
var
  o: boolean;
  k: string;
begin
  Screen.Cursor := crHourGlass;
  try
  // TEMPORARYCOMMENT
//  o := (rio.HttpRio as ISystemSoapMainService).SystemSoapInfo(k);
  finally
    Screen.Cursor := crDefault;
  end;
end;

function TSysRec.RioLicense: string;
var
  o: boolean;
  k: string;
begin
  Screen.Cursor := crHourGlass;
  try
  // TEMPORARYCOMMENT
//  o := (rio.HttpRio as ISystemSoapMainService).SystemSoapLicense(Result, k);
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TSysRec.RioLog(IvHost, IvAgent, IvTag, IvValue: string; IvLifeMs: integer);
begin
  raise Exception.Create(NOT_IMPLEMENTED_STR);
end;

function TSysRec.RioOutline: string;
var
  o: boolean;
  k: string;
begin
  Screen.Cursor := crHourGlass;
  try
  // TEMPORARYCOMMENT
//  o := (rio.HttpRio as ISystemSoapMainService).SystemSoapOutline(Result, k);
  finally
    Screen.Cursor := crDefault;
  end;
end;

function TSysRec.RioPrivacy: string;
var
  o: boolean;
  k: string;
begin
  Screen.Cursor := crHourGlass;
  try
  // TEMPORARYCOMMENT
//  o := (rio.HttpRio as ISystemSoapMainService).SystemSoapPrivacy(Result, k);
  finally
    Screen.Cursor := crDefault;
  end;
end;

function TSysRec.RioRequestLog(IvOrganization, IvUsername, IvPassword, IvSession: string): string;
var
  o: boolean;
  k: string;
begin
  Screen.Cursor := crHourGlass;
  try
  // TEMPORARYCOMMENT
//  o := (rio.HttpRio as ISystemSoapMainService).SystemSoapRequestLog(IvOrganization, IvUsername, IvPassword, IvSession, Result, k);
  finally
    Screen.Cursor := crDefault;
  end;
end;

function TSysRec.RioSessionLog(IvOrganization, IvUsername, IvPassword, IvSession: string): string;
var
  o: boolean;
  k: string;
begin
  Screen.Cursor := crHourGlass;
  try
  // TEMPORARYCOMMENT
//  o := (rio.HttpRio as ISystemSoapMainService).SystemSoapSessionLog(IvOrganization, IvUsername, IvPassword, byn.Nick, Result, k);
  finally
    Screen.Cursor := crDefault;
  end;
end;

function TSysRec.Slogan(): string;
begin
  Result := obj.DbaParamGet('System', 'Slogan', 'Programmed for progress');
end;

function TSysRec.Support(): string;
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
  raise Exception.Create(NOT_IMPLEMENTED_STR);
end;

function TUagRec.DbaInsert(var IvFbk: string): boolean;
var
  q: string;
  z: integer;
  x: TDbaCls;
begin
  x := TDbaCls.Create(FDManager);
  try

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
    Result := x.ExecFD(q, z, IvFbk);
    {$ENDREGION}

  finally
    FreeAndNil(x);
  end;
end;

function TUagRec.DbaSelect(var IvFbk: string): boolean;
var
  d: TFDDataset;
  w, q: string;
  x: TDbaCls;
begin
  x := TDbaCls.Create(FDManager);
  try

    {$REGION 'Insert'}
    if not x.RecExists('DbaClient.dbo.TblUserAgent', 'FldUserAgent', UserAgent, IvFbk) then begin
      ods('USERAGENT', 'Useragent record does not exists, create it now');
      DbaInsert(IvFbk);
    end else begin
      // update the datetime in register
      w := 'FldUserAgent = ' + sql.Val(UserAgent);
      x.FldSet('DbaClient.dbo.TblUserAgent', 'FldDateTime', w, Now, IvFbk);
      x.FldInc('DbaClient.dbo.TblUserAgent', 'FldHit', w, IvFbk);
    end;
    {$ENDREGION}

    {$REGION 'Select'}
    q := Format('select * from DbaClient.dbo.TblUserAgent where FldUserAgent = ''%s''', [UserAgent]);
    Result := x.DsFD(q, d, IvFbk, true);
    if not Result then begin
      Result := DbaInsert(IvFbk);
      Result := x.DsFD(q, d, IvFbk, true);
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

  finally
    FreeAndNil(x);
  end;
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
  x: TDbaCls;
begin
  x := TDbaCls.Create(FDManager);
  try
    w := Format('FldUsername = ''%s''', [Username]);
    Result := x.RecExists('DbaUser.dbo.TblUser', w, k);
    IvFbk := fbk.ExistsStr('User', Username, Result);
  finally
    FreeAndNil(x);
  end;
end;

function TUsrRec.DbaIsActive(var IvFbk: string): boolean;
var
  w, k: string;
  x: TDbaCls;
begin
  x := TDbaCls.Create(FDManager);
  try
    w := Format('FldState = ''%s''', [sta.Active.Key]);
    Result := x.RecExists('DbaUser.dbo.TblUser', w, k);
    IvFbk := fbk.IsActiveStr('User', Username, Result);
  finally
    FreeAndNil(x);
  end;
end;

function TUsrRec.DbaIsAuthenticated(var IvFbk: string; IvConsiderUsernameOnly, IvPasswordSkip: boolean): boolean;
var
  w, s: string;
  r: variant; // returnval
  x: TDbaCls;
begin
  x := TDbaCls.Create(FDManager);
  try
    // nosqlinjection
    Organization := str.PartN(Organization, 0, ' ');
    Username     := str.PartN(Username    , 0, ' ');
    Password     := str.PartN(Password    , 0, ' ');

    // dba
    if IvConsiderUsernameOnly then begin
      w := UsernameWhere(Organization, Username, Password, true);
      Result := x.FldGet('DbaUser.dbo.TblUser', 'FldUsername', w, r, '', IvFbk);
      s := Username;
    end else begin
      w := UsernameWhere(Organization, Username, Password, false);
      Result := x.FldGet('DbaUser.dbo.TblUser', 'FldUsername', w, r, '', IvFbk);
      s := Format('%s@%s', [Username, Organization]);
    end;
    if not Result then
      Exit;

    // authenticated?
    Result := (r = Username) and (r <> '');
    IvFbk := fbk.IsAuthenticatedStr('User', Username, Result);
  finally
    FreeAndNil(x);
  end;
end;

function TUsrRec.DbaIsLoggedIn(var IvFbk: string): boolean;
var
  w, k: string;
  x: TDbaCls;
begin
  x := TDbaCls.Create(FDManager);
  try
  w := UsernameWhere(Organization, Username, Password, false) + Format(' and FldSession = ''%s''', [Session]);
  Result := x.RecExists('DbaUser.dbo.TblUser', w, k);
  IvFbk := fbk.IsLoggedStr('User', Username, Result);
  finally
    FreeAndNil(x);
  end;
end;

function TUsrRec.DbaSelect(const IvUsername: string; var IvFbk: string): boolean;
begin
  raise Exception.Create(NOT_IMPLEMENTED_STR);
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
  Screen.Cursor := crHourGlass;
  try
  // TEMPORARYCOMMENT
//  Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapUserExists(IvOrganization, IvUsername, IvFbk);
  finally
    Screen.Cursor := crDefault;
  end;
end;

function TUsrRec.RioIsActive(IvOrganization, IvUsername: string; var IvFbk: string): boolean;
begin
  Screen.Cursor := crHourGlass;
  try
  // TEMPORARYCOMMENT
//  Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapUserIsActive(IvOrganization, IvUsername, IvFbk);
  finally
    Screen.Cursor := crDefault;
  end;
end;

function TUsrRec.RioIsAuthenticated(IvOrganization, IvUsername, IvPassword: string; var IvFbk: string): boolean;
begin
  Screen.Cursor := crHourGlass;
  // TEMPORARYCOMMENT
//  Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapUserIsAuthenticated(IvOrganization, IvUsername, IvPassword, IvFbk);
  try
  finally
    Screen.Cursor := crDefault;
  end;
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

{$REGION 'TWapRec'}
function TWapRec.PathInfoActionIsValid(IvPathInfo: string): boolean;
var
  i: integer;
begin
  for i := 0 to WebModule.Actions.Count - 1 do begin
    Result := WebModule.Actions[i].PathInfo = IvPathInfo;
    if Result then
      Exit;
  end;
end;

procedure TWapRec.Reply(var IvWebResponse: TWebResponse; IvStateCode: integer; IvStateMessage, IvDebug: string);
begin
  IvWebResponse.StatusCode := IvStateCode;
  IvWebResponse.ReasonString := IvStateCode.ToString + ' ' + IvStateMessage;
//  if IvDebug.IsEmpty then
//    AddToLog('Response set: ' + IvWebResponse.StatusCode.ToString + ' ' + IvStateMessage, leDevelopment)
//  else
//    AddToLog('Response set: ' + IvWebResponse.StatusCode.ToString + ' ' + IvStateMessage + ' Debug Info: ' + IvDebug, leMinorError);
end;
{$ENDREGION}

{$REGION 'TWreRec'}
procedure TWreRec.Init(IvWebRequest: TWebRequest);
var
  c, o, k: string; // cookie, organization
  t: TDateTime;
  x: TDbaCls;
begin
  x := TDbaCls.Create(FDManager);
  try

    {$REGION 'UserAgent'}
    uag.UserAgent := IvWebRequest.UserAgent;
    //uag.DbaSelect(IvDbaCls, k);
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
    UserOrganization     :=   {Wks (fromurl/dba)                      }  x.ScalarFD('select top(1) FldOrganization from DbaOrganization.dbo.TblOrganization where FldState= ''Active'' and FldWww = ''' + WebRequest.Host + '''', 'Unknown', k);
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

  finally
    FreeAndNil(x);
  end;
end;

function TWreRec.DbaInsert(var IvFbk: string): boolean;
var
  q: string;
  z: integer;
  x: TDbaCls;
begin
  x := TDbaCls.Create(FDManager);
  try
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
    Result := x.ExecFD(q, z, IvFbk);
    if not Result then
      ods('TWREREC.DBAINSERT', IvFbk);

    // fbk
    IvFbk := Format('Web request %d saved into database', [RequestId]);
  finally
    FreeAndNil(x);
  end;
end;

function TWreRec.DbaSelectInput(var IvTable, IvField, IvWhere, IvFbk: string): boolean;
begin
  // database
//Result := Field('CoDba', IvDba, '', true, IvFbk);
//if not Result then
//  Exit;

  // table
  Result := Field('CoTable', IvTable, '', IvFbk);
  if not Result then
    Exit;

  // field
  Result := Field('CoField', IvField, '', IvFbk);
  if not Result then
    Exit;

  // where
  Result := Field('CoWhere', IvWhere, '', IvFbk);
end;

function TWreRec.DbaUpdateInput(var IvTable, IvField, IvWhere, IvValue, IvFbk: string): boolean;
begin
  // forselect
  Result := DbaSelectInput(IvTable, IvField, IvWhere, IvFbk);
  if not Result then
    Exit;

  // value
  Result := Field('CoValue', IvValue, '', IvFbk, false); // value can be empty
end;

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
  if Length(WebRequest.CookieFields.Values[IvCookie]) > 0 then
    Result := WebRequest.CookieFields.Values[IvCookie]
  else
    Result := IvDefault;
end;

function TWreRec.CookieGet(IvCookie: string; IvDefault: integer): integer;
var
  s, d: string; // default
begin
  d := IntToStr(IvDefault);
  s := CookieGet(IvCookie, d);
  Result := StrToInt(s);
end;

function TWreRec.CookieGet(IvCookie: string; IvDefault: boolean): boolean;
var
  s, d: string; // default
begin
  d := bol.ToStr(IvDefault);
  s := CookieGet(IvCookie, d);
  Result := bol.FromStr(s);
end;

function TWreRec.FieldExists(IvField: string; var IvFbk: string): boolean;
begin
  Result := (WebRequest.QueryFields.IndexOfName(IvField) >= 0) or (WebRequest.ContentFields.IndexOfName(IvField) >= 0);
  IvFbk := fbk.ExistsStr('WebField', IvField, Result);
end;

function TWreRec.Field(IvField: string; var IvValue: string; IvDefault: string; var IvFbk: string; IvFalseIfValueIsEmpty: boolean): boolean;
begin
  // exists
  if IvFalseIfValueIsEmpty then begin
    if not FieldExists(IvField, IvFbk) then begin
      Result := false;
      Exit;
    end;
  end;

  // queryfield 1sttry
  IvValue := WebRequest.QueryFields.Values[IvField];
  Result := IvValue <> '';
  if Result then begin
    IvFbk := Format('%s = %s selected from query fields', [IvField, IvValue]);
    Exit;
  end;

  // contentfield 2ndtry
  IvValue := WebRequest.ContentFields.Values[IvField];
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

function TWreRec.Field(IvField: string; var IvValue: integer; IvDefault: integer; var IvFbk: string; IvFalseIfValueIsEmpty: boolean): boolean;
var
  v, d: string; // value, default
begin
  d := IntToStr(IvDefault);
  Result := Field(IvField, v, d, IvFbk, IvFalseIfValueIsEmpty);
  IvValue := StrToIntDef(v, IvDefault);
end;

function TWreRec.Field(IvField: string; var IvValue: boolean; IvDefault: boolean; var IvFbk: string; IvFalseIfValueIsEmpty: boolean): boolean;
var
  v, d: string; // value, default
begin
  d := BoolToStr(IvDefault);
  Result := Field(IvField, v, d, IvFbk, IvFalseIfValueIsEmpty);
  IvValue := StrToBoolDef(v, IvDefault);
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
  raise Exception.Create(NOT_IMPLEMENTED_STR);
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
procedure TWrsRec.CookieSet(IvCookie: string; IvValue: variant; IvExpireInXDay: double; IvDomain, IvPath: string);
begin
  with WebResponse.Cookies.Add do begin
    Name                           := IvCookie; // key
    Value                          := IvValue;  // value
    if IvDomain <> '' then Domain  := IvDomain; // wre.Domain
    Path                           := IvPath;   // '/'
  //Secure                         := false;    // ???
    Expires                        := Now + IvExpireInXDay;
  end;
end;

procedure TWrsRec.CookieDelete(IvCookie: string; IvDomain, IvPath: string);
begin
  raise Exception.Create(NOT_IMPLEMENTED_STR);
end;
{$ENDREGION}

{$REGION 'TVstRec'}
(*
procedure TVstRec.GetImageIndex(IvVst: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: TImageIndex);
var
  r: PNodeItem; // q: TDTNodeItem;
  n{, l}, i, p, z, k, s, o, w: string; // name, level, id, pid, ord, kind, state, orga, owner
begin
  // def
  ImageIndex := -1;

  {$REGION 'Exit'}
  if not (Kind in [ikNormal, ikSelected]) then // only selected or not
    Exit;
  if Column > 0 then // -1 = nocolumns, 0 = 1stcol, 1..= 2nd..col
    Exit;
  {$ENDREGION}

  {$REGION 'Info DUPLICATED'}
  try
    // node
    r := IvVst.GetNodeData(Node);
    if not Assigned(r) then
      Exit;

    // level
  //l := IvVst.GetNodeLevel(Node);

    // name
    n := r.Caption;
  //n := r.Param[0];       // only available if r.Param has been set during AgentDTClientTreeDBTreeCreateNode
  //n := r.FieldValues[1]; // only available if header columns values are present

    {0-id          }  i := r.Key; //i := r.Param[0];

    if VarIsClear(r.Param) then
      Exit;

    {1-pid         }  p := r.Param[1];
    {2-order       }  z := r.Param[2];
    {3-kind        }  k := r.Param[3];
    {4-state       }  s := r.Param[4];
    {5-organization}  o := r.Param[5];
    {6-owner       }  w := r.Param[6]; // r.FieldValues[6];

    // kind
  //if not VarIsClear(r.Param)       and (VarArrayDimCount(r.Param)       = 1) and (VarArrayHighBound(r.Param, 1) > 1) then k := VarToStrDef(r.Param[2]      , '') else k := '';
  //if not VarIsClear(r.FieldValues) and (VarArrayDimCount(r.FieldValues) = 1) and (VarArrayHighBound(r.Param, 1) > 0) then k := VarToStrDef(r.FieldValues[1], '') else k := '';

    // state
  //if not VarIsClear(r.Param)       and (VarArrayDimCount(r.Param)       = 1) and (VarArrayHighBound(r.Param, 1) > 2) then s := VarToStrDef(r.Param[3]      , '') else s := '';
  //if not VarIsClear(r.FieldValues) and (VarArrayDimCount(r.FieldValues) = 1) and (VarArrayHighBound(r.Param, 1) > 1) then s := VarToStrDef(r.FieldValues[2], '') else s := '';
  except
    ;
  end;
  {$ENDREGION}

  {$REGION 'ById'}
  {$ENDREGION}

  {$REGION 'ByName'}
  // 0-level (root)
       if n            = 'Root'                 then ImageIndex :=  1
  // 1-level
  else if SameText(n   , 'Zzz'                ) then ImageIndex :=  3
  else if SameText(   n, 'System'             ) then ImageIndex :=  2
  else if nam.IsNumOf(n, 'Test'               ) then ImageIndex := 20
  else if SameText(   n, 'Template'           ) then ImageIndex := 12
  else if SameText(   n, 'Organization'       ) then ImageIndex :=  6
  else if n =            'People'               then ImageIndex := 57
  else if nam.IsNumOf(n, 'Public'             ) then ImageIndex := 70
  else if nam.IsNumOf(n, 'Help'               ) then ImageIndex := 19
  else if nam.IsNumOf(n, 'New'                ) then ImageIndex := 25
  else if SameText(   n, '!!!'                ) then ImageIndex :=  4
  // objects
  else if nam.IsNumOf(n, 'Folder'             ) then ImageIndex :=  8
  else if n =            'Unknown'              then ImageIndex := 14
  else if nam.IsNumOf(n, 'Link'               ) then ImageIndex := 11
  else if nam.IsNumOf(n, 'Library'            ) then ImageIndex := 10
  // objects
  else if n =            'Localhost'            then ImageIndex := 14
  else if n =            'Person'               then ImageIndex := 16
  else if n =            'Member'               then ImageIndex := 66
  else if n =            'Sidemenu'             then ImageIndex := 34
  else if n =            'Image'                then ImageIndex := 75
  else if n =            'Picture'              then ImageIndex := 76
  // notevoli
  else if n            = 'Wks'                  then ImageIndex := 15
  else if nam.IsNumOf(n, 'Sample'             ) then ImageIndex := 20
  else if nam.IsNumOf(n, 'Reserved'           ) then ImageIndex :=  5
  else if SameText(n   , '???'                ) then ImageIndex :=  4
  else if Length(n) = 1                         then ImageIndex :=  9 // A..Z
  // structure
  else if SameText(n   , 'Department'         ) then ImageIndex := 21
  else if SameText(n   , 'Area'               ) then ImageIndex := 38
  else if SameText(n   , 'Team'               ) then ImageIndex := 39
  // organization=school
  else if SameText(n   , 'School')              then ImageIndex := 71
  // area
//else if SameText(n   , 'Cfa'                ) or SameText(n, 'Cfa') or SameText(n, 'Cf') then ImageIndex := 24
//else if SameText(n   , 'Cmp'                ) or SameText(n, 'Cmp') or SameText(n, 'Cm') then ImageIndex := 25
//else if SameText(n   , 'Cvd'                ) or SameText(n, 'Cvd') or SameText(n, 'Cv') then ImageIndex := 26
//else if SameText(n   , 'Diffusion'          ) or SameText(n, 'Dif') or SameText(n, 'Df') then ImageIndex := 27
//else if SameText(n   , 'DryEtch'            ) or SameText(n, 'Dry') or SameText(n, 'De') then ImageIndex := 28
//else if SameText(n   , 'FailureAnalysis'    ) or SameText(n, 'Fan') or SameText(n, 'Fa') then ImageIndex := 29
//else if SameText(n   , 'Implant'            ) or SameText(n, 'Imp') or SameText(n, 'Im') then ImageIndex := 30
//else if SameText(n   , 'Metrology'          ) or SameText(n, 'Met') or SameText(n, 'Mt') then ImageIndex := 31
//else if SameText(n   , 'Photo'              ) or SameText(n, 'Pho') or SameText(n, 'Ph') then ImageIndex := 32
//else if SameText(n   , 'Probe'              ) or SameText(n, 'Prb') or SameText(n, 'Pr') then ImageIndex := 33
//else if SameText(n   , 'Pvd'                ) or SameText(n, 'Pvd') or SameText(n, 'Pv') then ImageIndex := 34
//else if SameText(n   , 'Rda'                ) or SameText(n, 'Rda') or SameText(n, 'Rd') then ImageIndex := 35
//else if SameText(n   , 'Wet'                ) or SameText(n, 'Wet') or SameText(n, 'Wp') then ImageIndex := 36
  // task
//else if SameText(n, tsk.TaskKindOrganization) then ImageIndex :=  1
//else if SameText(n, tsk.TaskKindPortfolio   ) then ImageIndex :=  2
//else if SameText(n, tsk.TaskKindProgram     ) then ImageIndex :=  3
//else if SameText(n, tsk.TaskKindPackage     ) then ImageIndex :=  4
//else if SameText(n, tsk.TaskKindProject     ) then ImageIndex :=  5
//else if SameText(n, tsk.TaskKindModule      ) then ImageIndex :=  6
//else if SameText(n, tsk.TaskKindGroup       ) then ImageIndex :=  7
//else if SameText(n, tsk.TaskKindTask        ) then ImageIndex :=  8
  {$ENDREGION}

  {$REGION 'ByKind'}
  // system
  else if k         =    'Root'                 then ImageIndex :=   1
  else if k         =    'Folder'               then ImageIndex :=   8
  else if k         =    'Library'              then ImageIndex :=  10
  else if k         =    'Link'                 then ImageIndex :=  11
  else if k         =    'Param'                then ImageIndex :=  99
  else if k         =    'Switch'               then ImageIndex :=  94
  // object
  else if k         =    'User'                 then ImageIndex :=  90
  else if k         =    'Person'               then ImageIndex := 100
  else if k         =    'Men'                  then ImageIndex :=  16
  else if k         =    'Woman'                then ImageIndex :=  17
  else if k         =    'Member'               then ImageIndex :=  67
  else if k         =    'Account'              then ImageIndex :=  90
  // organization
  else if k         =    'Organization'         then ImageIndex :=   6
  else if k         =    'Department'           then ImageIndex :=  21
  else if k         =    'Area'                 then ImageIndex :=  38
  else if k         =    'Team'                 then ImageIndex :=  39
  // organization=school
  else if k         =    'School'               then ImageIndex :=  72
  // document
  else if k         =    'Page'                 then ImageIndex :=  67
  else if k         =    'Home'                 then ImageIndex :=  7
  else if k         =    'MenuLeft'             then ImageIndex :=  91
  else if k         =    'MenuRight'            then ImageIndex :=  92
  else if k         =    'Document'             then ImageIndex :=  66
  else if k         =    'Presentation'         then ImageIndex :=  68
  else if k         =    'Slide'                then ImageIndex :=  69
  else if k         =    'Image'                then ImageIndex :=  75
  else if k         =    'Picture'              then ImageIndex :=  76
  else if k         =    'Report'               then ImageIndex :=  98
  // spc
  else if k         =    'Run'                  then ImageIndex :=  38
  else if k         =    'ZScore'               then ImageIndex :=  39
  // code
  else if k         = cod.BAT_KIND              then ImageIndex :=  36 // *** WARNING, POTENTIALLY INCOMPLETE ***
  else if k         = cod.CSS_KIND              then ImageIndex :=  49
  else if k         = cod.CSV_KIND              then ImageIndex :=  43
  else if k         = cod.DWS_KIND              then ImageIndex :=  46
  else if k         = cod.ETL_KIND              then ImageIndex :=  45
  else if k         = cod.ETL_SQL_KIND          then ImageIndex :=  14 // TODO
  else if k         = cod.ETL_MONGO_KIND        then ImageIndex :=  14 // TODO
  else if k         = cod.HTML_KIND             then ImageIndex :=  48
  else if k         = cod.ISS_KIND              then ImageIndex :=  93
  else if k         = cod.JAVA_KIND             then ImageIndex :=  14 // TODO
  else if k         = cod.JS_KIND               then ImageIndex :=  50
  else if k         = cod.JSON_KIND             then ImageIndex :=  51
  else if k         = cod.PAS_KIND              then ImageIndex :=  55
  else if k         = cod.PY_KIND               then ImageIndex :=  52
  else if k         = cod.R_KIND                then ImageIndex :=  54
  else if k         = cod.SQL_KIND              then ImageIndex :=  44
  else if k         = cod.TXT_KIND              then ImageIndex :=  42
  else if k         = cod.INI_KIND              then ImageIndex :=  97
  {$ENDREGION}

  {$REGION 'ByState'}
  // managed via text color, see onpainttext
  {$ENDREGION}

  {$REGION 'else'}
  else                                               ImageIndex :=  0; // -1
  {$ENDREGION}

end;
*)
procedure TVstRec.GetNodeInfo(IvVst: TBaseVirtualTree; Node: PVirtualNode; var IvPath, IvCaption: string; var IvKey, IvLevel, IvChildCount: integer);
var
  d: PNodeItem;
begin
  d            := IvVst.GetNodeData(Node);
  IvPath       := GetNodePath(IvVst, Node, '/');
  IvCaption    := d.Caption;
  IvKey        := d.Key.ToInteger;
  IvLevel      := IvVst.GetNodeLevel(Node);
  IvChildCount := Node.ChildCount;
end;

function TVstRec.GetNodePath(IvVst: TBaseVirtualTree; IvNode: PVirtualNode; IvDelimiter: char; IvUseLevels: boolean): string;
const
  COLUMN = 0;
var
  l: cardinal;
begin
  if not Assigned(IvNode) then begin
    Result := '';
    Exit;
  end;

  if not IvUseLevels then begin
    Result := (IvVst as TVirtualStringTree).Path(IvNode, COLUMN, IvDelimiter);
    Exit;
  end;

  Result := '';
  while IvNode <> IvVst.RootNode do begin
    l := IvVst.GetNodeLevel(IvNode);
    Result := IntToStr(l) + IvDelimiter + Result;
    IvNode := IvNode.Parent;
  end;
  Delete(Result, Length(Result), 1);
end;

procedure TVstRec.NodeParamSet(IvVst: TVirtualStringTree; IvNode: PVirtualNode; IvDs: TDataSet);
var
  r: PNodeItem;
  i, p, z, k, s, o, w: string; // id, pid, ord, kind, state, orga, owner
begin
  // parent state kind
  if Assigned(IvDs.FindField('FldId'          )) then i := IvDs.FieldByName('FldId'          ).AsString else i := '0';
  if Assigned(IvDs.FindField('FldPId'         )) then p := IvDs.FieldByName('FldPId'         ).AsString else p := '0';
  if Assigned(IvDs.FindField('FldOrder'       )) then z := IvDs.FieldByName('FldOrder'       ).AsString else z := '0';
  if Assigned(IvDs.FindField('FldKind'        )) then k := IvDs.FieldByName('FldKind'        ).AsString else k := sta.Unknown.Key;
  if Assigned(IvDs.FindField('FldState'       )) then s := IvDs.FieldByName('FldState'       ).AsString else s := sta.Unknown.Key;
  if Assigned(IvDs.FindField('FldOrganization')) then o := IvDs.FieldByName('FldOrganization').AsString else o := sta.Unknown.Key;
  if Assigned(IvDs.FindField('FldOwner'       )) then w := IvDs.FieldByName('FldOwner'       ).AsString else w := sta.Unknown.Key;

  // set
  r := IvVst.GetNodeData(IvNode);
  r.Param := VarArrayOf([i, p, z, k, s, o, w]);

  // in OnFormCreate might appear DTClientTree.NodeDataSize := SizeOf(PNodeItem)
  //IvVst.NodeDataSize := SizeOf(r);
end;

procedure TVstRec.OnCompareNodes(IvVst: TBaseVirtualTree; Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: integer);
var
  a, b: PNodeItem;
  r, s: string;  // orderstr
  i, j: integer; // orderint
begin
  // a
  a := IvVst.GetNodeData(Node1);
  if not Assigned(a) then begin
    Result := 0;
    Exit;
  end;

  // b
  b := IvVst.GetNodeData(Node2);
  if not Assigned(b) then begin
    Result := 0;
    Exit;
  end;

  // sort
  try
    // bycaption
    if Column <= 0 then begin
      r := a.Caption;
      s := b.Caption;
      Result := CompareText(r, s);

    // byspecificcolumnorparam
    end else begin
      //if VarIsNull(a.FieldValues[Column]) then i := 0 else i := a.FieldValues[Column];
      //if VarIsNull(b.FieldValues[Column]) then j := 0 else j := b.FieldValues[Column];
      r := a.FieldValues[Column]; // VarToStr(a.FieldValues[Column])
      s := b.FieldValues[Column]; // VarToStr(a.FieldValues[Column])
      if str.IsNumeric(r) and str.IsNumeric(s) then
        Result := StrToIntDef(r, 0) - StrToIntDef(s, 0)
      else
        Result := CompareText(r, s);
    end;
  except
    Result := 0;
  end;
end;

procedure TVstRec.OnPaintText(IvVst: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
var
  r: PNodeItem; // q: TDTNodeItem;
  n{, l}, i, p, z, k, s, o, w: string; // name, level, id, pid, ord, kind, state, orga, owner
begin

  {$REGION 'Exit'}
  if Column > 0 then // -1 = nocolumns, 0 = 1stcol, 1..= 2nd..col
    Exit;
  {$ENDREGION}

  {$REGION 'Info DUPLICATED'}
  try
    // node
    r := IvVst.GetNodeData(Node);
    if not Assigned(r) then
      Exit;

    // level
  //l := IvVst.GetNodeLevel(Node);

    // name
    n := r.Caption;
  //n := r.Param[0];       // only available if r.Param has been set during AgentDTClientTreeDBTreeCreateNode
  //n := r.FieldValues[1]; // only available if header columns values are present

    {0-id          }  i := r.Key; //i := r.Param[0];

    if VarIsClear(r.Param) then
      Exit;

    {1-pid         }  p := r.Param[1];
    {2-order       }  z := r.Param[2];
    {3-kind        }  k := r.Param[3];
    {4-state       }  s := r.Param[4];
    {5-organization}  o := r.Param[5];
    {6-owner       }  w := r.Param[6]; // r.FieldValues[6];

    // kind
  //if not VarIsClear(r.Param)       and (VarArrayDimCount(r.Param)       = 1) and (VarArrayHighBound(r.Param, 1) > 1) then k := VarToStrDef(r.Param[2]      , '') else k := '';
  //if not VarIsClear(r.FieldValues) and (VarArrayDimCount(r.FieldValues) = 1) and (VarArrayHighBound(r.Param, 1) > 0) then k := VarToStrDef(r.FieldValues[1], '') else k := '';

    // state
  //if not VarIsClear(r.Param)       and (VarArrayDimCount(r.Param)       = 1) and (VarArrayHighBound(r.Param, 1) > 2) then s := VarToStrDef(r.Param[3]      , '') else s := '';
  //if not VarIsClear(r.FieldValues) and (VarArrayDimCount(r.FieldValues) = 1) and (VarArrayHighBound(r.Param, 1) > 1) then s := VarToStrDef(r.FieldValues[2], '') else s := '';
  except
    ;
  end;

  // exit
  if Str.Has('Root,Folder,Link', n)  then
    Exit;
  {$ENDREGION}

  {$REGION 'ByState'}
       if s = sta.Active.Key     then       TargetCanvas.Font.Color := col.BLUE //; TargetCanvas.Brush.Color := clBlue; TargetCanvas.Font.Style := Font.Style + [{fsBold,} fsItalic];
  else if s = sta.Inactive.Key   then       TargetCanvas.Font.Color := col.GRAY
//else if s = sta.Archived.Key   then
//else if s = sta.Developing.Key then
  else if s = sta.Testing.Key    then begin TargetCanvas.Font.Color := col.ORANGE; TargetCanvas.Font.Style := TargetCanvas.Font.Style + [{fsBold,} fsItalic]; end
  else if s = sta.Validating.Key then       TargetCanvas.Font.Color := col.ORANGERED
  else if s = sta.Validated.Key  then       TargetCanvas.Font.Color := col.GREEN
  else if s = sta.Running.Key    then       TargetCanvas.Font.Color := col.RED
//else if s = sta.New.Key        then
//else if s = sta.Waiting.Key    then
//else if s = sta.Unknown.Key    then
  ;
  {$ENDREGION}

end;
{$ENDREGION}

initialization

{$REGION 'Init'}
  lmx := TCriticalSection.Create;
  ods('WKSALLUNIT INIT', '--== I N I T I A L I Z A T I O N ==--');
  ods('WKSALLUNIT INIT', 'TCriticalSection created');

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

  FOR ISAPI DLL
  Q: in the initialization section of a unit, I create the thread and in the
     finalization section I would like to free/release/terminate the thread

  A: that is not a good thing to do inside a DLL
     you should export public functions like TerminateExtension that is callod by IIS just before to unload the dll.
  }
  {$ENDREGION}

  {$REGION 'FormatSettings'}
  FormatSettings.DecimalSeparator  := '.';              // or numbers will be 12,123 with a comma instead of a period
  FormatSettings.ShortDateFormat   := 'MM/dd/yyyy';     // or mssql will fails
  FormatSettings.ShortTimeFormat   := 'HH:mm:ss AM/PM'; // or mssql will fails
  Application.UpdateFormatSettings := false;            // avoid windows to change back the format setting, to much size increase
  ods('WKSALLUNIT INIT', 'FormatSettings applied');
  {$ENDREGION}

  {$REGION 'Leaks'}
  {$WARN SYMBOL_PLATFORM OFF}
  ReportMemoryLeaksOnShutDown := IsDebuggerPresent();
  ods('WKSALLUNIT INIT', 'ReportMemoryLeaksOnShutDown');
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
  ods('WKSALLUNIT INIT', 'TStopwatch wa0 started');
  {$ENDREGION}

  {$REGION 'sys'}                                                                 (*
  // main
  bmp.GetFromRc(sys.LogoBmp, 'WKS_LOGO_BMP_RC');
  ods('WKSALLUNIT INIT COMMON SYSTEM LOGO', 'Assigned');

  // dirs
  if not DirectoryExists(sys.TEMPDIR) then CreateDir(sys.TEMPDIR);

  // smtp-out
  sys.Smtp.Host     := ini.StrGet('Smtp/Host'    , sys.SMTP_HOST    );
  sys.Smtp.Port     := ini.StrGet('Smtp/Port'    , sys.SMTP_PORT    );
  sys.Smtp.Username := ini.StrGet('Smtp/Username', sys.SMTP_USERNAME);
  sys.Smtp.Password := ini.StrGet('Smtp/Password', sys.SMTP_PASSWORD);
  ods('WKSALLUNIT INIT COMMON SYSTEM SMTP', 'Assigned');

  // pop3-in
  sys.Pop3.Host     := ini.StrGet('Pop3/Host'    , sys.POP3_HOST    );
  sys.Pop3.Port     := ini.StrGet('Pop3/Port'    , sys.POP3_PORT    );
  sys.Pop3.Username := ini.StrGet('Pop3/Username', sys.POP3_USERNAME);
  sys.Pop3.Password := ini.StrGet('Pop3/Password', sys.POP3_PASSWORD);
  ods('WKSALLUNIT INIT COMMON SYSTEM POP3', 'Assigned');

  ods('WKSALLUNIT INIT', 'TSysRec sys initialized');                   *)
  {$ENDREGION}

  {$REGION 'lic'}
  //ods('WKSALLUNIT INIT', 'TLicRec lic not implemented');
  {$ENDREGION}

  {$REGION 'log'}
  //lgt := TLgtCls.Create(); // globalobject
  //ods('WKSALLUNIT INIT', 'TThreadFileLog created');
  {$ENDREGION}

  {$REGION 'SERVER'}
  if byn.IsServer or byn.IsDemon then begin

    {$REGION 'com'}
  //CoInitializeEx(nil, COINIT_MULTITHREADED); // use COINIT_APARTMENTTHREADED for opaR
  //ods('WKSALLUNIT INIT SERVER', 'COM initialized');
    {$ENDREGION}

    {$REGION 'dba'}
    {
      *** WARNING ***

      IN SERVERS APP LIKE ISAPI OR SOAP THESE OBJECTS CAN BE USED ONLY AT SERVER-INSTANCE LEVEL
      USE THEM IN WebModuleCreate/WebModuleDestroy EVENTS

      IN EACH USER REQUEST SESSION USE LOCAL OBJECTS TO ACCESS DBS
      CREATED THEM IN WebModuleBeforeDispatch AND IMMEDIATELY DESTROYED IN WebModuleAfterDispatch
      THIS WAY EACH USER HAS IT OWN CONNECTION TO THE DB LIVING FOR A SHORT PERIOD OF TIME

      THESE OBJETS CAN ALSO BE USED IN UTILITIES APPLICATIONS THAT DIRECTLY CAN SEE THE DB
    }

  //db0 := TDbaCls.Create(ini.StrGet('Database/Db0FDCs', ''));
  //ods('WKSALLUNIT INIT SERVER', 'TDbaCls db0 created (mssql)');

  //db1 := TDbaCls.Create(ini.StrGet('Database/Db1Cs', ''));
  //ods('WKSALLUNIT INIT SERVER', 'TMonCls db1 created (mongo)');

  //db2 := TDbaCls.Create(ini.StrGet('Database/Db2Cs', ''), 'Redis', '???Client');
  //ods('WKSALLUNIT INIT SERVER', 'TRedCls db2 created (redis)');

  //db3 := TDbaCls.Create(ini.StrGet('Database/Db3Cs', ''), 'Kafka', 'LogClient');
  //ods('WKSALLUNIT INIT SERVER', 'TKafCls db2 created (kafka)');
    {$ENDREGION}

    {$REGION 'usr,mbr,org,smt,pop : nologin'}
  //ods('WKSALLUNIT INIT SERVER', 'User, member and organization data acquired after a user webrequest (domanin -> organization, login --> user/menber)');
    {$ENDREGION}

  end;
  {$ENDREGION}

  {$REGION 'CLIENT'}
  if byn.IsClient then begin

    {$REGION 'ico'}
    h00 := LoadIcon(HInstance, 'AAA_APPLICATION_ICON_INV_RC');
    if h00 > 0 then begin
      Application.Icon.Handle := h00; // assign main icon at runtime
      ods('WKSALLUNIT INIT CLIENT', 'icon assigned');
    end else
      ods('WKSALLUNIT INIT CLIENT', 'Unable to assign icon');
    {$ENDREGION}

    {$REGION 'hlp'}
  //Application.HelpFile := ChangeFileExt(Application.ExeName, 'Help.chm');
  //ods('WKSALLUNIT INIT CLIENT', 'Help file not implemented');
    {$ENDREGION}

    {$REGION 'com'}
  //ods('WKSALLUNIT INIT CLIENT', 'COM not implemented');
    {$ENDREGION}

    {$REGION 'dba'}
  //ods('WKSALLUNIT INIT CLIENT', 'DbaCls not implemented');
    {$ENDREGION}

    {$REGION 'net'}
  //if not net.InternetIsAvailable(fk) then begin
  //  ods('WKSALLUNIT INIT CLIENT', 'Internet is not available, exit');
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
  //ods('WKSALLUNIT INIT CLIENT', 'User, member and organization data acquired after a succesful login');
    {$ENDREGION}

    {$REGION 'gui'}
  //syn.SynEditSearch      := TSynEditSearch.Create(nil);
  //syn.SynEditRegexSearch := TSynEditRegexSearch.Create(nil);
  //syg.SearchFromCaret    := true;
  //ods('WKSALLUNIT INIT CLIENT', 'gui stuff created (syneditsearch)');
    {$ENDREGION}

  end;
  {$ENDREGION}

{$ENDREGION}

finalization

{$REGION 'Fine'}
  ods('WKSALLUNIT FINE', '--== F I N A L I Z A T I O N ==--');

  {$REGION 'CLIENT'}
  if byn.IsClient then begin

    {$REGION 'gui'}
  //FreeAndNil(syn.SynEditSearch);
  //FreeAndNil(syn.SynEditRegexSearch);
  //ods('WKSALLUNIT FINE CLIENT', 'gui stuff free (syneditsearch)');
    {$ENDREGION}

    {$REGION 'usr,mbr,org,smt,pop : logout'}
  //FreeAndNil(org.LogoGraphic);
  //ods('WKSALLUNIT FINE CLIENT', 'User, member and organization stuff free');

    // sessionclose
  //ses.RioClose(usr.Organization, usr.Username, fk);
  //ods('WKSALLUNIT FINE CLIENT', 'User logout');
    {$ENDREGION}

  end;
  {$ENDREGION}

  {$REGION 'SERVER'}
  if byn.IsServer or byn.IsDemon then begin

    {$REGION 'usr,mbr,org,smt,pop : nologout'}
  //usr.Avatar.Free;
  //mbr.Badge.Free;
  //org.LogoGraphic.Free;
  //ods('WKSALLUNIT FINE SERVER', 'User, member and organization stuff free');
    {$ENDREGION}

    {$REGION 'dba'}
  //db0.Free; // *** problems freeing the FConnFD ***
  //ods('WKSALLUNIT FINE SERVER', 'TDbaCls db0 free (mssql)');
    {$ENDREGION}

    {$REGION 'com'}
  //CoUninitialize; // non so se e' questo a causare il disaster !!!
  //ods('WKSALLUNIT FINE SERVER', 'COM uninitialize');
    {$ENDREGION}

  end;
  {$ENDREGION}

  {$REGION 'log'}
  //lgt.Free; // cause the iis applicationpool to not recycle properly, do this in TerminateExtension place
  //ods('WKSALLUNIT FINE', 'TThreadFileLog NOT free');
  {$ENDREGION}

  {$REGION 'sys'}
  //FreeAndNil(sys.LogoBmp);
  //ods('WKSALLUNIT FINE', 'TSysCls logo bitmap free');
  {$ENDREGION}

  {$REGION 'wa0'}
  ods('WKSALLUNIT FINE', 'TStopwatch total lifetime ' + wa0.ElapsedMilliseconds.ToString + ' ms');
  {$ENDREGION}

  ods('WKSALLUNIT FINE', 'TCriticalSection free');
  ods('WKSALLUNIT FINE', '--== E N D ==--');
  FreeAndNil(lmx);
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
  Screen.Cursor := crHourGlass;
  try
    Result := (rio.HttpRio as ISystemSoapMainService).SystemSoapRecordInsertSimple(IvTable, IvStringVe, IvFbk);
  finally
    Screen.Cursor := crDefault;
  end;
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
