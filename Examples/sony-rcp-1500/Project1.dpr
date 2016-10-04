program Project1;

uses
  System.StartUpCopy,
  FMX.Forms,
  FH.SONY.SPP.CNS in 'FH.SONY.SPP.CNS.pas',
  FH.SONY.SPP.COMMANDHANDLERS in 'FH.SONY.SPP.COMMANDHANDLERS.pas',
  FH.SONY.SPP.COMMANDADDR in 'FH.SONY.SPP.COMMANDADDR.pas',
  FH.SONY.SPP.UTILS in 'FH.SONY.SPP.UTILS.pas',
  FH.SONY.SPP.PACKET in 'FH.SONY.SPP.PACKET.pas',
  FH.SONY.SPP.CNS.BRIDGE in 'FH.SONY.SPP.CNS.BRIDGE.pas',
  FH.SONY.SPP.CNS.MCS in 'FH.SONY.SPP.CNS.MCS.pas',
  Unit1 in 'Unit1.pas' {Form1};

{$R *.res}

begin
{$IFDEF MSWINDOWS}
  ReportMemoryLeaksOnShutdown := DebugHook <> 0;
{$ENDIF}


  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
