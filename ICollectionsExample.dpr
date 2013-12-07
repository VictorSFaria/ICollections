program ICollectionsExample;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  DUnitX.TestFramework,
  DUnitX.TestRunner,
  DUnitX.Loggers.Console,
  DUnitX.Windows.Console,
  DUnitX.MemoryLeakMonitor.FastMM4,
  Generics.ICollections in 'Generics.ICollections.pas',
  Generics.ICollections.Test in 'Generics.ICollections.Test.pas';

var
  runner : ITestRunner;
  results : IRunResults;
  logger : ITestLogger;
begin
  try
    runner := TDUnitX.CreateRunner;
    runner.UseRTTI := True;
    logger := TDUnitXConsoleLogger.Create(true);
    runner.AddLogger(logger);

    results := runner.Execute;

    System.Write('Press <Enter> key to quit.');
    System.Readln;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
