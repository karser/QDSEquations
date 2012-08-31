unit UsefulUtils;

interface

uses
  SysUtils, Windows;

function GetCharFromVirtualKey(AKey: Word): string;
function GetCharFromVirtualKey2(Key: Word): Char;
function GetString(const Index: String) : String;
function IntToStrZero(Value: Integer; Size: Integer): String;


implementation

function GetCharFromVirtualKey(AKey: Word): string;
var
  KeyboardState: Windows.TKeyboardState; // keyboard state codes
const
  MAPVK_VK_TO_VSC = 0;  // parameter passed to MapVirtualKey
begin
  Windows.GetKeyboardState(KeyboardState);
  SetLength(Result, 2); // max number of returned chars
  case Windows.ToAscii(
    AKey,
    Windows.MapVirtualKey(AKey, MAPVK_VK_TO_VSC),
    KeyboardState,
    @Result[1],
    0
  ) of
    0: Result := '';         // no translation available
    1: SetLength(Result, 1); // single char returned
    2: {Do nothing};         // two chars returned: leave Length(Result) = 2
    else Result := '';       // probably dead key
  end;
end;

function GetCharFromVirtualKey2(Key: Word): Char;
var
   keyboardState: TKeyboardState;
   asciiResult: Integer;
begin
   GetKeyboardState(keyboardState) ;

   asciiResult := ToAscii(Key, MapVirtualKey(Key, 0), keyboardState, @Result, 0) ;
   case asciiResult of
     0: Result := #0;
     1:;
     2:;
     else
       Result := #0;
   end;
end;

function GetString(const Index: String) : String;
var
  buffer : array[0..255] of Char;
  ls : integer;
begin
  Result := '';
  ls := LoadString(hInstance, StrToInt(Index), buffer, sizeof(buffer));
  if ls <> 0 then Result := buffer;
end;

function IntToStrZero(Value: Integer; Size: Integer): String;
begin
  Result:=IntToStr(Value);
  while Length(Result)<Size do Result:='0'+Result;
end;

end.
 