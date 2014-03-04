{********************************************************}
{ CeosServer Main Form                                   }
{                                                        }
{ Copyright (c) 2013 JBS Soluções.                       }
{                                                        }
{********************************************************}
unit umain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, ComCtrls, Process, lclintf, Buttons, ActnList;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    actStartService: TAction;
    actStopService: TAction;
    actInstallService: TAction;
    actUnistallService: TAction;
    actServerSettings: TAction;
    actApplications: TAction;
    actList: TActionList;
    btStart: TBitBtn;
    btStop: TBitBtn;
    btInstall: TBitBtn;
    btUninstall: TBitBtn;
    btAppsConfig: TBitBtn;
    btServerConfig: TBitBtn;
    Image1: TImage;
    imgList: TImageList;
    lblURL: TLabel;
    statusBarServer: TStatusBar;
    Timer1: TTimer;
    procedure actApplicationsExecute(Sender: TObject);
    procedure actInstallServiceExecute(Sender: TObject);
    procedure actServerSettingsExecute(Sender: TObject);
    procedure actStartServiceExecute(Sender: TObject);
    procedure actStopServiceExecute(Sender: TObject);
    procedure actUnistallServiceExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lblURLClick(Sender: TObject);
    procedure statusBarServerDrawPanel(statusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
    procedure Timer1Timer(Sender: TObject);
  private
    { private declarations }
    procedure updatestatus;
    procedure ServiceInstall();
    procedure ServiceUninstall();
    procedure SetServiceDescription();
    procedure SetStatusText(const AIndex: integer; const AText: string = '');
    procedure OpenNotepad(const AFile: string);
  public
    { public declarations }
    imgStatusIndex: integer;
  end;

var
  frmMain: TfrmMain;

implementation

uses cwinsrvc, uapps, userverconfig, jwawinsvc, versioninfo;

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  frmmain.DoubleBuffered := true;
  statusBarServer.panels[0].text := GetProductVersion;

  //reload server config (reconfigure paths)
  application.createform(TfrmServerConfig,frmServerConfig);
  frmServerConfig.Loadconfig;
  frmServerConfig.Saveconfig;
  frmServerConfig.free;
  frmServerConfig := nil;

  updatestatus;
end;

procedure TfrmMain.lblURLClick(Sender: TObject);
begin
  OpenURL(lblURL.caption);
end;

procedure TfrmMain.statusBarServerDrawPanel(statusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
begin
  if Panel.index <> 2 then
    exit;

  with statusBarServer.Canvas do
  begin
    FillRect(Rect) ;

    TextRect(Rect,2 + imgList.Width + Rect.Left, 2 + Rect.Top,Panel.Text) ;
  end;

  imgList.Draw(statusBar.Canvas, Rect.Left, Rect.Top, imgStatusIndex);
end;

procedure TfrmMain.Timer1Timer(Sender: TObject);
begin
  updatestatus;
end;

procedure TfrmMain.actStartServiceExecute(Sender: TObject);
begin
  SetStatusText(2,'Starting...');
  ServiceStartSC('','CeosServer');
  updatestatus;
end;

procedure TfrmMain.actInstallServiceExecute(Sender: TObject);
begin
  SetStatusText(2,'Installing...');
  ServiceInstall();
  updatestatus;
end;

procedure TfrmMain.actApplicationsExecute(Sender: TObject);
begin
  application.createform(tfrmapps, frmapps);
  frmapps.showmodal;
  frmapps.free;
  frmapps := nil;

  if (ServiceGetStatus('','CeosServer') = SERVICE_RUNNING) then
  begin
    if messagedlg('Restart service?',mtConfirmation,[mbYes,mbNo],0) = mrYes then
    begin
      actStopService.Execute;

      while not (ServiceGetStatus('','CeosServer') = SERVICE_STOPPED) do
      begin
        sleep(100);
        application.ProcessMessages;
      end;

      actStartServiceExecute(actStartService);
    end;
  end;
end;

procedure TfrmMain.actServerSettingsExecute(Sender: TObject);
begin
  application.createform(tfrmserverconfig, frmserverconfig);
  frmserverconfig.showmodal;
  frmserverconfig.free;
  frmserverconfig := nil;

  updatestatus;
end;

procedure TfrmMain.actStopServiceExecute(Sender: TObject);
begin
  SetStatusText(2,'Stopping...');
  ServiceStopSC('','CeosServer');
  updatestatus;
end;

procedure TfrmMain.actUnistallServiceExecute(Sender: TObject);
begin
  SetStatusText(2,'Uninstalling...');
  ServiceUninstall();
  updatestatus;
end;

procedure TfrmMain.updatestatus;
var
  ServerPort: integer;
begin
  try
    application.processmessages;

    statusBarServer.Panels[2].text := ServiceGetStrCode(ServiceGetStatus('','CeosServer'));

    actStartService.enabled    := (ServiceGetStatus('','CeosServer') = SERVICE_STOPPED);
    actStopService.enabled     := (ServiceGetStatus('','CeosServer') = SERVICE_RUNNING);
    actInstallService.enabled  := (ServiceGetStrCode(ServiceGetStatus('','CeosServer')) = 'Unknown');
    actUnistallService.enabled := (ServiceGetStatus('','CeosServer') = SERVICE_STOPPED);
    actServerSettings.enabled  := (ServiceGetStatus('','CeosServer') = SERVICE_STOPPED);;

    case ServiceGetStatus('','CeosServer') of
      SERVICE_STOPPED : imgStatusIndex := 1;
      SERVICE_RUNNING : imgStatusIndex := 0;
      SERVICE_START_PENDING,
      SERVICE_STOP_PENDING,
      SERVICE_CONTINUE_PENDING,
      SERVICE_PAUSE_PENDING,
      SERVICE_PAUSED: imgStatusIndex := 2;
    else
      imgStatusIndex := 3;
    end;

    statusBarServerDrawPanel(statusBarServer,statusBarServer.panels[2],statusBarServer.BoundsRect);

    application.createform(TfrmServerConfig,frmServerConfig);
    frmServerConfig.Loadconfig;
    ServerPort := frmServerConfig.sePort.Value;

    lblURL.caption := format('http://localhost:%d',[ServerPort]);
    lblURL.enabled := (ServiceGetStatus('','CeosServer') = SERVICE_RUNNING);

    SetServiceDescription();
  finally
    freeandnil(frmServerConfig);
    application.processmessages;
  end;

end;

procedure TfrmMain.ServiceInstall;
var
  AProcess: TProcess;
begin
  try
    AProcess := TProcess.Create(nil);

    AProcess.CommandLine := extractfilepath(paramstr(0)) + 'apache\bin\httpd -k install -n "CeosServer"';

    AProcess.Options := AProcess.Options + [poWaitOnExit,poNoConsole];

    AProcess.Execute;
  finally
    AProcess.Free;
  end;
end;

procedure TfrmMain.ServiceUninstall;
var
  AProcess: TProcess;
begin
  try
    AProcess := TProcess.Create(nil);

    AProcess.CommandLine := extractfilepath(paramstr(0)) + 'apache\bin\httpd -k uninstall -n "CeosServer"';

    AProcess.Options := AProcess.Options + [poWaitOnExit,poNoConsole];

    AProcess.Execute;
  finally
    AProcess.Free;
  end;
end;

procedure TfrmMain.SetServiceDescription;
var
  AProcess: TProcess;
begin
  try
    AProcess := TProcess.Create(nil);

    AProcess.CommandLine := 'sc description CeosServer "Ceos Application Server - www.jbsolucoes.net"';

    AProcess.Options := AProcess.Options + [poWaitOnExit,poNoConsole];

    AProcess.Execute;

  finally
    AProcess.Free;
  end;
end;

procedure TfrmMain.SetStatusText(const AIndex: integer; const AText: string = '');
begin
  statusBarServer.panels[AIndex].text := AText;
  statusBarServerDrawPanel(statusBarServer,statusBarServer.panels[AIndex],statusBarServer.BoundsRect);
  Application.ProcessMessages;
end;

procedure TfrmMain.OpenNotepad(const AFile: string);
var
  AProcess: TProcess;
begin
  try
    AProcess := TProcess.Create(nil);

    AProcess.CommandLine := 'notepad "'+ AFile + '"';

    AProcess.Options := AProcess.Options + [poWaitOnExit];

    AProcess.Execute;
  finally
    AProcess.Free;
  end;

end;

end.

