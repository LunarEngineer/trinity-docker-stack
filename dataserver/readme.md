# Trinity Docker Data Server

This is a Maria DB container that also installs some minimal dependencies:
* Libreadline
* 7-zip
* jq
* curl

This is a pretty simple image. It slurps up some credential files that you **need** to have created. In the `creds` folder ensure you put a mysql_pass.cred file and a mysql_root_password.cred file, both containing nothing but the passwords you wish to use.

### Fresh or Frozen Data

This will create the databases from scratch, import a backup to create the databases, or just start with existent data.

Currently this is hard coded to eat certain SQL files in the database populater script. Check in there to see *for sure* what's going on.

## TL;DR: Build Arguments

### Data Creation Arguments

* CREATE_DATABASES - Boolean flag. If set to 1 then this will download the Trinity Core TDB specified. If you want a *specific* TDB then ensure that the TRINITYCORE_TDB="whatever the url is" and it will download that specific version.
* IMPORT_DATABASES - Boolean flag. If set to 1 then this will ingest a SQL dump and instantiate the databases that way. This is not intended to be used in conjunction with CREATE_DATABASES.
* CUSTOM_SQL - Boolean flag. If set to 1 then this will copy the contents of the custom_sql folder in and will run them while populating the databases. These are executed in 'name' order and so if you want to *ensure* that one file is run before another prepend it with a number like '45_do_stupid_things_to_my_data.sql' or '99_another_bad_idea.sh'.
* TRINITY_CORE_TDB - This will download the SQL files from this URL.

### Database User and Password Arguments

You very likely should not be messing with this at all unless you are *very* sure you want to.

* MYSQL_ROOT_PASSWORD_FILE - Specifies the location in the container to pull the root password from.
* MYSQL_USER - The name of the default user.
* MYSQL_PASSWORD_FILE - Specifies the location in the container to pull the user password from.
* MYSQL_DATABASE - The name of the default database.
* MYSQL_HOST - The IP address (or hostname) of the data server.
* MYSQL_PORT - The port to serve data on.

## What Exactly Does It Do?

This builds the data server for the Trinity stack dependent on how you tell it to and, as part of the compose recipe, will create a persistent volume that contains the database.

## How Exactly Does It Do It?

Prior to running this you likely need to be aware of the [Trinity Core Install Documentation](https://trinitycore.atlassian.net/wiki/spaces/tc/pages/2130077/Installation+Guide), even if you're just going to run this blindly. Although the documentation can be frustrating, incomplete, glosses over assumptions, and other quibbles I have, I don't know that I'm much better...

When running this for the first time you need to decide to either:

1. Start from a known TDB file (read the TC documentation and look at the SQL downloads) and pass that file URL as "TRINITYCORE_TDB" with CREATE_DATABASES=1. This will build a fresh database from the specified TDB url.
1. Start from the latest TDB file (read the TC documentation and look at the SQL downloads) by *not passing* "TRINITYCORE_TDB" with CREATE_DATABASES=1. This will build a fresh database from the latest TDB url available.
1. Start from an existing database dump. This requires you to use [mysqldump](https://dev.mysql.com/doc/refman/8.0/en/mysqldump.html) to dump your existent databases to a file. You need to ensure that file is placed into the ./dataserver/baked_scripts folder and named `02_import_db.sql`. Then change the IMPORT_DATABASES flag in the build to 1.
2. In addition to or just by itself you can choose to run custom sql on startup by changing the CUSTOM_SQL flag to 1 and dropping those SQL statements in the ./dataserver/custom_sql folder.

In practice you will likely use the CREATE_DATABASES flag during the initial install, will use the CUSTOM_SQL as necessary to 'unfix' things that the Trinity Core devs have done, will use the IMPORT_DATABASES flag when restoring from a SQL dump (say after you've done something catastrophically stupid), and otherwise will simply set all the flags to zero while you're in maintenance mode.

### Security (Environment Variables MYSQL_ROOT_PASSWORD_FILE and MYSQL_PASS_FILE)

This uses the Docker Compose 'Secrets' capability. Basically that means that you create a file with a 'secret'. In this case you need to create two files:

* mysql_root_password_file.cred
* mysql_pass_file.cred

For ease simply put these in the creds folder and name them exactly as above. Just put a single string password in each. The way that Docker compose secrets work ensures that, although they are *not* available during build, there will be files located at /var/run/secret with the *same* names as above, without .cred appended.

The password for the Trinity user is a *default* password that (if you wish to change) needs to be changed after the build.

This is on my list of 'stuff I will figure out how to fix'; the files are not available during the build process.

An alternative way to set a different password for the Trinity user is to edit the 01_create_db.sql script in the baked_scripts directory.

### Users and Databases (Environment Variables MYSQL_DATABASE, MYSQL_HOST, and MYSQL_PORT)

This uses a script in the baked sql folder `00_create_db.sql` to create the Trinity user with the default password.

It also creates the auth, characters, and world databases and sets the IP address of the server.

### Build Process

During the build process this just moves scripts around. Scripts to be run are put into the entrypoint directory and when the MariaDB docker-entrypoint.sh script fires it will run *any* additional scripts found in the entrypoint directory.

Depending on what you selected (create, build, custom scripts) it will copy in the database creation scripts, the SQL dump, and any custom scripts you've added.

### Custom Scripts

The database creation scripts are intentionally prepended with low numbers to ensure they are run first. If you add custom SQL and scripts you should think critically about when you want them to run and name them accordingly.

### Backup and Restore

To restore from a SQL dump see the Build Arguments section above.

To *dump* from the database in this container see the syntax below.

```
docker exec trinity-docker_db_1 sh -c 'exec mysqldump --databases world characters auth -uroot -p"$MYSQL_ROOT_PASSWORD"' > /some/path/on/your/host/db_bkp.sql
```

This command uses the *running* database container named trinity-test_db_1 (change this to appropriately match your container name) to create a database backup.

Why would you want to do this? Do you have data in the server that you (or someone else) has put some time and effort into? Do you want them to lose that because you were careless? No? Don't be a fool, use a backup tool.

## Possible Future Improvements

1. Secure password set correctly during the build process.
2. Maybe remove the git dependency and just use curl? Using git is so much *easier*, though.
