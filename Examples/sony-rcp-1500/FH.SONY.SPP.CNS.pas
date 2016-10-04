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

unit FH.SONY.SPP.CNS;


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
  FH.SONY.SPP.UTILS;

type
  TExceptionProcedure = reference to procedure(Sender: TObject; E: Exception);
  TSuccessfulProcedure = reference to procedure(Sender: TObject);
  TWriteBufferResponce1  = reference to procedure(Sender: TObject; AResponseBuffer: TBytes);

  TWriteBufferResponce  = reference to procedure(Sender: TObject; AResponsePacket: TSPpBasicPacket);

  TOnSuccessfulProcedure<T> = reference to procedure(Sender: TObject; Data: T);





  TMicrophoneGainEvent  = reference to procedure(Sender: TObject; ABasicPacket: TSPpBasicPacket; const Ch01: byte; const Ch02: byte);
  THandShakeEvent  = reference to procedure(Sender: TObject; ABasicPacket: TSPpBasicPacket; const ASerialNumber: cardinal);




const
  cEOL            : byte = $00;
  cWaitTimeOut    : integer = 1000;
  cDefaulCNSPort  : word = 7700;

const
  MSG_Handshake               = 18;
  MSG_ConnClosedGracefully  = 19;


type
  TDataMessage = record
    Msg: DWORD;
    Data: PChar;
  end;



type
  TSPpCNS = class;

  TDebugEvent = procedure(Sender: TObject; messages: string) of object;
  TDataAvailableEvent = procedure (Sender: TSPpCNS; const Buffer: TIdBytes) of object;
  TSPpPacketAvailableEvent = procedure(const ASPpBasicPacket: TSPpBasicPacket) of object;

  TClientContext = class(TIdContext)
  protected
    FClient: TIdTCPClient;
  public
    property Client: TIdTCPClient read FClient;
  end;


  THeartBeatThread = class(TThread)
  private
    FActive               : boolean;

    FContext              : TClientContext;
    FOwner                : TSPpCNS;

    FWriteLock            : TCriticalSection;
    FReadLock             : TCriticalSection;
    FMonitor              : TObject;

    procedure DoConnClosedGracefully;
  protected
    procedure DoTerminate;
    procedure Execute; override;
  public
    constructor Create(AOwner: TSPpCNS; AWriteLock: TCriticalSection; AReadLock: TCriticalSection; AMonitor: TObject); overload;
    destructor Destroy; override;
    procedure Terminate;
    property Owner: TSPpCNS read FOwner;
    property Active : boolean read FActive write FActive;
  end;

  TDataReadThread = class(TThread)
  private
    FActive               : boolean;

    FContext              : TClientContext;
    FOwner                : TSPpCNS;

    FWriteLock            : TCriticalSection;
    FReadLock             : TCriticalSection;
    FMonitor              : TObject;

    procedure DoConnClosedGracefully;
  protected
    procedure DoTerminate;
    procedure Execute; override;
  public
    constructor Create(AOwner: TSPpCNS; AWriteLock: TCriticalSection; AReadLock: TCriticalSection; AMonitor: TObject); overload;
    destructor Destroy; override;
    procedure Terminate;
    property Owner: TSPpCNS read FOwner;
    property Active : boolean read FActive write FActive;
  end;


  TSPpCNS = class(TThread)
  private
    FClient           : TIdTCPClient;

    FSerialNumber     : cardinal;
    FMode             : TSPpCNSMode;
    FRcpId            : Byte;

    FHeartBeat        : THeartBeatThread;
    FDataReadThread   : TDataReadThread;

    FWriteLock        : TCriticalSection;
    FReadLock         : TCriticalSection;
    FMonitor          : TObject;

    FResponseID       : word;
    FRequestID        : word;

    (* Triggers *)
    FOnDataAvailable            : TDataAvailableEvent;
    FOnUnknownPacketAvailable   : TSPpPacketAvailableEvent;
    FOnNotifyPacketAvailable    : TSPpPacketAvailableEvent;
    FOnResponsePacketAvailable  : TSPpPacketAvailableEvent;
    FOnRequestPacketAvailable   : TSPpPacketAvailableEvent;
    FOnBasicPacketAvailable     : TSPpPacketAvailableEvent;

    FOnDebug                    : TDebugEvent;
    FOnConnClosedGracefully     : TNotifyEvent;
    FOnHandShake                : THandShakeEvent;

    procedure DoConnClosedGracefully(Sender: TObject);
    procedure DoDataProcessor(const ABuffer: TIdBytes);
    procedure DoDataAvailable(const ABuffer: TIdBytes);
    procedure DoUnknownPacketAvailable(const ASPpBasicPacket: TSPpBasicPacket);
    procedure DoNotifyPacketAvailable(const ASPpBasicPacket: TSPpBasicPacket);
    procedure DoResponsePacketAvailable(const ASPpBasicPacket: TSPpBasicPacket);
    procedure DoRequestPacketAvailable(const ASPpBasicPacket: TSPpBasicPacket);
    procedure DoBasicPacketAvailable(const ASPpBasicPacket: TSPpBasicPacket);

    procedure DoDebug(const AMsg: string);


    function GetMode: TSPpCNSMode;
    procedure SetMode(AValue: TSPpCNSMode);
    function GetHost: string;
    procedure SetHost(AValue: string);
    function GetPort: Integer;
    procedure SetPort(AValue: Integer);

    function GetResponseID : word;
    function GetRequestID : word;

  protected
    procedure DoTerminate;
    procedure Execute; override;
  public
    constructor Create(OnDebug: TDebugEvent; AWriteLock : TCriticalSection; AReadLock : TCriticalSection; AMonitor: TObject); overload;
    destructor Destroy; override;
    procedure Terminate;

    procedure Connect;
    procedure Disconnect;

    procedure BasicResponse(ARequestPacket: TSPpRequestPacket = nil);
    function WaitFor(const ABytes: TArray<System.Byte>; ARemoveFromBuffer: Boolean = True;
      AInclusive: Boolean = False; ATimeout: Integer = IdTimeoutDefault): TIdBytes; overload;
    function WaitFor(const AValue: Word; ARemoveFromBuffer: Boolean = True;
      AInclusive: Boolean = False; ATimeout: Integer = IdTimeoutDefault): TIdBytes; overload;
    Procedure WriteBuffer1(ARequestBuffer: TIdBytes;
                          AOnResponse   : TWriteBufferResponce1 = nil;
                          AOnExcaption  : TExceptionProcedure = nil;
                          AWaitTimeOut  : integer = 500);
    Procedure WriteBuffer(ABasicPacket  : TSPpBasicPacket;
                           AOnResponse   : TWriteBufferResponce = nil;
                           AOnExcaption  : TExceptionProcedure = nil;
                           AWaitTimeOut  : integer = 500);
    procedure HandShake(ACNSMode: TSPpCNSMode; ASerialNumber: Cardinal;
                        AOnHandShake  : THandShakeEvent;
                        AOnExcaption  : TExceptionProcedure = nil);

    function Assign1: boolean;
    procedure BUTTON_CHARACTER;
    function BUTTON_PANELACTIVE: boolean;

    property OnDebug                    : TDebugEvent               read fOnDebug                   write fOnDebug;
    property OnConnClosedGracefully     : TNotifyEvent              read fOnConnClosedGracefully    write fOnConnClosedGracefully;
    property OnDataAvailable            : TDataAvailableEvent       read FOnDataAvailable           write FOnDataAvailable;
    property OnUnknownPacketAvailable   : TSPpPacketAvailableEvent  read FOnUnknownPacketAvailable  write FOnUnknownPacketAvailable;
    property OnNotifyPacketAvailable    : TSPpPacketAvailableEvent  read FOnNotifyPacketAvailable   write FOnNotifyPacketAvailable;
    property OnResponsePacketAvailable  : TSPpPacketAvailableEvent  read FOnResponsePacketAvailable write FOnResponsePacketAvailable;
    property OnRequestPacketAvailable   : TSPpPacketAvailableEvent  read FOnRequestPacketAvailable  write FOnRequestPacketAvailable;
    property OnBasicPacketAvailable     : TSPpPacketAvailableEvent  read FOnBasicPacketAvailable    write FOnBasicPacketAvailable;
    property OnHandShake                : THandShakeEvent           read FOnHandShake               write FOnHandShake;

    property Master       : string      read GetHost        write SetHost;
    property Target       : string      read GetHost        write SetHost;
    property Host         : string      read GetHost        write SetHost;
    property Port         : Integer     read GetPort        write SetPort;

    property Mode         : TSPpCNSMode read GetMode        write SetMode;
    property SerialNumber : cardinal    read FSerialNumber  write FSerialNumber;
    property RcpId        : Byte        read FRcpId         write FRcpId;


    property ResponseID   : word read GetResponseID;
    property RequestID    : word read GetRequestID write FRequestID;

    property Client           : TIdTCPClient  read FClient write FClient;
    property HeartBeat        : THeartBeatThread read FHeartBeat write FHeartBeat;
    property DataReadThread   : TDataReadThread read FDataReadThread write FDataReadThread;

  end;


  ETCPClientError = class(EIdException);
  ETCPClientConnectError = class(ETCPClientError);

implementation

uses
  IdResourceStringsCore,
  IdResourceStringsProtocols;


//EIdReadTimeout


(* THearBitThread *)
constructor THeartBeatThread.Create(AOwner: TSPpCNS; AWriteLock: TCriticalSection; AReadLock: TCriticalSection; AMonitor: TObject);
begin
  inherited Create(false);
{$IFDEF MSWINDOWS}
  Priority := TThreadPriority.tpLower;
{$ENDIF}
  FreeOnTerminate := False;
  FActive :=  false;

  FWriteLock := AWriteLock;
  FReadLock := AReadLock;
  FMonitor  :=  AMonitor;

  FOwner := AOwner;
  FContext := TClientContext.Create(FOwner.Client, nil, nil);
  FContext.FClient := FOwner.Client;
  TClientContext(FContext).FOwnsConnection := False;
end;

destructor THeartBeatThread.Destroy;
begin
  FreeAndNil(FContext);
  inherited Destroy;
end;

procedure THeartBeatThread.Terminate;
begin
  inherited Terminate;
end;

procedure THeartBeatThread.DoConnClosedGracefully;
begin
  TThread.Synchronize(nil,
  procedure
  begin
    FOwner.DoConnClosedGracefully(self);
  end);
end;
//EIdReadTimeout

procedure THeartBeatThread.Execute;
var
  FBuffer : TIdBytes;
  FBuffer1 : word;

  ANotifyPacket   : TSPpHeartBeatPacket;
  ARequestBuffer  : TIdBytes;
begin
  while not Terminated do
  begin

    if ((not assigned(FOwner)) or (not FOwner.Client.Connected) or (not FActive))  then
    begin
      sleep(1000);
      Continue;
    end;

    TMonitor.Enter(FMonitor);
    try
      ANotifyPacket := TSPpHeartBeatPacket.Create();
      try
        ANotifyPacket.Header := $08;
        FOwner.WriteBuffer(ANotifyPacket,
          //nil,{
          procedure(Sender: TObject; AResponsePacket: TSPpBasicPacket)
          begin
            //FClient.DoDebug('Response HeartBeatThread: '+ ToHex(TSPpUTILS.CopyBytes(AResponsePacket.ToBytes)));
          end,
          procedure(Sender: TObject; E: Exception)
          begin
            FOwner.DoDebug(Format('Exception HeartBeatThread: %s', [E.Message]));
          end
        );
      finally
        ANotifyPacket.Destroy;
      end;
    finally
      TMonitor.Exit(FMonitor);
    end;

    sleep(1000);
  end;
end;


procedure THeartBeatThread.DoTerminate;
begin
  inherited;
end;


(* TDataReadThread *)
constructor TDataReadThread.Create(AOwner: TSPpCNS; AWriteLock: TCriticalSection; AReadLock: TCriticalSection; AMonitor: TObject);
begin
  inherited Create(false);
{$IFDEF MSWINDOWS}
  Priority := TThreadPriority.tpNormal;
{$ENDIF}
  FreeOnTerminate := False;
  FActive :=  false;

  FWriteLock := AWriteLock;
  FReadLock := AReadLock;
  FMonitor  :=  AMonitor;
  FOwner := AOwner;
  FContext := TClientContext.Create(AOwner.Client, nil, nil);
  FContext.FClient := AOwner.Client;
  TClientContext(FContext).FOwnsConnection := False;
end;

destructor TDataReadThread.Destroy;
begin
  FreeAndNil(FContext);
  inherited Destroy;
end;

procedure TDataReadThread.Terminate;
begin
  inherited Terminate;
end;

procedure TDataReadThread.DoTerminate;
begin
  inherited;
end;

procedure TDataReadThread.DoConnClosedGracefully;
begin
  TThread.Synchronize(nil,
  procedure
  begin
    FOwner.DoConnClosedGracefully(self);
  end);
end;

//EIdReadTimeout

procedure TDataReadThread.Execute;
var
  FBuffer : TIdBytes;
begin
  while not Terminated do
  begin

    if (not assigned(FOwner)) or (not FOwner.Client.Connected) then
    begin
      sleep(100);
      Continue;
    end;

    // waiting for response
   { if FClient.IOHandler.InputBufferIsEmpty then
    begin
      FClient.IOHandler.CheckForDataOnSource(50);
      if FClient.IOHandler.InputBufferIsEmpty then
        Continue;
    end; }

    TMonitor.Enter(FMonitor); //FWriteLock.Enter;
    try
      //FReadLock.Enter;
      try
        if not FOwner.Client.IOHandler.InputBufferIsEmpty then
        begin
          SetLength(FBuffer, 0);
          while not FOwner.Client.IOHandler.InputBufferIsEmpty do
          begin
            AppendByte(FBuffer, FOwner.Client.IOHandler.ReadByte);
          end;

          TThread.Synchronize(nil,
          procedure
          begin
            FOwner.DoDataProcessor(FBuffer);
          end);
        end;

        try
          FOwner.Client.IOHandler.CheckForDisconnect(true, false);
        except
          on E: EIdConnClosedGracefully do
          begin
            DoConnClosedGracefully
          end;
        end;


      finally
        //FReadLock.Leave;
      end;
    finally
     TMonitor.Exit(FMonitor); //FWriteLock.Leave;
    end;

  end;
end;



{ TTCPClient}

constructor TSPpCNS.Create(OnDebug: TDebugEvent; AWriteLock : TCriticalSection; AReadLock : TCriticalSection; AMonitor: TObject);
begin
  inherited Create(false);
{$IFDEF MSWINDOWS}
  Priority := TThreadPriority.tpNormal;
{$ENDIF}
  FreeOnTerminate := False;

  FClient := TIdTCPClient.Create(nil);
  FClient.ReadTimeOut := 1000;
  FClient.ConnectTimeout := IdTimeoutDefault;
  FClient.Port  := cDefaulCNSPort;

  FWriteLock := AWriteLock;
  FReadLock := AReadLock;
  FMonitor := AMonitor;

  FOnDebug:=OnDebug;

  DoDebug('TSPpCNS.create');
end;

destructor TSPpCNS.Destroy;
begin
  DoDebug('TSPpCNS.destroy');

  Disconnect;
  FClient.Destroy;

  inherited Destroy;
end;

procedure TSPpCNS.Terminate;
begin
  inherited Terminate;
end;

procedure TSPpCNS.DoTerminate;
begin
  inherited;
end;
//EIdReadTimeout

procedure TSPpCNS.Execute;
begin
  while not Terminated do
  begin
    sleep(1000);
  end;
end;

function TSPpCNS.WaitFor(const ABytes: TArray<System.Byte>; ARemoveFromBuffer: Boolean = True;
  AInclusive: Boolean = False; ATimeout: Integer = IdTimeoutDefault): TIdBytes;
var
  LBytes: TIdBytes;
  LPos: Integer;
  FBytes: TIdBytes;
begin
  SetLength(Result, 0);
  SetLength(LBytes, Length(ABytes));
  move(ABytes[0], LBytes[0], Length(ABytes));
  LPos := 0;
  repeat
    LPos := FClient.IOHandler.InputBuffer.IndexOf(LBytes, LPos);
    if LPos <> -1 then
    begin
      if ARemoveFromBuffer and AInclusive then
      begin
        FClient.IOHandler.InputBuffer.ExtractToBytes(result{, LPos+Length(LBytes)});
      end else
      begin
        FClient.IOHandler.InputBuffer.ExtractToBytes(FBytes{, LPos});
        if ARemoveFromBuffer then
        begin
          FClient.IOHandler.InputBuffer.Remove(Length(LBytes));
        end;
        if AInclusive then
        begin
          AppendBytes(FBytes, Result)
        end;
      end;
      Exit;
    end;
    LPos := IndyMax(0, FClient.IOHandler.InputBuffer.Size - (Length(LBytes)-1));
    if not FClient.IOHandler.CheckForDataOnSource(ATimeout) then exit;
  until False;
end;


function TSPpCNS.WaitFor(const AValue: Word; ARemoveFromBuffer: Boolean = True;
  AInclusive: Boolean = False; ATimeout: Integer = IdTimeoutDefault): TIdBytes;
var
  FBuffer : TBytes;
begin
  SetLength(FBuffer, sizeof(AValue));
  pWord(@FBuffer[0])^ := AValue;
  result:=WaitFor(FBuffer, ARemoveFromBuffer, AInclusive, ATimeout);
end;

procedure TSPpCNS.DoDebug(const AMsg: string);
begin
  if assigned(fOnDebug) then
    fOnDebug(self, AMsg);

end;

function TSPpCNS.GetMode(): TSPpCNSMode;
begin
  result := FMode;
end;

procedure TSPpCNS.SetMode(AValue: TSPpCNSMode);
begin
  FMode := AValue;
end;


function TSPpCNS.GetHost: string;
begin
  result := FClient.Host;
end;

procedure TSPpCNS.SetHost(AValue: string);
begin
  FClient.Host := AValue;
end;

function TSPpCNS.GetPort: integer;
begin
  result := FClient.Port;
end;

procedure TSPpCNS.SetPort(AValue: Integer);
begin
  FClient.Port := AValue;
end;

function TSPpCNS.GetResponseID : word;
begin
  inc(FResponseID);
  result := TSPpUTILS.Swap2(FResponseID);

end;

function TSPpCNS.GetRequestID : word;
begin
  result := TSPpUTILS.Swap2(FRequestID);
  inc(FRequestID);
end;

Procedure TSPpCNS.WriteBuffer(ABasicPacket   : TSPpBasicPacket;
                              AOnResponse     : TWriteBufferResponce = nil;
                              AOnExcaption    : TExceptionProcedure = nil;
                              AWaitTimeOut    : integer = 500);
var
  AResponseBuffer : TIdBytes;
  FBasicPacket    : TSPpBasicPacket;
  FId : word;
begin
  try
    if not assigned(ABasicPacket) then raise Exception.Create('TSPpBasicPacket not assigned');

    TThread.Synchronize(nil,
      procedure
      begin
        FClient.IOHandler.WriteBufferOpen;
        try
          FClient.IOHandler.Write(ABasicPacket.ToIdBytes);
          FClient.IOHandler.WriteBufferFlush;
        finally
          FClient.IOHandler.WriteBufferClose;
        end;

        if assigned(AOnResponse) then
        begin

          SetLength(AResponseBuffer, 0);

          case ABasicPacket.PacketType of
            pt_Notify:
              begin
                AResponseBuffer:=WaitFor([$09, $00], true, true, AWaitTimeOut)
              end;
            pt_HandShake:
              begin
                AResponseBuffer:=WaitFor([$03, $12], true, true, AWaitTimeOut)
              end;
            pt_Request :
              begin
                FID := TSPpRequestPacket(ABasicPacket).ID;
                inc(FID);
                FID := TSPpUTILS.Swap2(FID);
                AResponseBuffer:=WaitFor(FID, true, true, AWaitTimeOut);
              end;
          end;

          FBasicPacket := TSPpBasicPacket.Create(TSPpUTILS.CopyBytes(AResponseBuffer));
          try
            AOnResponse(self, FBasicPacket);
          finally
            FBasicPacket.Destroy;
          end;
        end;

      end
    );

  except
    on E: EIdConnClosedGracefully do
    begin
      DoConnClosedGracefully(self);
    end;
    on E: Exception do
    begin
      if assigned(AOnExcaption) then
        AOnExcaption(self, E);
    end;
  end;
end;

Procedure TSPpCNS.WriteBuffer1(ARequestBuffer: TIdBytes;
                              AOnResponse   : TWriteBufferResponce1 = nil;
                              AOnExcaption  : TExceptionProcedure = nil;
                              AWaitTimeOut  : integer = 500);
var
  AResponseBuffer : TBytes;
begin
  try

    TThread.Synchronize(nil,
          procedure
          begin
            FClient.IOHandler.WriteBufferOpen;
            try
              FClient.IOHandler.Write(ARequestBuffer);
              FClient.IOHandler.WriteBufferFlush;
            finally
              FClient.IOHandler.WriteBufferClose;
            end;
          end
    );


    if assigned(AOnResponse) then
    begin
      SetLength(AResponseBuffer, 0);
      // waiting for response
      if FClient.IOHandler.InputBufferIsEmpty then
      begin
        FClient.IOHandler.CheckForDataOnSource(AWaitTimeOut);
      end;

      if not FClient.IOHandler.InputBufferIsEmpty then
      begin
        while not FClient.IOHandler.InputBufferIsEmpty do
        begin
          // read response
          TSPpUTILS.AppendByte(AResponseBuffer, FClient.IOHandler.ReadByte);
        end;
      end;

      TThread.Synchronize(nil,
        procedure
        begin
          AOnResponse(self, AResponseBuffer);
        end
      );
    end;

  except
    on E: Exception do
    begin
      if assigned(AOnExcaption) then
        AOnExcaption(self, E);
    end;
  end;
end;

procedure TSPpCNS.HandShake(ACNSMode: TSPpCNSMode; ASerialNumber: Cardinal;
                            AOnHandShake    : THandShakeEvent;
                            AOnExcaption    : TExceptionProcedure = nil);
var
  FHandShakePacket      : TSPpHandShakePacket;
  FHandShakePacketNext  : TSPpHandShakePacket;
begin
  try
    TMonitor.Enter(FMonitor);
    try
      FHandShakePacket := TSPpHandShakePacket.InitHandShake($02, ACNSMode, FRequestID, ASerialNumber);
      try
        WriteBuffer(FHandShakePacket,
          procedure(Sender: TObject; AResponsePacket: TSPpBasicPacket)
          begin
            if TSPpHandShakePacket(AResponsePacket).PacketType = pt_HandShake then
            begin

              FHandShakePacketNext := TSPpHandShakePacket.InitHandShake($01, ACNSMode, FRequestID, ASerialNumber);
              try
                WriteBuffer(FHandShakePacketNext,
                  nil,
                  procedure(Sender: TObject; E: Exception)
                  begin
                    if assigned(AOnExcaption) then
                      AOnExcaption(Sender, E);
                  end
                );
              finally
                  FHandShakePacketNext.Destroy;
              end;

              FResponseID := TSPpHandShakePacket(AResponsePacket).ID;
              if assigned(AOnHandShake) then
                AOnHandShake(self, AResponsePacket, TSPpHandShakePacket(AResponsePacket).SerialNumber);
            end else
            begin
              raise Exception.Create('TSPpBasicPacket not handshake');
            end;
          end,
          procedure(Sender: TObject; E: Exception)
          begin
            if assigned(AOnExcaption) then
              AOnExcaption(Sender, E);
          end
        );
      finally
        FHandShakePacket.Destroy;
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
end;



function TSPpCNS.BUTTON_PANELACTIVE: boolean;

var
  AControlPacket  : TSPpRequestPacket;
  ARequestBuffer  : TIdBytes;
  ABlockBuffer    : TBytes;
begin

(* 1 **************************)
  AControlPacket := TSPpRequestPacket.Create();
  try
    AControlPacket.Header := $0e;
    AControlPacket.Size := $15;
    AControlPacket.ID := RequestID;
    AControlPacket.CommandCode := $50;
    SetLength(ABlockBuffer, AControlPacket.GetBlockSize);
    ABlockBuffer[0]:=$18;
    ABlockBuffer[1]:=$04;
    ABlockBuffer[2]:=$00;
    ABlockBuffer[3]:=$00;
    ABlockBuffer[4]:=$18;
    ABlockBuffer[5]:=$90;
    ABlockBuffer[6]:=$00;
    ABlockBuffer[7]:=$00;

    ABlockBuffer[8]:=$00;
    ABlockBuffer[9]:=$08;

    ABlockBuffer[10]:=$0b;
    ABlockBuffer[11]:=$90;
    ABlockBuffer[12]:=$01;
    ABlockBuffer[13]:=$81;

    ABlockBuffer[14]:=$0b;
    ABlockBuffer[15]:=$90;
    ABlockBuffer[16]:=$02;
    ABlockBuffer[17]:=$81;


    AControlPacket.SetBlock(ABlockBuffer);

    ARequestBuffer := TSPpUTILS.CopyBytes(AControlPacket.ToBytes);
  finally
    AControlPacket.Free;
  end;

  DoDebug('Request BUTTON_PANELACTIVE: '+ ToHex(ARequestBuffer));
  WriteBuffer1(ARequestBuffer,
    procedure(Sender: TObject; AResponseBuffer: TBytes)
    begin
      DoDebug('Response BUTTON_PANELACTIVE: '+ ToHex(TSPpUTILS.CopyBytes(AResponseBuffer)));
    end,
    procedure(Sender: TObject; E: Exception)
    begin
      DoDebug(Format('Exception3: %s', [E.Message]));
    end
  );
end;


procedure TSPpCNS.BUTTON_CHARACTER;

var
  AControlPacket  : TSPpRequestPacket;
  ARequestBuffer  : TIdBytes;
  ABlockBuffer    : TBytes;
begin
  Self.FHeartBeat.Active := false;

(* 1 **************************)
  AControlPacket := TSPpRequestPacket.Create();
  try
    AControlPacket.Header := $0e;
    AControlPacket.Size := $13;
    AControlPacket.ID := RequestID;
    AControlPacket.CommandCode := $50;
    SetLength(ABlockBuffer, AControlPacket.GetBlockSize);
    ABlockBuffer[0]:=$18;
    ABlockBuffer[1]:=$02;
    ABlockBuffer[2]:=$00;
    ABlockBuffer[3]:=$00;
    ABlockBuffer[4]:=$18;
    ABlockBuffer[5]:=$90;
    ABlockBuffer[6]:=$00;
    ABlockBuffer[7]:=$00;

    ABlockBuffer[8]:=$00;
    ABlockBuffer[9]:=$06;

    ABlockBuffer[10]:=$41;
    ABlockBuffer[11]:=$00;
    ABlockBuffer[12]:=$00;

    ABlockBuffer[13]:=$40;
    ABlockBuffer[14]:=$1a;
    ABlockBuffer[15]:=$01;

    AControlPacket.SetBlock(ABlockBuffer);

    ARequestBuffer := TSPpUTILS.CopyBytes(AControlPacket.ToBytes);
  finally
    AControlPacket.Free;
  end;

  DoDebug('Request CHARACTER: '+ ToHex(ARequestBuffer));
  WriteBuffer1(ARequestBuffer,
    procedure(Sender: TObject; AResponseBuffer: TBytes)
    begin
      DoDebug('Response CHARACTER: '+ ToHex(TSPpUTILS.CopyBytes(AResponseBuffer)));
    end,
    procedure(Sender: TObject; E: Exception)
    begin
      DoDebug(Format('Exception3: %s', [E.Message]));
    end
  );

  Self.FHeartBeat.Active := true;
end;

function TSPpCNS.Assign1: boolean;
type
  TAssignBlock = packed record
    ID           : Word;
    Command      : Byte;
    Unknown      : array[0..3] of Byte;
    RCPId        : byte;
  end;

begin
  result := false;


    {cmd3 := '0e08'+'6468'+'0100029000a0';
    (* handshake channel 11 *)
    cmd3 := '0e0864680100029000b0';
    cmd4 := '0f023fed0e0a64692000d9fe129000b1';
    cmd5 := '0e05646a020000';
    cmd6 := '0f023fef0e08646b2001d9fe580b';
    cmd7 := '0e0f646c300b00129000b1810082000300';
    cmd8 := '0f023ff3';  }

{

  FillChar(AssignPacket, sizeof(AssignPacket), #0);
  AssignPacket.Header := $0e;
  AssignPacket.Size := Sizeof(TAssignBlock);
  AssignPacket.NextBlock.ID := $6864;
  AssignPacket.NextBlock.Command := $01;
  AssignPacket.NextBlock.Unknown[0] := $00;
  AssignPacket.NextBlock.Unknown[1] := $02;
  AssignPacket.NextBlock.Unknown[2] := $90;
  AssignPacket.NextBlock.Unknown[3] := $00;
  AssignPacket.NextBlock.RCPId := self.RCPId * 16;



  SetLength(FBuffer, sizeof(AssignPacket));
  Move(AssignPacket, FBuffer[0], sizeof(AssignPacket));

  DoDebug('Send3: '+ ToHex(FBuffer));

  WriteBuffer(FBuffer,
    procedure(Sender: TObject; ABuffer: TIdBytes)
    begin
      //DoDebug('Recive3: '+ ToHex(ABuffer));

      TSonyProtocolHelper.Parse0F(ABuffer,
          procedure(Sender: TObject; Data: SP_0F_Packet)
          begin
            //SP_0F_Packet
            DoDebug(format(' -0F - %s', [ToHex(Data.Data.NextBlock.Data)]));
          end,
          procedure(Sender: TObject; E: Exception)
          begin
            ;
          end
        );
    end,
    procedure(Sender: TObject; E: Exception)
    begin
      DoDebug(Format('Exception3: %s', [E.Message]));
    end
  );
       }



{

    (* SEND 3 PACKET *)
    cmd :=  cmd3;
    setLength(reciveBuffer, 0);
    setlength(Buffer, length(cmd) div 2);
    HexToBin(PChar(cmd), Buffer, Length(Buffer));
    DoDebug('Send3: '+ ToHex(Buffer));
    IOHandler.Write(Buffer);
    //IOHandler.ReadBytes(reciveBuffer, -1);
   DoDebug('Recive3: '+ ToHex(reciveBuffer));

    (* SEND 4 PACKET *)
    cmd :=  cmd4;
    setLength(reciveBuffer, 0);
    setlength(Buffer, length(cmd) div 2);
    HexToBin(PChar(cmd), Buffer, Length(Buffer));
    DoDebug('Send4: '+ ToHex(Buffer));
    IOHandler.Write(Buffer);
    //IdTCPClient1.IOHandler.ReadBytes(reciveBuffer, -1);
   // memo1.Lines.Add('Recive4: '+ ToHex(reciveBuffer));

      (* SEND 5 PACKET *)
    cmd :=  cmd5;
    setLength(reciveBuffer, 0);
    setlength(Buffer, length(cmd) div 2);
    HexToBin(PChar(cmd), Buffer, Length(Buffer));
    DoDebug('Send5: '+ ToHex(Buffer));
    IOHandler.Write(Buffer);
    //IOHandler.ReadBytes(reciveBuffer, -1);
    DoDebug('Recive5: '+ ToHex(reciveBuffer));


      (* SEND 6 PACKET *)
    cmd :=  cmd6;
    setLength(reciveBuffer, 0);
    setlength(Buffer, length(cmd) div 2);
    HexToBin(PChar(cmd), Buffer, Length(Buffer));
    DoDebug('Send6: '+ ToHex(Buffer));
    IOHandler.Write(Buffer);
    //IOHandler.ReadBytes(reciveBuffer, -1);
    DoDebug('Recive6: '+ ToHex(reciveBuffer));


      (* SEND 7 PACKET *)
    cmd :=  cmd7;
    setLength(reciveBuffer, 0);
    setlength(Buffer, length(cmd) div 2);
    HexToBin(PChar(cmd), Buffer, Length(Buffer));
    DoDebug('Send7: '+ ToHex(Buffer));
    IOHandler.Write(Buffer);
    //IOHandler.ReadBytes(reciveBuffer, -1);
    DoDebug('Recive7: '+ ToHex(reciveBuffer));


    //  IOHandler.Write(#0);
      DoDebug(format('TCPClient.write(%s)',['ok']));
      }

 { FLock.Enter;
  try

  finally
    FLock.Leave;
  end; }
end;

procedure TSPpCNS.Connect;
begin
  try
    FClient.Connect;
  except
    on E: EIdAlreadyConnected do
    begin
      DoDebug('EIdAlreadyConnected');
      exit;
    end;
    on E: EIdHostRequired do
    begin
      DoDebug('EIdHostRequired');
      exit;
    end;
    on E: Exception do
    begin
      DoDebug(E.Message);
      exit;
    end;
  end;

  DoDebug('TSPpCNS.Connect');


  try
    FDataReadThread := TDataReadThread.Create(Self, FWriteLock, FReadLock, FMonitor);
  except
    FClient.Disconnect;
    raise Exception.Create('TDataReadThread.Create Error ');
  end;

  try
    FHeartBeat := THeartBeatThread.Create(Self, FWriteLock, FReadLock, FMonitor);
  except
    FClient.Disconnect;
    raise Exception.Create('THeartBeatThread.Create Error');
  end;


  Self.FDataReadThread.Active := true;

  FRequestID := $6468;




  Self.HandShake(FMode, FSerialNumber,
    procedure(Sender: TObject; ABasicPacket: TSPpBasicPacket; const ASerialNumber: cardinal)
    begin
      if assigned(FOnHandShake) then
        FOnHandShake(Self, ABasicPacket, ASerialNumber);
    end,
    procedure(Sender: TObject; E: Exception)
    begin
      DoDebug(Format('HandShake Exception, %s', [E.Message]));
    end
  );

  Self.FHeartBeat.Active := true;
end;

procedure TSPpCNS.Disconnect;
begin
  if Assigned(FHeartBeat) then
  begin
    FHeartBeat.Terminate;
  end;
  if Assigned(FDataReadThread) then
  begin
    FDataReadThread.Terminate;
  end;
  try
    FClient.Disconnect;
  finally
    if Assigned(FHeartBeat) and not IsCurrentThread(FHeartBeat) then
    begin
      FHeartBeat.WaitFor;
      FreeAndNil(FHeartBeat);
    end;

    if Assigned(FDataReadThread) and not IsCurrentThread(FDataReadThread) then
    begin
      FDataReadThread.WaitFor;
      FreeAndNil(FDataReadThread);
    end;
  end;

end;



{CCU 0f:02:64:70: 0e: 1d: ef:6a: 10: 07: 03:18:40:00:00: c3:18:20:00:00: c1:18:d3:00:00: c1:18:d4:00:00: c1:18:60:00:00
RCP 0f:02:ef:6d: 0e: 22: 64:70: 10:  07: 03:18:90:00:00: 00:18:20:00:00: 00:18:40:00:00: 00:18:d3:00:00: 00:18:d4:00:00: 00:18:60:00:00

}


procedure TSPpCNS.BasicResponse(ARequestPacket: TSPpRequestPacket = nil);
var
  AResponsePacket   : TSPpResponsePacket;
begin
  AResponsePacket := TSPpResponsePacket.Create();
  try
    if assigned(ARequestPacket) then
      AResponsePacket.NextPacket := ARequestPacket;
    AResponsePacket.ID := ResponseID;
    DoDebug(format('BasicResponse:  %s', [ToHex(AResponsePacket.ToIdBytes)]));
    WriteBuffer(AResponsePacket,
      nil,
      procedure(Sender: TObject; E: Exception)
      begin
        //DoDebug(Format('Exception3: %s', [E.Message]));
      end
    );
  finally
    AResponsePacket.Free;
  end;
end;

procedure TSPpCNS.DoConnClosedGracefully(Sender: TObject);
begin
  if assigned(FOnConnClosedGracefully) then
    FOnConnClosedGracefully(self);
end;

procedure TSPpCNS.DoDataProcessor(const ABuffer: TIdBytes);
var
  FBuffer : TIdBytes;
  LBasicPacket    : TSPpBasicPacket;
  LNextPacket     : TSPpBasicPacket;
  LRequestPacket  : TSPpRequestPacket;
  LHeartBeatPacket: TSPpHeartBeatPacket;
  LNotifyPacket   : TSPpNotifyPacket;
  LDataParser     : TSPpDataParser;
  LDataBlock      : TBytes;
  I               : integer;
begin

  (* Check empty data *)
  if Length(ABuffer)=0 then
  begin
    DoDebug('Empty data');
    exit;
  end;

  FBuffer := ABuffer;
  (* Event *)
  DoDataAvailable(ABuffer);

  LBasicPacket := TSPpBasicPacket.Create(TSPpUTILS.CopyBytes(FBuffer));
  try
    LNextPacket := LBasicPacket;
    while LNextPacket <> nil do
    begin

      if LBasicPacket.PacketType = pt_Unknown then
      begin
        DoDebug('Unknown packet format');
        continue;
      end;

      (* Event *)
      DoBasicPacketAvailable(LNextPacket);

      case LNextPacket.PacketType of
        pt_HandShake:
        begin
          (* Event *)
        end;
        pt_Notify:
        begin
          (* Event *)
          DoNotifyPacketAvailable(LNextPacket);

          case  TSPpNotifyPacket(LNextPacket).Header of
            $0A:
              begin
                LNotifyPacket := TSPpNotifyPacket.Create;
                try
                  LNotifyPacket.Header := $0B;
                  LNotifyPacket.Size := 0;
                  WriteBuffer(LNotifyPacket, nil, nil);
                finally
                  LNotifyPacket.Destroy;
                end;
              end;
            $0B:
              begin
              end;
          end;
        end;
        pt_HeartBeat:
        begin
          case TSPpHeartBeatPacket(LNextPacket).Header of
            $08:
              begin
                LHeartBeatPacket := TSPpHeartBeatPacket.Create;
                try
                  LHeartBeatPacket.Header := $09;
                  LHeartBeatPacket.Size := 0;
                  WriteBuffer(LHeartBeatPacket, nil, nil);
                finally
                  LHeartBeatPacket.Destroy;
                end;
              end;
            $09:
              begin
              end;
          end;
        end;
        pt_Response:
        begin
          (* Event *)
          DoResponsePacketAvailable(LNextPacket);
        end;
        pt_Request:
        begin
          (* Event *)
          DoRequestPacketAvailable(LNextPacket);
        end;
        pt_Error:
        begin
          BasicResponse;
          DoDebug('ERROR: '+ ToHex(LNextPacket.ToIdBytes));
        end;
        pt_Unknown:
        begin
          DoUnknownPacketAvailable(LNextPacket);
          DoDebug(format('Unknown - %s', [ToHex(TSPpUTILS.CopyBytes(LNextPacket.ToBytes))]));
        end;
      end;
      LNextPacket := LNextPacket.NextPacket
    end;

  finally
    LBasicPacket.Destroy;
  end;

end;

procedure TSPpCNS.DoBasicPacketAvailable(const ASPpBasicPacket: TSPpBasicPacket);
begin
  if Assigned(FOnBasicPacketAvailable) then
    FOnBasicPacketAvailable(ASPpBasicPacket);
end;

procedure TSPpCNS.DoRequestPacketAvailable(const ASPpBasicPacket: TSPpBasicPacket);
begin
  if Assigned(FOnRequestPacketAvailable) then
    OnRequestPacketAvailable(ASPpBasicPacket);
end;

procedure TSPpCNS.DoResponsePacketAvailable(const ASPpBasicPacket: TSPpBasicPacket);
begin
  if Assigned(FOnResponsePacketAvailable) then
    OnResponsePacketAvailable(ASPpBasicPacket);
end;

procedure TSPpCNS.DoNotifyPacketAvailable(const ASPpBasicPacket: TSPpBasicPacket);
begin
  if Assigned(FOnNotifyPacketAvailable) then
    OnNotifyPacketAvailable(ASPpBasicPacket);
end;

procedure TSPpCNS.DoUnknownPacketAvailable(const ASPpBasicPacket: TSPpBasicPacket);
begin
  if Assigned(FOnUnknownPacketAvailable) then
    OnUnknownPacketAvailable(ASPpBasicPacket);
end;

procedure TSPpCNS.DoDataAvailable(const ABuffer: TIdBytes);
begin
  if Assigned(FOnDataAvailable) then
    OnDataAvailable(Self, ABuffer);
end;



END.