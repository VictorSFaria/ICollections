unit ICollections.Default;

interface
type
  IEnumerator<T> = interface
    function GetCurrent: T;
    property Current: T read GetCurrent;
    function MoveNext: Boolean;
  end;

  IEnumerable<T> = interface
    function GetEnumerator: IEnumerator<T>;
  end;

implementation

end.
