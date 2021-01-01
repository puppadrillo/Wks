object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'MainForm'
  ClientHeight = 501
  ClientWidth = 1302
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  WindowState = wsMaximized
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 249
    Width = 1302
    Height = 3
    Cursor = crVSplit
    Align = alTop
    ExplicitTop = 201
    ExplicitWidth = 323
  end
  object TopPanel: TPanel
    Left = 0
    Top = 0
    Width = 1302
    Height = 89
    Align = alTop
    BevelOuter = bvNone
    Caption = 'TopPanel'
    ShowCaption = False
    TabOrder = 0
    DesignSize = (
      1302
      89)
    object UrlLabel: TLabel
      Left = 8
      Top = 13
      Width = 13
      Height = 13
      Caption = 'Url'
    end
    object ResultLabel: TLabel
      AlignWithMargins = True
      Left = 403
      Top = 51
      Width = 41
      Height = 16
      Margins.Right = 16
      Caption = 'Result'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlCenter
    end
    object GoButton: TButton
      Left = 1011
      Top = 10
      Width = 42
      Height = 21
      Anchors = [akTop, akRight]
      Caption = 'Go'
      TabOrder = 0
      OnClick = GoButtonClick
    end
    object StartButton: TButton
      Left = 1115
      Top = 10
      Width = 41
      Height = 21
      Anchors = [akTop, akRight]
      Caption = 'Start'
      TabOrder = 1
      OnClick = StartButtonClick
    end
    object ClearAtStartCheckBox: TCheckBox
      Left = 284
      Top = 52
      Width = 72
      Height = 17
      Caption = 'Clean start'
      Checked = True
      State = cbChecked
      TabOrder = 2
    end
    object LogResponseCheckBox: TCheckBox
      Left = 197
      Top = 52
      Width = 81
      Height = 17
      Caption = 'Log response'
      TabOrder = 3
    end
    object ClearButton: TButton
      Left = 1243
      Top = 10
      Width = 49
      Height = 21
      Margins.Top = 9
      Margins.Right = 13
      Margins.Bottom = 9
      Anchors = [akTop, akRight]
      Caption = 'Clear'
      TabOrder = 4
      OnClick = ClearButtonClick
    end
    object LogCheckBox: TCheckBox
      Left = 155
      Top = 52
      Width = 36
      Height = 17
      Caption = 'Log'
      Checked = True
      State = cbChecked
      TabOrder = 5
    end
    object UrlComboBox: TComboBox
      Left = 228
      Top = 10
      Width = 169
      Height = 21
      TabOrder = 6
      Text = 'UrlComboBox'
    end
    object WebsiteComboBox: TComboBox
      Left = 27
      Top = 10
      Width = 135
      Height = 21
      TabOrder = 7
      Text = 'WebsiteComboBox'
    end
    object PortComboBox: TComboBox
      Left = 168
      Top = 10
      Width = 54
      Height = 21
      TabOrder = 8
      Text = 'PortComboBox'
    end
    object RepeatComboBox: TComboBox
      Left = 1059
      Top = 10
      Width = 50
      Height = 21
      Anchors = [akTop, akRight]
      DropDownCount = 12
      TabOrder = 9
      Text = 'RepeatComboBox'
      Items.Strings = (
        '1'
        '10'
        '100'
        '1000'
        '2'
        '20'
        '200'
        '2000'
        '5'
        '50'
        '500'
        '5000')
    end
    object ThreadGoButton: TButton
      Left = 1162
      Top = 10
      Width = 75
      Height = 21
      Anchors = [akTop, akRight]
      Caption = 'Thread Start'
      TabOrder = 10
      OnClick = ThreadGoButtonClick
    end
    object AgentRadioGroup: TRadioGroup
      Left = 27
      Top = 37
      Width = 114
      Height = 40
      Caption = ' Agent '
      Columns = 2
      Items.Strings = (
        'Wsst'
        'Ie')
      TabOrder = 11
      OnClick = AgentRadioGroupClick
    end
    object PathInfoComboBox: TComboBox
      Left = 403
      Top = 10
      Width = 94
      Height = 21
      TabOrder = 12
      Text = 'PathInfoComboBox'
    end
    object QueryEdit: TEdit
      Left = 503
      Top = 10
      Width = 502
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 13
      Text = 'QueryEdit'
    end
  end
  object ChartPanel: TPanel
    Left = 0
    Top = 89
    Width = 1302
    Height = 160
    Align = alTop
    Caption = 'ChartPanel'
    ShowCaption = False
    TabOrder = 1
    object TickChart: TChart
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 1294
      Height = 152
      Legend.Visible = False
      Title.Text.Strings = (
        'Ticks')
      BottomAxis.Axis.Color = clDefault
      BottomAxis.Axis.Width = 0
      BottomAxis.Grid.Visible = False
      BottomAxis.MinorTickCount = 1
      BottomAxis.TickLength = 5
      DepthAxis.Automatic = False
      DepthAxis.AutomaticMaximum = False
      DepthAxis.AutomaticMinimum = False
      DepthAxis.Maximum = 0.500000000000000000
      DepthAxis.Minimum = -0.500000000000000000
      DepthTopAxis.Automatic = False
      DepthTopAxis.AutomaticMaximum = False
      DepthTopAxis.AutomaticMinimum = False
      DepthTopAxis.Maximum = 0.500000000000000000
      DepthTopAxis.Minimum = -0.500000000000000000
      LeftAxis.Axis.Width = 0
      LeftAxis.Grid.Visible = False
      LeftAxis.MinorTicks.Visible = False
      LeftAxis.TickLength = 5
      LeftAxis.Title.Pen.Color = clDefault
      TopAxis.Visible = False
      View3D = False
      View3DWalls = False
      Align = alClient
      BevelOuter = bvNone
      Color = clWindow
      TabOrder = 0
      DefaultCanvas = 'TGDIPlusCanvas'
      ColorPaletteIndex = 7
      object Series1: TPointSeries
        Marks.Brush.Gradient.Visible = True
        Marks.Font.Height = -20
        Marks.Callout.Length = 20
        ClickableLine = False
        Pointer.Brush.Color = clRed
        Pointer.Brush.BackColor = clRed
        Pointer.HorizSize = 3
        Pointer.InflateMargins = True
        Pointer.Pen.Width = 0
        Pointer.Pen.Visible = False
        Pointer.Style = psCircle
        Pointer.VertSize = 3
        XValues.Name = 'X'
        XValues.Order = loAscending
        YValues.Name = 'Y'
        YValues.Order = loNone
      end
    end
  end
  object MainPageControl: TPageControl
    AlignWithMargins = True
    Left = 3
    Top = 255
    Width = 1296
    Height = 243
    ActivePage = ChromeTabSheet
    Align = alClient
    TabOrder = 2
    object WsstTabSheet: TTabSheet
      Caption = 'Wsst'
      object WsstMemo: TMemo
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 1282
        Height = 209
        Align = alClient
        BorderStyle = bsNone
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        Lines.Strings = (
          'WsstMemo')
        ParentFont = False
        ScrollBars = ssVertical
        TabOrder = 0
        WordWrap = False
      end
    end
    object IeTabSheet: TTabSheet
      Caption = '   Ie'
      ImageIndex = 1
      object IeWebBrowser: TWebBrowser
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 1282
        Height = 209
        Align = alClient
        TabOrder = 0
        OnBeforeNavigate2 = IeWebBrowserBeforeNavigate2
        OnNavigateComplete2 = IeWebBrowserNavigateComplete2
        OnDocumentComplete = IeWebBrowserDocumentComplete
        ExplicitLeft = 160
        ExplicitTop = 56
        ExplicitWidth = 300
        ExplicitHeight = 150
        ControlData = {
          4C000000808400009A1500000000000000000000000000000000000000000000
          000000004C000000000000000000000001000000E0D057007335CF11AE690800
          2B2E126208000000000000004C0000000114020000000000C000000000000046
          8000000000000000000000000000000000000000000000000000000000000000
          00000000000000000100000000000000000000000000000000000000}
      end
    end
    object ChromeTabSheet: TTabSheet
      Caption = 'Chrome'
      ImageIndex = 3
    end
    object LogTabSheet: TTabSheet
      Caption = '  Log'
      ImageIndex = 2
      object LogPanel: TPanel
        Left = 0
        Top = 0
        Width = 1288
        Height = 41
        Align = alTop
        BevelOuter = bvNone
        Caption = 'LogPanel'
        ShowCaption = False
        TabOrder = 0
        object LogRefreshButton: TButton
          Left = 8
          Top = 8
          Width = 75
          Height = 25
          Caption = 'Refresh'
          TabOrder = 0
          OnClick = LogRefreshButtonClick
        end
        object LogClearButton: TButton
          Left = 89
          Top = 9
          Width = 75
          Height = 25
          Caption = 'Clear'
          TabOrder = 1
          OnClick = LogClearButtonClick
        end
        object LogScrollDownButton: TButton
          Left = 170
          Top = 10
          Width = 75
          Height = 25
          Caption = 'Scroll Down'
          TabOrder = 2
          OnClick = LogScrollDownButtonClick
        end
        object LogDeleteButton: TButton
          Left = 251
          Top = 10
          Width = 75
          Height = 25
          Caption = 'Log Delete'
          TabOrder = 3
          OnClick = LogDeleteButtonClick
        end
      end
      object LogSynEdit: TSynEdit
        Left = 0
        Top = 41
        Width = 1288
        Height = 174
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Pitch = fpFixed
        Font.Style = []
        TabOrder = 1
        Gutter.AutoSize = True
        Gutter.Font.Charset = DEFAULT_CHARSET
        Gutter.Font.Color = clWindowText
        Gutter.Font.Height = -11
        Gutter.Font.Name = 'Courier New'
        Gutter.Font.Style = []
        Gutter.LeadingZeros = True
        Gutter.LeftOffset = 2
        Gutter.ShowLineNumbers = True
        Lines.Strings = (
          'LogSynEdit')
        Options = [eoEnhanceEndKey, eoGroupUndo, eoShowScrollHint, eoSmartTabDelete, eoSmartTabs]
        ScrollBars = ssVertical
        FontSmoothing = fsmNone
      end
    end
  end
end
