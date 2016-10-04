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

unit FH.SONY.SPP.COMMANDHANDLERS;


interface

uses
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
  System.Generics.Defaults,
  System.Generics.Collections,
  IdGlobal,
  FH.SONY.SPP.UTILS,
  FH.SONY.SPP.PACKET,
  FH.SONY.SPP.COMMANDADDR;

type
  TSPpCommand = class;
  TSPpCommandHandler = class;
  TSPpCommandHandlers = class;

  (* Events *)
  TSPpCommandEvent = reference to procedure(ASender: TSPpCommand);

  TSPpCommand = class(TObject)
  protected
    FCommandHandler : TSPpCommandHandler;
    FDisconnect     : Boolean;
    FBasicPacket    : TSPpBasicPacket;
    //
    procedure DoCommand; virtual;
  public
    constructor Create(AOwner: TSPpCommandHandler); virtual;
    destructor Destroy; override;
    //
    property CommandHandler: TSPpCommandHandler read FCommandHandler;
    property Disconnect: Boolean read FDisconnect write FDisconnect;
    property BasicPacket: TSPpBasicPacket read FBasicPacket;
  end;


  TSPpCommandHandlerComparer = class(TComparer<TBytes>)
  public
    function Compare(const Left, Right : TBytes) : integer; override;
  end;

  TSPpCommandHandler = class(TCollectionItem)
  protected
    FName           : string;
    FCommands       : TList<TBytes>;
    FDescription    : TStrings;
    FOnCommand      : TSPpCommandEvent;
    FTag            : integer;
    FDisconnect     : boolean;

    procedure SetDescription(AValue: TStrings);
  public
    procedure DoCommand(const AData: TBytes; ABasicPacket: TSPpBasicPacket); virtual;
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
    function Compare(const ACommand: TBytes; ABasicPacket: TSPpBasicPacket): boolean;
  published
    property Commands: TList<TBytes> read FCommands write FCommands;
    property Description: TStrings read FDescription write SetDescription;
    property Disconnect: boolean read FDisconnect write FDisconnect;

    property OnCommand: TSPpCommandEvent read FOnCommand write FOnCommand;
    property Name : string read FName write FName;
  end;

  TSPpCommandHandlerClass = class of TSPpCommandHandler;

  TSPpCommandHandlers = class(TOwnedCollection)
    protected
      function GetItem(AIndex: Integer): TSPpCommandHandler;
      procedure SetItem(AIndex: Integer; const AValue: TSPpCommandHandler);
    public
      constructor Create(ACommandHandlerClass: TSPpCommandHandlerClass = nil); reintroduce;

      function HandleCommand(ABasicPacket: TSPpBasicPacket; const VCommand: TArray<System.Byte>): Boolean; virtual;

      function Add: TSPpCommandHandler;
      property Items[AIndex: Integer]: TSPpCommandHandler read GetItem write SetItem;
  end;

implementation




constructor TSPpCommand.Create(AOwner: TSPpCommandHandler);
begin
  inherited Create;
  //FReply := AOwner.FReplyClass.CreateWithReplyTexts(nil, TIdCommandHandlers(AOwner.Collection).ReplyTexts);
  FCommandHandler := AOwner;
  FDisconnect := AOwner.Disconnect;
end;

destructor TSPpCommand.Destroy;
begin
  inherited Destroy;
end;

procedure TSPpCommand.DoCommand;
begin
  if Assigned(CommandHandler.OnCommand) then begin
    CommandHandler.OnCommand(Self);
  end;
end;

(* TCommandHandlers *)
constructor TSPpCommandHandlers.Create(ACommandHandlerClass: TSPpCommandHandlerClass = nil);
begin
  if ACommandHandlerClass = nil then begin
    ACommandHandlerClass := TSPpCommandHandler;
  end;
  inherited Create(nil, ACommandHandlerClass);
end;

function TSPpCommandHandlers.Add: TSPpCommandHandler;
begin
  Result := TSPpCommandHandler(inherited Add);
end;

function TSPpCommandHandlers.GetItem(AIndex: Integer): TSPpCommandHandler;
begin
  Result := TSPpCommandHandler(inherited Items[AIndex]);
end;

procedure TSPpCommandHandlers.SetItem(AIndex: Integer; const AValue: TSPpCommandHandler);
begin
  inherited SetItem(AIndex, AValue);
end;


function TSPpCommandHandlers.HandleCommand(ABasicPacket: TSPpBasicPacket; const VCommand: TArray<System.Byte>): Boolean;
var
  i, j: Integer;
begin
  j := Count - 1;
  Result := False;
  //DoBeforeCommandHandler(AContext, VCommand);
  try
    i := 0;
    while i <= j do
    begin
      Result := Items[i].Compare(VCommand, ABasicPacket);
      if Result then
      begin
        Break;
      end;

      Inc(i);
    end;
  finally
    //DoAfterCommandHandler(AContext);
  end;
end;

(* TSPpCommandHandler *)
function TSPpCommandHandlerComparer.Compare(const Left, Right: TBytes): integer;
begin
  result := -1;
  if (Length(Left) = Length(Right)) and CompareMem(Left, Right, Length(Left)) then
  begin
    Result := 0;
  end;
end;

(* TSPpCommandHandler *)
constructor TSPpCommandHandler.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);

  //FReplyClass := TCommandHandlers(ACollection).ReplyClass;

  FCommands := TList<TBytes>.Create(TSPpCommandHandlerComparer.Create);

  FDescription := TStringList.Create;
end;

destructor TSPpCommandHandler.Destroy;
begin
  FreeAndNil(FCommands);
  FreeAndNil(FDescription);
  inherited Destroy;
end;

function TSPpCommandHandler.Compare(const ACommand: TBytes; ABasicPacket: TSPpBasicPacket): boolean;
begin
  Result := false;
  if FCommands.Contains(ACommand) then
  begin
    DoCommand(ACommand, ABasicPacket);
    Result := true;
  end;
end;

procedure TSPpCommandHandler.SetDescription(AValue: TStrings);
begin
  FDescription.Assign(AValue);
end;


procedure TSPpCommandHandler.DoCommand(const AData: TBytes; ABasicPacket: TSPpBasicPacket);
var
  LCommand: TSPpCommand;
begin
  LCommand := TSPpCommand.Create(Self);
  try
    LCommand.FBasicPacket := ABasicPacket;
    // RLebeau 2/21/08: for the IRC protocol, RFC 2812 section 2.4 says that
    // clients are not allowed to issue numeric replies for server-issued
    // commands.  Added the PerformReplies property so TIdIRC can specify
    // that behavior.
    {if Collection is TIdCommandHandlers then begin
      LCommand.PerformReply := TIdCommandHandlers(Collection).PerformReplies;
    end; }
    try
      LCommand.DoCommand;
    except
      ;
    end;

  finally
    try
      {if LCommand.Disconnect then begin
        AContext.Connection.Disconnect;
      end;}
    finally
      LCommand.Free;
    end;
  end;
end;

end.
