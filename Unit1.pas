unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type ULONG_PTR = LongWord;


var
  Form1: TForm1;
  hevent,htread1,hthread2:thandle;

implementation

{$R *.dfm}

procedure loadDll; assembler;
asm
      push $DEADBEEF // EIP
      pushfd
      pushad
      push $DEADBEEF // memory with dll name
      mov eax, $DEADBEEF // loadlibrary address
      call eax
      popad
      popfd
      ret
end;


procedure dEnd; assembler;
asm

end;

//The PUSHAD and POPAD instruction always pushes and restore all 8 general purpose registers onto the stack
//PUSHFD and POPFD are used to save and restore the EFLAGS register
//mov : Copies the second operand (source operand) to the first operand (destination)
//https://shelladept.wordpress.com/2010/11/09/hex-instruction-dictionary-x86/
//mov eax, ebx moves the value in register EBX to EAX .
//The mov [eax], ebx moves the 32-bit value in EBX to the memory location that EAX is pointing at
procedure waitfor; assembler;
asm
      push $DEADBEEF // EIP 68 xx xx xx xx
      pushfd   //9C
      pushad    //60
      push $00616161 //eventname="aaa" 68 00 61 61 61
      push esp     //push a pointer to "aaa" on the stack  54
      push 0       //inheritable=false  6A 00
      push $00100000  //access=100000  68 00 00 10 00
      mov eax, $76AE8800 // openevent address A1 xx xx xx xx
      call eax //call function, hobject now in EAX  FF D0
      mov ebx, eax //mov eax in ebx 89 c3
      push $ffffffff //push infinite on the stack   6A FF FF FF FF
      push ebx //push hobject on the stack   50
      mov eax, $76AE88C0 // waitforsingleevent address A1 xx xx xx xx
      call eax    //call function - far (9a) vs call near (e8)
      add esp, 4 //esp is off by 4 bytes - lets fix it
      popad    //61
      popfd    //9D
      ret     //c3
end;

procedure dEnd2; assembler;
asm

end;

//will sleep for 5 secs and loop
function sleep1(param:pointer):dword;stdcall;
var
dwret:dword;
begin
form1.Memo1.Lines.Add('sleep1 enter:'+inttostr(GetCurrentThreadId ));
dwret:=0;
while 1=1 do
begin
inc(dwret);
SleepEx (5000,true); //alertable=true allow APC's
form1.Memo1.Lines.Add('X:'+inttostr(dwret));
//exit; //could be a one time thingie
end;
form1.Memo1.Lines.Add('sleep1 exit'+inttostr(GetCurrentThreadId ));
ExitThread(0);
end;

////wait for event to be signaled, and exit
function wait2(param:pointer):dword;stdcall;
var
h:thandle;
begin
form1.Memo1.Lines.Add('wait2 enter:'+inttostr(GetCurrentThreadId ));
//outputdebugstring(pchar('wait:'+IntToStr(GetCurrentThreadId )));
h:=thandle(param^);
//h:=OpenEvent(SYNCHRONIZE,false,'myevent');
//while 1=1 do
//begin
WaitForSingleObject(h,infinite);
//break; //could be a one time thingie or not
//end;
//form1.Memo1.Lines.Add('exit');
//outputdebugstring('wait:exit');
form1.Memo1.Lines.Add('wait2 exit:'+inttostr(GetCurrentThreadId ));
//ExitThread(0); //beware, if you hijack a thread, exitthread will terminate the hijacked thread
end;


//wait for event to be signaled, and loop
function wait1(param:pointer):dword;stdcall;
type
TOpenEvt=function(dwDesiredAccess: DWORD; bInheritHandle: BOOL; lpName: PAnsiChar): THandle; stdcall;
var
dwret:dword;
h:thandle;
p:pointer;
OpenEvt:TOpenEvt;
begin
@OpenEvt:=GetProcAddress(GetModuleHandle('kernel32.dll'), 'OpenEventA');
form1.Memo1.Lines.Add('wait1 enter:'+inttostr(GetCurrentThreadId ));
//h:=thandle(param^);
//h:=OpenEvt (SYNCHRONIZE,false,'aaaa');
h:=OpenEventA  (SYNCHRONIZE,false,'aaa');
while 1=1 do
begin
dwret:=WaitForSingleObject(h,infinite);
form1.Memo1.Lines.Add('wait1 wakeup call'+inttostr(GetCurrentThreadId ));
//break; //could be a one time thingie or not
end;
form1.Memo1.Lines.Add('wait1 exit:'+inttostr(GetCurrentThreadId ));
//ExitThread(0); //beware, if you hijack a thread, exitthread will terminate the hijacked thread
end;

//call wait1 and wait for event to be signaled
procedure TForm1.Button1Click(Sender: TObject);
var
tid:cardinal;
begin
htread1:=CreateThread(nil,0,@wait1,@hevent,0,tid);
form1.Memo1.Lines.Add('wait1:'+inttostr(tid));
//2nd thread will react only if createevent manualreset=true
//CreateThread(nil,0,@func1,@hevent,0,tid);
//form1.Memo1.Lines.Add(inttostr(tid));

end;

procedure TForm1.Button2Click(Sender: TObject);
begin
//set the event to signaled.
SetEvent(hevent);
memo1.Lines.Add('SetEvent OK');
end;

//inject wait1 in thread2
procedure TForm1.Button3Click(Sender: TObject);
begin
//hijacks thread2 and inject wait1 while passing hevent param
if QueueUserAPC(@wait2,hthread2,dword(@(hevent)))=true
  then memo1.Lines.Add('ok') else Memo1.Lines.Add('nok');
end;

procedure TForm1.Button4Click(Sender: TObject);
var
tid:dword;
begin
hthread2:=CreateThread(nil,0,@sleep1,nil,0,tid);
form1.Memo1.Lines.Add('sleep1:'+inttostr(tid));
end;


procedure TForm1.Button6Click(Sender: TObject);
begin
{
HANDLE CreateEventA(
LPSECURITY_ATTRIBUTES lpEventAttributes,
  BOOL                  bManualReset,
  BOOL                  bInitialState,
  LPCSTR                lpName
);
}
//bManualReset
//[in] Boolean that specifies whether a manual-reset or auto-reset event object is created.
//If TRUE, then you must use the ResetEvent function to manually reset the state to nonsignaled.
//If FALSE, the system automatically resets the state to nonsignaled after a single waiting thread has been released.
//bInitialState
//If this parameter is TRUE, the initial state of the event object is signaled; otherwise, it is nonsignaled.
hevent:=CreateEvent(nil,false,false,pchar('aaa'));
memo1.Lines.Add('CreateEvent OK');
end;

//inject setevent in thread2
procedure TForm1.Button7Click(Sender: TObject);
begin
//SuspendThread(hthread2);
//hijacks thread2 and inject setevent while passing hevent param
if QueueUserAPC(@setevent,hthread2,ulong_ptr(hevent))=true
  then memo1.Lines.Add('ok') else Memo1.Lines.Add('nok');
//ResumeThread(hthread2);
end;

procedure TForm1.Button8Click(Sender: TObject);
var
stub,p:pointer;
ctx:TContext;
stubLen,openevt,waitforevt,oldip,oldprot,ret:dword;
tid:cardinal;
begin
//waitfor ;
//exit;
stubLen := DWORD(@dEnd2) - DWORD(@waitfor );

SuspendThread(hthread2 );

FillChar (ctx,sizeof(ctx),0);
ctx.ContextFlags :=CONTEXT_CONTROL;
GetThreadContext(hthread2 ,ctx);

VirtualProtect(@waitfor, stubLen, PAGE_EXECUTE_READWRITE, @oldprot);
Memo1.Lines.Add('waitfor:'+inttohex(dword(@waitfor),8));

oldip :=ctx.Eip;
CopyMemory(pointer(dword(@waitfor) + 1), @oldIP, 4);
Memo1.Lines.Add('oldIP:'+inttohex(dword(oldIP),8));

openevt := DWORD(GetProcAddress(GetModuleHandle('kernel32.dll'), 'OpenEventA'));
//p:= (GetProcAddress(GetModuleHandle('kernel32.dll'), 'OpenEventA'));
CopyMemory(pointer(dword(@waitfor) + 21), @openevt, 4);
Memo1.Lines.Add('loadLibAddy:'+inttohex(dword(openevt),8));

waitforevt:=DWORD(GetProcAddress(GetModuleHandle('kernel32.dll'), 'WaitForSingleObject'));
CopyMemory(pointer(dword(@waitfor) + 36), @waitforevt, 4);
Memo1.Lines.Add('loadLibAddy:'+inttohex(dword(waitforevt),8));

stub:=nil;
stub := VirtualAllocEx(GetCurrentProcess , nil, stubLen, MEM_COMMIT, PAGE_EXECUTE_READWRITE);
if stub=nil then exit;
Memo1.Lines.Add(pchar('VirtualAllocEx:'+inttohex(dword(stub),8)));

ret:=0;
WriteProcessMemory(GetCurrentProcess, stub, @waitfor, stubLen, ret);
if ret=0 then exit;
Memo1.Lines.Add(pchar('WriteProcessMemory:'+inttostr(dword(ret))));

//CreateThread(nil,0,@stub,nil,0,tid);
ctx.Eip :=dword(stub );
SetThreadContext(hthread2, ctx);
ResumeThread(hthread2 );
end;

procedure TForm1.Button9Click(Sender: TObject);
var
tid:cardinal;
begin
htread1:=CreateThread(nil,0,@wait2,@hevent,0,tid);
form1.Memo1.Lines.Add('wait1:'+inttostr(tid));
//2nd thread will react only if createevent manualreset=true
//CreateThread(nil,0,@func1,@hevent,0,tid);
//form1.Memo1.Lines.Add(inttostr(tid));

end;

end.

