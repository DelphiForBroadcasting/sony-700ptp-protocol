(*
 *
 *  CNS: Sony Camera Network System - A network system consisting of Sony Cameras (Sony CCUs)
 *    and Sony Control Panels, connected to each other via TCP/IP.
 *  SPP: Sony Proprietary Protocol - A communication protocol used by CNS
 *
 *  CNS MODE LEGACY/BRIDGE/MCS - Sets camera network system connection mode
 *    LEGACY: System connection using conventional 700 protocol cable
 *    BRIDGE: Mode for one-to-one connections using the network
 *    MCS: Mode for multi-camera systems using the network
 *
 *    by Freehand (mail@freehand.com.ua)
 *)

unit FH.SONY.SPP.CNS.BRIDGE;


interface

uses
  System.SysUtils,
  System.Types,
  System.Classes,
  IdAssignedNumbers,
  IdGlobal,
  IdExceptionCore,
  IdException,
  IdStack,
  IdContext,
  IdIOHandler,
  IdTCPClient,
  IdThread,
  IdSync,
  System.SyncObjs,
  FH.SONY.SPP.PACKET,
  FH.SONY.SPP.COMMANDHANDLERS,
  FH.SONY.SPP.COMMANDADDR,
  FH.SONY.SPP.UTILS,
  FH.SONY.SPP.CNS;

type
  TSPpCNSBridge = class
  private
    FSPpCNS                 : TSPpCNS;

    FWriteLock              : TCriticalSection;
    FReadLock               : TCriticalSection;
    FMonitor                : TObject;


    FOnDebug                : TDebugEvent;
    FOnMicrophoneGain       : TMicrophoneGainEvent;

    FCommandHandlers        : TSPpCommandHandlers;
    FCommandsHelper         : TSPpCommandsHelper;

    procedure DoMicrophoneGain(Sender: TObject; ABasicPacket: TSPpBasicPacket; const Ch01: byte; const Ch02: byte);
    procedure DoDebug(AMsg: string);

    procedure SetCommandHandlers(AValue: TSPpCommandHandlers);

    (* COMMANDS *)
    procedure UNKNOWN_10001018200000;
    procedure FirstInit;

    (* TRIGERS *)
    procedure AssignSPpCommands;
    procedure DoTrigger2104(ASender: TSPpCommand);
    procedure DoTrigger2103(ASender: TSPpCommand);
    procedure DoTrigger2101(ASender: TSPpCommand);
    procedure DoTrigger4100(ASender: TSPpCommand);
    procedure DoTrigger2186(ASender: TSPpCommand);
    procedure DoTrigger2183(ASender: TSPpCommand);
    procedure DoTrigger4110(ASender: TSPpCommand);
    procedure DoTrigger4111(ASender: TSPpCommand);
    procedure DoTrigger4132(ASender: TSPpCommand);
    procedure DoTrigger411A(ASender: TSPpCommand);
    procedure DoTrigger410A(ASender: TSPpCommand);
    procedure DoTrigger4183(ASender: TSPpCommand);
    procedure DoTrigger212C(ASender: TSPpCommand);
    procedure DoTrigger0C05(ASender: TSPpCommand);
    procedure DoTrigger2184(ASender: TSPpCommand);
    procedure DoTrigger2108(ASender: TSPpCommand);
    procedure DoTrigger2109(ASender: TSPpCommand);
    procedure DoTrigger2360(ASender: TSPpCommand);
    procedure DoTrigger2350(ASender: TSPpCommand);
    procedure DoTrigger234D(ASender: TSPpCommand);
    procedure DoTrigger2340(ASender: TSPpCommand);
    procedure DoTrigger210A(ASender: TSPpCommand);
    procedure DoTrigger21A0(ASender: TSPpCommand);
    procedure DoTrigger2380(ASender: TSPpCommand);
    procedure DoTrigger2381(ASender: TSPpCommand);
    procedure DoTrigger2382(ASender: TSPpCommand);
    procedure DoTrigger23A9(ASender: TSPpCommand);
    procedure DoTrigger23AA(ASender: TSPpCommand);
    procedure DoTrigger23AB(ASender: TSPpCommand);
    procedure DoTrigger23AC(ASender: TSPpCommand);
    procedure DoTrigger2386(ASender: TSPpCommand);
    procedure DoTrigger2387(ASender: TSPpCommand);
    procedure DoTrigger2388(ASender: TSPpCommand);
    procedure DoTrigger2389(ASender: TSPpCommand);
    procedure DoTrigger238A(ASender: TSPpCommand);
    procedure DoTrigger238B(ASender: TSPpCommand);
    procedure DoTrigger238C(ASender: TSPpCommand);
    procedure DoTrigger238D(ASender: TSPpCommand);
    procedure DoTrigger238E(ASender: TSPpCommand);
    procedure DoTrigger238F(ASender: TSPpCommand);
    procedure DoTrigger2390(ASender: TSPpCommand);
    procedure DoTrigger2391(ASender: TSPpCommand);
    procedure DoTrigger2392(ASender: TSPpCommand);
    procedure DoTrigger2393(ASender: TSPpCommand);
    procedure DoTrigger2394(ASender: TSPpCommand);
    procedure DoTrigger2395(ASender: TSPpCommand);
    procedure DoTrigger2396(ASender: TSPpCommand);
    procedure DoTrigger2397(ASender: TSPpCommand);
    procedure DoTrigger2398(ASender: TSPpCommand);
    procedure DoTrigger2399(ASender: TSPpCommand);
    procedure DoTrigger239A(ASender: TSPpCommand);
    procedure DoTrigger23B3(ASender: TSPpCommand);
    procedure DoTrigger23B4(ASender: TSPpCommand);
    procedure DoTrigger23B5(ASender: TSPpCommand);
    procedure DoTrigger2301(ASender: TSPpCommand);
    procedure DoTrigger2302(ASender: TSPpCommand);
    procedure DoTrigger2303(ASender: TSPpCommand);
    procedure DoTrigger4113(ASender: TSPpCommand);
    procedure DoTrigger4115(ASender: TSPpCommand);
    procedure DoTrigger2308(ASender: TSPpCommand);
    procedure DoTrigger2309(ASender: TSPpCommand);
    procedure DoTrigger230A(ASender: TSPpCommand);
    procedure DoTrigger230B(ASender: TSPpCommand);
    procedure DoTrigger2181(ASender: TSPpCommand);
    procedure DoTrigger2190(ASender: TSPpCommand);
    procedure DoTrigger2182(ASender: TSPpCommand);
    procedure DoTrigger21A3(ASender: TSPpCommand);
    procedure DoTrigger2307(ASender: TSPpCommand);
    procedure DoTrigger2306(ASender: TSPpCommand);
    procedure DoTrigger2305(ASender: TSPpCommand);
    procedure DoTrigger2304(ASender: TSPpCommand);
    procedure DoTrigger4319(ASender: TSPpCommand);
    procedure DoTrigger431A(ASender: TSPpCommand);
    procedure DoTrigger431B(ASender: TSPpCommand);
    procedure DoTrigger4371(ASender: TSPpCommand);
    procedure DoTrigger4372(ASender: TSPpCommand);
    procedure DoTrigger41E6(ASender: TSPpCommand);

    (* SPpCNS EVENTS *)
    procedure SPpCNSOnResponsePacketAvailable(const ASPpBasicPacket: TSPpBasicPacket);
    procedure SPpCNSOnRequestPacketAvailable(const ASPpBasicPacket: TSPpBasicPacket);
    procedure SPpCnsOnDebug(ASender: TObject; AMsg: string);
    procedure SPpCnsOnConnClosedGracefully(Sender: TObject);

    (* PROPERTY *)
    function GetMode: TSPpCNSMode;
    procedure SetMode(AValue: TSPpCNSMode);
    function GetSerialNumber: cardinal;
    procedure SetSerialNumber(AValue: cardinal);
    function GetRcpId: Byte;
    procedure SetRcpId(AValue: Byte);
    function GetHost: string;
    procedure SetHost(AValue: string);
    function GetPort: Integer;
    procedure SetPort(AValue: Integer);

  public
    constructor Create(OnDebug: TDebugEvent = nil); overload;
    destructor Destroy; override;

    property CommandHandlers  : TSPpCommandHandlers read FCommandHandlers write  SetCommandHandlers;
    property CommandsHelper   : TSPpCommandsHelper read FCommandsHelper;

    property Mode         : TSPpCNSMode read GetMode          write SetMode;
    property SerialNumber : cardinal    read GetSerialNumber  write SetSerialNumber;
    property RcpId        : Byte        read GetRcpId         write SetRcpId;
    property Master       : string      read GetHost        write SetHost;
    property Target       : string      read GetHost        write SetHost;
    property Host         : string      read GetHost        write SetHost;
    property Port         : Integer     read GetPort        write SetPort;

    procedure Connect;
    procedure Disconnect;


    procedure GetMicrophoneGain(AOnMicrophoneGain  : TMicrophoneGainEvent;
                                AOnExcaption       : TExceptionProcedure = nil);

    procedure SetMicrophoneGain(AChAddr: Byte; AIncrement: boolean;
                                AOnMicrophoneGain  : TMicrophoneGainEvent;
                                AOnExcaption       : TExceptionProcedure = nil);

    function SetBars: boolean;
    function GetBars: boolean;


    property OnMicrophoneGain : TMicrophoneGainEvent read FOnMicrophoneGain write FOnMicrophoneGain;



  end;


implementation

constructor TSPpCNSBridge.Create(OnDebug: TDebugEvent = nil);
begin
  FOnDebug := OnDebug;

  FWriteLock := TCriticalSection.Create;
  FReadLock := TCriticalSection.Create;
  FMonitor := TObject.Create;

  FCommandsHelper := TSPpCommandsHelper.Create;
  FCommandHandlers := TSPpCommandHandlers.Create();

  FSPpCNS := TSPpCNS.Create(SPpCnsOnDebug, FWriteLock, FReadLock, FMonitor);
  //inherited Create(DoDebug, FWriteLock, FReadLock, FMonitor);
  FSPpCNS.OnRequestPacketAvailable := SPpCNSOnRequestPacketAvailable;
  FSPpCNS.OnResponsePacketAvailable := SPpCNSOnResponsePacketAvailable;
  FSPpCNS.OnConnClosedGracefully := SPpCnsOnConnClosedGracefully;






  AssignSPpCommands;

  FSPpCNS.OnHandShake := procedure(Sender: TObject; ABasicPacket: TSPpBasicPacket; const ASerialNumber: cardinal)
                      begin
                        if ASerialNumber > 0 then
                        begin
                          DoDebug(Format('HandShake OK, CCU device SN: %d', [ASerialNumber]));
                          FirstInit;
                        end;
                      end;


  (*  *)
  FSPpCNS.SerialNumber := 0;
  FSPpCNS.Mode := TSPpCNSMode.m_BRIDGE;
  FSPpCNS.RCPId := 0;

end;

destructor TSPpCNSBridge.Destroy;
begin
  FSPpCNS.Disconnect;
  FSPpCNS.Destroy;

  FreeAndNil(FCommandsHelper);
  FreeAndNil(FCommandHandlers);

  FreeAndNil(FWriteLock);
  FreeAndNil(FReadLock);
  FreeAndNil(FMonitor);

  inherited Destroy;
end;

procedure TSPpCNSBridge.SPpCNSOnResponsePacketAvailable(const ASPpBasicPacket: TSPpBasicPacket);
begin
  DoDebug(format('CCU_Response - %s', [ToHex(TSPpUTILS.CopyBytes(ASPpBasicPacket.ToBytes))]));
end;

procedure TSPpCNSBridge.SPpCNSOnRequestPacketAvailable(const ASPpBasicPacket: TSPpBasicPacket);
var
  i               : integer;
  LRequestPacket  : TSPpRequestPacket;
  LDataParser     : TSPpDataParser;
  LDataBlock      : TBytes;
begin
  LRequestPacket := TSPpRequestPacket(ASPpBasicPacket);

  case LRequestPacket.CommandCode of
    $50:
      begin
        LRequestPacket.GetBlock(LDataBlock);
        LDataParser := TSPpDataParser.Create(LDataBlock);
        try
          for I := 0 to LDataParser.Pairs.Count-1 do
          begin
            if not CommandHandlers.HandleCommand(ASPpBasicPacket, LDataParser.Pairs.Items[I].Key) then
            begin
              DoDebug(format('Unknown command - %s', [ToHex(ASPpBasicPacket.ToIdBytes)]));
            end;
          end;
          //LDataParser.Response.ToBytes
          FSPpCNS.BasicResponse;
        finally
          LDataParser.Destroy;
        end;
      end;
    $10:
      begin
        DoDebug(format('CCU$10 - %s', [ToHex(TSPpUTILS.CopyBytes(ASPpBasicPacket.ToBytes))]));
        if ((LRequestPacket.CommandCode = $10) and (pCardinal(@LRequestPacket.RawData[5])^ = 8216) and (LRequestPacket.RawData[4] = $10))  then
        begin
          UNKNOWN_10001018200000;
        end else
          FSPpCNS.BasicResponse;
      end;
    else
    begin
      DoDebug(format('CCU$FF - %s', [ToHex(ASPpBasicPacket.ToIdBytes)]));
      FSPpCNS.BasicResponse;
    end;
  end;
end;

procedure TSPpCNSBridge.SetCommandHandlers(AValue: TSPpCommandHandlers);
begin
  FCommandHandlers.Assign(AValue);
end;


procedure TSPpCNSBridge.DoDebug(AMsg: string);
begin

    TThread.Synchronize(nil,
      procedure
      begin
        if assigned(fOnDebug) then
        begin
          fOnDebug(self, AMsg);
        end;
      end
    );
end;


procedure TSPpCNSBridge.SPpCnsOnDebug(ASender: TObject; AMsg: string);
begin
  DoDebug(AMsg);
end;

procedure TSPpCNSBridge.SPpCnsOnConnClosedGracefully(Sender: TObject);
begin
  DoDebug('ConnClosedGracefully');
end;

procedure TSPpCNSBridge.AssignSPpCommands;
var
  LCommandHandler: TSPpCommandHandler;
begin

  // ::MENU::MAINTENANCE::CAMERA::MICROPHONEGAIN::CH01
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CAMERA::MICROPHONEGAIN::CH01';
  LCommandHandler.Commands.Add([$21, $08]);
  LCommandHandler.OnCommand := DoTrigger2108;

  // ::MENU::MAINTENANCE::CAMERA::MICROPHONEGAIN::CH01
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CAMERA::MICROPHONEGAIN::CH02';
  LCommandHandler.Commands.Add([$21, $09]);
  LCommandHandler.OnCommand := DoTrigger2109;

  // ::MENU::CONFIG::CCU::MENUCONTROL::MENUDISP
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::CONFIG::CCU::MENUCONTROL::MENUDISP';
  LCommandHandler.Commands.Add([$41, $32]);
  LCommandHandler.OnCommand := DoTrigger4132;

  // ::BUTTON::MASTER_GAIN
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::BUTTON::MASTER_GAIN';
  LCommandHandler.Commands.Add([$21, $01]);
  LCommandHandler.OnCommand := DoTrigger2101;

  // ::BUTTON::ND_FILTER
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::BUTTON::ND_FILTER';
  LCommandHandler.Commands.Add([$21, $03]);
  LCommandHandler.OnCommand := DoTrigger2103;

  // ::BUTTON::CC_FILTER
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::BUTTON::CC_FILTER';
  LCommandHandler.Commands.Add([$21, $04]);
  LCommandHandler.OnCommand := DoTrigger2104;

  // ::BUTTON::BARS
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::BUTTON::BARS';
  LCommandHandler.Commands.Add([$41, $10]);
  LCommandHandler.OnCommand := DoTrigger4110;

  // ::BUTTON::TEST
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::BUTTON::TEST';
  LCommandHandler.Commands.Add([$21, $86]);
  LCommandHandler.OnCommand := DoTrigger2186;

  // ::BUTTON::TEST
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::BUTTON::CLOSE';
  LCommandHandler.Commands.Add([$21, $83]);
  LCommandHandler.OnCommand := DoTrigger2183;

  // ::BUTTON::CAMPW
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::BUTTON::CAMPW';
  LCommandHandler.Commands.Add([$41, $11]);
  LCommandHandler.OnCommand := DoTrigger4111;

  // ::BUTTON::CHARACTER::NEXT_PAGE
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::BUTTON::CHARACTER::NEXT_PAGE';
  LCommandHandler.Commands.Add([$41, $00]);
  LCommandHandler.OnCommand := DoTrigger4100;

  // ::MENU::CONFIG::CCU::MODE::BARSCHARACTER::ON
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::CONFIG::CCU::MODE::BARSCHARACTER::ON';
  LCommandHandler.Commands.Add([$41, $1a]);
  LCommandHandler.OnCommand := DoTrigger411A;

  // ::MENU::CONFIG::CCU::MODE::GENLOCK_MODE
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::CONFIG::CCU::MODE::GENLOCK_MODE';
  LCommandHandler.Commands.Add([$41, $0a]);
  LCommandHandler.OnCommand := DoTrigger410A;

  // ::MENU::CONFIG::CCU::CHANNELID::ON
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::CONFIG::CCU::CHANNELID::ON';
  LCommandHandler.Commands.Add([$41, $83]);
  LCommandHandler.OnCommand := DoTrigger4183;

  // ::MENU::MAINTENANCE::CAMERA::ATWSETTINGS::ATW
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CAMERA::ATWSETTINGS::ATW';
  LCommandHandler.Commands.Add([$21, $84]);
  LCommandHandler.OnCommand := DoTrigger2184;

  // ::MENU::MAINTENANCE::CAMERA::ATWSETTINGS::SPEED
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CAMERA::ATWSETTINGS::SPEED';
  LCommandHandler.Commands.Add([$21, $2C]);
  LCommandHandler.OnCommand := DoTrigger212C;

  // ::MENU::MAINTENANCE::LENS::AUTOIRIS_SETTINGS::AUTOIRIS
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::LENS::AUTOIRIS_SETTINGS::AUTOIRIS';
  LCommandHandler.Commands.Add([$23, $60]);
  LCommandHandler.OnCommand := DoTrigger2360;

  // ::MENU::MAINTENANCE::LENS::AUTOIRIS_SETTINGS::LEVEL
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::LENS::AUTOIRIS_SETTINGS::LEVEL';
  LCommandHandler.Commands.Add([$23, $50]);
  LCommandHandler.OnCommand := DoTrigger2350;

  // ::MENU::MAINTENANCE::LENS::AUTOIRIS_SETTINGS::APL_RATIO
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::LENS::AUTOIRIS_SETTINGS::APL_RATIO';
  LCommandHandler.Commands.Add([$23, $40]);
  LCommandHandler.OnCommand := DoTrigger2340;

  // ::MENU::MAINTENANCE::LENS::AUTOIRIS_SETTINGS::IRIS_GAIN
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::LENS::AUTOIRIS_SETTINGS::IRIS_GAIN';
  LCommandHandler.Commands.Add([$23, $4d]);
  LCommandHandler.OnCommand := DoTrigger234D;

  // ::MENU::MAINTENANCE::LENS::AUTOIRIS_SETTINGS::PATTERN
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::LENS::AUTOIRIS_SETTINGS::PATTERN';
  LCommandHandler.Commands.Add([$21, $0a]);
  LCommandHandler.OnCommand := DoTrigger210A;

  // ::MENU::MAINTENANCE::CAMERA::OHB_MATRIX::ON
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CAMERA::OHB_MATRIX::ON';
  LCommandHandler.Commands.Add([$21, $A0]);
  LCommandHandler.OnCommand := DoTrigger21A0;

  // ::MENU::MAINTENANCE::CAMERA::BLACK_SET::BLACK::R
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CAMERA::BLACK_SET::BLACK::R';
  LCommandHandler.Commands.Add([$23, $AA]);
  LCommandHandler.OnCommand := DoTrigger23AA;

  // ::MENU::MAINTENANCE::CAMERA::BLACK_SET::BLACK::G
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CAMERA::BLACK_SET::BLACK::G';
  LCommandHandler.Commands.Add([$23, $AB]);
  LCommandHandler.OnCommand := DoTrigger23AB;

  // ::MENU::MAINTENANCE::CAMERA::BLACK_SET::BLACK::B
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CAMERA::BLACK_SET::BLACK::B';
  LCommandHandler.Commands.Add([$23, $AC]);
  LCommandHandler.OnCommand := DoTrigger23AC;

  // ::MENU::MAINTENANCE::CAMERA::BLACK_SET::BLACK::MASTER
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CAMERA::BLACK_SET::BLACK::MASTER';
  LCommandHandler.Commands.Add([$23, $A9]);
  LCommandHandler.OnCommand := DoTrigger23A9;

  // ::MENU::MAINTENANCE::CAMERA::BLACK_SET::BLACK_SET::R
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CAMERA::BLACK_SET::BLACK_SET::R';
  LCommandHandler.Commands.Add([$23, $80]);
  LCommandHandler.OnCommand := DoTrigger2380;

  // ::MENU::MAINTENANCE::CAMERA::BLACK_SET::BLACK_SET::G
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CAMERA::BLACK_SET::BLACK_SET::G';
  LCommandHandler.Commands.Add([$23, $81]);
  LCommandHandler.OnCommand := DoTrigger2381;

  // ::MENU::MAINTENANCE::CAMERA::BLACK_SET::BLACK_SET::B
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CAMERA::BLACK_SET::BLACK_SET::B';
  LCommandHandler.Commands.Add([$23, $82]);
  LCommandHandler.OnCommand := DoTrigger2382;

  // ::ROMVERSION::CAMERA
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::ROMVERSION::CAMERA';
  LCommandHandler.Commands.Add([$0c, $05]);
  LCommandHandler.OnCommand := DoTrigger0C05;

  // ::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::R::H_SAW
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::R::H_SAW';
  LCommandHandler.Commands.Add([$23, $86]);
  LCommandHandler.OnCommand := DoTrigger2386;

  // ::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::R::H_PARA
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::R::H_PARA';
  LCommandHandler.Commands.Add([$23, $89]);
  LCommandHandler.OnCommand := DoTrigger2389;

  // ::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::R::V_SAW
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::R::V_SAW';
  LCommandHandler.Commands.Add([$23, $8C]);
  LCommandHandler.OnCommand := DoTrigger238C;

  // ::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::R::V_PARA
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::R::V_PARA';
  LCommandHandler.Commands.Add([$23, $8F]);
  LCommandHandler.OnCommand := DoTrigger238F;

  // ::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::G::H_SAW
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::G::H_SAW';
  LCommandHandler.Commands.Add([$23, $87]);
  LCommandHandler.OnCommand := DoTrigger2387;

  // ::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::G::H_PARA
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::G::H_PARA';
  LCommandHandler.Commands.Add([$23, $8A]);
  LCommandHandler.OnCommand := DoTrigger238A;

  // ::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::G::V_SAW
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::G::V_SAW';
  LCommandHandler.Commands.Add([$23, $8D]);
  LCommandHandler.OnCommand := DoTrigger238D;

  // ::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::G::V_PARA
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::G::V_PARA';
  LCommandHandler.Commands.Add([$23, $90]);
  LCommandHandler.OnCommand := DoTrigger2390;

  // ::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::B::H_SAW
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::B::H_SAW';
  LCommandHandler.Commands.Add([$23, $88]);
  LCommandHandler.OnCommand := DoTrigger2388;

  // ::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::B::H_PARA
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::B::H_PARA';
  LCommandHandler.Commands.Add([$23, $8B]);
  LCommandHandler.OnCommand := DoTrigger238B;

  // ::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::B::V_SAW
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::B::V_SAW';
  LCommandHandler.Commands.Add([$23, $8E]);
  LCommandHandler.OnCommand := DoTrigger238E;

  // ::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::B::V_PARA
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::B::V_PARA';
  LCommandHandler.Commands.Add([$23, $91]);
  LCommandHandler.OnCommand := DoTrigger2391;

 // ::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::R::H_SAW
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::R::H_SAW';
  LCommandHandler.Commands.Add([$23, $92]);
  LCommandHandler.OnCommand := DoTrigger2392;

  // ::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::R::H_PARA
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::R::H_PARA';
  LCommandHandler.Commands.Add([$23, $95]);
  LCommandHandler.OnCommand := DoTrigger2395;

  // ::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::R::V_SAW
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::R::V_SAW';
  LCommandHandler.Commands.Add([$23, $B3]);
  LCommandHandler.OnCommand := DoTrigger23B3;

  // ::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::R::V_PARA
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::R::V_PARA';
  LCommandHandler.Commands.Add([$23, $98]);
  LCommandHandler.OnCommand := DoTrigger2398;

 // ::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::G::H_SAW
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::G::H_SAW';
  LCommandHandler.Commands.Add([$23, $93]);
  LCommandHandler.OnCommand := DoTrigger2393;

  // ::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::G::H_PARA
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::G::H_PARA';
  LCommandHandler.Commands.Add([$23, $96]);
  LCommandHandler.OnCommand := DoTrigger2396;

  // ::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::G::V_SAW
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::G::V_SAW';
  LCommandHandler.Commands.Add([$23, $B4]);
  LCommandHandler.OnCommand := DoTrigger23B4;

  // ::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::G::V_PARA
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::G::V_PARA';
  LCommandHandler.Commands.Add([$23, $99]);
  LCommandHandler.OnCommand := DoTrigger2399;

 // ::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::B::H_SAW
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::B::H_SAW';
  LCommandHandler.Commands.Add([$23, $94]);
  LCommandHandler.OnCommand := DoTrigger2394;

  // ::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::B::H_PARA
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::B::H_PARA';
  LCommandHandler.Commands.Add([$23, $97]);
  LCommandHandler.OnCommand := DoTrigger2397;

  // ::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::B::V_SAW
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::B::V_SAW';
  LCommandHandler.Commands.Add([$23, $B5]);
  LCommandHandler.OnCommand := DoTrigger23B5;

  // ::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::B::V_PARA
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::B::V_PARA';
  LCommandHandler.Commands.Add([$23, $9A]);
  LCommandHandler.OnCommand := DoTrigger239A;

 // ::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::WHITE::R
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::WHITE::R';
  LCommandHandler.Commands.Add([$23, $01]);
  LCommandHandler.OnCommand := DoTrigger2301;

  // ::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::WHITE::G
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::WHITE::G';
  LCommandHandler.Commands.Add([$23, $02]);
  LCommandHandler.OnCommand := DoTrigger2302;

  // ::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::WHITE::B
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::WHITE::B';
  LCommandHandler.Commands.Add([$23, $03]);
  LCommandHandler.OnCommand := DoTrigger2303;

  // ::MENU::FUNCTION::PIXWF::PIX
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::FUNCTION::PIXWF::PIX';
  LCommandHandler.Commands.Add([$41, $15]);
  LCommandHandler.Commands.Add([$41, $16]);
  LCommandHandler.OnCommand := DoTrigger4115;

  // ::MENU::FUNCTION::PIXWF::WF
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::FUNCTION::PIXWF::WF';
  LCommandHandler.Commands.Add([$41, $13]);
  LCommandHandler.Commands.Add([$41, $14]);
  LCommandHandler.OnCommand := DoTrigger4113;

  // ::MENU::MAINTENANCE::LENS::ALAC::ON
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::LENS::ALAC::ON';
  LCommandHandler.Commands.Add([$21, $90]);
  LCommandHandler.OnCommand := DoTrigger2190;

  // ::MENU::MAINTENANCE::LENS::VMODSAW::OFF
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::LENS::VMODSAW::OFF';
  LCommandHandler.Commands.Add([$21, $82]);
  LCommandHandler.OnCommand := DoTrigger2182;

  // ::MENU::MAINTENANCE::LENS::VMODSAW::D_SHADE_COMP
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::LENS::VMODSAW::D_SHADE_COMP';
  LCommandHandler.Commands.Add([$21, $A3]);
  LCommandHandler.OnCommand := DoTrigger21A3;

  // ::MENU::MAINTENANCE::LENS::VMODSAW::R
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::LENS::VMODSAW::R';
  LCommandHandler.Commands.Add([$23, $05]);
  LCommandHandler.OnCommand := DoTrigger2305;

  // ::MENU::MAINTENANCE::LENS::VMODSAW::G
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::LENS::VMODSAW::G';
  LCommandHandler.Commands.Add([$23, $06]);
  LCommandHandler.OnCommand := DoTrigger2306;

  // ::MENU::MAINTENANCE::LENS::VMODSAW::B
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::LENS::VMODSAW::B';
  LCommandHandler.Commands.Add([$23, $07]);
  LCommandHandler.OnCommand := DoTrigger2307;

  // ::MENU::MAINTENANCE::LENS::VMODSAW::MASTER
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::LENS::VMODSAW::MASTER';
  LCommandHandler.Commands.Add([$23, $04]);
  LCommandHandler.OnCommand := DoTrigger2304;

  // ::MENU::MAINTENANCE::LENS::FLARE::OFF
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::LENS::FLARE::OFF';
  LCommandHandler.Commands.Add([$21, $81]);
  LCommandHandler.OnCommand := DoTrigger2181;

  // ::MENU::MAINTENANCE::LENS::FLARE::R
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::LENS::FLARE::R';
  LCommandHandler.Commands.Add([$23, $09]);
  LCommandHandler.OnCommand := DoTrigger2309;

  // ::MENU::MAINTENANCE::LENS::FLARE::G
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::LENS::FLARE::G';
  LCommandHandler.Commands.Add([$23, $0A]);
  LCommandHandler.OnCommand := DoTrigger230A;

  // ::MENU::MAINTENANCE::LENS::FLARE::B
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::LENS::FLARE::B';
  LCommandHandler.Commands.Add([$23, $0B]);
  LCommandHandler.OnCommand := DoTrigger230B;

  // ::MENU::MAINTENANCE::LENS::FLARE::MASTER
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::LENS::FLARE::MASTER';
  LCommandHandler.Commands.Add([$23, $08]);
  LCommandHandler.OnCommand := DoTrigger2308;











  // ::MENU::MAINTENANCE::CCU::MONITOR_OUTPUT::43MARKER/43MOD
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CCU::MONITOR_OUTPUT::43MARKER/43MOD';
  LCommandHandler.Commands.Add([$41, $E6]);
  LCommandHandler.OnCommand := DoTrigger41E6;

  // ::MENU::MAINTENANCE::CCU::MONITOR_OUTPUT::GATEMK
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CCU::MONITOR_OUTPUT::GATEMK';
  LCommandHandler.Commands.Add([$43, $72]);
  LCommandHandler.OnCommand := DoTrigger4372;

  // ::MENU::MAINTENANCE::CCU::MONITOR_OUTPUT::MODLVL
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CCU::MONITOR_OUTPUT::MODLVL';
  LCommandHandler.Commands.Add([$43, $71]);
  LCommandHandler.OnCommand := DoTrigger4371;

  // ::MENU::MAINTENANCE::CCU::PHASE::H
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CCU::PHASE::H';
  LCommandHandler.Commands.Add([$43, $1A]);
  LCommandHandler.OnCommand := DoTrigger431A;

  // ::MENU::MAINTENANCE::CCU::PHASE::H_STEP
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CCU::PHASE::H_STEP';
  LCommandHandler.Commands.Add([$43, $1B]);
  LCommandHandler.OnCommand := DoTrigger431B;

  // ::MENU::MAINTENANCE::CCU::PHASE::H_COARSE
  LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CCU::PHASE::H_COARSE';
  LCommandHandler.Commands.Add([$43, $19]);
  LCommandHandler.OnCommand := DoTrigger4319;



end;


procedure TSPpCNSBridge.DoTrigger2108(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger2109(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger4111(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger4110(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger2101(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger2103(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger2104(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger2186(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger2183(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger4100(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger4132(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger411A(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger410A(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger4183(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger2184(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger212C(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger2360(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger2350(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger2340(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger234D(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger210A(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger21A0(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger0C05(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger2382(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger2381(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger2380(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger23A9(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger23AA(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger23AB(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger23AC(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger2386(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger2389(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger238C(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger238F(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger2387(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger238A(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger238D(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger2390(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger2388(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger238B(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger238E(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger2391(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger2392(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger2395(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger23B3(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger2398(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger2393(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger2396(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger23B4(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger2399(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger2394(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger2397(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger23B5(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger239A(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger2301(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger2302(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger2303(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger4115(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger4113(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger2308(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger2181(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger2182(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger2309(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger230A(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger230B(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger2190(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger21A3(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger2305(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger2306(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger2307(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger2304(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCNSBridge.DoTrigger4319(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;


procedure TSPpCNSBridge.DoTrigger431A(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;


procedure TSPpCNSBridge.DoTrigger431B(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;


procedure TSPpCNSBridge.DoTrigger4372(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;


procedure TSPpCNSBridge.DoTrigger4371(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;


procedure TSPpCNSBridge.DoTrigger41E6(ASender: TSPpCommand);
begin
  DoDebug(format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;



function TSPpCNSBridge.GetMode(): TSPpCNSMode;
begin
  result := FSPpCNS.Mode;
end;

procedure TSPpCNSBridge.SetMode(AValue: TSPpCNSMode);
begin
  FSPpCNS.Mode := AValue;
end;

function TSPpCNSBridge.GetSerialNumber: cardinal;
begin
  result := FSPpCNS.SerialNumber;
end;

procedure TSPpCNSBridge.SetSerialNumber(AValue: cardinal);
begin
  FSPpCNS.SerialNumber := AValue;
end;

function TSPpCNSBridge.GetRcpId: Byte;
begin
  result := FSPpCNS.RcpId;
end;

procedure TSPpCNSBridge.SetRcpId(AValue: Byte);
begin
  FSPpCNS.RcpId := AValue;
end;

function TSPpCNSBridge.GetHost: string;
begin
  result := FSPpCNS.Host;
end;

procedure TSPpCNSBridge.SetHost(AValue: string);
begin
  FSPpCNS.Host := AValue;
end;

function TSPpCNSBridge.GetPort: integer;
begin
  result := FSPpCNS.Port;
end;

procedure TSPpCNSBridge.SetPort(AValue: Integer);
begin
  FSPpCNS.Port := AValue;
end;



procedure TSPpCNSBridge.Connect;
begin
  FSPpCNS.Connect;
end;

procedure TSPpCNSBridge.Disconnect;
begin
  FSPpCNS.Disconnect;
end;

procedure TSPpCNSBridge.DoMicrophoneGain(Sender: TObject; ABasicPacket: TSPpBasicPacket; const Ch01: byte; const Ch02: byte);
begin
  if assigned(FOnMicrophoneGain) then
    FOnMicrophoneGain(Sender, ABasicPacket, Ch01, Ch02);
end;


procedure TSPpCNSBridge.GetMicrophoneGain(AOnMicrophoneGain  : TMicrophoneGainEvent;
                                          AOnExcaption       : TExceptionProcedure = nil);
var
  ARequestPacket  : TSPpRequestPacket;
  FResponsePacket : TSPpResponsePacket;
  FCh01, FCh02    : byte;
  FDataBlock      : TBytes;
begin
  FSPpCNS.HeartBeat.Active := false;

  try
    TMonitor.Enter(FMonitor);
    try
      ARequestPacket := TSPpRequestPacket.Create();
      try
        ARequestPacket.Size := $13;
        ARequestPacket.ID := FSPpCNS.RequestID;
        ARequestPacket.CommandCode := $50;

        ARequestPacket.SetBlock([$18,$02,$00,$00,$18,$90,$00,$00, $00,$06, $20,$08,$00, $20,$09,$00]);

        FSPpCNS.WriteBuffer(ARequestPacket,
          procedure(Sender: TObject; ABasicPacket: TSPpBasicPacket)
          begin
            FSPpCNS.BasicResponse;

            FResponsePacket := TSPpResponsePacket(ABasicPacket);
            if assigned(FResponsePacket.NextPacket) then
            begin
              FResponsePacket.NextPacket.GetBlock(FDataBlock);
              FCh01 := FDataBlock[12];
              FCh02 := FDataBlock[15];
              if assigned(AOnMicrophoneGain) then
                AOnMicrophoneGain(Sender, ABasicPacket, FCh01, FCh02);
              (* Trigger *)
              DoMicrophoneGain(Sender, ABasicPacket, FCh01, FCh02);
            end;

          end,
          procedure(Sender: TObject; E: Exception)
          begin
            if assigned(AOnExcaption) then
              AOnExcaption(Sender, E);
          end
        );
      finally
        ARequestPacket.Free;
      end;
    finally
      TMonitor.Exit(FMonitor);
    end;
  except
    on E: Exception do
    begin
      if assigned(AOnExcaption) then
        AOnExcaption(self, E);
    end;
  end;

  FSPpCNS.HeartBeat.Active := true;

end;


procedure TSPpCNSBridge.SetMicrophoneGain(AChAddr: Byte; AIncrement: boolean;
                                    AOnMicrophoneGain  : TMicrophoneGainEvent;
                                    AOnExcaption       : TExceptionProcedure = nil);
var
  ARequestPacket  : TSPpRequestPacket;
  FResponsePacket : TSPpResponsePacket;
  FDataBlock      : TBytes;
  FCh01           : integer;
  FCh02           : integer;
begin
  FSPpCNS.HeartBeat.Active := false;

  try
    TMonitor.Enter(FMonitor);
    try
      ARequestPacket := TSPpRequestPacket.Create();
      try
        ARequestPacket.Size := $10;
        ARequestPacket.ID := FSPpCNS.RequestID;
        ARequestPacket.CommandCode := $50;

        if AIncrement then
          ARequestPacket.SetBlock([$18,$02,$00,$00,$18,$90,$00,$00, $00,$03, $21, AChAddr, $40])
        else
          ARequestPacket.SetBlock([$18,$02,$00,$00,$18,$90,$00,$00, $00,$03, $21, AChAddr, $80]);

        FSPpCNS.WriteBuffer(ARequestPacket,
          procedure(Sender: TObject; ABasicPacket: TSPpBasicPacket)
          begin
            FSPpCNS.BasicResponse;
            FResponsePacket := TSPpResponsePacket(ABasicPacket);
            FResponsePacket.NextPacket.GetBlock(FDataBlock);

            FCh01 := FDataBlock[12];

            if assigned(AOnMicrophoneGain) then
              AOnMicrophoneGain(Sender, ABasicPacket, FCh01, 0);

          end,
          procedure(Sender: TObject; E: Exception)
          begin
            if assigned(AOnExcaption) then
              AOnExcaption(Sender, E);
          end
        );

      finally
        ARequestPacket.Free;
      end;
    finally
      TMonitor.Exit(FMonitor);
    end;
  except
    on E: Exception do
    begin
      if assigned(AOnExcaption) then
        AOnExcaption(self, E);
    end;
  end;

  FSPpCNS.HeartBeat.Active := true;
end;

function TSPpCNSBridge.SetBars: boolean;
var
  LRequestPacket  : TSPpRequestPacket;
  FDataBlock      : TBytes;
  LBars           : boolean;
begin
  LBars := false;
  result := LBars;

  FSPpCNS.HeartBeat.Active := false;

  TMonitor.Enter(FMonitor);
  try
    LRequestPacket := TSPpRequestPacket.Create();
    try
      LRequestPacket.Size := $10;
      LRequestPacket.ID := FSPpCNS.RequestID;
      LRequestPacket.CommandCode := $50;
      LRequestPacket.SetBlock([$18,$02,$00,$00,$18,$90,$00,$00, $00,$03, $40,$10,$01]);

      FSPpCNS.WriteBuffer(LRequestPacket,
        procedure(Sender: TObject; ABasicPacket: TSPpBasicPacket)
        var
          i               : integer;
          LResponsePacket : TSPpResponsePacket;
          LDataParser     : TSPpDataParser;
        begin

          LResponsePacket := TSPpResponsePacket(ABasicPacket);
          if assigned(LResponsePacket.NextPacket) then
          begin
            LResponsePacket.NextPacket.GetBlock(FDataBlock);
            LDataParser := TSPpDataParser.Create(FDataBlock);
            try
              for I := 0 to LDataParser.Pairs.Count-1 do
              begin
                CommandHandlers.HandleCommand(ABasicPacket, LDataParser.Pairs.Items[i].Key);
              end;
              if CommandsHelper.ContainsKey('::BUTTON::BARS') then
              begin
                if LDataParser.Pairs.Contains(TSPpPair.Create(CommandsHelper['::BUTTON::BARS'].AddrRes, [$03])) then
                  LBars := true;
                if LDataParser.Pairs.Contains(TSPpPair.Create(CommandsHelper['::BUTTON::BARS'].AddrRes, [$02])) then
                  LBars := false;
              end;

            finally
              LDataParser.Destroy;
            end;
          end;
          FSPpCNS.BasicResponse;
        end,
        procedure(Sender: TObject; E: Exception)
        begin
          DoDebug(Format('Exception BUTTON_BARS: %s', [E.Message]));
        end
      );

      result := LBars
    finally
      LRequestPacket.Free;
    end;
  finally
    TMonitor.Exit(FMonitor);
  end;

  FSPpCNS.HeartBeat.Active := true;
end;

function TSPpCNSBridge.GetBars: boolean;
var
  LRequestPacket  : TSPpRequestPacket;
  FDataBlock      : TBytes;
  LBars           : boolean;
begin
  LBars := false;
  result := LBars;

  FSPpCNS.HeartBeat.Active := false;

  TMonitor.Enter(FMonitor);
  try
    LRequestPacket := TSPpRequestPacket.Create();
    try
      LRequestPacket.Size := $10;
      LRequestPacket.ID := FSPpCNS.RequestID;
      LRequestPacket.CommandCode := $50;
      LRequestPacket.SetBlock([$18,$02,$00,$00,$18,$90,$00,$00, $00,$03, $40,$10,$00]);

      FSPpCNS.WriteBuffer(LRequestPacket,
        procedure(Sender: TObject; ABasicPacket: TSPpBasicPacket)
        var
          i               : integer;
          LDataParser     : TSPpDataParser;
          LResponsePacket : TSPpResponsePacket;
        begin
          LResponsePacket := TSPpResponsePacket(ABasicPacket);
          if assigned(LResponsePacket.NextPacket) and (LResponsePacket.NextPacket.CommandCode = $50) then
          begin
            LResponsePacket.NextPacket.GetBlock(FDataBlock);
            LDataParser := TSPpDataParser.Create(FDataBlock);
            try
              for I := 0 to LDataParser.Pairs.Count-1 do
              begin
                CommandHandlers.HandleCommand(ABasicPacket, LDataParser.Pairs.Items[i].Key);
              end;

              if CommandsHelper.ContainsKey('::BUTTON::BARS') then
              begin
                if LDataParser.Pairs.Contains(TSPpPair.Create(CommandsHelper['::BUTTON::BARS'].AddrRes, [$03])) then
                  LBars := true;
                if LDataParser.Pairs.Contains(TSPpPair.Create(CommandsHelper['::BUTTON::BARS'].AddrRes, [$02])) then
                  LBars := false;
              end;

            finally
              LDataParser.Destroy;
            end;
          end;
          FSPpCNS.BasicResponse;
        end,
        procedure(Sender: TObject; E: Exception)
        begin
          DoDebug(Format('Exception BUTTON_BARS: %s', [E.Message]));
        end
      );

      result := LBars
    finally
      LRequestPacket.Free;
    end;
  finally
    TMonitor.Exit(FMonitor);
  end;

  FSPpCNS.HeartBeat.Active := true;
end;

procedure TSPpCNSBridge.FirstInit;
var
  AControlPacket  : TSPpRequestPacket;
begin
  FSPpCNS.HeartBeat.Active := false;
  FSPpCNS.DataReadThread.Active := false;

    (* 0 **************************)
    AControlPacket := TSPpRequestPacket.Create();
    try
      AControlPacket.Size := 9;
      AControlPacket.ID := FSPpCNS.RequestID;
      AControlPacket.CommandCode := $10;
      AControlPacket.SetBlock([$00, $40, $18, $20, $00, $00]);

      DoDebug('RCP: '+ ToHex(AControlPacket.ToIdBytes));
      FSPpCNS.WriteBuffer(AControlPacket,
        nil,{
        procedure(Sender: TObject; ABasicPacket: TSPpBasicPacket)
        begin
          DoDebug('CCU: '+ ToHex(ABasicPacket.ToIdBytes));
        end,}
        procedure(Sender: TObject; E: Exception)
        begin
          DoDebug(Format('Exception3: %s', [E.Message]));
        end
      );
    finally
      AControlPacket.Free;
    end;


    (* 1 **************************)
    AControlPacket := TSPpRequestPacket.Create();
    try
      AControlPacket.Size := 9;
      AControlPacket.ID := FSPpCNS.RequestID;
      AControlPacket.CommandCode := $10;
      AControlPacket.SetBlock([$00, $40, $18, $40, $00, $00]);

      DoDebug('RCP: '+ ToHex(AControlPacket.ToIdBytes));
      FSPpCNS.WriteBuffer(AControlPacket,
        nil,{
        procedure(Sender: TObject; ABasicPacket: TSPpBasicPacket)
        begin
          DoDebug('CCU: '+ ToHex(ABasicPacket.ToIdBytes));
        end,}
        procedure(Sender: TObject; E: Exception)
        begin
          DoDebug(Format('Exception3: %s', [E.Message]));
        end
      );
    finally
      AControlPacket.Free;
    end;

    (* 2 **************************)
    AControlPacket := TSPpRequestPacket.Create();
    try
      AControlPacket.Size := 9;
      AControlPacket.ID := FSPpCNS.RequestID;
      AControlPacket.CommandCode := $10;
      AControlPacket.SetBlock([$00, $40, $18, $d3, $00, $00]);

      DoDebug('RCP: '+ ToHex(AControlPacket.ToIdBytes));
      FSPpCNS.WriteBuffer(AControlPacket,
        nil,{
        procedure(Sender: TObject; ABasicPacket: TSPpBasicPacket)
        begin
          DoDebug('CCU: '+ ToHex(ABasicPacket.ToIdBytes));
        end,}
        procedure(Sender: TObject; E: Exception)
        begin
          DoDebug(Format('Exception3: %s', [E.Message]));
        end
      );
    finally
      AControlPacket.Free;
    end;


    (* 3 **************************)
    AControlPacket := TSPpRequestPacket.Create();
    try
      AControlPacket.Size := 9;
      AControlPacket.ID := FSPpCNS.RequestID;
      AControlPacket.CommandCode := $10;
      AControlPacket.SetBlock([$00, $40, $18, $d4, $00, $00]);

      DoDebug('RCP: '+ ToHex(AControlPacket.ToIdBytes));
      FSPpCNS.WriteBuffer(AControlPacket,
        nil,{
        procedure(Sender: TObject; ABasicPacket: TSPpBasicPacket)
        begin
          DoDebug('CCU: '+ ToHex(ABasicPacket.ToIdBytes));
        end,}
        procedure(Sender: TObject; E: Exception)
        begin
          DoDebug(Format('Exception3: %s', [E.Message]));
        end
      );
    finally
      AControlPacket.Free;
    end;


    (* 4 **************************)
    AControlPacket := TSPpRequestPacket.Create();
    try
      AControlPacket.Size := 9;
      AControlPacket.ID := FSPpCNS.RequestID;
      AControlPacket.CommandCode := $10;
      AControlPacket.SetBlock([$00, $40, $18, $60, $00, $00]);

      DoDebug('RCP: '+ ToHex(AControlPacket.ToIdBytes));
      FSPpCNS.WriteBuffer(AControlPacket,
        nil,{
        procedure(Sender: TObject; ABasicPacket: TSPpBasicPacket)
        begin
          DoDebug('CCU: '+ ToHex(ABasicPacket.ToIdBytes));
        end,}
        procedure(Sender: TObject; E: Exception)
        begin
          DoDebug(Format('Exception3: %s', [E.Message]));
        end
      );
    finally
      AControlPacket.Free;
    end;

  FSPpCNS.HeartBeat.Active := true;
  FSPpCNS.DataReadThread.Active := true;
end;


procedure TSPpCNSBridge.UNKNOWN_10001018200000;

var
  AControlPacket    : TSPpRequestPacket;
  ABuffer1          : TIdBytes;
  ABuffer2          : TIdBytes;
  ARequestBuffer    : TIdBytes;
begin

(* 1 **************************)
  AControlPacket := TSPpRequestPacket.Create();
  try
    AControlPacket.Header := $0f;
    AControlPacket.Size := $02;
    AControlPacket.ID := FSPpCNS.ResponseID;
    ABuffer1 := TSPpUTILS.CopyBytes(AControlPacket.ToBytes);
  finally
    AControlPacket.Free;
  end;


  AControlPacket := TSPpRequestPacket.Create();
  try
    AControlPacket.Header := $0e;
    AControlPacket.Size := $09;
    AControlPacket.ID := FSPpCNS.RequestID;
    AControlPacket.CommandCode := $10;
    AControlPacket.SetBlock([$03, $91, $18, $20, $00, $00]);

    ABuffer2 := TSPpUTILS.CopyBytes(AControlPacket.ToBytes);
  finally
    AControlPacket.Free;
  end;


  AppendBytes(ARequestBuffer, ABuffer1);
  AppendBytes(ARequestBuffer, ABuffer2);

  DoDebug('RCP: '+ ToHex(ARequestBuffer));
  FSPpCNS.WriteBuffer1(ARequestBuffer,
    nil,
    procedure(Sender: TObject; E: Exception)
    begin
      DoDebug(Format('Exception3: %s', [E.Message]));
    end
  );
end;



END.