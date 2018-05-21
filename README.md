# Django + Angular@CLI for Heroku / Amazon Elastic Beanstalk

A template for deploying Angular 2+ with Django app

## Setup

### GIT REPO SETUP
- Use Python ignore preset. Angular subfolder has its gitignore to handle Node ignore files.
- Gitignore exclude django staticfiles or root static, include angular /dist/

### [DJANGO SETTING](https://www.techiediaries.com/django-angular-cli/)
- Create venv, activate it
- Requirements.txt
  - django<2
  - django-cors-headers
  - `pip install -r requirements.txt`
- Django startproject **IMPORTANT: make sure you add a DOT "." at the end!** This will let Django files collected into a single folder but let manage.py be in root. Cleaner for seperating backend and frontend files.
- Settings
  - INSTALLED APP add ‘corsheaders’,
  - MIDDLEWARE add 'corsheaders.middleware.CorsMiddleware',
  - CORS_ORIGIN_ALLOW_ALL = True 

*can now accept request from different origins (different port), but this is not recommended in production* (TODO: then what's recommended?)

### ANGULAR SETTING
- `ng new <app name>`
- `ng serve` this will start a server.

### BOOTSTRAP ANGULAR UNDER DJANGO

*words in **bold** are needed after editing Angular code and want to run the project in Django.*

- **Build angular to create /dist/**
- Add /dist/ in django static settings
  - NOTICE! Set ANGULAR_APP_DIR to  'angular-frontend/dist/angular-frontend'. Have to go one level deeper in dist; otherwise Django static routing will fail
- **collectstatic**
- Let django serve angular’s index.html as start point
- Add routing for any angular /static/ request, see `urlpatterns` part in [this article](https://www.techiediaries.com/django-angular-cli/)

### DEPLOY TO HEROKU
- Heroku Bootstrapping...following [this heroku dev post](https://devcenter.heroku.com/articles/django-app-configuration#migrating-an-existing-django-project)
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

### DEPLOY TO AWS Elastic Beanstalk

We'll mainly use [this tutorial](http://www.1strategy.com/blog/2017/05/23/tutorial-django-elastic-beanstalk/) to deploy Django to Elastic Beanstalk.

- Have your model.py ready
- Setup Elastic Beanstalk environment
  - `pip install psycopg2 mako awsebcli // these should already be covered in requirements.txt`
  - `eb init`
    - interactive prompt: 
      - setup data center location. Use US East (Ohio) to have best proximity for Mid-West area. 
      - choose CNAME (prefix for the website URL)
    - get a aws credential and insert. see below.
      - IAM
        - visit [IAM site](https://console.aws.amazon.com/iam/home)
        - goto left side bar: User --> add user --> check programmatic access --> next
        - follow instructions on [tutorial](http://www.1strategy.com/blog/2017/05/23/tutorial-django-elastic-beanstalk/)
        - (edit permission later for production)
        - save secret keys
        - enter these keys in console prompt
- Additional Configs
  - create the folder & file `.ebextensions/python.config`
  - for the complete content for `python.config`, refer to the tutorial.
  - make sure you change Django's collectstatic output folder to be under www: `STATIC_ROOT = os.path.join(BASE_DIR, "www", "static")`
  - if you use `django_heroku.settings(locals())` for deploying to heroku, make sure to only running that on heorku by surrounding it with `elif 'DATABASE_URL' in os.environ:`. `django_heroku` will change collectstatic output to `project_root/staticfiles`, which will cause problems for eb to access static files.
- git add, git commit, then `eb create --scale 1 -db -db.engine postgres -db.i db.t2.micro`
  - see details of the prompts in tutorial.
  
*this will start deploying to eb for the very first time.*

- From now on, do your work, commit git, then do `eb deploy`
- [Elastic Beanstalk Main Page](https://console.aws.amazon.com/elasticbeanstalk/home).
- If you want to **connect to database** on amazon RDS in other clients e.g. postgresql GUI apps, heroku, ...
  - Edit amazon RDS permission, see [heroku doc](https://devcenter.heroku.com/articles/amazon-rds) or [here](https://stackoverflow.com/questions/47661151/connecting-to-rds-postgres-from-heroku)
    1. let RDS always require SSL
       - **Amazon RDS/Parameter Groups**: Create a new parameter group to [force ssl](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts.General.SSL), if you don’t already have such group.
       - **Amazon RDS/Instance/modify database/DB parameter group:** enable group for ssl
    2. reboot the RDS instance immediately to force SSL!
    3. let RDS allow all inbound IP: Security Group (the one used by db)/Inbound: create rule for all traffic.
    4. let local/client db connection use SSL
       - turn on ssl, use `sslmode=require` *the amz official and heroku ask you to use `sslmode=verify-full`; then download a [certificate](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts.General.SSL) and using it with the connection by specifying its file path in `sslrootcert=...`; however, you can just use `require` if that works for you*
  - get a decent database GUI client. DBeaver is OK. Can try [PgAdmin](https://www.pgadmin.org/).
    - test the connection. just hardcode the credentials obtained from the RDS console.
- **TODO: Domain name - it's ugly now. how to change it?**
- future: [separate front/back end on different platform](https://stackoverflow.com/questions/41247687/how-to-deploy-separated-frontend-and-backend)
  - Frontend: GitHub Pages + CloudFlare
  - Backend: beanstalk
  - Cross domain setting: jwt

### TODO: ANGULAR [ROUTING](https://angular.io/tutorial/toh-pt4) & GET STARTED

- How does Angular deal with different page & always-existing sticky nav bar?
  - can use iriversland basic layout (nav, etc) for testing.
  
### DJANGO RESTFUL API TEST POST | GET

- For testing RESTful purpose, setup new repo to push to
  - git remote set-url origin git@bitbucket.org:iriver/iriversland2.git
  - git push 
- Django create app `./manage.py startapp <app name>`
- Create model
  - create empty custom user model: 
    - setup `AUTH_USER_MODEL`, select an app or create a new one like `account`, in its model `from django.contrib.auth.models import AbstractUser` then `class CustomUser(AbstractUser):` can just do a `pass`.
    - If you do want to change some stuff in the user model, see [this post](https://stackoverflow.com/questions/45722025/forcing-unique-email-address-during-registration-with-django), e.g. make email unique, ...etc.
      - you can also add email, first/last name to REQUIRED_FIELDS (a class attr) in CustomUser
- Setup database model
  - Recheck model no problem?
  - `makemigrations`, then `migrate`
    - create superuser to test out
  - Deploy on eb
  - Add migrate command in python.config
  - Import your table's data if necessary. Notice foreign key field, its value needs to exist.
- Install restful and get started using [official doc](http://www.django-rest-framework.org/tutorial/quickstart/) quick start.
- Attaching an API to existing model - trying w/ model Post
  - Create serializer for that model
  - Create view or viewset fetching model and the serializer
  - Setup url routing
- Test in server!
- TODO: see how we can use it, to do CRUD operations. Use [this tutorial](https://www.techiediaries.com/tutorial-django-rest-framework-building-products-manager-api/) to figure out the RESTful class view by looking at their functional programming alternatives. 
- TODO: Setup security: require login or certain user to access API.
- **TODO: Angular try to request a POST, see if no error**
- Try to reset the Django project to a cleaner file tree. Try adding a dot at the end when creating django project, this makes file tree very clean! Recreate django --> copy codes --> try deploy to eb.

## Reference

- [Building Modern Web Apps with Python, Django Rest Framework and Angular 4|5](Building Modern Web Apps with Python, Django Rest Framework and Angular 4|5) 
  - How to: [Django + Angular]
  - Test Ajax to backend in Angular
- [Getting started with Django Rest Framework by Building a Simple Product Inventory Manager](https://www.techiediaries.com/tutorial-django-rest-framework-building-products-manager-api/)
  - Setup RESTful framework for Django.
  - Provides functional programming examples to clearly illustrate what restful class view does for you. Good for customizing things later on.
  - [Tutorial: Deploying Python 3, Django, PostgreSQL to AWS Elastic Beanstalk](http://www.1strategy.com/blog/2017/05/23/tutorial-django-elastic-beanstalk/)
