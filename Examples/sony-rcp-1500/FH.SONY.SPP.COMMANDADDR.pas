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

unit FH.SONY.SPP.COMMANDADDR;


interface

uses
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
  System.Generics.Defaults,
  System.Generics.Collections,
  IdGlobal;


type
  TSPpKeyAddr = record
    Name        : string;
    Description : string;
    AddrReq     : TBytes;
    AddrRes     : TBytes;
    class function Create(AName: string; ADescription: string; AAddrReq: TArray<System.Byte>; AAddrRes: TArray<System.Byte>): TSPpKeyAddr; static;
  end;

  type
    TSPpCommandsHelper = class(TDictionary<string, TSPpKeyAddr>)
    public
      constructor Create; overload;
      procedure Initialization_;
    end;

implementation

class function TSPpKeyAddr.Create(AName: string; ADescription: string; AAddrReq: TArray<System.Byte>; AAddrRes: TArray<System.Byte>): TSPpKeyAddr;
begin
  result.Name := AName;
  result.Description := ADescription;
  result.AddrReq := AAddrReq;
  result.AddrRes := AAddrRes;
end;

constructor TSPpCommandsHelper.Create;
begin
  inherited create;
  Initialization_;
end;

procedure TSPpCommandsHelper.Initialization_;
begin
//---
  self.Add('::BUTTON::PARA',
    TSPpKeyAddr.Create('::BUTTON::PARA',
      'This is the PARA function button. It allows you to simultaneously control the '
      +'control panels that are active. However, IRIS and master black are only enabled '
      +'on control panels on which IRIS/MB is active, and cannot be controlled '
      +'simultaneously',
      [], [])
  );

//---
  self.Add('::BUTTON::BARS',
    TSPpKeyAddr.Create('::BUTTON::BARS',
      'Color bar signal',
      [$40, $10], [$41, $10])
  );

//---
  self.Add('::BUTTON::TEST',
    TSPpKeyAddr.Create('::BUTTON::TEST',
      'Camera test signal',
      [], [])
  );

//---
  self.Add('::BUTTON::CLOSE',
    TSPpKeyAddr.Create('::BUTTON::CLOSE',
      'This button is for closing the iris of the lens connected to the camera.',
      [$20, $83], [$21, $83])
  );

//---
  self.Add('::BUTTON::CAMPW',
    TSPpKeyAddr.Create('::BUTTON::CAMPW',
      'This button is for supplying power from the CCU to the camera heads.'
      +'On: The power is being supplied.'
      +'Off: The power is disconnected. It is not supplied even if the button is pressed.'
      +'Slow flashing: The power is disconnected. It is supplied when the button is pressed.'
      +'Fast flashing: The camera is starting up.',
      [$40, $11], [$41, $11])
  );

//---
  self.Add('::BUTTON::PANEL_ACTIVE',
    TSPpKeyAddr.Create('::BUTTON::PANEL_ACTIVE',
      'This button is for the control permission. It also serves as a function for'
      +'preventing unintentional operation because a camera cannot be controlled from'
      +'this control panel when this button and the PARA button are not lit.',
      [], [])
  );

//---
  self.Add('::BUTTON::PREVIEW',
    TSPpKeyAddr.Create('::BUTTON::PREVIEW',
      'This button is for outputting preview key signals from the EXT I/O connector',
      [], [])
  );

//---
  self.Add('::BUTTON::CALL',
    TSPpKeyAddr.Create('::BUTTON::CALL',
      'This button is for communication. If it is pressed, the tally state for the '
      +'camera or CCU changes, and a call signal is sent. Likewise, a call signal can '
      +'be received from another device. When a call signal is sent (or received), '
      +'this button lights and the call sound plays. The call sound can be selected '
      +'in the menu.',
      [], [])
  );

//---
  self.Add('::INDICATOR::ALARM',
    TSPpKeyAddr.Create('::INDICATOR::ALARM',
      'This lights red when a system error occurs and the selfdiagnosis function is '
      +'operating on the camera head or CCU/HDCU.',
      [], [])
  );

//---
  self.Add('::INDICATOR::NETWORK',
    TSPpKeyAddr.Create('::INDICATOR::NETWORK',
      'This indicates the status of the network connection'
      +'On: Connected to a control device.'
      +'Flashing: A control device cannot be found.'
      +'Off: Cannot connect to the camera network. Alternatively, the mode is LEGACY.',
      [], [])
  );

//---
  self.Add('::INDICATOR::CABLE',
    TSPpKeyAddr.Create('::INDICATOR::CABLE',
      'This indicates the communication state of the camera head and CCU.'
      +'On (green): The reception state is good.'
      +'On (yellow): The reception level is low.'
      +'On (red): The reception level is extremely low.'
      +'Off: The power of the camera is off. Alternatively, a communication error occurred.',
      [], [])
  );

//---
  self.Add('::MENU::CONFIG::CCU::MODE::GENLOCK_MODE',
    TSPpKeyAddr.Create('::MENU::CONFIG::CCU::MODE::GENLOCK_MODE',
      'Selects the type of signal using synchronization.',
      [$40, $0A], [$41, $0A])
  );

//---
  self.Add('::MENU::CONFIG::CCU::MODE::CHROMA',
    TSPpKeyAddr.Create('::MENU::CONFIG::CCU::MODE::CHROMA',
      'Turns OFF the VBS chroma signal.',
      [$40, $10], [$41, $10])
  );

//---
  self.Add('::MENU::CONFIG::CCU::MODE::BARSCHARACTER::ON',
    TSPpKeyAddr.Create('::MENU::CONFIG::CCU::MODE::BARSCHARACTER::ON',
      'Add characters to color bars signals.',
      [$40, $1A], [$41, $1A])
  );

//---
  self.Add('::BUTTON::CHARACTER::NEXT_PAGE',
    TSPpKeyAddr.Create('::BUTTON::CHARACTER::NEXT_PAGE',
      'Switches to the next page character output of the CCU.',
      [$40, $00], [$41, $00])
  );

//---
  self.Add('::MENU::CONFIG::CCU::CHANNELID::ON',
    TSPpKeyAddr.Create('::MENU::CONFIG::CCU::CHANNELID::ON',
      'Sets the Channel ID display for direct output. Turns ON the Channel ID display for direct output.',
      [$40, $83], [$41, $83])
  );

//---
  self.Add('::MENU::CONFIG::CCU::MENUCONTROL',
    TSPpKeyAddr.Create('::MENU::CONFIG::CCU::MENUCONTROL',
      '',
      [$40, $32], [$41, $32])
  );

//---
  self.Add('::MENU::CONFIG::CCU::MENUCONTROL::ARCDIAL',
    TSPpKeyAddr.Create('::MENU::CONFIG::CCU::MENUCONTROL::ARCDIAL',
      '',
      [$42, $74], [$43, $74])
  );

//---
  self.Add('::MENU::MAINTENANCE::CAMERA::MICROPHONEGAIN::CH01',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CAMERA::MICROPHONEGAIN::CH01',
      'Sets the sensitivity of the microphones mounted on the camera head. Sets the sensitivity of microphone 1.',
      [$20, $08], [$21, $08])
  );

//---
  self.Add('::MENU::MAINTENANCE::CAMERA::MICROPHONEGAIN::CH02',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CAMERA::MICROPHONEGAIN::CH02',
      'Sets the sensitivity of the microphones mounted on the camera head. Sets the sensitivity of microphone 2.',
      [$20, $09], [$21, $09])
  );

//---
  self.Add('::MENU::MAINTENANCE::CAMERA::ATWSETTINGS::ATW',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CAMERA::ATWSETTINGS::ATW',
      'Adjusts the Auto Tracing White balance. Enables the ATW function.',
      [$20, $84], [$21, $84])
  );

//---
  self.Add('::MENU::MAINTENANCE::CAMERA::ATWSETTINGS::SPEED',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CAMERA::ATWSETTINGS::SPEED',
      'Adjusts the Auto Tracing White balance. Sets the convergence speed.',
      [$20, $2C], [$21, $2C])
  );

//---
  self.Add('::MENU::MAINTENANCE::CAMERA::OHB_MATRIX::ON',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CAMERA::OHB_MATRIX::ON',
      '',
      [$20, $A0], [$21, $A0])
  );

//---
  self.Add('::MENU::MAINTENANCE::CAMERA::BLACK_SET::BLACK::R',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CAMERA::BLACK_SET::BLACK::R',
      '',
      [$22, $AA], [$23, $AA])
  );

//---
  self.Add('::MENU::MAINTENANCE::CAMERA::BLACK_SET::BLACK::G',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CAMERA::BLACK_SET::BLACK::G',
      '',
      [$22, $AB], [$23, $AB])
  );

//---
  self.Add('::MENU::MAINTENANCE::CAMERA::BLACK_SET::BLACK::B',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CAMERA::BLACK_SET::BLACK::B',
      '',
      [$22, $AC], [$23, $AC])
  );

//---
  self.Add('::MENU::MAINTENANCE::CAMERA::BLACK_SET::BLACK::MASTER',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CAMERA::BLACK_SET::BLACK::MASTER',
      '',
      [$22, $A9], [$23, $A9])
  );

//---
  self.Add('::MENU::MAINTENANCE::CAMERA::BLACK_SET::BLACK_SET::R',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CAMERA::BLACK_SET::BLACK_SET::R',
      '',
      [$22, $80], [$23, $80])
  );

//---
  self.Add('::MENU::MAINTENANCE::CAMERA::BLACK_SET::BLACK_SET::G',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CAMERA::BLACK_SET::BLACK_SET::G',
      '',
      [$22, $81], [$23, $81])
  );

//---
  self.Add('::MENU::MAINTENANCE::CAMERA::BLACK_SET::BLACK_SET::B',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CAMERA::BLACK_SET::BLACK_SET::B',
      '',
      [$22, $82], [$23, $82])
  );

//---
  self.Add('::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::R::H_SAW',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::R::H_SAW',
      '',
      [$22, $86], [$23, $86])
  );

//---
  self.Add('::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::R::H_PARA',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::R::H_PARA',
      '',
      [$22, $89], [$23, $89])
  );

//---
  self.Add('::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::R::V_SAW',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::R::V_SAW',
      '',
      [$22, $8C], [$23, $8C])
  );

//---
  self.Add('::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::R::V_PARA',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::R::V_PARA',
      '',
      [$22, $8F], [$23, $8F])
  );

//---
  self.Add('::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::G::H_SAW',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::G::H_SAW',
      '',
      [$22, $87], [$23, $87])
  );

//---
  self.Add('::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::G::H_PARA',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::G::H_PARA',
      '',
      [$22, $8A], [$23, $8A])
  );

//---
  self.Add('::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::G::V_SAW',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::G::V_SAW',
      '',
      [$22, $8D], [$23, $8D])
  );

//---
  self.Add('::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::G::V_PARA',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::G::V_PARA',
      '',
      [$22, $90], [$23, $90])
  );

//---
  self.Add('::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::B::H_SAW',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::B::H_SAW',
      '',
      [$22, $88], [$23, $88])
  );

//---
  self.Add('::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::B::H_PARA',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::B::H_PARA',
      '',
      [$22, $8B], [$23, $8B])
  );

//---
  self.Add('::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::B::V_SAW',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::B::V_SAW',
      '',
      [$22, $8E], [$23, $8E])
  );

//---
  self.Add('::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::B::V_PARA',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CAMERA::BLACK_SHADING::B::V_PARA',
      '',
      [$22, $91], [$23, $91])
  );

//---
  self.Add('::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::R::H_SAW',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::R::H_SAW',
      '',
      [$22, $92], [$23, $92])
  );

//---
  self.Add('::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::R::H_PARA',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::R::H_PARA',
      '',
      [$22, $95], [$23, $95])
  );

//---
  self.Add('::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::R::V_SAW',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::R::V_SAW',
      '',
      [$22, $B3], [$23, $B3])
  );

//---
  self.Add('::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::R::V_PARA',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::R::V_PARA',
      '',
      [$22, $98], [$23, $98])
  );

//---
  self.Add('::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::G::H_SAW',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::G::H_SAW',
      '',
      [$22, $93], [$23, $93])
  );

//---
  self.Add('::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::G::H_PARA',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::G::H_PARA',
      '',
      [$22, $96], [$23, $96])
  );

//---
  self.Add('::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::G::V_SAW',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::G::V_SAW',
      '',
      [$22, $B4], [$23, $B4])
  );

//---
  self.Add('::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::G::V_PARA',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::G::V_PARA',
      '',
      [$22, $99], [$23, $99])
  );

//---
  self.Add('::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::B::H_SAW',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::B::H_SAW',
      '',
      [$22, $94], [$23, $94])
  );

//---
  self.Add('::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::B::H_PARA',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::B::H_PARA',
      '',
      [$22, $97], [$23, $97])
  );

//---
  self.Add('::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::B::V_SAW',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::B::V_SAW',
      '',
      [$22, $B5], [$23, $B5])
  );

//---
  self.Add('::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::B::V_PARA',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::B::V_PARA',
      '',
      [$22, $9A], [$23, $9A])
  );

//---
  self.Add('::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::WHITE::R',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::WHITE::R',
      '',
      [$22, $94], [$23, $01])
  );

//---
  self.Add('::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::WHITE::G',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::WHITE::G',
      '',
      [$22, $97], [$23, $02])
  );

//---
  self.Add('::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::WHITE::B',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CAMERA::WHITE_SHADING::WHITE::B',
      '',
      [$22, $B5], [$23, $03])
  );

//---
  self.Add('::MENU::MAINTENANCE::LENS::AUTOIRIS_SETTINGS::AUTOIRIS',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::LENS::AUTOIRIS_SETTINGS::AUTOIRIS',
      'Enables the auto iris function',
      [$22, $60], [$23, $60])
  );

//---
  self.Add('::MENU::MAINTENANCE::LENS::AUTOIRIS_SETTINGS::PATTERN',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::LENS::AUTOIRIS_SETTINGS::PATTERN',
      '',
      [$20, $0a], [$21, $0a])
  );

//---
  self.Add('::MENU::MAINTENANCE::LENS::AUTOIRIS_SETTINGS::IRIS_GAIN',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::LENS::AUTOIRIS_SETTINGS::IRIS_GAIN',
      '',
      [$22, $4d], [$23, $4d])
  );

//---
  self.Add('::MENU::MAINTENANCE::LENS::AUTOIRIS_SETTINGS::APL_RATIO',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::LENS::AUTOIRIS_SETTINGS::APL_RATIO',
      '',
      [$22, $40], [$23, $40])
  );

//---
  self.Add('::MENU::MAINTENANCE::LENS::AUTOIRIS_SETTINGS::LEVEL',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::LENS::AUTOIRIS_SETTINGS::LEVEL',
      '',
      [$22, $50], [$23, $50])
  );

//---
  self.Add('::MENU::MAINTENANCE::LENS::ALAC::ON',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::LENS::ALAC::ON',
      '',
      [$20, $90], [$21, $90])
  );

//---
  self.Add('::MENU::MAINTENANCE::LENS::VMODSAW::OFF',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::LENS::VMODSAW::OFF',
      '',
      [$20, $82], [$21, $82])
  );

//---
  self.Add('::MENU::MAINTENANCE::LENS::VMODSAW::D_SHADE_COMP',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::LENS::VMODSAW::D_SHADE_COMP',
      '',
      [$20, $A3], [$21, $A3])
  );

//---
  self.Add('::MENU::MAINTENANCE::LENS::VMODSAW::R',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::LENS::VMODSAW::R',
      '',
      [$22, $05], [$23, $05])
  );

//---
  self.Add('::MENU::MAINTENANCE::LENS::VMODSAW::G',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::LENS::VMODSAW::G',
      '',
      [$22, $06], [$23, $06])
  );

//---
  self.Add('::MENU::MAINTENANCE::LENS::VMODSAW::B',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::LENS::VMODSAW::B',
      '',
      [$22, $07], [$23, $07])
  );

//---
  self.Add('::MENU::MAINTENANCE::LENS::VMODSAW::MASTER',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::LENS::VMODSAW::MASTER',
      '',
      [$22, $04], [$23, $04])
  );


//---
  self.Add('::MENU::MAINTENANCE::LENS::FLARE::OFF',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::LENS::FLARE::OFF',
      '',
      [$20, $81], [$21, $81])
  );

//---
  self.Add('::MENU::MAINTENANCE::LENS::FLARE::R',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::LENS::FLARE::R',
      '',
      [$22, $09], [$23, $09])
  );

//---
  self.Add('::MENU::MAINTENANCE::LENS::FLARE::G',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::LENS::FLARE::G',
      '',
      [$22, $0A], [$23, $0A])
  );

//---
  self.Add('::MENU::MAINTENANCE::LENS::FLARE::B',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::LENS::FLARE::B',
      '',
      [$22, $0B], [$23, $0B])
  );

//---
  self.Add('::MENU::MAINTENANCE::LENS::FLARE::MASTER',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::LENS::FLARE::MASTER',
      '',
      [$22, $08], [$23, $08])
  );

//---
  self.Add('::MENU::MAINTENANCE::CCU::MONITOR_OUTPUT::43MARKER/43MOD',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CCU::MONITOR_OUTPUT::43MARKER/43MOD',
      '',
      [$40, $E6], [$41, $E6])
  );

//---
  self.Add('::MENU::MAINTENANCE::CCU::MONITOR_OUTPUT::GATEMK',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CCU::MONITOR_OUTPUT::GATEMK',
      '',
      [$42, $72], [$43, $72])
  );

//---
  self.Add('::MENU::MAINTENANCE::CCU::MONITOR_OUTPUT::MODLVL',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CCU::MONITOR_OUTPUT::MODLVL',
      '',
      [$42, $71], [$43, $71])
  );

//---
  self.Add('::MENU::MAINTENANCE::CCU::PHASE::H',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CCU::PHASE::H',
      '',
      [$42, $1A], [$43, $1A])
  );

//---
  self.Add('::MENU::MAINTENANCE::CCU::PHASE::H_STEP',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CCU::PHASE::H_STEP',
      '',
      [$42, $1B], [$43, $1B])
  );

//---
  self.Add('::MENU::MAINTENANCE::CCU::PHASE::H_COARSE',
    TSPpKeyAddr.Create('::MENU::MAINTENANCE::CCU::PHASE::H_COARSE',
      '',
      [$42, $19], [$43, $19])
  );






//---
  self.Add('::BUTTON::MASTER_GAIN',
    TSPpKeyAddr.Create('::BUTTON::MASTER_GAIN',
      '',
      [$20, $01], [$21, $01])
  );

//---
  self.Add('::BUTTON::ND_FILTER',
    TSPpKeyAddr.Create('::BUTTON::ND_FILTER',
      '',
      [$20, $03], [$21, $03])
  );

//---
  self.Add('::BUTTON::CC_FILTER',
    TSPpKeyAddr.Create('::BUTTON::CC_FILTER',
      '',
      [$20, $04], [$21, $04])
  );

//---
  self.Add('::ROMVERSION::CAMERA',
    TSPpKeyAddr.Create('::ROMVERSION::CAMERA',
      '',
      [$0c, $05], [$0c, $05])
  );

//---
  self.Add('::MENU::FUNCTION::PIXWF::PIX',
    TSPpKeyAddr.Create('::MENU::FUNCTION::PIXWF::PIX',
      '',
      [$40, $15], [$41, $15])
  );

//---
  self.Add('::MENU::FUNCTION::PIXWF::PIX-',
    TSPpKeyAddr.Create('::MENU::FUNCTION::PIXWF::PIX',
      '',
      [$40, $16], [$41, $16])
  );

//---
  self.Add('::MENU::FUNCTION::PIXWF::WF',
    TSPpKeyAddr.Create('::MENU::FUNCTION::PIXWF::WF',
      '',
      [$40, $13], [$41, $13])
  );

//---
  self.Add('::MENU::FUNCTION::PIXWF::WF-',
    TSPpKeyAddr.Create('::MENU::FUNCTION::PIXWF::WF',
      '',
      [$40, $14], [$41, $14])
  );

end;


end.
