# Docker WoW Builder

After much time, effort, and swearing Chris Hill found a [repository](https://github.com/JustinChristensen/trinitycore-dockerfile) where someone had done essentially what we wanted. Unfortunately, due to the fluidity of the Trinity build environment, this still needed some work on my end to make it do *exactly* what we want.

## What does this thing even do?

This is an *all-in-one* Trinity-Core stack meant to run the 3.3.5 branch.

This Docker stack builds images for a base server, a data server, an authentication server, and a world server. The base server is used as a base image for the authentication and world server. The data server is just a MariaDB container with a thin wrapper letting you arbitrarily load in whatever databases you want.

## How do I run this thing?

```
/start.sh
```

You're done.

Haha, ok, maybe it's a little more complex than that, but not by much.

You can choose to either just clone down and run the start.sh script in the trinity-docker folder (which will run *everything* like a good boy) or you can run piecemeal.

### Everything at once

Literally just navigate to the trinity-docker folder, modify to suit your needs, and run `/start.sh`. Wait.

The bits that you *need* to change are:

1. In the creds folder you need files for the root MYSQL password (mysql_root_password.cred) and the user MYSQL password (mysql_pass.cred)
1. In the start shell script you need to change the environment variable to point at the correct destination of the WoW client.

There are lots of other choices you can make in the install, but those are likely the only *required* changes.

### Running things piecemeal

1. You need to create a Docker volume that holds the client data in order for the tools to unpack all the maps. Look inside the `start.sh` script for the syntax and structure on exactly how to do that and feel free to reach back to me with questions.
2. You need to build the [dataserver](dataserver/readme.md) image.
3. You need to build the [base](base/readme.md) image.
4. You need to build the [authserver](authserver/readme.md) image.
5. You need to build the [worldserver](worldserver/readme.md) image.

Again, see the start.sh for the quick and easy way to do this, or reach out to me and yell at me for how poor my documentation is and I'll make it better.

## **Known Issues**

1. The World Server stops printing output before it's done spinning up. This is 'fixed' by forcing the server to use a tty. See the compose file.

2. The Trinity Core devs play pretty fast and loose with the database structure and the codebase and in the four week span where I was trying to get this working they introduced a number of *features* which broke my build by changing the database structure. In the authserver directory there is a `create_root.sql` file which is run when the container spins up. Notice there are some commented lines? Well, depending on *which* database and commit you're using you need to uncomment one of them.

Thanks guys, I appreciate that. I get that you're a bunch of randoms who are working together but is there *anyone* in charge of design? Rant over.
