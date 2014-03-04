{********************************************************}
{ CeosServer Server Config Form                          }
{                                                        }
{ Copyright (c) 2013 JBS Soluções.                       }
{                                                        }
{********************************************************}
unit userverconfig;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Spin, Buttons;

type

  { TfrmServerConfig }

  TfrmServerConfig = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Label2: TLabel;
    sePort: TSpinEdit;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    procedure LoadConfig;
    procedure SaveConfig;
  end;

var
  frmServerConfig: TfrmServerConfig;

implementation

{$R *.lfm}

{ TfrmServerConfig }

procedure TfrmServerConfig.FormCreate(Sender: TObject);
begin
  LoadConfig;
end;

procedure TfrmServerConfig.BitBtn1Click(Sender: TObject);
begin
  SaveConfig;
  close;
end;

procedure TfrmServerConfig.BitBtn2Click(Sender: TObject);
begin
  close;
end;

procedure TfrmServerConfig.LoadConfig;
var
  i, iPosEnd: Integer;
  sApp, sAux: string;
  slConfig: TStringlist;
begin
  try
    slConfig := TStringlist.create;

    if fileexists(extractfilepath(paramstr(0)) + 'server.conf') then
      slConfig.loadfromfile(extractfilepath(paramstr(0)) + 'server.conf');

    for i := 0 to slConfig.count -1 do
    begin
      if Pos('Listen', slConfig[i]) > 0 then
      begin
        sAux := copy(slConfig[i],Pos(' ',slConfig[i]) +1,length(slConfig[i]) - (Pos(' ',slConfig[i]) +1) +1);

        sApp := trim(sAux);

        sePort.value := strtoint(sApp);
      end;
    end;

  finally
    freeandnil(slConfig);
  end;

end;

procedure TfrmServerConfig.SaveConfig;
var
  slConfig: TStringlist;
begin
  try
    slConfig := TStringlist.create;

    slConfig.Add('#CeosServer Settings');

    slConfig.Add(format('ServerRoot "%s"',[extractfilepath(paramstr(0)) + 'apache']));
    slConfig.Add(format('Listen %d',[sePort.value]));
    slConfig.Add('');
    slConfig.Add(format('DocumentRoot "%s"',[stringreplace(extractfilepath(paramstr(0)) + 'webfiles','\','/',[rfReplaceAll])]));
    slConfig.Add(format('  <Directory "%s">',[stringreplace(extractfilepath(paramstr(0)) + 'webfiles','\','/',[rfReplaceAll])]));
    slConfig.Add('    Options Indexes FollowSymLinks');
    slConfig.Add('    AllowOverride None');
    slConfig.Add('    Order allow,deny');
    slConfig.Add('    Allow from all');
    slConfig.Add('  </Directory>');
    slConfig.Add('');
    slConfig.Add('<IfModule alias_module>');
    slConfig.Add(format('    ScriptAlias /cgi-bin/ "%s"',[stringreplace(extractfilepath(paramstr(0)),'\','/',[rfReplaceAll]) + 'apache/cgi-bin/']));
    slConfig.Add('</IfModule>');
    slConfig.Add('');
    slConfig.Add(format('  <Directory "%s">',[stringreplace(extractfilepath(paramstr(0)),'\','/',[rfReplaceAll]) + 'apache/cgi-bin']));
    slConfig.Add('    Options Indexes FollowSymLinks');
    slConfig.Add('    AllowOverride None');
    slConfig.Add('    Order allow,deny');
    slConfig.Add('    Allow from all');
    slConfig.Add('  </Directory>');
  finally
    slConfig.savetofile(extractfilepath(paramstr(0)) + 'server.conf');
    freeandnil(slConfig);
  end;
end;

end.

