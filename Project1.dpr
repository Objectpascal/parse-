program Project1;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Operations in 'Operations.pas';
var
  ep:TequationParsing;
  count:integer;
  SomeMath:string;
  res:double;
begin
try

  ep:=TequationParsing.create('');

  repeat
    write('-->');
    readln(SomeMath);
    ep.setNewString('('+SomeMath+')');
   try
    res:= ep.CalcResult;
    writeln('------------------------------');
    writeln;
    writeln('[The Result] ---> ',res:0:8);
    writeln;
   // ep.fill();
    ep.displayStack;
    ep.DisplayPostfin;
   except
    on E:Exception do
      writeln(e.Message);

   end;
  until UpperCase(SomeMath)='Q';

  finally
    FreeAndNil(ep);
  end;
 readln;
end.
