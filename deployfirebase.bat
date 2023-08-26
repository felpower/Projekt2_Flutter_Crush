cmd /C flutter build web
xcopy ".\build\web" "..\build\web" /Y /K /D /H /S
firebase deploy