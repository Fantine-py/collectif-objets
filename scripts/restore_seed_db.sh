curl https://s3.fr-par.scw.cloud/collectif-objets-public/seeds.pgsql | \
  pg_restore --clean --if-exists --no-owner --no-privileges --no-comments --dbname $SCALINGO_POSTGRESQL_URL