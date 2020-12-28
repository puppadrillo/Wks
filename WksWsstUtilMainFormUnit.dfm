object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'MainForm'
  ClientHeight = 524
  ClientWidth = 1018
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 201
    Width = 1018
    Height = 3
    Cursor = crVSplit
    Align = alTop
    ExplicitWidth = 323
  end
  object TopPanel: TPanel
    Left = 0
    Top = 0
    Width = 1018
    Height = 41
    Align = alTop
    Caption = 'TopPanel'
    ShowCaption = False
    TabOrder = 0
    object UrlLabel: TLabel
      Left = 8
      Top = 13
      Width = 13
      Height = 13
      Caption = 'Url'
    end
    object ResultLabel: TLabel
      AlignWithMargins = True
      Left = 960
      Top = 4
      Width = 41
      Height = 36
      Margins.Right = 16
      Align = alRight
      Caption = 'Result'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlCenter
      ExplicitHeight = 16
    end
    object GoButton: TButton
      Left = 343
      Top = 10
      Width = 42
      Height = 21
      Caption = 'Go'
      TabOrder = 0
      OnClick = GoButtonClick
    end
    object GoThreadButton: TButton
      Left = 435
      Top = 10
      Width = 41
      Height = 21
      Caption = 'Start'
      TabOrder = 1
      OnClick = GoThreadButtonClick
    end
    object RepeatEdit: TEdit
      Left = 391
      Top = 10
      Width = 38
      Height = 21
      TabOrder = 2
      Text = 'RepeatEdit'
    end
    object ClearAtStartCheckBox: TCheckBox
      Left = 537
      Top = 12
      Width = 72
      Height = 17
      Caption = 'Clean start'
      Checked = True
      State = cbChecked
      TabOrder = 3
    end
    object LogResponseCheckBox: TCheckBox
      Left = 615
      Top = 12
      Width = 81
      Height = 17
      Caption = 'Log response'
      TabOrder = 4
    end
    object ClearButton: TButton
      AlignWithMargins = True
      Left = 895
      Top = 10
      Width = 49
      Height = 21
      Margins.Top = 9
      Margins.Right = 13
      Margins.Bottom = 9
      Align = alRight
      Caption = 'Clear'
      TabOrder = 5
      OnClick = ClearButtonClick
    end
    object LogCheckBox: TCheckBox
      Left = 495
      Top = 12
      Width = 36
      Height = 17
      Caption = 'Log'
      Checked = True
      State = cbChecked
      TabOrder = 6
    end
    object UrlComboBox: TComboBox
      Left = 168
      Top = 10
      Width = 169
      Height = 21
      TabOrder = 7
      Text = 'UrlComboBox'
    end
    object WebsiteComboBox: TComboBox
      Left = 27
      Top = 10
      Width = 135
      Height = 21
      TabOrder = 8
      Text = 'WebsiteComboBox'
    end
  end
  object LogMemo: TMemo
    AlignWithMargins = True
    Left = 3
    Top = 207
    Width = 1012
    Height = 314
    Align = alClient
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    Lines.Strings = (
      'LogMemo')
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object ChartPanel: TPanel
    Left = 0
    Top = 41
    Width = 1018
    Height = 160
    Align = alTop
    Caption = 'ChartPanel'
    ShowCaption = False
    TabOrder = 2
    object TickChart: TChart
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 1010
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
end
