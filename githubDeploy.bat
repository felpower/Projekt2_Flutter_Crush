cmd /C flutter build web
cd .\build\web
git add .
git commit -m "Deploy to GitHub Pages"
git push -u origin main
