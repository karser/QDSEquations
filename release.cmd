set package=".\package"
set demo=".\demo"
set release=".\release"
set releasefile=".\QDSEqations.zip"


set exerar="C:\Program Files\WinRAR\Rar.exe"


IF EXIST %release% (
	DEL /Q %release%\*.*
	RMDIR /S /Q %release%
)

MKDIR %release%
MKDIR %release%\demo
MKDIR %release%\package
MKDIR %release%\package\Delphi7
MKDIR %release%\package\Delphi2007
MKDIR %release%\package\Delphi2009

COPY %demo% %release%\demo

COPY %package%\Delphi7 %release%\package\Delphi7
COPY %package%\Delphi2007 %release%\package\Delphi2007
COPY %package%\Delphi2009 %release%\package\Delphi2009

DEL /Q %releasefile%

%exerar% a -ep1 -r %releasefile% %release%\



pause
