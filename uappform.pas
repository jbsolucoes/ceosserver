{********************************************************}
{ CeosServer App Form                                    }
{                                                        }
{ Copyright (c) 2013 JBS Soluções.                       }
{                                                        }
{********************************************************}
unit uappform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Buttons,
  DbCtrls, StdCtrls, uapps;

type

  { TfrmAppForm }

  TfrmAppForm = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    DBEdit1: TDBEdit;
    DBEdit2: TDBEdit;
    Label1: TLabel;
    Label2: TLabel;
    OpenDialog1: TOpenDialog;
    SpeedButton1: TSpeedButton;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmAppForm: TfrmAppForm;

implementation

{$R *.lfm}

{ TfrmAppForm }

procedure TfrmAppForm.SpeedButton1Click(Sender: TObject);
begin
  if OpenDialog1.execute then
    frmApps.dstApps.fields[1].value := OpenDialog1.filename;
end;

procedure TfrmAppForm.BitBtn1Click(Sender: TObject);
begin
  frmApps.dstApps.fields[0].value := trim(frmApps.dstApps.fields[0].value);
  frmApps.dstApps.fields[1].value := trim(frmApps.dstApps.fields[1].value);
  frmApps.dstApps.post;
  close;
end;

procedure TfrmAppForm.BitBtn2Click(Sender: TObject);
begin
  frmApps.dstApps.cancel;
  close;
end;

end.

