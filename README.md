# Skeema with Gh-ost

## Initial setup

1. Start up MySQL instances: `COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose up -d`
2. Start our `skeema` container: `COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose run --rm skeema bash`
3. Initialize skeema with `production` database instance (wait for the MySQL servers to finish initializing or you'll get a connection error): `skeema init production -h mysql-production -u root -d schemas -d schemas`
4. Add our `development` database instance: `skeema add-environment development -h mysql-development -u root -d schemas`
5. Add our `staging` database instance: `skeema add-environment staging -h mysql-staging -u root -d schemas`
6. View the files generated in `./skeema-data/schemas`

## Comparing and Promoting Environments

To see the differences between `development` and `staging`, with the intention of promoting `development` changes to the `staging` database instance:
1. Set `development` to the base environment to compare to: `skeema pull development`
2. View differences between `development` and `staging`: `skeema diff staging` 
    ```
    root@84c67edde143:/skeema# skeema pull development
    2022-03-20 19:34:50 [INFO]  Updating /skeema/schemas/my_database to reflect mysql-development:3306 my_database
    2022-03-20 19:34:50 [INFO]  Wrote /skeema/schemas/my_database/my_table.sql (505 bytes)

    root@84c67edde143:/skeema# skeema diff staging
    2022-03-20 19:34:55 [INFO]  Generating diff of mysql-staging:3306 my_database vs /skeema/schemas/my_database/*.sql
    -- instance: mysql-staging:3306
    USE `my_database`;
    ALTER TABLE `my_table` ADD COLUMN `last_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL AFTER `first_name`;
    2022-03-20 19:34:55 [INFO]  mysql-staging:3306 my_database: diff complete
    ```
3. See the "dry run" of what `skeema` would do on a `push`: `skeema push staging --dry-run --alter-wrapper="gh-ost --user={USER} --host={HOST} --port={PORT} --database={SCHEMA} --table={TABLE} --alter={CLAUSES} --allow-on-master --verbose --initially-drop-ghost-table --initially-drop-old-table --ok-to-drop-table --switch-to-rbr"`
    ```
    root@84c67edde143:/skeema# skeema push staging --dry-run --alter-wrapper="gh-ost --user={USER} --host={HOST} --port={PORT} --database={SCHEMA} --table={TABLE} --alter={CLAUSES} --allow-on-master --verbose --initially-drop-ghost-table --initially-drop-old-table --ok-to-drop-table --switch-to-rbr"
    2022-03-20 19:36:23 [INFO]  Generating diff of mysql-staging:3306 my_database vs /skeema/schemas/my_database/*.sql
    -- instance: mysql-staging:3306
    USE `my_database`;
    \! gh-ost --user=root --host=mysql-staging --port=3306 --database=my_database --table=my_table --alter='ADD COLUMN `last_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL AFTER `first_name`' --allow-on-master --verbose --initially-drop-ghost-table --initially-drop-old-table --ok-to-drop-table --switch-to-rbr
    2022-03-20 19:36:23 [INFO]  mysql-staging:3306 my_database: diff complete
    ```
4. Run `skeema` without `--dry-run` to apply: `skeema push staging --alter-wrapper="gh-ost --user={USER} --host={HOST} --port={PORT} --database={SCHEMA} --table={TABLE} --alter={CLAUSES} --allow-on-master --verbose --initially-drop-ghost-table --initially-drop-old-table --ok-to-drop-table --switch-to-rbr"`
5. Run diff again to see the changes applied successfully: `skeema diff staging`

To see the differences between `staging` and `production`, with the intention of promoting `staging` changes to the `production` database instance:
1. Set `staging` to the base environment to compare to: `skeema pull staging`
2. View differences between `staging` and `production`: `skeema diff production`
3. See the "dry run" of what `skeema` would do on a `push`: `skeema push production --dry-run --alter-wrapper="gh-ost --user={USER} --host={HOST} --port={PORT} --database={SCHEMA} --table={TABLE} --alter={CLAUSES} --allow-on-master --verbose --initially-drop-ghost-table --initially-drop-old-table --ok-to-drop-table --switch-to-rbr"`
4. Run `skeema` without `--dry-run` to apply: `skeema push production --alter-wrapper="gh-ost --user={USER} --host={HOST} --port={PORT} --database={SCHEMA} --table={TABLE} --alter={CLAUSES} --allow-on-master --verbose --initially-drop-ghost-table --initially-drop-old-table --ok-to-drop-table --switch-to-rbr"`
5. Run diff again to see the changes applied successfully: `skeema diff production`

## References

- https://www.skeema.io/docs/config/
- https://www.skeema.io/docs/options/#schema
- https://github.com/github/gh-ost