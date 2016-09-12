unit Operations;

interface
uses classes,sysutils;
type
  Toperator=record
    ch:string;
    priority:integer;
    NumArg:integer;
  end;
const
  ArrOperator:array[0..7] of Toperator=(
   (ch:'^';priority:3;NumArg:2)
  ,(ch:'*';priority:2;NumArg:2)
  ,(ch:'/';priority:2;NumArg:2)
  ,(ch:'+';priority:1;NumArg:2)
  ,(ch:'-';priority:1;NumArg:2)
  ,(ch:'sqrt';priority:3;NumArg:1)
  ,(ch:'cos';priority:3;NumArg:1)
  ,(ch:'sin';priority:3;NumArg:1)
  );
type
TArrStack=array of string;
TstackClass=class
    private
     FStack:TStringList;
     Ftop:integer;
    public
    procedure move(from_index,to_index: integer);
    procedure clearStack();
    procedure Push(const val:string);
    function getString(index:integer):string;
    function pop():string;
    function getTop:integer;
    function isEmpty():boolean;
    constructor create();
    destructor Destroy; override;
    end;
  TequationParsing=class
      private
        Fstack:TstackClass;
        Fpostfin:TstackClass;
        Fstr:string;
       function getOperationMethod(const op:string;num1:double;num2:double=0):double;
       function isOperation(op:string):boolean;
       function getEndOfNumber(const str:string;strPos:integer):integer;
       function isOperation_haveArg(op:string;NumArgs:integer):boolean;
       procedure CalcOperation(op:string);
       procedure addOperation(op:string);
       function getpriority(op:string):integer;
       procedure MoveToPostfin();
       procedure fill();
       procedure Fix_Input();
      public
      constructor create(str:string);
      procedure CalcResult();
      procedure setNewString(const str:string);
      procedure displayStack;
      procedure DisplayPostfin;
     destructor Destroy; override;

    end;
implementation
uses math;
{ TstackClass }

procedure TstackClass.clearStack;
begin
  FStack.Clear;
  Ftop:=-1;
end;

constructor TstackClass.create;
begin
  FStack:=TStringList.Create();
  Ftop:=-1;

end;

destructor TstackClass.Destroy;
begin
  if Assigned(FStack) then
    FreeAndNil(FStack);
  inherited;
end;

function TstackClass.getString(index: integer): string;
begin
result:='';
if isEmpty then
  raise Exception.Create('Stack is Empty');
  result:=FStack[index];
end;

function TstackClass.getTop: integer;
begin
  result:=Ftop;
end;

procedure TstackClass.move(from_index,to_index: integer);
begin
FStack.Move(from_index,to_index);
end;

function TstackClass.isEmpty: boolean;
begin
  result:=(Ftop<=-1);

end;

function TstackClass.pop: string;
var
  res:string;
begin
if isEmpty() then
  raise Exception.Create('Empty Satck pop');
  res:=FStack[Ftop];
  FStack.Delete(Ftop);
  Dec(Ftop);
  result:=res;
end;

procedure TstackClass.Push(const val: string);
begin
  inc(Ftop,1);
  FStack.Add(val);
end;

{ TequationParsing }

procedure TequationParsing.addOperation(op: string);
var
  op_p:integer;
  r_p:integer;
  r_op:string;

begin
op_p:=getpriority(op);
r_p:=getpriority(Fstack.getString(Fstack.getTop));
if (op_p>r_p) or(r_p=-1) then
  Fstack.Push(op)
else
  begin
  r_op:=Fstack.pop;
  Fpostfin.Push(r_op);
  addOperation(op);
  end;
end;

procedure TequationParsing.CalcOperation(op: string);
var
  Strnum2,Strnum1:string;
  num1_Val,num2_Val:double;
  res:double;
begin
  Strnum2:=Fstack.pop;
  num2_Val:=StrToFloat(Strnum2);
  if isOperation_haveArg(op,2) then
   begin
    Strnum1:=Fstack.pop;
    num1_Val:=StrToFloat(Strnum1);
    res:=getOperationMethod(op,num1_val,num2_val);
   end
  else
   if isOperation_haveArg(op,1) then
    begin
     res:=getOperationMethod(op,num2_Val);
    end;
  Fstack.Push(FloatToStr(res));
end;

procedure TequationParsing.CalcResult;
var
  count:integer;
  max:integer;
  val:string;

begin
 fill();
  max:=Fpostfin.getTop;
    for count := 0 to max do
        begin
        val:=Fpostfin.getString(count);
          if isOperation(val) then
            begin
              //writeln('add op:',val);
              CalcOperation(val);
            end
          else
            begin
                Fstack.Push(val);
            //    displayStack
            end;
        end;
end;

constructor TequationParsing.create(str: string);
begin
  inherited create;
  Fstack:=TstackClass.create;
  Fpostfin:=TstackClass.create;
  setNewString(str);
end;

destructor TequationParsing.Destroy;
begin
  if Assigned(Fstack) then
    FreeAndNil(Fstack);
  if Assigned(Fpostfin) then
    FreeAndNil(Fpostfin);
  inherited;
end;

procedure TequationParsing.DisplayPostfin;
var
  top:integer;
begin
  top:=Fpostfin.getTop;
  writeln;
  writeln('-----------------Dislpay postfin----------------');
  while (top>=0) do
  begin
  writeln(Format('[%d] -> %s',[top,Fpostfin.getString(top)]));
  dec(top,1);
  end;

end;

procedure TequationParsing.displayStack;
var
  top:integer;
begin
  top:=Fstack.getTop;
  writeln;
  writeln('-----------------Dislpay Stack----------------');
  while (top>=0) do
  begin
  writeln(Format('[%d] -> %s',[top,Fstack.getString(top)]));
  dec(top,1);
  end;

end;

procedure TequationParsing.Fill;
var
  val:string;
  copyStr:string;
  pos_index:integer;
  len_index:integer;
  count:integer;
begin
  Fstack.clearStack;
  Fpostfin.clearStack;
   copyStr:=Fstr;
  while copyStr<>'' do
  begin
        pos_index:=1;
        len_index:=1;
        val:=Copy(copyStr,pos_index,len_index);
         if isOperation(val) then
            begin
              writeln('add op:',val);
              addOperation(val);
            end
          else
            if (val='(') or (val=')') then
            begin
                if val='(' then
                  Fstack.Push(val)
                else
                  MoveToPostfin();
            end
          else
            begin
                len_index:=getEndOfNumber(copyStr,pos_index+1);

                val:=Copy(copyStr,pos_index,len_index);
                if isOperation(val) then
                begin
                  writeln('add op:',val);
                  addOperation(val);
                end
                else
                  Fpostfin.Push(val);
            end;

            copyStr:=Copy(copyStr,len_index+1,length(copyStr));
   end;
end;

procedure TequationParsing.Fix_Input;
begin
 { TODO : fix input bug }

end;

function TequationParsing.getEndOfNumber(const str: string;
  strPos: integer): integer;
  var
    count:integer;
    val:string;
begin
result:=-1;
  for count := strPos to length(str) do
                  begin
                  val:=str[count];
                    if  isOperation(val) or (val='(') or (val=')') then
                     begin
                         result:=count-1;
                         break;
                     end;
                  end;
end;


function TequationParsing.getOperationMethod(const op: string; num1,
  num2: double): double;

begin
result:=0;
 if op='+' then
    result:=num1+num2
  else
  if op='-' then
    result:=num1-num2
  else
  if op='*' then
    result:=num1*num2
  else
  if op='/' then
    result:=num1/num2
  else
    if op='^' then
      result:= power(num1,num2)
  else
    if UpperCase(op)='SQRT' then
    begin
      result:=sqrt(num1);
    end
    else
    if UpperCase(op)='COS' then
    begin
      result:=cos(num1);
    end
   else
    if UpperCase(op)='SIN' then
    begin
      result:=sin(num1);
    end;
end;

function TequationParsing.getpriority(op:string): integer;
var
  count:integer;
begin
  result:=-1;
    for count := Low(ArrOperator) to High(ArrOperator) do
        if (ArrOperator[count].ch=op) then
          begin
            result:=ArrOperator[count].priority;
            break;
          end;
end;

function TequationParsing.isOperation(op: string): boolean;
var
  count:integer;
begin
  result:=false;
  for count := low(ArrOperator) to High(ArrOperator) do
      begin
        if uppercase( ArrOperator[count].ch )=uppercase(op) then
          begin
            result:=true;
            break;
          end;
      end;
end;

function TequationParsing.isOperation_haveArg(op:string;NumArgs:integer): boolean;
var
  count:integer;
begin
result:=false;
    for count := Low(ArrOperator) to High(ArrOperator) do
        begin
          if uppercase( ArrOperator[count].ch)=UpperCase(op)  then
            begin
              result:=ArrOperator[count].NumArg=NumArgs;
              break;
            end;

        end;

end;

procedure TequationParsing.MoveToPostfin();
var
  popString:string;
begin
  popString:=Fstack.pop;
  while(popString<>'(') do
    begin
      Fpostfin.Push(popString);
      popString:=Fstack.pop;
    end;

end;

procedure TequationParsing.setNewString(const str: string);
begin
  Fstack.clearStack;
  Fpostfin.clearStack;
  Fstr:=str;
  Fix_Input();
end;

end.
