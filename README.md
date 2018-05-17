# django-angular-cli (Heroku)

A template for deploying Angular 2+ with Django app

## Setup

### GIT REPO SETUP
- Use Python ignore preset. Angular subfolder has gitignore to handle Node gitignore.
- Gitignore exclude django staticfiles, include angular /dist/

### [DJANGO SETTING](https://www.techiediaries.com/django-angular-cli/)
- Create venv, activate it
- Requirements.txt
  - django<2
  - django-cors-headers
  - `pip install -r requirements.txt`
- Django startproject
- Move out subfolder after did startproject
- Settings
  - INSTALLED APP add ‘corsheaders’,
  - MIDDLEWARE add 'corsheaders.middleware.CorsMiddleware',
  - CORS_ORIGIN_ALLOW_ALL = True 
*can now accept request from different origin, but this is not recommended in production*

### ANGULAR SETTING
- ng new <> 
- ng serve

### BOOTSTRAP ANGULAR UNDER DJANGO
- Build angular to create /dist/
- Add /dist/ in django static settings
  - NOTICE! Set ANGULAR_APP_DIR to  'angular-frontend/dist/angular-frontend'. Have to go one level deeper in dist; otherwise Django static routing will fail
- collectstatic
- Let django serve angular’s index.html as start point
- Add routing for any angular /static/ request, see `urlpatterns` part in [this article](https://www.techiediaries.com/django-angular-cli/)

### DEPLOY TO HEROKU
- Heroku Bootstrapping...following this heroku dev post
- Setup Procfile = web: gunicorn <django project name>.wsgi
- Requirements.txt += gunicorn
- Settings add: import django_heroku; django_heroku.settings(locals())
- Setup heroku app & git remote
- Create heroku app, [get remote](https://git.heroku.com/iriversland2.git)
  - heroku git:remote -a iriversland2
  - git commit & Push to heroku
  - [Solved] while doing collectstatic | can’t find dist/ to do collectstatic
    - Gitignore exclude django staticfiles, include angular /dist/
- done
