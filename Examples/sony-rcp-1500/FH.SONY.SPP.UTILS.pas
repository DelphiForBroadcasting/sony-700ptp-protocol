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

unit FH.SONY.SPP.UTILS;


interface

uses
  System.SysUtils,
  System.Types,
  System.Classes,
  IdGlobal;


type
  TSPpMicrophoneGain = record
  strict private

  public
    class function Raw2Value(const ARaw: byte): integer; static;
    class function Value2Raw(const AValue: integer): byte; static;
  end;

type
  TSPpUTILS = record
  strict private

  public
    class function RcpIdToRaw(ARcpId : byte; AEnabled: boolean; ASwap : boolean = false): word;  static;
    class function Swap2(const w: word): word; static;
    class function Swap4(dw: cardinal): cardinal; static;
    class function CopyBytes(const Bytes: array of Byte): TBytes; overload; static;
    class function CopyBytes(const Bytes: TArray<System.byte> ): TIdBytes; overload; static;
    class procedure AppendByte(var VBytes: TArray<System.byte>; const AByte: Byte); overload; static;
    class procedure AppendBytes(var ToBytes: TArray<System.byte>; const FromByte: TArray<System.byte>); overload; static;
  end;

implementation

class function TSPpMicrophoneGain.Raw2Value(const ARaw: byte): integer;
begin
  result := 0;
  case ARaw of
    $20:  result := 20;
    $1F:  result := 30;
    $1E:  result := 40;
    $1D:  result := 50;
    $1C:  result := 60;
  end;
end;

class function TSPpMicrophoneGain.Value2Raw(const AValue: integer): byte;
begin
  result := 0;
  case AValue of
    20:  result := $20;
    30:  result := $1F;
    40:  result := $1E;
    50:  result := $1D;
    60:  result := $1C;
  end;
end;




class function TSPpUTILS.RcpIdToRaw(ARcpId : byte; AEnabled: boolean; ASwap : boolean = false): word;
var
  LRes  : word;
begin
  LRes := word(AEnabled) and $FFFF;
  LRes := LRes +(ARcpId Shl 4) and $FFFF;
  if ASwap then
    result:= TSPpUTILS.Swap2(LRes)
  else
    result := LRes;
end;

class function TSPpUTILS.Swap2(const w: word): word;
{$IFDEF ASSEMBLER}
asm
  {$IFDEF CPUX64}
  mov rax, rcx
  {$ENDIF}
  xchg   al, ah
{$ELSE}
begin
  result := System.Swap(w);
{$ENDIF}
end;


class function TSPpUTILS.Swap4(dw: cardinal): cardinal;
{$IFDEF ASSEMBLER}
asm
  {$IFDEF CPUX64}
  mov rax, rcx
  {$ENDIF}
  bswap eax
{$ELSE}
begin
  result := System.Swap(dw);
{$ENDIF}
end;


class function TSPpUTILS.CopyBytes(const Bytes: array of Byte): TBytes;
var
  Count: Integer;
begin

  Count := Length(Bytes);
  SetLength(Result, Count);
  if Count > 0 then
    Move(Bytes[0], Result[0], Length(Bytes));
end;

class function TSPpUTILS.CopyBytes(const Bytes: TArray<System.byte> ): TIdBytes;
var
  Count: Integer;
begin
  Count := Length(Bytes);
  SetLength(Result, Count);
  if Count > 0 then
    Move(Bytes[0], Result[0], Length(Bytes));
end;

class procedure TSPpUTILS.AppendByte(var VBytes: TArray<System.byte>; const AByte: Byte);
var
  LOldLen: Integer;
begin
  LOldLen := Length(VBytes);
  SetLength(VBytes, LOldLen + 1);
  VBytes[LOldLen] := AByte;
end;

class procedure TSPpUTILS.AppendBytes(var ToBytes: TArray<System.byte>; const FromByte: TArray<System.byte>);
var
  LOldLen: Integer;
begin
  LOldLen := Length(ToBytes);
  SetLength(ToBytes, LOldLen + length(FromByte));
  move(FromByte[0], ToBytes[LOldLen], length(FromByte));
end;

end.