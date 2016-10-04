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

unit FH.SONY.SPP.PACKET;


interface

uses
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
  System.Generics.Defaults,
  System.Generics.Collections,
  IdGlobal,
  FH.SONY.SPP.UTILS;


{$MINENUMSIZE 1}

Type
  TSPpCNSMode = (
    m_LEGACY  = $00,
    m_BRIDGE  = $01,
    m_MCS     = $02
  );

  TSPpPacketType = (pt_Unknown, pt_HandShake, pt_Assign, pt_Response, pt_Request, pt_Notify, pt_Error, pt_HeartBeat);


const
  cResponseHeader : byte = $0F;
  cRequestHeader  : byte = $0E;

Type
(*********************************************)
  TSPpBasicPacket = class
  strict private
    FRAWPacket  : TBytes;
    FHeader     : Byte;
    FSize       : Byte;
    FRawData    : TBytes;
    FNextPacket : TSPpBasicPacket;
    FPacketType : TSPpPacketType;

    procedure SetHeader(value: byte);
    procedure SetRawData(value: TBytes);
    procedure SetSize(value: byte);
    function GetSize: byte;
  protected
    procedure Parse; virtual;

    function GetNextPacket: TSPpBasicPacket; virtual;
    procedure SetNextPacket(APacket: TSPpBasicPacket);  virtual;

  public
    constructor Create(const ARAWPacket: TBytes = nil); overload;
    destructor Destroy; override;

    function GetPacketSize: cardinal;

    Function ToBytes: TBytes; virtual;
    Function ToIdBytes : TIdBytes;

    property Header     : Byte            read  FHeader       write SetHeader;
    property Size       : Byte            read  GetSize       write SetSize;
    property RawData    : TBytes          read  FRawData      write SetRawData;
    property NextPacket1: TSPpBasicPacket read  FNextPacket   write FNextPacket;
    property NextPacket : TSPpBasicPacket read  GetNextPacket write SetNextPacket;

    property PacketType : TSPpPacketType  read  FPacketType;
  end;


(*********************************************)
  TSPpHandShakePacket  = class(TSPpBasicPacket)
  const
    cUnknownPos      = 0;
    cCNSModePos      = 3;
    cIdPos           = 4;
    cUnknown1Pos     = 6;
    cSerialNumberPos = 10;
    cUnknown2Pos     = 14;
  strict private

  private
    procedure Parse; override;

    function GetCNSMode: TSPpCNSMode;
    procedure SetCNSMode(value: TSPpCNSMode);
    procedure SetID(value: word);
    function GetID: word;
    procedure SetSerialNumber(value: cardinal);
    function GetSerialNumber: cardinal;
    function GetUnknown: TBytes;
    procedure SetUnknown(value: TArray<System.Byte>);
    function GetUnknown1: TBytes;
    procedure SetUnknown1(value: TArray<System.Byte>);
    function GetUnknown2: TBytes;
    procedure SetUnknown2(value: TArray<System.Byte>);

  public
    constructor Create(const ARAWPacket: TBytes = nil); overload;
    destructor Destroy; override;

    class function InitHandShake(AHeader: byte; ACNSMode: TSPpCNSMode; ARequestID: word; ASerialNumber: cardinal): TSPpHandShakePacket; static;

    Function ToBytes : TBytes; //override;
    property Unknown      : TBytes        read GetUnknown       write SetUnknown;
    property Unknown1     : TBytes        read GetUnknown1      write SetUnknown1;
    property Unknown2     : TBytes        read GetUnknown2      write SetUnknown2;
    property CNSMode      : TSPpCNSMode   read GetCNSMode       write SetCNSMode;  (* $00 = legacy; $01 = bridge; $02 = MCS *)
    property ID           : Word          read GetID            write SetID;
    property SerialNumber : cardinal      read GetSerialNumber  write SetSerialNumber;
  end;

(*********************************************)
  TSPpHeartBeatPacket  = class(TSPpBasicPacket)
    strict private
    public
  end;

(*********************************************)
  TSPpNotifyPacket  = class(TSPpBasicPacket)
    strict private
    public
  end;

(*********************************************)
  TSPpRequestPacket  = class(TSPpBasicPacket)
  const
    cIdPos           = 0;
    cCommandCodePos  = 2;
    cBlockPos        = 3;
  strict private

  private
    procedure SetID(value: word);
    function GetID: word;
    procedure SetCommandCode(value: byte);
    function GetCommandCode: byte;

    procedure Parse; override;
  public
    constructor Create(const ARAWPacket: TBytes = nil); overload;
    destructor Destroy; override;
    Function ToBytes : TBytes; //override;

    procedure SetBlock(ARawData: TArray<System.Byte>);
    procedure GetBlock(var ARawData: TBytes);
    function GetBlockSize: cardinal;

    property ID           : Word    read GetID           write SetID;
    property CommandCode  : byte    read GetCommandCode  write SetCommandCode;

  end;

(*********************************************)
  TSPpResponsePacket  = class(TSPpBasicPacket)
  const
    cIdPos           = 0;
  strict private

  private
    procedure SetID(value: word);
    function GetID: word;

    procedure Parse; override;

    function GetNextPacket: TSPpRequestPacket; overload;
    procedure SetNextPacket(APacket: TSPpRequestPacket); overload;
  public
    constructor Create(const ARAWPacket: TBytes = nil); overload;
    destructor Destroy; override;
    Function ToBytes : TBytes; override;

    property ID           : Word              read GetID          write SetID;
    property NextPacket   : TSPpRequestPacket read GetNextPacket  write SetNextPacket;
  end;


(*********************************************)
  TSPpPair = record
    Key       : TBytes;
    Value     : TBytes;
    class function Create(const AKey: TArray<System.Byte>; const AValue: TArray<System.Byte>): TSPpPair; static;
    function ToBytes: TBytes;
  end;

  TSPpPairComparer = class(TComparer<TSPpPair>)
    public
      function Compare(const Left, Right : TSPpPair) : integer; override;
    end;

  TSPpDataParser = class
  strict private
    FBuffer     : TBytes;

    FUnknown    : packed record
                    Unknown   : word;
                    CCUNum    : byte;
                    Unknown1  : byte;
                  end;
    FUnknown1   : packed record
                    Unknown   : word;
                    CCUNum    : byte;
                    Unknown1  : byte;
                  end;

    FSize       : word;
    FRawPairs   : TBytes;
    FPairs      : TList<TSPpPair>;
    FResponse   : TSPpDataParser;

    procedure SetSize(value: word);
    function GetSize: word;
    procedure ParsePairs;
  protected
    procedure Parse; virtual;
  public
    constructor Create(const ABuffer: TBytes = nil); overload;
    destructor Destroy; override;

    property Pairs      : TList<TSPpPair> read FPairs write FPairs;

    Function ToBytes: TBytes; virtual;
    Function ToIdBytes : TIdBytes;
    property Response : TSPpDataParser read FResponse write FResponse;
  end;

implementation

constructor TSPpBasicPacket.Create(const ARAWPacket: TBytes = nil);
begin
  inherited Create;
  FNextPacket := nil;


  if assigned(ARAWPacket) then
  begin
    SetLength(FRAWPacket, Length(ARAWPacket));
    Move(ARAWPacket[0], FRAWPacket[0], Length(ARAWPacket));
    Parse;
  end;
end;

destructor TSPpBasicPacket.Destroy;
begin
  if Assigned(FNextPacket) then FNextPacket.Destroy;
  SetLength(FRAWPacket, 0);
  SetLength(FRawData, 0);
  inherited Destroy;
end;

function TSPpBasicPacket.GetPacketSize: cardinal;
var
  FRawSize  : cardinal;
begin
  FRawSize := 0;
  FRawSize := SizeOF(FHeader)+SizeOF(FSize)+Length(FRawData);

  if assigned(FNextPacket) and (FPacketType = pt_Response) then
    FRawSize := FRawSize+FNextPacket.GetPacketSize;

  result := FRawSize;
end;

Function TSPpBasicPacket.ToBytes: TBytes;
var
  FRawSize   : cardinal;
  FCurPos : cardinal;
  FRawNextPacket  : TBytes;
begin

  FRawSize :=GetPacketSize;

  SetLength(Result, FRawSize);

  if FSize <> Length(FRawData) then FSize := Length(FRawData);

  FCurPos:=0;
  move(FHeader, Result[FCurPos], sizeOf(FHeader));
  inc(FCurPos, sizeOf(FHeader));

  move(FSize, Result[FCurPos], sizeOf(FSize));
  inc(FCurPos, sizeOf(FSize));

  move(FRawData[0], Result[FCurPos], Length(FRawData));
  inc(FCurPos, +Length(FRawData));


  if assigned(FNextPacket) and (FPacketType = pt_Response) then
  begin
    FRawNextPacket := FNextPacket.ToBytes;
    move(FRawNextPacket[0], Result[FCurPos], Length(FRawNextPacket));
    inc(FCurPos, +Length(FRawNextPacket));
  end;

end;

Function TSPpBasicPacket.ToIdBytes : TIdBytes;
var
  ABuffer : TBytes;
begin
  ABuffer := Self.ToBytes;
  SetLength(Result, Length(ABuffer));
  move(ABuffer[0], Result[0], Length(ABuffer));
end;

procedure TSPpBasicPacket.SetHeader(value: byte);
begin
  FHeader :=  Value;

  case FHeader of
    $01, $02, $03 : FPacketType := pt_HandShake;
    $08, $09      : FPacketType := pt_HeartBeat;
    $0A, $0B      : FPacketType := pt_Notify;
    $0F           : FPacketType := pt_Response;
    $0E           : FPacketType := pt_Request;
    $0D           : FPacketType := pt_Error;
    else FPacketType := pt_Unknown;
  end;
end;

procedure TSPpBasicPacket.SetSize(value: byte);
begin
  FSize :=  value;
  SetLength(FRawData, FSize);
end;

function TSPpBasicPacket.GetSize: byte;
begin
  result := FSize;
end;

procedure TSPpBasicPacket.SetRawData(value: TBytes);
begin
  SetSize(Length(value));
  move(value[0], FRawData[0], Length(value));
end;

procedure TSPpBasicPacket.Parse;
var
  FRawSize        : cardinal;
  FRawNextPacket  : TBytes;
  FPacketSize     : cardinal;
begin
  FRawSize := Length(FRAWPacket);
  if FRawSize = 0 then raise Exception.Create('RAW Packet is empty');

  SetHeader(FRAWPacket[0]);

  SetSize(FRAWPacket[1]);

  Move(FRAWPacket[2], FRawData[0], FSize);

  FPacketSize := GetPacketSize;

  if Length(FRAWPacket) > FPacketSize then
  begin
    SetLength(FRawNextPacket, FRawSize - (FPacketSize));
    Move(FRAWPacket[FPacketSize],  FRawNextPacket[0], length(FRawNextPacket));
    FNextPacket := TSPpBasicPacket.Create(FRawNextPacket);
  end;
end;

function TSPpBasicPacket.GetNextPacket: TSPpBasicPacket;
begin
  result := FNextPacket;
end;

procedure TSPpBasicPacket.SetNextPacket(APacket: TSPpBasicPacket);
begin
  FNextPacket := APacket;
end;


(*************  TSPpControlPacket  ****************)
constructor TSPpRequestPacket.Create(const ARAWPacket: TBytes = nil);
begin
  inherited Create(ARAWPacket);

  if not assigned(ARAWPacket) then
  begin
    Header := cRequestHeader;
    Size  :=  3;
    CommandCode := 0;
  end;

end;

destructor TSPpRequestPacket.Destroy;
begin
  inherited Destroy;
end;

Function TSPpRequestPacket.toBytes : TBytes;
begin
  result := inherited toBytes;
end;

procedure TSPpRequestPacket.Parse;
var
  FRawSize  : cardinal;
  FCurPos   : cardinal;
begin
  inherited Parse;
  if ((Header <> $0F) and (Header <> $0E)) then  raise Exception.Create('Packet not control');
  if Size <> Length(RawData) then  raise Exception.Create('Incorect block size');
end;


function TSPpRequestPacket.GetID: word;
begin
  result := 0;
  if Size > cIdPos then
    result := TSPpUTILS.Swap2(PWord(@Self.RawData[cIdPos])^);
end;

procedure TSPpRequestPacket.SetID(value: word);
begin
  PWord(@Self.RawData[cIdPos])^ := value;
end;

procedure TSPpRequestPacket.SetCommandCode(value: byte);
begin
  Self.RawData[cCommandCodePos] := value;
end;

function TSPpRequestPacket.GetCommandCode: byte;
begin
  result := 0;
  if Size > cCommandCodePos then
    result := Self.RawData[cCommandCodePos];
end;


procedure TSPpRequestPacket.SetBlock(ARawData: TArray<System.Byte>);
begin
  move(ARawData[0], Self.RawData[cBlockPos], Length(ARawData));
end;

procedure TSPpRequestPacket.GetBlock(var ARawData: TBytes);
var
  FBlockSize : integer;
begin
  FBlockSize := GetBlockSize;
  SetLength(ARawData, FBlockSize);
  move(Self.RawData[cBlockPos], ARawData[0], FBlockSize);
end;

function TSPpRequestPacket.GetBlockSize: cardinal;
var
  LRawDataCount : integer;
begin
  result := 0;
  LRawDataCount := Length(Self.RawData);
  if LRawDataCount>=cBlockPos then
    result := LRawDataCount - cBlockPos;
end;


(**************************************************************)
constructor TSPpHandShakePacket.Create(const ARAWPacket: TBytes = nil);
begin
  inherited Create(ARAWPacket);

  if not assigned(ARAWPacket) then
  begin
    Size := 18;
    SetUnknown([$02, $01, $00]);
    SetUnknown1([$01, $90, $90, $0a]);
    SetUnknown2([$64, $32, $0a, $05]);
  end;

end;

destructor TSPpHandShakePacket.Destroy;
begin
  inherited Destroy;
end;

class function TSPpHandShakePacket.InitHandShake(AHeader: byte; ACNSMode: TSPpCNSMode; ARequestID: word; ASerialNumber: cardinal): TSPpHandShakePacket;
var
  AHandShakePacket : TSPpHandShakePacket;
begin
  result := nil;
  AHandShakePacket := TSPpHandShakePacket.Create;
  try
    AHandShakePacket.Header := AHeader;
    AHandShakePacket.CNSMode := ACNSMode;
    AHandShakePacket.ID:= ARequestID;
    AHandShakePacket.SerialNumber := ASerialNumber;
  finally
    result :=  AHandShakePacket;
  end;
end;

Function TSPpHandShakePacket.toBytes : TBytes;
begin
  result := inherited toBytes;
end;

procedure TSPpHandShakePacket.Parse;
var
  FRawSize  : cardinal;
  FCurPos   : cardinal;
begin
  inherited Parse;

  if Size <> 18 then  raise Exception.Create('Packet not handshake');
  if Size <> Length(RawData) then  raise Exception.Create('Incorect block size');

end;

function TSPpHandShakePacket.GetCNSMode: TSPpCNSMode;
begin
  result := TSPpCNSMode.m_LEGACY;
  if Size > cCNSModePos then
    result := TSPpCNSMode(Self.RawData[cCNSModePos]);
end;

procedure TSPpHandShakePacket.SetCNSMode(value: TSPpCNSMode);
begin
  Self.RawData[cCNSModePos] := Byte(value) and $FF;;
end;


function TSPpHandShakePacket.GetID: word;
begin
  result := 0;
  if Size > cIdPos then
    result := TSPpUTILS.Swap2(PWord(@Self.RawData[cIdPos])^);
end;

procedure TSPpHandShakePacket.SetID(value: word);
begin
  PWord(@Self.RawData[cIdPos])^ := TSPpUTILS.Swap2(value);
end;

procedure TSPpHandShakePacket.SetSerialNumber(value: cardinal);
begin
  PCardinal(@Self.RawData[cSerialNumberPos])^ := TSPpUTILS.Swap4(value);
end;

function TSPpHandShakePacket.GetSerialNumber: cardinal;
begin
  result := 0;
  if Size > cSerialNumberPos then
    result := TSPpUTILS.Swap4(PCardinal(@Self.RawData[cSerialNumberPos])^);
end;

procedure TSPpHandShakePacket.SetUnknown(value: TArray<System.Byte>);
begin
  if length(value) = 3 then
    move(value[0],  Self.RawData[cUnknownPos], 3);
end;

function TSPpHandShakePacket.GetUnknown: TBytes;
begin
  SetLength(result, 0);
  if Size > cUnknownPos then
  begin
    SetLength(result, 3);
    move(Self.RawData[cUnknownPos], result[0], 3);
  end;
end;

procedure TSPpHandShakePacket.SetUnknown1(value: TArray<System.Byte>);
begin
  if length(value) = 4 then
    move(value[0],  Self.RawData[cUnknown1Pos], 4);
end;

function TSPpHandShakePacket.GetUnknown1: TBytes;
begin
  SetLength(result, 0);
  if Size > cUnknown1Pos then
  begin
    SetLength(result, 4);
    move(Self.RawData[cUnknown1Pos], result[0], 4);
  end;
end;

procedure TSPpHandShakePacket.SetUnknown2(value: TArray<System.Byte>);
begin
  if length(value) = 4 then
    move(value[0],  Self.RawData[cUnknown2Pos], 4);
end;

function TSPpHandShakePacket.GetUnknown2: TBytes;
begin
  SetLength(result, 0);
  if Size > cUnknown2Pos then
  begin
    SetLength(result, 4);
    move(Self.RawData[cUnknown2Pos], result[0], 4);
  end;
end;


(*************  TSPpResponsePacket  ****************)
constructor TSPpResponsePacket.Create(const ARAWPacket: TBytes = nil);
begin
  inherited Create(ARAWPacket);

  if not assigned(ARAWPacket) then
  begin
    Header := cResponseHeader;
    Size  :=  2;
  end;

end;

destructor TSPpResponsePacket.Destroy;
begin
  inherited Destroy;
end;

Function TSPpResponsePacket.toBytes : TBytes;
begin
  result := inherited toBytes;
end;

procedure TSPpResponsePacket.Parse;
var
  FRawSize  : cardinal;
  FCurPos   : cardinal;
begin
  inherited Parse;
  if (Header <> $0F) then  raise Exception.Create('Packet not response');
  if Size <> Length(RawData) then  raise Exception.Create('Incorect block size');
end;

function TSPpResponsePacket.GetID: word;
begin
  result := 0;
  if Size > cIdPos then
    result := TSPpUTILS.Swap2(PWord(@Self.RawData[cIdPos])^);
end;

procedure TSPpResponsePacket.SetID(value: word);
begin
  PWord(@Self.RawData[cIdPos])^ := value;
end;


function TSPpResponsePacket.GetNextPacket: TSPpRequestPacket;
var
  FBasicPacket : TSPpBasicPacket;
begin
  FBasicPacket := inherited GetNextPacket;
  result := TSPpRequestPacket(FBasicPacket);
end;

procedure TSPpResponsePacket.SetNextPacket(APacket: TSPpRequestPacket);
begin
  inherited SetNextPacket(APacket as TSPpBasicPacket);
end;

(*----------------------------------------------------------*)
class function TSPpPair.Create(const AKey: TArray<System.Byte>; const AValue: TArray<System.Byte>): TSPpPair;
begin
  Result.Key := AKey;
  Result.Value := AValue;
end;

function TSPpPair.ToBytes: TBytes;
begin
  setLength(result, Length(Key)+Length(value));
  move(Key[0], result[0], Length(Key));
  move(value[0], result[Length(Key)], Length(value));
end;

(*----------------------------------------------------------*)
function TSPpPairComparer.Compare(const Left, Right: TSPpPair): integer;
begin
  result := -1;
  if ((Length(Left.Key) = Length(Right.Key)) and CompareMem(@Left.Key[0], @Right.Key[0], Length(Left.Key))) and
  ((Length(Left.value) = Length(Right.value)) and CompareMem(@Left.value[0], @Right.value[0], Length(Left.value)))  then
  begin
    result := 0;
  end;
end;

(*----------------------------------------------------------*)
constructor TSPpDataParser.Create(const ABuffer: TBytes = nil);
begin
  inherited Create;

  FResponse := nil;
  FPairs := TList<TSPpPair>.Create(TSPpPairComparer.Create);
  if assigned(ABuffer) then
  begin
    SetLength(FBuffer, Length(ABuffer));
    Move(ABuffer[0], FBuffer[0], Length(ABuffer));
    Parse;
  end;
end;

destructor TSPpDataParser.Destroy;
begin
  if assigned(FResponse) then FreeAndNil(FResponse);  
  SetLength(FBuffer, 0);
  FPairs.Clear;
  FreeAndNil(FPairs);
  inherited Destroy;
end;



Function TSPpDataParser.ToBytes: TBytes;
var
  i         : integer;
  LRawPairs : TBytes;
  LCurPos   : integer;
begin
  for I := 0 to FPairs.Count-1 do
    TSPpUTILS.AppendBytes(LRawPairs, FPairs.Items[i].ToBytes);

  setLength(result, sizeof(FUnknown)+sizeof(FUnknown1)+sizeof(FSize)+ length(LRawPairs));
  LCurPos := 0;

  move(FUnknown, result[LCurPos], sizeof(FUnknown));
  inc(LCurPos, sizeof(FUnknown));

  move(FUnknown1, result[LCurPos], sizeof(FUnknown1));
  inc(LCurPos, sizeof(FUnknown1));

  pWord(@result[LCurPos])^ := TSPpUTILS.Swap2(FSize);
  inc(LCurPos, sizeof(FSize));

  move(LRawPairs[0], result[LCurPos], length(LRawPairs));
  inc(LCurPos, length(LRawPairs));
end;

Function TSPpDataParser.ToIdBytes : TIdBytes;
var
  ABuffer : TBytes;
begin
  ABuffer := Self.ToBytes;
  SetLength(Result, Length(ABuffer));
  move(ABuffer[0], Result[0], Length(ABuffer));
end;


procedure TSPpDataParser.ParsePairs;
var
  LCurPos : integer;
begin

  LCurPos := 0;

  repeat

    if  (FRawPairs[LCurPos] = $20) or
        (FRawPairs[LCurPos] = $21) or
        (FRawPairs[LCurPos] = $40) or
        (FRawPairs[LCurPos] = $41) then
    begin
      FPairs.Add(TSPpPair.Create([FRawPairs[LCurPos],FRawPairs[LCurPos+1]],[FRawPairs[LCurPos+2]]));
      inc(LCurPos, 3);
    end else
    if  (FRawPairs[LCurPos] = $22) or
        (FRawPairs[LCurPos] = $23) or
        (FRawPairs[LCurPos] = $42) or
        (FRawPairs[LCurPos] = $43) then
    begin
      FPairs.Add(TSPpPair.create([FRawPairs[LCurPos],FRawPairs[LCurPos+1]],[FRawPairs[LCurPos+2],FRawPairs[LCurPos+3]]));
      inc(LCurPos, 4);
    end else
    begin
      inc(LCurPos);
    end;

  until length(FRawPairs) <= LCurPos;

end;

procedure TSPpDataParser.Parse;
var
  FRawSize        : cardinal;
  FRawNextPacket  : TBytes;
  FPacketSize     : cardinal;
begin
  FRawSize := Length(FBuffer);
  if FRawSize = 0 then raise Exception.Create('RAW Packet is empty');

  if FRawSize>=4 then
  begin
    move(FBuffer[0], self.FUnknown, sizeof(self.FUnknown));
  end;

  if FRawSize>=8 then
  begin
    move(FBuffer[4], self.FUnknown1, sizeof(self.FUnknown1));
  end;

  SetSize(TSPpUTILS.Swap2(pWord(@FBuffer[8])^));

  if length(FRawPairs)>0 then
  begin
    move(FBuffer[10], FRawPairs[0], Length(FRawPairs));
    ParsePairs;
  end;

end;

procedure TSPpDataParser.SetSize(value: word);
begin
  FSize :=  value;
  SetLength(FRawPairs, FSize);
end;

function TSPpDataParser.GetSize: word;
begin
  result := FSize;
end;


end.
