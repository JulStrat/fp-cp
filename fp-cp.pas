program fpcp;
{$mode delphi}

type
  // returns > 0 if akey > bkey, 0 if akey = bkey, < 0 if akey < bkey
  TCompare = function(akey: Pointer; bkey: Pointer): Integer;
  TArrayOfSizeInt = array of SizeInt;  

// Compare function for testing
function Compare(akey: Pointer; bkey: Pointer): Integer;
begin
  if PLongInt(akey)^ < PLongInt(bkey)^ then Result := -1
  else if PLongInt(akey)^ = PLongInt(bkey)^ then Result := 0
  else Result := 1;
end;
 
function BisectLeft(key: Pointer; base: Pointer; num: SizeInt; size: SizeInt; comp: TCompare): SizeInt;
var
  l, h, m: SizeInt;
begin
  l := 0;
  h := num;
  while l < h do
  begin
    m := l + (h-l) div 2;
    if comp(base+m*size, key) < 0 then l := m + 1
    else h := m;
  end;
  Result := l;
end;

function BisectRight(key: Pointer; base: Pointer; num: SizeInt; size: SizeInt; comp: TCompare): SizeInt;
var
  l, h, m: SizeInt;
begin
  l := 0;
  h := num;
  while l < h do
  begin
    m := l + (h-l) div 2;
    if comp(key, base+m*size) < 0 then h := m
    else l := m + 1;
  end;
  Result := l
end;

(* Euler's totient sieve *)
function SieveTotient(n: SizeInt): TArrayOfSizeInt;
var
  i, j: SizeInt;
  phi: TArrayOfSizeInt;
begin
  SetLength(phi, n+1);
  for i := 0 to n do phi[i] := i;
  for i := 2 to n do 
  begin
    if phi[i] = i then 
    begin
      Dec(phi[i]); j := 2*i;
      while j <= n do begin phi[j] := (phi[j] div i)*(i-1); Inc(j, i); end;
    end;
  end;
  Result := phi;
end;

(* Least prime factor linear sieve *)
function LPFSieve(n: SizeInt): TArrayOfSizeInt;
var 
  primes: TArrayOfSizeInt; 
  lpf: TArrayOfSizeInt;
  i, j, c: SizeInt;
  h: SizeInt = -1;
begin
  SetLength(primes, n+1);
  SetLength(lpf, n+1);  
  for i := 0 to n do lpf[i] := i;

  for i := 2 to (n div 2) do
  begin
    if lpf[i] = i then
    begin
      Inc(h);
      primes[h] := i;
    end;  
    for j := 0 to h do
    begin
      c := primes[j]*i;
      if c > n then break;
      lpf[c] := primes[j];
      if primes[j] = lpf[i] then break;
    end
  end;
  SetLength(primes, 0);
  Result := lpf;
end;

(* Union Find *)
type
  TUnionFindCrossed = record
    private
      uf: array of SizeInt;
    public
      constructor Create(n: SizeInt);
      function Find(x: SizeInt): SizeInt;
      function Union(x, y: SizeInt): Boolean;
      function Connected(x, y: SizeInt): Boolean; inline;
      procedure Free; inline;
    end;

constructor TUnionFindCrossed.Create(n: SizeInt);
var
  i: SizeInt;
begin
  SetLength(uf, n);
  for i := Low(uf) to High(uf) do uf[i] := i;
end;

function TUnionFindCrossed.Find(x: SizeInt): SizeInt;
var
  p: SizeInt;
begin
  while x <> uf[x] do
  begin
    p := uf[x];
    uf[x] := uf[p];
    x := p;
  end;
  Result := x;
end;

function TUnionFindCrossed.Union(x, y: SizeInt): Boolean;
var
  t: SizeInt;
begin
  while uf[x] <> uf[y] do
  begin
    if uf[x] < uf[y] then begin t := x; x := y; y := t; end; // Swap x, y
    if uf[y] = y then begin uf[y] := uf[x]; Exit(True); end;
    t := uf[y];
    uf[y] := uf[x];
    y := t;
  end;
  Exit(False);
end;

function TUnionFindCrossed.Connected(x, y: SizeInt): Boolean;
begin
  Result := (Find(x) = Find(y));
end;

procedure TUnionFindCrossed.Free;
begin
  SetLength(uf, 0);
end;

var
  i, t: LongInt;
  arr: Array[0..9] of LongInt;
  pos: SizeInt;
  
  lpf: TArrayOfSizeInt;
  phi: TArrayOfSizeInt;  
  uf: TUnionFindCrossed;

begin
  for i := Low(arr) to High(arr) do
    arr[i] := i*i;
  for i := Low(arr) to High(arr) do
  begin
    t := i*i;
    pos := BisectLeft(@t, @arr[0], Length(arr), SizeOf(LongInt), Compare);
    WriteLn('Key - ', t, ', Left Pos - ', pos, ', arr - ', arr[i]);
    pos := BisectRight(@t, @arr[0], Length(arr), SizeOf(LongInt), Compare);
    WriteLn('Key - ', t, ', Right Pos - ', pos, ', arr - ', arr[i]);
  end;
  
  lpf := LPFSieve(1000000);
  WriteLn(lpf[17]);
  WriteLn(lpf[31]);
  WriteLn(lpf[41]);
  SetLength(lpf, 0);
  
  phi := SieveTotient(10000000);
  for i := 0 to 30 do WriteLn(i, ' - ', phi[i]);
  SetLength(phi, 0);

  uf := TUnionFindCrossed.Create(1000000);
  uf.Union(0, 1);
  uf.Union(2, 1);
  uf.Union(3, 1);
  uf.Union(4, 1);
  WriteLn(uf.Connected(0, 4));
  uf.Free;
end.
