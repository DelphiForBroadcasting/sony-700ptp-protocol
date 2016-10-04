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

unit FH.SONY.SPP.CNS.MCS;


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
  TSPpCnsMcs = class(TSPpCNS)
  private

    FWriteLock    : TCriticalSection;
    FReadLock     : TCriticalSection;
    FMonitor      : TObject;

    FOnDebug                : TDebugEvent;

    procedure DoDebug(ASender: TObject; AMsg: string);
    procedure FirstInit;
    procedure AssignSPpCommands;
    procedure DoTrigger2108(ASender: TSPpCommand);
  public
    constructor Create(OnDebug: TDebugEvent = nil); overload;
    destructor Destroy; override;

    function Assignment(const ACcuId: byte): boolean;
    function GetCcuIpAddress(const ACcuId: byte): cardinal;
  end;


implementation


constructor TSPpCnsMcs.Create(OnDebug: TDebugEvent = nil);
begin
  FOnDebug := OnDebug;

  FWriteLock := TCriticalSection.Create;
  FReadLock := TCriticalSection.Create;
  FMonitor := TObject.Create;

  inherited Create(DoDebug, FWriteLock, FReadLock, FMonitor);


  AssignSPpCommands;

  Self.OnHandShake := procedure(Sender: TObject; ABasicPacket: TSPpBasicPacket; const ASerialNumber: cardinal)
                      begin
                        if ASerialNumber > 0 then
                        begin
                          DoDebug(self, Format('HandShake OK, CCU device SN: %d', [ASerialNumber]));
                          FirstInit;
                        end;
                      end;


  (*  *)
  SerialNumber := 0;
  Mode := TSPpCNSMode.m_MCS;
  RCPId := 0;

end;

destructor TSPpCnsMcs.Destroy;
begin
  Self.Disconnect;

  FreeAndNil(FWriteLock);
  FreeAndNil(FReadLock);
  FreeAndNil(FMonitor);

  inherited Destroy;
end;

procedure TSPpCnsMcs.DoDebug(ASender: TObject; AMsg: string);
begin
    TThread.Synchronize(nil,
      procedure
      begin
        if assigned(fOnDebug) then
        begin
          fOnDebug(ASender, AMsg);
        end;
      end
    );
end;

procedure TSPpCnsMcs.AssignSPpCommands;
var
  LCommandHandler: TSPpCommandHandler;
begin
  // ::MENU::MAINTENANCE::CAMERA::MICROPHONEGAIN::CH01
 { LCommandHandler := CommandHandlers.Add;
  LCommandHandler.Name := '::MENU::MAINTENANCE::CAMERA::MICROPHONEGAIN::CH01';
  LCommandHandler.Commands.Add([$21, $08]);
  LCommandHandler.OnCommand := DoTrigger2108;    }
end;


procedure TSPpCnsMcs.DoTrigger2108(ASender: TSPpCommand);
begin
  DoDebug(self, format('TRIGGER%s - %s', [ASender.CommandHandler.Name, ToHex(ASender.BasicPacket.ToIdBytes)]));
end;

procedure TSPpCnsMcs.FirstInit;
var
  ARequestPacket  : TSPpRequestPacket;
  LRequestPacket  : TSPpRequestPacket;
begin
  Self.HeartBeat.Active := false;
  Self.DataReadThread.Active := false;

  DoDebug(self, '');

  (* SEND RCP ID *)
  LRequestPacket := TSPpRequestPacket.Create();
  try
    LRequestPacket.Size := 8;
    LRequestPacket.ID := RequestID;
    LRequestPacket.CommandCode := $01;
    LRequestPacket.SetBlock([$00, $02, $90, $00, $c0]);
    TSPpUTILS.RcpIdToRaw(self.RCPId, false);
    DoDebug(self, 'RCP: '+ ToHex(LRequestPacket.ToIdBytes));
    WriteBuffer(LRequestPacket,
      nil,{
      procedure(Sender: TObject; ABasicPacket: TSPpBasicPacket)
      begin
        DoDebug(self, 'MCS: '+ ToHex(ABasicPacket.ToIdBytes));
      end,  }
      procedure(Sender: TObject; E: Exception)
      begin
        DoDebug(self, Format('Exception3: %s', [E.Message]));
      end
    );
  finally
    LRequestPacket.Free;
  end;


  DoDebug(self, '');

  (* GET CCU ASSIGNED *)
    (* 0 **************************)
    ARequestPacket := TSPpRequestPacket.Create();
    try
      ARequestPacket.Size := 10;
      ARequestPacket.ID := RequestID;
      ARequestPacket.CommandCode := $20;
      ARequestPacket.SetBlock([$00, $d9, $fe, $12, $90, $00, $c1]);


      TSPpUTILS.RcpIdToRaw(self.RCPId, false);


      DoDebug(self, 'RCP: '+ ToHex(ARequestPacket.ToIdBytes));



      WriteBuffer(ARequestPacket,
        nil,{
        procedure(Sender: TObject; ABasicPacket: TSPpBasicPacket)
        begin
          DoDebug(Sender, 'MCS: '+ ToHex(ABasicPacket.ToIdBytes));
        end, }
        procedure(Sender: TObject; E: Exception)
        begin
          DoDebug(self, Format('Exception3: %s', [E.Message]));
        end
      );
    finally
      ARequestPacket.Free;
    end;


   DoDebug(self, '');

  (* *)
    (* 0 **************************)
    ARequestPacket := TSPpRequestPacket.Create();
    try
      ARequestPacket.Size := 5;
      ARequestPacket.ID := RequestID;
      ARequestPacket.CommandCode := $02;
      ARequestPacket.SetBlock([$00, $00]);

      DoDebug(self, 'RCP: '+ ToHex(ARequestPacket.ToIdBytes));
      WriteBuffer(ARequestPacket,
        nil,{
        procedure(Sender: TObject; ABasicPacket: TSPpBasicPacket)
        begin
          DoDebug(Sender, 'MCS: '+ ToHex(ABasicPacket.ToIdBytes));
        end, }
        procedure(Sender: TObject; E: Exception)
        begin
          DoDebug(self, Format('Exception3: %s', [E.Message]));
        end
      );
    finally
      ARequestPacket.Free;
    end;

   DoDebug(self, '');
  (* GET IP CCU *)
  LRequestPacket := TSPpRequestPacket.Create();
  try
    LRequestPacket.Size := 8;
    LRequestPacket.ID := RequestID;
    LRequestPacket.CommandCode := $20;
    LRequestPacket.SetBlock([$01, $d9, $fe, $58, $0c]);
    TSPpUTILS.RcpIdToRaw(self.RCPId, false);
    DoDebug(self, 'RCP: '+ ToHex(LRequestPacket.ToIdBytes));


    WriteBuffer(LRequestPacket,
      nil,{
      procedure(Sender: TObject; ABasicPacket: TSPpBasicPacket)
      begin
        DoDebug(self, 'MCS: '+ ToHex(ABasicPacket.ToIdBytes));
      end, }
      procedure(Sender: TObject; E: Exception)
      begin
        DoDebug(self, Format('Exception3: %s', [E.Message]));
      end
    );
  finally
    LRequestPacket.Free;
  end;

   DoDebug(self, '');


  LRequestPacket := TSPpRequestPacket.Create();
  try
    LRequestPacket.Size := 15;
    LRequestPacket.ID := RequestID;
    LRequestPacket.CommandCode := $30;
    LRequestPacket.SetBlock([$0c,$00,$12,$90,$00,$c1,$81,$00,$82,$00,$03,$00]);
    TSPpUTILS.RcpIdToRaw(self.RCPId, false);
    DoDebug(self, 'RCP: '+ ToHex(LRequestPacket.ToIdBytes));
    WriteBuffer(LRequestPacket,
      nil,{
      procedure(Sender: TObject; ABasicPacket: TSPpBasicPacket)
      begin
        DoDebug(self, 'MCS: '+ ToHex(ABasicPacket.ToIdBytes));
      end,}
      procedure(Sender: TObject; E: Exception)
      begin
        DoDebug(self, Format('Exception3: %s', [E.Message]));
      end
    );
  finally
    LRequestPacket.Free;
  end;



DoDebug(self, '');
   //GetCcuIpAddress($0b);

     DoDebug(self, '');

  Self.HeartBeat.Active := true;
  Self.DataReadThread.Active := true;
end;



function TSPpCnsMcs.GetCcuIpAddress(const ACcuId: byte): cardinal;
var
  LRequestPacket  : TSPpRequestPacket;
  FDataBlock      : TBytes;
begin

  Self.HeartBeat.Active := false;

  TMonitor.Enter(FMonitor);
  try
    LRequestPacket := TSPpRequestPacket.Create();
    try
      LRequestPacket.Size := 8;
      LRequestPacket.ID := RequestID;
      LRequestPacket.CommandCode := $20;
      LRequestPacket.SetBlock([$01, $d9, $fe, $58, ACcuId]);

      DoDebug(self, 'RCP: '+ ToHex(LRequestPacket.ToIdBytes));
      WriteBuffer(LRequestPacket,
        procedure(Sender: TObject; ABasicPacket: TSPpBasicPacket)
        begin
          DoDebug(self, 'MCS: '+ ToHex(ABasicPacket.ToIdBytes));
        end,
        procedure(Sender: TObject; E: Exception)
        begin
          DoDebug(self, Format('Exception3: %s', [E.Message]));
        end
      );

    finally
      LRequestPacket.Free;
    end;
  finally
    TMonitor.Exit(FMonitor);
  end;

  Self.HeartBeat.Active := true;
end;

function TSPpCnsMcs.Assignment(const ACcuId: byte): boolean;
var
  LRequestPacket  : TSPpRequestPacket;
  FDataBlock      : TBytes;
  LBars           : boolean;
begin
  LBars := false;
  result := LBars;

  Self.HeartBeat.Active := false;

  TMonitor.Enter(FMonitor);
  try
    LRequestPacket := TSPpRequestPacket.Create();
    try
      LRequestPacket.Size := 24;
      LRequestPacket.ID := RequestID;
      LRequestPacket.CommandCode := $20;
      LRequestPacket.SetBlock([$51,$d9,$fe,$12,$90,$00,$a1,$00,$01,$d9,$fe,$12,$ff, $00,$a0,$d9,$fe,$58,ACcuId,$00,$00]);

      DoDebug(self, 'RCP: '+ ToHex(LRequestPacket.ToIdBytes));
      WriteBuffer(LRequestPacket,
        procedure(Sender: TObject; ABasicPacket: TSPpBasicPacket)
        begin
          DoDebug(self, 'MCS: '+ ToHex(ABasicPacket.ToIdBytes));
        end,
        procedure(Sender: TObject; E: Exception)
        begin
          DoDebug(self, Format('Exception3: %s', [E.Message]));
        end
      );

      result := LBars
    finally
      LRequestPacket.Free;
    end;
  finally
    TMonitor.Exit(FMonitor);
  end;

  Self.HeartBeat.Active := true;
end;


END.