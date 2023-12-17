Um das Python Script für das Umwandeln der Daten in ein CSV-File zu starten, muss folgendes Script ausgeführt werden:
```python extract_json.py```
Jedoch bevor man das Script ausführt muss die Flag use_database angepasst werden, wenn man False angibt, wird das aktuelle JSON namens darkpatterns-ac762-default-rtdb-export.json gewählt. Sollte man True eingeben, wird die Datenbank verwendet. 
Um die Datenbank zu verwenden, wird jedoch ein credentials.json File benötigt welches ich nicht auf GitHub hochladen will, da sonst jeder Zugriff auf die Datenbank hat, der Zugriff auf das Repository hat.
Also um das Credentials File zu bekommen, schick mir einfach eine Nachricht und ich schicke dir das File zu.

Um neue Levels zu generieren, startet man einfach das Script generate_levels.py mit folgendem Befehl:
```python generate_levels.py``` die Levels sind danach im File unityLevels_generated.json zu finden.