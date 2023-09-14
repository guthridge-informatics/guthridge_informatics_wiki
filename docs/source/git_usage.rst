Git
===
`Git <https://git-scm.com/>`_ is a version control system originally developed for software development; however, since source code is typically plain text,
git works well to store and track changes to analysis scripts and notebooks.


Git global setup ::

   git config --global user.name "Miles Smith"
   git config --global user.email "mileschristiansmith@gmail.com"

Create a new repository ::

   git clone git@gitlab.com:guthridge_informatics/guthridge_informatics_wiki.git
   cd guthridge_informatics_wiki
   touch README.md
   git add README.md
   git commit -m "add README"
   git push -u origin master

Push an existing folder::

   cd existing_folder
   git init
   git remote add origin git@gitlab.com:guthridge_informatics/guthridge_informatics_wiki.git
   git add .
   git commit -m "Initial commit"
   git push -u origin master

Push an existing Git repository::

   cd existing_repo
   git remote rename origin old-origin
   git remote add origin git@gitlab.com:guthridge_informatics/guthridge_informatics_wiki.git
   git push -u origin --all
   git push -u origin --tags

Setting up to use Gitlab
~~~~~~~~~~~~~~~~~~~~~~~~~

Setup and add an `ssh private key <https://docs.gitlab.com/ee/ssh/
README.html#generating-a-new-ssh-key-pair>`_ to your account.

If the you encounter this error when trying to test the new key... ::

   user@computer:~/$ ssh -T git@gitlab.com
   git@gitlab.com: Permission denied (publickey)

then you probably need to explicitly tell git which ssh key to use with Gitlab.
First test to see it that is the problem by running ::

   user@computer:~/$ ssh -T git@gitlab.com -i ~/.ssh/gitlab_key

If now you see something like::

   Welcome to GitLab, @milothepsychic!

Then you will need to setup git to explicitly use that key.  Use a text editor
to create or add to ``~/.ssh/config``::

   host gitlab.com
    HostName gitlab.com
    IdentityFile ~/.ssh/gitlab_key
    User git

.. note::
   Of course Github has to be different and requires a few extra lines. For
   a public key to work with Github, instead add ::

      host github.com-milescsmith
        HostName github.com
        IdentityFile ~/.ssh/github
        User git
        AddKeysToAgent yes
        PreferredAuthentications publickey

   You will then need to register the key with the ssh-agent ::

      ssh-add ~/.ssh/github

If that file is new, then change the permissions::

   user@computer:~/$ chmod 600 ~/.ssh/config

Place the following to your `~/.bashrc` file to start the ssh agent: ::

   # Set up ssh-agent
   SSH_ENV="$HOME/.ssh/environment"

   function start_agent {
      echo "Initializing new SSH agent..."
      touch $SSH_ENV
      chmod 600 "${SSH_ENV}"
      /usr/bin/ssh-agent | sed 's/^echo/#echo/' >> "${SSH_ENV}"
      . "${SSH_ENV}" > /dev/null
      /usr/bin/ssh-add
   }

   # Source SSH settings, if applicable
   if [ -f "${SSH_ENV}" ]; then
      . "${SSH_ENV}" > /dev/null
      kill -0 $SSH_AGENT_PID 2>/dev/null || {
         start_agent
      }
   else
      start_agent
   fi

Add the new ssh key to the agent ::

   ssh-add ~/.ssh/github
   
And then reload the environment with ::

    source ~/.bashrc