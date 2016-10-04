unit FH.RCP.MCS;


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
  IdTCPClient,
  IdThread,
  IdSync,
  System.SyncObjs,
  FH.SONY.RCP.SPP;

type
  TExceptionProcedure = reference to procedure(Sender: TObject; E: Exception);
  TSuccessfulProcedure = reference to procedure(Sender: TObject);
  TWriteBufferResponce  = reference to procedure(Sender: TObject; ABuffer: TIdBytes);

  TOnSuccessfulProcedure<T> = reference to procedure(Sender: TObject; Data: T);
  TDebugEvent = procedure(Sender: TObject; messages: string) of object;


const
  EOL           : byte = $00;
  waitTimeOut   : integer = 1000;

const
  MSG_Handshake               = 18;
  MSG_ConnClosedGracefully  = 19;


type
  TDataMessage = record
    Msg: DWORD;
    Data: PChar;
  end;



const
  FHeartBeatRequest : word = $0008;
  FHeartBeatResponse : word = $0009;



type
  TTCPClient = class;



  //TTCPClientDataAvailEvent = procedure(Sender: TObject; const Data: String; const dataType : TJustInDataType) of object;



  TClientContext = class(TIdContext)
  protected
    FClient: TTCPClient;
  public
    property Client: TTCPClient read FClient;
  end;


  THeartBeatThread = class(TThread)
  protected
    FContext              : TClientContext;
    FClient               : TTCPClient;

    FWriteLock            : TCriticalSection;
    FReadLock             : TCriticalSection;
    FMonitor              : TObject;

    procedure Execute; override;
  public
    constructor Create(AClient: TTCPClient; AWriteLock: TCriticalSection; AReadLock: TCriticalSection; AMonitor: TObject); overload;
    destructor Destroy; override;
    procedure Terminate;
    property Client: TTCPClient read FClient;
  end;


  TDataReadThread = class(TThread)
  protected
    FContext              : TClientContext;
    FClient               : TTCPClient;
    FWriteLock            : TCriticalSection;
    FReadLock             : TCriticalSection;
    FMonitor              : TObject;
    procedure Execute; override;
  public
    constructor Create(AClient: TTCPClient; AWriteLock: TCriticalSection; AReadLock: TCriticalSection; AMonitor: TObject); overload;
    destructor Destroy; override;
    procedure Terminate;
    property Client: TTCPClient read FClient;
  end;

  TMCUDataAvailEvent = procedure (Sender: TTCPClient; const Buffer: TIdBytes) of object;

  TTCPClient = class(TIdTCPClientCustom)
  private
    FSerialNumber : cardinal;
    FRCPId        : Byte;


    FWriteLock    : TCriticalSection;
    FReadLock     : TCriticalSection;
    FMonitor      : TObject;
    FHeartBeat    : THeartBeatThread;


    FOnDataAvailable        : TMCUDataAvailEvent;
    FOnDebug                : TDebugEvent;
    FOnConnClosedGracefully : TNotifyEvent;


    procedure DoDebug(const AMsg: string);


    procedure OnConnClosedGracefullyReceived(var Msg: TDataMessage); message MSG_ConnClosedGracefully;
    procedure OnHandshakeReceived(var Msg: TDataMessage); message MSG_Handshake;

    procedure DoDataProcessor(const ABuffer: TIdBytes);
    procedure DoOnDataAvailable(const ABuffer: TIdBytes);

    Procedure WriteBuffer(ABuffer       : TIdBytes;
                          AOnResponse   : TWriteBufferResponce = nil;
                          AOnExcaption  : TExceptionProcedure = nil);


  protected
    FDataReadThread: TDataReadThread;
  public
    constructor Create(OnDebug: TDebugEvent = nil); reintroduce; overload;
    destructor Destroy; override;
    procedure Connect; override;
    procedure Disconnect(ANotifyPeer: Boolean); override;
  published

    function handshake: boolean;
    function Assign1: boolean;


    property OnDebug     : TDebugEvent read fOnDebug write fOnDebug;
    property OnConnClosedGracefully : TNotifyEvent read fOnConnClosedGracefully write fOnConnClosedGracefully;
    property OnDataAvailable: TMCUDataAvailEvent read FOnDataAvailable write FOnDataAvailable;


    property Host;
    property Port default 7700;

    property SerialNumber : cardinal read FSerialNumber write FSerialNumber;
    property RCPId: Byte read FRCPId write FRCPId;

  end;

  ETCPClientError = class(EIdException);
  ETCPClientConnectError = class(ETCPClientError);

implementation

uses
  IdResourceStringsCore,
  IdResourceStringsProtocols;



(* TDataReadThread *)
constructor TDataReadThread.Create(AClient: TTCPClient; AWriteLock: TCriticalSection; AReadLock: TCriticalSection; AMonitor: TObject);
begin
  inherited Create(false);
  Priority := TThreadPriority.tpNormal;
  FreeOnTerminate := True;

  FWriteLock := AWriteLock;
  FReadLock := AReadLock;
  FMonitor  :=  AMonitor;
  FClient := AClient;
  FContext := TClientContext.Create(AClient, nil, nil);
  FContext.FClient := AClient;
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


//EIdReadTimeout

procedure TDataReadThread.Execute;
var
  FBuffer : TIdBytes;
begin
  while not Terminated do
  begin

    // waiting for response
    if FClient.IOHandler.InputBufferIsEmpty then
    begin
      FClient.IOHandler.CheckForDataOnSource(IdTimeoutInfinite); // TimeOut in milliseconds   IdTimeoutInfinite
    end;

    TMonitor.Enter(FMonitor); //FWriteLock.Enter;
    try
      //FReadLock.Enter;
      try
        if not FClient.IOHandler.InputBufferIsEmpty then
        begin
          SetLength(FBuffer, 0);
          while not FClient.IOHandler.InputBufferIsEmpty do
          begin
            // read response
            AppendByte(FBuffer, FClient.IOHandler.ReadByte);
          end;

          TThread.Synchronize(nil,
          procedure
          begin
            FClient.DoDataProcessor(FBuffer);
          end);
        end;

      finally
        //FReadLock.Leave;
      end;
    finally
     TMonitor.Exit(FMonitor); //FWriteLock.Leave;
    end;


    try
      FClient.IOHandler.CheckForDisconnect(true, false);
    except
      on E: EIdConnClosedGracefully do
      begin
        exit;
      end;
    end;


    sleep(0);

  end;
end;



(* THearBitThread *)
constructor THeartBeatThread.Create(AClient: TTCPClient; AWriteLock: TCriticalSection; AReadLock: TCriticalSection; AMonitor: TObject);
begin
  inherited Create(false);
  Priority := TThreadPriority.tpLower;
  FreeOnTerminate := True;
  FWriteLock := AWriteLock;
  FReadLock := AReadLock;
  FMonitor  :=  AMonitor;

  FClient := AClient;
  FContext := TClientContext.Create(AClient, nil, nil);
  FContext.FClient := AClient;
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


//EIdReadTimeout

procedure THeartBeatThread.Execute;
var
  FBuffer : TIdBytes;
  FBuffer1 : word;
begin
  while not Terminated do
  begin

    {try
      FClient.IOHandler.CheckForDisconnect(true, false);
    except
      on E: EIdConnClosedGracefully do
      begin
        exit;
      end;
    end;}


    TMonitor.Enter(FMonitor); //FWriteLock.Enter;
    try
      TThread.Synchronize(nil,
        procedure
        begin
          FClient.IOHandler.WriteBufferOpen;
          try
            FClient.IOHandler.Write(ToBytes(FHeartBeatRequest));
            FClient.IOHandler.WriteBufferFlush;
          finally
            FClient.IOHandler.WriteBufferClose;
          end;
        end
      );
    finally
      TMonitor.Exit(FMonitor);//FWriteLock.Leave;
    end;

    sleep(1000);
  end;
end;



{ TTCPClient}

constructor TTCPClient.Create(OnDebug: TDebugEvent = nil);
begin
  inherited Create(nil);
  FSerialNumber := 0;

  FWriteLock := TCriticalSection.Create;
  FReadLock := TCriticalSection.Create;
  FMonitor := TObject.Create;

  readtimeout:=1000;
  FOnDebug:=OnDebug;
  DoDebug('TCPClient.create');
  DoDebug(format('TCPClient.readtimeout=%d', [readtimeout]));
end;

destructor TTCPClient.Destroy;
begin
  Disconnect;
  DoDebug('TCPClient.destroy');
  FreeAndNil(FWriteLock);
  FreeAndNil(FReadLock);
  FreeAndNil(FMonitor);
  inherited Destroy;
end;

procedure TTCPClient.DoDebug(const AMsg: string);
begin
  if assigned(fOnDebug) then
    fOnDebug(self, AMsg);
end;



Procedure TTCPClient.WriteBuffer( ABuffer     : TIdBytes;
                                  AOnResponse   : TWriteBufferResponce = nil;
                                  AOnExcaption  : TExceptionProcedure = nil);
var
  FBuffer : TIdBytes;
begin
  try

    TMonitor.Enter(FMonitor); //FWriteLock.Acquire;
    try
      //FReadLock.Acquire;
      try




        TThread.Synchronize(nil,
          procedure
          begin
            IOHandler.WriteBufferOpen;
            try
              IOHandler.Write(ABuffer);
              IOHandler.WriteBufferFlush;
            finally
              IOHandler.WriteBufferClose;
            end;
          end
        );

            if assigned(AOnResponse) then
            begin
              SetLength(FBuffer, 0);

              // waiting for response
              if IOHandler.InputBufferIsEmpty then
              begin
                IOHandler.CheckForDataOnSource(waitTimeOut); // TimeOut in milliseconds
              end;

              if not IOHandler.InputBufferIsEmpty then
              begin
                while not IOHandler.InputBufferIsEmpty do
                begin
                  // read response
                  AppendByte(FBuffer, IOHandler.ReadByte);
                end;
              end;

              TThread.Synchronize(nil,
                procedure
                begin
                  AOnResponse(self, FBuffer);
                end
              );

            end;




      finally
        //FReadLock.Release;
      end;
    finally
     TMonitor.Exit(FMonitor); // FWriteLock.Release;
    end;
  except
    on E: Exception do
    begin
      if assigned(AOnExcaption) then
        AOnExcaption(self, E);
    end;
  end;
end;




  function ReverseWord(w: word): word;
  asm
     {$IFDEF CPUX64}
     mov rax, rcx
     {$ENDIF}
     xchg   al, ah
  end;

  function ReverseDWord(dw: cardinal): cardinal;
  asm
    {$IFDEF CPUX64}
    mov rax, rcx
    {$ENDIF}
    bswap eax
  end;


function ReverseBits(b : Byte) : Byte;  inline;
begin
  Result :=
    {$IFDEF WIN64}  // This is slightly better in x64 than the code in x32
    (((b * UInt64($80200802)) and UInt64($0884422110)) * UInt64($0101010101)) shr 32;
    {$ENDIF}
    {$IFDEF WIN32}
    ((b * $0802 and $22110) or (b * $8020 and $88440)) * $10101 shr 16;
    {$ENDIF}
end;

function CopyBytes(const Bytes: array of Byte): TBytes;
var
  Count: Integer;
begin
  Count := Length(Bytes);
  SetLength(Result, Count);
  if Count > 0 then
    Move(Bytes[0], Result[0], Length(Bytes));
end;

function TTCPClient.handshake: boolean;



  function InitHandShake(AHeader: byte = $02): TIdBytes;
  var
    HandShakePacket : TSPpHandShakePacket;
    FBuffer : TBytes;
  begin
    HandShakePacket := TSPpHandShakePacket.Create;
    HandShakePacket.Header := AHeader;
    HandShakePacket.CNSMode := TSPpCNSMode.m_BRIDGE;
    HandShakePacket.ID:= $6864;
    HandShakePacket.Command := $01;
    HandShakePacket.SerialNumber := 1;

    FBuffer := HandShakePacket.toBytes;
    SetLength(result, Length(FBuffer));
    move(FBuffer[0], result[0], Length(FBuffer));

  end;

var
  FBuffer : TIdBytes;
  HandShakePacket : TSPpHandShakePacket;
begin
  result:= false;
  FSerialNumber := 0;

  FBuffer:=InitHandShake;
  DoDebug('Send1: '+ ToHex(FBuffer));
  WriteBuffer(FBuffer,
    procedure(Sender: TObject; ABuffer: TIdBytes)
    begin
      DoDebug('Recive1: '+ ToHex(ABuffer));
      HandShakePacket := TSPpHandShakePacket.Create(CopyBytes(ABuffer));
      if HandShakePacket.Header=$03 then
      begin
        DoDebug(Format('HandShake OK, SN: %d', [HandShakePacket.SerialNumber]));
      end;
    end,
    procedure(Sender: TObject; E: Exception)
    begin
      DoDebug(Format('Exception1: %s', [E.Message]));
    end
  );

  FBuffer:=InitHandShake($01);
  DoDebug('Send2: '+ ToHex(FBuffer));
  WriteBuffer(FBuffer,
    nil,
    procedure(Sender: TObject; E: Exception)
    begin
      DoDebug(Format('Exception2: %s', [E.Message]));
    end
  );

  result := not (HandShakePacket.SerialNumber = 0);
end;




function TTCPClient.Assign1: boolean;
type
  TAssignBlock = packed record
    ID           : Word;
    Command      : Byte;
    Unknown      : array[0..3] of Byte;
    RCPId        : byte;
  end;

var
  FBuffer: TIdBytes;
begin



    {cmd3 := '0e08'+'6468'+'0100029000a0';
    (* handshake channel 11 *)
    cmd3 := '0e0864680100029000b0';
    cmd4 := '0f023fed0e0a64692000d9fe129000b1';
    cmd5 := '0e05646a020000';
    cmd6 := '0f023fef0e08646b2001d9fe580b';
    cmd7 := '0e0f646c300b00129000b1810082000300';
    cmd8 := '0f023ff3';  }



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

procedure TTCPClient.Connect;
begin
  inherited Connect;





  DoDebug('TCPClient.Connect');


  {TThread.CreateAnonymousThread(procedure
    begin
        handshake;
    end
  ).start;}
  if handshake then
  begin
    assign1;
  end;



  try
    FDataReadThread := TDataReadThread.Create(Self, FWriteLock, FReadLock, FMonitor);
  except
    Disconnect(True);
    raise Exception.Create('TDataReadThread.Create Error ');
  end;

  try
    FHeartBeat := THeartBeatThread.Create(Self, FWriteLock, FReadLock, FMonitor);
  except
    Disconnect(True);
    raise Exception.Create('THeartBeatThread.Create Error');
  end;


end;

procedure TTCPClient.Disconnect(ANotifyPeer: Boolean);
begin
  if Assigned(FHeartBeat) then
  begin
    FHeartBeat.Terminate;
    //FHeartBeat.WaitFor;
    //FreeAndNil(FHeartBeat);
  end;

  if Assigned(FDataReadThread) then
  begin
    FDataReadThread.Terminate;
    //FDataReadThread.WaitFor;
    //FreeAndNil(FDataReadThread);
  end;

  inherited Disconnect(ANotifyPeer);
end;




procedure TTCPClient.OnHandshakeReceived(var Msg: TDataMessage);
var
  Data : string;
begin
  data:=MSG.Data;
  //DoHandshake(Data);
end;


procedure TTCPClient.OnConnClosedGracefullyReceived(var Msg: TDataMessage);
begin
  DoDebug(Msg.Data);
  if assigned(FOnConnClosedGracefully) then
    FOnConnClosedGracefully(self);
end;

procedure TTCPClient.DoDataProcessor(const ABuffer: TIdBytes);
var
  FBuffer : TIdBytes;

  SP_0F : SP_0F_Packet;
  SP_0E : SP_0E_Packet;
begin

  (* Check empty data *)
  if Length(ABuffer)=0 then
  begin
    DoDebug('Empty data');
    exit;
  end;

  FBuffer := ABuffer;


  case FBuffer[0] of
      $09:
      begin
        //DoDebug(format('09 - %s', [ToHex(ABuffer)]));
      end;
      $03:
      begin
        DoDebug(format('03 - %s', [ToHex(FBuffer)]));
      end;
      $0E:
      begin
        TSonyProtocolHelper.Parse0E(FBuffer,
          procedure(Sender: TObject; Data: SP_0E_Packet)
          begin
            ;
          end,
          procedure(Sender: TObject; E: Exception)
          begin
            ;
          end
        );



        DoDebug(format('0E - %s', [ToHex(FBuffer)]));
      end;
      $0F:
      begin
        DoDebug(format('  0F - %s', [ToHex(FBuffer)]));
        TSonyProtocolHelper.Parse0F(FBuffer,
          procedure(Sender: TObject; Data: SP_0F_Packet)
          begin
            DoDebug(format(' -0F - %s', [ToHex(Data.Data.NextBlock.Data)]));
          end,
          procedure(Sender: TObject; E: Exception)
          begin
            ;
          end
        );

      end;
      else
        begin
          DoDebug(format('?? - %s', [ToHex(FBuffer)]));
        end;
  end;





  DoOnDataAvailable(ABuffer);
end;


procedure TTCPClient.DoOnDataAvailable(const ABuffer: TIdBytes);
begin
  if Assigned(FOnDataAvailable) then
    OnDataAvailable(Self, ABuffer);


end;


END.