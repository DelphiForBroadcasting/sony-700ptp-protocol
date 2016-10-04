(*

UI BASIC OPTIONS
  TList<TPair<COLOR, DISCRIPTION>>
    #FF333333 - dsfsdfdsf


  TList<URL>
    http://www.iconsdb.com/custom-color/settings-14-icon.html               - SETTINGS
    http://www.iconsdb.com/custom-color/settings-4-icon.html                - SETTINGS
    http://www.iconsdb.com/custom-color/parallel-tasks-icon.html            - PARA
    http://www.iconsdb.com/custom-color/sharethis-3-icon.html               - PARA
    http://www.iconsdb.com/custom-color/side-left-view-icon.html            - SIDE
    http://www.iconsdb.com/custom-color/left-navigation-toolbar-icon.html   - SIDE
    http://www.iconsdb.com/custom-color/list-view-icon.html                 - BARS
    panel active LOOK UNLOOK
    http://www.iconsdb.com/custom-color/signs-icons.html
*)


unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.Generics.Defaults, System.Generics.Collections,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.EditBox,
  FMX.SpinBox, FMX.Controls.Presentation, FMX.Edit, FMX.StdCtrls, FMX.ListBox,
  FMX.Layouts, FMX.Memo, IdBaseComponent, IdComponent, IdTCPConnection, IdGlobal,
  FMX.MultiView, FMX.Menus, FMX.Ani, FMX.Effects, FMX.Objects,
  FMX.Filter.Effects, FMX.TabControl, System.Actions, FMX.ActnList, IdTCPClient,
  FMX.ScrollBox,
  FH.SONY.SPP.CNS,
  FH.SONY.SPP.PACKET,
  FH.SONY.SPP.UTILS,
  FH.SONY.SPP.CNS.BRIDGE,
  FH.SONY.SPP.CNS.MCS;

type
  TForm1 = class(TForm)
    StyleBook1: TStyleBook;
    pLayoutConfig: TLayout;
    pLayoutPanel: TPanel;
    FloatAnimation1: TFloatAnimation;
    cMainLayout: TLayout;
    ListBox1: TListBox;
    ListBoxItem1: TListBoxItem;
    Switch1: TSwitch;
    Label4: TLabel;
    Label5: TLabel;
    Edit2: TEdit;
    SpinBox1: TSpinBox;
    Label1: TLabel;
    ListBoxItem2: TListBoxItem;
    Switch2: TSwitch;
    Label6: TLabel;
    Label7: TLabel;
    Edit3: TEdit;
    Layout2: TLayout;
    cFooterLayout: TLayout;
    SpeedButton8: TSpeedButton;
    TabControl1: TTabControl;
    tHomePaga: TTabItem;
    tMenuPaga: TTabItem;
    tDebugPage: TTabItem;
    cMenuControl: TTabControl;
    cMainMenuItem: TTabItem;
    cConfigItem: TTabItem;
    ListBox2: TListBox;
    lbConfig: TListBoxItem;
    lbMaintenance: TListBoxItem;
    ActionList1: TActionList;
    cMainMenuItemAction: TChangeTabAction;
    lbScene: TListBoxItem;
    lbFunction: TListBoxItem;
    lbMulti: TListBoxItem;
    lbFile: TListBoxItem;
    lbPaint: TListBoxItem;
    cSceneItem: TTabItem;
    cFunctionItem: TTabItem;
    cFileItem: TTabItem;
    cPaintItem: TTabItem;
    cMultiItem: TTabItem;
    ListBox3: TListBox;
    lbConfig_Camera: TListBoxItem;
    lbConfig_CCU: TListBoxItem;
    lbConfig_RCP: TListBoxItem;
    lbConfig_RCPAssign: TListBoxItem;
    lbConfig_MultiFormat: TListBoxItem;
    lbConfig_BPUMultiFormat: TListBoxItem;
    Button3: TButton;
    GlowEffect1: TGlowEffect;
    cControlPanel: TPanel;
    GlowEffect2: TGlowEffect;
    cHeaderPanel: TPanel;
    GlowEffect3: TGlowEffect;
    Text1: TText;
    ShadowEffect2: TShadowEffect;
    ScrollBox2: TScrollBox;
    Expander1: TExpander;
    Button11: TButton;
    Expander2: TExpander;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    SpeedButton7: TSpeedButton;
    ArcDial1: TArcDial;
    SizeGrip1: TSizeGrip;
    ListBoxItem32: TListBoxItem;
    ListBoxItem33: TListBoxItem;
    Panel1: TPanel;
    GlowEffect4: TGlowEffect;
    ScrollBox1: TScrollBox;
    cDebugExpander: TExpander;
    Memo1: TMemo;
    FloatAnimation2: TFloatAnimation;
    cMaintenanceItem: TTabItem;
    ListBox4: TListBox;
    lbMaintenanceCamera: TListBoxItem;
    lbMaintenanceLens: TListBoxItem;
    lbMaintenanceCcu: TListBoxItem;
    lbMaintenanceSDAdj: TListBoxItem;
    cTitleAction: TControlAction;
    cBackTabAction: TChangeTabAction;
    ToolBar2: TToolBar;
    GlowEffect5: TGlowEffect;
    SpeedButton11: TSpeedButton;
    Label2: TLabel;
    cMaintenanceCameraItem: TTabItem;
    ListBox5: TListBox;
    lbMaintenanceCameraBlackShading: TListBoxItem;
    lbMaintenanceCameraWhiteShading: TListBoxItem;
    lbMaintenanceCameraBlackSet: TListBoxItem;
    lbMaintenanceCameraOHBMatrix: TListBoxItem;
    lbMaintenanceCameraAtwSettings: TListBoxItem;
    lbMaintenanceCameraMicGain: TListBoxItem;
    cMaintenanceLensItem: TTabItem;
    ListBox6: TListBox;
    lbMaintenanceLensAutoIris: TListBoxItem;
    lbMaintenanceLensFlare: TListBoxItem;
    lbMaintenanceLensVModSaw: TListBoxItem;
    lbMaintenanceLensAlac: TListBoxItem;
    lbMaintenanceRpn: TListBoxItem;
    cMaintenanceCameraMicGainItem: TTabItem;
    Layout3: TLayout;
    Button4: TButton;
    Button5: TButton;
    Edit6: TEdit;
    Layout4: TLayout;
    Button6: TButton;
    Button7: TButton;
    Edit4: TEdit;
    cMaintenanceCameraAtwItem: TTabItem;
    cMaintenanceCameraOHBMatrixItem: TTabItem;
    cMaintenanceSDAdjSDDetailItem: TTabItem;
    cMaintenanceSDAdjSDGammaItem: TTabItem;
    cMaintenanceSDAdjSDMatrixItem: TTabItem;
    cMaintenanceSDAdjInterpolationItem: TTabItem;
    cMaintenanceSDAdjCrossColorItem: TTabItem;
    cMaintenanceSDAdjAspectItem: TTabItem;
    cConfigCameraItem: TTabItem;
    cMaintenanceCameraBlackSetItem: TTabItem;
    cMaintenanceCameraWhiteShadingItem: TTabItem;
    cMaintenanceCameraBlackShadingItem: TTabItem;
    cMaintenanceCCUItem: TTabItem;
    cMaintenanceRPNItem: TTabItem;
    cMaintenanceSDAdjItem: TTabItem;
    cMaintenanceCCUMonitorOutItem: TTabItem;
    cMaintenanceLensAutoIrisItem: TTabItem;
    cMaintenanceLensFlareItem: TTabItem;
    cMaintenanceLensVModSawItem: TTabItem;
    cMaintenanceLensAlacItem: TTabItem;
    Layout5: TLayout;
    SpeedButton1: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton2: TSpeedButton;
    Text2: TText;
    cMaintenanceCCUPhaseItem: TTabItem;
    ListBox7: TListBox;
    lbMaintenanceCcuPhase: TListBoxItem;
    lbMaintenanceCcuMonOut: TListBoxItem;
    ListBox8: TListBox;
    lbMaintenanceSDAdjSDDetail: TListBoxItem;
    lbMaintenanceSDAdjSDGamma: TListBoxItem;
    lbMaintenanceSDAdjSDMatrix: TListBoxItem;
    lbMaintenanceSDAdjInterpolation: TListBoxItem;
    lbMaintenanceSDAdjCrossColor: TListBoxItem;
    lbMaintenanceSDAdjAspect: TListBoxItem;
    cSwitchTabItemAction: TChangeTabAction;
    cConfigCCUItem: TTabItem;
    cFunctionOpticalLevelItem: TTabItem;
    cFunctionPIXWFItem: TTabItem;
    TabItem4: TTabItem;
    TabItem5: TTabItem;
    TabItem6: TTabItem;
    TabItem7: TTabItem;
    TabItem8: TTabItem;
    TabItem9: TTabItem;
    cConfigRCPItem: TTabItem;
    cConfigRCPAssignItem: TTabItem;
    cConfigMultiFormatItem: TTabItem;
    cConfigBPUMultiFormatItem: TTabItem;
    ListBox9: TListBox;
    lbFunctionOpticalLevel: TListBoxItem;
    lbFunctionPIXWF: TListBoxItem;
    Layout6: TLayout;
    Rectangle2: TRectangle;
    SpeedButton9: TSpeedButton;
    SpeedButton10: TSpeedButton;
    SpeedButton13: TSpeedButton;
    SpeedButton14: TSpeedButton;
    Layout8: TLayout;
    Rectangle3: TRectangle;
    SpeedButton15: TSpeedButton;
    SpeedButton16: TSpeedButton;
    SpeedButton17: TSpeedButton;
    SpeedButton18: TSpeedButton;
    SpeedButton19: TSpeedButton;
    Label3: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Layout7: TLayout;
    Layout1: TLayout;
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Label10: TLabel;
    Layout9: TLayout;
    Button8: TButton;
    Button9: TButton;
    Edit5: TEdit;
    Label11: TLabel;
    Label12: TLabel;
    Layout10: TLayout;
    Layout11: TLayout;
    Button10: TButton;
    Button12: TButton;
    Edit7: TEdit;
    Label13: TLabel;
    SpeedButton12: TSpeedButton;
    Label14: TLabel;
    TabControl2: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    TabItem3: TTabItem;
    Layout12: TLayout;
    Layout13: TLayout;
    Label15: TLabel;
    Edit8: TEdit;
    ArcDial3: TArcDial;
    Layout15: TLayout;
    Label17: TLabel;
    Edit10: TEdit;
    ArcDial4: TArcDial;
    Layout16: TLayout;
    Label18: TLabel;
    Edit11: TEdit;
    ArcDial5: TArcDial;
    Layout14: TLayout;
    Label16: TLabel;
    Edit9: TEdit;
    ArcDial2: TArcDial;
    Layout17: TLayout;
    SpeedButton20: TSpeedButton;
    SpeedButton21: TSpeedButton;
    SpeedButton22: TSpeedButton;
    Expander3: TExpander;
    Edit12: TEdit;
    SpinBox2: TSpinBox;
    Button13: TButton;
    Button14: TButton;
    Button15: TButton;
    Button16: TButton;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MSUClientOnDebug(Sender: TObject; messages: string);
    procedure Button11Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Expander1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure Expander1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Single);
    procedure Expander1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure Expander2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure Expander2MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Single);
    procedure Expander2MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure SpeedButton8Click(Sender: TObject);
    procedure Switch2Switch(Sender: TObject);
    procedure FloatAnimation1OnFinish(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure SpeedButton11Click(Sender: TObject);
    procedure ActionList1Update(Action: TBasicAction; var Handled: Boolean);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure ScrollBox1Gesture(Sender: TObject;
      const EventInfo: TGestureEventInfo; var Handled: Boolean);
    procedure Button4ApplyStyleLookup(Sender: TObject);
    procedure MenuItemClick(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
    procedure Button15Click(Sender: TObject);
    procedure Button16Click(Sender: TObject);
  private
    FConsole          : string;
    FMenuHistory      : TStack<TTabItem>;
    procedure InitRcpMenu;
    function FindItemParent(Obj: TFmxObject; ParentClass: TClass): TFmxObject;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  CNSBridge : TSPpCnsBridge;
  SPpCnsMcs : TSPpCnsMcs;

  // Mouse Drag Control
  FMouseDown: Boolean;
  FMouseStart: TPointF;
implementation

{$R *.fmx}

uses
  FMX.Platform, FMX.VirtualKeyboard, System.Rtti;


procedure TForm1.MSUClientOnDebug(Sender: TObject; messages: string);
begin
  memo1.Lines.Insert(0, formatdatetime('hh:mm:ss.zzz', now)+' : '+messages);
end;

procedure TForm1.ScrollBox1Gesture(Sender: TObject;
  const EventInfo: TGestureEventInfo; var Handled: Boolean);
begin
  case EventInfo.GestureID of
    sgiLeft :     cDebugExpander.Visible := not cDebugExpander.Visible;
  end;
end;

procedure TForm1.SpeedButton11Click(Sender: TObject);
var
  LTabItem : TTabItem;
begin
  if FMenuHistory.Count>=1 then
  begin
    LTabItem := FMenuHistory.Pop;
    cBackTabAction.Tab := LTabItem;
    self.cBackTabAction.ExecuteTarget(self);
  end;
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
  (sender as TSpeedButton).IsPressed := CNSBridge.SetBARS;
end;

procedure TForm1.FloatAnimation1OnFinish(Sender: TObject);
begin
    cMainLayout.visible := true;
end;

procedure TForm1.SpeedButton8Click(Sender: TObject);
var
  targetX: single;
begin
  targetX := Self.ClientWidth - 65;

  if (pLayoutPanel.Position.X = targetX) then
  begin
    FloatAnimation1.StartValue := targetX;
    FloatAnimation1.StopValue := 0;
    FloatAnimation1.OnFinish := FloatAnimation1OnFinish;
  end
  else
  begin
    FloatAnimation1.StartValue := 0;
    FloatAnimation1.StopValue := targetX;
    FloatAnimation1.OnFinish := nil;
    cMainLayout.visible := false;
  end;
  FloatAnimation1.Start;
end;

procedure TForm1.Switch2Switch(Sender: TObject);
begin
  if (Sender as TSwitch).IsChecked then
  begin
    CNSBridge.RCPId := Round(SpinBox1.Value) and $FF;
    CNSBridge.Mode :=   TSPpCNSMode.m_BRIDGE;
    CNSBridge.SerialNumber  :=  1;
    CNSBridge.Host := Edit3.Text;
    CNSBridge.Connect;
  end else
  begin
     CNSBridge.Disconnect;
  end;
end;

procedure TForm1.ActionList1Update(Action: TBasicAction; var Handled: Boolean);
var
  LTab: TTabItem;
begin
  LTab := self.cMenuControl.ActiveTab;

  if Action = cTitleAction then
    cTitleAction.Text := LTab.Text;
end;

procedure TForm1.Button11Click(Sender: TObject);
begin
  CNSBridge.GetMicrophoneGain(
    procedure(Sender: TObject; ABasicPacket: TSPpBasicPacket; const Ch01: byte; const Ch02: byte)
    begin
      edit6.Text := format('%d',[TSPpMicrophoneGain.Raw2Value(Ch01)]);
      edit4.Text := format('%d',[TSPpMicrophoneGain.Raw2Value(Ch02)]);
    end,
    procedure(Sender: TObject; E: Exception)
    begin
      MSUClientOnDebug(Sender, e.Message);
    end
  );
end;

procedure TForm1.Button13Click(Sender: TObject);
begin
  SPpCnsMcs.RCPId := Round(SpinBox1.Value) and $FF;
  SPpCnsMcs.SerialNumber  :=  1;
  SPpCnsMcs.Host := Edit12.Text;
  SPpCnsMcs.Connect;
end;

procedure TForm1.Button14Click(Sender: TObject);
begin
  SPpCnsMcs.Disconnect;
end;

procedure TForm1.Button15Click(Sender: TObject);
begin
  SPpCnsMcs.Assignment(round(SpinBox2.Value) and $FF);
end;

procedure TForm1.Button16Click(Sender: TObject);
begin
  SPpCnsMcs.GetCcuIpAddress(round(SpinBox2.Value) and $FF);

end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  SpeedButton1.IsPressed := CNSBridge.GetBARS;

  CNSBridge.GetMicrophoneGain(
    procedure(Sender: TObject; ABasicPacket: TSPpBasicPacket; const Ch01: byte; const Ch02: byte)
    begin
      edit6.Text := format('%d',[TSPpMicrophoneGain.Raw2Value(Ch01)]);
      edit4.Text := format('%d',[TSPpMicrophoneGain.Raw2Value(Ch02)]);
    end,
    procedure(Sender: TObject; E: Exception)
    begin
      MSUClientOnDebug(Sender, e.Message);
    end
  );
end;

procedure TForm1.Button4ApplyStyleLookup(Sender: TObject);
var
  BckObject: TFmxObject;
  RecObject: TFmxObject;
begin
{  BckObject := Button4.FindStyleResource('background');
  if Assigned(BckObject) and (BckObject is TRectAngle) then
  begin
    TRectAngle(BckObject).XRadius := 5.0;
    TRectAngle(BckObject).YRadius := 5.0;
    TRectAngle(BckObject).Fill.Gradient.Style := TGradientStyle.Linear;
    TRectAngle(BckObject).Fill.Gradient.Points.Points[0].Color := $FF0097A5;
    TRectAngle(BckObject).Fill.Gradient.Points.Points[0].Offset := 0.25;
    TRectAngle(BckObject).Fill.Gradient.Points.Points[1].Color := $FF0097F5;
    TRectAngle(BckObject).Fill.Gradient.Points.Points[1].Offset := 1.00;
  end; }
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  CNSBridge.SetMicrophoneGain($08, false,
    procedure(Sender: TObject; ABasicPacket: TSPpBasicPacket; const Ch01: byte; const Ch02: byte)
    begin
      edit6.Text := format('%d',[TSPpMicrophoneGain.Raw2Value(Ch01)]);
    end,
    procedure(Sender: TObject; E: Exception)
    begin
      MSUClientOnDebug(Sender, e.Message);
    end
  );
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  CNSBridge.SetMicrophoneGain($08, true,
    procedure(Sender: TObject; ABasicPacket: TSPpBasicPacket; const Ch01: byte; const Ch02: byte)
    begin
      edit6.Text := format('%d',[TSPpMicrophoneGain.Raw2Value(Ch01)]);
    end,
    procedure(Sender: TObject; E: Exception)
    begin
      MSUClientOnDebug(Sender, e.Message);
    end
  );
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  CNSBridge.SetMicrophoneGain($09, false,
    procedure(Sender: TObject; ABasicPacket: TSPpBasicPacket; const Ch01: byte; const Ch02: byte)
    begin
      edit4.Text := format('%d',[TSPpMicrophoneGain.Raw2Value(Ch01)]);
    end,
    procedure(Sender: TObject; E: Exception)
    begin
      MSUClientOnDebug(Sender, e.Message);
    end
  );
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
  CNSBridge.SetMicrophoneGain($09, true,
    procedure(Sender: TObject; ABasicPacket: TSPpBasicPacket; const Ch01: byte; const Ch02: byte)
    begin
      edit4.Text := format('%d',[TSPpMicrophoneGain.Raw2Value(Ch01)]);
    end,
    procedure(Sender: TObject; E: Exception)
    begin
      MSUClientOnDebug(Sender, e.Message);
    end
  );
end;

procedure TForm1.Expander1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  FMouseDown := True;
  FMouseStart.X := X;
  FMouseStart.Y := Y;
  (Sender as TExpander).Root.Captured := (Sender as TControl);
end;

procedure TForm1.Expander1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Single);
begin
  X :=  X - FMouseStart.X;     // in local coords  how far mouse has moved horizontally
  Y :=  Y - FMouseStart.Y;     // in local coords  how far mouse has moved horizontally
  if FMouseDown and (Abs(FMouseStart.X) > 0.9) then  // want to move at least one pixel left or right
  begin
    (Sender as TExpander).Position.X := (Sender as TExpander).Position.X + X
  end;

  if FMouseDown and (Abs(FMouseStart.Y) > 0.9) then  // want to move at least one pixel left or right
  begin
    (Sender as TExpander).Position.Y := (Sender as TExpander).Position.Y + Y
  end;
end;

procedure TForm1.Expander1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  FMouseDown := False;
  (Sender as TExpander).Root.Captured := nil;
end;

procedure TForm1.Expander2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  FMouseDown := True;
  FMouseStart.X := X;
  FMouseStart.Y := Y;
  (Sender as TExpander).Root.Captured := (Sender as TControl);
end;

procedure TForm1.Expander2MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Single);
begin
  X :=  X - FMouseStart.X;     // in local coords  how far mouse has moved horizontally
  Y :=  Y - FMouseStart.Y;     // in local coords  how far mouse has moved horizontally
  if FMouseDown and (Abs(FMouseStart.X) > 0.9) then  // want to move at least one pixel left or right
  begin
    (Sender as TExpander).Position.X := (Sender as TExpander).Position.X + X
  end;

  if FMouseDown and (Abs(FMouseStart.Y) > 0.9) then  // want to move at least one pixel left or right
  begin
    (Sender as TExpander).Position.Y := (Sender as TExpander).Position.Y + Y
  end;
end;

procedure TForm1.Expander2MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  FMouseDown := False;
  (Sender as TExpander).Root.Captured := nil;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FMenuHistory := TStack<TTabItem>.Create;

  InitRcpMenu;

  CNSBridge := TSPpCNSBridge.Create(MSUClientOnDebug);
  CNSBridge.SerialNumber:=$00005050;
  CNSBridge.OnMicrophoneGain := procedure(Sender: TObject; ABasicPacket: TSPpBasicPacket; const Ch01: byte; const Ch02: byte)
                                begin
                                  form1.Caption := 'OnMicrophoneGain'
                                end;




  SPpCnsMcs := TSPpCnsMcs.Create(MSUClientOnDebug);
  SPpCnsMcs.SerialNumber:=$00005050;

end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  CNSBridge.Destroy;

  SPpCnsMcs.Destroy;


  FMenuHistory.Destroy;
end;


procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
begin
  if length(FConsole)>10 then
    FConsole:= copy(FConsole, 2, length(FConsole));
  FConsole := FConsole + KeyChar;

  if (pos('debug', FConsole)>0) or (pos('DEBUG', FConsole)>0) then
  begin
    FConsole:='';
    cDebugExpander.Visible := not cDebugExpander.Visible;
  end;


  if pos('close', FConsole)>0 then
  begin
    FConsole:='';
    close;
  end;
end;

procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
var
  FService : IFMXVirtualKeyboardService;
begin
  if Key = vkHardwareBack then
  begin
    TPlatformServices.Current.SupportsPlatformService(IFMXVirtualKeyboardService, IInterface(FService));
    if (FService <> nil) and (TVirtualKeyboardState.Visible in FService.VirtualKeyBoardState) then
    begin
      // Back button pressed, keyboard visible, so do nothing...
    end else
    begin
      // Back button pressed, keyboard not visible or not supported on this platform, lets exit the app...
      if MessageDlg('Exit Application?', TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbOK, TMsgDlgBtn.mbCancel], -1) = mrOK then
      begin
        //
      end else
      begin
        // They changed their mind, so ignore the Back button press...
        Key := 0;
      end;
    end;
  end
end;

procedure TForm1.MenuItemClick(Sender: TObject);
var
  LTabItem          : TTabItem;
  LListBoxItem      : TListBoxItem;
begin
  if Sender is TListBoxItem then
  begin
    LListBoxItem := (Sender as TListBoxItem);
    LTabItem := TTabItem(FindItemParent(Sender as TFMXObject, TTabItem));

    if assigned(LTabItem) and (LListBoxItem.TagObject is TTabItem) then
    begin
      (* Add parent Tab to backlist *)
      FMenuHistory.Push(LTabItem);
      self.cSwitchTabItemAction.Tab := TTabItem(LListBoxItem.TagObject);
      self.cSwitchTabItemAction.ExecuteTarget(self);
    end;

  end;
end;

procedure TForm1.InitRcpMenu;
begin

  //::MainMenu::Scene
  self.lbScene.TagObject := Self.cSceneItem;
  self.lbScene.OnClick := MenuItemClick;

  //::MainMenu::Function
  self.lbFunction.TagObject := Self.cFunctionItem;
    //::MainMenu::Function::OpticalLevel
    self.lbFunctionOpticalLevel.TagObject := Self.cFunctionOpticalLevelItem;
    //::MainMenu::Function::PIXWF
    self.lbFunctionPIXWF.TagObject := Self.cFunctionPIXWFItem;


  //::MainMenu::Config
  self.lbConfig.TagObject := Self.cConfigItem;
    //::MainMenu::Config::Camera
    self.lbConfig_Camera.TagObject := Self.cConfigCameraItem;
    //::MainMenu::Config::CCU
    self.lbConfig_CCU.TagObject := Self.cConfigCCUItem;
    //::MainMenu::Config::RCP
    self.lbConfig_RCP.TagObject := Self.cConfigRCPItem;
    //::MainMenu::Config::RCP Assign
    self.lbConfig_RCPAssign.TagObject := Self.cConfigRCPAssignItem;
    //::MainMenu::Config::Multi Format
    self.lbConfig_MultiFormat.TagObject := Self.cConfigMultiFormatItem;
    //::MainMenu::Config::BPU Multi Format
    self.lbConfig_BPUMultiFormat.TagObject := Self.cConfigBPUMultiFormatItem;

  //::MainMenu::Maintenance
  self.lbMaintenance.TagObject := Self.cMaintenanceItem;
    //::MainMenu::Maintenance::Camera
    self.lbMaintenanceCamera.TagObject := Self.cMaintenanceCameraItem;
      //::MainMenu::Maintenance::Camera::Black Shading
      self.lbMaintenanceCameraBlackShading.TagObject := Self.cMaintenanceCameraBlackShadingItem;
      //::MainMenu::Maintenance::Camera::White Shading
      self.lbMaintenanceCameraWhiteShading.TagObject := Self.cMaintenanceCameraWhiteShadingItem;
      //::MainMenu::Maintenance::Camera::Black Set
      self.lbMaintenanceCameraBlackSet.TagObject := Self.cMaintenanceCameraBlackSetItem;
      //::MainMenu::Maintenance::Camera::OHB Matrix
      self.lbMaintenanceCameraOHBMatrix.TagObject := Self.cMaintenanceCameraOHBMatrixItem;
      //::MainMenu::Maintenance::Camera::ATW Settings
      self.lbMaintenanceCameraAtwSettings.TagObject := Self.cMaintenanceCameraAtwItem;
      //::MainMenu::Maintenance::Camera:: Microphone Gain
      self.lbMaintenanceCameraMicGain.TagObject := Self.cMaintenanceCameraMicGainItem;
    //::MainMenu::Maintenance::Lens
    self.lbMaintenanceLens.TagObject := Self.cMaintenanceLensItem;
      //::MainMenu::Maintenance::Lens::Auto Iris
      self.lbMaintenanceLensAutoIris.TagObject := Self.cMaintenanceLensAutoIrisItem;
      //::MainMenu::Maintenance::Lens::Flare
      self.lbMaintenanceLensFlare.TagObject := Self.cMaintenanceLensFlareItem;
      //::MainMenu::Maintenance::Lens::V Mod Saw
      self.lbMaintenanceLensVModSaw.TagObject := Self.cMaintenanceLensVModSawItem;
      //::MainMenu::Maintenance::Lens::ALAC
      self.lbMaintenanceLensAlac.TagObject := Self.cMaintenanceLensAlacItem;
    //::MainMenu::Maintenance::CCU
    self.lbMaintenanceCcu.TagObject := Self.cMaintenanceCcuItem;
      //::MainMenu::Maintenance::CCU::Phase
      self.lbMaintenanceCcuPhase.TagObject := Self.cMaintenanceCcuPhaseItem;
      //::MainMenu::Maintenance::CCU::Monitor Output
      self.lbMaintenanceCcuMonOut.TagObject := Self.cMaintenanceCcuMonitorOutItem;
    //::MainMenu::Maintenance::SD Adj
    self.lbMaintenanceSDAdj.TagObject := Self.cMaintenanceSDAdjItem;
      //::MainMenu::Maintenance::SD Adj:: SD Detail
      self.lbMaintenanceSDAdjSDDetail.TagObject := Self.cMaintenanceSDAdjSDDetailItem;
      //::MainMenu::Maintenance::SD Adj::SD Gamma
      self.lbMaintenanceSDAdjSDGamma.TagObject := Self.cMaintenanceSDAdjSDGammaItem;
      //::MainMenu::Maintenance::SD Adj::SD Matrix
      self.lbMaintenanceSDAdjSDMatrix.TagObject := Self.cMaintenanceSDAdjSDMatrixItem;
      //::MainMenu::Maintenance::SD Adj::Interpolation
      self.lbMaintenanceSDAdjInterpolation.TagObject :=  Self.cMaintenanceSDAdjInterpolationItem;
      //::MainMenu::Maintenance::SD Adj::Cross Color
      self.lbMaintenanceSDAdjCrossColor.TagObject := Self.cMaintenanceSDAdjCrossColorItem;
      //::MainMenu::Maintenance::SD Adj::Aspect
      self.lbMaintenanceSDAdjAspect.TagObject := Self.cMaintenanceSDAdjAspectItem;
    //::MainMenu::Maintenance::RPN
    self.lbMaintenanceRpn.TagObject := Self.cMaintenanceRpnItem;



  //::MainMenu::Multi
  self.lbMulti.TagObject := Self.cMultiItem;

  //::MainMenu::File
  self.lbFile.TagObject := Self.cFileItem;

  //::MainMenu::Paint
  self.lbPaint.TagObject := Self.cPaintItem;

end;

function TForm1.FindItemParent(Obj: TFmxObject; ParentClass: TClass): TFmxObject;
begin
  Result := nil;
  if Assigned(Obj.Parent) then
    if Obj.Parent.ClassType = ParentClass then
      Result := Obj.Parent
    else
      Result := FindItemParent(Obj.Parent, ParentClass);
end;

end.
