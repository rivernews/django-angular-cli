git_commit_msg=

if [[ $1 == '' ]]
then
    git_commit_msg=fix
else
    git_commit_msg="$1"
fi

if [[ $2 == 'dev' ]]
then
    heroku git:remote -a iriversland2
else
    heroku git:remote -a iriversland2
fi

git add .
git commit -m "$git_commit_msg"
git push heroku # heroku git:remote -a iriversland || dev-iriversland
# git push github
git push